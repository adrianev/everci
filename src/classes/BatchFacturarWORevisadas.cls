global class BatchFacturarWORevisadas implements Database.Batchable<sObject>, Schedulable {
	
	
	global Database.QueryLocator start(Database.BatchableContext bc){
		return Database.getQueryLocator('SELECT Id,Status,CaseId FROM WorkOrder WHERE Status = :Label.OTR_ESTADO_REVISADO AND OTR_CAS_Orden_Trabajo_Facturada__c = false');
	}
	
	/*global Iterable<sObject> start(Database.BatchableContext bc){
		List<Workorder> woList = new List<Workorder>();
		List<Workorder> wos = [SELECT Id,Status,CaseId FROM WorkOrder WHERE id = '0WO9E000000Gw9dWAC'];
		Workorder wo = wos[0];
		for(Integer i=0; i<1000; i++){
			woList.add(wo);
		}
		
		return woList;
	}*/
    
    global void execute(SchedulableContext ctx) {
    	Database.executeBatch(this,10);
    }
    
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
    	
		
    	List<Workorder> servicios = (List<Workorder>) scope;
    	Set<Id> casosId = new Set<Id>();
    	for(Workorder wo: servicios){
    		casosId.add(wo.CaseId);
    	}
    	
    	Map<Id, Case> mapaCasos = new Map<Id,Case>([Select Id,RecordtypeId from Case where Id in :casosId]);
    	
    	for(Workorder wo: servicios){
    		Case caso = mapaCasos.get(wo.CaseId);
    			
    		if(caso != null && (caso.RecordTypeId  == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C))){
				Map<Id, String> mapaOTR = new Map<Id, String>();
				String idBitacora = '';
				mapaOTR.put(wo.Id, 'WorkOrder');
				Util_Llamada_Externa n = new Util_Llamada_Externa(mapaOTR,'Facturador',label.FAC_Maestro_Clientes,'');
				n.generarLlamada();
				//System.enqueueJob(n);
				Util_Llamada_Externa n2 = new Util_Llamada_Externa(mapaOTR,'Facturador',label.FAC_PreFactura,'');
				n.generarLlamada();
				//System.enqueueJob(n2);
				Util_Llamada_Externa n3 = new Util_Llamada_Externa(mapaOTR,'Facturador',label.FAC_Maestro_Profesionales,'');
				n.generarLlamada();
				//System.enqueueJob(n3);
			}
    	}
    	
    }
    
    global void finish(Database.BatchableContext bc){
    }
}