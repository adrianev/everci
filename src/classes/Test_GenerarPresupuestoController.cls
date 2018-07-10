/**
 * Clase de Test de la Clase GenerarPresupuestoController 
 * 
 */
@isTest
public without sharing class Test_GenerarPresupuestoController {  

	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	public static Account compania;
	public static Account cuenta;
	public static Tipo_Producto_CIA__c tipoProducto;
	public static Producto_CIA__c producto;
	public static ServiceContract sv;
	public static Case caso;
	public static Procedencia__c procedencia;
	public static WorkOrder wo;
	public static WorkType wt;
	public static Buzon_CIA__c buzon;
	public static Presupuesto__c pre;
	public static Linea_Presupuesto__c lineaPre;
	public static WorkOrderLineItem woLI;
	
	private static void inicializaVariables(){
		Baipas.establecerVariableControl(); 
		
		compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
		insert compania;
		
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		insert cuenta;
		
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
		
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
		
		sv = Util_Tests.crearPolizaContrato('Alberto', cuenta.Id, compania.Id, producto.Id);
		insert sv;
		procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
		insert procedencia;

		buzon = new Buzon_CIA__c();
		buzon.BUZ_LKP_Cuenta__r = compania;
		buzon.BUZ_LKP_Cuenta__c = compania.Id;
		buzon.BUZ_SEL_Tipo_Programa__c = '02;03;'+Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO;
		buzon.BUZ_EMA_Direccion__c = 'ser@ser.com';
		buzon.Name = 'buzon';
		insert buzon;
		
		caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
		caso.CAS_SEL_Encuestador__c = 'Servitelco';
		caso.CAS_LKP_Compania__r = compania;
		caso.CAS_LKP_Compania__c = compania.Id;
		caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';		
		caso.CAS_LKP_Procedencia__c = procedencia.Id;
		insert caso;
		
		wt = Util_Tests.crearTipoTrabajo('Rotura de bajante/tubería empotrada', '01', 120.0);
		insert wt;
		
		wo = Util_Tests.crearOrdenTrabajo('0000000545','01',wt.Id,caso.Id);
		insert wo;
		
		woLI = Util_Tests.crearNuevaPartidaTrabajo(wo.Id);
		woLI.Status = Label.PAR_ESTADO_ACEPTADA;
		insert woLI;
		pre = new Presupuesto__c();
		pre.PRE_LKP_Caso__c = caso.Id;
		pre.PRE_NUM_Version__c = 1.0;
		
		insert pre;
		
		lineaPre = new Linea_Presupuesto__c();
		lineaPre.PREL_LKP_Presupuesto__c = pre.Id;
		lineaPre.PREL_TXT_Descripcion__c = 'lineaPre prueba';
		lineaPre.PREL_DIV_Facturacion_Total_AI__c = 100.2;
		lineaPre.PREL_DIV_Facturacion_Total_DI__c = 111;
		lineaPre.PREL_POR_Impuesto_Cliente__c = 1;
		
		insert lineaPre;
	}
    
    @isTest static void success1(){
        test_GenerarPresupuestoController();
    }
    
    @isTest static void success2(){
        test_GenerarPresupuestoController1(false);
    }
    
    @isTest static void fail(){
        test_GenerarPresupuestoController1(true);
    }
    
	private static void test_GenerarPresupuestoController(){
		inicializaVariables();
		Test.startTest();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('fase','Y');
		ApexPages.currentPage().getParameters().put('solicitudExistente','Y');
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','Y');
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('nuevoPresupuesto','Y');
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.StandardController sc = new ApexPages.StandardController(caso);
		GenerarPresupuestoController presupuesto = new GenerarPresupuestoController(sc);
		presupuesto.aceptarPresupuesto();
		presupuesto.pensarPresupuesto();
		presupuesto.generarPDF();
		presupuesto.rechazarPresupuesto();
		presupuesto.rechazarPresupuestoParcial();
		presupuesto.motivoSeleccionado();
		presupuesto.volver();
		presupuesto.actualizarPartidas();
	   
		Test.stopTest();
	}
	
	private static void test_GenerarPresupuestoController1(boolean willTestFail){
		Test.startTest();
		inicializaVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('fase','Y');
		ApexPages.currentPage().getParameters().put('solicitudExistente','Y');
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','Y');
		ApexPages.currentPage().getParameters().put('id',caso.Id);
        system.debug('a');
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.StandardController sc = new ApexPages.StandardController(caso);
		GenerarPresupuestoController presupuesto = new GenerarPresupuestoController(sc);
        if(willTestFail)
        //presupuesto.presupuesto.PRE_NUM_Version__c=null;
		presupuesto.guardarPresupuesto();
		presupuesto.aceptarPresupuesto();
		presupuesto.pensarPresupuesto();
		presupuesto.generarPDF();
		presupuesto.rechazarPresupuesto();
		presupuesto.rechazarPresupuestoParcial();
		presupuesto.motivoSeleccionado();
		presupuesto.volver();
		presupuesto.actualizarPartidas();
		Test.stopTest();
	}
}