/**
 * Clase de funciones auxiliares relativas a Telefonía.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_CTI
{

	/**
	 * Devuelve las compañías VDN filtradas por nombres.
	 *
	 * @param setName: conjunto de nombres
	 *
	 * @return mapa que contiene las compañías VDN encontradas
	 */
	public static Map<Id,VDN_Compania__c> getVDNByName(Set<String> setName){
		Map<Id,VDN_Compania__c> mapa = new Map<Id,VDN_Compania__c>();
		if(setName != null && !setName.isEmpty()){
			for(List<VDN_Compania__c> lista:[SELECT Name,
													VDN_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													VDN_FOR_Cuenta__c,
													VDN_FOR_CuentaIdRT__c,
													VDN_LKP_Compania__c,
													VDN_LKP_Compania__r.Type,
													VDN_LKP_Compania__r.CUE_TXT_Identificador__c,
													VDN_LKP_Compania__r.Name,
													VDN_LKP_Compania__r.CUE_FOR_RTDevName__c,
													VDN_TXT_Ayuda_Busqueda__c,
													VDN_LKP_Compania__r.RecordType.Id,
													VDN_TXT_Presentacion__c
											 FROM VDN_Compania__c
											 WHERE Name IN :setName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Extrae lista de compañías por VDN
	 * 
	 * @param vdn VDN de compañía a buscar
	 * @return lista de compañías que coinciden con VDN
	 */
	/*public static List<VDN_Compania__c> queryVDN(String vdn)
	{
		List<VDN_Compania__c> listaVDN = new List<VDN_Compania__c>();
		if (vdn != null)
		{
			String sentencia = 'SELECT Id,';
			sentencia += ' Name,';
			sentencia += ' VDN_FOR_Cuenta__c,';
			sentencia += ' VDN_FOR_CuentaIdRT__c,';
			sentencia += ' VDN_LKP_Compania__c,';
			sentencia += ' VDN_LKP_Compania__r.Type,';
			sentencia += ' VDN_LKP_Compania__r.CUE_TXT_Identificador__c,';
			sentencia += ' VDN_LKP_Compania__r.Name,';
			sentencia += ' VDN_LKP_Compania__r.CUE_FOR_RTDevName__c,';
			sentencia += ' VDN_TXT_Ayuda_Busqueda__c,';
			sentencia += ' VDN_LKP_Compania__r.RecordType.Id,';
			sentencia += ' VDN_TXT_Presentacion__c';
			sentencia += ' FROM VDN_Compania__c';
			sentencia += ' WHERE Name = \'' + vdn + '\'';
			listaVDN = database.query(sentencia);
		}
		return listaVDN;
	}*/
	
	/**
	 * Extrae mapa de compañías por VDN
	 * 
	 * @param set de vdn VDN de compañía a buscar
	 * @return mapa de compañías que coinciden con VDN
	 */
	public static Map<Id, VDN_Compania__c> queryMapVDN(Set<String> setVdn){	
		Map<Id, VDN_Compania__c> mapaVDN = new Map<Id, VDN_Compania__c>();
		if(setVdn != null && !setVdn.isEmpty()){
			for(List<VDN_Compania__c> listaVDN : [SELECT Id,
													   Name,
													   VDN_FOR_Cuenta__c,
													   VDN_FOR_CuentaIdRT__c,
													   VDN_LKP_Compania__c,
													   VDN_LKP_Compania__r.Type,
													   VDN_LKP_Compania__r.CUE_TXT_Identificador__c,
													   VDN_LKP_Compania__r.Name,
													   VDN_LKP_Compania__r.CUE_FOR_RTDevName__c,
													   VDN_TXT_Ayuda_Busqueda__c,
													   VDN_LKP_Compania__r.RecordType.Id,
													   VDN_TXT_Presentacion__c
												FROM VDN_Compania__c
												WHERE Name IN :setVdn]){
				mapaVDN.putAll(listaVDN);
			}
		}
		return mapaVDN;
	}
	
	/**
	 * Extrae mapa de teléfonos de transferencia por el ID de compañía
	 * 
	 * @param setIdCia - cia ID de compañia a buscar
	 * @return mapa de telefonos que coinciden con la compañia
	 */
	public static Map<Id, Telefonos_Transfer_CIA__c> queryTransferPhoneByCia(Set<Id> setIdCia){	
		Map<Id, Telefonos_Transfer_CIA__c> mapaTelefonos = new Map<Id, Telefonos_Transfer_CIA__c>();
		if(setIdCia != null && !setIdCia.isEmpty()){
			for(List<Telefonos_Transfer_CIA__c> listaVDN:[SELECT Id,TTC_TXT_Descripcion__c FROM Telefonos_Transfer_CIA__c WHERE TTC_LKP_Cuenta__c IN :setIdCia]){
				mapaTelefonos.putAll(listaVDN);
			}
		}
		return mapaTelefonos;
	}
	
		/**
	 * Extrae mapa de teléfonos por Descripcion LIKE
	 * 
	 * @param setLike - conjunto de Strings a usar en la comparacion LIKE  (usar sin %)
	 * @return mapa de telefonos que coinciden con la compañia
	 */
	public static Map<Id, Telefonos_Transfer_CIA__c> getTelefonosTransfer_CIAByDescripcionLike(Set<String> setLike){	
		Map<Id, Telefonos_Transfer_CIA__c> mapaTelefonos = new Map<Id, Telefonos_Transfer_CIA__c>();
		
		String[] filters = new String[]{};
		for(String st :setLike){
			filters.add('%'+st);
		}
		
		if(setLike != null && !setLike.isEmpty()){
			for(List<Telefonos_Transfer_CIA__c> listaVDN :
	[               Select 	Id
                    FROM	Telefonos_Transfer_CIA__c 
                    Where	TTC_TXT_Descripcion__c like: filters]){
				mapaTelefonos.putAll(listaVDN);
			}
		}
		return mapaTelefonos;
	}
}