@isTest 
public without sharing class Test_DormirReclamacion{

	private static Account compania;
	private static Account asegurado;
	private static Account cuenta;
	private static Account cuentaPrincipal;
	private static Tipo_Producto_CIA__c tipoProducto;
	private static Producto_CIA__c producto;
	private static ServiceContract sv;
	private static Case caso;
	private static DormirReclamacion dr;

	static void InicializarVariables(){
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1114567X');
		insert cuenta;
		tipoProducto = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		system.debug('@@@@@@@@@@@ '+tipoProducto);
		insert tipoProducto;
		producto = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProducto.Id);
		insert producto;

		sv = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,producto.Id);
		insert sv;
		asegurado = Util_Tests.crearCuentaAsegurado('ClienteMembership','132456','prueba@prueba.es','15809766A','María','García','Montes');
		asegurado.Type = '01';
		asegurado.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert asegurado;
		caso = Util_Tests.crearCasoB2B(sv.Id, cuentaPrincipal.Id, compania.Id);
		cuenta.CUE_LKP_Cuenta_principal__c=compania.Id;
		caso.CAS_LKP_Cliente_contable_cliente__c=asegurado.Id;
		insert caso;
		Baipas.deshabilitarVariableControl();
	}

	@isTest
	public static void DormirReclamacionConId(){
		InicializarVariables();
		pruebaPage(caso);
	}
	
	@isTest
	public static void DormirReclamacionSinId(){
		Case caso = new Case();
		pruebaPage(caso);
	}

	@isTest
	public static void GuardarConFechaDespertar(){
			  
		InicializarVariables();

		caso.CAS_DAT_Fecha_Despertar__c = Date.today();
		update caso;

		pruebaPage(caso);

	}

	@isTest
	public static void GuardarConFechaConComentarioCorto(){
	   
		InicializarVariables();

		caso.CAS_DAT_Fecha_Despertar__c = Date.today();
		update caso;

		dr = pruebaPage2(caso);

		dr.comentario.CMC_TXT_Comentario__c = '123';
		dr.guardar();

	}

	@isTest
	public static void GuardarConFechaConComentarioLargo(){
	   
		InicializarVariables();

		caso.CAS_DAT_Fecha_Despertar__c = Date.today();
		update caso;

		dr = pruebaPage2(caso);

		dr.comentario.CMC_TXT_Comentario__c = '123456789012345';
		dr.guardar();
	}

	@isTest
	public static void GuardarConFechaConComentarioErrorCaso(){
	   
		InicializarVariables();

		caso.CAS_DAT_Fecha_Despertar__c = Date.today();
		update caso;

		dr = pruebaPage2(caso);

		dr.comentario.CMC_LKP_Caso__c = null;
		dr.comentario.CMC_TXT_Comentario__c = '123456789012345';
		dr.guardar();
	}

	@isTest
	public static void GuardarConFechaConComentarioErrorOT(){
	   
		InicializarVariables();

		caso.CAS_DAT_Fecha_Despertar__c = Date.today();
		update caso;

		dr = pruebaPage2(caso);
		dr.comentario.CMC_TXT_Comentario__c = '122222222222222222222223';
		dr.controlador = null;
		dr.guardar();
	}

	static void pruebaPage( Case caso){
		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(caso);
		PageReference pageRef = Page.DormirReclamacion;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',caso.id);
		
		DormirReclamacion dr = new DormirReclamacion(sc);
		dr.guardar();

		Test.stopTest();

	}

	static DormirReclamacion pruebaPage2( Case caso){
		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(caso);
		PageReference pageRef = Page.DormirReclamacion;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',caso.id);
		
		DormirReclamacion dr = new DormirReclamacion(sc);

		Test.stopTest();
		return dr;

	}
	
}