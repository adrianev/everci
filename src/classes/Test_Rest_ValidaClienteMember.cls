/**
 * Clase de Test de la Clase est_ValidaClienteMember
 *
 */

@isTest
public without sharing class Test_Rest_ValidaClienteMember {
	
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get;set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	
	private static Account cuenta1 {get;set;}
	private static Account compania1 {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA1 {get; set;}
	private static Producto_CIA__c productoCIA1 {get; set;}
	private static ServiceContract poliza1 {get; set;}
	private static Case caso1 {get;set;}
	private static WorkType tipoTrabajo1 {get; set;}
	private static WorkOrder ordenTrabajo1 {get; set;}
	
	@isTest static void inicializarVariablesMembership(){
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('Membership','1999', 'X1134569X');
		insert compania;
		cuenta = Util_Tests.crearCuentaAsegurado('ClienteMembership', '132456', 'prueba@prueba.es', '03629033R', 'María', 'García', 'Montes');
		cuenta.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('MEMBERSHIP - Hogar','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('MEMBERSHIP - MEMBERSHIP SINIESTROS','01',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('8899767', compania.Id, cuenta.Id, productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoSini(poliza.Id,cuenta.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		insert ordenTrabajo;
	}
	
	@isTest static void inicializarVariablesSegurCaixa(){
		Baipas.establecerVariableControl();
		
		cuenta1 = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1234567X');
		insert cuenta1;
		compania1 = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234568X');
		insert compania1;
		tipoProductoCIA1 = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania1.ID);
		insert tipoProductoCIA1;
		productoCIA1 = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA1.Id);
		insert productoCIA1;
		poliza1 = Util_Tests.crearPolizaContrato('8899764', compania1.Id, cuenta1.Id,productoCIA1.Id);
		insert poliza1;
		caso1 = Util_Tests.crearCasoSini(poliza1.Id,cuenta1.Id, compania1.Id);
		insert caso1;
		tipoTrabajo1 = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo1;
		ordenTrabajo1 = Util_Tests.crearOrdenTrabajo('20210.0','21',tipoTrabajo1.Id,caso1.Id);
		ordenTrabajo1.AccountId = cuenta1.Id;
		insert ordenTrabajo1;
	}
	
	/*Test cuando se proporciona información en los dos campos (Case y WorkOrder)*/
	@isTest static void TestOK1() {
		inicializarVariablesMembership();
		Test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<WorkOrder> ordenTrabajo = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id =: ordenTrabajo.Id];
		List<Case> caso = [SELECT CaseNumber FROM Case WHERE Id =: caso.Id];
		
		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '72564560S');
		req.addParameter('WorkOrderNumber', ordenTrabajo[0].WorkOrderNumber);
		req.addParameter('CaseNumber', caso[0].CaseNumber);
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
	
	/*Test cuando se proporciona información de uno de los campos (WorkOrder)*/
	@isTest static void TestOK2() {
		inicializarVariablesMembership();
		Test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<WorkOrder> ordenTrabajo = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id =: ordenTrabajo.Id];
		
		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '72564560S');
		req.addParameter('WorkOrderNumber', ordenTrabajo[0].WorkOrderNumber);
		req.addParameter('CaseNumber', '');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
	
	/*Test cuando se proporciona información de uno de los campos (Case)*/
	@isTest static void TestOK3() {
		inicializarVariablesMembership();
		Test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<Case> caso = [SELECT CaseNumber FROM Case WHERE Id =: caso.Id];
		
		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '72564560S');
		req.addParameter('WorkOrderNumber', '');
		req.addParameter('CaseNumber', caso[0].CaseNumber);
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}

	/*Test cuando no se proporciona información de ninguno de los campos (Case y WorkOrder)*/
	@isTest static void TestKO1() {
		inicializarVariablesMembership();
		Test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '72564560S');
		req.addParameter('WorkOrderNumber', '');
		req.addParameter('CaseNumber', '');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
	
	/*Test cuando se proporciona información del caso, pero no es de Membership*/
	@isTest static void TestKO2() {
		inicializarVariablesSegurCaixa();
		Test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<Case> caso = [SELECT CaseNumber FROM Case WHERE Id =: caso1.Id];
		
		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '56347898R');
		req.addParameter('WorkOrderNumber', '');
		req.addParameter('CaseNumber', caso[0].CaseNumber);
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
	
	/*Test cuando se proporciona información del caso, pero no existe*/
	@isTest static void testKO3(){
		inicializarVariablesMembership();
		test.startTest();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '72564560S');
		req.addParameter('WorkOrderNumber', '');
		req.addParameter('CaseNumber', '00055338');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
	
	/*Test cuando se proporciona información del workOrder, pero no existe*/
	@isTest static void testKO4(){
		inicializarVariablesMembership();
		test.startTest();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '72564560S');
		req.addParameter('WorkOrderNumber', '00772406');
		req.addParameter('CaseNumber', '');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
	
	/*Test donde se proporciona el numero de caso y de orden de trabajo, pero no coincide con el dni*/
	@isTest static void testKO5(){
		inicializarVariablesMembership();
		inicializarVariablesSegurCaixa();
		test.startTest();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<WorkOrder> ordenTrabajo = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id =: ordenTrabajo1.Id];
		List<Case> caso = [SELECT CaseNumber FROM Case WHERE Id =: caso1.Id];

		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '56347898R');
		req.addParameter('WorkOrderNumber', ordenTrabajo[0].WorkOrderNumber);
		req.addParameter('CaseNumber', caso[0].CaseNumber);
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
	
	/*Test cuando se proporciona información del workOrder, pero no es de Membership*/
	@isTest static void TestKO6() {
		inicializarVariablesSegurCaixa();
		Test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<WorkOrder> ordenTrabajo = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id =: ordenTrabajo1.Id];
		
		req.requestURI = '/services/apexrest/validarCliente';
		req.addParameter('CUE_TXT_Numero_Documento', '56347898R');
		req.addParameter('WorkOrderNumber', ordenTrabajo[0].WorkOrderNumber);
		req.addParameter('CaseNumber', '');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();
		resultado = Rest_ValidaClienteMember.doGet();

		test.stopTest();
	}
}