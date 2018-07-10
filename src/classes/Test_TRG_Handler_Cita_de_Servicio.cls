@isTest (seeAllData=true)
public without sharing class Test_TRG_Handler_Cita_de_Servicio {

	public static FSL__Scheduling_Policy__c scheduling{get; set;}
	public static ServiceAppointment serviceApp{get; set;}
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account asegurada {get; set;}
	private static Account cuenta {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static Festivos__c festivo {get; set;}
	private static OperatingHours horaFuncionamiento {get; set;}
	private static ServiceTerritory territorioServicio {get; set;}
	
	
	private static void inicializarVariables1(){
		Baipas.establecerVariableControl();
		scheduling = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		insert scheduling;
		compania = Util_Tests.crearCuentaCompania('S','1088','S0159404C');
		insert compania;
		system.debug('ID COMPANIA:'+compania.CUE_TXT_Identificador__c);
		system.debug('ID COMPANIA EN BD:'+[SELECT CUE_TXT_Identificador__c FROM Account WHERE Id = :compania.Id]);
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','87656586','V6646775D');
		system.debug('ID CUENTA:'+cuentaPrincipal.CUE_TXT_Identificador__c);
		insert cuentaPrincipal;
		asegurada = Util_Tests.crearCuentaB2BSec('Asegurado','1020',cuentaPrincipal.Id,'P3544152F');
		cuenta = Util_Tests.crearCuentaB2BSec('SegurCaixa1','1021',cuentaPrincipal.Id,'H97111066');
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277384',compania.Id,asegurada.Id,productoCIA.Id);

		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '51', 5.30);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('0000000739','01',tipoTrabajo.Id,caso.Id);
		insert ordenTrabajo;

		List<ServiceAppointment> listCit = [SELECT Id,ParentRecordId FROM ServiceAppointment WHERE ParentRecordId = :ordenTrabajo.Id];
		system.debug('cita creada automaticamente al crear un workorder '+listCit);
		delete listCit;
		
		OperatingHours horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
		insert horaFuncionamiento;

		datetime mydate = system.today() + 1;
		datetime newDate = mydate.addHours(2);
        //Datetime myDateTime = Datetime.newInstance(2018, 02, 19);
        Datetime myDateTime = Datetime.newInstance(2018, 03,06,12,10,10);
        Datetime dueDate = myDateTime.addDays(2);
        //Datetime arrivalDate = myDateTime.addDays(-2);
        Datetime arrivalDate = myDateTime;
        Datetime arrivalStartDate = arrivalDate.addDays(-15);
        serviceApp = Util_Tests.crearCitaServicio('Madrid','Espana','28001','Madrid','robles',myDateTime,dueDate);

        
        serviceApp.CreatedById = system.UserInfo.getUserId();
        serviceApp.ArrivalWindowEndTime = arrivalDate;
        serviceApp.ArrivalWindowStartTime = arrivalDate;
        serviceApp.CSE_CAS_Asignada__c = false;
        serviceApp.CSE_CAS_Autoasignar__c = true;
        serviceApp.CSE_CAS_Asignar_como_Urgencias__c = false;
        serviceApp.CSE_CAS_Asignar_territorio_prim_no_franq__c = false;
        serviceApp.CSE_CAS_Asignar_Como_Franquiciado__c = false;
        serviceApp.CSE_CAS_Asignar_Mizad__c = false;
        serviceApp.CSE_CAS_Comprobado_Horario__c = false;
        serviceApp.CSE_CAS_Crear_cita_app__c = false;
        serviceApp.CSE_CAS_Urgente__c = false;
        serviceApp.CSE_NUM_Numero_de_Ofrecimientos__c = 1.0;
        serviceApp.Duration = 2;
        serviceApp.DurationType = 'Hours';
        serviceApp.FSL__Auto_Schedule__c = false;
        serviceApp.FSL__Emergency__c = false;
        serviceApp.FSL__InJeopardy__c = false;
        serviceApp.FSL__InternalSLRGeolocation__Latitude__s = 40.381038;
        serviceApp.FSL__InternalSLRGeolocation__Longitude__s = 	-3.734841;
        serviceApp.FSL__IsFillInCandidate__c = true;
        serviceApp.FSL__IsMultiDay__c = false;
        serviceApp.FSL__Pinned__c = false;
        serviceApp.FSL__Prevent_Geocoding_For_Chatter_Actions__c = false;
        serviceApp.FSL__Same_Day__c = false;
        serviceApp.FSL__Same_Resource__c = false;
        serviceApp.FSL__Schedule_Mode__c = 'Automatic';
        serviceApp.FSL__Scheduling_Policy_Used__c = scheduling.Id;
        serviceApp.FSL__UpdatedByOptimization__c = false;
        serviceApp.FSL__Virtual_Service_For_Chatter_Action__c = false;
        serviceApp.GeocodeAccuracy = 'Zip';
        serviceApp.Latitude = 40.38096;
        serviceApp.Longitude = -3.73376;
        serviceApp.CSE_DAT_Fecha_Proxima_Programacion__c = system.today() +2;
        serviceApp.CSE_DAT_Fecha_Ultima_Programacion__c = system.today() +1;
        serviceApp.Status = Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL;
        serviceApp.ParentRecordId = ordenTrabajo.Id;
        //serviceApp.CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c =system.today() +2;
        //serviceApp.CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c =system.today() +1;




        horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
        insert horaFuncionamiento;
        territorioServicio = Util_Tests.crearTerritorioServicio('28001 BARCELONA',horaFuncionamiento.Id,'28001');
        territorioServicio.IsActive=true;
        insert territorioServicio;
        serviceApp.ServiceTerritoryId=territorioServicio.Id;
        festivo = Util_Tests.crearFestivo('Nacional',territorioServicio.Id,Date.newInstance(2018, 3, 08));
        festivo.FES_SEL_Tipo_de_Festivo__c= 'Nacional';
        insert festivo;
        
        
        Baipas.deshabilitarVariableControl();
    }

    @isTest static void testCasoParametroIdInformado() {
    	Test.startTest();
    	inicializarVariables1();
    	Baipas.establecerVariableControl();
    	insert serviceApp;
    	ordenTrabajo.OTR_LKP_Primera_Cita__c = serviceApp.Id;
    	ordenTrabajo.OTR_CAS_Urgente__c = false; 
    	update ordenTrabajo;
    	Account cuentaProfesional = Util_Tests.crearCuentaB2BPpal('CuentaProf','1022','S5162221E');
    	insert cuentaProfesional;
		//Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Gestor Front/Tramitacion'];
		Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL];
		User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;
		ServiceResource recursoServicio = Util_Tests.crearRecursoServicio('Recurso Prueba','1234',cuentaProfesional.Id,usuario);
		recursoServicio.isActive=true;

		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = recursoServicio.Id;
		update ordenTrabajo;
		//serviceApp.status='Pte. de asignar manual';
		
		Baipas.deshabilitarVariableControl();
		
	 	//update serviceApp;
	 	Test.stopTest();
	 }

	 @isTest static void testP(){
	 	Test.startTest();
	 	inicializarVariables1();
	 	Baipas.establecerVariableControl();
	 	insert serviceApp;		
		//ordenTrabajo.OTR_CAS_Urgente__c = false;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = serviceApp.Id; 
		update ordenTrabajo;
		//serviceApp.status='Pte. de asignar manual';
		Baipas.deshabilitarVariableControl();
		Account cuentaProfesional = Util_Tests.crearCuentaB2BPpal('CuentaProf','1000023','U9164003G');
		insert cuentaProfesional;
		//Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Gestor Front/Tramitacion'];
		Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL];
		User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;
		ServiceResource recursoServicio = Util_Tests.crearRecursoServicio('Recurso Prueba','1234',cuentaProfesional.Id,usuario);
		recursoServicio.isActive=true;

		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = recursoServicio.Id;
		Baipas.establecerVariableControl();
		update ordenTrabajo;
		update serviceApp;
		Baipas.deshabilitarVariableControl();
	 	//insert recursoAsignado;
	 	Test.stopTest();

	 }

	 @isTest static void HistoricoAsignaciones(){
	 	Test.startTest();
	 	inicializarVariables1();
	 	Baipas.establecerVariableControl();
	 	upsert serviceApp;
	 	Baipas.deshabilitarVariableControl();
	 	Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR000001','1024745','W4364779A', cuentaPrincipal.Id);
	 	cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
	 	insert cuentaProfesional;
	 	cuentaProfesional.CUE_SEL_Estado__c = '02';
	 	update cuentaProfesional;
		//Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Gestor Front/Tramitacion'];
		Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL];
		system.debug('Perfiles<<>>'+perfil);
		User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;
		ServiceResource recursoServicio = Util_Tests.crearRecursoServicio([SELECT CUE_TXT_Identificador__c FROM Account WHERE Id = :cuentaProfesional.id].get(0).CUE_TXT_Identificador__c+'_01_1','74749',cuentaProfesional.Id,usuario);
		recursoServicio.isActive=true;

		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = recursoServicio.Id;
	 	Baipas.establecerVariableControl();
		update ordenTrabajo;
	 	Baipas.deshabilitarVariableControl();

		insert recursoServicio;
		Historico_de_Asignaciones__c historico = new Historico_de_Asignaciones__c();
		historico = TRG_Handler_Cita_de_Servicio.crearRegistroHistoricoAsignacion(serviceApp,'estadoNuevo','estadoAntiguo',recursoServicio.Id, true);
		
		Test.stopTest();

	}
	
	//Dejo comentado este metodo porque sigue dando error para la inserccion porque actualiza el estado de la Cita 

	@isTest static void cambioEstadosCita1(){
		inicializarVariables1();
		
		Baipas.establecerVariableControl();
		upsert serviceApp;
		Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR000001','1024745','P6104644G', cuentaPrincipal.Id);
	 	cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
		insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		update cuentaProfesional;
		//Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Gestor Front/Tramitacion'];
		Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL];
		User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;
		OperatingHours horasOperacion = Util_Tests.crearHoraFuncionamiento('Horas Funcion','Europe/Paris');
		insert horasOperacion;
		ServiceTerritory territorio = Util_Tests.crearTerritorioServicio('Territorio',horasOperacion.Id,'01002');
		territorio.isActive=true;
		insert territorio;
		ServiceResource recursoServicio = Util_Tests.crearRecursoServicio([SELECT CUE_TXT_Identificador__c FROM Account WHERE Id = :cuentaProfesional.id].get(0).CUE_TXT_Identificador__c+'_01_1','74749',cuentaProfesional.Id,usuario);
		recursoServicio.isActive=true;
		insert recursoServicio;
		Datetime fecha = Datetime.newInstance(2018,03,05);
		ServiceTerritoryMember miembro = Util_Tests.crearMiembroTerritorioServicio(recursoServicio,territorio,'S',fecha);
		insert miembro;

		insert new CaseShare(CaseId=caso.Id,RowCause='Manual',UserOrGroupId=usuario.Id,CaseAccessLevel='Edit');

		Baipas.deshabilitarVariableControl();
		System.runAs(usuario){
			Test.startTest();
			serviceApp.Status = 'Programado';
			Baipas.establecerVariableControl();
			update serviceApp;
			serviceApp.Status = 'Asignada';
			
			update serviceApp;
			Baipas.deshabilitarVariableControl();
			/*serviceApp.Status = 'En curso';
			serviceApp.CSE_SEL_Motivo_Retraso__c = '01';
			serviceApp.CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c =system.today() +2;
	        serviceApp.CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c =system.today() +1;
	        
			update serviceApp;
			serviceApp.Status = 'Completado';
			
			update serviceApp;
			/*serviceApp.Status = Label.CIT_ESTADO_ANULADA_POR_CAMBIO;
			serviceApp.CSE_CAS_Cambio_de_cita__c = true;
			update serviceApp;
			serviceApp.CSE_CAS_Cambio_de_cita__c = false;
			serviceApp.Status = Label.CIT_ESTADO_ANULADA;
			update serviceApp;*/
			Test.stopTest();
		}
	}

	@isTest static void cambioEstadosCita2(){
		inicializarVariables1();
		
		Baipas.establecerVariableControl();
		upsert serviceApp;
		Baipas.deshabilitarVariableControl();
		Baipas.establecerVariableControl();
		Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR000001','1024745','P6104644G', cuentaPrincipal.Id);
	 	cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
		insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		update cuentaProfesional;
		//Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Gestor Front/Tramitacion'];
		Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL];
		User usuario = Util_Tests.nuevoUsuario('pruebos','pruebos','hola@hotmail.com','pruebos','pruebos',perfil);
		insert usuario;
		OperatingHours horasOperacion = Util_Tests.crearHoraFuncionamiento('Horas Funcion','Europe/Paris');
		insert horasOperacion;
		ServiceTerritory territorio = Util_Tests.crearTerritorioServicio('Territorio',horasOperacion.Id,'01002');
		territorio.isActive=true;
		insert territorio;
		ServiceResource recursoServicio = Util_Tests.crearRecursoServicio([SELECT CUE_TXT_Identificador__c FROM Account WHERE Id = :cuentaProfesional.id].get(0).CUE_TXT_Identificador__c+'_01_1','74749',cuentaProfesional.Id,usuario);
		//recursoServicio.isActive=true;
		insert recursoServicio;
		Datetime fecha = Datetime.newInstance(2018,03,05);
		ServiceTerritoryMember miembro = Util_Tests.crearMiembroTerritorioServicio(recursoServicio,territorio,'S',fecha);
		insert miembro;

        /*
		AssignedResource recursoAsignado = Util_Tests.asignarRecurso(serviceApp,recursoServicio);
		insert recursoAsignado;
*/

		Baipas.deshabilitarVariableControl();

		insert new CaseShare(CaseId=caso.Id,RowCause='Manual',UserOrGroupId=usuario.Id,CaseAccessLevel='Edit');

		Guardia__c guardia = new Guardia__c(GUA_DAT_Fecha_Inicio__c = Date.newInstance(2018, 03,06), GUA_DAT_Fecha_Fin__c= Date.newInstance(2018, 03,06), GUA_LKP_Profesional__c = recursoServicio.Id, GUA_LKP_Territorio__c = territorioServicio.Id);
		insert guardia;
		

		serviceApp.Status = 'Programado';
		Baipas.establecerVariableControl();
		upsert serviceApp;

		serviceApp.Status = 'Asignada';

		upsert serviceApp;

		
		Baipas.deshabilitarVariableControl();
		//System.runAs(usuario){
			Test.startTest();
			serviceApp.Status = 'Desasignada';
			serviceApp.CSE_SEL_Motivo_Retraso__c = '01';
			serviceApp.CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c =system.today() +2;
			serviceApp.CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c =system.today() +1;
			serviceApp.CSE_SEL_Motivo_Desasignacion__c='01';
			Baipas.establecerVariableControl();
			upsert serviceApp;
        	Baipas.deshabilitarVariableControl();
			Baipas.deshabilitarVariableControl();
			serviceApp.CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c =system.today() +2;
			Datetime myDateTime = Datetime.newInstance(2018, 03,06,12,10,10);
			Datetime dueDate = myDateTime.addDays(2);
    	   //Datetime arrivalDate = myDateTime.addDays(-2);
    	   Datetime arrivalDate = myDateTime;
    	   ServiceAppointment serviceApp2 = Util_Tests.crearCitaServicio('Murcia','España','03183','Murcia','Murcia',Datetime.newInstance(Date.today(),Time.newInstance(0,0,0,0)),Datetime.now().addDays(1));

    	   User newUser = new User();
    	   newUser.LastName= Label.PERFIL_PARTNER_COMMUNITY_DISPATCHER;
    	   newUser.Email = 'manolo@manolo.com';
    	   newUser.Alias = 'Manolo';
    	   newUser.ProfileId = [SELECT Id FROM Profile WHERE Name=:Label.PERFIL_PROFESIONAL].get(0).Id;
    	   newUser.Username = ' john784poi@acme7.com';
    	   newUser.CommunityNickname = 'pepe';
    	   newUser.TimeZoneSidKey = 'Europe/Paris';
    	   newUser.LocaleSidKey = system.UserInfo.getLocale();
    	   newUser.EmailEncodingKey = 'ISO-8859-1';
    	   newUser.LanguageLocaleKey = 'es';

    	   insert newUser;

    	   serviceApp2.CreatedById = system.UserInfo.getUserId();
    	   serviceApp2.ArrivalWindowEndTime = arrivalDate;
    	   serviceApp2.ArrivalWindowStartTime = arrivalDate;
    	   serviceApp2.CSE_CAS_Asignada__c = false;
    	   serviceApp2.CSE_CAS_Autoasignar__c = true;
    	   serviceApp2.CSE_CAS_Asignar_como_Urgencias__c = false;
    	   serviceApp2.CSE_CAS_Asignar_territorio_prim_no_franq__c = false;
    	   serviceApp2.CSE_CAS_Asignar_Como_Franquiciado__c = false;
    	   serviceApp2.CSE_CAS_Asignar_Mizad__c = false;
    	   serviceApp2.CSE_CAS_Comprobado_Horario__c = false;
    	   serviceApp2.CSE_CAS_Crear_cita_app__c = false;
    	   serviceApp2.CSE_CAS_Urgente__c = false;
    	   serviceApp2.CSE_NUM_Numero_de_Ofrecimientos__c = 1.0;
    	   serviceApp2.Duration = 2;
    	   serviceApp2.DurationType = 'Hours';
    	   serviceApp2.FSL__Auto_Schedule__c = false;
    	   serviceApp2.FSL__Emergency__c = false;
    	   serviceApp2.FSL__InJeopardy__c = false;
    	   serviceApp2.FSL__InternalSLRGeolocation__Latitude__s = 40.381038;
    	   serviceApp2.FSL__InternalSLRGeolocation__Longitude__s = 	-3.734841;
    	   serviceApp2.FSL__IsFillInCandidate__c = true;
    	   serviceApp2.FSL__IsMultiDay__c = false;
    	   serviceApp2.FSL__Pinned__c = false;
    	   serviceApp2.FSL__Prevent_Geocoding_For_Chatter_Actions__c = false;
    	   serviceApp2.FSL__Same_Day__c = false;
    	   serviceApp2.FSL__Same_Resource__c = false;
    	   serviceApp2.FSL__Schedule_Mode__c = 'Automatic';
    	   serviceApp2.FSL__Scheduling_Policy_Used__c = scheduling.Id;
    	   serviceApp2.FSL__UpdatedByOptimization__c = false;
    	   serviceApp2.FSL__Virtual_Service_For_Chatter_Action__c = false;
    	   serviceApp2.GeocodeAccuracy = 'Zip';
    	   serviceApp2.Latitude = 40.38096;
    	   serviceApp2.Longitude = -3.73376;
    	   serviceApp2.CSE_DAT_Fecha_Proxima_Programacion__c = system.today() +2;
    	   serviceApp2.CSE_DAT_Fecha_Ultima_Programacion__c = system.today() +1;
    	   serviceApp2.status = 'Pte. de asignar';
    	   serviceApp2.ParentRecordId = ordenTrabajo.Id;
    	   Baipas.establecerVariableControl();
    	   upsert serviceApp2;
    	   Baipas.deshabilitarVariableControl();
    	   Util_Cita_Servicio.ejecutaTrigger=0;

    	   serviceApp2.Status=Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL;

    	   system.debug('AQUI SE ACTUALIZA Pendiente');
    	   system.debug('hasta aqui llega');
    	   Baipas.establecerVariableControl();
    	   upsert serviceApp2;
    	   Baipas.deshabilitarVariableControl();

    	   Util_Cita_Servicio.ejecutaTrigger=0;

    	   Procedencia__c pcd=Util_Tests.crearProcedencia(0,0,0,0,0,cuentaPrincipal.Id,'12345','CAS_Servicio_B2B_B2B2C');
    	   pcd.PROC_CAS_Requiere_Informe_Cierre_Cita__c=true;
    	   insert pcd;

    	   caso.CAS_LKP_Procedencia__c=pcd.Id;
    	   update caso;

    	   serviceApp2.status=	'Asignada';
    	   Baipas.establecerVariableControl();
    	   upsert serviceApp2;
    	   Baipas.deshabilitarVariableControl();
    	   serviceApp2.Status='En curso';
    	   serviceApp2.CSE_SEL_Motivo_Retraso__c='01';
    	   Baipas.establecerVariableControl();
    	   upsert serviceApp2;
    	   Baipas.deshabilitarVariableControl();

    	   serviceApp2.Status=Label.CIT_ESTADO_COMPLETADA;
    	   serviceApp2.ActualDuration=20;


    	   system.runAs(newUser){
    	   	system.debug('INICIO TEST');
    	   	try{
    	   		Baipas.establecerVariableControl();
    	   		upsert serviceApp2;
    	   		Baipas.deshabilitarVariableControl();
    	   		}catch (Exception e){}
    	   	}

    	   	Util_Cita_Servicio.ejecutaTrigger=0;

    	   	pcd.PROC_CAS_Requiere_Informe_Cierre_Cita__c=false;
    	   	update pcd;

    	   	Baipas.establecerVariableControl();
    	   	upsert serviceApp2;
    	   	Baipas.deshabilitarVariableControl();

    	   	Test.stopTest();
		/*
		serviceApp.Status = 'Completado';
		
		update serviceApp;
		Test.stopTest();
		/*serviceApp.Status = Label.CIT_ESTADO_ANULADA_POR_CAMBIO;
		serviceApp.CSE_CAS_Cambio_de_cita__c = true;
		update serviceApp;
		serviceApp.CSE_CAS_Cambio_de_cita__c = false;
		serviceApp.Status = Label.CIT_ESTADO_ANULADA;
		update serviceApp;*/
		//}
	}
	
	@isTest static void testAsCommunityDispatcher(){
		inicializarVariables1();

		Baipas.establecerVariableControl();
		upsert serviceApp;
		Baipas.deshabilitarVariableControl();

		User newUser = new User();
		newUser.LastName= Label.PERFIL_PARTNER_COMMUNITY_DISPATCHER;
		newUser.Email = 'manolo@manolo.com';
		newUser.Alias = 'Manolo';
		newUser.ProfileId = system.UserInfo.getProfileId();
		newUser.Username = ' john784poi@acme7.com';
		newUser.CommunityNickname = 'pepe';
		newUser.TimeZoneSidKey = 'Europe/Paris';
		newUser.LocaleSidKey = system.UserInfo.getLocale();
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.LanguageLocaleKey = 'es';

		insert newUser;

		system.runAs(newUser){

			Baipas.establecerVariableControl();
			upsert serviceApp;
			Baipas.deshabilitarVariableControl();
		}
	}

}