global without sharing class BATCH_Limites_Recurso_Mensual  implements Database.Batchable<sObject>, Database.Stateful{

	/* ---------------------------------------------------------------------------------------------------------------------------------------
        BATCHABLE METHODS
    ----------------------------------------------------------------------------------------------------------------------------------------*/
	global Database.QueryLocator start(final Database.BatchableContext BC) {

		return Database.getQueryLocator('SELECT RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c FROM ServiceResource');
	}

	global void execute(final Database.BatchableContext BC, final List<sObject> scope) {

		List<ServiceResource> srList = (List<ServiceResource>) scope;
		for(ServiceResource sr:srList){
			sr.RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c = 0;
		}
		update srList;
	}

	global void finish(final Database.BatchableContext BC){
		sendErrorEmail(BC.getJobId());
	}


	/* ---------------------------------------------------------------------------------------------------------------------------------------
        AUXILIAR METHODS
    ----------------------------------------------------------------------------------------------------------------------------------------*/
	private static void sendErrorEmail(final Id jobId){
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
		                  FROM AsyncApexJob WHERE Id =:jobId];

		// Send an email to the Apex job's submitter notifying of job completion.

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Apex Sharing Recalculation ' + a.Status);
		mail.setPlainTextBody
		('The batch Apex job processed ' + a.TotalJobItems +
				' batches with '+ a.NumberOfErrors + ' failures.');
		if(a.NumberOfErrors > 0){
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
}