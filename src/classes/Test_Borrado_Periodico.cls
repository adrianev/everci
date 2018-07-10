@isTest
public class Test_Borrado_Periodico {
	private static testMethod void testBatch(){
		Account compania = Util_Tests.crearCuentaCompania('compania1', '1042','X1234567X');
		compania.Type = '01';
		insert compania;
		Account cuenta = Util_Tests.crearCuentaB2BPpal('Name','12345', 'X1234567X');
		cuenta.CUE_LKP_Cuenta_Principal__c = compania.id;
		cuenta.CUE_LKP_Cliente_Contable__c = compania.id;
		cuenta.Type = '01';
        insert cuenta;
        Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('nombre','01', compania.Id);
        insert tipoProducto;
        Producto_CIA__c producto = Util_Tests.crearProductoCIA('nombre','1234',tipoProducto.Id);
        insert producto;
        ServiceContract sv = Util_Tests.crearPolizaContrato('nombre', compania.Id, cuenta.Id, producto.Id);
        insert sv;
		Case caso = Util_Tests.crearCasoB2B(sv.Id,cuenta.Id,compania.Id);
		insert caso;
		
		List<INT_Movimiento_CIA__c> movList = new List<INT_Movimiento_CIA__c>();
		INT_Movimiento_CIA__c m = new INT_Movimiento_CIA__c();
		m.MOV_TXT_Tipo_Movimiento__c = '1';
		m.MOV_LKP_Cliente__c=compania.Id;
		m.MOV_LKP_Caso__c = caso.Id;
		m.MOV_TXT_Desc_Error__c= 'Elemento sólo para cobertura de test';
		movList.add(m);
		//INT_Movimiento_CIA__c m = new INT_Movimiento_CIA__c(MOV_TXT_Desc_Error__c= 'Elemento sólo para cobertura de test');
		insert movList;
		Datetime fechaVieja = Datetime.now().addDays(-3);
		Test.setCreatedDate(m.Id, fechaVieja);
		Borrado_Periodico bec = new Borrado_Periodico();
		bec.execute(null);
	}
}