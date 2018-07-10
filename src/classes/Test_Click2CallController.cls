@isTest
global without sharing class Test_Click2CallController extends TestSetup{
	
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account asegurada {get; set;}
	private static Account cuenta {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	
    private static void inicializarVariables(){
    	compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
    	insert compania;
    	cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
    	insert cuentaPrincipal;
    	asegurada = Util_Tests.crearCuentaB2BSec('Asegurado','1020',cuentaPrincipal.Id,'X1114567X');
    	cuenta = Util_Tests.crearCuentaB2BSec('SegurCaixa1','1021',cuentaPrincipal.Id,'X1111567X');
    	tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
        insert tipoProductoCIA;
        productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;
        poliza = Util_Tests.crearPolizaContrato('2277384',compania.Id,asegurada.Id,productoCIA.Id);
        insert poliza;
        caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        insert caso;
        tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '51', 5.30);
        insert tipoTrabajo;
        ordenTrabajo = Util_Tests.crearOrdenTrabajo('0000000739','01',tipoTrabajo.Id,caso.Id);
        ordenTrabajo.OTR_DAT_Fecha_ultimo_C2C__c = Date.today();
        ordenTrabajo.OTR_NUM_Numero_C2C__c = 2;
        ordenTrabajo.OTR_TEL_Telefono_C2C__c = '654987359';
        insert ordenTrabajo;
    }
    
    @isTest static void test(){
    	Test.startTest();
    	Baipas.establecerVariableControl();
        inicializarVariables();
        ApexPages.currentPage().getParameters().put('id',ordenTrabajo.Id);
        Click2CallController c2c = new Click2CallController();
        c2c.distanciaMenor = true;
        c2c.solicitarLlamada2();
        Baipas.ejecutarTrigger();
        c2c.telefono=null;
		Test.stopTest();
    }
    
    @isTest static void test2(){
        Test.startTest();
        
        Baipas.establecerVariableControl();

        inicializarVariables();
        ApexPages.currentPage().getParameters().put('id',ordenTrabajo.Id);
        Click2CallController c3c = new Click2CallController();
        c3c.distanciaMenor = false;
        
        c3c.solicitarLlamada2();
        Baipas.ejecutarTrigger();

        c3c.telefono=null;

        Test.stopTest();
    }




}