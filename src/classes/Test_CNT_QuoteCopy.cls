@isTest
public class Test_CNT_QuoteCopy {

    private static Account cuentaPrincipal {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static Case caso1 {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
    private static WorkOrder ordenTrabajo1 {get; set;}
    
    @isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'G8425767D');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','S2787313B');
        compania.CUE_LKP_Cuenta_principal__c = cuentaPrincipal.Id; 
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;

		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', compania.Id, cuentaPrincipal.Id, productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		insert caso;
		caso1 = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		insert caso1;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;		
        ordenTrabajo1 = Util_Tests.crearOrdenTrabajo('20210.0','21',tipoTrabajo.Id,caso1.Id);
		ordenTrabajo1.AccountId = cuentaPrincipal.Id;
		ordenTrabajo1.Status = '323';
		insert ordenTrabajo1;
        ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '997';
        //ordenTrabajo.OTR_SEL_Categoria_del_profesional__c = 'Franquiciado';
        ordenTrabajo.OTR_CAS_Confianza_en_la_red__c = true;
        ordenTrabajo.OTR_CAS_AplicaRevision__c = false;
        ordenTrabajo.ParentWorkOrderId = ordenTrabajo1.Id;
		insert ordenTrabajo;
		
	}
    static testMethod void cntQuoteCopy(){
     	inicializarVariables();
        PageReference pageRef = Page.QuoteCopy;
		Test.setCurrentPage(pageRef); 
        pageRef.getParameters().put('idWorkO', ordenTrabajo.Id);
        pageRef.getParameters().put('retorno', 'google.es');
        CNT_QuoteCopy cnt = new CNT_QuoteCopy();
        cnt.aplicaFranquiciado = true;
        cnt.caso = caso;
        cnt.woId = ordenTrabajo.Id;
        cnt.cuenta = cuentaPrincipal;
        Boolean resp = CNT_QuoteCopy.woHasQuote(ordenTrabajo.Id);
        cnt.volver();
        cnt.volverDialogo();
        cnt.checkCambioPartidas();
    }
}