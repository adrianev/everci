@isTest
public without sharing class TRG_Handler_Reclamacion_IR_Test {

	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	
	public static void inicializarVariables(){

		Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1111111X');
		compania.Type = '01';
		insert compania;

		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '73661110E','Miguel', 'Sagrado', 'Velasco');
		asegurado.Type = '01';
		asegurado.CUE_lkp_cliente_contable__c = compania.id;
		asegurado.CUE_LKP_Cuenta_principal__c = compania.id;
		insert asegurado;

		Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;

		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;

		ServiceContract poliza = Util_Tests.crearPolizaContrato('15', compania.id, asegurado.id, productoCIA.id);

		Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        insert caso; 

        WorkType wt = Util_Tests.crearTipoTrabajo('Trabajo_Test','21',2.00);
        insert wt;

        WorkOrder wo = Util_Tests.crearOrdenTrabajo('10030399', '41', wt.Id, caso.id);
        wo.OTR_SEL_Gremio__c = '41';
        insert wo;

	}

	@isTest
	public static void Testing(){
		test.startTest();
		inicializarVariables();

		List<Account> cuenta = [SELECT Id, CUE_TXT_PrimerApellido__c, CUE_TXT_SegundoApellido__c, CUE_TXT_Numero_Documento__c, CUE_TXT_Nombre__c FROM Account WHERE CUE_TXT_Numero_Documento__c = 'X1111111X' AND  RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA)];

		List<Case> listaCasos = [SELECT Id, Status, CAS_CAS_Confirmado__c, CAS_SEL_Motivo_Indemnizable__c, CAS_TFN_Telefono_1__c, CaseNumber FROM Case WHERE CAS_LKP_Compania__c =: cuenta[0].Id];

		List<WorkOrder> listaOrdenesTrabajo = [SELECT Id, CaseId, WorkOrderNumber FROM WorkOrder LIMIT 20];

		TRG_Handler_MovimientoIR.actualizarOrdenTrabajo(listaOrdenesTrabajo);
		TRG_Handler_MovimientoIR.actualizaCuentaIR(cuenta);

		test.stopTest();

	}

}