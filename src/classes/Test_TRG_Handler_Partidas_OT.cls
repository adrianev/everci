@isTest
public without sharing class Test_TRG_Handler_Partidas_OT{

	private static Account cuentaCompania {get; set;}
	private static Account cuentaAsegurado {get; set;}
	private static Account cuentaB2BSec {get; set;}
	private static Account cuentaB2BPrincipal {get; set;}
	private static Account profesional {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static Contract contrato {get; set;}
	private static Linea_Contrato__c lineaContrato {get; set;}
	private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
	private static ServiceResource recursoServ {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static User user {get; set;}
	private static Account cuentaPrincipalProf {get;set;}
	private static Case siniestro {get; set;}

	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaB2BPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1018','X1234567X');
		//insert cuentaB2BPrincipal;
		cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1019','X1134567X');
		cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1021','email@gmail.es','41847655Y','nombre','apellido1','apellido2');
		cuentaB2BSec = Util_Tests.crearCuentaB2BSec('SegurCaixa2','1020',cuentaB2BPrincipal.Id,'X1114567X');
		cuentaPrincipalProf = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','2002','X1134567X');
		insert cuentaPrincipalProf;
		profesional = Util_Tests.crearCuentaProfesionalContrato('SegurCaixa2','1020','X1114567X',cuentaPrincipalProf.Id);
		profesional.CUE_SEL_Estado__c = '01';
		profesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        profesional.Name='PR123456';
		insert profesional;
		profesional.CUE_SEL_Estado__c = '02';
		update profesional;
		insert cuentaCompania;
		cuentaAsegurado.CUE_LKP_Cuenta_Principal__c = cuentaCompania.Id;
		insert cuentaAsegurado;
		//insert cuentaB2BSec;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.id);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('9729187',cuentaCompania.Id,cuentaAsegurado.Id,productoCIA.Id);
		insert poliza;
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,profesional.Id,'101801','CAS_Siniestro');
		procedencia.Name = Label.IDE_PROCEDENCIA_HOMESERVE;
		procedencia.PROC_LKP_Cuenta__c = cuentaAsegurado.Id;
		insert procedencia;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		contrato = Util_Tests.crearContrato(cuentaAsegurado.Id,'b2b_p_1');
		insert contrato;
		lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
		lineaContrato.LDC_LKP_Tipo_Trabajo__c = tipoTrabajo.Id;
		insert lineaContrato;
		caso = Util_Tests.crearCasoReclamacion(poliza.Id,profesional.Id,cuentaCompania.Id);
		caso.CAS_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		caso.CAS_LKP_Procedencia__c = procedencia.Id;
		insert caso;
		direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(profesional.Id,lineaContrato.Id,3);
		direccionBB_lineas.DLC_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		//insert direccionBB_lineas;
		user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Account prof = [SELECT Id, Name, CUE_TXT_Identificador__c FROM Account WHERE id=:profesional.Id];
		recursoServ = Util_Tests.crearRecursoServicio('Recurso de Servicio', '000000', profesional.Id , user);
        recursoServ.Name = prof.CUE_TXT_Identificador__c + '_01_1';
		insert recursoServ;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = recursoServ.Id;
		ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = false;
		insert ordenTrabajo;
		
		siniestro = Util_Tests.crearCasoSini(poliza.Id, cuentaPrincipalProf.Id, cuentaPrincipalProf.Id);
		insert siniestro;
		Baipas.deshabilitarVariableControl();
	}
	
	@isTest static void testPartidasOT() {
		Test.startTest();
		inicializarVariables();
		WorkOrderLineItem partidaOT = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
		partidaOT.Status = Label.PAR_ESTADO_EN_CURSO_PROF;
		partidaOT.PAR_LKP_Imputar_a_prof1__c = recursoServ.Id;
		partidaOT.PAR_DIV_Importe_a_Imputar_prof1__c = 0;
		partidaOT.PAR_LKP_Imputar_a_prof2__c = recursoServ.Id;
		partidaOT.PAR_DIV_Importe_a_Imputar_prof2__c = 0;
		partidaOT.PAR_LKP_Imputar_a_prof3__c = recursoServ.Id;
		partidaOT.PAR_DIV_Importe_a_Imputar_prof3__c = 0;
		partidaOT.PAR_LKP_Imputar_a_gestor1__c = user.Id;
		partidaOT.PAR_DIV_Importe_a_Imputar_gestor1__c = 0;
		partidaOT.PAR_LKP_Imputar_a_gestor2__c = user.Id;
		partidaOT.PAR_DIV_Importe_a_Imputar_gestor2__c = 0;
		partidaOT.PAR_LKP_Imputar_a_gestor3__c = user.Id;
		partidaOT.PAR_DIV_Importe_a_Imputar_gestor3__c = 0;
        /*partidaOT.PAR_POR_Porcentaje_Imp_Cia_Cliente__c = 20;
        partidaOT.PAR_DIV_Cargar_Comp_AI__c = 240;*/
		insert partidaOT;
		partidaOT.Status = label.PAR_ESTADO_ACEPTADA_POR_PERITO_CIA;
		Baipas.establecerVariableControl();
		upsert partidaOT;
		Baipas.deshabilitarVariableControl();
		//delete partidaOT;
		Test.stopTest();
	}
	
	//Método test para probar el fragmento de Facturador;
	@isTest static void ActualizaImportesPartidasOT(){
		Test.startTest();
		inicializarVariables();
		Baipas.establecerVariableControl();
		ordenTrabajo.CaseId = siniestro.Id;
		update ordenTrabajo;
		Baipas.deshabilitarVariableControl();
		WorkOrderLineItem partidaOT = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
		partidaOT.Status = Label.PAR_ESTADO_EN_CURSO_PROF;
		partidaOT.PAR_DIV_Cargar_Cliente_AI__c = 11.65;
		insert partidaOT;
		partidaOT.PAR_DIV_Cargar_Cliente_AI__c = 13.25;
		update partidaOT;
		Test.stopTest();
	}
	
}