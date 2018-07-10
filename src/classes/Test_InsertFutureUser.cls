@isTest
public class Test_InsertFutureUser {

    static testMethod void insertFutureUser(){
        Account cuentaPrinc = Util_Tests.crearCuentaB2BPpal('Cuenta Principal 1','Ident_Cuen1','X1234567X');
    	insert cuentaPrinc;
        Contact contacto = Util_Tests.crearContacto('Otro Cuenta Principal', 'Otro Cuenta Principal', cuentaPrinc.Id ,'Ident_Cont2');
        insert contacto;
        InsertFutureUser.insertUser(contacto.Id);
    }
}