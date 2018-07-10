/**

 * Clase de funciones auxiliares relativas a las Tipos de Trabajo.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_TipoTrabajo {

	/**
	 * Devuelve los Tipos de Trabajo filtrados por Gremios y valor de Categoría.
	 *
	 * @param setStringGremios: conjunto de Gremios
	 * @param selectValueCategoria: valor contenido en las Categorías
	 *
	 * @return mapa que contiene los Tipos de Trabajos encontrados
	 */
	public static Map<Id,WorkType> getWorkTypeByGremioAndCategoria(Set<String> setStringGremios, String selectValueCategoria){
		Map<Id,WorkType> mapa = new Map<Id,WorkType>();
		if(setStringGremios != null && !setStringGremios.isEmpty() && selectValueCategoria != null){
			for(List<WorkType> lista:[SELECT Id,Name FROM WorkType WHERE TDT_SEL_Categoria__c INCLUDES (:selectValueCategoria) AND TDT_SEL_Gremio__c IN :setStringGremios]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Tipos de Trabajo filtrados por los IDs.
	 *
	 * @param setId: conjunto de IDs de Tipo de Trabajo
	 *
	 * @return mapa que contiene los Tipos de Trabajos encontrados
	 */
	public static Map<Id,WorkType> getWorkTypeById(Set<Id> setId){
		Map<Id,WorkType> mapa = new Map<Id,WorkType>();
		if(setId != null && !setId.isEmpty()){
			for(List<WorkType> lista:[SELECT Id,Name FROM WorkType WHERE Id IN :setId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Tipos de Trabajo filtrados por los nombres.
	 *
	 * @param setName: conjunto de nombres de Tipo de Trabajo
	 *
	 * @return mapa que contiene los Tipos de Trabajos encontrados
	 */
	public static Map<Id,WorkType> getWorkTypeByName(Set<String> setName){
		Map<Id,WorkType> mapa = new Map<Id,WorkType>();
		if(setName != null && !setName.isEmpty()){
			for(List<WorkType> lista:[SELECT Id,Name FROM WorkType WHERE Name IN :setName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Tipos de Trabajo filtrados por Procedencias, Gremios y valor de Categoría.
	 *
	 * @param setIdProcedencia: conjunto de IDs de Procedencia
	 * @param setStringGremios: conjunto de Gremios
	 * @param selectValueCategoria: valor contenido en las Categorías
	 *
	 * @return mapa que contiene los Tipos de Trabajos encontrados
	 */
	public static Map<Id,WorkType> getWorkTypeByProcedenciaAndGremioAndCategoria(Set<Id> setIdProcedencia, Set<String> setStringGremios, String selectValueCategoria){
		Map<Id,WorkType> mapa = new Map<Id,WorkType>();
		if(setIdProcedencia != null && !setIdProcedencia.isEmpty() && setStringGremios != null && !setStringGremios.isEmpty() && selectValueCategoria != null){
			for(List<WorkType> lista:[SELECT Id,Name FROM WorkType WHERE TDT_SEL_Categoria__c INCLUDES (:selectValueCategoria) AND TDT_SEL_Gremio__c IN :setStringGremios AND Id IN (SELECT PRTT_LKP_TipoTrabajo__c FROM Procedencia_TipoTrabajo__c WHERE PRTT_LKP_Procedencia__c IN :setIdProcedencia)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

    /*public static List<WorkType> queryTipoTrabajo(String categoria, String gremio) {
        List<WorkType> listWorkType=new List<WorkType>();
        if(!String.isEmpty(categoria)) {
            for(WorkType tipoTrabajoAux:[SELECT Id,Name FROM WorkType WHERE TDT_SEL_Categoria__c INCLUDES (:categoria) AND TDT_SEL_Gremio__c = :gremio]) {
                listWorkType.add(tipoTrabajoAux);
            }
        }
        return listWorkType;
    }

    public static List<WorkType> queryTipoTrabajo(String categoria, String gremio, Id procedencia) {
        List<WorkType> listWorkType=new List<WorkType>();
        if(!String.isEmpty(categoria)) {
            for(WorkType tipoTrabajoAux: [SELECT Id,Name FROM WorkType WHERE TDT_SEL_Categoria__c INCLUDES (:categoria) AND TDT_SEL_Gremio__c = :gremio AND Id IN (SELECT PRTT_LKP_TipoTrabajo__c FROM Procedencia_TipoTrabajo__c WHERE PRTT_LKP_Procedencia__c = :procedencia)]) {
                listWorkType.add(tipoTrabajoAux);
            }
        }
        return listWorkType;
    }*/
}