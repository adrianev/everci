/**
  *
  * Clase encargada de actualizar la visibilidad de los links de los documentos en la comunidad
  * 
  */
public without sharing class TRG_Handler_ContentDocumentLink {
	
	public static void actualizarVisibility(List<ContentDocumentLink> lContentDocumentLink){
		
		for(ContentDocumentLink contentDocumentLink:lContentDocumentLink){
			System.debug('contentDocumentLink='+contentDocumentLink);
					contentDocumentLink.Visibility = 'AllUsers';
		}
	}	
}