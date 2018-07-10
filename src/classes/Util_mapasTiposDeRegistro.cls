/**
 * Clase de funciones auxiliares relativas a los mapas de tipos de registro.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_mapasTiposDeRegistro {
	//Se inicializan los mapas para recoger los nombres de los tipos de registro
	public final static Map<Id, RecordType> RTBYID = getRTById();
	public final static Map<String, Id> RTIDBYDEVNAME = getRTIdByDevName();
	public final static Map<Id, String> RTDEVNAMEBYID = getRTDevNameById();
	public final static Map<Id, String> RTNAMEBYID = getRTNameById();

	/**
	 * Devuelve un mapa de tipos de registro identificados por el ID.
	 * 
	 * @return mapa que relaciona los IDs con los tipos de registro
	 */
	private static Map<Id, RecordType> getRTById() {
		Map<Id, RecordType> rtByIdAux = new Map<Id, RecordType>();
		for (RecordType r : [SELECT r.Id, r.DeveloperName, r.Name, r.SobjectType FROM RecordType r]) {
			rtByIdAux.put(r.Id, r);
		}
		system.debug('@Laura: '+ rtByIdAux);
		return rtByIdAux;
	}

	/**
	 * Devuelve un mapa de IDs de tipos de registro identificados por el nombre API.
	 * 
	 * @return mapa que relaciona los IDs con los nombres API
	 */
	private static Map<String, Id> getRTIdByDevName() {
		Map<String, Id> rtIdByDevNameAux = new Map<String, Id>();
		if (RTBYID != null) {
			for (RecordType r : RTBYID.values()) {
				rtIdByDevNameAux.put(r.SobjectType + ':' + r.DeveloperName, r.Id);
			}
		}
		return rtIdByDevNameAux;
	}

	/**
	 * Devuelve un mapa de nombres API de tipos de registro identificados por el ID.
	 * 
	 * @return mapa que relaciona los nombres API con los IDs
	 */
	private static Map<Id, String> getRTDevNameById() {
		Map<Id, String> rtDevNameByIdAux = new Map<Id, String>();
		if (RTBYID != null) {
			for (RecordType r : RTBYID.values()) {
				rtDevNameByIdAux.put(r.Id, r.DeveloperName);
			}
		}
		return rtDevNameByIdAux;
	}

	/**
	 * Devuelve un mapa de nombres de tipos de registro identificados por el ID.
	 * 
	 * @return mapa que relaciona los nombres con los IDs
	 */
	private static Map<Id, String> getRTNameById() {
		Map<Id, String> rtNameByIdAux = new Map<Id, String>();
		if (RTBYID != null) {
			for (RecordType r : RTBYID.values()) {
				rtNameByIdAux.put(r.Id, r.Name);
			}
		}
		return rtNameByIdAux;
	}
	
	/**
	 * Devuelve los RecordType filtrados por el nombre y sObjectType
	 *
	 * @param setNombre: conjunto de los Nombres
	 * @param setType: conjunto de nombres de tipo de preferencia
	 *
	 * @return mapa que contiene los RecordTypes encontrados
	 */
	public static Map<Id,RecordType> getRecordTypeByNameAndType(Set<String> setNombre, Set<String> setType){
		Map<Id,RecordType> mapa = new Map<Id,RecordType>();
		if(setNombre != null && !setNombre.isEmpty() && setType != null && !setType.isEmpty()){
			for(List<RecordType> lista:[Select Id,SobjectType,Name From RecordType where Name IN :setNombre and SobjectType IN :setType limit 1]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Recordtypes filtrando por los nombres.
	 *
	 * @param setName: conjunto de nombres de Recordtypes
	 *
	 * @return mapa que contiene los RecordTypes encontrados
	 */
	public static Map<Id,RecordType> getRTByName(Set<String> setName){
		Map<Id,RecordType> mapa = new Map<Id,RecordType>();
		if(setName != null && !setName.isEmpty()){
			for(List<RecordType> lista:[SELECT Id,Name FROM RecordType WHERE Name IN :setName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/** REVISAR ESTA QUERY PORQUE NO DEBERIA DE HABER QUERIES DE RECORDTYPE
	 * Devuelve los RecordType filtrados por el sObjectType
	 *
	 * @param setType: conjunto de nombres de tipo de preferencia
	 *
	 * @return mapa que contiene los RecordTypes encontrados
	 */
	public static Map<Id,RecordType> getRecordTypeByType(Set<String> setType){
		Map<Id,RecordType> mapa = new Map<Id,RecordType>();
		if(setType != null && !setType.isEmpty()){
			for(List<RecordType> lista:[Select Id,SobjectType,Name,DeveloperName From RecordType where SobjectType IN :setType]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}