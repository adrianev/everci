/**
 * Clase de funciones auxiliares relativas a las bitácoras.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Bitacora {

	/**
	 * Método que busca bitácoras por query.
	 *
	 * @param setIdBitacora: IDs de las bitácoras a buscar
	 * @param setNameBitacora: nombres de las bitácoras a buscar
	 * @param filtro: otras condiciones del Where
	 *
	 * @return lista con bitácoras resultantes de la query
	 */
	/*public static List<INT_Bitacora__c> queryBitacora(Set<Id> setIdBitacora, Set<String> setNameBitacora, String filtro){
        system.debug('<<<<<<<sera arg1, 1rg2, arg3>>>>>>>>>>' + setIdBitacora + ' / ' + setNameBitacora + ' / ' + filtro);
		Boolean arg1 = setIdBitacora != null && !setIdBitacora.isEmpty();
		Boolean arg2 = setNameBitacora != null && !setNameBitacora.isEmpty();
		Boolean arg3 = filtro != null;
        system.debug('<<<<<<<sera arg1, 1rg2, arg3>>>>>>>>>>' + arg1 + arg2 + arg3);
		List<INT_Bitacora__c> bitacoras = new List<INT_Bitacora__c>();
		if(arg1 || arg2 || arg3){
			String sentenciaOT = 'SELECT Id,';
			sentenciaOT += ' Name,';
			sentenciaOT += ' RecordTypeId,';
			sentenciaOT += ' BIT_SEL_Tipo_Integracion__c,';
			sentenciaOT += ' BIT_SEL_Estado__c,';
			sentenciaOT += ' BIT_FOR_Id_Fichero__c,';
			sentenciaOT += ' BIT_NUM_Lote__c,';
			sentenciaOT += ' BIT_NUM_Reintentos__c,';
			sentenciaOT += ' BIT_TXT_Error__c,';
			sentenciaOT += ' BIT_TXT_Nombre_Integracion__c,';
			sentenciaOT += ' BIT_TXT_Json__c,';
			sentenciaOT += ' BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__r.FIC_TXT_Query__c';
			sentenciaOT += ' FROM INT_Bitacora__c';
			String sentenciaOT_where = ' WHERE ';
			if(arg1 && !arg2){
				sentenciaOT_where += 'Id IN :setIdBitacora';
			}
			else if(!arg1 && arg2){
				sentenciaOT_where += 'Name IN :setNameBitacora';
			}
			else if(arg1 && arg2){
				sentenciaOT_where += '(Id IN :setIdBitacora OR Name IN :setNameBitacora)';
			}
			if(arg3){
				if(sentenciaOT_where != ' WHERE '){
					sentenciaOT_where += ' AND ';
				}
				sentenciaOT_where += '('+filtro+')';
			}
			sentenciaOT += sentenciaOT_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Bitacora.queryBitacora.sentenciaOT: ' + sentenciaOT);
			bitacoras = database.query(sentenciaOT);
		}
		return bitacoras;
	}*/

	/**
	 * Método que devuelve mapa de bitácoras a partir del Set<ID>.
	 *
	 * @param setIdBitacora: Set<ID> de la bitácora a buscar
	 *
	 * @return mapa de bitácoras encontradas
	 */
	public static Map<Id,INT_Bitacora__c> queryBitacora(Set<ID> setIdBitacora){
		Map<Id,INT_Bitacora__c> mapa = new Map<Id,INT_Bitacora__c>();
		if(setIdBitacora != null && !setIdBitacora.isEmpty()){
			for(List<INT_Bitacora__c> lb:[SELECT Id,
													RecordTypeId,
													BIT_LKP_Compania__c,
													BIT_SEL_Estado__c,
													BIT_NUM_Lote__c,
													BIT_TXT_Nombre_Fichero__c,
													BIT_LKP_Envio_Programado_CIA__c,
													BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__r.Name
			                              FROM INT_Bitacora__c 
			                              WHERE Id IN: setIdBitacora ]){
				mapa.putAll(lb);
			}
		}
		return mapa;
	}

	public static Map<String, INT_Bitacora__C> queryBitacoraByEstadoYLote(Set<String> setEstados,Set<Decimal> setLotes) {
		Map<String, INT_Bitacora__c> mapBitacora=new Map<String, INT_Bitacora__c>();
		if(!setEstados.isEmpty() && !setLotes.isEmpty()) {
			for(List<INT_Bitacora__c> listBitacoras:[SELECT Id,RecordTypeId, BIT_SEL_Tipo_Integracion__c
														FROM INT_Bitacora__c WHERE BIT_SEL_Estado__c IN :setEstados AND BIT_NUM_Lote__c IN: setLotes]) {
				mapBitacora.putAll(listBitacoras);
			}
		}
		return mapBitacora;
	}
	
	public static Map<String, INT_Bitacora__C> queryBitacoraByFechaRecordTypeAndEstado(Set<Date> setFecha,Set<Id> setRecordType,Set<String> setEstado) {
		Map<String, INT_Bitacora__c> mapBitacora=new Map<String, INT_Bitacora__c>();
		if(!setFecha.isEmpty() && !setRecordType.isEmpty() && setEstado.isEmpty()) {
			for(List<INT_Bitacora__c> listBitacoras:[SELECT Id FROM INT_Bitacora__c
														WHERE LastModifiedDate <: setFecha AND RecordTypeId  =: setRecordType AND BIT_SEL_Estado__c =: setEstado]) {
				mapBitacora.putAll(listBitacoras);
			}
		}
		return mapBitacora;
	}
}