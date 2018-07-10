/**
 * Clase de test de la clase Rest_B2C_CodigoActivacion
 * 
 */
@isTest public without sharing class Test_Rest_B2C_CodigoActivacion extends TestSetup{
	
	private static Account cuentaPrincipal {get;set;}
	private static Account cuentaSecundaria {get;set;}
    private static Baremo__c baremo {get;set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'R4803323G');
		cuentaPrincipal.CUE_CAS_Permite_Servicio_CodActivac__c = true;
		insert cuentaPrincipal;
		
		cuentaSecundaria = Util_Tests.crearCuentaB2BSec('B2BSecundaria', '1516268087741', cuentaPrincipal.Id,'S4489778C');
		cuentaSecundaria.Type = '01';
		insert cuentaSecundaria;
        
        baremo = new Baremo__c();
        baremo.BAR_LKP_Compania__c = cuentaPrincipal.Id;
        baremo.BAR_TXT_Codigo_Barra__c = '8435133620320';
        baremo.BAR_TXT_Identificador__c = 'ABEP';
        insert baremo;
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		
		Rest_B2C_CodigoActivacion.Resultado resultado = new Rest_B2C_CodigoActivacion.Resultado();
        
		//Caso OK
		resultado = Rest_B2C_CodigoActivacion.doPost(cuentaSecundaria.Id,'31','04','30500','Descripción Prueba',baremo.BAR_TXT_Identificador__c);
		//Caso KO. No existe el cliente
		resultado = Rest_B2C_CodigoActivacion.doPost('','31','04','30500','Descripción Prueba','');
		
		test.stopTest();
	}
	
}