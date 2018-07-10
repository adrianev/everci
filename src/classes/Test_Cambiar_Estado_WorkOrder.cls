@isTest
public without sharing class Test_Cambiar_Estado_WorkOrder {

    private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account cuenta {get; set;}
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
    
    @testSetup
    static void setup() {
    	List<Account> listaCuentas = new List<Account>();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		compania.Type = '01';
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1114567X');
		cuenta.Type = '01';
		listaCuentas.add(compania);
		listaCuentas.add(cuenta);
		insert listaCuentas;
		cuenta.CUE_LKP_Cuenta_Principal__c = compania.id;
		cuenta.CUE_LKP_Cliente_Contable__c = compania.id;
		update cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;
		poliza = Util_tests.crearPolizaContrato('10', compania.id, cuenta.id, productoCIA.id);
		insert poliza;
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta.Id,'101801','CAS_Siniestro');
		insert procedencia;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		contrato = Util_Tests.crearContrato(cuenta.Id,'b2b_p_1');
        contrato.CTR_TXT_Identificador__c = '5635463';
		insert contrato;
		lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
		insert lineaContrato;
		direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id,lineaContrato.Id,3);
		insert direccionBB_lineas;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		insert ordenTrabajo;
    	
    }
    
    static testmethod void test() {
        PageReference pageRef = Page.Cambiar_Estado_WorkOrder_al_pulsar_boton;
        Test.setCurrentPage(pageRef);
        system.assertEquals(pageRef.getURL(), '/apex/cambiar_estado_workorder_al_pulsar_boton');
        WorkOrder ordenTrabajo = Util_Tests.getWorkOrderByTXT('18210.0');
		List<WorkOrder> listWO = new List<WorkOrder>();
		listWO.add(ordenTrabajo);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listWO);
        sc.setSelected(listWO);
        Cambiar_Estado_WorkOrder_al_pulsar_boton cambio = new Cambiar_Estado_WorkOrder_al_pulsar_boton(sc);
        cambio.revisionAutoWorkOrders();
        cambio.updateWorkOrders();
        cambio.volver();
    }
    
    
    static testmethod void test1() {
        PageReference pageRef = Page.Cambiar_Estado_WorkOrder_al_pulsar_boton;
        Test.setCurrentPage(pageRef);
        WorkOrder ordenTrabajo = Util_Tests.getWorkOrderByTXT('18210.0');
        ordenTrabajo.status  = Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO;
		List<WorkOrder> listWO = new List<WorkOrder>();
		listWO.add(ordenTrabajo);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listWO);
        sc.setSelected(listWO);
        Cambiar_Estado_WorkOrder_al_pulsar_boton cambio = new Cambiar_Estado_WorkOrder_al_pulsar_boton(sc);
        cambio.revisionAutoWorkOrders();
        //pageReference pag = cambio.updateWorkOrders();
        cambio.volver();
    }
    
    
}