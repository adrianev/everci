/**
 * Clase de Test de la Clase CNT_CustomPop
 * 
 */
@isTest
public without sharing class Test_CNT_CustomPop{
	 private static Task tarea;
	 private static Account asegurado;
	 private static Account cuentaPrincipal;
	 private static Account compania;
	 private static ServiceContract poliza;
	 private static VDN_Compania__c vdn;
	 private static Case caso;
     private static Case caso2;
	 private static Tipo_Producto_CIA__c tipoProductoCIA;
	 private static Producto_CIA__c productoCIA;
	 private static WorkType wt;
	 private static WorkOrder wo;
	
	private static void inicializarVariables(){
		 Baipas.establecerVariableControl();
		 tarea= new Task();
		 tarea.TAR_DAT_Fin_Llamada__c=DateTime.now().addDays(1);
		 insert tarea;
		 List<Account> listaCuentas = new List<Account>();
		 compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		 cuentaPrincipal= Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		 listaCuentas.add(compania);
		 listaCuentas.add(cuentaPrincipal);
		 insert listaCuentas;
		 asegurado = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1234567X');
		 insert asegurado;
		 tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		 insert tipoProductoCia;
		 productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		 poliza = Util_Tests.crearPolizaContrato('Alberto', asegurado.Id, cuentaPrincipal.Id, productoCIA.Id);
		 insert poliza;
		 vdn = Util_Tests.crearVDNCompania('6000', asegurado.Id);
		 insert vdn;
		 caso = Util_Tests.crearCasoB2B(poliza.Id, asegurado.Id, compania.Id);
		 insert caso;
         caso2 = Util_Tests.crearCasoB2B(poliza.Id, asegurado.Id, compania.Id);
		 insert caso2;
         caso2.Status = Label.CAS_ESTADO_CERRADO;
		 caso2.Type=Label.CAS_TIPO_CORRECTIVO;
		 update caso2;
		 caso.Status = Label.CAS_ESTADO_CERRADO;
		 caso.Type=Label.CAS_TIPO_CORRECTIVO;
		 update caso;
		 wt = Util_Tests.crearTipoTrabajo('Rotura de bajante/tubería empotrada', '01', 120.0);
		 insert wt;
		 wo = Util_Tests.crearOrdenTrabajo('0000000545','01',wt.Id,caso.Id);
		 insert wo;
		 Baipas.ejecutarTrigger();
	}
	
	@isTest static void test1(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
        System.debug('@@@@userId ' + UserInfo.getUserId());
        List<CaseHistory> ch= new List<CaseHistory>([SELECT CaseId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue FROM CaseHistory]);
        System.debug('@@@@CaseHistory:'+ch);
        System.debug('@@@@Tarea: '+ tarea);
		PageReference pageRef = Page.customPop;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('sources','{"opened":["'+caso.Id+'","'+wo.Id+'","'+caso2.Id+'"],"match":["'+caso.Id+'","'+wo.Id+'","'+caso2.Id+'"]}');
		ApexPages.currentPage().getParameters().put('VDN','6000');
		ApexPages.currentPage().getParameters().put('callType','OUTBOUND');
		ApexPages.currentPage().getParameters().put('dnis','666777888');
		ApexPages.currentPage().getParameters().put('taskid',tarea.Id);
		CNT_CustomPop cnt = new CNT_CustomPop();
		cnt.updateCallData();
		Baipas.ejecutarTrigger();
		Test.stopTest();
	 }
	@isTest static void test2(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.customPop;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','6000');
		ApexPages.currentPage().getParameters().put('callType','INBOUND');
		ApexPages.currentPage().getParameters().put('ani','666777888');
		ApexPages.currentPage().getParameters().put('taskid',tarea.Id);
		CNT_CustomPop cnt = new CNT_CustomPop();
		cnt.updateCallData();
		Baipas.ejecutarTrigger();
		Test.stopTest();
	 }
	
	
}