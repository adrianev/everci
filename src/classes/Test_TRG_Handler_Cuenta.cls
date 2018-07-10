@isTest
public without sharing class Test_TRG_Handler_Cuenta extends TestSetup{

   static testMethod void test_Handler_Cuenta(){
      Account profesional_1 = Util_Tests.crearCuentaAsegurado('Manolo','0000','manolo@gmail.es','20125974P','Manolo', 'Manolin', 'Manolazo');
      profesional_1.CUE_SEL_Tipo_Documento__c = 'N';
      Account profesional_ppal = Util_Tests.crearCuentaB2BPpal('Pepe','0003','X1234557X');
      insert profesional_ppal;
      String a = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Profesional Empresa').getRecordTypeId();
      profesional_1.RecordTypeId = a;
      insert profesional_1;
      profesional_1.CUE_SEL_Estado__c= '02';
      update profesional_1;
      update profesional_1;

        //profesional_1.CUE_TXT_Numero_Documento__c = '46748515J';
        Account profesional_2 = Util_Tests.crearCuentaAsegurado('PR000001','0001','profesional@gmail.es','89074907R','Paco', 'Paca', 'Pacu');   
        profesional_2.CUE_SEL_Tipo_Documento__c = 'N';
        profesional_2.CUE_LKP_CuentaPrincipalProf__c = profesional_ppal.Id;//profesional_1.Id;
        profesional_2.CUE_SEL_Tipo_de_Profesional__c='01';
        profesional_2.CUE_LKP_Cuenta_principal__c = null;
        insert profesional_2;
        String b = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Profesional Contrato').getRecordTypeId();
        profesional_2.RecordTypeId = b;
        profesional_2.CUE_SEL_Motivo_Baja_Temp__c = '9';
        profesional_2.CUE_TXT_Observaciones_BajaTemp__c = 'pepito';
        update profesional_2;
        update profesional_2;
        profesional_2.CUE_SEL_Motivo_Baja_Temp__c = '1';
        profesional_2.CUE_TXT_Observaciones_BajaTemp__c = 'Puf se tuvo que dar de baja';
        update profesional_2;
        update profesional_2;
        profesional_2.CUE_SEL_Motivo_Baja_Def__c = '9';
        profesional_2.CUE_TXT_Observaciones_BajaDef__c = 'Puf este si que sí tenía que irse';
        update profesional_2;
        update profesional_2;
        profesional_2.CUE_SEL_Estado__c = '02';
        profesional_2.CUE_CAS_Dada_de_Baja__c = false;
        update profesional_2;
        profesional_2.CUE_SEL_Estado__c = '03';
        profesional_2.CUE_CAS_Dada_de_Baja__c = true;
        update profesional_2;
        profesional_2.CUE_SEL_Estado__c = '04';
        profesional_2.CUE_CAS_Dada_de_Baja__c = true;
        update profesional_2;
        Account asegurado = Util_Tests.crearCuentaAsegurado('Manola','0002','manola@gmail.es','89074907R','Manola', 'Manolan', 'Manolozo');
        asegurado.CUE_SEL_Tipo_Documento__c = 'N';
        system.debug('Asegurado ' + asegurado.CUE_TXT_Numero_Documento__c);
        insert asegurado;
        asegurado.CUE_TXT_Identificador__c = '00001';
        asegurado.CUE_TXT_Numero_Documento__c = '38231074Z';
        update asegurado;

        Account asegurado2 = Util_Tests.crearCuentaAsegurado('Manola','0002','manola@gmail.es','12345677J','Manola', 'Manolan', 'Manolozo');
        asegurado2.CUE_SEL_Tipo_Documento__c = 'N';
        asegurado2.CUE_TXT_Numero_Documento__c = '12345677J';
        system.debug('Asegurado ' + asegurado2.CUE_TXT_Numero_Documento__c);
        insert asegurado2;

        Account profesional_3 = Util_Tests.crearCuentaAsegurado('PR000001','0001','profesional@gmail.es','89074907R','Paco', 'Paca', 'Pacu');   
        profesional_3.CUE_SEL_Tipo_Documento__c = 'N';
        profesional_3.CUE_LKP_CuentaPrincipalProf__c = profesional_ppal.Id;//profesional_1.Id;
        profesional_3.CUE_LKP_Cuenta_principal__c = null;
        insert profesional_3;        

        Account b2b_1 = new Account(Name = 'b2b principal', CUE_TXT_Identificador__c='8951891',RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1));  
        insert b2b_1;
        b2b_1.Name = 'b2b principal update';
        update b2b_1;
        Account b2b_2 = new Account(Name = 'b2b secundaria', CUE_TXT_Identificador__c='8951991',RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2), CUE_LKP_Cuenta_principal__c = b2b_1.Id,CUE_TXT_Numero_Documento__c = 'X1234567X', CUE_SEL_Tipo_Documento__c = 'C');  
        insert b2b_2;
        b2b_2.Name = 'b2b secundaria update';
        update b2b_2;
        b2b_2.Type = Label.CUE_TIPO_CONTABLE;
        update b2b_2;
        Account b2b_3 = new Account(Name = 'cliente contable',RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2), Type = Label.CUE_TIPO_CONTABLE, CUE_LKP_Cuenta_principal__c = b2b_1.Id,CUE_TXT_Numero_Documento__c = 'X4534042Y', CUE_SEL_Tipo_Documento__c = 'C');
        insert b2b_3;
        Account b2c_ppal = new Account(Name = 'cliente b2c ppal', RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2C_1),CUE_TXT_Identificador__c='B2C_8951891');
        insert b2c_ppal;
        Account cliParticular = new Account(CUE_TXT_Nombre__c = 'cliente particular',RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR), CUE_TXT_Numero_Documento__c = '90252651F', CUE_SEL_Tipo_Documento__c = 'N', CUE_LKP_Cuenta_principal__c = b2c_ppal.Id);
        insert cliParticular;
        Account profContrato = new Account(Name = 'PR000002',RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_PROFESIONAL_CONTRATO), CUE_TXT_Numero_Documento__c = 'D65119653', CUE_SEL_Tipo_Documento__c = 'C');
        profContrato.CUE_LKP_CuentaPrincipalProf__c = profesional_ppal.Id;//profesional_1.Id;
        profContrato.CUE_LKP_Cuenta_principal__c = null;
        profContrato.CUE_SEL_Tipo_de_Profesional__c='01';
        profContrato.CUE_CAS_Activado__c=false;
        insert profContrato;
    }
}