@isTest
public without sharing class Test_BATCH_Limites_Recurso_Mensual{

    
    static testMethod void LimitesRecursoMensualTest(){
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('Julian','1018','X1234567X');
        Insert cuentaPrincipal;
        RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        Account acc=Util_Tests.crearCuentaAsegurado('RP123456', 'RP123456', 'email', '12345678Z', 'PR123456', 'primerApellido', 'segundoApellido');   
        acc.CUE_SEL_Tipo_de_Profesional__c = '01';
        acc.CUE_EMA_Email__c='test@email.com';
        acc.CUE_TXT_Identificador__c='RP123456';
        acc.RecordTypeId = rt.Id;
        acc.Name = 'PR123456';
        acc.CUE_LKP_Cuenta_principal__c = Null;
        acc.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        insert acc;
        acc.CUE_SEL_Estado__c = '02';
        update acc;
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :acc.Id ];
        
        ServiceResource service = new ServiceResource();
        service.RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c = 5;
        service.RSE_LKP_Cuenta__c=acc.Id;
        service.RelatedRecordId = '0050Y000001ay50QAA';
        service.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        service.RSE_TXT_Codigo_Recurso__c = '1242141';
        insert service;
        
        Test.startTest();

            BATCH_Limites_Recurso_Mensual obj = new BATCH_Limites_Recurso_Mensual();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}