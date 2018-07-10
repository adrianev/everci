/**
 * Clase de Test de la Clase Rest_ClicHogar_ConsultaCaso
 *
 * @author EVERIS
 */
//@isTest
public without sharing class Test_Rest_ClicHogar_ConsultaCaso {
	
	private static Account cuentaPrincipal {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static WorkOrderLineItem partidaTrabajo {get;set;}
	private static ServiceAppointment citaServicio {get; set;}
	private static Garantia__c garantia {get;set;}
	private static Garantia_Siniestro__c garantiaSiniestro {get;set;}
	
	//@isTest 
	public static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', '86547823F');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('224477393',compania.Id,cuentaPrincipal.Id,true,'791627066','28001','PISO',Date.newInstance(2016, 12, 31),'Madrid',productoCIA.Id,'2');
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		caso.CAS_TXT_Num_Caso_HS__c = '2217132880';
		caso.Type = '3';
		caso.CAS_SEL_Grupo_Causa__c = '03';
		caso.CAS_SEL_Causa_Averia__c = 'Dañado por el impacto';
		caso.CAS_CAS_Requiere_Perito__c = true;
		caso.Status = '700';
		caso.CAS_CAS_Siniestro_Encuestado__c = false;
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('28210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.OTR_DAT_Fecha_Cierre_servicio__c = Date.newInstance(2018, 03, 25); 
		ordenTrabajo.Status = '990';
		insert ordenTrabajo;
		ordenTrabajo.Status = '994';
		update ordenTrabajo;
		partidaTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
		insert partidaTrabajo;
		citaServicio = [SELECT Id FROM ServiceAppointment WHERE ParentRecordId =:ordenTrabajo.Id];
		citaServicio.ArrivalWindowStartTime = datetime.newInstance(2018,03,12);
		upsert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
		update caso;
		garantia = new Garantia__c();
		garantia.GAR_LKP_Compania__c = compania.Id;
		garantia.GAR_TXT_Descripcion__c = 'CRISTALES MARMOLES LOZA VITROCERAMICAS - CTE';
		insert garantia;
		garantiaSiniestro = new Garantia_Siniestro__c();
		garantiaSiniestro.GSIN_LKP_Garantia__c = garantia.Id;
		garantiaSiniestro.GSIN_LKP_Caso__c = caso.Id;
		insert garantiaSiniestro;
		system.debug('---- SVV. Insertado todo lo necesario ----');
	}
	
	/*Test*/
	//@isTest 
	public static void Test(){
		inicializarVariables();
		//test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/consultaCaso/*';
		req.addParameter('Id', caso.Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		system.debug('---- SVV. Id Caso: ' + caso.Id);
		system.debug('---- SVV. Id Orden de Trabajo: ' + ordenTrabajo.Id);
		Rest_ClicHogar_ConsultaCaso_RP resultado = new Rest_ClicHogar_ConsultaCaso_RP();
		resultado = Rest_ClicHogar_ConsultaCaso.doGet();
		system.debug('---- SVV. Resultado ----');
		system.debug(resultado);
		
		//test.stopTest();
	}
	
	/*Test KO*/
	/*
	@isTest static void TestKO(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/consultaCaso/*';
		req.addParameter('Id', '');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ClicHogar_ConsultaCaso_RP resultado = new Rest_ClicHogar_ConsultaCaso_RP();
		resultado = Rest_ClicHogar_ConsultaCaso.doGet();
		system.debug(resultado);
		
		test.stopTest();
	}*/
	
}

	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	 /*
	@testSetup
	public static void test(){
		TestSetup loadData = new Test_Rest_ClicHogar_ConsultaCaso();
		loadData.setTestData();
	}
	*/

	/**
	 * Este método se encarga de realizar las diferentes pruebas para validar que el 
	 * servicio tiene en cuenta todos los casos posibles
	 *
	 */
	 /*
	@isTest static void testOK1(){
		test.startTest();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		List<Case> caso = [SELECT Id FROM Case WHERE RecordTypeId  =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO) AND AccountId = '0019E00000XZI54QAH'];


		req.requestURI = '/services/apexrest/consultaCaso';
		req.addParameter('Id', caso[0].Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ClicHogar_ConsultaCaso_RP resultado = new Rest_ClicHogar_ConsultaCaso_RP();
		resultado = Rest_ClicHogar_ConsultaCaso.doGet();

		test.stopTest();
	}
}


@isTest (SeeAllData = True)
public without sharing class Rest_ClicHogar_ConsultaCaso_Test {
	@isTest
	public static void testOK1(){
		//Test con DNI válido asociado a cuenta pero sin número de caso
		test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/consultaCaso';
		req.addParameter('Id', '5009E000007J32G');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ClicHogar_ConsultaCaso_RP resultado = new Rest_ClicHogar_ConsultaCaso_RP();
		resultado = Rest_ClicHogar_ConsultaCaso.doGet();

		test.stopTest();
	}
}*/