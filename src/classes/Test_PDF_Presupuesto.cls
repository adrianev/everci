@isTest
public without sharing class Test_PDF_Presupuesto {

    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType tipoTrabajo;
    
    @isTest static void PDF_Presupuesto(){
        Test.startTest();
        compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.Type = '04';
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1019','X1134567X');
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
    	cuenta.Type = '04';
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
            caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '28';
            insert caso;
            
        }
        
        Presupuesto__c pre = new Presupuesto__c();
        pre.PRE_LKP_Caso__c = caso.Id;
        pre.PRE_NUM_Version__c = 1.0;
        
        insert pre;
        
        List<Linea_Presupuesto__c> listaLP = new List<Linea_Presupuesto__c>();
        
        for(Integer i = 0; i<28; i++){
        	Linea_Presupuesto__c lineaPre = new Linea_Presupuesto__c();
      	  	lineaPre.PREL_LKP_Presupuesto__c = pre.Id;
        	lineaPre.PREL_TXT_Descripcion__c = 'lineaPre prueba';
        	lineaPre.PREL_DIV_Facturacion_Total_AI__c = 100.2;
        	listaLP.add(lineaPre);
        }
        insert listaLP;
        
        Test.stopTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caso);
        PDF_Presupuesto presupuesto0 = new PDF_Presupuesto(sc);
        
        PageReference pageRef = Page.PDF_Presupuesto_0000_1;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',caso.Id);
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(caso);
        PDF_Presupuesto presupuesto1 = new PDF_Presupuesto(sc1);
    }
}