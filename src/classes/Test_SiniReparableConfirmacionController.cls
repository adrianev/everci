/**
 * Clase de Test para la clase SiniReparableConfirmacionController.
 *
 * @author Everis
 */
@isTest
public without sharing class Test_SiniReparableConfirmacionController {

	// Constantes:
	private final static PageReference PAGINA_VISUALFORCE_EJECUCION = Page.SiniReparableConfirmacion;

	// Objetos para el Test:
	private static Account cia;
	private static Account asegurado;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCIA;
	private static ServiceContract poliza;
	private static Case intervencion;
	private static Comentario_caso__c comentarioCaso;
	private static Confirmacion__c confirmacion;
	private static WorkType tipoTrabajo;
	private static WorkOrder servicio;
	private static Comentario_Orden_de_Trabajo__c comentarioOT;
	private static ServiceAppointment citaServicio;
	private static Profile perfilAdministrador;
	private static Profile perfilProfesional;
	private static Profile perfilGestor;
	private static User usuarioAdministrador;
	private static User usuarioProfesional;
	private static User usuarioGestor;
	private static PageReference paginaActual;
	private static ApexPages.StandardController sc;

	/**
	 * Método privado que inicializa todos los objetos y parámetros requeridos por el Test.
	 */
	private static void inicializacionTest(){
		// Insertar objetos en la Base de Datos:
		system.debug('Test_SiniReparableConfirmacionController : inicializacionTest : Insertar objetos en la Base de Datos');

		Baipas.establecerVariableControl();
			// Cuenta Compañía:
			cia = Util_Tests.crearCuentaCompania('CIA','1018','X1234567X');
			cia.CUE_DIV_Limite_Actuacion__c = 200;
			insert cia;

			// Cuenta Asegurado:
			asegurado = Util_Tests.crearCuentaAsegurado('Asegurado','2018','asegurado@mail.com','73661110E','Sergio','Martínez','Manzano');
			asegurado.CUE_LKP_Cuenta_principal__c = cia.Id;
			insert asegurado;

			// Tipos de Producto de Compañía:
			tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa','01',cia.Id);
			insert tipoProductoCIA;

			// Productos de Compañía:
			productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
			insert productoCIA;

			// Pólizas de Contrato:
			poliza = Util_Tests.crearPolizaContrato('22',cia.Id,asegurado.Id,productoCIA.Id);
			insert poliza;

			// Casos:
			intervencion = Util_Tests.crearCasoSini(poliza.Id,asegurado.Id,cia.Id);
			intervencion.CAS_NUM_Id_Actuacion_SondeoExt__c = 1;
			intervencion.CAS_CAS_Siniestro_Grave__c = false;
			insert intervencion;

			// Comentarios de Caso:
			comentarioCaso = Util_Tests.crearComentarioCaso('Este es el comentario de la intervención',intervencion.Id);
			comentarioCaso.CMC_SEL_Tipo__c = '08';
			insert comentarioCaso;

			// Confirmaciones:
			confirmacion = new Confirmacion__c();
			confirmacion.cnf_lkp_parentid__c = intervencion.Id;
			confirmacion.CNF_CAS_Siniestro_Grave__c = true;
			insert confirmacion;

			// Tipos de Trabajo:
			tipoTrabajo = Util_Tests.crearTipoTrabajo('AIRE ACONDICIONADO','21',1.0);
			insert tipoTrabajo;

			// Órdenes de Trabajo:
			servicio = Util_Tests.crearOrdenTrabajo('1','21',tipoTrabajo.Id,intervencion.Id);
			insert servicio;

			// Comentarios de Orden de Trabajo:
			comentarioOT = Util_Tests.crearComentarioOT('Este es el comentario del servicio',servicio.Id);
			insert comentarioOT;

			// Citas de Servicio:
			citaServicio = Util_Tests.crearCitaServicio('Madrid','España','28050','España','Avenida Manoteras',Datetime.newInstance(2018,12,31),Datetime.newInstance(2019,12,31));
			citaServicio.ParentRecordId = servicio.Id;
			citaServicio.Status = Label.CIT_ESTADO_EN_CURSO;
			insert citaServicio;

			// Perfiles:
			perfilAdministrador = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_ADMINISTRADOR LIMIT 1];
			perfilProfesional = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL LIMIT 1];
			perfilGestor = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_GESTOR_FRONT_TRAMITACION LIMIT 1];

			// Usuarios:
			usuarioAdministrador = Util_Tests.nuevoUsuario('Apellido1_1 Apellido1_2','Admin','Admin@mail.com','Administrador','Admin',perfilAdministrador);
			usuarioProfesional = Util_Tests.nuevoUsuario('Apellido2_1 Apellido2_2','Prof','Prof@mail.com','Profesional','Profesional',perfilProfesional);
			usuarioGestor = Util_Tests.nuevoUsuario('Apellido3_1 Apellido3_2','Gestor','Gestor@mail.com','Gestor Tramitación','Gestor',perfilGestor);
			insert new List<User>{usuarioAdministrador,usuarioProfesional,usuarioGestor};

			// Actualizaciones:
			intervencion.OwnerId = usuarioProfesional.Id;
			update intervencion;
		Baipas.deshabilitarVariableControl();

		// Inicializar página y controlador:
		system.debug('Test_SiniReparableConfirmacionController : inicializacionTest : Inicializar página y controlador');

		Test.setCurrentPage(PAGINA_VISUALFORCE_EJECUCION);
		paginaActual = ApexPages.currentPage();
		sc = new ApexPages.StandardController(intervencion);
	}

	/**
	 * Método privado que realiza las acciones del flujo a probar logueado como un usuario especificado por parámetro.
	 *
	 * @param usuarioEjecutor: Objeto User que realiza la ejecución del flujo
	 */
	private static void ejecutarTestFlujo(User usuarioEjecutor){
		system.debug('Test_SiniReparableConfirmacionController : ejecutarTestFlujo : usuarioEjecutor : '+usuarioEjecutor);

		Test.startTest();
			System.runAs(usuarioEjecutor){
				// Setear los parámetros de la página:
				paginaActual.getParameters().put('numeroGremiosArbolSalida','0');
				paginaActual.getParameters().put('idConfirmacion',confirmacion.Id);
				paginaActual.getParameters().put('indice','1');
				paginaActual.getParameters().put('idOrdenTrabajo',servicio.Id);
				
				// Crear y setear el controlador:
				SiniReparableConfirmacionController controlador = new SiniReparableConfirmacionController(sc);
				
				// Testeo de la navegación a funcionalidades:
				controlador.insertarComentarioOrdenTrabajo();
				controlador.hacerOrdenTrabajoPrincipal();
				controlador.guardarConfirmacion();
				controlador.finalizarConfirmacionSalesforce();
				controlador.salirBorrarDatosSaleforce();
				
				// Testeo de la navegación a páginas:
				paginaActual = controlador.insertarComentarioPerito();
				paginaActual = controlador.vincularContactos();
				paginaActual = controlador.nuevoGremio();
				paginaActual = controlador.dormirOrdenDeTrabajo();
				paginaActual = controlador.anularOrdenDeTrabajo();
				paginaActual = controlador.habilidadesRequeridas();
				paginaActual = controlador.cambiarCita();
				paginaActual = controlador.actualizarPartidas();
				paginaActual = controlador.navegarDetalleCaso(intervencion);
				paginaActual = controlador.navegarConfirmacionFinalizada();
				paginaActual = controlador.navegarFinalizadaConfirmacion();
				paginaActual = controlador.salirInformarVesta();
			}
		Test.stopTest();
	}

	/**
	 * Testea el flujo como Gestor.
	 */
	@isTest
	public static void testFlujoGestor(){
		inicializacionTest();
		ejecutarTestFlujo(usuarioGestor);
	}

	/**
	 * Testea el flujo como Profesional.
	 */
	@isTest
	public static void testFlujoProfesional(){
		inicializacionTest();
		ejecutarTestFlujo(usuarioProfesional);
	}

	/**
	 * Testea el flujo como Administrador.
	 */
	@isTest
	public static void testFlujoAdministrador(){
		inicializacionTest();
		ejecutarTestFlujo(usuarioAdministrador);
	}
}