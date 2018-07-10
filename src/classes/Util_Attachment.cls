/**
 * Clase de funciones auxiliares relativas a Attachment.
 * 
 * @author EVERIS
 */
public without sharing class Util_Attachment {

	/**
	 * Devuelve un mapa de adjuntos a partir de los nombres.
	 *
	 * @param setName: conjunto de nombres de los adjuntos buscados
	 * @return mapa que contiene los adjuntos encontrados
	 */
	public static Map<Id,Attachment> queryMapAttachment(set<String> setName){
		Map<Id,Attachment> mapa = new Map<Id,Attachment>();
		if(setName != null && !setName.isEmpty()){
			mapa = new Map<Id,Attachment>(
				[SELECT Id,
						Name,
						Body,
						OwnerId
				 FROM Attachment
				 WHERE Name IN :setName
				 ORDER BY Name ASC]);
		}
		return mapa;
	}


	/**
	 * Devuelve un mapa de adjuntos a partir de los ParentId.
	 *
	 * @param setParentId: conjunto de ParentId's
	 * @return mapa que contiene los adjuntos encontrados
	 */
	public static Map<Id,Attachment> queryMapAttachmentByParent(set<Id> setParentId){
		Map<Id,Attachment> mapa = new Map<Id,Attachment>();
		if(setParentId != null && !setParentId.isEmpty()){
			mapa = new Map<Id,Attachment>(
				[SELECT Id,
						Name,
						Body,
						OwnerId
				 FROM Attachment
				 WHERE ParentId IN :setParentId]);
		}
		return mapa;
	}
}