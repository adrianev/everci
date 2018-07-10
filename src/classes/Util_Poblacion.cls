/**
 * Clase de funciones auxiliares relativas a los campos Poblacion y Provincia.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Poblacion {
	/**
	 * Inicialización de la lista de provincias
	 * 
	 * @return la lista de provincias inicializada
	 */
	public static List<SelectOption> inicializarListaProvincias(){
		List<SelectOption> listaProvincias = new List<SelectOption>();
		listaProvincias.add(new SelectOption('', '-- Ninguno --'));
		Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map <String, Schema.SObjectField> poblacionFieldMap = schemaMap.get('Poblacion__c').getDescribe().fields.getMap();
		DescribeFieldResult provincia = poblacionFieldMap.get('POB_SEL_Provincia__c').getDescribe();
		for(Schema.PicklistEntry prov : provincia.getPicklistValues()){
			listaProvincias.add(new SelectOption(prov.getValue(), prov.getLabel()));
		}
		return listaProvincias;
	}
	/**
	 * Se inicializa la lista de poblaciones, insertando la opcion "Ninguno"
	 * 
	 * @return la lista de poblaciones inicializada
	 */
	public static List<SelectOption> inicializarListaPoblaciones(){
		List<SelectOption> listaPoblaciones = new List<SelectOption>();
		listaPoblaciones.add(new SelectOption('', '-- Ninguno --'));
		return listaPoblaciones;
	}
	/**
	 * Se busca la poblacion por codigo postal
	 * 
	 * @param valorCodigoPostal Código Postal a usar para la búsqueda
	 * @return una lista con las poblaciones que coinciden con el código postal
	 */
	/*public static List<SelectOption> buscarPorCP(String valorCodigoPostal){
        List<SelectOption> listaPoblaciones;
        if(valorCodigoPostal != null 
         && valorCodigoPostal.isNumeric()
         && valorCodigoPostal.length() <= 5){
            List<Poblacion__c> listaPobsBusq = new List<Poblacion__c>([SELECT Name
             FROM Poblacion__c 
             WHERE POB_NUM_Codigo_Postal_Inicio__c <= :Integer.valueOf(valorCodigoPostal) 
                 AND (POB_NUM_Codigo_Postal_Fin__c = null
                    OR POB_NUM_Codigo_Postal_Fin__c >= :Integer.valueOf(valorCodigoPostal))]);
            if(!listaPobsBusq.isEmpty()){
                listaPoblaciones = new List<SelectOption>();
                listaPoblaciones.add(new SelectOption(listaPobsBusq.get(0).Id, listaPobsBusq.get(0).Name));

            }else{
                listaPoblaciones = inicializarListaPoblaciones();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
            }

        }else{
            listaPoblaciones = inicializarListaPoblaciones();
            if(valorCodigoPostal != null && valorCodigoPostal != ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_CAMPO_CP));
            }
        }
        return listaPoblaciones;
    }*/

	/**
	 * Se busca la poblacion por provincia
	 * 
	 * @param valorCodigoPostal Código Postal a usar para la búsqueda
	 * @param valorProvincia Provincia a usar para la búsqueda
	 * @return una lista con las poblaciones que coinciden con el código postal
	 */
	//	NO SE INVOCA NUNCA
	/*public static List<SelectOption> buscarPorProvincia(String valorCodigoPostal, String valorProvincia){
        List<SelectOption> listaPoblaciones;
        if(valorCodigoPostal == null || valorCodigoPostal == ''){
            List<Poblacion__c> listaPobsBusq = new List<Poblacion__c>([SELECT Name 
             FROM Poblacion__c 
             WHERE POB_SEL_Provincia__c = :valorProvincia]);
            if(!listaPobsBusq.isEmpty()){
                listaPoblaciones = new List<SelectOption>();
                for(Poblacion__c pob : listaPobsBusq){
                    listaPoblaciones.add(new SelectOption(pob.Id, pob.Name));
                }
            }else{
                listaPoblaciones = inicializarListaPoblaciones();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_PROVINCIA));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_BUSQUEDA_CP));
        }
        return listaPoblaciones;
    }*/

	//NO SE LLAMA DESDE NINGUNA PARTE
	/*public static List<Poblacion__c> recogerProvinciaPoblacion(Id poblacion){
    //public static String recogerProvinciaPoblacion(Id poblacion){ 
        List<Poblacion__c> listaProvs = new List<Poblacion__c>(
                                [SELECT POB_SEL_Provincia__c
                                 FROM Poblacion__c
                                 WHERE Id = :poblacion]);

        return listaProvs.get(0).POB_SEL_Provincia__c;

        List<Poblacion__c> listaProvs = new List<Poblacion__c>(
                                [SELECT Name,
                                        POB_SEL_Provincia__c
                                 FROM Poblacion__c
                                 WHERE Id = :poblacion]);

        return listaProvs;
    }*/

	/**
	* Devuelve un objeto Poblacion__c desde la búsqueda de identificador por provincia
	*
	* @param provincia: String de una provincia
	*
	* @return mapa que contiene los objetos Poblacion__c
	*/
	public static Map<Id,Poblacion__c> getPoblacionProv(String provincia){
		Map<Id,Poblacion__c> mapa = new Map<Id,Poblacion__c>();
		if(provincia != null){
			for(List<Poblacion__c> lista:[SELECT Id,POB_TXT_Identificador__c FROM Poblacion__c  WHERE POB_TXT_Identificador__c Like :provincia+'%']){
				mapa.putAll(lista);
			}
		} 
		return mapa;
	}

	/**
	* Devuelve un objeto Poblacion_CP__c desde su LKP a Poblacion__c
	*
	* @param setPoblacion: id de la poblacion asociada
	*
	* @return mapa que contiene los objetos Poblacion_CP__c
	*/
	public static Map<Id,Poblacion_CP__c> getCpPoblacion(set<String> setPoblacion){
		Map<Id,Poblacion_CP__c> mapa = new Map<Id,Poblacion_CP__c>();
		if(setPoblacion != null && !setPoblacion.isEmpty()){
	        for(List<Poblacion_CP__c> lista:[SELECT PCP_LKP_TerritorioServicio__c, PCP_LKP_Poblacion__c, PCP_TXT_Identificador__c
	         FROM Poblacion_CP__c WHERE PCP_LKP_Poblacion__c IN :setPoblacion LIMIT 1]){
	            mapa.putAll(lista);
	        }               
	    } 
	    return mapa;
	}

	/**
	 * Query que obtiene un mapa de poblaciones asociadas a un conjunto de códigos postales que se especifican como parámetro
	 *
	 * @param codigoPostal: Set de códigos postales sobre los que se quiere buscar la población
	 *
	 * @return mapa que <Id,Poblacion_CP__c>
	 */
    public static Map <Id,Poblacion_CP__c> queryPoblacion_CPByPCP_LKP_TerritorioServicio_r_TDS_TXT_Identificador (Set<String> codigoPostal){
        Map<Id,Poblacion_CP__c> mapa = new Map<Id,Poblacion_CP__c>();
	    if(!codigoPostal.isEmpty()){
	        for(List<Poblacion_CP__c> lista:[SELECT PCP_LKP_Poblacion__r.POB_SEL_Provincia__c,
								PCP_LKP_Poblacion__r.Name
						 FROM Poblacion_CP__c 
						 WHERE PCP_LKP_TerritorioServicio__r.TDS_TXT_Identificador__c in :codigoPostal]){
	            mapa.putAll(lista);
	        }               
	    }
		return mapa;
    }
}