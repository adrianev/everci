/**
 * Clase de Test de la Clase controladora B2B_Gremios
 * 
 */
@isTest
public without sharing class Test_B2B_Gremios extends TestSetup {

	final static String SERVICE_CONTRACT_NAME = '9729187';

	private static Account cuenta {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}

	/**
	 * Realizamos el caso de prueba con el parámetro Id informado.
	 * 
	 */
	@isTest static void testCasoParametroIdInformado() {
		Test.startTest();
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);

		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('b2c','Case:CAS_Solicitud_de_Servicio_B2C');
	    system.debug('>>>>>>>>>>>>>>>>caso22: ' + caso);
		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('b2c'), 'Case:CAS_Solicitud_de_Servicio_B2C');
		System.assertEquals(ApexPages.currentPage().getParameters().get('id'), caso.Id);
		B2B_Gremios prueba = new B2B_Gremios(stdc);

		prueba.buscarTiposTrabajo();
		prueba.validarCheckUrgente();
		prueba.listaResultados.get(0).seleccionado = true;
		prueba.guardar();
		Test.stopTest();
	}

	/**
	 * Realizamos el caso de prueba con el parámetro Id NO informado y B2C informado.
	 * 
	 */
	@isTest static void testCasoParametroIdNoInformadoB2CInformado() {
		Test.startTest();
		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);

		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('b2c','Case:CAS_Solicitud_de_Servicio_B2C');

		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('b2c'), 'Case:CAS_Solicitud_de_Servicio_B2C');


		B2B_Gremios prueba = new B2B_Gremios(stdc);

		//prueba.buscarTTyLC();
		prueba.buscarTiposTrabajo();
		//prueba.buscarLineasDeContrato();
		prueba.validarCheckUrgente();
		prueba.guardar();
		Test.stopTest();
	}

	/**
	 * Realizamos el caso de prueba con el parámetro Id NO informado y el B2C NO informado.
	 * 
	 */
	@isTest static void testCasoParametroIdNoInformadoB2CNoInformado() {
		Test.startTest();
		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		B2B_Gremios prueba = new B2B_Gremios(stdc);
		prueba.buscarTiposTrabajo();
		prueba.validarCheckUrgente();
		prueba.guardar();
		Test.stopTest();
	}

	/**
	 * Realizamos el caso de prueba con el RTDevName igual al CAS_SOLIC_B2C.
	 * 
	 */
	@isTest static void testCasoRTDevNameIgualSolicB2C() {
		Test.startTest(); 
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);

		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('b2c','Case:CAS_Solicitud_de_Servicio_B2C');

		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('b2c'), 'Case:CAS_Solicitud_de_Servicio_B2C');
		System.assertEquals(ApexPages.currentPage().getParameters().get('id'), caso.Id);       
		B2B_Gremios prueba = new B2B_Gremios(stdc);
		Test.stopTest();
	}

	/**
	 * Realizamos el caso de prueba de cancelar abriendo el servicio y sin seleccionar el gremio principal.
	 */
	@isTest static void testAbriendoServicioSinSeleccionarGremio() {
		Test.startTest();
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);

		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('b2c','Case:CAS_Solicitud_de_Servicio_B2C');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		caso.CAS_LKP_Orden_Trabajo_Principal__c = null;

		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('b2c'), 'Case:CAS_Solicitud_de_Servicio_B2C');
		System.assertEquals(ApexPages.currentPage().getParameters().get('fase'), 'APERTURA');

		System.assertEquals(caso.CAS_LKP_Orden_Trabajo_Principal__c, null);
		B2B_Gremios prueba = new B2B_Gremios(stdc);
		prueba.cancelar();
		Test.stopTest();
	}

	/**
	 * Realizamos el caso de prueba de cancelar sin abrir el servicio.
	 */
	@isTest static void testCancelarSinAbrirServicio() {
		Test.startTest();
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);

		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('b2c','Case:CAS_Solicitud_de_Servicio_B2C');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_CONFIRMACION);

		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('b2c'), 'Case:CAS_Solicitud_de_Servicio_B2C');
		System.assertEquals(ApexPages.currentPage().getParameters().get('fase'), 'CONFIRMACION');

		B2B_Gremios prueba = new B2B_Gremios(stdc);
		prueba.cancelar();
		Test.stopTest();
	}    

	/**
	 * Realizamos el caso de prueba con el parámetro Id informado, informando 'gremio'.
	 * 
	 */
	@isTest static void testCasoParametroIdInformadoInformandoGremio() {
		Test.startTest();
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);

		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('b2c','Case:CAS_Solicitud_de_Servicio_B2C');

		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('b2c'), 'Case:CAS_Solicitud_de_Servicio_B2C');
		System.assertEquals(ApexPages.currentPage().getParameters().get('id'), caso.Id);

		B2B_Gremios prueba = new B2B_Gremios(stdc);

		prueba.buscarTiposTrabajo();
		//prueba.resultado.seleccionado = true;
		prueba.listaResultados.get(0).seleccionado = true;
		prueba.guardar();
		prueba.validarCheckUrgente();
		Test.stopTest();
	}

	/**
	 * Realizamos el caso de prueba con el parámetro Id informado, informando 'gremio' con contrato 'activo'.
	 * 
	 */
	@isTest static void testCasoParametroIdInformadoInformandoGremioContratoActivo() {
		Test.startTest();
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);

		PageReference pageRef = Page.B2B_Gremios;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('idCuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('b2c','Case:CAS_Solicitud_de_Servicio_B2C');

		System.assertEquals(ApexPages.currentPage().getParameters().get('idCuenta'), cuenta.Id);
		System.assertEquals(ApexPages.currentPage().getParameters().get('b2c'), 'Case:CAS_Solicitud_de_Servicio_B2C');
		System.assertEquals(ApexPages.currentPage().getParameters().get('id'), caso.Id);

		B2B_Gremios prueba = new B2B_Gremios(stdc);

		prueba.buscarTiposTrabajo();
		prueba.booleanUrgente = true;
		prueba.validarCheckUrgente();
		prueba.nuevoComentario.COT_TXT_Comentario__c = '';
		prueba.listaResultados.get(0).seleccionado = true;
		caso.CAS_LKP_Orden_Trabajo_Principal__c = null;
		prueba.guardar();
		Test.stopTest();
	}

	
	
	private static void inicializarVariables() {
		Baipas.establecerVariableControl();
		List<Account> listaCuentas = new List<Account>();
		//cuenta = Util_Tests.crearCuentaAsegurado('Asegurado','19783886E','aseguradoExample@gmail.es','12345678A','Paco','Fernadez','Lopez','12345678X');
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1234567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1134567X');
		Account compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1114567X');
		listaCuentas.add(cuenta);
		listaCuentas.add(compania);
		insert listaCuentas;
		Tipo_Producto_CIA__c tipoProd = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProd;
		Producto_CIA__c prod = Util_Tests.crearProductoCIA('KIT 107','12345678', tipoProd.Id);
		insert prod;
		Poblacion__c pobl =  Util_Tests.crearPoblacion('Madrid','28');
		insert pobl;
		poliza = Util_Tests.crearPolizaContrato('2277393', compania.Id, cuenta.Id,prod.Id);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0,0,0,0,0,cuentaPrincipal.Id,'101444',Label.PROCEDENCIA_SERVICIO_B2C);
		procedencia.PROC_SEL_Gremios_Disp__c = '02';
		insert procedencia;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21',2.00);
		tipoTrabajo.TDT_SEL_Categoria__c = '02';
		insert tipoTrabajo;
		caso = Util_Tests.crearCasoSini(poliza.Id,cuenta.Id,compania.Id);
		caso.CAS_SEL_Gremio_Principal__c = '21';
		caso.CAS_LKP_Procedencia__c = procedencia.Id;
		insert caso;
		Contact contacto = Util_Tests.crearContacto('Ruben','Gomez',cuenta.Id,'55558888');
		contacto.CON_CAS_Contacto_principal__c  = false;
		insert contacto;
		Contact contacto2 = Util_Tests.crearContacto('Sergio','Manzano',cuenta.Id,'55558878');
		contacto.CON_CAS_Contacto_principal__c  = true;
		insert contacto2;
	}
}