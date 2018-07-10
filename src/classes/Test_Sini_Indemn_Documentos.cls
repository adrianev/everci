@isTest
public without sharing class Test_Sini_Indemn_Documentos /*extends TestSetup*/ {
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
        TestSetup loadData = new Test_Sini_Indemn_Documentos();
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
    @isTest static void testSiniDocumentosCancelarApertura(){
        InicializarVariables();
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('4523814');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.salir_paso1();
        siniDocumentos.salir_paso2();
    }
    
    @isTest static void testSiniDocumentosApertura(){
        InicializarVariables();
        NuevaPoliza.Name ='2423394';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2423394');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.nuevoComentCaso.CMC_TXT_Comentario__c = 'Comentario de prueba 2';
        siniDocumentos.insertarComentarioCaso();
        siniDocumentos.crearItem();
        siniDocumentos.cancelarCreacionItem();
        siniDocumentos.crearItem();
        siniDocumentos.guardarItem();
        siniDocumentos.indiceListaItems = 0;
        //siniDocumentos.seleccionarItem();
        //siniDocumentos.actualizarItem();
        siniDocumentos.indiceListaItems = 1;
        //siniDocumentos.eliminarItem();
        siniDocumentos.mensajePartidas = true;
        //siniDocumentos.finalizarApertura_paso1();
        siniDocumentos.finalizarApertura_paso2();
    }
    
    @isTest static void testSiniDocumentosAperturaGrave(){
        InicializarVariables();
        NuevaPoliza.Name ='4523814';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('4523814');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.nuevoComentCaso.CMC_TXT_Comentario__c = 'Comentario de prueba 2';
        siniDocumentos.insertarComentarioCaso();
        siniDocumentos.mensajePartidas = true;
        //siniDocumentos.finalizarApertura_paso1();
        siniDocumentos.finalizarApertura_paso2();
    }
    
    @isTest static void testSiniDocumentosConfirmacion(){
        InicializarVariables();
        NuevaPoliza.Name ='2423394';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2423394');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_CONFIRMACION);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.nuevoComentCaso.CMC_TXT_Comentario__c = 'Comentario de prueba 2';
        siniDocumentos.insertarComentarioCaso();
        siniDocumentos.mensajePartidas = true;
        //siniDocumentos.finalizarConfirmacion_paso1();
        siniDocumentos.finalizarConfirmacion_paso2();
    }
    
    @isTest static void testSiniDocumentosConfirmacionGrave(){
        InicializarVariables();
        NuevaPoliza.Name ='4523814';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('4523814');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_CONFIRMACION);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.nuevoComentCaso.CMC_TXT_Comentario__c = 'Comentario de prueba 2';
        siniDocumentos.insertarComentarioCaso();
        siniDocumentos.mensajePartidas = true;
        //siniDocumentos.finalizarConfirmacion_paso1();
        siniDocumentos.finalizarConfirmacion_paso2();
    }
    
    @isTest static void testActualizarPartidas(){
        InicializarVariables();
        NuevaPoliza.Name ='2423394';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2423394');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.actualizarPartidas();
    }
    
    @isTest static void testVincularContactos(){
        InicializarVariables();
        NuevaPoliza.Name ='2423394';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2423394');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.vincularContactos();
    }
    
    @isTest static void testNavegarACaso(){
        InicializarVariables();
        NuevaPoliza.Name ='2423394';
        update NuevaPoliza;
    	PageReference pageRef = Page.Sini_Indemn_Documentos;
    	Test.setCurrentPage(pageRef);
    	ServiceContract poliza = getServiceContractByName('2423394');
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniDocumentos = new SiniIndemnDocumentosController(stdc);	
        siniDocumentos.navegarDetalleCaso(caso);
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
                                  CAS_LKP_PolizaContrato__r.Name
                                  FROM Case Where CAS_LKP_PolizaContrato__c = :id LIMIT 1]);
                                  
      	if(!listaCasos.isEmpty()){
            caso = listaCasos.get(0);
        }else{
            throw new TestException('No existen casos con el nombre especificado');
        }
      	
        return caso;
    }

}