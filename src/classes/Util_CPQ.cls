/**
 * Clase de funciones auxiliares relativas a las Compañías.
 * 
 * @author EVERIS
 */
public without sharing class Util_CPQ {
	/**
	 * Devuelve los Registros de configuración BigMachines filtradas por BigMachines__bm_site__c
	 *
	 * @param setDominio: conjunto de nombres del site del registro
	 *
	 * @return mapa que contiene los Registros de configuración BigMachines
	 */
	public static Map<Id,BigMachines__Configuration_Record__c> getBigMachRecBySite(Set<String> setDominio){
		Map<Id,BigMachines__Configuration_Record__c> mapa = new Map<Id,BigMachines__Configuration_Record__c>();
		if(setDominio != null && !setDominio.isEmpty()){
			for(List<BigMachines__Configuration_Record__c> lista:[SELECT Id,
																		BigMachines__bm_site__c,
																		BigMachines__process_id__c,
																		BigMachines__version_id__c,
																		BigMachines__action_id_open__c,
																		BigMachines__document_id__c,
																		BigMachines__process__c,
																		BigMachines__action_id_copy__c
																	FROM BigMachines__Configuration_Record__c 
																	WHERE BigMachines__bm_site__c IN :setDominio]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve los Registros de BigMachine_quote filtradas por su lkp a Workorder
	 *
	 * @param setWoId: conjunto de Ids de las Wo
	 *
	 * @return mapa que contiene los Registros de BigMachine_quote
	 */
	public static Map<Id,BigMachines__Quote__c> getBigMachQuoByWo(Set<Id> setWoId){
		Map<Id,BigMachines__Quote__c> mapa = new Map<Id,BigMachines__Quote__c>();
		if(setWoId != null && !setWoId.isEmpty()){
			for(List<BigMachines__Quote__c> lista:[SELECT BigMachines__Transaction_Id__c,
														OQU_LKP_Work_Order__c,
														BigMachines__Is_Primary__c 
													FROM BigMachines__Quote__c
													WHERE OQU_LKP_Work_Order__c IN :setWoId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}