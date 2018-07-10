@isTest
public without sharing class Test_Callout_ConsultaSiniestroOcaso {
    private static Account cuentaProfesionalContrato {get; set;}
    private static Account compania {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
    private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}


    
    @isTest 
    static void Callout_ConsultaSiniestroOcaso(){
     compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X'); 
     insert compania;
     cuentaProfesionalContrato = Util_Tests.crearCuentaAsegurado('Laura','xxxxxx', 'laura@laura.com', '23017462M', 'rayo', 'kiko', 'hdez');
     cuentaProfesionalContrato.CUE_LKP_Cuenta_Principal__c = compania.id;
     insert cuentaProfesionalContrato;
     tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
	 insert tipoProductoCIA;
     productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
	 insert productoCIA;
     poliza = Util_tests.crearPolizaContrato('10', compania.id, cuentaProfesionalContrato.id, productoCIA.id);
	 insert poliza;
     Case caso = new Case();
     caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaProfesionalContrato.Id, compania.Id);
	 insert caso; 

     Callout_ConsultaSiniestroOcaso.updateCase();
        
    }

}