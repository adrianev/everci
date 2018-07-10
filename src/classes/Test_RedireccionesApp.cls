@isTest
public without sharing class Test_RedireccionesApp {
    
    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType tipoTrabajo;
    private static RedireccionesApp red;
    private static ApexPages.StandardController sc;
    
    @isTest static void RedireccionesApp(){
        Test.startTest();
        
        compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		cuenta.Type = Label.CUE_TIPO_CONTABLE;
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert cuenta;
        
        Account cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Alejandro','04626393N','coredamnwork@gmail.com',
		'04626393N','Alejandro', 'Rey', 'Lopez');
       	cuentaAsegurado.Type = '01';
        cuentaAsegurado.CUE_LKP_Cliente_contable__c = cuenta.Id;
        cuentaAsegurado.CUE_LKP_Cuenta_principal__c = cuenta.Id;
        insert cuentaAsegurado ;
        
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', cuenta.Id, cuentaAsegurado.Id, producto.Id);
        insert sv;
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        
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
        
        
        system.runAs(newUser){
            
            caso = Util_Tests.crearCasoConClienteContable(sv.Id, cuenta.Id, compania.Id, cuenta.Id);//crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.OwnerId = newUser.Id;
            caso.CreatedDate = system.now();
            caso.Status = '993';
            caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
            insert caso;
            
            
        }
        
        wo=new WorkOrder();
        insert wo;
        
        system.debug('<<<<<<<<<<<<recordType>>>>>>>>>>>' + caso.RecordTypeId);
        Test.stopTest();
        
        PageReference pageRef = Page.RedireccionesApp;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.currentPage().getParameters().put('idOT',wo.Id);
        ApexPages.currentPage().getParameters().put('tipo','APERTURAB2C');
        sc = new ApexPages.StandardController(caso);
        RedireccionesApp red = new RedireccionesApp(sc);
        red.redireccion();
        
        cambiarTipoRedireccion('TRAMITACION');
        
        //cambiarTipoRedireccion('GESTIONGREMIO');
        
        ApexPages.currentPage().getParameters().put('tipo','ANULACIONOT');
        red.redireccion();
        
        
        red.redireccionTramitacion();
        red.casoNuevo();
        //red.redireccionB2BGremios(caso.Id);
        //red.anulacionOT();
    }
    
    private static void cambiarTipoRedireccion(String tipo){
        ApexPages.currentPage().getParameters().put('tipo',tipo);
        sc = new ApexPages.StandardController(caso);
        red = new RedireccionesApp(sc);
        red.redireccion();
    }
    
    /*@isTest static void RedireccionesApp2(){
         
        Test.startTest();
        compania = Util_Tests.crearCuentaCompania('compania', '1018');
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458');
		insert cuenta;
        
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, true,'81629344', '28001',
			'PISO',system.today(), 'Madrid', producto.Id, '2');
        
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        
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
        
        
        system.runAs(newUser){
            
            caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.OwnerId = newUser.Id;
            caso.CreatedDate = system.now();
            caso.Status = '993';
            caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
            insert caso;
            
        }
        system.debug('<<<<<<<<<<<<recordType>>>>>>>>>>>' + caso.RecordTypeId);
        Test.stopTest();
        PageReference pageRef = Page.RedireccionesApp;
		Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(caso);
        ApexPages.currentPage().getParameters().put('tipo','TRAMITACION');
        RedireccionesApp red1 = new RedireccionesApp(sc);
        red1.redireccion();
    }*/

}