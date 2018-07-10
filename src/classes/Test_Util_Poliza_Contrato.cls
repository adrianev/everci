@isTest
public without sharing class Test_Util_Poliza_Contrato {

    static testMethod void util_Poliza_Contrato(){
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel', '2018','miguel@gmail.es', '46745581G','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
        asegurado.CUE_TXT_Numero_Documento__c='03522374Q';
        asegurado.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert asegurado;
		Date startDate = Date.newInstance(2016, 12, 31);
        Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.id);
        tipoProductoCIA.TPR_SEL_Interlocutores_Seleccionables__c = 'Administrador de la Finca';
        insert tipoProductoCIA;
        Producto_Cia__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('poliza', compania.Id, asegurado.Id, productoCIA.Id);
    	poliza.POL_LKP_Producto_Cia__c = productoCIA.Id;
        insert poliza;
        Callout_ConsultaPolizaVesta_RP resError =new Callout_ConsultaPolizaVesta_RP();
        List<ServiceContract> scList = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{poliza.Id}).values();
        //List<ServiceContract> scList = Util_Poliza_Contrato.queryMapPoliza('Id = \''+poliza.Id+'\'').values();
        //List<ServiceContract> scList = Util_Poliza_Contrato.queryPoliza(poliza.Id);
        ServiceContract nuevaPoliza = Util_Poliza_Contrato.nuevaPoliza(resError, asegurado.Id);
        List<SelectOption> so = Util_Poliza_Contrato.cargarSelectorTipoInterlocutor(poliza);
        List<SelectOption> so1 = Util_Poliza_Contrato.cargarSelectorTipoRiesgo(poliza, null);
    }
}