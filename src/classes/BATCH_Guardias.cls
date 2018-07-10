public without sharing class BATCH_Guardias implements Database.Batchable<sObject>, Database.Stateful{

	Date fechaHoy = Date.today();
	Date fechaAyer = Date.today().addDays(-1);


	/* ---------------------------------------------------------------------------------------------------------------------------------------
        BATCHABLE METHODS
    ----------------------------------------------------------------------------------------------------------------------------------------*/
	public Database.QueryLocator start(final Database.BatchableContext BC) {

		String query = 'SELECT GUA_LKP_Territorio__c, GUA_LKP_Profesional__c, GUA_DAT_Fecha_Inicio__c, GUA_DAT_Fecha_Fin__c FROM Guardia__c '+
				'WHERE GUA_DAT_Fecha_Inicio__c =: fechaHoy OR GUA_DAT_Fecha_Fin__c =: fechaAyer';

		return Database.getQueryLocator(query);
	}

	public void execute(final Database.BatchableContext BC, final List<sObject> scope) {

		// Se clasifican las guardias como las que son a crear y las que caducan ese día
		Map<Id, Set<Id>> territorioProfesionalMapNUEVAS = new Map<Id, Set<Id>>();
		Set<Id> todosProfesionalesSetNUEVAS = new Set<Id>();
		Map<Id, Set<Id>> territorioProfesionalMapVIEJAS = new Map<Id, Set<Id>>();
		Set<Id> todosProfesionalesSetVIEJAS = new Set<Id>();
		for(Guardia__c gua:(List<Guardia__c>) scope){
			if(gua.GUA_DAT_Fecha_Inicio__c == fechaHoy){
				if(territorioProfesionalMapNUEVAS.containsKey(gua.GUA_LKP_Territorio__c)){
					territorioProfesionalMapNUEVAS.get(gua.GUA_LKP_Territorio__c).add(gua.GUA_LKP_Profesional__c);
				}else{
					Set<Id> profesionalSet = new Set<Id>();
					profesionalSet.add(gua.GUA_LKP_Profesional__c);
					territorioProfesionalMapNUEVAS.put(gua.GUA_LKP_Territorio__c, profesionalSet);
                    system.debug('NOMBRE ESPECIAL: '+gua);
				}
				todosProfesionalesSetNUEVAS.add(gua.GUA_LKP_Profesional__c);	
			}else if(gua.GUA_DAT_Fecha_Fin__c == fechaAyer){
				if(territorioProfesionalMapVIEJAS.containsKey(gua.GUA_LKP_Territorio__c)){
					territorioProfesionalMapVIEJAS.get(gua.GUA_LKP_Territorio__c).add(gua.GUA_LKP_Profesional__c);
				}else{
					Set<Id> profesionalSet = new Set<Id>();
					profesionalSet.add(gua.GUA_LKP_Territorio__c);
					territorioProfesionalMapVIEJAS.put(gua.GUA_LKP_Territorio__c, profesionalSet);
                    System.debug('la vieja '+gua.GUA_LKP_Profesional__c);
                    System.debug('guardia '+gua.GUA_LKP_Territorio__c);
				}
                    todosProfesionalesSetVIEJAS.add(gua.GUA_LKP_Territorio__c);
			}
            
		}

		// Se recuperan todos los registros de miembros de territorio primario y los secundarios que aplique
		List<ServiceTerritoryMember> stmList = Util_TerritorioServicio.getSTMemberBySRAndServiceTerritory(todosProfesionalesSetNUEVAS,todosProfesionalesSetVIEJAS,territorioProfesionalMapNUEVAS.keySet(),territorioProfesionalMapVIEJAS.keySet(),new Set<String>{'P'},new Set<String>{'P'}).values();
		/*List<ServiceTerritoryMember> stmList = [SELECT ServiceResourceId, ServiceTerritoryId, TerritoryType, OperatingHoursId, MTS_CAS_Creado_para_guardia__c FROM ServiceTerritoryMember
		                                        WHERE ((ServiceResourceId IN: todosProfesionalesSetNUEVAS OR ServiceResourceId IN: todosProfesionalesSetVIEJAS) AND TerritoryType = 'P')
		                                        OR ((ServiceTerritoryId IN: territorioProfesionalMapNUEVAS.keySet() OR ServiceTerritoryId IN: territorioProfesionalMapVIEJAS.keySet())
		                                        		AND (ServiceResourceId IN: todosProfesionalesSetNUEVAS OR ServiceResourceId IN: todosProfesionalesSetVIEJAS) AND  TerritoryType != 'P')];*/
		Id horarioDefecto = Util_Service_Resource.getOperatingHoursByName(new Set<String>{Label.OPH_NOMBRE_HORARIO_DEFECTO}).values().get(0).Id;
		Id horarioCompleto =  Util_Service_Resource.getOperatingHoursByName(new Set<String>{Label.OPH_NOMBRE_HORARIO_COMPLETO}).values().get(0).Id;
		//Id horarioDefecto = [SELECT Id FROM OperatingHours WHERE Name =: Label.OPH_NOMBRE_HORARIO_DEFECTO].Id;												
		//Id horarioCompleto = [SELECT Id FROM OperatingHours WHERE Name =: Label.OPH_NOMBRE_HORARIO_COMPLETO].Id;												

		// Se actualiza el horario del territorio primario además de eliminarse los territorios creados para las guardias y obtener los datos de los que son requeridos para crear
		List<ServiceTerritoryMember> stmListUpdate = new List<ServiceTerritoryMember>();
		List<ServiceTerritoryMember> stmListDelete = new List<ServiceTerritoryMember>();
		Map<Id, Set<Id>> territorioProfesionalMapNUEVASyaExisten = new Map<Id, Set<Id>>();
		System.debug('MAPA1:' +territorioProfesionalMapVIEJAS);
        System.debug('MAPA2: '+territorioProfesionalMapNUEVAS);
        
        List<Set<id>> content=territorioProfesionalMapVIEJAS.values();
        for(Set<id> i:content)
            system.debug('VIEJA: '+content);
        
        content=territorioProfesionalMapNUEVAS.values();
        for(Set<id> i:content)
            system.debug('NUEVA: '+content);
        
        for(ServiceTerritoryMember stm: stmList){
            System.debug('Elemento '+stm);
            
			if(todosProfesionalesSetVIEJAS.contains(stm.ServiceResourceId) && stm.TerritoryType == 'P'){
				stm.OperatingHoursId = horarioDefecto;
				stmListUpdate.add(stm);
			}else if(todosProfesionalesSetNUEVAS.contains(stm.ServiceResourceId) && stm.TerritoryType == 'P'){
				stm.OperatingHoursId = horarioCompleto;
				stmListUpdate.add(stm);
			}else if(territorioProfesionalMapVIEJAS.containsKey(stm.ServiceTerritoryId) && territorioProfesionalMapVIEJAS.get(stm.ServiceTerritoryId).contains(stm.ServiceResourceId) && stm.MTS_CAS_Creado_para_guardia__c){
				stmListDelete.add(stm);
			}

			if(territorioProfesionalMapNUEVAS.containsKey(stm.ServiceTerritoryId) && territorioProfesionalMapNUEVAS.get(stm.ServiceTerritoryId).contains(stm.ServiceResourceId)){
				if(territorioProfesionalMapNUEVASyaExisten.containsKey(stm.ServiceTerritoryId)){
					territorioProfesionalMapNUEVASyaExisten.get(stm.ServiceTerritoryId).add(stm.ServiceResourceId);
				}else{
					Set<Id> profesionalSet = new Set<Id>();
					profesionalSet.add(stm.ServiceResourceId);
					territorioProfesionalMapNUEVASyaExisten.put(stm.ServiceTerritoryId, profesionalSet);
				}
			}
		}
		update stmListUpdate;
		delete stmListDelete;

		// Se eliminan las ausencias de tipo festivo creadas previamente para los profesionales de guardia si las hubiera
		Id ausenciaRecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_FSL_FESTIVO);
		List<ResourceAbsence> raList = Util_Service_Resource.getResourceAbsenceByResourceAndRecordTypeAndStartDate(todosProfesionalesSetNUEVAS,new Set<Id>{ausenciaRecordTypeId},DateTime.now(),DateTime.now().addDays(6)).values();												
		/*List<ResourceAbsence> raList = [SELECT ResourceId, Start, RecordTypeId FROM ResourceAbsence 
		                                WHERE ResourceId IN: todosProfesionalesSetNUEVAS AND RecordTypeId =: ausenciaRecordTypeId AND Start >=: DateTime.now() AND Start <=: DateTime.now().addDays(6)];*/
		delete raList;


		// Se crean los miembros de territorio que no existan ya para las guardias y se actualizan los registros de guardia para tener el inventario de los checkeados
		List<ServiceTerritoryMember> stmListInsert = new List<ServiceTerritoryMember>();
		List<Guardia__c> guardiasListUpdate = new List<Guardia__c>();
		for(Guardia__c gua:(List<Guardia__c>) scope){
			if((territorioProfesionalMapNUEVAS.containsKey(gua.GUA_LKP_Territorio__c) && territorioProfesionalMapNUEVAS.get(gua.GUA_LKP_Territorio__c).contains(gua.GUA_LKP_Profesional__c)) && 
					(!territorioProfesionalMapNUEVASyaExisten.containsKey(gua.GUA_LKP_Territorio__c) || 
							(territorioProfesionalMapNUEVASyaExisten.containsKey(gua.GUA_LKP_Territorio__c) && !territorioProfesionalMapNUEVASyaExisten.get(gua.GUA_LKP_Territorio__c).contains(gua.GUA_LKP_Profesional__c)))){
				ServiceTerritoryMember stm = new ServiceTerritoryMember(ServiceResourceId = gua.GUA_LKP_Profesional__c, ServiceTerritoryId = gua.GUA_LKP_Territorio__c, 
						TerritoryType = 'S', MTS_CAS_Creado_para_guardia__c = true, MTS_CAS_Procesado_Festivo__c = true,
						EffectiveStartDate = DateTime.newInstance(gua.GUA_DAT_Fecha_Inicio__c.year(), gua.GUA_DAT_Fecha_Inicio__c.month(), gua.GUA_DAT_Fecha_Inicio__c.day()));
				stmListInsert.add(stm);
			}

			if(gua.GUA_DAT_Fecha_Inicio__c == fechaHoy){
				gua.GUA_CAS_Tratada_Inicio__c = true;
				guardiasListUpdate.add(gua);
			}else if (gua.GUA_DAT_Fecha_Fin__c == fechaAyer){
				gua.GUA_CAS_Tratada_Fin__c = true;
				guardiasListUpdate.add(gua);
			}
		}
		insert stmListInsert;
		update guardiasListUpdate;

	}


	public void finish(final Database.BatchableContext BC){
		//sendErrorEmail(BC.getJobId());
	} 
}