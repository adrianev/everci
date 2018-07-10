/**
 * Clase de Test de la Clase Rest_PolizasActivasCompania_Test
 *
 */
@isTest
global without sharing class Test_Rest_PolizasActivasCompania {

	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	/*@testSetup
	public static void test(){
		TestSetup loadData = new Test_Rest_PolizasActivasCompania();
		loadData.setTestData();
	}*/
	static Integer mock_val ; 

	@isTest static void testOK1() {
		
		mock_val = 1 ;
		
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/polizasActivasCompania';
		req.addParameter('CUE_TXT_Identificador', '1018');
		req.addParameter('infoFee', 'True');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_PolizasActivasCompania.doGet();

		system.debug(Rest_PolizasActivasCompania.doGet());
	}
	
		@isTest static void testKO1() {
			
		mock_val = 2 ;		
	
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/polizasActivasCompania';
		req.addParameter('CUE_TXT_Identificador', '1018');
		req.addParameter('infoFee', 'True');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_PolizasActivasCompania.doGet();

		system.debug(Rest_PolizasActivasCompania.doGet());
	}
	
	
		@isTest static void testKO2() {
			
		mock_val = 3 ;
		
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/polizasActivasCompania';
		req.addParameter('CUE_TXT_Identificador', '1018');
		req.addParameter('infoFee', 'True');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_PolizasActivasCompania.doGet();

		system.debug(Rest_PolizasActivasCompania.doGet());
	}
	
	
	
	
	
	global without sharing class TestHttpCalloutMock implements HttpCalloutMock {
		// Implement this interface method
		global HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
		
			response.setHeader('Content-Type', 'application/json');
			
			if (mock_val ==1){
			response.setBody('{'+
				'"poliza":{'+
				'"identificadorCompania": "1042",'+
				'"numeroPoliza":"22222222",'+
				'"identificadorVersion":"333332",'+
				'"fechaInicioCobertura": "2017-08-24T11:00:00.000+0000",'+
				'"fechaFinCobertura": "2018-08-24T11:00:00.000+0000",'+
				'"tomadorNumeroDocumentoCliente": "12345678A",'+
				'"nombre": "Antonio",'+
				'"apellido1": "López",'+
				'"apellido2": "Lorente",'+
				'"email": "antonio@mail.es",'+
				'"idioma": "Español",'+
				'"producto": "Ph2",'+
				'"direccionRiesgoDomicilio": "Camino del Cerro de los Gamos, 1",'+
				'"direccionRiesgoPoblacion": "Pozuelo Alarcon",'+
				'"direccionRiesgoProvincia" : "Madrid",'+
				'"direccionRiesgoCp": "28000",'+
				'"capitalContenido": "100",'+
				'"capitalContinente": "500",'+
				'"capitalObjetos": "200",'+
				'"certificado": "Certificado 105060",'+
				'"codigoDelegacion": "0000002200",'+
				'"codigoSucursal": "5000002200",'+
				'"controlDigitoSegurcaixa": "2",'+
				'"datosVivienda": "3 HABITACIONES 1 BAÑO 1 SALON",'+
				'"fechaAltaCompania": "2017-10-24T20:51:31.274Z",'+
				'"isGold": "true",'+
				'"isVip": "false",'+
				'"superficieGaraje": "14",'+
				'"superficieTrastero": "12",'+
				'"superficieVivienda": "150",'+
				'"suplemento": "50",'+
				'"tipoDivisa": "euro",'+
				'"tipoRegimenVivienda": "Propia",'+
				'"tipoTransferencia": "1234",'+
				'"polizaComplementaria":"333332",'+
				'"codigoGestor": "2345",'+
				'"codigocliente": "800232",'+
				'"telefono1": "555555555",'+
				'"telefono2": "244554555",'+
				'"telefono3": "600000000",'+
				'"numeroPolizasActivas": "88"'+
				'"codigoMunicipio": "12345"'+
				'"rolAsegurado": "P"'+
				'"idClienteEnsura": "7654e567"'+
				'},'+
				'"poliza":{'+
				'"identificadorCompania": "6000",'+
				'"numeroPoliza":"22222222",'+
				'"identificadorVersion":"333332",'+
				'"fechaInicioCobertura": "2017-08-24T11:00:00.000+0000",'+
				'"fechaFinCobertura": "2018-08-24T11:00:00.000+0000",'+
				'"tomadorNumeroDocumentoCliente": "12345678A",'+
				'"nombre": "Antonio",'+
				'"apellido1": "López2",'+
				'"apellido2": "Lorente2",'+
				'"email": "antonio@mail.es2",'+
				'"idioma": "Españo2l",'+
				'"producto": "Ph2",'+
				'"direccionRiesgoDomicilio": "Camino del Cerro de los Gamos, 1",'+
				'"direccionRiesgoPoblacion": "Pozuelo Alarcon2",'+
				'"direccionRiesgoProvincia" : "Madrid2",'+
				'"direccionRiesgoCp": "28000",'+
				'"capitalContenido": "1002",'+
				'"capitalContinente": "5002",'+
				'"capitalObjetos": "2002",'+
				'"certificado": "Certificado 1050602",'+
				'"codigoDelegacion": "00000022002",'+
				'"codigoSucursal": "50000022002",'+
				'"controlDigitoSegurcaixa": "1",'+
				'"datosVivienda": "3 HABITACIONES 1 BAÑO 1 SALON",'+
				'"fechaAltaCompania": "2017-10-24T20:51:31.274Z",'+
				'"isGold": "true",'+
				'"isVip": "false",'+
				'"superficieGaraje": "14",'+
				'"superficieTrastero": "12",'+
				'"superficieVivienda": "150",'+
				'"suplemento": "50",'+
				'"tipoDivisa": "euro",'+
				'"tipoRegimenVivienda": "Propia",'+
				'"tipoTransferencia": "1234",'+
				'"polizaComplementaria":"333332",'+
				'"codigoGestor": "2345",'+
				'"codigocliente": "800232",'+
				'"telefono1": "555555555",'+
				'"telefono2": "244554555",'+
				'"telefono3": "600000000",'+
				'"numeroPolizasActivas": "88"'+
				'"codigoMunicipio": "12345"'+
				'"rolAsegurado": "P"'+
				'"idClienteEnsura": "7654e567"'+
				'}}');
				response.setStatusCode(200);
			}
			else if(mock_val == 2 ) {
				response.setStatusCode(200);
				response.setBody('{"poliza":{"identificadorCompania": "",'+
				'"numeroPoliza":"",'+
				'"identificadorVersion":"",'+
				'"fechaInicioCobertura": "2017-08-24T11:00:00.000+0000",'+
				'"fechaFinCobertura": "2018-08-24T11:00:00.000+0000",'+
				'"tomadorNumeroDocumentoCliente": "12345678A",'+
				'"nombre": "Antonio",'+
				'"apellido1": "López",'+
				'"apellido2": "Lorente",'+
				'"email": "antonio@mail.es",'+
				'"idioma": "Español",'+
				'"producto": "Ph2",'+
				'"direccionRiesgoDomicilio": "Camino del Cerro de los Gamos, 1",'+
				'"direccionRiesgoPoblacion": "Pozuelo Alarcon",'+
				'"direccionRiesgoProvincia" : "Madrid",'+
				'"direccionRiesgoCp": "28000",'+
				'"capitalContenido": "100",'+
				'"capitalContinente": "500",'+
				'"capitalObjetos": "200",'+
				'"certificado": "Certificado 105060",'+
				'"codigoDelegacion": "0000002200",'+
				'"codigoSucursal": "5000002200",'+
				'"controlDigitoSegurcaixa": "2",'+
				'"datosVivienda": "3 HABITACIONES 1 BAÑO 1 SALON",'+
				'"fechaAltaCompania": "2017-10-24T20:51:31.274Z",'+
				'"isGold": "true",'+
				'"isVip": "false",'+
				'"superficieGaraje": "14",'+
				'"superficieTrastero": "12",'+
				'"superficieVivienda": "150",'+
				'"suplemento": "50",'+
				'"tipoDivisa": "euro",'+
				'"tipoRegimenVivienda": "Propia",'+
				'"tipoTransferencia": "1234",'+
				'"polizaComplementaria":"333332",'+
				'"codigoGestor": "2345",'+
				'"codigocliente": "800232",'+
				'"telefono1": "555555555",'+
				'"telefono2": "244554555",'+
				'"telefono3": "600000000",'+
				'"numeroPolizasActivas": "88"'+
				'"codigoMunicipio": "12345"'+
				'"rolAsegurado": "P"'+
				'"idClienteEnsura": "7654e567"}}');
			}
			
			else if(mock_val == 3 ) {
				response.setStatusCode(500);
				response.setBody('{"errorCode" : " ", "errorMessage" : " "}');
			}
			
			return response; 
		}
	}
	
	
	
}