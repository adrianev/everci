/**
 * Clase de funciones auxiliares relativas a Report.
 * 
 * @author EVERIS
 */
public without sharing class Util_Report {

	/**
	 * Devuelve los informes encontrados a partir de un conjunto de DeveloperName's.
	 * @param setDevName: conjunto de valores del campo DeveloperName de los informes a buscar
	 *
	 * @return mapa con los informes encontrados
	 */
	public static Map<Id,Report> queryMapInforme(Set<String> setDevName){
		Map<Id,Report> mapa = new Map<Id,Report>();
		if(setDevName != null && !setDevName.isEmpty()){
			mapa = new Map<Id,Report>(
				[SELECT Id
				 FROM Report
				 WHERE DeveloperName IN :setDevName]);
		}
		return mapa;
	}
}