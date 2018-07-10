@isTest(seeAllData = true)
public without sharing class Test_TRG_Handler_Recurso_Asignado{
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
    private static WorkType tipoTrabajo;

    static testMethod void actualizarCitaServicioAsignacionDirectaTest(){
       
        Baipas.establecerVariableControl();
        List<Account> listaCuentas = new List<Account>();
        Account compania = Util_Tests.crearCuentaCompania('compania', '111018','X1234567X');
        listaCuentas.add(compania);
        //compania.CUE_TXT_Numero_Documento__c='2153523646';
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		listaCuentas.add(cuentaPrincipal);
		insert listaCuentas;
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		insert cuenta;

		cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123486','PR155586','E1234567E',compania.id);
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01'; //Autonomo
        insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;

		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;

		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        productoCIA.PRD_TXT_Identificador__c = '58765657';
		insert productoCIA;
		//poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		poblacion = new Poblacion__c();
		poblacion.Name = 'Madrid_Test';
		poblacion.POB_SEL_Provincia__c = '28';
		poblacion.POB_TXT_Identificador__c = '28#Madrid_Test';
		insert poblacion;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        caso.CAS_TXT_Identificador__c = '678576897';
		insert caso;
        ServiceResource sr = new ServiceResource();
        sr.RSE_LKP_Cuenta__c = cuentaProfesional.Id;
        sr.Name = cuentaProfesional.CUE_TXT_Identificador__c+'_01_1';
        sr.RelatedRecordId = usuario.id;
        sr.RSE_TXT_Codigo_Recurso__c = cuentaProfesional.Name+'_01_1';
        sr.IsCapacityBased = true;
        sr.IsActive = true;
        
        insert sr;
        
        Tipo_Producto_CIA__c tipoProd = new Tipo_Producto_CIA__c();
        tipoProd.Name = 'SegurCaixa333';
        tipoProd.TPR_SEL_Tipo_Producto__c = '01';
        tipoProd.TPR_LKP_Compania__c = compania.Id;
        tipoProd.TPR_SEL_Interlocutores_Autorizados__c = 'Padre';
        tipoProd.TPR_TXT_Identificador__c = '435345_Test';
        
        insert tipoProd;
        
        WorkType wt = new WorkType();
        wt.Name = 'Tipo de Trabajo por Defecto';
        wt.EstimatedDuration = 120.0;
        wt.DurationType = 'Minutes';
        wt.TDT_SEL_Categoria__c = '01;02';
        wt.TDT_SEL_Gremio__c = '07';
        wt.ShouldAutoCreateSvcAppt = true;
        wt.TDT_TXT_Identificador__c = '701_Test';
        
        insert wt;
        
        OperatingHours oh = new OperatingHours();
        oh.name = 'Horario por defecto';
        oh.OPH_TXT_Identificador__c = 'Test';
        
        insert oh;
        
        Poblacion__c poblacion = new Poblacion__c();
        poblacion.Name = 'MADRID_Test';
        poblacion.POB_SEL_Provincia__c = '28';
        poblacion.POB_TXT_Identificador__c = '28#MADRID_Test';
        
        //insert poblacion;
        
        ServiceTerritory st = new ServiceTerritory();
        st.IsActive = true;
        st.Name = '69096 Ochitoria';
        st.PostalCode = '69096';
        st.TDS_TXT_Identificador__c = '69096#Ochitoria_Test';
        st.OperatingHoursId = oh.Id;
        //st.TDS_LKP_Poblacion__c = poblacion.Id; 
        
        insert st;
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.EffectiveStartDate = DateTime.newInstance(2018, 3, 13, 12, 0, 0);
        stm.MTS_CAS_Creado_para_guardia__c = false;
        stm.MTS_CAS_Procesado_Festivo__c = false;
        stm.ServiceTerritoryId = st.Id;
        stm.TerritoryType = 'P';
        stm.OperatingHoursId = oh.Id;
        stm.MTS_TXT_Identificador__c = 'STM-0012_69096#Ochitoria_Test';
        stm.PostalCode = '69096';
        stm.ServiceResourceId = sr.Id;
        /*stm.FSL__Internal_SLR_HomeAddress_Geolocation__Longitude__s = 98989.89;
        stm.Street = 'jkdhfalshflkjas';
        stm.City = 'Madrid';
        stm.Country = 'España';
        stm.PostalCode = '28001';*/
        
        insert stm;
        tipoTrabajo = Util_Tests.crearTipoTrabajo('Siniestro', '21', 2.5);
        insert tipoTrabajo;
        
        WorkOrder wo = Util_Tests.crearOrdenTrabajo('26032018', '75', tipoTrabajo.id, caso.Id);

        insert wo;
        
        List<ServiceAppointment> serviceApp = new List<ServiceAppointment>([SELECT AccountId
                                                                    ,ActualDuration,ActualEndTime,ActualStartTime,Address,AppointmentNumber,ArrivalWindowEndTime
                                                                    ,ArrivalWindowStartTime,City,ContactId,Country,CreatedById,CreatedDate,CSE_CAS_Asignada__c
                                                                    ,CSE_CAS_Asignar_Como_Franquiciado__c,CSE_CAS_Asignar_como_Urgencias__c,CSE_CAS_Asignar_Mizad__c
                                                                    ,CSE_CAS_Asignar_territorio_prim_no_franq__c,CSE_CAS_Comprobado_Horario__c
                                                                    ,CSE_CAS_Crear_cita_app__c,CSE_CAS_Urgente__c,CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c
                                                                    ,CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c,CSE_DAT_Fecha_para_nueva_cita__c
                                                                    ,CSE_DAT_Fecha_Proxima_Programacion__c,CSE_DAT_Fecha_Ultima_Programacion__c
                                                                    ,CSE_FOR_Calculo_de_Segmentacion__c,CSE_FOR_Num_Asociado_Mizad__c,CSE_FOR_Num_Asociado_Urgencias__c
                                                                    ,CSE_NUM_Numero_de_Ofrecimientos__c,CSE_SEL_Gremio__c,CSE_SEL_Hora_para_nueva_cita__c
                                                                    ,CSE_SEL_Motivo_Desasignacion__c,CSE_SEL_Motivo_Retraso__c,CSE_SEL_Tipo_Red__c
                                                                    ,CSE_TXT_Comentario_Estado__c,CSE_TXT_Identificador__c,CSE_TXT_Segmentacion_Cliente__c
                                                                    ,Description,DueDate,Duration,DurationInMinutes,DurationType,EarliestStartTime
                                                                    ,FSL__Appointment_Grade__c,FSL__Auto_Schedule__c,FSL__Emergency__c,FSL__GanttColor__c
                                                                    ,FSL__GanttLabel__c,FSL__InJeopardyReason__c,FSL__InJeopardy__c,FSL__InternalSLRGeolocation__c
                                                                    ,FSL__InternalSLRGeolocation__Latitude__s,FSL__InternalSLRGeolocation__Longitude__s
                                                                    ,FSL__IsFillInCandidate__c,FSL__IsMultiDay__c,FSL__Pinned__c
                                                                    ,FSL__Prevent_Geocoding_For_Chatter_Actions__c,FSL__Related_Service__c,FSL__Same_Day__c
                                                                    ,FSL__Same_Resource__c,FSL__Schedule_Mode__c,FSL__Scheduling_Policy_Used__c,FSL__Time_Dependency__c
                                                                    ,FSL__UpdatedByOptimization__c,FSL__Virtual_Service_For_Chatter_Action__c,GeocodeAccuracy,Id,IsDeleted
                                                                    ,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Latitude,Longitude,OwnerId
                                                                    ,ParentRecordId,ParentRecordStatusCategory,ParentRecordType,PostalCode,RecordTypeId,SchedEndTime
                                                                    ,SchedStartTime,ServiceNote,ServiceTerritoryId,State,Status,StatusCategory,Street,Subject
                                                                    ,SystemModstamp,WorkTypeId 
                                                                    FROM ServiceAppointment where ParentRecordId = :wo.Id]);

        ServiceAppointment sa = serviceApp.get(0);
        //ServiceAppointment sa = new ServiceAppointment();
        sa.EarliestStartTime = DateTime.newInstance(2018,3,15,14,0,0);
        sa.DueDate = sa.EarliestStartTime.addDays(1);
        //sa.EarliestStartTime = wo.CreatedDate.addDays(2);
        //sa.DueDate = wo.CreatedDate.addDays(4);
        sa.Duration = 2.0;
        //sa.SchedEndTime = wo.CreatedDate.addDays(2).addHours(1);
        //sa.SchedStartTime = wo.CreatedDate.addDays(2);
        sa.SchedEndTime = sa.EarliestStartTime.addDays(1).addHours(1);
        sa.SchedStartTime = sa.EarliestStartTime.addDays(1);
        //sa.ArrivalWindowStartTime = wo.CreatedDate.addDays(2);
        //sa.ArrivalWindowEndTime = wo.CreatedDate.addDays(2).addHours(1);
        sa.ArrivalWindowStartTime = sa.EarliestStartTime.addDays(1);
        sa.ArrivalWindowEndTime = sa.EarliestStartTime.addDays(1).addHours(1);
        sa.ServiceTerritoryId = st.Id;
        sa.City = 'MADRID';
        sa.CSE_CAS_Asignar_como_Urgencias__c = true;
        //sa.ParentRecordId = wo.Id;
        //sa.Status = 'Anulada por el cambio de cita';
        update sa;
        Baipas.deshabilitarVariableControl();
        
        AssignedResource assign = new AssignedResource();
        assign.ServiceAppointmentId = sa.Id;
        assign.ServiceResourceId = sr.Id;
        insert assign;
        List<AssignedResource> ListaRecursosAsignados = new List<AssignedResource>();
        ListaRecursosAsignados.add(assign);
        TRG_Handler_Recurso_Asignado.sharePartner(ListaRecursosAsignados);   
    }
}