@isTest
public without sharing class Test_TRG_Handler_Contacto {

	private static List<Contact> listaContactos {get;set;}

 	 @isTest static void testtratamientoBeforeInsert(){
 	 	Test.startTest();
 	 	inicializarVariables();
 	 	TRG_Handler_Contacto.tratamientoBeforeInsert(listaContactos);
 	 	

 	 	Test.stopTest();
 	 }
    
    private static void inicializarVariables(){
    	List<Account> listaCuentas = new List<Account>();
        
		Date startDate = Date.newInstance(2016, 12, 31);

        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
        insert compania;

        Account cuentaPrinc = Util_Tests.crearCuentaB2BPpal('Cuenta Principal 1','Ident_Cuen1','X1234567X');
        insert cuentaPrinc;    
    	listaCuentas.add(cuentaPrinc);
        
        ServiceContract poliza = Util_Tests.crearPolizaContrato('9729187', compania.Id, cuentaPrinc.Id , null);
        poliza.POL_TXT_Cliente_Ensura__c = 'Ensura';
        insert poliza;

    	Account cuentaSecun = Util_Tests.crearCuentaB2BSec('Cuenta Secundaria 1','Ident_Cuen2',cuentaPrinc.Id,'X1134567X');
    	insert cuentaSecun;
    	listaCuentas.add(cuentaSecun);

    	listaContactos = new List<Contact>();
    	Contact contacto1 = Util_Tests.crearContacto('Nombre Cuenta Principal', 'Apellido Cuenta Principal', cuentaPrinc.Id ,'Ident_Cont1');
    	contacto1.CON_CAS_Contacto_principal__c=true;
    	contacto1.MobilePhone='623456789';
    	contacto1.Phone='678954321';
    	contacto1.HomePhone='987654321';
        contacto1.Email = 'albertosolermatas@gmail.com';
        contacto1.CON_EMA_Email_Adicional__c = contacto1.Email;
    	Contact contacto2 = Util_Tests.crearContacto('Otro Cuenta Principal', 'Otro Cuenta Principal', cuentaPrinc.Id ,'Ident_Cont2');
    	Contact contacto4 = Util_Tests.crearContacto('Otro1 Cuenta Principal', 'Otro1 Cuenta Principal', cuentaPrinc.Id ,null);
    	Contact contacto3 = Util_Tests.crearContacto('Nombre Cuenta Secundaria', 'Apellido Cuenta Secundaria', cuentaSecun.Id ,'Ident_Cont3');
    	listaContactos.add(contacto1);
    	listaContactos.add(contacto2);
		listaContactos.add(contacto3);
		listaContactos.add(contacto4);
    	insert listaContactos;

    	delete contacto2;
    	contacto1.HomePhone='910156473';
    	contacto1.MobilePhone='683928163';
    	contacto1.Phone='674039173';
    	update contacto1;
    }
}