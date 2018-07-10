@isTest
global without sharing class Test_Reenvio_Bitacora {
	private static Account cuenta;
	private static INT_Config_Fichero_CIA__c configFich;
	private static INT_Envio_Programado__c envProg;
	private static INT_Bitacora__c bit;
	
	@testSetup
	static void setup() {
		cuenta = Util_Tests.crearCuentaCompania('Cuenta','1000','Y6191776Y');
		insert cuenta;
		configFich=Util_Tests.crearConfigFichero(cuenta.Id,'SELECT MOV_FOR_Cons_Codigo__c FROM INT_Movimiento_CIA__c', 'Fichero');
		insert configFich;
		envProg=Util_Tests.crearEnvProg(configFich.Id,'00:00', Date.today().addDays(1), 123);
		insert envProg;
		bit = Util_Tests.crearbitacoraFichero(envProg.Id);
		insert bit;
    }
	static testmethod void test() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMockOK()); 
		List<INT_Bitacora__c> bitList = new List<INT_Bitacora__c>([SELECT Id,RecordTypeId, BIT_LKP_Envio_Programado_CIA__c FROM INT_Bitacora__c where RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO)]);
		ApexPages.StandardController sc = new ApexPages.StandardController(bitList.get(0));
		Reenvio_Bitacora envioMov = new Reenvio_Bitacora(sc);
		ApexPages.currentPage().getParameters().put('id',bitList.get(0).Id);
		envioMov.autoRun();
		Test.stopTest();
	}
	static testmethod void fallosTest(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMockOK()); 
		List<INT_Bitacora__c> bitList = new List<INT_Bitacora__c>([SELECT Id,RecordTypeId, BIT_LKP_Envio_Programado_CIA__c FROM INT_Bitacora__c]);
		ApexPages.StandardController sc = new ApexPages.StandardController(bitList.get(0));
		Reenvio_Bitacora envioMov = new Reenvio_Bitacora(sc);
		envioMov.autoRun();
		Test.stopTest();}
	
	static testmethod void carpetaLlena(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMockKO()); 
		List<INT_Bitacora__c> bitList = new List<INT_Bitacora__c>([SELECT Id,RecordTypeId, BIT_LKP_Envio_Programado_CIA__c FROM INT_Bitacora__c where RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO)]);
		ApexPages.StandardController sc = new ApexPages.StandardController(bitList.get(0));
		Reenvio_Bitacora envioMov = new Reenvio_Bitacora(sc);
		ApexPages.currentPage().getParameters().put('id',bitList.get(0).Id);
		envioMov.autoRun();
		Test.stopTest();
	}
	
	global without sharing class TestHttpCalloutMockOK implements HttpCalloutMock {
		// Implement this interface method
		global HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"code" : "INT-001", "errorMessage" : " "}');
			response.setStatusCode(200);
			return response; 
		}
	}
	global without sharing class TestHttpCalloutMockKO implements HttpCalloutMock {
		// Implement this interface method
		global HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"code" : "INT-002", "errorMessage" : " "}');
			response.setStatusCode(200);
			return response; 
		}
	}
}