/**
 * Clase de Test de la Clase Rest_ConsultaReclamacionMembership
 *
 */
@isTest
public without sharing class Test_Rest_ConsultaReclamacionMembership extends TestSetup {
	
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get;set;}
	private static Case caso1 {get;set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	
	@isTest static void inicializarVariablesMembership(){
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('Membership','1999','X1234567X');
		insert compania;
		cuenta = Util_Tests.crearCuentaAsegurado('ClienteMembership', '132456', 'prueba@prueba.es', '12345678Z',
			'María', 'García', 'Montes');
		cuenta.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('MEMBERSHIP - Hogar','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('MEMBERSHIP - MEMBERSHIP SINIESTROS','01',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('8899767', compania.Id, cuenta.Id, productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoSini(poliza.Id,cuenta.Id, compania.Id);
		caso.CAS_TXT_Num_Caso_HS__c = '2018000002';
		caso.CAS_TXT_Direccion__c = 'CALLE Chimbo 22 2 B';
		caso.CAS_TXT_DirRiesgo_CP__c = '28025';
		caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '28';
		caso.Type = '1';
		caso.Status = '001';
		caso.CAS_DIV_Importe_Total__c = 0;
		insert caso;
		caso1 = Util_Tests.crearCasoReclamacion(poliza.Id,cuenta.Id, compania.Id);
		caso1.ParentId = caso.Id;
		caso1.Status = '991';
		insert caso1;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso1.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		ordenTrabajo.Status = '002';
		ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c = date.newInstance(2018, 01, 30);
		ordenTrabajo.OTR_SEL_Rango_Primera_Cita__c = '09';
		insert ordenTrabajo;
	}
	
	/*Test con dni correcto, y tiene un caso de tipo reclamacion*/
	@isTest static void testOK1() {
		inicializarVariablesMembership();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/consultarReclamacion';
		req.addParameter('CUE_TXT_Numero_Documento', '72564560S');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ConsultaReclamacionMembership_RP resultado = new Rest_ConsultaReclamacionMembership_RP();
		resultado = Rest_ConsultaReclamacionMembership.doGet();

		system.debug(resultado);
	}
	
}

	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	 /*
	@testSetup
	public static void test(){
		TestSetup loadData = new Test_Rest_ConsultaReclamacionMembership();
		loadData.setTestData();
	}

	@isTest static void testOK1() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/consultarReclamacion';
		req.addParameter('CUE_TXT_Numero_Documento', '12453267Y');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;


		Rest_ConsultaReclamacionMembership_RP resultado = new Rest_ConsultaReclamacionMembership_RP();
		resultado = Rest_ConsultaReclamacionMembership.doGet();

		system.debug(resultado);
	}

}*/

/*@isTest (SeeAllData = True)
public without sharing class Rest_ConsultaReclamacionMembership_Test {
	@isTest
	public static void testOK1(){
		//Test con DNI válido asociado a cuenta pero sin número de caso
		test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/consultarReclamacion';
		req.addParameter('CUE_TXT_Numero_Documento', '01112906M');
		req.addParameter('CAS_SEL_origen_web', '01');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;


		Rest_ConsultaReclamacionMembership_RP resultado = new Rest_ConsultaReclamacionMembership_RP();
		resultado = Rest_ConsultaReclamacionMembership.doGet();

		system.debug(resultado);

		test.stopTest();
	}
}*/