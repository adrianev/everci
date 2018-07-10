@isTest
public without sharing class Test_CTI_Dispatcher {

	@testSetup
	public static void test(){
		Test.startTest();
		Baipas.establecerVariableControl();
		List<Account> listaCuentas = new List<Account>();
		Account cuenta = new Account();
		
		listaCuentas.add(Util_Tests.crearCuentaB2BPpal('CuentaB2B','1000','X1234567X'));
		listaCuentas.add(Util_Tests.crearCuentaCompania('CuentaCIA','1001','X1134567X'));
		cuenta = Util_Tests.crearCuentaB2BPpal('CuentaB2C','1002','X1114567X');
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2C_1);
		listaCuentas.add(cuenta);
		cuenta = Util_Tests.crearCuentaB2BPpal('CuentaHS','1003','X1111567X');
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA_HS);
		listaCuentas.add(cuenta);
		insert listaCuentas;
		List<VDN_Compania__c> listaVDN = new List<VDN_Compania__c>();
		listaVDN.add(Util_Tests.crearVDNCompania('60000', listaCuentas.get(0).Id));
		listaVDN.add(Util_Tests.crearVDNCompania('60001', listaCuentas.get(1).Id));
		listaVDN.add(Util_Tests.crearVDNCompania('60002', listaCuentas.get(2).Id));
		listaVDN.add(Util_Tests.crearVDNCompania('60003', listaCuentas.get(3).Id));
		insert listaVDN;
		WorkType wt = Util_Tests.crearTipoTrabajo('Rotura de bajante/tubería empotrada', '01', 120.0);
        insert wt;
		WorkOrder wo = Util_Tests.crearOrdenTrabajo('1234567890','01', wt.Id,null);
		insert wo;
		Baipas.ejecutarTrigger();
		Test.stopTest();
	}

	static testMethod void testB2BconVDN() {
        CTI_DispatcherException de = new CTI_DispatcherException();
        de.CTI_DispatcherExcepctionMET();
		PageReference pageRef = Page.CTI_Dispatcher;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','60000');
		ApexPages.currentPage().getParameters().put('UUI','11223344W');
		Test.startTest();
		Baipas.establecerVariableControl();
		CTI_Dispatcher cti = new CTI_Dispatcher();
		cti.redireccion();
		Baipas.ejecutarTrigger();
		Test.stopTest();
	}

	static testMethod void testCIAconVDN() {
		PageReference pageRef = Page.CTI_Dispatcher;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','60001');
		ApexPages.currentPage().getParameters().put('UUI','11223344W!60001!666666666!1234567890');
		Test.startTest();
		Baipas.establecerVariableControl();
		CTI_Dispatcher cti = new CTI_Dispatcher();
		cti.redireccion();
		Baipas.ejecutarTrigger();
		Test.stopTest();
	}

	static testMethod void testB2CconVDN() {
		PageReference pageRef = Page.CTI_Dispatcher;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','60002');
		Test.startTest();
		Baipas.establecerVariableControl();
		CTI_Dispatcher cti = new CTI_Dispatcher();
		cti.redireccion();
		Baipas.ejecutarTrigger();
		Test.stopTest();
	}
	static testMethod void testHSconVDN() {
		PageReference pageRef = Page.CTI_Dispatcher;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','60003');
		ApexPages.currentPage().getParameters().put('calltype','OUTBOUND');
		List<WorkOrder> woList = new List<WorkOrder>([Select Id,WorkOrderNumber FROM WorkOrder]);
		ApexPages.currentPage().getParameters().put('data1',woList.get(0).WorkOrderNumber);
		Test.startTest();
		Baipas.establecerVariableControl();
		CTI_Dispatcher cti = new CTI_Dispatcher();
		cti.redireccion();
		Baipas.ejecutarTrigger();
		Test.stopTest();
	}
}