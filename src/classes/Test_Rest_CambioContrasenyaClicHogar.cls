/**
 * Clase de Test de la Clase Rest_CambioContrasenyaClicHogar
 *
 * @author EVERIS
 *
 */

@isTest
public without sharing class Test_Rest_CambioContrasenyaClicHogar {
	
	public static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuenta = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X1234567X');
		insert cuenta;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoSini(poliza.Id, cuenta.Id, compania.Id);
		caso.CAS_TXT_Usuario_Clic_Hogar__c = '101810';
		caso.CAS_TXT_Password_Clic_Hogar__c = '5009E000007J82s';
		insert caso;
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		
		List<Case> infoCaso = [SELECT CAS_TXT_Usuario_Clic_Hogar__c, CAS_TXT_Password_Clic_Hogar__c FROM Case WHERE Id =: caso.Id];
		
		Rest_CambioContrasenyaClicHogar_RP resultado = new Rest_CambioContrasenyaClicHogar_RP();
		resultado = Rest_CambioContrasenyaClicHogar.doPatch(infoCaso[0].CAS_TXT_Usuario_Clic_Hogar__c,'Cambio34Contra',infoCaso[0].CAS_TXT_Password_Clic_Hogar__c);
		resultado = Rest_CambioContrasenyaClicHogar.doPatch(infoCaso[0].CAS_TXT_Usuario_Clic_Hogar__c,'Cambio34Contra','56787654');
		
		test.stopTest();
	}
}