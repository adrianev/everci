public without sharing class CNT_CustomPop{
	public cls_Sources source;
	public Task task;
	public String vdn{get; set;} 
	public id cuentaAsociada{get; set;}
	public string callType{get; set;}
	public string phone{get; set;}

	public CNT_CustomPop(){
		System.debug('Input parameters: ' + ApexPages.currentPage().getParameters());
		String sources = ApexPages.currentPage().getParameters().get('sources');
		String taskId = ApexPages.currentPage().getParameters().get('taskid');
        system.debug('URL: '+ ApexPages.currentPage().getUrl());

		if(apexpages.currentpage().getParameters().containsKey('VDN')){
        	vdn = ApexPages.currentPage().getParameters().get('VDN');
            //cuentaAsociada = [SELECT VDN_LKP_Compania__c FROM VDN_Compania__c WHERE Name = :vdn].VDN_LKP_Compania__c;
            if(!String.isEmpty(vdn)) {
            	for(VDN_Compania__c cuentaAsociadaAux: Util_CTI.getVDNByName(new Set<String>{vdn}).values()){
            	//[SELECT VDN_LKP_Compania__c FROM VDN_Compania__c WHERE Name = :vdn LIMIT 1]) {
                    if(!String.isEmpty(cuentaAsociadaAux.VDN_LKP_Compania__c)) {
                        cuentaAsociada=cuentaAsociadaAux.VDN_LKP_Compania__c;
                    }
            	}
            }
        }

		callType = ApexPages.currentPage().getParameters().get('calltype');
		if(callType == 'INBOUND'){
			phone = ApexPages.currentPage().getParameters().get('ani');
		}else if(callType == 'OUTBOUND'){
			phone = ApexPages.currentPage().getParameters().get('dnis');
		}
		system.debug('RPM vdn1: ' + vdn);
		System.debug('RPM cuentaAsociada: ' + cuentaAsociada);

		if(sources!=null ){
			source = (cls_Sources)System.JSON.deserializeStrict(sources, cls_Sources.class);
		}else{
			source = new cls_Sources();
		}
		/*task = [SELECT CreatedDate, LastModifiedDate,ActivityDate,Description,FSL__Count_of_Events__c,FSL__Count_of_Tasks__c,FSL__Event_Type__c,IsArchived,IsClosed,
					IsDeleted,OwnerId,Priority,RecordTypeId,Status,Subject,TAR_DAT_Fin_Llamada__c,TAR_DAT_Inicio_Llamada__c,TAR_LKP_Compania__c,TAR_LKP_Orden_Trabajo__c,
					TAR_LKP_Perito__c,TAR_TXT_Id_Sesion__c,TaskSubtype,thinkConnect__ANI__c,thinkConnect__DNIS__c,thinkConnect__ucidURL__c,thinkConnect__UCID__c,
					thinkConnect__UUI__c,Type,WhatId,WhoId, TAR_TIM_duration__c, Who.Phone, TAR_SEL_Prioridad__c
					FROM Task where Id =:taskId];*/
		task = Util_Tarea.getTareaById(new Set<Id>{taskId}).get(taskId);
		System.debug('source: ' +source );
		system.debug('RPM whoId: ' + task.whoId);

		//update task to registro Llamada
		
		//task.RecordTypeId = [Select Id,SobjectType,Name From RecordType where Name = 'Registro llamada' and SobjectType ='Task' limit 1].Id;
		task.RecordTypeId = Util_mapasTiposDeRegistro.getRecordTypeByNameAndType(new Set<String>{'Registro llamada'},new Set<String>{'Task'}).values()[0].Id;
	}
	
	public PageReference updateCallData (){
		setCallDuration(task);
		cloneTaskToCase();
		getHistory();
		PageReference nextPage;
		if(source.opened.size()>0){
			nextPage = new PageReference('/' + task.Id);
			//nextPage = new PageReference('/' + source.opened[0]);
		}else{
			nextPage = new PageReference('/' + task.Id);
		}
		system.debug('task.Id: ' + task.Id);
		return nextPage;
	}
	
	
	// param1 timestamp
	// param2 task ID
	private void setCallDuration(Task task){
		
		System.debug('task.LastModifiedDate: ' + task.LastModifiedDate);
		System.debug('task.CreatedDate: ' + task.CreatedDate);
		System.debug('(Datetime.now().getTime() - task.CreatedDate.getTime()).intValue(): ' + (Datetime.now().getTime() - task.CreatedDate.getTime()).intValue());
		Integer horas = 0;
		Integer minutos = 00;
		Integer segundos = 00;
		Integer duracion;
		String divSegundos = ':';
		try{
			
			task.CallDurationInSeconds =(task.LastModifiedDate.getTime() - task.CreatedDate.getTime()).intValue();
			task.TAR_DAT_Fin_Llamada__c = Datetime.now();
			task.TAR_DAT_Inicio_Llamada__c = task.CreatedDate;
			task.TAR_TIM_duration__c = Time.newInstance(0, 0, 0, (Datetime.now().getTime() - task.CreatedDate.getTime()).intValue());
			task.TAR_LKP_Compania__c = cuentaAsociada;
			task.CallType = callType;
			//task.Who.Phone = phone;
			duracion = (Integer)((Datetime.now().getTime().intValue() - task.CreatedDate.getTime().intValue())/1000);
			horas = (Integer)(duracion/3600);
			if(math.mod(duracion,3600) > 0){
				Integer aux = math.mod(duracion,3600);
				minutos = (Integer)(aux/60);
				if(math.mod(aux,60) > 0){
					segundos = math.mod(aux,60);
				}
			}
			if(segundos < 10){
				divSegundos += '0';
			}
			if(horas > 0){
				String divMinutos = ':';
				system.debug('------- '+minutos);
				if(minutos < 10){
					divMinutos += '0';
				}
				task.TAR_TXT_Duracion__c = horas + divMinutos + minutos + divSegundos + segundos;
			}else{
				task.TAR_TXT_Duracion__c = minutos + divSegundos + segundos;
			}
			System.debug('task.TAR_TIM_duration__c: ' + task.TAR_TIM_duration__c);
			update task;
		}
		catch(Exception e){
			System.debug('Error en método setCallDuration. Linea ' + e.getLineNumber() + ' Excepción ' + e );
		}
	}
	
	
	private void cloneTaskToCase(){
		
		// check the whole sources object looking for cases
		List<String> sourcesIdsList = new List<String>();
		List<String> sourcesWoIdsList = new List<String>();
		List<String> sourcesContactIdsList = new List<String>();
		List<WorkOrder> woList = new List<WorkOrder>();
		system.debug('RPM vdn2: ' + vdn);
		system.debug('RPM sources: ' + source);
		
		/*for(Integer i=0; i<source.transfer.size() ;i++){
			if(source.transfer[i].startsWith('500')){sourcesIdsList.add(source.transfer[i].substring(0,15));}
		}
		for(Integer i=0; i<source.uui.size() ;i++){	 
			if(source.uui[i].startsWith('500')){sourcesIdsList.add(source.uui[i].substring(0,15));}
		}
		for(Integer i=0; i<source.contact.size() ;i++){
			if(source.contact[i].startsWith('500')){sourcesIdsList.add(source.contact[i].substring(0,15));}
		}*/
		for(Integer i=0; i<source.match.size() ;i++){
			if(source.match[i].startsWith('003')){sourcesContactIdsList.add(source.match[i].substring(0,15));}
		}
		/*for(Integer i=0; i<source.origin.size() ;i++){
			if(source.origin[i].startsWith('500')){sourcesIdsList.add(source.origin[i].substring(0,15));}
		}*/
		for(Integer i=0; i<source.opened.size() ;i++){	  
			if(source.opened[i].startsWith('500')){sourcesIdsList.add(source.opened[i].substring(0,15));}
		}
		for(Integer i=0; i<source.opened.size() ;i++){	  
			if(source.opened[i].startsWith('0WO')){sourcesWoIdsList.add(source.opened[i].substring(0,15));}
		}
		//woList = [SELECT CaseId FROM WorkOrder WHERE Id IN :sourcesWoIdsList];
		Set<Id> setWoIds = new Set<Id>((List<Id>)sourcesWoIdsList);
		woList = Util_Orden_Trabajo.queryMapOTById(setWoIds).values();
		for(WorkOrder workO : woList){
			if(!sourcesIdsList.contains(String.valueOf(workO.CaseId).substring(0,15))){
				sourcesIdsList.add(String.valueOf(workO.CaseId).substring(0,15));
			}
		}

		if(!sourcesContactIdsList.isEmpty()){
			task.WhoId = sourcesContactIdsList.get(sourcesContactIdsList.size()-1);
		}

		system.debug('RPM sourcesIdsList: ' + sourcesIdsList);
		
		// distinct
		
		List<String> distinctListIds = new list<string>(new Set<String>(sourcesIdsList));
		system.debug('RPM distinctListIds: ' + distinctListIds);
		//clone and assing
		
		List<Task> taskList = new List<Task>();
		if(distinctListIds.size() > 0){
			for(Integer i = 0; i< distinctListIds.size(); i++){
				if(i==0){
					task.WhatId = distinctListIds[i];
					task.TAR_BOL_Actualizacion_CTI__c = true;
                    task.TAR_SEL_Prioridad__c = task.Priority;
					taskList.add(task);
				}else{
					Task tc = task.clone(false, true, true, false);
					//Task tc = new Task();
					tc.Subject = task.Subject;
					tc.TAR_DAT_Fin_Llamada__c = task.TAR_DAT_Fin_Llamada__c;
					tc.TAR_DAT_Inicio_Llamada__c = task.TAR_DAT_Inicio_Llamada__c;
					tc.TAR_TIM_duration__c = task.TAR_TIM_duration__c;
					tc.TAR_LKP_Compania__c = task.TAR_LKP_Compania__c;
					tc.Status = task.Status;				
					tc.RecordTypeId = task.RecordTypeId;
					tc.ActivityDate = task.ActivityDate;
					tc.WhoId = task.WhoId; 
					tc.Priority = task.Priority;
                    tc.TAR_SEL_Prioridad__c = task.Priority;
					tc.CallType = task.CallType;
					tc.CallDurationInSeconds = task.CallDurationInSeconds;
					tc.WhatId = distinctListIds[i];
					tc.TAR_BOL_Actualizacion_CTI__c = true;
					tc.CallType = task.CallType;
					tc.WhoId = task.WhoId;
					taskList.add(tc);
				}
			}
		}else{
			task.WhatId = cuentaAsociada;
			task.TAR_BOL_Actualizacion_CTI__c = true;
			taskList.add(task);
		}
		
		try{
			system.debug('RPM taskList: ' + taskList);
			//update task;
			upsert taskList;	
		}
		catch(Exception e){
			System.debug('Error en método cloneTaskToCase. Linea ' + e.getLineNumber() + ' Excepción ' + e );
		}   
	}
	
	private void getHistory() {
		String userId = UserInfo.getUserId();
		System.debug('userId ' + userId);
		System.debug('task.TAR_DAT_Fin_Llamada__c ' + task.TAR_DAT_Fin_Llamada__c);
		System.debug('task.CreatedDate ' + task.CreatedDate);
		//cases
		//List<CaseHistory> csHistList = [SELECT CaseId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue FROM CaseHistory WHERE CreatedById =: userId and CreatedDate >=: task.CreatedDate and CreatedDate <=: task.TAR_DAT_Fin_Llamada__c];
		List<CaseHistory> csHistList = Util_Historico.getMapaHistoricoCaso(new Set<Id>{userId},task.CreatedDate,task.TAR_DAT_Fin_Llamada__c).values();
		//contacts
		//List<ContactHistory> ctHistList = [SELECT ContactId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue FROM ContactHistory WHERE CreatedById =: userId and CreatedDate >=: task.CreatedDate and CreatedDate <=: task.TAR_DAT_Fin_Llamada__c];
		List<ContactHistory> ctHistList = Util_Historico.getMapaHistoricoContacto(new Set<Id>{userId},task.CreatedDate,task.TAR_DAT_Fin_Llamada__c).values();
		List<HISTORICO_CALL__c> histCallList = new List<HISTORICO_CALL__c>();
		
		for(CaseHistory csHist : csHistList){
			HISTORICO_CALL__c h = new HISTORICO_CALL__c();
			h.HC_CAS_ISDELETED__c = csHist.IsDeleted;
			h.HC_TXT_CREATED_BY__c  = csHist.CreatedById;
			h.HC_DAT_CREATED_DATE__c = csHist.CreatedDate;
			h.HC_TXT_FIELD__c = csHist.Field;
			h.HC_TXT_HISTORYID__c = csHist.Id;
			h.HC_TXT_ID_SALESFORCE__c = csHist.CaseId;
			h.HC_TXA_NEWVALUE__c = String.valueof(csHist.NewValue);
			h.HC_TXT_OBJECT__c = 'Caso';
			h.HC_TXT_OLDVALUE__c = String.valueof(csHist.OldValue);
			histCallList.add(h);
		}
		
		for(ContactHistory ctHist : ctHistList){
			HISTORICO_CALL__c h = new HISTORICO_CALL__c();
			h.HC_CAS_ISDELETED__c = ctHist.IsDeleted;
			h.HC_TXT_CREATED_BY__c  = ctHist.CreatedById;
			h.HC_DAT_CREATED_DATE__c = ctHist.CreatedDate;
			h.HC_TXT_FIELD__c = ctHist.Field;
			h.HC_TXT_HISTORYID__c = ctHist.Id;
			h.HC_TXT_ID_SALESFORCE__c = ctHist.ContactId;
			h.HC_TXA_NEWVALUE__c = String.valueof(ctHist.NewValue);
			h.HC_TXT_OBJECT__c = 'Contacto';
			h.HC_TXT_OLDVALUE__c = String.valueof(ctHist.OldValue);
			histCallList.add(h);
		}
		
		insert histCallList;
		
	}
	
	public without sharing class cls_Sources{
		 public String[] transfer = new String[]{};
		 public String[] uui = new String[]{};
		 public String[] contact = new String[]{};
		 public String[] match = new String[]{};
		 public String[] origin = new String[]{};
		 public String[] opened = new String[]{};
	}
}