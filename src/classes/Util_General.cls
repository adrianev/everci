/**
 * Clase de funciones auxiliares relativas a utilidades generales.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_General{
	
	/**
	 * Recoge las etiqueta de todos los campos de cualquier objeto de SalesForce
	 * 
	 * @param string Objeto con el nombre API del objeto
	 * 
	 * @return mapa que relaciona los nombres API de los campos del objeto de entrada con sus etiquetas
	 */
	public static Map<String, String> getMapaEtiquetasDeCampos(String objeto){
		Map<String,String> mapaAPILabel = new Map<String,String>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    	Schema.SObjectType leadSchema = schemaMap.get(objeto);
    	Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
		for (String fieldName: fieldMap.keySet()) {  
        	mapaAPILabel.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
   		}
   		return mapaAPILabel;         
   }
}