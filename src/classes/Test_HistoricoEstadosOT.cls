/**
 * Clase de Test de la Clase controladora HistoricoEstadosOT
 * 
 */
@isTest
public class Test_HistoricoEstadosOT {
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account cuenta {get; set;}
    private static Account cuentaProfesional {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static Poblacion__c poblacion {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static Contract contrato {get; set;}
	private static Linea_Contrato__c lineaContrato {get; set;}
	private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
    private static WorkOrderLineItem lineaOrdenTrabajo {get; set;}
    private static ServiceResource profesional {get; set;}
    private static User usuari {get; set;}
    
    private static ServiceResource sresource {get; set;}
    
	@isTest static void Test_HistoricoEstadosOT() {
		inicializarVariables();
		Baipas.deshabilitarVariableControl();

		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(ordenTrabajo);
		HistoricoEstadosOT historico = new HistoricoEstadosOT(stdc);
		HistoricoEstadosOT.EntradaHistoricoEstado estadoHistorico = new HistoricoEstadosOT.EntradaHistoricoEstado('test','test',system.now(),system.now(),'test','test');
		/*estadoHistorico.estado = 'test';
		estadoHistorico.estadoAPI = 'test';
		estadoHistorico.fechaInicio = system.now();
		estadoHistorico.fechaFin = system.now();
		estadoHistorico.usuarioInicio = 'test';
		estadoHistorico.perfilUsuarioInicio = 'test';*/
		//estadoHistorico.EntradaHistoricoEstado(estadoHistorico.estado,estadoHistorico.estadoAPI,estadoHistorico.fechaInicio,estadoHistorico.fechaFin,estadoHistorico.usuarioInicio
						//						,estadoHistorico.perfilUsuarioInicio);
		Test.stopTest();
	}
	
    private static void inicializarVariables(){
    	Baipas.establecerVariableControl();
    	List<Account> listaCuentas = new List<Account>();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
		insert cuentaPrincipal;
        cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',compania.Id);
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.id;
        cuentaProfesional.CUE_LKP_Cuenta_principal__c = Null;
		insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuari;
        Account cuentaProfesional2 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :cuentaProfesional.Id ];
        profesional = Util_Tests.crearRecursoServicio('PR11047_02_2','72819283',cuentaProfesional.Id,usuari);
        profesional.Name = cuentaProfesional2.CUE_TXT_Identificador__c + '_01_1';
        profesional.RSE_SEL_Gremio__c='01';
        insert profesional;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1021',cuentaPrincipal.Id,'X1111567X');
		listaCuentas.add(compania);
		listaCuentas.add(cuenta);
		insert listaCuentas;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;
		poliza = Util_tests.crearPolizaContrato('10', cuentaPrincipal.id, cuenta.id, productoCIA.id);
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta.Id,'101801','CAS_Siniestro');
		insert procedencia;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, cuentaPrincipal.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		sresource = Util_Tests.crearRecursoServicio('PR11047_12_11', '72819283E' , cuentaProfesional.Id, usuari);
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,sresource.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		ordentrabajo.CaseId = caso.Id;
		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = sresource.Id; 
		insert ordenTrabajo;
		system.debug('>>>>>MostrarOT: ' + ordenTrabajo);
		WorkOrderHistory historia = new WorkOrderHistory();
		historia.WorkOrderId = ordenTrabajo.Id;
		historia.Field = 'Status';
		insert historia;
    }	
}