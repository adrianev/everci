/**

 * Clase de funciones auxiliares relativas a los Festivos.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Festivos {

	/**
	* Se recogen los festivos locales y provinciales cuyo CP se encuentre entre los Miembros de Territorio a procesar.
	*
	* @param setCPostales: código postales
	*
	* @return mapa que contiene los festivos
	*/
	public static Map<Id,Festivos__c> getFestMiemb (set<String> setCPostales){
	    Map<Id,Festivos__c> mapa = new Map<Id,Festivos__c>();
	    if(setCPostales != null && !setCPostales.isEmpty()){
	        for(List<Festivos__c> lista:[SELECT FES_SEL_Tipo_de_Festivo__c,
	        									FES_DAT_Fecha__c, FES_LKP_Territorio__c, 
	        									FES_CAS_Procesado__c,
	        									FES_SEL_Provincia__c,
	        									FES_LKP_Territorio__r.PostalCode
											FROM Festivos__c 
											WHERE (FES_LKP_Territorio__r.PostalCode IN: setCPostales
											AND FES_SEL_Tipo_de_Festivo__c = 'Local') OR (FES_SEL_Tipo_de_Festivo__c = 'Provincial')]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}
	
	
	/**
	 * Método que obtiene los festivos locales y nacionales por los territorio y las fechas que usan sets 
	 *
	 * @param setTerritorios: set de Territorios
	 * @param setFechas: conjunto de fechas (Date) 
	 * @return mapa que contiene los festivos que satisfacen las condiciones
	 */
	public static Map<Id,Festivos__c> getFestivoByTerritorio_AND_Fecha_AND_Tipo_de_Festivo_is_Nacional_o_Local(Set<Id> setTerritorios, Set<Date> setFechas){
	    Map<Id,Festivos__c> mapa = new Map<Id,Festivos__c>();
	    if(setTerritorios != null && !setTerritorios.isEmpty() && !setFechas.isEmpty() && setFechas != null){
	        for(List<Festivos__c> lista:[SELECT FES_SEL_Tipo_de_Festivo__c,
	        									FES_DAT_Fecha__c, FES_LKP_Territorio__c 
											FROM Festivos__c
											WHERE (FES_LKP_Territorio__c IN :setTerritorios 
											AND FES_DAT_Fecha__c IN :setFechas
											AND FES_SEL_Tipo_de_Festivo__c = 'Local') OR (FES_DAT_Fecha__c IN: setFechas 
											AND FES_SEL_Tipo_de_Festivo__c = 'Nacional')]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}
	

	/**
	* Se recogen todos los festivos nacionales para asignarlos a profesionales.
	*
	* @param setTipo: Tipo de Festivo
	*
	* @return mapa que contiene los festivos
	*/
	public static Map<Id,Festivos__c> getFestivos (set<String> setTipo){
		Map<Id,Festivos__c> mapa = new Map<Id,Festivos__c>();
			for(List<Festivos__c> lista:[SELECT FES_SEL_Tipo_de_Festivo__c,
												FES_DAT_Fecha__c,
												FES_LKP_Territorio__c,
												FES_CAS_Procesado__c,
												FES_SEL_Provincia__c,
												FES_LKP_Territorio__r.PostalCode
											FROM Festivos__c
											WHERE FES_SEL_Tipo_de_Festivo__c IN : setTipo]){
				mapa.putAll(lista);
			}
		return mapa;
	}
	
	/**
	* Se recogen los festivos Locales y Nacionales en los Territorios determinados.
	*
	* @param setTerritorios: territorios 
	* @param setTipo: Tipo de Festivo
	*
	* @return mapa que contiene los festivos
	*/
	public static Map<Id,Festivos__c> getFestTerritorios (set<Id> setTerritorios,set<String> setTipo){
	    Map<Id,Festivos__c> mapa = new Map<Id,Festivos__c>();
	    if(setTerritorios != null && !setTerritorios.isEmpty() && setTipo != null && !setTipo.isEmpty()){
	        for(List<Festivos__c> lista:[SELECT FES_SEL_Tipo_de_Festivo__c,
	        									FES_DAT_Fecha__c,
	        									FES_LKP_Territorio__c 
											FROM Festivos__c
											WHERE FES_DAT_Fecha__c = :Date.today()
											AND ((FES_LKP_Territorio__c IN :setTerritorios 
											AND FES_SEL_Tipo_de_Festivo__c IN : setTipo) OR FES_SEL_Tipo_de_Festivo__c IN : setTipo)]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}

	/**
	 * Devuelve los festivos filtrando por las fechas.
	 *
	 * @param setFecha: conjunto de fechas
	 *
	 * @return mapa que contiene festivos encontrados
	 */
	public static Map<Id,Festivos__c> getFestivoByFecha(Set<Date> setFecha){
		Map<Id,Festivos__c> mapa = new Map<Id,Festivos__c>();
		if(setFecha != null && !setFecha.isEmpty()){
			for(List<Festivos__c> lista:[SELECT Id,
												FES_DAT_Fecha__c,
												FES_LKP_Territorio__c,
												FES_LKP_Territorio__r.Name,
												FES_SEL_Provincia__c,
												FES_SEL_Tipo_de_Festivo__c,
												Name
											FROM Festivos__c
											WHERE FES_DAT_Fecha__c IN :setFecha]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}