@isTest
global without sharing class Test_Callout_ConsultaPolizaVesta {
	
	static Integer mock_val ;
	
	
	@isTest
	public static void testUtil(){
		system.debug('test Callout_ConsultaPolizaVesta_Test');
		test.startTest();
		mock_val = 1;
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());

		Id identificadorCompania = '0019E00000NriNrQAJ';
		String numeroDocumento='Y4586574Z';

		List<Callout_ConsultaPolizaVesta_RP> respPortaAmdocs = Fachada.consultaPolizaVestaSimple(identificadorCompania, numeroDocumento);
		system.debug('Callout_ConsultaPolizaVesta_Test'+respPortaAmdocs);

		test.stopTest();
	}
	
	@isTest
	public static void testUtil2(){
		system.debug('test Callout_ConsultaPolizaVesta_Test2');
		test.startTest();
		mock_val = 2;
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());

		Id identificadorCompania = '0019E00000NriNrQAJ';
		String numeroDocumento='Y4586574Z';

		List<Callout_ConsultaPolizaVesta_RP> respPortaAmdocs = Fachada.consultaPolizaVestaSimple(identificadorCompania, numeroDocumento);
		system.debug('Callout_ConsultaPolizaVesta_Test'+respPortaAmdocs);
		
		test.stopTest();
	}
	
	
	@isTest
	public static void testUtil3(){
		system.debug('test Callout_ConsultaPolizaVesta_Test3');
		test.startTest();
		mock_val = 3;
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());

		Id identificadorCompania = '0019E00000NriNrQAJ';
		String numeroDocumento='Y4586574Z';

		List<Callout_ConsultaPolizaVesta_RP> respPortaAmdocs = Fachada.consultaPolizaVestaSimple(identificadorCompania, numeroDocumento);
		system.debug('Callout_ConsultaPolizaVesta_Test'+respPortaAmdocs);

		test.stopTest();
	}
	
	@isTest static void testUtil4(){
		system.debug('test Callout_ConsultaPolizaVesta_Test4');
		test.startTest();
		
		//Respuesta:
		Callout_ConsultaPolizaVesta_RP res =new Callout_ConsultaPolizaVesta_RP();
		res.numeroPoliza = ''+2;
		res.nombre = 'Juan';
		res.apellido1 = 'Ortega';
		res.apellido2 = 'Plaza';
		
		
		List<Account> listaCuentas = new List<Account>();
		
		Account cuentaPrincipal = new Account();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1234567X');
		insert cuentaPrincipal;
		
		Account cuenta = new Account();
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1134567X');
		
		Account compania = new Account();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1114567X');
		listaCuentas.add(cuenta);
		listaCuentas.add(compania);
		insert listaCuentas;
		
		Tipo_Producto_CIA__c tipoProd = new Tipo_Producto_CIA__c();
		tipoProd = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProd;
		
		Producto_CIA__c prod = new Producto_CIA__c();
		prod = Util_Tests.crearProductoCIA('KIT 107','12345678', tipoProd.Id);
		insert prod;
		
		ServiceContract poliza = Util_tests.crearPolizaContrato('10', compania.id, cuenta.id, prod.id);
		insert poliza;
		ServiceContract segundaPoliza = Util_tests.crearPolizaContrato('11', compania.id, cuenta.id, prod.id);
		insert segundaPoliza;
		mock_val = 4;
		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());

		Id identificadorCompania = '' + compania.Id;
		String numeroDocumento='X1234567X';

		List<Callout_ConsultaPolizaVesta_RP> respPortaAmdocs = Fachada.consultaPolizaVestaSimple(identificadorCompania, numeroDocumento);
		system.debug('Callout_ConsultaPolizaVesta_Test'+respPortaAmdocs);

		test.stopTest();
	}
	

	global without sharing class TestHttpCalloutMock implements HttpCalloutMock {
		// Implement this interface method
		global HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();

			response.setHeader('Content-Type', 'application/json');
			
			if(mock_val==1){

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
					'"telefono4": "123456789",'+
					'"numeroPolizasActivas": "88"'+
					'"codigoMunicipio": "12345"'+
					'"rolAsegurado": "P"'+
					'"idClienteEnsura": "7654e567"'+
					'} }');
				response.setStatusCode(200);
				
			}
			
			if(mock_val==2){

				response.setBody('{"errorCode": "1234", "errorMessage": "1234"}');	
				response.setStatusCode(402);
				
			}
			
			if(mock_val==3){

				response.setBody('{ }');
				response.setStatusCode(400);
				
			}
			
			
			
			return response;
		}
	}
}