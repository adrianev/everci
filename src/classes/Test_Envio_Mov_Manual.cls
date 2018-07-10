@isTest
global without sharing class Test_Envio_Mov_Manual {
	private static Account compania;
	private static INT_Config_Fichero_CIA__c configFich;
	private static INT_Envio_Programado__c envProg;
	private static INT_Bitacora__c bit;
	private static INT_Movimiento_CIA__c mov;
	
	@testSetup
	static void setup() {
		compania = Util_Tests.crearcuentaCompania('compania','1000','X8157623Y');
		insert compania;

		Account asegurado = Util_Tests.crearcuentaAsegurado('Laura','xxxxxx', 'laura@laura.com', '23017462M', 'rayo', 'kiko', 'hdez');
		asegurado.CUE_LKP_Cuenta_Principal__c = compania.id;
		insert asegurado;

		Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;

	    Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;

	    ServiceContract poliza = Util_tests.crearPolizaContrato('10', compania.id, asegurado.id, productoCIA.id);
		 insert poliza;
		Case caso = new Case();
		caso = Util_Tests.crearCasoB2B(poliza.Id, asegurado.Id, compania.Id);
		insert caso; 

		configFich=Util_Tests.crearConfigFichero(compania.Id,'SELECT MOV_FOR_Cons_Codigo__c FROM INT_Movimiento_CIA__c', 'Fichero');
		insert configFich;
		envProg=Util_Tests.crearEnvProg(configFich.Id,'00:00', Date.today(),1);
		bit = Util_Tests.crearbitacoraFichero(envProg.Id);
		insert bit;
		mov = new INT_Movimiento_CIA__c(MOV_LKP_Bitacora__c=bit.Id,MOV_LKP_Caso__c=caso.id);
		insert mov;
		INT_Comentarios__c com = new INT_Comentarios__c(ICC_LKP_Movimiento_CIA__c=mov.Id);
		insert com;
		INT_Garantias_Siniestros__c gar = new INT_Garantias_Siniestros__c(IGS_LKP_Movimiento_CIA__c=mov.Id);
		insert gar;
		INT_Orden_Trabajo__c ot = new INT_Orden_Trabajo__c(IOT_LKP_Movimiento_CIA__c=mov.Id);
		insert ot;
		INT_Contactos_Telefonicos__c ct = new INT_Contactos_Telefonicos__c(ICT_LKP_Movimiento_CIA__c=mov.Id);
		insert ct;
		INT_Perjudicados__c perj = new INT_Perjudicados__c(IPE_LKP_Movimiento_CIA__c=mov.Id);
		insert perj;


    }
	static testmethod void test() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
		List<INT_Movimiento_CIA__c> movList = new List<INT_Movimiento_CIA__c>([SELECT Id, MOV_LKP_Bitacora__c,MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__c FROM INT_Movimiento_CIA__c]);
		ApexPages.StandardSetController sc = new ApexPages.StandardSetController(movList);
		sc.setSelected(movList);
		Envio_Mov_Manual envioMov = new Envio_Mov_Manual(sc);
		envioMov.enviaMovs();
		Test.stopTest();
	}
	global without sharing class TestHttpCalloutMock implements HttpCalloutMock {
		// Implement this interface method
		global HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"errorCode" : " ", "errorMessage" : " "}');
			response.setStatusCode(200);
			return response; 
		}
	}
}