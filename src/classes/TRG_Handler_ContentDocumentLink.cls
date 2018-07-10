public without sharing class TRG_Handler_ContentDocumentLink {
	
	public static void actualizarVisibility(List<ContentDocumentLink> lContentDocumentLink){
		
		//Solución para evitar que se produzca un "too many queries"
		
		/*List<Id> linkedEnId = new List<Id>();
		for(ContentDocumentLink contentDocumentLink:lContentDocumentLink){
			linkedEnId.add(contentDocumentLink.LinkedEntityId);
		}
				
		Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id FROM Case WHERE Id IN :linkedEnId]);
		Map<Id,WorkOrder> lWorkOrders = new Map<Id,WorkOrder>([SELECT Id FROM WorkOrder WHERE Id IN :linkedEnId]);*/
		
		for(ContentDocumentLink contentDocumentLink:lContentDocumentLink){
			System.debug('contentDocumentLink='+contentDocumentLink);
			/*if(mapCases.ContainsKey(contentDocumentLink.LinkedEntityId) || lWorkOrders.ContainsKey(contentDocumentLink.LinkedEntityId)){
				if (contentDocumentLink.Visibility.equals('InternalUsers') && contentDocumentLink.ShareType.equals('V')) {*/
					contentDocumentLink.Visibility = 'AllUsers';
				/*}
			}*/
		}
		
	}
	
	//Método comentado, por realizar queries dentro de un bucle
	/*DEG*/
	/*
    public static void actualizarVisibility(List<ContentDocumentLink> lContentDocumentLink){
        
        //List<String> listaDesencadenador = new List<String> ();
        for(ContentDocumentLink contentDocumentLink:lContentDocumentLink){
            system.debug('>>>>>contentVersion: '+contentDocumentLink);
            
            List<Case> lCases = [SELECT Id FROM Case WHERE Id =: contentDocumentLink.LinkedEntityId];
            List<WorkOrder> lWorkOrders = [SELECT Id FROM WorkOrder WHERE Id =: contentDocumentLink.LinkedEntityId];
            
            //String sObjectName = contentDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName();
            //system.debug('>>>>>LinkedEntityId Object Name: ' + sObjectName);
            
            if (lCases.size() > 0 || lWorkOrders.size() > 0){
                if (contentDocumentLink.Visibility.equals('InternalUsers') && contentDocumentLink.ShareType.equals('V')) {
                    contentDocumentLink.Visibility = 'AllUsers';
                }
            }
            
        }
    }*/
    /*DEG*/
	
}