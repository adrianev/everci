@isTest
public without sharing class Test_Sini_RetornoSondeoExterno /*extends TestSetup*/ {
    
    private static ServiceContract NuevaPoliza{get; set;}
    private static Case Nuevocaso {get; set;}
    public static SiniIndemnDocumentosController siniDocumentos  {get; set;}
    private static Account compania {get; set;}
    private static Account cuenta {get; set;}
    private static Account cuentaPrincipal {get; set;}
    private static Tipo_Producto_CIA__c  tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
    
    public static SiniRetornoSondeoExternoController siniRetornoSondeoExt  {get; set;}  
    /*
    @testSetup
    public static void test(){
        TestSetup loadData = new Test_Sini_RetornoSondeoExterno();
        loadData.setTestData();
    }
    */
    
        
    public static void InicializarVariables(){
        
       	compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		NuevaPoliza = Util_Tests.crearPolizaContrato('4523814',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
        insert NuevaPoliza;
        Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
		insert Nuevocaso;	  
        
    }
    
    
    @isTest static void testSiniRetornoSondeoExt1(){
        InicializarVariables();
        NuevaPoliza.Name ='2423394';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_RetornoSondeoExterno;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2423394');
        Case caso = Util_Tests.getCaseById(poliza.Id);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniRetornoSondeoExt = new SiniRetornoSondeoExternoController(stdc);	
        //siniRetornoSondeoExt.asignarPerito();
    }
    
    @isTest static void testSiniRetornoSondeoExt2(){
        InicializarVariables();
        NuevaPoliza.Name ='2255384';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_RetornoSondeoExterno;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2255384');
        Case caso = Util_Tests.getCaseById(poliza.Id);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniRetornoSondeoExt = new SiniRetornoSondeoExternoController(stdc);	
    }
    
    @isTest static void testSiniRetornoSondeoExt3(){
        InicializarVariables();
        NuevaPoliza.Name ='2277384';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_RetornoSondeoExterno;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2277384');
        Case caso = Util_Tests.getCaseById(poliza.Id);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniRetornoSondeoExt = new SiniRetornoSondeoExternoController(stdc);
        //siniRetornoSondeoExt.asignarPerito();
    }
    
    @isTest static void testError(){
        InicializarVariables();
        NuevaPoliza.Name ='2423394';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_RetornoSondeoExterno;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2423394');
        Case caso = Util_Tests.getCaseById(poliza.Id);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniRetornoSondeoExt = new SiniRetornoSondeoExternoController(stdc);	
        //siniRetornoSondeoExt.asignarPerito();
    }
    
    private static ServiceContract getServiceContractByName(String name){
        ServiceContract poliza;
        
        List<ServiceContract> listaPolizas = new List<ServiceContract>([Select Id,
                                  POL_LKP_Compania__r.Name,
                                  POL_LKP_Compania__r.CUE_EMA_Email__c,
                                  AccountId,
                                  Account.Name,
                                  POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Autorizados__c
                                  FROM ServiceContract Where Name = :name LIMIT 1]);
                                  
      	if(!listaPolizas.isEmpty()){
            poliza = listaPolizas.get(0);
        }else{
            throw new TestException('No existen polizas/contratos con el nombre especificado');
        }
      	
        return poliza;
    }
    //Id,CAS_LKP_PolizaContrato__c,AccountId,CAS_LKP_Compania__c,Origin,CAS_TXT_Persona_que_llama__c
    //,RecordTypeId,status,CAS_SEL_Motivo_No_Apertura__c,CAS_SEL_Tipo_Interlocutor__c
    
}