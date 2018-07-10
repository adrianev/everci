/**
 * Clase de Test de la Clase Callout_Actualizar_Check_Robin
 * @author everis
 * @version 1.0
 **/
@isTest
public without sharing class Test_Actualizar_Check_Robin{
	
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		
		compania = Util_Tests.crearCuentaCompania('Membership','1999','R8720258F');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('MEMBERSHIP - Hogar','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('MEMBERSHIP - MEMBERSHIP SINIESTROS','01',tipoProductoCIA.Id);
		insert productoCIA;

	}
	
	/*Test cuando se inserta un contacto*/
	@isTest static void TestOK1(){
		inicializarVariables();
		test.startTest();
		
		Baipas.deshabilitarVariableControl();
		cuenta = Util_Tests.crearCuentaAsegurado('ClienteMembership', '132456', 'prueba@prueba.es', '15809766A',
			'María', 'García', 'Montes');
		cuenta.CUE_CAS_Robinson__c = false;
		cuenta.CUE_LKP_CUENTA_PRINCIPAL__c = compania.id;
		insert cuenta;
		
		Baipas.establecerVariableControl();
		poliza = Util_Tests.crearPolizaContrato('8899767', compania.Id, cuenta.Id,productoCIA.Id);
		poliza.POL_TXT_Cliente_Ensura__c = '26983233';
		upsert poliza;
		
		Baipas.deshabilitarVariableControl();
		cuenta.CUE_CAS_Robinson__c = true;
		update cuenta;
		
		test.stopTest();
	}
	
}