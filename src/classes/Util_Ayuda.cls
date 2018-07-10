/**
 * Clase de funciones auxiliares relativas a las ayudas.
 * 
 * @author EVERIS
 *
 */
public without sharing class Util_Ayuda{
	
	/**
	 * Query para traer la ayuda asociada a la compañia
	 * @param setCompania conjunto de compañias 
	 * @return mapa con las ayudas resultado
	 */
	public static Map<Id, Ayuda__c> getMapaAyudaCompania(set<Id> setCompania){
		Map<Id, Ayuda__c> mapaRetorno = new Map<Id,Ayuda__c>();
		if(setCompania != null){
			mapaRetorno = new Map<Id, Ayuda__c>();
			for(List<Ayuda__c> lista : [SELECT AYU_TXT_Identificador__c,
			    				 		AYU_TXT_Descripcion__c,
			    				 		AYU_SEL_Tipo__c,
			    						Name
			    						FROM Ayuda__c WHERE (AYU_SEL_Tipo__c = :Label.AYUDA_NO_EXISTEN_RESUL AND AYU_LKP_Compania__c IN : setCompania)]){
				mapaRetorno.putAll(lista);
			}
		}
		return mapaRetorno;
	}
	
	/**
	 * Query para traer la ayuda asociada al tipo
	 * @param setTipo conjunto de tipos de ayuda 
	 * @return mapa con las ayudas resultado
	 */
	public static Map<Id, Ayuda__c> getMapaAyudaByTipo(set<String> setTipo){
		Map<Id, Ayuda__c> mapaRetorno = new Map<Id,Ayuda__c>();
		if(setTipo != null){
			mapaRetorno = new Map<Id, Ayuda__c>();
			for(List<Ayuda__c> lista : [SELECT AYU_TXT_Identificador__c,
			    				 		AYU_TXT_Descripcion__c,
			    				 		AYU_SEL_Tipo__c,
			    						Name
			    						FROM Ayuda__c WHERE (AYU_SEL_Tipo__c IN :setTipo)]){
				mapaRetorno.putAll(lista);
			}
		}
		return mapaRetorno;
	}
}