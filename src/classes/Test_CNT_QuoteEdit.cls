@isTest
public without sharing class Test_CNT_QuoteEdit {
    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType tipoTrabajo;
    private static Account asegurado;
    private static WorkType wt;
    private static BigMachines__Quote__c BMQ;
    
    private static void inicializarVariables(){
                system.debug('empieza');
        Test.startTest();
        Baipas.establecerVariableControl(); 
        PageReference pageRef = Page.AltaModificacionCliente;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('fase','Y');
        ApexPages.currentPage().getParameters().put('solicitudExistente','Y');
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
        ApexPages.currentPage().getParameters().put('retorno','Y');
        
        compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        insert compania;
        
        cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        insert cuenta;
        
        tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
        insert tipoProducto;
        
        producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
        insert producto;
        
        sv = Util_tests.crearPolizaContrato('10', compania.id, cuenta.id, producto.id);
        insert sv;
        
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        //procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = 'Avería de un tercero';
        insert procedencia;
        
        system.debug('<<<<<<<<<<<<<<<<procedencia>>>>>>>' + procedencia.Id);
        
        Buzon_CIA__c buzon = new Buzon_CIA__c();
        buzon.BUZ_LKP_Cuenta__c = compania.Id;
        buzon.BUZ_SEL_Tipo_Programa__c = '02;03';
        buzon.BUZ_EMA_Direccion__c = 'ser@ser.com';
        buzon.Name = 'buzon';
        insert buzon;
        
        caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        caso.CAS_SEL_Encuestador__c = 'Servitelco';
        caso.CAS_LKP_Compania__c = compania.Id;
        caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        insert caso;
        
        wt = Util_Tests.crearTipoTrabajo('Rotura de bajante/tubería empotrada', '01', 120.0);
        insert wt;
        
        wo = Util_Tests.crearOrdenTrabajo('0000000545','01',wt.Id,caso.Id);
        insert wo;
        
        //Case caso = Util_Tests.getCaseById(poliza.Id);
        system.debug('<<<<<<<<<<<<<caso.CAS_SEL_Encuestador__c >>>>>>>>>' + caso.CAS_SEL_Encuestador__c);
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        ApexPages.currentPage().getParameters().put('nuevoPresupuesto','Y');
        //Account asegurado = Util_Tests.getAccountByName('Asegurado');
        ApexPages.currentPage().getParameters().put('idWorkO',wo.Id);
    }

    @isTest static void test_B2B_Presupuesto(){

        inicializarVariables();

        ApexPages.currentPage().getParameters().put('enRevision','Y');
        ApexPages.currentPage().getParameters().put('idWorkO', wo.Id);

        BigMachines__Configuration_Record__c bcr=new BigMachines__Configuration_Record__c();

        bcr.BigMachines__action_id_copy__c = '1';
        bcr.BigMachines__action_id_open__c='1';
        bcr.BigMachines__bm_site__c='homeservetest';
        bcr.BigMachines__document_id__c='1';
        bcr.BigMachines__process__c='1';
        bcr.BigMachines__process_id__c='1';
        bcr.BigMachines__version_id__c='36494562';
        bcr.BigMachines__Is_Active__c = true;
        bcr.BigMachines__Is_Primary__c = false;       

        insert bcr;
        
        BigMachines__Quote__c BMQ = new BigMachines__Quote__c();
        BMQ.OQU_LKP_Work_Order__c = wo.Id;
        BMQ.BigMachines__Site__c = bcr.Id;
        insert BMQ;

                        
		
        system.debug('QUEEEEEEEEEEEEERY'+[SELECT Id FROM BigMachines__Quote__c]);

        CNT_QuoteEdit cqe = new CNT_QuoteEdit();
		
        PageReference prNew = cqe.volver();
        Integer x = CNT_QuoteEdit.getSumQuotes(wo.Id);
        
        cqe.volverDialogo();

		Test.stopTest();

	}
    
     @isTest static void test_B2B_Presupuesto2(){

        inicializarVariables();

        ApexPages.currentPage().getParameters().put('enRevision','Y');
        ApexPages.currentPage().getParameters().put('idWorkO', wo.Id);

        BigMachines__Configuration_Record__c bcr=new BigMachines__Configuration_Record__c();

        bcr.BigMachines__action_id_copy__c = '1';
        bcr.BigMachines__action_id_open__c='1';
        bcr.BigMachines__bm_site__c='homeservetest';
        bcr.BigMachines__document_id__c='1';
        bcr.BigMachines__process__c='1';
        bcr.BigMachines__process_id__c='1';
        bcr.BigMachines__version_id__c='36494562';
        bcr.BigMachines__Is_Active__c = true;
        bcr.BigMachines__Is_Primary__c = true;       

        insert bcr;
         
        
        BigMachines__Quote__c BMQ = new BigMachines__Quote__c();
        BMQ.OQU_LKP_Work_Order__c = wo.Id;
        BMQ.BigMachines__Site__c = bcr.Id;
        insert BMQ;
         
        BMQ.BigMachines__Is_Primary__c = true;
         update BMQ;

                        
		
        system.debug('QUEEEEEEEEEEEEERY'+[SELECT Id FROM BigMachines__Quote__c]);
         
        wo.OTR_CAS_Confianza_en_la_red__c = true;
         update wo;

        CNT_QuoteEdit cqe = new CNT_QuoteEdit();
		
        PageReference prNew = cqe.volver();
        Integer x = CNT_QuoteEdit.getSumQuotes(wo.Id);
        
        cqe.volverDialogo();


	}
         @isTest static void test_checkCambioPartidas(){

        inicializarVariables();

        ApexPages.currentPage().getParameters().put('enRevision','Y');
        ApexPages.currentPage().getParameters().put('idWorkO', wo.Id);

        BigMachines__Configuration_Record__c bcr=new BigMachines__Configuration_Record__c();

        bcr.BigMachines__action_id_copy__c = '1';
        bcr.BigMachines__action_id_open__c='1';
        bcr.BigMachines__bm_site__c='homeservetest';
        bcr.BigMachines__document_id__c='1';
        bcr.BigMachines__process__c='1';
        bcr.BigMachines__process_id__c='1';
        bcr.BigMachines__version_id__c='36494562';
        bcr.BigMachines__Is_Active__c = true;
        bcr.BigMachines__Is_Primary__c = true;       

        insert bcr;
         
        
        BigMachines__Quote__c BMQ = new BigMachines__Quote__c();
        BMQ.OQU_LKP_Work_Order__c = wo.Id;
        BMQ.BigMachines__Site__c = bcr.Id;
        insert BMQ;
         
        BMQ.BigMachines__Is_Primary__c = true;
         update BMQ;

                        
		
        system.debug('QUEEEEEEEEEEEEERY'+[SELECT Id FROM BigMachines__Quote__c]);
         
        wo.OTR_CAS_Confianza_en_la_red__c = true;
         update wo;

        CNT_QuoteEdit cqe = new CNT_QuoteEdit();
        cqe.caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        cqe.caso.Status = Label.RT_CAS_SINIESTRO;
		
        PageReference prNew = cqe.volver();
        Integer x = CNT_QuoteEdit.getSumQuotes(wo.Id);
        
        cqe.volverDialogo();
        cqe.checkCambioPartidas();
    
   
	}
    
    
}