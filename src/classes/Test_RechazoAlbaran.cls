@isTest
public class Test_RechazoAlbaran {
	public static FSL__Scheduling_Policy__c scheduling{get; set;}
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account cuenta {get; set;}
	private static Account cuentaProfesional {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static Poblacion__c poblacion {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Case caso {get; set;}  
	private static User usuario {get; set;}
	private static ServiceResource profesional {get; set;}
	private static AssignedResource recurso {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	
	@isTest static void RechazoAlbaran(){
		
		Baipas.establecerVariableControl();
		RecordType princi =[SELECT RecordType.DeveloperName FROM RecordType WHERE RecordType.DeveloperName  = 'CUE_Cliente_B2C_ppaL']; 
		
		scheduling = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		insert scheduling;
		

		List<Account> listaCuentas = new List<Account>();
		compania = Util_Tests.crearCuentaCompania('CuentaCompañia', '1019', 'X1264567X');
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('Cliente B2B/B2B2C principal','1219','X1134567X');
		cuentaPrincipal.RecordTypeId = princi.Id;
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1020',cuentaPrincipal.Id,'X1114567X');
		cuenta.RecordTypeId = princi.Id;
		insert cuenta;
		Account cuenta2 = Util_Tests.crearCuentaAsegurado('serafin', '1021', 'sera@sera.com', '23017462M', 'pepe', 'roca', 'vergara');
		cuenta2.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert cuenta2;
		cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','PRX1111567X','X1111567X',cuenta2.Id);
		//cuentaProfesional.CUE_SEL_Estado__c = '02'; 
		cuentaProfesional.CUE_LKP_Cuenta_principal__c = Null;
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
		cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuenta.Id;
		insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		update cuentaProfesional;

		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		
		Tipo_Producto_CIA__c tipoProd = new Tipo_Producto_CIA__c();
		tipoProd.Name = 'SegurCaixa333';
		tipoProd.TPR_SEL_Tipo_Producto__c = '01';
		tipoProd.TPR_LKP_Compania__c = cuenta.Id;
		tipoProd.TPR_SEL_Interlocutores_Autorizados__c = 'Padre';
		tipoProd.TPR_TXT_Identificador__c = '435345';
		tipoProd.TPR_LKP_Compania__c = compania.Id;

		insert tipoProd;

		WorkType wt = new WorkType();
		wt.Name = 'Tipo de Trabajo por Defecto';
		wt.EstimatedDuration = 120.0;
		wt.DurationType = 'Minutes';
		wt.TDT_SEL_Categoria__c = '01;02';
		wt.TDT_SEL_Gremio__c = '07';
		wt.ShouldAutoCreateSvcAppt = true;
		wt.TDT_TXT_Identificador__c = '701';

		insert wt;

		OperatingHours oh = new OperatingHours();
		oh.name = 'Horario por defecto';
		oh.OPH_TXT_Identificador__c = '0001';

		insert oh;

		Poblacion__c poblacion = new Poblacion__c();
		poblacion.Name = 'MADRID';
		poblacion.POB_SEL_Provincia__c = '28';
		poblacion.POB_TXT_Identificador__c = '28#MADRID';

		//insert poblacion;


		ServiceTerritory st = new ServiceTerritory();
		st.IsActive = true;
		st.Name = '28015 MADRID';
		st.PostalCode = '28015';
		st.TDS_TXT_Identificador__c = '28015#MADRID';
		st.OperatingHoursId = oh.Id;
		//st.TDS_LKP_Poblacion__c = poblacion.Id; 

		insert st;
		
		ServiceResource sr = new ServiceResource();
		sr.RSE_LKP_Cuenta__c = cuentaProfesional.Id;
		sr.Name = cuentaProfesional.CUE_TXT_Identificador__c + '_01_2';
	
		sr.RelatedRecordId = system.UserInfo.getUserId();
		sr.RSE_TXT_Codigo_Recurso__c = '1242141';
		sr.IsCapacityBased = true;
		sr.IsActive = true;
		sr.RSE_SEL_Gremio__c='01';
		
		insert sr;

		ServiceTerritoryMember stm = new ServiceTerritoryMember();
		stm.EffectiveStartDate = system.now();
		stm.MTS_CAS_Creado_para_guardia__c = false;
		stm.MTS_CAS_Procesado_Festivo__c = false;
		stm.ServiceTerritoryId = st.Id;
		stm.TerritoryType = 'P';
		stm.OperatingHoursId = oh.Id;
		stm.MTS_TXT_Identificador__c = 'STM-0012_28015#MADRID';
		stm.PostalCode = '28015';
		stm.ServiceResourceId = sr.Id;
		stm.State='01';
		insert stm;


		
		//List<WorkOrder> listaOTs = new List<WorkOrder>();
		WorkOrder wo = new WorkOrder();
		wo.AccountId = cuenta.Id;
		wo.City = 'Madrid';
		wo.StartDate = system.now();
		wo.Duration = 2.0;
		wo.DurationType = 'Hours';
		wo.Latitude = 40.48023673004623;
		wo.Longitude = -3.6690412312805356;
		wo.WorkTypeId = wt.Id;
		wo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815917';
		wo.ServiceTerritoryId = st.Id;
		wo.CreatedDate = system.now();
		wo.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo.OTR_SEL_Rango_Primera_Cita__c = '07';
		wo.OwnerId = System.UserInfo.getUserId();
		wo.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';
		wo.CaseId = caso.Id;
		wo.OTR_LKP_Recurso_Servicio__c = sr.id;
		wo.ParentWorkOrderId = wo.Id;
		//listaOTs.add(wo);
		insert wo;
		
		WorkOrder wo2 = new WorkOrder();
		wo2.AccountId = cuenta.Id;
		wo2.City = 'Madrid';
		wo2.StartDate = system.now();
		wo2.Duration = 2.0;
		wo2.DurationType = 'Hours';
		wo2.Latitude = 40.48023673004623;
		wo2.Longitude = -3.6690412312805356;
		wo2.WorkTypeId = wt.Id;
		wo2.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815817';
		wo2.ServiceTerritoryId = st.Id;
		wo2.CreatedDate = system.now();
		wo2.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo2.OTR_SEL_Rango_Primera_Cita__c = '07';
		wo2.OwnerId = System.UserInfo.getUserId();
		wo2.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';
		wo2.CaseId = caso.Id;
		Datetime posibleFechaReserva = Datetime.now().addDays(Util_Cita_Servicio.sumarDias(Datetime.now()));
		wo2.OTR_DAT_Fecha_Primera_Cita__c = posibleFechaReserva.date();
		wo2.OTR_SEL_Rango_Primera_Cita__c = '07';
		wo2.OTR_LKP_Recurso_Servicio__c = sr.id;
		
		wo2.ParentWorkOrderId = wo.Id;
		
		//listaOTs.add(wo2);
		insert wo2;

		//insert listaOTs;
		
		WorkOrder wo3 = new WorkOrder();
		insert wo3;
		list <Task> listas = new list<Task> ();
								Task Tarea1 = new Task();
								Tarea1.WhatId = wo2.ParentWorkOrderId ;
								Tarea1.Status = 'Finalizado';
								listas.add(Tarea1);
								insert listas;

		WorkOrderLineItem partida = Util_Tests.crearNuevaPartidaTrabajo(wo.Id);
		insert partida;

		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;

		datetime mydate = system.today() + 1;
		datetime newDate = mydate.addHours(2);
		//Datetime myDateTime = Datetime.newInstance(2018, 02, 19);
		Datetime myDateTime = Datetime.newInstance(2018, 03,06,12,10,10);
		Datetime dueDate = myDateTime.addDays(2);
		//Datetime arrivalDate = myDateTime.addDays(-2);
		Datetime arrivalDate = myDateTime;
		Datetime arrivalStartDate = arrivalDate.addDays(-15); 
		
		citaServicio = Util_Tests.crearCitaServicio('Madrid','España','','','',myDateTime,dueDate);
		
		citaServicio.CreatedById = system.UserInfo.getUserId();
		citaServicio.ArrivalWindowEndTime = arrivalDate;
		citaServicio.ArrivalWindowStartTime = arrivalDate;
		//citaServicio.FSL__Auto_Schedule__c = true;
		citaServicio.CSE_CAS_Asignada__c = false;
		citaServicio.CSE_CAS_Asignar_como_Urgencias__c = false;
		citaServicio.CSE_CAS_Asignar_territorio_prim_no_franq__c = false;
		citaServicio.CSE_CAS_Asignar_Como_Franquiciado__c = false;
		citaServicio.CSE_CAS_Asignar_Mizad__c = false;
		citaServicio.CSE_CAS_Comprobado_Horario__c = false;
		citaServicio.CSE_CAS_Crear_cita_app__c = false;
		citaServicio.CSE_CAS_Urgente__c = false;
		citaServicio.CSE_NUM_Numero_de_Ofrecimientos__c = 1.0;
		citaServicio.Duration = 2;
		citaServicio.DurationType = 'Hours';
		citaServicio.FSL__Auto_Schedule__c = false;
		citaServicio.FSL__Emergency__c = false;
		citaServicio.FSL__InJeopardy__c = false;
		citaServicio.FSL__InternalSLRGeolocation__Latitude__s = 40.381038;
		citaServicio.FSL__InternalSLRGeolocation__Longitude__s = 	-3.734841;
		citaServicio.FSL__IsFillInCandidate__c = true;
		citaServicio.FSL__IsMultiDay__c = false;
		citaServicio.FSL__Pinned__c = false;
		citaServicio.FSL__Prevent_Geocoding_For_Chatter_Actions__c = false;
		citaServicio.FSL__Same_Day__c = false;
		citaServicio.FSL__Same_Resource__c = false;
		//citaServicio.FSL__Schedule_Mode__c = 'Automatic';
		citaServicio.FSL__Scheduling_Policy_Used__c = scheduling.Id;
		citaServicio.FSL__UpdatedByOptimization__c = false;
		citaServicio.FSL__Virtual_Service_For_Chatter_Action__c = false;
		citaServicio.GeocodeAccuracy = 'Zip';
		citaServicio.Latitude = 40.38096;
		citaServicio.Longitude = -3.73376;
		citaServicio.CSE_DAT_Fecha_Proxima_Programacion__c = system.today() +2;
		citaServicio.CSE_DAT_Fecha_Ultima_Programacion__c = system.today() +1;
		citaServicio.status = 'Scheduled';
		citaServicio.ParentRecordId = wo2.ParentWorkOrderId; 
		citaServicio.SchedStartTime = system.today() +2;
		citaServicio.SchedEndTime = system.today() +6;

		insert citaServicio;

		
		//citaServicio = Util_Tests.crearCitaServicio('Madrid', 'Espana', '28000', 'Espana', 'Virgen de la Cabeza', fechaInicio, fechaVencimiento);
		//citaServicio.ParentRecordId = wo2.Id;
		//insert citaServicio;

		recurso = Util_Tests.asignarRecurso(citaServicio, sr);
		recurso.FSL__EstimatedTravelDistanceFrom__c = 100.21;
		recurso.FSL__EstimatedTravelDistanceTo__c = 299.21;
		recurso.FSL__EstimatedTravelTimeFrom__c = 198.21;
		recurso.FSL__UpdatedByOptimization__c = true;
//wo2.ParentWorkOrderId = citaservicio.ParentRecordId;
		//update wo2;

		 System.debug(wo.OTR_LKP_Recurso_Servicio__c + 'Claveee 1');
		 System.debug(wo2.OTR_LKP_Recurso_Servicio__c + 'Claveee 2');
		 System.debug(wo3.OTR_LKP_Recurso_Servicio__c + 'Claveee 3');

		insert recurso;
		List<ServiceResource> Soler3 = [select id, RelatedRecordId from ServiceResource where Id in (Select ServiceResourceId from AssignedResource where ServiceAppointment.ParentRecordId = :wo2.ParentWorkOrderId)];
		//insert soler3;
		
		List<AssignedResource> Soler = [Select ServiceResourceId from AssignedResource WHERE ServiceAppointment.ParentRecordId = :wo2.ParentWorkOrderId  ];
		List<ServiceResource> Soler1 = [select id, RelatedRecordId from ServiceResource];
		//= :wo2.ParentWorkOrderId
		system.debug(Soler + 'QUERYYYYYYY 1');
		system.debug(Soler1 + 'QUERYYYYYYY 2');
		system.debug(Soler3 + 'QUERYYYYYYY 3');
		
		PageReference pageRef = Page.RechazoAlbaran;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',wo2.Id);
		
		
		ApexPages.StandardController sc = new ApexPages.StandardController(wo2);
		RechazoAlbaran rechazo = new RechazoAlbaran(sc);
		RechazoAlbaran.Resultado res = new RechazoAlbaran.Resultado(true, 'Otros', false);
		
		rechazo.cuerpoCorreo='prueba';
		rechazo.motivoList.add(res);
		rechazo.motivoValores.put('09', 'Otros');
		rechazo.cancelar();
		rechazo.rechazoInterno();
		rechazo.rechazoProfesional();
		
		Test.startTest();
		rechazo.rechazo('09',System.UserInfo.getUserId(), false);
		Test.stopTest();
		rechazo.readMotivos();
		
		rechazo.enviarMail(usuario.id, true);
		//rechazo.copiarOTenPadre('03');
		//rechazo.clonePartidas(wo2, wo);
		//rechazo.copiarUltimoAlbaran( wo2, wo);

		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
		evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
		evento.EV_AB_SEL_Descripcion__c = 'E21';
		evento.EV_AB_LKP_Orden_de_Trabajo__c = wo2.Id;
		evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
		evento.EV_AB_SEL_Estado__c = '02';
		evento.EV_AB_LKP_Caso__c = wo2.CaseId;
		evento.EV_DIV_Importe_a_imputar_Departamento__c = 1000.26;
		evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;
		evento.EV_AB_DIV_Importe_profesional__c = 1000.0;
		evento.EV_AB_LKP_Imputar_a_gestor__c = usuario.Id;
		evento.EV_AB_LKP_Imputar_a_profesional__c = wo2.OTR_LKP_Recurso_Servicio__c;
		insert evento;
		Baipas.deshabilitarVariableControl();
	}
	
	
	@isTest public static void TetMethod2(){
		
		 Baipas.establecerVariableControl();
		RecordType princi =[SELECT RecordType.DeveloperName FROM RecordType WHERE RecordType.DeveloperName  = 'CUE_Cliente_B2C_ppaL']; 
		
		scheduling = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		insert scheduling;
		compania = Util_Tests.crearCuentaCompania('CuentaCompañia', '1019', 'X1264567X');
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('Cliente B2B/B2B2C principal','1219','X1134567X');
		cuentaPrincipal.RecordTypeId = princi.Id;
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1020',cuentaPrincipal.Id,'X1114567X');
		cuenta.RecordTypeId = princi.Id;
		insert cuenta;
		Account cuenta2 = Util_Tests.crearCuentaAsegurado('serafin', '1021', 'sera@sera.com', '23017462M', 'pepe', 'roca', 'vergara');
		cuenta2.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert cuenta2;
		cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','PRX1111567X','X1111567X',cuenta2.Id);
		//cuentaProfesional.CUE_SEL_Estado__c = '02'; 
		cuentaProfesional.CUE_LKP_Cuenta_principal__c = Null;
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
		cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuenta.Id;
		insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		update cuentaProfesional;

		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		
		Tipo_Producto_CIA__c tipoProd = new Tipo_Producto_CIA__c();
		tipoProd.Name = 'SegurCaixa333';
		tipoProd.TPR_SEL_Tipo_Producto__c = '01';
		tipoProd.TPR_LKP_Compania__c = cuenta.Id;
		tipoProd.TPR_SEL_Interlocutores_Autorizados__c = 'Padre';
		tipoProd.TPR_TXT_Identificador__c = '435345';
		tipoProd.TPR_LKP_Compania__c = compania.Id;

		insert tipoProd;

		WorkType wt = new WorkType();
		wt.Name = 'Tipo de Trabajo por Defecto';
		wt.EstimatedDuration = 120.0;
		wt.DurationType = 'Minutes';
		wt.TDT_SEL_Categoria__c = '01;02';
		wt.TDT_SEL_Gremio__c = '07';
		wt.ShouldAutoCreateSvcAppt = true;
		wt.TDT_TXT_Identificador__c = '701';

		insert wt;

		OperatingHours oh = new OperatingHours();
		oh.name = 'Horario por defecto';
		oh.OPH_TXT_Identificador__c = '0001';

		insert oh;

		Poblacion__c poblacion = new Poblacion__c();
		poblacion.Name = 'MADRID';
		poblacion.POB_SEL_Provincia__c = '28';
		poblacion.POB_TXT_Identificador__c = '28#MADRID';

		//insert poblacion;

		ServiceTerritory st = new ServiceTerritory();
		st.IsActive = true;
		st.Name = '28015 MADRID';
		st.PostalCode = '28015';
		st.TDS_TXT_Identificador__c = '28015#MADRID';
		st.OperatingHoursId = oh.Id;
		//st.TDS_LKP_Poblacion__c = poblacion.Id; 

		insert st;
		
		ServiceResource sr = new ServiceResource();
		sr.RSE_LKP_Cuenta__c = cuentaProfesional.Id;
		sr.Name = cuentaProfesional.CUE_TXT_Identificador__c + '_01_2';

		sr.RelatedRecordId = system.UserInfo.getUserId();
		sr.RSE_TXT_Codigo_Recurso__c = '1242141';
		sr.IsCapacityBased = true;
		sr.IsActive = true;
		sr.RSE_SEL_Gremio__c='01';
		
		insert sr;

		ServiceTerritoryMember stm = new ServiceTerritoryMember();
		stm.EffectiveStartDate = system.now();
		stm.MTS_CAS_Creado_para_guardia__c = false;
		stm.MTS_CAS_Procesado_Festivo__c = false;
		stm.ServiceTerritoryId = st.Id;
		stm.TerritoryType = 'P';
		stm.OperatingHoursId = oh.Id;
		stm.MTS_TXT_Identificador__c = 'STM-0012_28015#MADRID';
		stm.PostalCode = '28015';
		stm.ServiceResourceId = sr.Id;
		stm.State='01';
		insert stm;
		
		//List<WorkOrder> listaOTs = new List<WorkOrder>();
		WorkOrder wo = new WorkOrder();
		wo.AccountId = cuenta.Id;
		wo.City = 'Madrid';
		wo.StartDate = system.now();
		wo.Duration = 2.0;
		wo.DurationType = 'Hours';
		wo.Latitude = 40.48023673004623;
		wo.Longitude = -3.6690412312805356;
		wo.WorkTypeId = wt.Id;
		wo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815917';
		wo.ServiceTerritoryId = st.Id;
		wo.CreatedDate = system.now();
		wo.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo.OTR_SEL_Rango_Primera_Cita__c = '07';
		wo.OwnerId = System.UserInfo.getUserId();
		wo.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';
		wo.CaseId = caso.Id;
		wo.OTR_LKP_Recurso_Servicio__c = sr.id;
		wo.ParentWorkOrderId = wo.Id;
		//listaOTs.add(wo);
		insert wo;
		
		WorkOrder wo2 = new WorkOrder();
		wo2.AccountId = cuenta.Id;
		wo2.City = 'Madrid';
		wo2.StartDate = system.now();
		wo2.Duration = 2.0;
		wo2.DurationType = 'Hours';
		wo2.Latitude = 40.48023673004623;
		wo2.Longitude = -3.6690412312805356;
		wo2.WorkTypeId = wt.Id;
		wo2.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815817';
		wo2.ServiceTerritoryId = st.Id;
		wo2.CreatedDate = system.now();
		wo2.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo2.OTR_SEL_Rango_Primera_Cita__c = '07';
		wo2.OwnerId = System.UserInfo.getUserId();
		wo2.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';
		wo2.CaseId = caso.Id;
		Datetime posibleFechaReserva = Datetime.now().addDays(Util_Cita_Servicio.sumarDias(Datetime.now()));
		wo2.OTR_DAT_Fecha_Primera_Cita__c = posibleFechaReserva.date();
		wo2.OTR_SEL_Rango_Primera_Cita__c = '07';
		wo2.OTR_LKP_Recurso_Servicio__c = sr.id;	 
		
		wo2.ParentWorkOrderId = wo.Id;
		
		//listaOTs.add(wo2);
		insert wo2;

		//insert listaOTs;
		
		WorkOrder wo3 = new WorkOrder();
		insert wo3;

	list <Task> listas = new list<Task> ();
							Task Tarea1 = new Task();
							Tarea1.WhatId = wo2.ParentWorkOrderId ;
							Tarea1.Status = 'Finalizado';
							//Tarea1.Subject = 'Correo electrónico: Hola';

							listas.add(Tarea1);

							insert listas;

		WorkOrderLineItem partida = Util_Tests.crearNuevaPartidaTrabajo(wo.Id);
		insert partida;
		
		 Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;
		
		datetime mydate = system.today() + 1;
		datetime newDate = mydate.addHours(2);
		//Datetime myDateTime = Datetime.newInstance(2018, 02, 19);
		Datetime myDateTime = Datetime.newInstance(2018, 03,06,12,10,10);
		Datetime dueDate = myDateTime.addDays(2);
		//Datetime arrivalDate = myDateTime.addDays(-2);
		Datetime arrivalDate = myDateTime;
		Datetime arrivalStartDate = arrivalDate.addDays(-15); 
		
		citaServicio = Util_Tests.crearCitaServicio('Madrid','España','','','',myDateTime,dueDate);
		
		citaServicio.CreatedById = system.UserInfo.getUserId();
		citaServicio.ArrivalWindowEndTime = arrivalDate;
		citaServicio.ArrivalWindowStartTime = arrivalDate;
		//citaServicio.FSL__Auto_Schedule__c = true;
		citaServicio.CSE_CAS_Asignada__c = false;
		citaServicio.CSE_CAS_Asignar_como_Urgencias__c = false;
		citaServicio.CSE_CAS_Asignar_territorio_prim_no_franq__c = false;
		citaServicio.CSE_CAS_Asignar_Como_Franquiciado__c = false;
		citaServicio.CSE_CAS_Asignar_Mizad__c = false;
		citaServicio.CSE_CAS_Comprobado_Horario__c = false;
		citaServicio.CSE_CAS_Crear_cita_app__c = false;
		citaServicio.CSE_CAS_Urgente__c = false;
		citaServicio.CSE_NUM_Numero_de_Ofrecimientos__c = 1.0;
		citaServicio.Duration = 2;
		citaServicio.DurationType = 'Hours';
		citaServicio.FSL__Auto_Schedule__c = false;
		citaServicio.FSL__Emergency__c = false;
		citaServicio.FSL__InJeopardy__c = false;
		citaServicio.FSL__InternalSLRGeolocation__Latitude__s = 40.381038;
		citaServicio.FSL__InternalSLRGeolocation__Longitude__s = 	-3.734841;
		citaServicio.FSL__IsFillInCandidate__c = true;
		citaServicio.FSL__IsMultiDay__c = false;
		citaServicio.FSL__Pinned__c = false;
		citaServicio.FSL__Prevent_Geocoding_For_Chatter_Actions__c = false;
		citaServicio.FSL__Same_Day__c = false;
		citaServicio.FSL__Same_Resource__c = false;
		//citaServicio.FSL__Schedule_Mode__c = 'Automatic';
		citaServicio.FSL__Scheduling_Policy_Used__c = scheduling.Id;
		citaServicio.FSL__UpdatedByOptimization__c = false;
		citaServicio.FSL__Virtual_Service_For_Chatter_Action__c = false;
		citaServicio.GeocodeAccuracy = 'Zip';
		citaServicio.Latitude = 40.38096;
		citaServicio.Longitude = -3.73376;
		citaServicio.CSE_DAT_Fecha_Proxima_Programacion__c = system.today() +2;
		citaServicio.CSE_DAT_Fecha_Ultima_Programacion__c = system.today() +1;
		citaServicio.status = 'Scheduled';
		citaServicio.ParentRecordId = wo2.ParentWorkOrderId; 
		citaServicio.SchedStartTime = system.today() +2;
		citaServicio.SchedEndTime = system.today() +6;

		insert citaServicio;

		recurso = Util_Tests.asignarRecurso(citaServicio, sr);
		recurso.FSL__EstimatedTravelDistanceFrom__c = 100.21;
		recurso.FSL__EstimatedTravelDistanceTo__c = 299.21;
		recurso.FSL__EstimatedTravelTimeFrom__c = 198.21;
		recurso.FSL__UpdatedByOptimization__c = true;

		 System.debug(wo.OTR_LKP_Recurso_Servicio__c + 'Claveee 1');
		 System.debug(wo2.OTR_LKP_Recurso_Servicio__c + 'Claveee 2');
		 System.debug(wo3.OTR_LKP_Recurso_Servicio__c + 'Claveee 3');

		insert recurso;
		List<ServiceResource> Soler3 = [select id, RelatedRecordId from ServiceResource where Id in (Select ServiceResourceId from AssignedResource where ServiceAppointment.ParentRecordId = :wo2.ParentWorkOrderId)];
		//insert soler3;
		
		List<AssignedResource> Soler = [Select ServiceResourceId from AssignedResource WHERE ServiceAppointment.ParentRecordId = :wo2.ParentWorkOrderId  ];
		List<ServiceResource> Soler1 = [select id, RelatedRecordId from ServiceResource];
		//= :wo2.ParentWorkOrderId
		system.debug(Soler + 'QUERYYYYYYY 1');
		system.debug(Soler1 + 'QUERYYYYYYY 2');
		system.debug(Soler3 + 'QUERYYYYYYY 3');

		PageReference pageRef = Page.RechazoAlbaran;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',wo2.Id);
		
		
		ApexPages.StandardController sc = new ApexPages.StandardController(wo2);
		RechazoAlbaran rechazo = new RechazoAlbaran(sc);
		RechazoAlbaran.Resultado res = new RechazoAlbaran.Resultado(true, 'Otros', false);
		
		rechazo.cuerpoCorreo='prueba';
		rechazo.motivoList.add(res);
		rechazo.motivoValores.put('09', 'Otros');
		rechazo.cancelar();
		rechazo.rechazoInterno();
		rechazo.rechazoProfesional();

		Test.startTest();
		rechazo.rechazo('09',System.UserInfo.getUserId(), false);
		Test.stopTest();
		rechazo.readMotivos();

		rechazo.enviarMail(usuario.id, true);
		//rechazo.copiarOTenPadre('03');
		//rechazo.clonePartidas(wo2, wo);
		//rechazo.copiarUltimoAlbaran( wo2, wo);

		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
		evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
		evento.EV_AB_SEL_Descripcion__c = 'E21';
		evento.EV_AB_LKP_Orden_de_Trabajo__c = wo2.Id;
		evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
		evento.EV_AB_SEL_Estado__c = '02';
		evento.EV_AB_LKP_Caso__c = wo2.CaseId;
		evento.EV_DIV_Importe_a_imputar_Departamento__c = 1000.26;
		evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;
		evento.EV_AB_DIV_Importe_profesional__c = 1000.0;
		evento.EV_AB_LKP_Imputar_a_gestor__c = usuario.Id;
		evento.EV_AB_LKP_Imputar_a_profesional__c = wo2.OTR_LKP_Recurso_Servicio__c;
		insert evento;
		Baipas.deshabilitarVariableControl();
	}

}