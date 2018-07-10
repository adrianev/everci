@isTest
public without sharing class Test_ReservarCita{
    
    public static ReservarCita reservarCita  {get; set;} 
    private static Account compania {get; set;} 
    private static Account cuenta {get; set;} 
    private static Tipo_Producto_CIA__c tipoProducto {get; set;} 
    private static Producto_CIA__c producto {get; set;} 
    private static ServiceContract sv {get; set;} 
    private static Case caso {get; set;} 
    private static Procedencia__c procedencia {get; set;} 
    private static WorkOrder wo {get; set;} 
    private static WorkType tipoTrabajo {get; set;} 
    private static Festivos__c festivo  {get; set;} 
    
    
    @isTest static void testVolver(){
        baipas.establecerVariableControl();
        Test.startTest();
    	compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        cuenta.type = '01';
		insert cuenta;
        
        Account cuentaSec = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuenta.Id,'X1114567X');
        cuentaSec.Type = '01';
		insert cuentaSec;
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        system.debug('<<<<<<<<<<<<<<<<procedencia>>>>>>>' + procedencia.Id);
        
        Buzon_CIA__c buzon = new Buzon_CIA__c();
        buzon.BUZ_LKP_Cuenta__c = compania.Id;
        buzon.BUZ_SEL_Tipo_Programa__c = '02;03';
        buzon.BUZ_EMA_Direccion__c = 'ser@ser.com';
        buzon.Name = 'buzon';
        insert buzon;
        
        Task tarea = new Task();
        
        //system.runAs(newUser){
            
            caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, cuentaSec.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.CreatedDate = system.now();
            caso.Status = '993';
            insert caso;
            
            caso.Status = '001';
            update caso;
            
            tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '01', 120.0);
            insert tipoTrabajo;
            
            wo = Util_Tests.crearOrdenTrabajo('0000000545','01',tipoTrabajo.Id,caso.Id);
            wo.OTR_DAT_Fecha_Primera_Cita__c = system.today();
            wo.OTR_SEL_Rango_Primera_Cita__c = '07';
            insert wo;
            
            tarea.CallDisposition = '{root=100}';
            tarea.CallDurationInSeconds = 248;
            tarea.CallObject = '12709';
            tarea.CallType = 'Inbound';
            tarea.TAR_DAT_Inicio_Llamada__c = System.now().addDays(-1);
            tarea.TAR_DAT_Fin_Llamada__c = System.now().addDays(1);
            
            insert tarea;
        
        Test.stopTest();
        //}
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
    	ApexPages.currentPage().getParameters().put('solicitudExistente','N');
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.currentPage().getParameters().put('idOrdenTrabajo',wo.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        reservarCita = new ReservarCita(stdc);
        reservarCita.volver();
        wo.OTR_DAT_Fecha_Primera_Cita__c = system.today().addDays(5);
        wo.OTR_SEL_Rango_Primera_Cita__c = '07';
        reservarCita.otInputManual = wo;
        ServiceAppointment sa = [SELECT ServiceTerritoryId FROM ServiceAppointment WHERE ParentRecordId = : wo.Id];
        festivo = Util_Tests.crearFestivo('Local', sa.ServiceTerritoryId, Date.today());
        insert festivo;
        FSL__Scheduling_Policy__c politica = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
        insert politica;
        reservarCita.continuar();
        reservarCita.automatico = true;
        reservarCita.verificarCitaReservada();
        Boolean bol1 = reservarCita.aplazamientoAplicado();
        bol1 = reservarCita.necesarioProgramarHoy();
        reservarCita.programarHoy();
        reservarCita.asignarComoUrgencia();
    }
    
    @isTest static void testReservarCita(){
        baipas.establecerVariableControl();
        Test.startTest();
    	compania = Util_Tests.crearCuentaCompania('compania2', '1018','X1114567X');
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta2', '1458','X1111567X');
		insert cuenta;
        
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        system.debug('<<<<<<<<<<<<<<<<procedencia>>>>>>>' + procedencia.Id);
        
        Buzon_CIA__c buzon = new Buzon_CIA__c();
        buzon.BUZ_LKP_Cuenta__c = compania.Id;
        buzon.BUZ_SEL_Tipo_Programa__c = '02;03';
        buzon.BUZ_EMA_Direccion__c = 'ser@ser.com';
        buzon.Name = 'buzon';
        insert buzon;
        
        User newUser = new User();
		newUser.FirstName = 'Manolo';
		newUser.LastName = 'tena';
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
        
        Task tarea = new Task();
        
        //system.runAs(newUser){
            
            caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.OwnerId = newUser.Id;
            caso.CreatedDate = system.now();
            caso.Status = '993';
            insert caso;
            
            caso.Status = '001';
            update caso;
            
            tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '01', 120.0);
            insert tipoTrabajo;
        
            wo = Util_Tests.crearOrdenTrabajo('0000000545','01',tipoTrabajo.Id,caso.Id);
            wo.OTR_DAT_Fecha_Primera_Cita__c = system.today();
            wo.OTR_SEL_Rango_Primera_Cita__c = '07';
            insert wo;
        	
        	integer year = System.now().year();
        	integer month = System.now().month();
        	integer day = System.now().day();
        
        	DateTime addDias = Datetime.newInstance(year, month, day, 12, 0, 0);
            
            tarea.CallDisposition = '{root=100}';
            tarea.CallDurationInSeconds = 248;
            tarea.CallObject = '12709';
            tarea.CallType = 'Inbound';
            tarea.TAR_DAT_Inicio_Llamada__c = addDias.addDays(-1);
            tarea.TAR_DAT_Fin_Llamada__c = addDias.addDays(1);
            tarea.OwnerId = newUser.Id;
            
            insert tarea;
        
        //}
        
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
    	ApexPages.currentPage().getParameters().put('solicitudExistente','N');
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.currentPage().getParameters().put('idOrdenTrabajo',wo.Id);
        ApexPages.currentPage().getParameters().put('buscarCita','N');
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        reservarCita = new ReservarCita(stdc);
        reservarCita.asignacionMizad();
        reservarCita.verificarCitaReservada();
        reservarCita.asignarUrgYProg();
        reservarCita.continuar();
        reservarCita.autoasignarCitas();
        reservarCita.manualAutomatico();
        reservarCita.asignarFranquiciado();
        reservarCita.asignarTerritorioPrimNoFranq();
        //repetimos para catch
        reservarCita.asignacionMizad();
        reservarCita.verificarCitaReservada();
        reservarCita.asignarUrgYProg();
        reservarCita.continuar();
        reservarCita.autoasignarCitas();
        reservarCita.manualAutomatico();
        reservarCita.asignarFranquiciado();
        reservarCita.asignarTerritorioPrimNoFranq();
        Test.stopTest();
    }
    
    @isTest static void testReservarCita2(){
        baipas.establecerVariableControl();
        Test.startTest();
    	compania = Util_Tests.crearCuentaCompania('compania2', '1018','X1114567X');
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta2', '1458','X1111567X');
		cuenta.CUE_TXT_Segmentacion_num__c ='1018';
		insert cuenta;
		
		Account cuenta2 = Util_Tests.crearCuentaB2BSec('b2b2','04',cuenta.Id,'X7654321X');
		cuenta2.CUE_TXT_Segmentacion_num__c ='04';
		insert cuenta2;
        
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        /*
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        system.debug('<<<<<<<<<<<<<<<<procedencia>>>>>>>' + procedencia.Id);
        
        Buzon_CIA__c buzon = new Buzon_CIA__c();
        buzon.BUZ_LKP_Cuenta__c = compania.Id;
        buzon.BUZ_SEL_Tipo_Programa__c = '02;03';
        buzon.BUZ_EMA_Direccion__c = 'ser@ser.com';
        buzon.Name = 'buzon';
        insert buzon;
        
        User newUser = new User();
		newUser.FirstName = 'Manolo';
		newUser.LastName = 'tena';
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
        
        Task tarea = new Task();*/
        
        //system.runAs(newUser){
            
            caso = Util_Tests.crearCasoB2B(sv.Id, cuenta2.Id, compania.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            //caso.CAS_LKP_Procedencia__c = procedencia.Id;
            //caso.OwnerId = newUser.Id;
            caso.CreatedDate = system.now();
            caso.Status = '993';
            insert caso;
            
            caso.Status = '001';
            update caso;
            
            tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '01', 120.0);
            insert tipoTrabajo;
        	
        	OperatingHours horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
        	insert horaFuncionamiento;
        	ServiceTerritory st = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
        	st.isActive = true;
        	insert st;
            wo = Util_Tests.crearOrdenTrabajo('0000000545','01',tipoTrabajo.Id,caso.Id);
            wo.OTR_CAS_Urgente__c = true;
            wo.OTR_DAT_Fecha_Primera_Cita__c = system.today();
            wo.OTR_SEL_Rango_Primera_Cita__c = '07';
            wo.ServiceTerritoryId = st.Id;
            wo.AccountId = cuenta2.Id;
            insert wo;/*
        	
        	integer year = System.now().year();
        	integer month = System.now().month();
        	integer day = System.now().day();
        
        	DateTime addDias = Datetime.newInstance(year, month, day, 12, 0, 0);
            
            tarea.CallDisposition = '{root=100}';
            tarea.CallDurationInSeconds = 248;
            tarea.CallObject = '12709';
            tarea.CallType = 'Inbound';
            tarea.TAR_DAT_Inicio_Llamada__c = addDias.addDays(-1);
            tarea.TAR_DAT_Fin_Llamada__c = addDias.addDays(1);
            tarea.OwnerId = newUser.Id;
            
            insert tarea;*/
        
        //}
        
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
    	ApexPages.currentPage().getParameters().put('solicitudExistente','N');
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.currentPage().getParameters().put('idOrdenTrabajo',wo.Id);
        ApexPages.currentPage().getParameters().put('buscarCita','N');
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        reservarCita = new ReservarCita(stdc);
        reservarCita.asignacionMizad();
        reservarCita.verificarCitaReservada();
        reservarCita.asignarUrgYProg();
        reservarCita.continuar();
        reservarCita.autoasignarCitas();
        reservarCita.manualAutomatico();
        reservarCita.asignarFranquiciado();
        reservarCita.asignarTerritorioPrimNoFranq();
        Test.stopTest();
    }
    
}