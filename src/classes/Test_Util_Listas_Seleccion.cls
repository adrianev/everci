@isTest
public without sharing class Test_Util_Listas_Seleccion {

	private static Account cuentaCompania {get; set;}
	private static Account cuentaAsegurado {get; set;}
	private static Account cuentaB2BSec {get; set;}
	private static Account cuentaB2BPrincipal {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static Contract contrato {get; set;}
	private static Linea_Contrato__c lineaContrato {get; set;}
	private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}

	private static void inicializarVariables(){
		cuentaB2BPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaB2BPrincipal;
		cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert cuentaCompania;
		cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Miguel', '2018','miguel@gmail.es', '89074907R','Miguel', 'Sagrado', 'Velasco');
		cuentaAsegurado.CUE_SEL_Tipo_Documento__c = 'N';
		cuentaAsegurado.CUE_LKP_Cuenta_principal__c = cuentaCompania.Id;
        cuentaB2BSec = Util_Tests.crearCuentaB2BSec('SegurCaixa2','12453267Y',cuentaB2BPrincipal.Id,'X2234567X');
		insert cuentaAsegurado;
		insert cuentaB2BSec;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.id);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('poliza', cuentaCompania.Id, cuentaB2BSec.Id, productoCIA.Id);
        insert poliza;
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuentaB2BSec.Id,'101801','CAS_Siniestro');
		procedencia.Name = Label.IDE_PROCEDENCIA_HOMESERVE;
		insert procedencia;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		contrato = Util_Tests.crearContrato(cuentaB2BSec.Id,'b2b_p_1');
		insert contrato;
		lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
		lineaContrato.LDC_LKP_Tipo_Trabajo__c = tipoTrabajo.Id;
		insert lineaContrato;
		caso = Util_Tests.crearCasoB2B(poliza.Id,cuentaB2BSec.Id,cuentaCompania.Id);
		caso.CAS_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		caso.CAS_LKP_Procedencia__c = procedencia.Id;
		insert caso;
		direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuentaB2BSec.Id,lineaContrato.Id,3);
		direccionBB_lineas.DLC_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
		insert ordenTrabajo;
	}

    @isTest static void testUtil(){
    	Baipas.establecerVariableControl();
    	inicializarVariables();
        Map<String, String> mapaString = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Gremio__c');
        String valor = Util_Listas_Seleccion.getValorAPIDesdeLabel('WorkOrder','Status',Label.OTR_ESTADO_REVISADO);
        List<String> campos = new List<String>{'OTR_SEL_Gremio__c','OTR_SEL_Incidente_Facturacion__c','OTR_SEL_Modo_de_pago__c'};
        Util_Listas_Seleccion.corregirListasSeleccion(ordenTrabajo,campos);
        String cadena = Util_Listas_Seleccion.limpiarAcentos('ÁÉÍÓÚÜ');
        Util_Listas_Seleccion.corregirListasDecision(ordenTrabajo,campos);
        Util_Listas_Seleccion.createService('Sesion1');
        Set<String> valores = new Set<String>{'01','20','16'};
        Map<String, Set<String>> nuevosValoresPickList = new Map<String, Set<String>>();
        nuevosValoresPickList.put('OTR_SEL_Gremio__c',valores);
        Util_Listas_Seleccion.createPicklistField('WorkOrder',JSON.serialize(nuevosValoresPickList),UserInfo.getSessionId());
        Baipas.deshabilitarVariableControl();
    }
}