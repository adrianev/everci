/**
* Clase de Test de la Clase Rest_ClicHogar_DevolucionMens
*
* @author EVERIS
*
*/
@isTest
public without sharing class Test_Rest_ClicHogar_DevolucionMens {
	
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static Case caso1 {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuenta = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X1234567X');
		insert cuenta;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoSini(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		caso1 = Util_Tests.crearCasoSini(poliza.Id, cuenta.Id, compania.Id);
		insert caso1;
		
		Mensaje_Clic_Hogar__c mensaje1 = new Mensaje_Clic_Hogar__c();
		mensaje1.MCH_LKP_Caso__c = caso.Id;
		mensaje1.MCH_TXT_asunto__c = 'Revisión';
		mensaje1.MCH_TXT_consulta__c = 'Revisión del siniestro por problemas en la terminación.';
		mensaje1.MCH_DAT_fecha_alta_consulta__c = Date.newInstance(2018, 02, 13); 
		mensaje1.MCH_DAT_fecha_respuesta__c = Date.newInstance(2018, 02, 13);
		mensaje1.MCH_CAS_estado__c = true;
		mensaje1.MCH_TXT_respuesta__c = 'Siniestro terminado correctamente';
		insert mensaje1;
		
		Mensaje_Clic_Hogar__c mensaje2 = new Mensaje_Clic_Hogar__c();
		mensaje2.MCH_LKP_Caso__c = caso.Id;
		mensaje2.MCH_TXT_asunto__c = 'Siniestro';
		mensaje2.MCH_TXT_consulta__c = 'Fecha terminación';
		mensaje2.MCH_DAT_fecha_alta_consulta__c = Date.newInstance(2018, 02, 14); 
		mensaje2.MCH_DAT_fecha_respuesta__c = Date.newInstance(2018, 02, 14);
		mensaje2.MCH_CAS_estado__c = false;
		mensaje2.MCH_TXT_respuesta__c = 'Terminará en tres días';
		insert mensaje2;
		
	}
	
	/*Test OK*/
	@isTest static void TestOK(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/devolverMensaje/*';
		req.addParameter('MCH_LKP_Caso__c', caso.Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Rest_ClicHogar_DevolucionMens_RP resultado = new Rest_ClicHogar_DevolucionMens_RP();
		List<Rest_ClicHogar_DevolucionMens_RP.mensajes> listaMensajes = new List<Rest_ClicHogar_DevolucionMens_RP.mensajes>();
		resultado = Rest_ClicHogar_DevolucionMens.doGet();
		
		test.stopTest();
	}
	
	/*Test KO. No existe el caso*/
	@isTest static void TestKO1(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/devolverMensaje/*';
		req.addParameter('MCH_LKP_Caso__c', '');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Rest_ClicHogar_DevolucionMens_RP resultado = new Rest_ClicHogar_DevolucionMens_RP();
		List<Rest_ClicHogar_DevolucionMens_RP.mensajes> listaMensajes = new List<Rest_ClicHogar_DevolucionMens_RP.mensajes>();
		resultado = Rest_ClicHogar_DevolucionMens.doGet();
		
		test.stopTest();
	}
	
	/*Test KO. Existe el caso pero no tiene mensajes*/
	@isTest static void TestKO2(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/devolverMensaje/*';
		req.addParameter('MCH_LKP_Caso__c', caso1.Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Rest_ClicHogar_DevolucionMens_RP resultado = new Rest_ClicHogar_DevolucionMens_RP();
		List<Rest_ClicHogar_DevolucionMens_RP.mensajes> listaMensajes = new List<Rest_ClicHogar_DevolucionMens_RP.mensajes>();
		resultado = Rest_ClicHogar_DevolucionMens.doGet();
		
		test.stopTest();
	}
}