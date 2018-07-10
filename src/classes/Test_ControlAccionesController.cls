/**
 * Clase de Test para la clase controladora ControlAccionesController.
 *
 * @author Everis
 */
@isTest 
public without sharing class Test_ControlAccionesController{

	private static Account cia;
	private static Account asegurado;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCIA;
	private static ServiceContract poliza;
	private static Case intervencion;
	private static Profile perfil;
	private static User usuarioAdmin;
	private static ApexPages.StandardController sc;

	/**
	 * Método privado que inicializa todos los objetos, parámetros y variables necesarios para el método de Test.
	 */
	private static void inicializacionTest(){
		Baipas.establecerVariableControl();
		cia = Util_Tests.crearCuentaCompania('CIA','1018','X1234567X');
		insert cia;
		asegurado = Util_Tests.crearCuentaAsegurado('Asegurado','2018','asegurado@mail.com','73661110E','Sergio','Martínez','Manzano');
		asegurado.CUE_LKP_Cuenta_principal__c=cia.Id;
		insert asegurado;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa','01',cia.Id);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('22',cia.Id,asegurado.Id,productoCIA.Id);
		insert poliza;
		intervencion = Util_Tests.crearCasoSini(poliza.Id,asegurado.Id,cia.Id);
		insert intervencion;
		perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_ADMINISTRADOR LIMIT 1];
		usuarioAdmin = Util_Tests.nuevoUsuario('Apellido1 Apellido2','Alias','Alias@mail.com','Nombre','Apodo',perfil);
		insert usuarioAdmin;
		Baipas.deshabilitarVariableControl();
		sc = new ApexPages.StandardController(intervencion);
		Test.setCurrentPage(Page.ControlAccionesEdit);
		ApexPages.currentPage().getParameters().put('retURL','/'+intervencion.Id);
	}

	/**
	 * Testea el controlador.
	 */
	@isTest
	public static void testControlador(){
		inicializacionTest();
		Test.startTest();
		System.runAs(usuarioAdmin){
			ControlAccionesController controlAcciones = new ControlAccionesController(sc);
			controlAcciones.navegacionControlAccion();
		}
		Test.stopTest();
	}
}