/**
* Clase de Test de la Clase Rest_ValidacionLoginClicHogar
*
* @author EVERIS
*
*/
@isTest
public without sharing class Test_Rest_ValidacionLoginClicHogar {
	
	public static Account cuentaB2BPrincipal {get;set;}
	private static Account cuentaCompania {get; set;}
	private static Account cuentaAsegurado {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case casoSini {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();

		cuentaB2BPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1018','X1234567X');
		insert cuentaB2BPrincipal;

		cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1019','X1134567X');
		insert cuentaCompania;

		Account cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1021','email@gmail.es','03629033R','nombre','apellido1','apellido2');
		cuentaAsegurado.CUE_LKP_Cuenta_principal__c = cuentaCompania.Id;
		insert cuentaAsegurado;

		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.id);
		insert tipoProductoCIA;

		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;

		poliza = new ServiceContract();
		poliza = Util_Tests.crearPolizaContrato('2277393',cuentaCompania.Id,cuentaAsegurado.Id,productoCIA.Id);
		insert poliza;

		casoSini = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,cuentaB2BPrincipal.Id);
		casoSini.CAS_TXT_Usuario_Clic_Hogar__c = '101810';
		casoSini.CAS_TXT_Password_Clic_Hogar__c = '5009E000007J82s';
		insert casoSini;

	}
	
	/*Test OK*/
	@isTest static void TestOK1(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<Case> infoCaso = [SELECT CAS_TXT_Usuario_Clic_Hogar__c, CAS_TXT_Password_Clic_Hogar__c FROM Case WHERE Id =: casoSini.Id];
		
		req.requestURI = '/services/apexrest/caso/validacionLogin/*';
		req.addParameter('CAS_TXT_Usuario_Clic_Hogar', infoCaso[0].CAS_TXT_Usuario_Clic_Hogar__c);
		req.addParameter('CAS_TXT_Password_Clic_Hogar', infoCaso[0].CAS_TXT_Password_Clic_Hogar__c);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Rest_ValidacionLoginClicHogar_RP resultado = new Rest_ValidacionLoginClicHogar_RP();
		resultado = Rest_ValidacionLoginClicHogar.doGet();

		resultado = Rest_ValidacionLoginClicHogar.doGet();
		
		test.stopTest();
	}
	
	/*Test KO*/
	@isTest static void TestKO2(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		List<Case> infoCaso = [SELECT CAS_TXT_Usuario_Clic_Hogar__c, CAS_TXT_Password_Clic_Hogar__c FROM Case WHERE Id =: casoSini.Id];
		
		req.requestURI = '/services/apexrest/caso/validacionLogin/*';
		req.addParameter('CAS_TXT_Usuario_Clic_Hogar', infoCaso[0].CAS_TXT_Usuario_Clic_Hogar__c);
		req.addParameter('CAS_TXT_Password_Clic_Hogar', '4567654345');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Rest_ValidacionLoginClicHogar_RP resultado = new Rest_ValidacionLoginClicHogar_RP();
		resultado = Rest_ValidacionLoginClicHogar.doGet();
		
		test.stopTest();
	}
	
}