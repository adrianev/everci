/**
 * Clase de Test de la Clase controladora AnulacionReclamaciones
 * 
 */
@isTest
public without sharing class Test_AnulacionReclamaciones extends TestSetup {

	private static Account compania1 {get; set;}
	private static Account compania2 {get; set;}
	private static Account cuenta1 {get; set;}
	private static Account cuenta2 {get; set;}
	private static Account profesionalContratoAux {get;set;}
	private static Account profesionalContratoAux2 {get;set;}
	private static Tipo_Producto_CIA__c tipoProCia1 {get; set;}
	private static Producto_CIA__c proCia1 {get; set;}
	private static ServiceContract poliza1 {get; set;}
	private static ServiceContract poliza2 {get; set;}
	private static Case caso1 {get; set;}
	private static Case caso2 {get; set;}
	private static Case caso3 {get; set;}
	private static Case caso4 {get; set;}
	private static WorkType tipoTRabajo1 {get; set;}
	private static WorkOrder ot1 {get; set;}
	private static WorkOrder ot2 {get; set;}
	private static WorkOrder ot3 {get; set;}

	/**
	 * Método privado para inicializar los objetos que se necesiten en el test.
	 */
	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		compania1 = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania1;
		compania2 = Util_Tests.crearCuentaCompania('CuentaVDN','1019','Z1585459M');
		insert compania2;
		profesionalContratoAux = Util_Tests.crearCuentaCompania('profesionalEmpresa1','1111','Z1855459M');
		insert profesionalContratoAux;
		profesionalContratoAux2 = Util_Tests.crearCuentaCompania('profesionalEmpresa2','2222','Z1855549M');
		insert profesionalContratoAux2;
		cuenta1 = Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',profesionalContratoAux.Id);
		cuenta1.CUE_SEL_Tipo_de_Profesional__c='01';
		insert cuenta1;
		cuenta2 = Util_Tests.crearCuentaProfesionalContrato('PR123460','1021','Z1585459M',profesionalContratoAux2.Id);
		cuenta2.CUE_SEL_Tipo_de_Profesional__c='02';
		insert cuenta2;
		tipoProCia1 = Util_Tests.crearTipoProductoCIA('HOGAR','01',compania1.Id);
		insert tipoProCia1;
		proCia1 = Util_Tests.crearProductoCIA('ProductoHogar','1234',tipoProCia1.Id);
		insert proCia1;
		poliza1 = Util_Tests.crearPolizaContrato('2277393',compania1.Id,cuenta1.Id,proCia1.Id);
		insert poliza1;
		poliza2 = Util_Tests.crearPolizaContrato('2277388',compania2.Id,cuenta2.Id,proCia1.Id);
		insert poliza2;
		caso1 = Util_Tests.crearCasoB2B(poliza1.Id,cuenta1.Id,compania1.Id);
		caso1.CAS_SEL_Motivo_anulacion_reclamacion__c = 'Abierta por error hay otra reclamación en curso por este motivo';
		insert caso1;
		caso2 = Util_Tests.crearCasoB2B(poliza2.Id,cuenta2.Id,compania2.Id);
		caso2.CAS_SEL_Motivo_anulacion_reclamacion__c = 'Abierta por error no es una solicitud del asegurado';
		insert caso2;
		caso3 = Util_Tests.crearCasoB2B(poliza2.Id,cuenta1.Id,compania2.Id);
		caso3.CAS_SEL_Motivo_anulacion_reclamacion__c = 'Abierta por error del gestor se debe gestionar por el siniestro';
		tipoTrabajo1 = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21',2.00);
		insert caso3;
		caso4 = Util_Tests.crearCasoB2B(poliza1.Id,cuenta2.Id,compania1.Id);
		tipoTrabajo1 = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21',2.00);
		insert tipoTrabajo1;
		ot1 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo1.Id,caso1.Id);
		ot1.Status = Label.OTR_ESTADO_ANULADO;
		insert ot1;
		ot2 = Util_Tests.crearOrdenTrabajo('18215.0','21',tipoTrabajo1.Id,caso2.Id);
		ot2.Status = Label.OTR_ESTADO_PDTE_CLIENTE_ENFERMEDAD;
		insert ot2;
		ot3 = Util_Tests.crearOrdenTrabajo('18220.0','21',tipoTrabajo1.Id,caso3.Id);
		insert ot3;
		Baipas.deshabilitarVariableControl();
	}

	@isTest static void testFlujo1(){
		inicializarVariables();
		Test.setCurrentPage(Page.AnulacionReclamaciones);
		ApexPages.currentPage().getParameters().put('id',caso1.Id);
		ApexPages.StandardController controlador = new ApexPages.StandardController(caso1);
		Test.startTest();
		AnulacionReclamaciones anulacionRec = new AnulacionReclamaciones(controlador);
		List<SelectOption> opciones = anulacionRec.getOpcionesAnulacion();
		PageReference pagina1 = anulacionRec.guardar();
		Test.stopTest();
	}
	
	@isTest static void testFlujo2(){
		inicializarVariables();
		Test.setCurrentPage(Page.AnulacionReclamaciones);
		ApexPages.currentPage().getParameters().put('id',caso2.Id);
		ApexPages.StandardController controlador = new ApexPages.StandardController(caso2);
		Test.startTest();
		AnulacionReclamaciones anulacionRec = new AnulacionReclamaciones(controlador);
		List<SelectOption> opciones = anulacionRec.getOpcionesAnulacion();
		PageReference pagina1 = anulacionRec.guardar();
		Test.stopTest();
	}

	@isTest static void testFlujo3(){
		inicializarVariables();
		Test.setCurrentPage(Page.AnulacionReclamaciones);
		ApexPages.StandardController controlador = new ApexPages.StandardController(caso1);
		Test.startTest();
		AnulacionReclamaciones anulacionRec = new AnulacionReclamaciones(controlador);
		Test.stopTest();
	}

	@isTest static void testFlujo4(){
		inicializarVariables();
		Test.setCurrentPage(Page.AnulacionReclamaciones);
		ApexPages.currentPage().getParameters().put('id',caso3.Id);
		ApexPages.StandardController controlador = new ApexPages.StandardController(caso3);
		Test.startTest();
		AnulacionReclamaciones anulacionRec = new AnulacionReclamaciones(controlador);
		List<SelectOption> opciones = anulacionRec.getOpcionesAnulacion();
		PageReference pagina1 = anulacionRec.guardar();
		Test.stopTest();
	}

	@isTest static void testFlujo5(){
		inicializarVariables();
		Test.setCurrentPage(Page.AnulacionReclamaciones);
		ApexPages.currentPage().getParameters().put('id',caso4.Id);
		ApexPages.StandardController controlador = new ApexPages.StandardController(caso4);
		Test.startTest();
		AnulacionReclamaciones anulacionRec = new AnulacionReclamaciones(controlador);
		Test.stopTest();
	}
}