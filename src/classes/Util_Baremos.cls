/**
 * Clase de funciones auxiliares relativas a los Baremos.
 * 
 * @author EVERIS
 *
 */
public without sharing class Util_Baremos{

	/**
	 * Devuelve los Baremos filtrados por Compañías y códigos de baremo.
	 *
	 * @param setCompania: conjunto de IDs de compañías
	 * @param setCodBaremo: conjunto de códigos de baremo
	 *
	 * @return mapa que contiene los Baremos encontrados
	 */
	public static Map<Id,Baremo__c> getBaremoByCompaniaAndCodigoBaremo(Set<Id> setCompania, Set<String> setCodBaremo){
		Map<Id,Baremo__c> mapa = new Map<Id,Baremo__c>();
		if(setCompania != null && !setCompania.isEmpty() && setCodBaremo != null && !setCodBaremo.isEmpty()){
			for(List<Baremo__c> lista:[SELECT Id,BAR_TXT_Identificador_Unico__c,BAR_LKP_Compania__c
										FROM Baremo__c
										WHERE BAR_TXT_Identificador_Unico__c IN :setCodBaremo
										AND BAR_LKP_Compania__c IN :setCompania]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}