/**
 * Clase de funciones auxiliares para los telefonos Transfer CIA
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Telef_TransferCIA {

	/**
	 * Devuelve un mapa de teléfonos de transferCIA a partir de un conjunto de IDs.
	 *
	 * @param setIdTelefonoCIA: IDs de los teléfonos a buscar
	 * @return mapa de teléfonos transferCIA encontrados
	 */
	public static Map<Id,Telefonos_Transfer_CIA__c> queryMapTelefonoTransferCIA(set<Id> setIdTelefonoCIA){
		Map<Id,Telefonos_Transfer_CIA__c> mapa = new Map<Id,Telefonos_Transfer_CIA__c>();
		if(setIdTelefonoCIA != null && !setIdTelefonoCIA.isEmpty()){
			for(List<Telefonos_Transfer_CIA__c> lista : [SELECT Id,
																Name,
																TTC_TXT_Ayuda__c,
																TTC_LKP_Cuenta__c,
																TTC_TXT_Descripcion__c
														FROM Telefonos_Transfer_CIA__c
														WHERE Id IN :setIdTelefonoCIA]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve un teléfono de transferCIA a partir de un Id.
	 *
	 * @param idTelefonoCIA: Id del teléfono_Transfer_CIA
	 * @return teléfono transferCIA del ID especificado
	 */
	/*public static Telefonos_Transfer_CIA__c queryTelefonoTransferCIA(Id idTelefonoCIA){
		Telefonos_Transfer_CIA__c telf = null;
		List<Telefonos_Transfer_CIA__c> lista = new List<Telefonos_Transfer_CIA__c>();
		if(idTelefonoCIA != null){
			lista = [SELECT Id,
							Name,
							TTC_TXT_Ayuda__c,
							TTC_LKP_Cuenta__c,
							TTC_TXT_Descripcion__c
					FROM Telefonos_Transfer_CIA__c WHERE Id = :idTelefonoCIA];
		}
		if(!lista.isEmpty()){
			telf = lista.get(0);
		}
		return telf;
	}*/

	public static List<SelectOption> buscarTelefonos(Id compania){
		List<SelectOption> listaTelefonos = new List<SelectOption>();
		List<Telefonos_Transfer_CIA__c> listaTelefonica = Util_CTI.queryTransferPhoneByCia(new Set<Id>{compania}).values();
		listaTelefonos.add(new SelectOption('', 'TELÉFONOS DE CONSULTA'));
		for (Telefonos_Transfer_CIA__c tel : listaTelefonica){
			listaTelefonos.add(new SelectOption(tel.Id, tel.TTC_TXT_Descripcion__c));
		}
		return listaTelefonos;
	}

	public static void mostrarAyudaTelefonoCompania(String idTelefonoCia) {
			if (!String.isEmpty(idTelefonoCia)) {
				Telefonos_Transfer_CIA__c telTransferCIA = Util_Telef_TransferCIA.queryMapTelefonoTransferCIA(new set<Id>{idTelefonoCIA}).get(idTelefonoCIA);
				//Telefonos_Transfer_CIA__c telTransferCIA = Util_Telef_TransferCIA.queryTelefonoTransferCIA(idTelefonoCIA);
				if (telTransferCIA != null) {
					String ayuda = telTransferCIA.TTC_TXT_Ayuda__c;
					// Adding HTML tag to phone
					Pattern pat = Pattern.compile('(Tfno:\\s+)([0-9|\\s]+)(\\b)([\\s\\.\\n])');
					Matcher mat = pat.matcher(ayuda);
					while(mat.find()){
						system.debug('grupo '+mat.group());
						String phone = mat.group(2).remove(' ');
						// Phone with blank spaces
						String phoneBS = mat.group(2);
						system.debug('RPM>>>phone: ' + phone + ' - phoneBS: ' + phoneBS);
						ayuda = ayuda.replace(phoneBS, '<a href="javascript:void(0);" onclick="clickPhone(this, \''+ phone +'\')">'+  phoneBS   + '</a>'); 
					}
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ayuda));
				}
			} 
		}
}