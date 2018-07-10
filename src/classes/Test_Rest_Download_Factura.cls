/**
 * Clase de test de la clase Rest_Download_Factura
 * 
 */
@isTest public without sharing class Test_Rest_Download_Factura extends TestSetup{
	
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get;set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static Factura__c factura {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('Membership','1999', 'X1234567X');
		insert compania;
		cuenta = Util_Tests.crearCuentaAsegurado('ClienteMembership', '132456', 'prueba@prueba.es', '12345678Z',
			'María', 'García', 'Montes');
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
		factura = new Factura__c();
		factura.FAC_TXT_Numero_factura__c = '1224';
		factura.FAC_LKP_Caso__c = caso.Id;
		factura.FAC_LKP_Cuenta__c = cuenta.Id;
		factura.FAC_LKP_WorkOrkder__c = ordenTrabajo.Id;
		insert factura;
		ContentVersion cv = new ContentVersion();
		cv.Title = 'Factura.txt';
		cv.PathOnClient = cv.Title;
		cv.VersionData = EncodingUtil.base64Decode('YQ==');
		cv.FirstPublishLocationId = factura.Id;
		insert cv;
	}
	
	/*Test*/
	@isTest static void TestOK1(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/descargaFactura';
		req.addParameter('Id', factura.Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_Download_Factura.Resultado resultado = new Rest_Download_Factura.Resultado();
		resultado = Rest_Download_Factura.doGet();
		system.debug(resultado);

		test.stopTest();
	}
	
	@isTest public static void testKO1(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/descargaFactura';
		req.addParameter('Id', 'fail');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_Download_Factura.Resultado resultado = new Rest_Download_Factura.Resultado();
		resultado = Rest_Download_Factura.doGet();
		system.debug(resultado);

		test.stopTest();
	}
	
}