@isTest
public without sharing class Test_Util_Cita_Servicio {
    
    public static Account compania;
    public static Account cuenta;
    public static Tipo_Producto_CIA__c tipoProducto;
    public static Producto_CIA__c producto;
    public static Procedencia__c procedencia;
    public static ServiceContract sv;
    public static Case caso;
    public static WorkType wt;
    public static OperatingHours oh;
    public static ServiceTerritory st;
    public static WorkOrder wo;
    public static Account cuentaPrincipal;
    

    private static void inicialize(){
        
        compania = Util_Tests.crearCuentaCompania('CuentaCompañia', '1019', 'X1264567X');
        compania.Type = '01';
        insert compania; 
        
        
        cuenta = Util_Tests.crearCuentaB2BPpal('Name','12345', 'X1234567X');
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
        cuenta.Type = '01';
        insert cuenta;
    
        tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto; 
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;  
        
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        insert procedencia;
        
      	sv = Util_Tests.crearPolizaContrato('Alberto', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        
        caso = new Case();
        caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        caso.CAS_SEL_Encuestador__c = 'Servitelco';
        caso.CAS_LKP_Compania__c = compania.Id;
        caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CreatedDate = system.now();
        caso.Status = '993';
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso;
        
        
        wt = new WorkType();
		wt.Name = 'Tipo de Trabajo por Defecto';
		wt.EstimatedDuration = 120.0;
		wt.DurationType = 'Minutes';
		wt.TDT_SEL_Categoria__c = '01;02';
		wt.TDT_SEL_Gremio__c = '07';
		wt.ShouldAutoCreateSvcAppt = true;
		wt.TDT_TXT_Identificador__c = '701';

		insert wt;
        
        oh = new OperatingHours();
		oh.name = 'Horario por defecto';
		oh.OPH_TXT_Identificador__c = '0001';

		insert oh;
        
        
		st = new ServiceTerritory();
		st.IsActive = true;
		st.Name = '28015 MADRID';
		st.PostalCode = '28015';
		st.TDS_TXT_Identificador__c = '28015#MADRID';
		st.OperatingHoursId = oh.Id;
		//st.TDS_LKP_Poblacion__c = poblacion.Id; 

		insert st;
        
        wo = new WorkOrder();
		wo.AccountId = cuenta.Id;
        wo.CaseId = caso.Id;
		wo.City = 'Madrid';
		wo.StartDate = system.now();
		wo.Duration = 2.0;
		wo.DurationType = 'Hours';
		wo.Latitude = 40.48023673004623;
		wo.Longitude = -3.6690412312805356;
		wo.WorkTypeId = wt.Id;
		wo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815917';
		wo.ServiceTerritoryId = st.Id;
		Datetime posibleFechaReserva = Datetime.now().addDays(Util_Cita_Servicio.sumarDias(Datetime.now()));
		wo.OTR_DAT_Fecha_Primera_Cita__c = posibleFechaReserva.date();
		//wo.CreatedDate = system.now();
		//wo.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo.OTR_SEL_Rango_Primera_Cita__c = '07';
        wo.OwnerId = System.UserInfo.getUserId();
        wo.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';

		insert wo;
        
    }
    @isTest static void util_Cita_Servicio(){
        Test.isRunningTest();
        inicialize();
        Util_cita_servicio.calcularFechaInicio(system.now(), true);
        Util_cita_servicio.calcularFechaInicio(system.now(), false);
        List<ServiceAppointment> serviceApp = new List<ServiceAppointment>([SELECT AccountId,ActualDuration,ActualEndTime,ActualStartTime,Address,AppointmentNumber,ArrivalWindowEndTime,ArrivalWindowStartTime,City,ContactId,Country,CreatedById,CreatedDate,CSE_CAS_Asignada__c,CSE_CAS_Asignar_Como_Franquiciado__c,CSE_CAS_Asignar_como_Urgencias__c,CSE_CAS_Asignar_Mizad__c,CSE_CAS_Asignar_territorio_prim_no_franq__c,CSE_CAS_Comprobado_Horario__c,CSE_CAS_Crear_cita_app__c,CSE_CAS_Urgente__c,CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c,CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c,CSE_DAT_Fecha_para_nueva_cita__c,CSE_DAT_Fecha_Proxima_Programacion__c,CSE_DAT_Fecha_Ultima_Programacion__c,CSE_FOR_Calculo_de_Segmentacion__c,CSE_FOR_Num_Asociado_Mizad__c,CSE_FOR_Num_Asociado_Urgencias__c,CSE_NUM_Numero_de_Ofrecimientos__c,CSE_SEL_Gremio__c,CSE_SEL_Hora_para_nueva_cita__c,CSE_SEL_Motivo_Desasignacion__c,CSE_SEL_Motivo_Retraso__c,CSE_SEL_Tipo_Red__c,CSE_TXT_Comentario_Estado__c,CSE_TXT_Identificador__c,CSE_TXT_Segmentacion_Cliente__c,Description,DueDate,Duration,DurationInMinutes,DurationType,EarliestStartTime,FSL__Appointment_Grade__c,FSL__Auto_Schedule__c,FSL__Emergency__c,FSL__GanttColor__c,FSL__GanttLabel__c,FSL__InJeopardyReason__c,FSL__InJeopardy__c,FSL__InternalSLRGeolocation__c,FSL__InternalSLRGeolocation__Latitude__s,FSL__InternalSLRGeolocation__Longitude__s,FSL__IsFillInCandidate__c,FSL__IsMultiDay__c,FSL__Pinned__c,FSL__Prevent_Geocoding_For_Chatter_Actions__c,FSL__Related_Service__c,FSL__Same_Day__c,FSL__Same_Resource__c,FSL__Schedule_Mode__c,FSL__Scheduling_Policy_Used__c,FSL__Time_Dependency__c,FSL__UpdatedByOptimization__c,FSL__Virtual_Service_For_Chatter_Action__c,GeocodeAccuracy,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Latitude,Longitude,OwnerId,ParentRecordId,ParentRecordStatusCategory,ParentRecordType,PostalCode,RecordTypeId,SchedEndTime,SchedStartTime,ServiceNote,ServiceTerritoryId,State,Status,StatusCategory,Street,Subject,SystemModstamp,WorkTypeId FROM ServiceAppointment]);
		ServiceAppointment sa = serviceApp.get(0);

		List<ServiceAppointment> saList = new List<ServiceAppointment>();
        saList.add(sa);
        Util_cita_servicio.actualizarReclamacionesEstado(saList);
        Set<Id> citas = new Set<Id>();
        citas.add(sa.Id);
        //Util_cita_servicio.getRecursosAsignados(citas);
        Test.isRunningTest();
    }
}