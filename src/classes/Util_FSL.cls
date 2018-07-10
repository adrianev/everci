/**
 * Clase de funciones auxiliares relativas a FSL
 * 
 * @author EVERIS
 */
public without sharing class Util_FSL {
	
	/**
	 * Devuelve el registro de la politica de horarios segun su nombre
	 *
	 * @param setName: conjunto de nombres 
	 *
	 * @return mapa que contiene el Registro de la politica de horarios
	 */
	public static Map<Id,FSL__Scheduling_Policy__c> getFSLSchedPol(Set<String> setName){
		Map<Id,FSL__Scheduling_Policy__c> mapa = new Map<Id,FSL__Scheduling_Policy__c>();
		if(setName != null && !setName.isEmpty()){
			for(List<FSL__Scheduling_Policy__c> lista:[select id from FSL__Scheduling_Policy__c where Name IN : setName limit 1]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las habilidades filtradas por dos valores de DeveloperName.
	 *
	 * @param devName1: DeveloperName 1 del filtro
	 * @param devName2: DeveloperName 1 del filtro
	 *
	 * @return mapa que contiene las habilidades encontradas
	 */
	public static Map<Id,Skill> getSkillByDevNames(String devName1, String devName2){
		Map<Id,Skill> mapa = new Map<Id,Skill>();
		if(devName1 != null && devName2 != null){
			for(List<Skill> lista:[SELECT Id,MasterLabel,DeveloperName FROM Skill WHERE DeveloperName LIKE :devName1 + '%' OR DeveloperName LIKE :devName2 + '%']){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las habilidades filtradas por un filtro de DeveloperName.
	 *
	 * @param devName: DeveloperName del filtro
	 *
	 * @return mapa que contiene las habilidades encontradas
	 */
	public static Map<Id,Skill> getSkillByDevName(String devName){
		Map<Id,Skill> mapa = new Map<Id,Skill>();
		if(devName != null){
			for(List<Skill> lista:[SELECT Id,MasterLabel,DeveloperName FROM Skill WHERE DeveloperName LIKE :devName + '%']){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las habilidades filtradas por los DeveloperNames.
	 *
	 * @param devName: conjunto de DeveloperNames
	 *
	 * @return mapa que contiene las habilidades encontradas
	 */
	public static Map<Id,Skill> getSkillBySetDevName(Set<String> setDevName){
		Map<Id,Skill> mapa = new Map<Id,Skill>();
		if(setDevName != null && !setDevName.isEmpty()){
			for(List<Skill> lista:[SELECT Id,MasterLabel,DeveloperName FROM Skill WHERE DeveloperName IN :setDevName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}