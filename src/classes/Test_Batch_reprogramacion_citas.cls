@isTest
public without sharing class Test_Batch_reprogramacion_citas{
	
	private static WorkOrder wo{get; set;}
	private static ServiceAppointment saTMP {get; set;}
	private static ServiceAppointment sa {get; set;}
	private static List<ServiceAppointment> saList {get; set;}
	private static  Historico_de_Asignaciones__c historico {get; set;}
	private static Datetime posibleFechaReserva {get; set;}

	private static void InicializarVariables(){

		Baipas.establecerVariableControl();
		saList = new List<ServiceAppointment> ();

		FSL__Scheduling_Policy__c sp = new FSL__Scheduling_Policy__c();
		sp.Name = 'Política de Asignación – Geolocalización';
		insert sp;

		Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;

		Account cuenta = Util_Tests.crearCuentaAsegurado('serafin','popupuup', 'sera@sera.com', '23017462M', 'pepe', 'roca', 'vergara');
		cuenta.CUE_SEL_Estado__c = '02'; //02 es 'Activo'
		cuenta.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert cuenta;

		Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',cuenta.Id);
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01'; //01 es 'Autonomo'
		cuentaProfesional.CUE_CAS_Activado__c = false;
		//cuentaProfesional.CUE_LKP_Cuenta_principal__c = Null;
		cuentaProfesional.CUE_SEL_Estado__c = '01'; //01 es 'Preactivado'		
		insert cuentaProfesional;

		cuentaProfesional.CUE_SEL_Estado__c = '02'; //02 es 'Activo'
		update cuentaProfesional;

		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		User usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuari;

		Account cuentaProfUp = [SELECT Id, Name, CUE_TXT_Identificador__c FROM Account WHERE Id=:cuentaProfesional.Id];
		ServiceResource sr = Util_Tests.crearRecursoServicio('David','Estanislao',cuentaProfUp.Id,usuari);
		sr.Name = cuentaProfUp.CUE_TXT_Identificador__c + '_01_1';
		insert sr;

		Tipo_Producto_CIA__c tipoProd = new Tipo_Producto_CIA__c();
		tipoProd.Name = 'SegurCaixa333';
		tipoProd.TPR_SEL_Tipo_Producto__c = '01';
		tipoProd.TPR_LKP_Compania__c = cuenta.Id;
		tipoProd.TPR_SEL_Interlocutores_Autorizados__c = 'Padre';
		tipoProd.TPR_TXT_Identificador__c = '435345';
		tipoProd.TPR_LKP_Compania__c = compania.Id;
		insert tipoProd;

		Producto_CIA__c producto = Util_Tests.crearProductoCIA('Producto', '51565', tipoProd.Id);
		insert producto;

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
		insert poblacion;

		ServiceTerritory st = new ServiceTerritory();
		st.IsActive = true;
		st.Name = '28015 MADRID';
		st.PostalCode = '28015';
		st.TDS_TXT_Identificador__c = '28015#MADRID';
		st.OperatingHoursId = oh.Id;
		insert st;

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
		
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Miguel',compania.Id, cuenta.Id, producto.Id);
		insert poliza;
		Case caso = Util_Tests.crearCasoSini(poliza.Id,cuenta.Id,compania.Id);
		insert caso;

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
		posibleFechaReserva = Datetime.now().addDays(Util_Cita_Servicio.sumarDias(Datetime.now()));
		wo.OTR_DAT_Fecha_Primera_Cita__c = posibleFechaReserva.date();
		wo.OTR_SEL_Rango_Primera_Cita__c = '07';
		wo.PostalCode = '28001';
		wo.OTR_SEL_Gremio__c = '01';
		wo.CaseId = caso.Id;
		wo.OTR_CAS_Urgente__c = true;
		insert wo;

		system.debug('CONSULTAAA '+[SELECT Id From ServiceAppointment]);

		List<ServiceAppointment> serviceApp = new List<ServiceAppointment>([
			SELECT	AccountId,
			ActualDuration,
			ActualEndTime,
			ActualStartTime,
			Address,
			AppointmentNumber,
			ArrivalWindowEndTime,
			ArrivalWindowStartTime,
			City,
			ContactId,
			Country,
			CreatedById,
			CreatedDate,
			CSE_CAS_Asignada__c,
			CSE_CAS_Asignar_Como_Franquiciado__c,
			CSE_CAS_Asignar_como_Urgencias__c,
			CSE_CAS_Asignar_Mizad__c,
			CSE_CAS_Asignar_territorio_prim_no_franq__c,
			CSE_CAS_Comprobado_Horario__c,
			CSE_CAS_Crear_cita_app__c,
			CSE_CAS_Urgente__c,
			CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c,
			CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c,
			CSE_DAT_Fecha_para_nueva_cita__c,
			CSE_DAT_Fecha_Proxima_Programacion__c,
			CSE_DAT_Fecha_Ultima_Programacion__c,
			CSE_FOR_Calculo_de_Segmentacion__c,
			CSE_FOR_Num_Asociado_Mizad__c,
			CSE_FOR_Num_Asociado_Urgencias__c,
			CSE_NUM_Numero_de_Ofrecimientos__c,
			CSE_SEL_Gremio__c,
			CSE_SEL_Hora_para_nueva_cita__c,
			CSE_SEL_Motivo_Desasignacion__c,
			CSE_SEL_Motivo_Retraso__c,
			CSE_SEL_Tipo_Red__c,
			CSE_TXT_Comentario_Estado__c,
			CSE_TXT_Identificador__c,
			CSE_TXT_Segmentacion_Cliente__c,
			Description,
			DueDate,
			Duration,
			DurationInMinutes,
			DurationType,
			EarliestStartTime,
			FSL__Appointment_Grade__c,
			FSL__Auto_Schedule__c,
			FSL__Emergency__c,
			FSL__GanttColor__c,
			FSL__GanttLabel__c,
			FSL__InJeopardyReason__c,
			FSL__InJeopardy__c,
			FSL__InternalSLRGeolocation__c,
			FSL__InternalSLRGeolocation__Latitude__s,
			FSL__InternalSLRGeolocation__Longitude__s,
			FSL__IsFillInCandidate__c,
			FSL__IsMultiDay__c,
			FSL__Pinned__c,
			FSL__Prevent_Geocoding_For_Chatter_Actions__c,
			FSL__Related_Service__c,
			FSL__Same_Day__c,
			FSL__Same_Resource__c,
			FSL__Schedule_Mode__c,
			FSL__Scheduling_Policy_Used__c,
			FSL__Time_Dependency__c,
			FSL__UpdatedByOptimization__c,
			FSL__Virtual_Service_For_Chatter_Action__c,
			GeocodeAccuracy,
			Id,
			IsDeleted,
			LastModifiedById,
			LastModifiedDate,
			LastReferencedDate,
			LastViewedDate,
			Latitude,
			Longitude,
			OwnerId,
			ParentRecordId,
			ParentRecordStatusCategory,
			ParentRecordType,
			PostalCode,
			RecordTypeId,
			SchedEndTime,
			SchedStartTime,
			ServiceNote,
			ServiceTerritoryId,
			State,
			Status,
			StatusCategory,
			Street,
			Subject,
			SystemModstamp,
			WorkTypeId FROM ServiceAppointment]);

		sa = serviceApp.get(0);

		sa.ArrivalWindowStartTime=date.today();
		sa.ArrivalWindowEndTime=date.today();
        //sa.Status=Label.CIT_ESTADO_PROGRAMADO;
        system.debug('OBJETOOOO1 '+sa);
        update sa;

        system.debug('OBJETOOOO2 '+[SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment]);

        FSL__Scheduling_Policy__c scheduling = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
        insert scheduling;

        /*DEG*/
        saTMP = new ServiceAppointment();
        saTMP.ParentRecordId=wo.Id;
        saTMP.Status= Null;	
        saTMP.EarliestStartTime = posibleFechaReserva;
        saTMP.ArrivalWindowStartTime = posibleFechaReserva.addYears(-1);
        //saTMP.ArrivalWindowEndTime = posibleFechaReserva.addYears(-1).addHours(1);
        saTMP.DueDate = posibleFechaReserva;
        satmp.CreatedDate = DateTime.now().AddHours(-1);
        saTMP.CSE_CAS_Urgente__c = False;
        saTMP.FSL__Scheduling_Policy_Used__c = scheduling.Id;
        insert saTMP;
        system.debug(saTMP + ' SAAAAAATMP');
        
        saList.add(saTMP);
        
        historico = new Historico_de_Asignaciones__c();
        historico = TRG_Handler_Cita_de_Servicio.crearRegistroHistoricoAsignacion(sa,'estadoNuevo','estadoAntiguo',sr.Id, true);
        historico.HAS_TXT_Estado_Nuevo_Cita__c = label.CIT_ESTADO_CADUCADO;
        historico.HAS_LKP_Cita_de_Servicio__c = saTMP.Id;
        insert historico;

        Festivos__c festivos = new Festivos__c();
        festivos.FES_SEL_Tipo_de_Festivo__c = 'Nacional';
        festivos.FES_DAT_Fecha__c = posibleFechaReserva.date();
        insert festivos;

        Festivos__c festivosL = new Festivos__c();
        festivosL.FES_SEL_Tipo_de_Festivo__c = 'Local';
        festivosL.FES_DAT_Fecha__c = Date.today();
        festivosL.FES_LKP_Territorio__c = saTMP.ServiceTerritoryId;
        insert festivosL;
        
        ResourcePreference rp = new ResourcePreference();
        rp.ServiceResourceId = sr.Id;
        rp.RelatedRecordId = wo.Id;
        rp.PreferenceType= 'Excluded';
        insert rp;

		/*Historico_de_Asignaciones__c histAsignaciones = new Historico_de_Asignaciones__c();
		histAsignaciones.HAS_LKP_Cita_de_Servicio__c = */

	}

	public static Account getAccountCompany(String name){
		Account cuenta;

		List<Account> listaCuentas = new List<Account>([Select Id,
			Name,
			ShippingStreet,
			ShippingPostalCode,
			ShippingCity,
			ShippingState,
			CUE_TXT_Identificador__c,
			CUE_EMA_Email__c,
			RecordTypeId,
			CUE_TXT_Numero_Documento__c,
			CUE_TXT_PrimerApellido__c,
			CUE_TXT_Nombre__c,
			CUE_CAS_No_Permite_Servicio_B2C__c,
			CUE_TXT_Presentacion__c,
			CUE_TXT_SegundoApellido__c,
			CUE_LKP_Cuenta_principal__c 
			FROM Account Where Name = :name LIMIT 1]);

		if(!listaCuentas.isEmpty()){
			cuenta = listaCuentas.get(0);
		}else{
			throw new TestException('No existen cuentas con el nombre especificado');
		}
		return cuenta;
	}

	@isTest
	public static void prueba(){

		InicializarVariables();

		system.debug([SELECT CCM_TXT_CP__c, CCM_SEL_Franja_Horaria__c, CCM_TXT_Gremio__c, 
			CCM_TXT_Identificador_CIA__c, CCM_TXT_Suceso__c, CCM_DEC_Tiempo__c,
			CCM_CAS_Urgencia__c
			FROM Cambios_a_Cita_Manual_Motor__mdt ] + ' queryy ');

		Test.startTest();

		BATCH_Reprogramacion_Citas citas = new BATCH_Reprogramacion_Citas(30);
		citas.start(null);
		citas.execute(null, saList);

		Test.stopTest();

	}

	@isTest
	public static void NotEstadoCaducado(){

		InicializarVariables();

		historico.HAS_TXT_Estado_Nuevo_Cita__c = Label.CIT_ESTADO_RECHAZADO;
		update historico;

		Test.startTest();

		BATCH_Reprogramacion_Citas citas = new BATCH_Reprogramacion_Citas(30);
		citas.start(null);
		citas.execute(null, saList);

		Test.stopTest();

	}

	@isTest
	public static void ChangeStatusUrgen(){

		InicializarVariables();

		saTMP.CSE_CAS_Urgente__c = True;
		update saTMP;

		Test.startTest();

		BATCH_Reprogramacion_Citas citas = new BATCH_Reprogramacion_Citas(30);
		citas.start(null);
		citas.execute(null, saList);

		Test.stopTest();

	}

	@isTest
	public static void ArrivalStartArrivalEnd(){

		InicializarVariables();

		saTMP.ArrivalWindowEndTime = posibleFechaReserva.addYears(-1).addHours(1);    
		update saTMP;

		Test.startTest();

		BATCH_Reprogramacion_Citas citas = new BATCH_Reprogramacion_Citas(30);
		citas.start(null);
		citas.execute(null, saList);

		Test.stopTest();

	}
}