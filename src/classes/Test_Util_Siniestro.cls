@isTest
public without sharing class Test_Util_Siniestro extends TestSetup{

private static Account cuentaCompania {get; set;}
	private static Account cuentaAsegurado {get; set;}
	private static Account cuentaB2BSec {get; set;}
	private static Account cuentaB2BPrincipal {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case casoB2B {get; set;}
	private static Case casoSini {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static Contract contrato {get; set;}
	private static Linea_Contrato__c lineaContrato {get; set;}
	private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account cuenta {get; set;}
    private static Account cuentaProfesional {get; set;}
	private static Poblacion__c poblacion {get; set;}
	private static Case caso {get; set;}
	private static ServiceResource profesional {get; set;}
	private static User usuari {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Procedencia__c procedencia2 {get; set;}
	
	private static void inicializarVariablesCaso(){
		Baipas.establecerVariableControl();
    	List<Account> listaCuentas = new List<Account>();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1019','X6712867H');
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1244678','H55668339');
		compania.CUE_TXT_Numero_Documento__c = 'X6712867H';
		cuentaPrincipal.CUE_TXT_Numero_Documento__c = 'D83027490';
		insert cuentaPrincipal;
        //cuentaProfesional = Util_Tests.crearCuentaB2BPpal('CuentaProf','134556','64568580J');
        //cuentaProfesional.CUE_TXT_Numero_Documento__c = '73187345B';
        //NEW
        cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','PR123456', 'R7242335C', cuentaPrincipal.Id);
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        
		insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;
		system.debug('>>>>>VerPerfiles: ' + [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR]);
        Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Gestor Front/Tramitacion'];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuari;
        profesional = Util_Tests.crearRecursoServicio(cuentaProfesional.Name+'_02_1','Estanislao',cuentaProfesional.Id,usuari);
        insert profesional;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','07387263P',cuentaPrincipal.Id);
        cuenta.CUE_TXT_Numero_Documento__c = '75384689G';
        cuenta.CUE_SEL_Tipo_Documento__c = 'N';
		listaCuentas.add(compania);
		listaCuentas.add(cuenta);
		insert listaCuentas;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta.Id,'101801','CAS_Siniestro');
		insert procedencia;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
		insert caso;		
	}
	
	private static void inicializarVariables(){
		cuentaB2BPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','S0782027G');
		insert cuentaB2BPrincipal;
		cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','H09059288');
		cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','19883886E',null,null,null,null,null);
		cuentaB2BSec = Util_Tests.crearCuentaB2BSec('SegurCaixa2','12453267Y',cuentaB2BPrincipal.Id);
		cuentaCompania.CUE_TXT_Numero_Documento__c = 'X1631059Z';
		cuentaAsegurado.CUE_TXT_Numero_Documento__c = '04613070Y';
		cuentaB2BSec.CUE_TXT_Numero_Documento__c = '10652701K';
        cuentaB2BSec.CUE_SEL_Tipo_Documento__c = 'N';
		insert cuentaCompania;
		cuentaAsegurado.CUE_LKP_Cuenta_principal__c = cuentaCompania.Id;
		insert cuentaAsegurado;
		insert cuentaB2BSec;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.id);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',cuentaCompania.Id,cuentaB2BSec.Id,productoCIA.Id);
		upsert poliza;
		procedencia2 = Util_Tests.crearProcedencia(0,0,0,0,0,cuentaB2BSec.Id,'101802','CAS_Siniestro');
		procedencia2.Name = Label.IDE_PROCEDENCIA_HOMESERVE;
		insert procedencia2;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		contrato = Util_Tests.crearContrato(cuentaB2BSec.Id,'b2b_p_1');
		insert contrato;
		lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
		lineaContrato.LDC_LKP_Tipo_Trabajo__c = tipoTrabajo.Id;
		insert lineaContrato;
		//casoB2B = Util_Tests.crearCasoB2B(poliza.Id,cuentaB2BSec.Id,cuentaCompania.Id);
		//casoB2B.CAS_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		//casoB2B.CAS_LKP_Procedencia__c = procedencia.Id;
		casoSini = Util_Tests.crearCasoB2B(poliza.Id,cuentaAsegurado.Id,cuentaCompania.Id);
		casoSini.CAS_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		casoSini.CAS_LKP_Procedencia__c = procedencia2.Id;
		casoSini.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
		//insert casoB2B;
		insert casoSini;
		direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuentaB2BSec.Id,lineaContrato.Id,3);
		direccionBB_lineas.DLC_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,casoSini.Id);
		ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
		insert ordenTrabajo;
	}

	@isTest static void testUtil(){
		Baipas.establecerVariableControl();
		inicializarVariables();
		Util_Siniestro.finalizarAperturaSiniestro(casoSini);
		Util_Siniestro.esSiniestro(casoSini);
		Case caso = Util_Siniestro.obtenerHijoSiniestroMixto(casoSini.Id);
		Case caso2 = Util_Siniestro.heredarDireccionRiesgoPoliza(casoSini,poliza);
		Boolean validacion = Util_Siniestro.validarCondicionesSiniGrave(casoSini);
		Baipas.deshabilitarVariableControl();
	}
	
	@isTest static void testUtil1(){
		Baipas.establecerVariableControl();
		String ret;
		ret = Util_Siniestro.devolverTipoActuacion('1',null);
		ret = Util_Siniestro.devolverTipoActuacion('2',null);
		ret = Util_Siniestro.devolverTipoActuacion('3',null);
		ret = Util_Siniestro.devolverTipoActuacion('4',null);
		ret = Util_Siniestro.devolverTipoActuacion('11',null);
	}
	
	@isTest static void testUtil2(){
		Baipas.establecerVariableControl();
		inicializarVariablesCaso();
		Util_Siniestro.finalizarAperturaSiniestro(caso);
		Util_Siniestro.finalizarConfirmacionSiniestro(caso);
		Util_Siniestro.validarCondicionesSiniGrave(caso);
		Util_Siniestro.cancelarAperturaSiniestro(caso);
		Util_Siniestro.partidasObligatoriasReparable(caso);
		Util_Siniestro.esSiniestro(caso);
		Util_Siniestro.comprobacionSondeo(caso);
		Util_Siniestro.terceroModificado(caso,caso);
	}		
	
	
	@isTest static void testUtil3(){
		Baipas.establecerVariableControl();
		inicializarVariablesCaso();
		inicializarVariables();
		Case c1 = Util_Tests.crearCasoB2B(poliza.Id,cuenta.Id,cuentaCompania.Id);
		c1.Parent = casoSini;
		insert c1;
		//Util_Siniestro.queryCaso(c1.Id,casoSini.Id,1);
	}
}