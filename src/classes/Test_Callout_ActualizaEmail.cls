/**
 * Clase de Test de la Clase Callout_ActualizaEmail
 *  @author everis 
 **/
@isTest
public without sharing class Test_Callout_ActualizaEmail {
	private static Callout_ActualizaEmail Actualizar {get;set;}
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Contact contacto {get;set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('Membership','1999','X1234567X');
		insert compania;
		cuenta = Util_Tests.crearCuentaAsegurado('ClienteMembership', '132456', 'prueba@prueba.es', '12345678Z',
			'María', 'García', 'Montes');
		cuenta.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('MEMBERSHIP - Hogar','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('MEMBERSHIP - MEMBERSHIP SINIESTROS','01',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_tests.crearPolizaContrato('10', compania.id, cuenta.id, productoCIA.id);
		insert poliza;
		poliza.POL_TXT_Cliente_Ensura__c = '26983233';
		update poliza;
	}
	
	
	/*Test cuando se inserta un contacto*/
	@isTest static void TestOK1(){
		inicializarVariables();
		test.startTest();
		
		Baipas.deshabilitarVariableControl();
		contacto = Util_Tests.crearContacto('Prueba','Callout_ActualizaEmail');
		contacto.AccountId = cuenta.Id;
		contacto.Email = 'pruebaInicioCall@prueba.com';
		contacto.CON_EMA_Email_Adicional__c = 'emailAdicionalPruebaInicioCall@prueba.com';
		insert contacto;
		
		contacto.Email = 'pruebaUpdateCall@prueba.com';
		update contacto;
		
		contacto.CON_EMA_Email_Adicional__c = 'emailAdicionalPruebaUpdateCall@prueba.com';
		update contacto;
		
		test.stopTest();
	}
	
}