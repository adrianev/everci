/**
 * Clase para metodos refactorizados de ContentVersion
 *
 * @author EVERIS
 */
public without sharing class Util_ContentVersion {

	/**
	 * Devuelve los ContentVersion filtrados por los IDs.
	 *
	 * @param setId: conjunto de IDs
	 *
	 * @return mapa que contiene los ContentVersion encontrados
	 */
	public static Map<Id,ContentVersion> queryCVById(Set<Id> setId){
		Map<Id,ContentVersion> mapa = new Map<Id,ContentVersion>();
		if(setId != null && !setId.isEmpty()){
			for(List<ContentVersion> lista:[SELECT Id,CreatedDate,FirstPublishLocationId,ContentDocumentId,VersionData FROM ContentVersion WHERE Id IN :setId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los ContentVersions filtrados por los FirstPublishLocationId's.
	 *
	 * @param setIds: conjunto de FirstPublishLocationId's
	 *
	 * @return mapa que contiene los ContentVersions encontrados
	 */
	public static Map<Id,ContentVersion> getCVBYFirstPublishLocationId(Set<Id> setIds){
		Map<Id,ContentVersion> mapa = new Map<Id,ContentVersion>();
		if(setIds != null && !setIds.isEmpty()){
			for(List<ContentVersion> lista:[SELECT Id,CreatedDate,FirstPublishLocationId
											FROM ContentVersion
											WHERE FirstPublishLocationId IN :setIds
											ORDER BY FirstPublishLocationId, CreatedDate DESC]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	public static List<SelectOption> inicializarListaTiposContentVersion(){
		List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = ContentVersion.DOC_SEL_Tipo_Documento__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               options.add(new SelectOption(f.getValue(), f.getLabel()));
       }     
       return options;
	}
}