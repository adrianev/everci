@isTest
public class Test_Callout_Centinela_Generacion {
	static testmethod void testOK() {
		Callout_Centinela_Generacion cg = new Callout_Centinela_Generacion();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
		cg.updateDatos('FICH-001');
		Test.stopTest();
	}

	public class TestHttpCalloutMock implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');		
			response.setBody('{"code":"INT-001","identificadorDestino":"FICH-001", "message" : "Todo OK" }');
			response.setStatusCode(200);
			return response; 
		}
	}
}