/**
 * Clase de Test de la Clase Callout_ClickToCall
 *  @author everis 
 **/
@isTest
public without sharing class Test_Callout_ClickToCall {
	@isTest
	public static void testOK(){		
		Callout_ClickToCall_RQ aux = new Callout_ClickToCall_RQ();
		aux.telefono  = '600745611';
		aux.idCarga = 22323;
		aux.idServicio = 2323;
		Datetime myDateTime = Datetime.newInstance(1960, 2, 17);
		aux.fechaProgramada = myDateTime;
		aux.dato1 = 'datoOne';
		aux.dato2 = '';
		aux.dato3 = 'datoThree';
		test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
		Callout_ClickToCall llamada = new Callout_ClickToCall();
		Callout_ClickToCall.Resultado res = new Callout_ClickToCall.Resultado();
		res =  Callout_ClickToCall.sendDatos(aux);
		test.stopTest();
	}

	public class TestHttpCalloutMock implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"code":"PRS-001", "message" : "Operación ejecutada correctamente" }');

			response.setStatusCode(200);
			return response; 
		}
	}
}