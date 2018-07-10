/**
 * Clase de test de la clase Rest_B2C_DevolverPDF
 * 
 */
@isTest public without sharing class Test_Rest_B2C_DevolverPDF {

	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get;set;}
		
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
        
        cuenta = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '9876543', 'F3814956C');
        insert cuenta;
        compania = Util_Tests.crearCuentaCompania('BricoDepot', '507508', 'F7421835E');
        compania.CUE_CAS_Permite_Servicio_CodActivac__c =true;
        insert compania;
        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('BricoDepot - Hogar','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','01',tipoProductoCIA.Id);
		insert productoCIA;
        poliza = Util_Tests.crearPolizaContrato('polizaContrato', compania.Id, cuenta.Id, productoCIA.Id);
        insert poliza;
        caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        insert caso;
        
        Baipas.deshabilitarVariableControl();
	}
	
	
	

	/**
	 * Estos métodos se encargan de realizar las diferentes pruebas para validar que el 
	 * servicio tiene en cuenta todos los casos posibles
	 *
	 */
	@isTest
	public static void testOK1(){
		inicializarVariables();

		test.startTest();
		//Caso OK
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/pdfCodigoActivacion';
		req.addParameter('Id', caso.Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_B2C_DevolverPDF.Resultado resultado = new Rest_B2C_DevolverPDF.Resultado();
		resultado = Rest_B2C_DevolverPDF.doGet();
		system.debug(resultado);

		test.stopTest();
	}

	@isTest
	public static void testKO1(){
		test.startTest();
		//Caso NOK. No se encuentra el caso
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/pdfCodigoActivacion';
		req.addParameter('Id', null);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_B2C_DevolverPDF.Resultado resultado = new Rest_B2C_DevolverPDF.Resultado();
		resultado = Rest_B2C_DevolverPDF.doGet();
		system.debug(resultado);

		test.stopTest();
	}
}