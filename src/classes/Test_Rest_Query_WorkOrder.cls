@isTest
public without sharing class Test_Rest_Query_WorkOrder {
	@isTest
	public static void testUtil(){
        baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
        cuentaPrincipal.Type = '01';
        insert cuentaPrincipal;
        Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
        cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
        cuenta.Type = '01';
        insert cuenta;
        
		Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		Case caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.id, cuentaPrincipal.Id);
		caso.CAS_TXT_Identificador__c = '678576897';
		insert caso;
        
		WorkOrder w = new WorkOrder();

		w.Description = 'Cambio tubería';
		//w.DurationType = '120';
		//w.OTR_CAS_Foto_Requerida__c = true;
		//w.OTR_SEL_Gremio__c = 'Carpinteria';
		w.OTR_TXT_Num_OrdenTrabajo_HS__c = '122';
		w.Priority ='Low';
		w.Status = 'ok';
		w.Case = caso;
		w.Account = cuenta;

		insert w;
		baipas.deshabilitarVariableControl();
		Rest_Query_WorkOrder.doGet();
	}
}