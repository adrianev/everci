@isTest
public without sharing class Test_RSE_Vista_Profesional {

    @isTest() static void RSE_Vista_Profesional(){
        Account compania = Util_tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
        insert compania;
        RecordType rt =[SELECT Id,Name FROM RecordType WHERE Name = 'Profesional Contrato'];
        Account cuenta = Util_Tests.crearCuentaB2BPpal('PR123456', '1458','X1234567X');
        cuenta.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuenta.RecordTypeId = rt.Id;
        cuenta.CUE_LKP_Cuenta_principal__c = Null;
        cuenta.CUE_LKP_CuentaPrincipalProf__c = compania.Id; 
		insert cuenta;
        cuenta.CUE_SEL_Estado__c = '02';
        update cuenta;
        
        Account acc = [SELECT Name, id,CUE_TXT_Identificador__c FROM Account WHERE id=:cuenta.id ];
        
        User us = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        ServiceResource sr =  Util_Tests.crearRecursoServicio(cuenta.CUE_TXT_Identificador__c+'123456_01_01', 'PRMPM', cuenta.Id, us);
        sr.Name = acc.CUE_TXT_Identificador__c + '_01_1';
        insert sr;
        
        RSE_Vista_Profesional vista = new RSE_Vista_Profesional();
        vista.irFichaProfesional();
    }
}