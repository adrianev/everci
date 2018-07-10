@isTest
public without sharing class Test_TRG_Handler_Propuesta_de_Evento {
	
	private static Profile perfil;
	private static User usuario;
	private static Account compania;
	private static Account cuentaPrincipal;
	private static Account cuentaProfesionalPrincipal;
	private static Account cuentaProfesional;
	private static ServiceResource recursoServ;
	private static Account cuentaSec;
	private static Account cuentaAsegurado;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCia;
	private static ServiceContract poliza;
	private static Case casoSini;
	private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo;
	private static Propuesta_de_Abono__c propAbono;

	private static void inicializarVariables(){
		List<Account> listaCuentas = new List<Account>();
		perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_GESTOR_FRONT_TRAMITACION];
		
		usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;

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
		
		propAbono = new Propuesta_de_Abono__c();
		propAbono.AB_SEL_Estado__c = '04';
		propAbono.AB_LKP_CASO__c = casoSini.id;
        propAbono.AB_LKP_Imputar_a__c = usuario.id;
        propAbono.AB_LKP_Ingresar_a__c  = casoSini.AccountId;
        propAbono.AB_DIV_Importe_a_Imputar__c = 50;
        propAbono.AB_SEL_Descripcion_evento__c = 'E11';
        propAbono.AB_DIV_Importe_a_ingresar__c = 50;
        propAbono.AB_LKP_Imputar_a4__c = ordenTrabajo.OTR_LKP_Recurso_Servicio__c;
        propAbono.AB_DIV_Importe_a_Imputar4__c = 1;
        insert propAbono;
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

	@isTest static void insertarEvento(){

		
		inicializarVariables();

		List<Propuesta_de_Evento__c> listaEventos = new List<Propuesta_de_Evento__c>();

		Propuesta_de_Evento__c propEvent1 = Util_Tests.crearPropuestaDeEvento('04', casoSini.id, ordenTrabajo.id);
		listaEventos.add(propEvent1);
		
		Propuesta_de_Evento__c propEvento = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = casoSini.Id);
		propEvento.EV_AB_SEL_Descripcion__c = 'E01';
		propEvento.EV_AB_LKP_Orden_de_Trabajo__c = ordenTrabajo.Id;
		listaEventos.add(propEvento);

		Propuesta_de_Evento__c propEvento4 = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = casoSini.Id);
		propEvento4.EV_AB_SEL_Descripcion__c = 'E23';
		propEvento4.EV_AB_LKP_Orden_de_Trabajo__c = ordenTrabajo.Id;
		listaEventos.add(propEvento4);

        insert listaEventos;
        Propuesta_de_Evento__c propEvento3 = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = casoSini.Id);
        propEvento3.EV_AB_SEL_Descripcion__c = 'E39';
        propEvento3.EV_AB_LKP_Orden_de_Trabajo__c = ordenTrabajo.Id;
        propEvento3.EV_AB_LKP_Propuesta_de_Evento_Economico__c = propEvento4.Id;
        propEvento3.EV_AB_DIV_Importe_a_liquidar_prof__c = 50;
        listaEventos.add(propEvento3);

        Propuesta_de_Evento__c propEvento28 = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = casoSini.Id);
        propEvento28.EV_AB_SEL_Descripcion__c = 'E28';
        propEvento28.EV_AB_DIV_Importe_profesional__c = 50;
        propEvento28.CreatedDate = system.now();
        propEvento28.EV_AB_LKP_Propuesta_de_Evento_Economico__c = propEvento4.Id;
        listaEventos.add(propEvento28);
        
        Propuesta_de_Evento__c propEvento35 = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = casoSini.Id);
        propEvento35.EV_AB_SEL_Descripcion__c = 'E35';
        propEvento35.EV_AB_LKP_Propuesta_de_Evento_Economico__c = propEvento4.Id;
        propEvento35.EV_AB_DIV_Importe_a_liquidar_prof__c = 50;
        listaEventos.add(propEvento35);

        upsert listaEventos;

        Test.stopTest();
    }
    
    @isTest static void updateEvento(){

    	inicializarVariables();

    	Propuesta_de_Evento__c propEvento = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = casoSini.Id);
        propEvento.EV_AB_SEL_Descripcion__c = 'E01';
        propEvento.EV_AB_LKP_Orden_de_Trabajo__c = ordenTrabajo.Id;
		propEvento.EV_AB_TXT_Identificador__c = '13042018';
		insert propEvento;
		
		propEvento.EV_AB_SEL_Estado__c = '02';
		propEvento.EV_AB_CAS_Evento_Ab_Facturado__c = true;
		propEvento.EV_AB_LKP_Orden_de_Trabajo__c = ordenTrabajo.Id;
		propEvento.EV_AB_LKP_Abono__c = propAbono.Id;
		
		update propEvento;
        Test.stopTest();
	}
	
}