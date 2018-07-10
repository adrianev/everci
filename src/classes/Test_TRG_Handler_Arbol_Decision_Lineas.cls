@isTest
public class Test_TRG_Handler_Arbol_Decision_Lineas {
	@isTest static void test1(){

		Account compania=Util_Tests.crearCuentaCompania('Name','12345','X1234567X');
		insert compania;

		Tipo_Producto_CIA__c tpc=new Tipo_Producto_CIA__c();
		tpc.TPR_LKP_Compania__c=compania.Id;
		tpc.TPR_LKP_Compania__r=compania;
		insert tpc;

		Producto_CIA__c pc=Util_Tests.crearProductoCIA('nombre','12345',tpc.id);
		insert pc;

		Arbol_Decision__c ad=new Arbol_Decision__c();
		ad.ADC_LKP_Producto_CIA__r=pc;
		ad.ADC_LKP_Producto_CIA__c=pc.id;
		insert ad;

		Arbol_Decision_Lineas__c adl=new Arbol_Decision_Lineas__c();
		adl.ADL_LKP_Arbol_Decision__r=ad;
		adl.ADL_LKP_Arbol_Decision__c=ad.Id;

		insert adl;

		update adl;
	}
}