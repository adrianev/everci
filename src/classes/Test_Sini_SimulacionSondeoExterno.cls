@isTest
public without sharing class Test_Sini_SimulacionSondeoExterno extends TestSetup {
    
    public static SiniSimulacionSondeoExternoController siniSimulacionSondeoExt  {get; set;} 
    
    private static ServiceContract NuevaPoliza{get; set;}
    private static Case Nuevocaso {get; set;}
    public static SiniIndemnDocumentosController siniDocumentos  {get; set;}
    private static Account compania {get; set;}
    private static Account cuenta {get; set;}
    private static Account cuentaPrincipal {get; set;}
    private static Tipo_Producto_CIA__c  tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
    /*
    @testSetup
    public static void test(){
        TestSetup loadData = new Test_Sini_SimulacionSondeoExterno();
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
    
    @isTest static void testSiniSimulacionSondeoExt(){
        InicializarVariables();
        NuevaPoliza.Name ='2277393';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_SimulacionSondeoExterno;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2277393');
        Case caso = getCaseById(poliza.Id);
        ApexPages.currentPage().getParameters().put('CaseId',caso.Id);
        ApexPages.currentPage().getParameters().put('CompanyExternalId',caso.CAS_LKP_Compania__c);
        ApexPages.currentPage().getParameters().put('CustomerEmail',poliza.POL_LKP_Compania__r.CUE_EMA_Email__c);
        //ApexPages.currentPage().getParameters().put('CustomerZipCode',poliza.POL_TXT_Codigo_Postal__c);
        //ApexPages.currentPage().getParameters().put('DocumentNumber',poliza.POL_FOR_N_de_Documento__c);
        ApexPages.currentPage().getParameters().put('Language','es');
        ApexPages.currentPage().getParameters().put('PolicyCompanyExternalId',poliza.Id);
        ApexPages.currentPage().getParameters().put('TypeRisk',caso.CAS_SEL_Tipo_Averia__c);
        ApexPages.currentPage().getParameters().put('WhoCalls',caso.CAS_SEL_Tipo_Interlocutor__c);
        ApexPages.currentPage().getParameters().put('returnURLOK','/'+caso.Id);
        ApexPages.currentPage().getParameters().put('returnURLKO','/'+caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniSimulacionSondeoExt = new SiniSimulacionSondeoExternoController(stdc);	
        PageReference pageRef2 = siniSimulacionSondeoExt.retornoSondeoOK();
    	Test.setCurrentPage(pageRef2);
    	PageReference pageRef3 = siniSimulacionSondeoExt.retornoSondeoKO();
    	Test.setCurrentPage(pageRef3);
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
    

  private static Case getCaseById(Id id){
        Case caso;
        
        List<Case> listaCasos = new List<Case>([Select Id,			
                                  CAS_LKP_PolizaContrato__c,
                                  AccountId,
                                  CAS_LKP_Compania__c,
                                  Origin,
                                  CAS_TXT_Persona_que_llama__c,
                                  RecordTypeId,
                                  status,
                                  CAS_SEL_Motivo_No_Apertura__c,
                                  CAS_SEL_Tipo_Interlocutor__c,
                                  CAS_LKP_Procedencia__c,
                                  CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
                                  CAS_CAS_Requiere_Perito__c,
                                  Type,
                                  CAS_CAS_Siniestro_Grave__c,
                                  CAS_SEL_Tipo_Averia__c
                                  FROM Case Where CAS_LKP_PolizaContrato__c = :id LIMIT 1]);
                                  
      	if(!listaCasos.isEmpty()){
            caso = listaCasos.get(0);
        }else{
            throw new TestException('No existen casos con el nombre especificado');
        }
      	
        return caso;
    }

}