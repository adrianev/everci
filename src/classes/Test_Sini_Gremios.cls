@isTest
public without sharing class Test_Sini_Gremios extends TestSetup {
    
    public static SiniGremiosController siniGremios  {get; set;}  
    /*
    @testSetup
    public static void test(){
        TestSetup loadData = new Test_Sini_Gremios();
        loadData.setTestData();
    }
*/
    
    @isTest static void testSiniGremiosSalir(){
    	Baipas.establecerVariableControl();
    	PageReference pageRef = Page.Sini_Gremios;
    	Test.setCurrentPage(pageRef);
        Account compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		insert cuentaPrincipal;
		Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		Tipo_Producto_CIA__c  tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		tipoProductoCIA.TPR_NUM_Limite_Servicios_Manitas__c = 0;
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract NuevaPoliza = Util_Tests.crearPolizaContrato('2277393',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
        insert NuevaPoliza;
        Case Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
        Nuevocaso.CAS_SEL_Sondeo_Gremios__c = '21';
        Nuevocaso.CAS_NUM_Id_Actuacion_SondeoExt__c = 2;
        Nuevocaso.Type = '13';
		insert Nuevocaso;
    	ServiceContract poliza = getServiceContractByName(NuevaPoliza.Name);
        Case caso = getCaseById(poliza.Id);
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        //caso.CAS_LKP_Procedencia__c = 'a1d9E000000xV06';
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniGremios = new SiniGremiosController(stdc);
        siniGremios.gremio = 'AIRE ACONDICIONADO_21';
        siniGremios.buscarTiposTrabajo();
        siniGremios.salir_paso1();
        PageReference pageRef2 = siniGremios.salir_paso2();
    	Test.setCurrentPage(pageRef2);
    	Baipas.deshabilitarVariableControl();
    }
    
    
    @isTest static void testSiniGremiosApertura1(){
    	Baipas.establecerVariableControl();
    	PageReference pageRef = Page.Sini_Gremios;
    	Test.setCurrentPage(pageRef);
        Account compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		insert cuentaPrincipal;
		Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		Tipo_Producto_CIA__c  tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		tipoProductoCIA.TPR_NUM_Limite_Servicios_Manitas__c = 0;
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract NuevaPoliza = Util_Tests.crearPolizaContrato('2277393',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
        insert NuevaPoliza;
        Case Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
        Nuevocaso.CAS_SEL_Sondeo_Gremios__c = '21';
        Nuevocaso.CAS_NUM_Id_Actuacion_SondeoExt__c = 2;
        Nuevocaso.Type = '13';
		insert Nuevocaso;
    	ServiceContract poliza = getServiceContractByName(NuevaPoliza.Name);
        Case caso = getCaseById(poliza.Id);
        WorkType NuevotipoTrabajo = Util_Tests.crearTipoTrabajo('Reparacion aire acondicionado','21', 2);
		insert NuevotipoTrabajo;
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        //caso.CAS_LKP_Procedencia__c = 'a1d9E000000xV06';
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniGremios = new SiniGremiosController(stdc);
        siniGremios.gremio = 'AIRE ACONDICIONADO_21';
        siniGremios.buscarTiposTrabajo();
        WorkType tipoTrabajo= getWorkTypeByName(NuevotipoTrabajo.Name);
       	SiniGremiosController.Resultado resultado = new SiniGremiosController.Resultado(true,tipoTrabajo);
        siniGremios.listaResultados.add(resultado);
        siniGremios.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de prueba para orden de trabajo';
        PageReference pageRef2 = siniGremios.guardar();
    	Test.setCurrentPage(pageRef2);
    	Baipas.deshabilitarVariableControl();
    }
    
    @isTest static void testSiniGremiosApertura2(){
    	Baipas.establecerVariableControl();
    	PageReference pageRef = Page.Sini_Gremios;
    	Test.setCurrentPage(pageRef);
        Account compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		insert cuentaPrincipal;
		Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		Tipo_Producto_CIA__c  tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract NuevaPoliza = Util_Tests.crearPolizaContrato('2277393',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
        insert NuevaPoliza;
        Case Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
        Nuevocaso.CAS_SEL_Sondeo_Gremios__c = '21';
        Nuevocaso.CAS_NUM_Id_Actuacion_SondeoExt__c = 2;
		insert Nuevocaso;
    	ServiceContract poliza = getServiceContractByName(NuevaPoliza.Name);
        Case caso = getCaseById(NuevaPoliza.Id);
        WorkType NuevotipoTrabajo = Util_Tests.crearTipoTrabajo('Reparacion aire acondicionado','21', 2);
		insert NuevotipoTrabajo;
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_CONFIRMACION);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('gravesGremioUrg','true');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        //caso.CAS_LKP_Procedencia__c = 'a1d9E000000xV06';
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniGremios = new SiniGremiosController(stdc);
        siniGremios.gremio = 'AIRE ACONDICIONADO_21';
        siniGremios.buscarTiposTrabajo();
        WorkType tipoTrabajo= getWorkTypeByName(NuevotipoTrabajo.Name);
       	SiniGremiosController.Resultado resultado = new SiniGremiosController.Resultado(true,tipoTrabajo);
       	siniGremios.listaResultados = new List<SiniGremiosController.Resultado>();
        siniGremios.listaResultados.add(resultado);
        siniGremios.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de prueba para orden de trabajo';
        PageReference pageRef2 = siniGremios.guardar();
    	Test.setCurrentPage(pageRef2);
    	Baipas.deshabilitarVariableControl();
    }
    
    @isTest
    public static void reabrirIntervencionTest(){
    	Baipas.establecerVariableControl();
    	PageReference pageRef = Page.Sini_Gremios;
    	Test.setCurrentPage(pageRef);
        Account compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		cuentaPrincipal.CUE_SEL_Motivo_Reapertura__c = 'Pendiente';
		insert cuentaPrincipal;
		Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		Tipo_Producto_CIA__c  tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract NuevaPoliza = Util_Tests.crearPolizaContrato('2277393',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
        insert NuevaPoliza;
        Case Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
        Nuevocaso.CAS_SEL_Sondeo_Gremios__c = '21';
        Nuevocaso.CAS_CAS_Siniestro_Facturado__c = true;
        Nuevocaso.CAS_NUM_Id_Actuacion_SondeoExt__c = 2;
		insert Nuevocaso;
    	ServiceContract poliza = getServiceContractByName(NuevaPoliza.Name);
        Case caso = getCaseById(poliza.Id);
        WorkType NuevotipoTrabajo = Util_Tests.crearTipoTrabajo('Reparacion aire acondicionado','21', 2);
		insert NuevotipoTrabajo;
    	ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        //caso.CAS_LKP_Procedencia__c = 'a1d9E000000xV06';
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        siniGremios = new SiniGremiosController(stdc);
        siniGremios.gremio = 'AIRE ACONDICIONADO_21';
        siniGremios.buscarTiposTrabajo();
        WorkType tipoTrabajo= getWorkTypeByName(NuevotipoTrabajo.Name);
       	SiniGremiosController.Resultado resultado = new SiniGremiosController.Resultado(true,tipoTrabajo);
        siniGremios.listaResultados.add(resultado);
        siniGremios.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de prueba para orden de trabajo';
        PageReference pageRef2 = siniGremios.reabrirIntervencion();
        Baipas.deshabilitarVariableControl();
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
                                  CAS_LKP_Procedencia__c
                                  FROM Case Where CAS_LKP_PolizaContrato__c = :id LIMIT 1]);
                                  
      	if(!listaCasos.isEmpty()){
            caso = listaCasos.get(0);
        }else{
            throw new TestException('No existen casos con el nombre especificado');
        }
      	
        return caso;
    }
    
    private static WorkType getWorkTypeByName(String name){
        Worktype tipoTrabajo;
        
        List<WorkType> listaTiposTrabajo = new List<WorkType>([Select Id,			
                                  Name,
                                  EstimatedDuration,
                                  DurationType,
                                  TDT_SEL_Categoria__c,
                                  TDT_SEL_Gremio__c,
                                  ShouldAutoCreateSvcAppt
                                  FROM WorkType Where Name = :name LIMIT 1]);
                                  
      	if(!listaTiposTrabajo.isEmpty()){
            tipoTrabajo = listaTiposTrabajo.get(0);
        }else{
            throw new TestException('No existen tipos de trabajo con el nombre especificado');
        }
      	
        return tipoTrabajo;
    }
}