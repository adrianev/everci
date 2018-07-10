@isTest
public without sharing class Test_TRG_Handler_Tarea {

    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType tipoTrabajo;
    
    static testMethod void Handler_Tarea(){
        Datetime posibleFechaReserva = Datetime.now().addDays(Util_Cita_Servicio.sumarDias(Datetime.now()));
        compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.Type='01';
        insert compania;
        
        cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        cuenta.cue_lkp_cuenta_principal__c = compania.id;
        cuenta.Cue_LKP_Cliente_contable__c = compania.id;
        cuenta.Type='01';
        insert cuenta;
        
        tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
        insert tipoProducto;
        
        producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
        insert producto;
        
        sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        
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
        newUser.USR_TXT_Identificador__c = '0000';

        insert newUser;
        
        Task tarea = new Task();
        
        system.runAs(newUser){
            
            caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.OwnerId = newUser.Id;
            caso.Status = '993';
            insert caso;
            
            caso.Status = '001';
            update caso;
            
            tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '01', 120.0);
            insert tipoTrabajo;
            
            wo = Util_Tests.crearOrdenTrabajo('0000000545','01',tipoTrabajo.Id,caso.Id);
            wo.OTR_DAT_Fecha_Primera_Cita__c = posibleFechaReserva.date();
            wo.OTR_SEL_Rango_Primera_Cita__c = '07';
            insert wo;
            
            tarea.CallDisposition = '{root=100}';
            tarea.CallDurationInSeconds = 248;
            tarea.CallObject = '12709';
            tarea.CallType = 'Inbound';
            tarea.TAR_DAT_Inicio_Llamada__c = posibleFechaReserva.addDays(-1);
            tarea.TAR_DAT_Fin_Llamada__c = posibleFechaReserva.addDays(1);
            tarea.OwnerId = newUser.Id;
            tarea.Subject = 'RE:' + Label.TAR_ASUNTO_RECORDATORIO_ID;
            tarea.Description = Label.EMAIL_TO_SALESFORCE;
            tarea.WhatId = caso.Id;
            
        Test.startTest();
            insert tarea;
            
            Task tarea1 = new Task();
            
            tarea1.CallDisposition = '{root=100}';
            tarea1.CallDurationInSeconds = 248;
            tarea1.CallObject = '12709';
            tarea1.CallType = 'Inbound';
            tarea1.TAR_DAT_Inicio_Llamada__c = posibleFechaReserva.addDays(-1);
            tarea1.TAR_DAT_Fin_Llamada__c = posibleFechaReserva.addDays(1);
            tarea1.OwnerId = newUser.Id;
            tarea1.Subject = Label.TAR_ASUNTO_RECORDATORIO_MINUTA;
            tarea1.Description = Label.EMAIL_TO_SALESFORCE;
            tarea1.WhatId = caso.Id;
            
            insert tarea1;
            tarea1.Subject = Label.TAR_ASUNTO_RECORDATORIO_MINUTA;
            update tarea1;
            
            Test.stopTest();
        }
    }
}