@isTest
public without sharing class Test_Batch_Elim_Bitacora {
    @isTest static void test_Elim_Bitacora(){
        //[Insert into RecordType (Id, Name) Values (Id.valueOf('123'), 'Servicio Web')];
        Account compania = Util_tests.crearCuentaCompania('compania','2000', 'X1234567X');
        Insert compania;
        Account acc=new Account();
        acc.CUE_TXT_Numero_Documento__c='12345678Z';
        acc.CUE_SEL_Tipo_Documento__c='P';
        acc.Name='Manolo';
        acc.CUE_LKP_CUENTA_PRINCIPAL__c = compania.id;
        insert acc;
        
        Batch_Elim_Bitacora bitacora=new Batch_Elim_Bitacora();
        Date hoy=Date.today().toStartOfMonth();
        bitacora.fechaLimite=hoy.addDays(10);
        bitacora.status='02';
       	bitacora.tipo= '0129E0000006EJyQAM';
        
        INT_Bitacora__c test=new INT_Bitacora__c();
        test.LastModifiedDate=hoy.addDays(2);//.addDays(29);
        test.CreatedDate=hoy;
        //test.
        test.RecordTypeId=bitacora.tipo;
        test.BIT_SEL_Estado__c=bitacora.status;
        
        test.BIT_SEL_Tipo_Integracion__c='02';
        
        insert test;
        
        bitacora.execute(null);
    }
}