@isTest
public without sharing class Test_B2B_LineaContrato_OT extends TestSetup {

	public static B2B_LineaContrato_OT b2bLineaContrato  {get; set;}  
	
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

	private static void inicializarVariables(){
		List<Account> listaCuentas = new List<Account>();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1114567X');
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
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		contrato = Util_Tests.crearContrato(cuenta.Id,'b2b_p_1');
		insert contrato;
		lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
		insert lineaContrato;
		direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id,lineaContrato.Id,3);
		insert direccionBB_lineas;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		insert ordenTrabajo;
	}

	@isTest static void testB2BLineaContratoVolver(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.B2B_LineaContrato_OT;
		Test.setCurrentPage(pageRef);
		ServiceContract poliza = Util_Tests.getServiceContractByName('2277393');
		Case caso = Util_Tests.getCaseById(poliza.Id);
		WorkOrder ordenTrabajo = Util_Tests.getWorkOrderByTXT('18210.0');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('solicitudExistente','N');
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('idOrdenTrabajo',ordenTrabajo.Id);

		System.assertEquals(ApexPages.currentPage().getParameters().get('solicitudExistente'), 'N');
		System.assertEquals(ApexPages.currentPage().getParameters().get('VDN'), '1018');
		System.assertEquals(ApexPages.currentPage().getParameters().get('idTabBusqClientes'), '01r9E0000000');
		System.assertEquals(ApexPages.currentPage().getParameters().get('retorno'), '/'+caso.Id);

		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		b2bLineaContrato = new B2B_LineaContrato_OT(stdc);

		System.assertNotEquals(b2bLineaContrato, null);
		System.assertEquals(b2bLineaContrato.fase, Label.SINI_FASE_APERTURA);
		System.assertEquals(b2bLineaContrato.caso.Id, caso.Id);
		System.assertEquals(b2bLineaContrato.ordenTrabajo.Id, ordenTrabajo.Id);
		System.assertEquals(b2bLineaContrato.gremio, ordenTrabajo.OTR_SEL_Gremio__c);

		b2bLineaContrato.volver();
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}

	@isTest static void testB2BLineaContrato(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.B2B_LineaContrato_OT;
		Test.setCurrentPage(pageRef);
		ServiceContract poliza = Util_Tests.getServiceContractByName('2277393');
		Case caso = Util_Tests.getCaseById(poliza.Id);
		WorkOrder ordenTrabajo = Util_Tests.getWorkOrderByTXT('18210.0');
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccion = Util_Tests.getDireccionB2B2CById(caso.AccountId);
		direccion.DLC_LKP_Linea_de_Contrato__r.LDC_LKP_Contrato__r.Status = 'Activo';
		direccion.DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Activo__c = true;
		update direccion;
		ordenTrabajo.OTR_LKP_Linea_Contrato__c = direccion.DLC_LKP_Linea_de_Contrato__c;
		update ordenTrabajo;
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('solicitudExistente','N');
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('idOrdenTrabajo',ordenTrabajo.Id);

		System.assertEquals(ApexPages.currentPage().getParameters().get('solicitudExistente'), 'N');
		System.assertEquals(ApexPages.currentPage().getParameters().get('VDN'), '1018');
		System.assertEquals(ApexPages.currentPage().getParameters().get('idTabBusqClientes'), '01r9E0000000');
		System.assertEquals(ApexPages.currentPage().getParameters().get('retorno'), '/'+caso.Id);

		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		b2bLineaContrato = new B2B_LineaContrato_OT(stdc);

		System.assertNotEquals(b2bLineaContrato, null);
		System.assertEquals(b2bLineaContrato.fase, Label.SINI_FASE_APERTURA);
		System.assertEquals(b2bLineaContrato.caso.Id, caso.Id);
		System.assertEquals(b2bLineaContrato.ordenTrabajo.Id, ordenTrabajo.Id);
		System.assertEquals(b2bLineaContrato.gremio, ordenTrabajo.OTR_SEL_Gremio__c);

		b2bLineaContrato.guardar();
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	} 

}