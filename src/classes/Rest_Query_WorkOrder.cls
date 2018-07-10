@RestResource(urlMapping='/WorkOrder/*')
global without sharing class Rest_Query_WorkOrder {
	@HttpGet
	global static list<WorkOrder> doGet() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String url;
		if (test.isRunningTest()) {
			url = 'https://homeserve--develop.cs88.my.salesforce.com/services/apexrest/WorkOrder/30458963M';
		}else{
			url = req.requestURI;
		}

		//String url = 'ce/services/data/v39.0/query/WorkOrder/02457965W/Membership/30458963M';
		list<String> urlSplit = url.split('/');
		Integer tamUrl = urlSplit.size();
		String documento = urlSplit[tamUrl-1];
		system.debug('++++ Documento='+documento);
		system.debug(urlSplit[tamUrl-2]);

		/*
		WorkType result = [SELECT Account.CUE_SEL_Tipo_Documento__c,Account.CUE_TXT_Numero_Documento__c,Account.Name, Address, Case.CaseNumber,Description,Discount,Duration,
		                   DurationType,EndDate,IsClosed,OTR_SEL_Gremio__c,OTR_RES_Importe_partidas__c,OTR_RES_Importe_Total__c,OTR_TXT_Num_OrdenTrabajo_HS__c,
		                   OTR_DAT_Fecha_Primera_Cita__c,OTR_FOR_Semaforo__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Profesional_HS__c,OTR_SEL_Gremio__c,ParentWorkOrder.WorkOrderNumber,
		                   Priority,ServiceAppointmentCount,ServiceTerritory.Name,SlaExitDate,SlaStartDate,StartDate,Status,WorkOrderNumber,WorkType.Name	  FROM WorkOrder 
		                   WHERE Account.CUE_TXT_Numero_Documento__c='02457965W' AND (Case.CAS_SEL_Procedencia__c='Membership' OR Case.CAS_SEL_Procedencia__c='Digital')];
		*/
		list<WorkOrder> result = [SELECT Account.CUE_SEL_Tipo_Documento__c, Account.CUE_TXT_Numero_Documento__c, Account.Name, Address, Case.CaseNumber,
		                          Description, Discount, Duration, DurationType, EndDate, IsClosed, OTR_NUM_Horas_amarillo__c, OTR_NUM_Horas_verde__c, 
		                           OTR_DAT_Fecha_cambio_estado__c, OTR_SEL_Gremio__c,
		                          OTR_RES_Importe_partidas__c, OTR_TXT_Num_OrdenTrabajo_HS__c, /*OTR_DAT_Fecha_Primera_Cita__c, OTR_RES_Importe_Total__c,*/ 
		                          OTR_FOR_Semaforo__c/*, OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Profesional_HS__c*/, ParentWorkOrder.WorkOrderNumber,
		                          Priority, ServiceAppointmentCount, ServiceTerritory.Name, SlaExitDate, SlaStartDate, StartDate, Status, WorkOrderNumber,
		                          WorkType.Name FROM WorkOrder 
		                          WHERE Account.CUE_TXT_Numero_Documento__c=:documento AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)];
		system.debug(result);				
		return result;
	}
}