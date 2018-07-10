@isTest
public without sharing class Test_TRG_Handler_Propuesta_de_Abono {

	private static Profile perfil;
	private static User usuario;
	private static User usuario2;
	private static Account compania;
	private static Account cuentaPrincipal;
	private static Account cuentaProfesionalPrincipal;
	private static Account cuentaProfesional;
	private static ServiceResource recursoServ;
	private static ServiceResource recursoServ2;
	private static Account cuentaSec;
	private static Account cuentaAsegurado;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCia;
	private static ServiceContract poliza;
	private static Case casoB2B;
	private static Case casoSini;
	private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo;
	private static Propuesta_de_Abono__c propAbono;

	private static void inicializarVariables(){
		List<Account> listaCuentas = new List<Account>();
		perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_GESTOR_FRONT_TRAMITACION];
		Profile perfil2 = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_GESTOR_FRONT_TRAMITACION];

		usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;
		usuario2 = Util_Tests.nuevoUsuario('pruebas2','pruebas2','asdd2@hotmail.com','pruebas2','pruebas2',perfil2);
		insert usuario2;

		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		cuentaProfesionalPrincipal = Util_Tests.crearCuentaB2C('PR123456','PR123456','X1234568X');

		listaCuentas.add(compania);
		listaCuentas.add(cuentaPrincipal);
		listaCuentas.add(cuentaProfesionalPrincipal);
		insert listaCuentas;

		cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR636325','PR636325','X1234567X',cuentaProfesionalPrincipal.id);
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01'; //AUTONOMO
		listaCuentas.add(cuentaProfesional);
		upsert listaCuentas;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		upsert listaCuentas;

		recursoServ = Util_Tests.crearRecursoServicio('PR636325_01_1', '00000', cuentaProfesional.Id, usuario);
		recursoServ.RSE_LKP_Cuenta__r = cuentaProfesional;
		insert recursoServ;

		recursoServ2 = Util_Tests.crearRecursoServicio('PR636325_01_2', '00001', cuentaProfesional.Id, usuario2);
		recursoServ2.isActive = true;
		insert recursoServ2;

		cuentaSec=Util_Tests.crearCuentaB2BSec('Name','13132', cuentaPrincipal.Id, 'X5544663X');
		listaCuentas.add(cuentaSec);

		cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1021','email@gmail.es','03629033R','nombre','apellido1','apellido2');
		cuentaAsegurado.CUE_LKP_CUENTA_Principal__c = cuentaPrincipal.id;
		listaCuentas.add(cuentaAsegurado);
		upsert listaCuentas;

		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		insert tipoProductoCIA;

		productoCia=Util_Tests.crearProductoCIA('nombre','01', tipoProductoCIA.Id);
		insert productoCia;

		poliza=Util_Tests.crearPolizaContrato('4523814',compania.Id, cuentaPrincipal.Id, productoCia.Id);
		insert poliza;

		createCaseSini();

		tipoTrabajo = Util_Tests.crearTipoTrabajo('Siniestro', '21', 2.5);
		insert tipoTrabajo;

		ordenTrabajo = Util_Tests.crearOrdenTrabajo('26032018', '75', tipoTrabajo.id, casoSini.Id);
		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = recursoServ.id;
		Test.startTest();
		insert ordenTrabajo;

	}

	private static void createCaseSini(){
		poliza.AccountId = cuentaAsegurado.id;
		update poliza;

		casoSini = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,cuentaPrincipal.Id);
		casoSini.CAS_TXT_Nombre__c = 'casoEvento';
		casoSini.CAS_DIV_Total_Facturar_Cliente_AI__c = 101.00;
		casoSini.CAS_DIV_Total_Facturar_Profesional__c = 101.00;
		insert casoSini;
		
	}

	@isTest static void insertarAbono(){		
		inicializarVariables();		
																				
		Propuesta_de_Abono__c propAbono = new Propuesta_de_Abono__c(AB_SEL_Estado__c = '04', AB_SEL_Descripcion_evento__c = 'E12');
		propAbono.AB_LKP_Caso__c = casoSini.Id;
		propAbono.AB_LKP_Cuenta__c = cuentaAsegurado.Id;
		propAbono.AB_LKP_Imputar_a__c = usuario.Id;
		propAbono.AB_DIV_Importe_a_Imputar__c = 1;
		propAbono.AB_LKP_Imputar_a2__c = usuario.Id;
		propAbono.AB_DIV_Importe_a_Imputar2__c = 1;
		propAbono.AB_LKP_Imputar_a3__c = usuario.Id;
		propAbono.AB_DIV_Importe_a_Imputar3__c = 1;
		propAbono.AB_LKP_Imputar_a4__c = recursoServ.Id;
		propAbono.AB_DIV_Importe_a_Imputar4__c = 1;
		propAbono.AB_LKP_Imputar_a5__c = recursoServ.Id;
		propAbono.AB_DIV_Importe_a_Imputar5__c = 1;
		propAbono.AB_LKP_Imputar_a6__c = recursoServ.Id;
		propAbono.AB_DIV_Importe_a_Imputar6__c = 1;
		propAbono.AB_DIV_Importe_a_ingresar__c = 1;
		propAbono.AB_LKP_Ingresar_a__c = casoSini.AccountId;
		insert propAbono;

		propAbono.AB_SEL_Estado__c = '02';
		propAbono.AB_LKP_Caso__c = casoSini.Id;
		propAbono.AB_LKP_Cuenta__c = cuentaAsegurado.Id;
		propAbono.AB_CAS_Abono_Liquidado__c = true;
		propAbono.AB_LKP_Imputar_a2__c = usuario2.Id;
		propAbono.AB_LKP_Imputar_a3__c = usuario2.Id;
		propAbono.AB_LKP_Imputar_a5__c = recursoServ2.Id;
		propAbono.AB_LKP_Imputar_a6__c = recursoServ2.Id;
		update propAbono;

		Test.stopTest();
	}
	@isTest static void insertarAbono2(){

		inicializarVariables();

		Propuesta_de_Abono__c propAbono2 = new Propuesta_de_Abono__c(AB_SEL_Estado__c = '01', AB_SEL_Descripcion_evento__c = 'E12');
		propAbono2.AB_LKP_Caso__c = casoSini.Id;
		propAbono2.AB_CAS_Abono_Liquidado__c = false;
		propAbono2.AB_SEL_Estado__c = Label.EV_AB_ESTADO_APROBADO;
		propAbono2.AB_LKP_Imputar_a2__c = usuario.Id;
		propAbono2.AB_DIV_Importe_a_Imputar2__c = 1;
		propAbono2.AB_LKP_Imputar_a4__c = recursoServ.Id;
		propAbono2.AB_DIV_Importe_a_Imputar4__c = 1;
		propAbono2.AB_DIV_Importe_a_ingresar__c = 1;
		propAbono2.AB_LKP_Ingresar_a__c = casoSini.AccountId;

		insert propAbono2;
		
		propAbono2.AB_CAS_Abono_Automatico__c = false;
		propAbono2.AB_CAS_Abono_Liquidado__c = true;
		propAbono2.AB_SEL_Estado__c = Label.EV_AB_ESTADO_NUEVO;
		update propAbono2;
		
		Test.stopTest();
	}
	//El método de facturarAbono sólo se utiliza en la clase TRG_Handler_Propuesta_de_Abono, y no es invocada desde ninguna clase
	@isTest static void facturarAbono(){
		
		Case casoEvento = new Case();
		WorkOrder ordenTrabajoEvento = new WorkOrder();
		Account cuentaAbono = new Account();
		
		inicializarVariables();
		
		Propuesta_de_Abono__c propAbono = new Propuesta_de_Abono__c(AB_SEL_Estado__c = '02', AB_SEL_Descripcion_evento__c = 'E12');
		
		propAbono.AB_LKP_Orden_de_Trabajo__c = ordenTrabajoEvento.Id;
		propAbono.AB_LKP_Caso__c = casoEvento.Id;
		propAbono.AB_LKP_Cuenta__c = cuentaAbono.Id;
		propAbono.AB_CAS_Abono_Liquidado__c = true;
		propAbono.AB_LKP_Imputar_a__c = usuario.Id;
		propAbono.AB_DIV_Importe_a_Imputar__c = 50;
		propAbono.AB_LKP_Imputar_a2__c = usuario.Id;
		propAbono.AB_DIV_Importe_a_Imputar2__c = 50;
		propAbono.AB_LKP_Imputar_a3__c = usuario.Id;
		propAbono.AB_DIV_Importe_a_Imputar3__c = 50;
		propAbono.AB_LKP_Imputar_a4__c = recursoServ.Id;
		propAbono.AB_DIV_Importe_a_Imputar4__c = 50;
		propAbono.AB_LKP_Imputar_a5__c = recursoServ.Id;
		propAbono.AB_DIV_Importe_a_Imputar5__c = 50;
		propAbono.AB_LKP_Imputar_a6__c = recursoServ.Id;
		propAbono.AB_DIV_Importe_a_Imputar6__c = 50;
		propAbono.AB_DIV_Importe_a_ingresar__c = 300;		
		Baipas.establecerVariableControl();
		insert propAbono;
		Baipas.deshabilitarVariableControl();
		
		List<Propuesta_de_Abono__c> ListaAbonos = new List<Propuesta_de_Abono__c>();
		ListaAbonos.add(propAbono);
		
		List<String> listaRespuesta = new List<String>(TRG_Handler_Propuesta_de_Abono.facturarAbono(ListaAbonos));
		Test.stopTest();
	}
	
}