@isTest
public without sharing class Test_BATCH_Festivos {

    static testMethod void festivoNacionalTest(){
        
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('Julian','1018','X1234567X');
        Insert cuentaPrincipal;
        RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        
        Account acc=Util_Tests.crearCuentaAsegurado('RP123456', 'RP123456', 'email', '12345678Z', 'PR123456', 'primerApellido', 'segundoApellido');   
        acc.CUE_SEL_Tipo_de_Profesional__c = '01';
        acc.CUE_EMA_Email__c='test@email.com';
        acc.CUE_TXT_Identificador__c='RP123456';
        acc.RecordTypeId = rt.Id;
        acc.CUE_SEL_Direccion_Territorial__c = 'a7';
        acc.Name = 'PR123456';
        acc.CUE_LKP_Cuenta_principal__c = Null;
        acc.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        system.debug('ID CUENTA'+acc.CUE_TXT_Identificador__c);
        insert acc;
		acc.CUE_SEL_Estado__c = '02';
        update acc;
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :acc.Id ];
        
        
        
        
        Profesional_Gremio__c profGrem = new Profesional_Gremio__c();
       	profGrem.PRG_LKP_Cuenta_Profesional__c=acc1.Id;
       	profGrem.PRG_TXT_Identificador__c='j40dg49alnf194j';
       	profGrem.PRG_NUM_Lim_OT_en_Curso__c=2;
       	profGrem.PRG_SEL_Gremio__c='21';
       	insert profGrem;
        ServiceResource serv = new ServiceResource();
        serv.IsActive = true;
        serv.RSE_LKP_Cuenta__c=acc.Id;
        serv.RSE_SEL_Gremio__c='01'; 
        serv.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        serv.RelatedRecordId = UserInfo.getUserId();
        serv.RSE_TXT_Codigo_Recurso__c = '1242141';
        serv.RSE_LKP_Profesional_Gremio__c=profGrem.Id;
        insert serv;
        
        String tipoBatch = 'Festivos';
        Festivos__c festivo = new Festivos__c();
        festivo.FES_CAS_Procesado__c = false;
        festivo.FES_DAT_Fecha__c = system.today();
        festivo.FES_SEL_Tipo_de_Festivo__c = 'Nacional';
        
        
        insert festivo;
        
        Test.startTest();

            BATCH_Festivos obj = new BATCH_Festivos(tipoBatch);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    static testMethod void festivoLocalTest(){
        
        String tipoBatch = 'Festivos';
        Festivos__c festivo = new Festivos__c();
        festivo.FES_CAS_Procesado__c = false;
        festivo.FES_DAT_Fecha__c = system.today();
        festivo.FES_SEL_Tipo_de_Festivo__c = 'Local';
 
        
        insert festivo;
        
        Test.startTest();

            BATCH_Festivos obj = new BATCH_Festivos(tipoBatch);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    static testMethod void festivoProvincialTest(){
        
        String tipoBatch = 'Festivos';
        Festivos__c festivo = new Festivos__c();
        festivo.FES_CAS_Procesado__c = false;
        festivo.FES_DAT_Fecha__c = system.today();
        festivo.FES_SEL_Tipo_de_Festivo__c = 'Provincial';
        festivo.FES_SEL_Provincia__c = '28';
        //festivo.FES_LKP_Territorio__r.PostalCode = '28000';
        
        insert festivo;
        
        Test.startTest();

            BATCH_Festivos obj = new BATCH_Festivos(tipoBatch);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    

    
    static testmethod void NacionalTest2(){
        
         RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('Julian','1018','X1234567X');
        Insert cuentaPrincipal;
        
        
        Account acc=Util_Tests.crearCuentaAsegurado('RP123456', 'RP123456', 'email', '12345678Z', 'PR123456', 'primerApellido', 'segundoApellido');   
        acc.CUE_EMA_Email__c='test@email.com';
        //acc.CUE_CAS_Activado__c = true;
        acc.CUE_SEL_Tipo_de_Profesional__c = '01';
        //acc.CUE_SEL_Estado__c = '01';
        acc.CUE_TXT_Identificador__c='RP123456';
        acc.RecordTypeId = rt.Id;
        acc.CUE_SEL_Direccion_Territorial__c = 'a6';
        acc.Name = 'PR123456';
        acc.CUE_LKP_Cuenta_principal__c = Null;
        acc.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        system.debug('ID CUENTA'+acc.CUE_TXT_Identificador__c);
        insert acc;
        acc.CUE_SEL_Estado__c = '02';
        update acc;
        
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :acc.Id ];
        
        
        
        
        Profesional_Gremio__c profGrem = new Profesional_Gremio__c();
       	profGrem.PRG_LKP_Cuenta_Profesional__c=acc.Id;
       	profGrem.PRG_TXT_Identificador__c='urh0485hdc12n5f';
       	profGrem.PRG_NUM_Lim_OT_en_Curso__c=2;
       	profGrem.PRG_SEL_Gremio__c='01';
       	insert profGrem;
        ServiceResource serv = new ServiceResource();
        serv.IsActive = true;
        serv.RSE_LKP_Cuenta__c=acc.Id;
        serv.RSE_SEL_Gremio__c='01'; 
        serv.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        serv.RelatedRecordId = UserInfo.getUserId();
        serv.RSE_TXT_Codigo_Recurso__c = '1242141';
        serv.RSE_LKP_Profesional_Gremio__c=profGrem.Id;
        insert serv;
        
        String tipoBatch = 'Festivos';
        Festivos__c festivo = new Festivos__c();
        festivo.FES_CAS_Procesado__c = false;
        festivo.FES_DAT_Fecha__c = system.today();
        festivo.FES_SEL_Tipo_de_Festivo__c = 'Nacional';
        
        
        insert festivo;
        
        Test.startTest();

            BATCH_Festivos obj = new BATCH_Festivos(tipoBatch);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
        
       
        
    }
   
    static testMethod void MiembrosTerritorioTest(){
        
        //ID accountID=Id.valueOf('identificador');
         
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('Julian','1018','X1234567X');
        Insert cuentaPrincipal;
        RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        Account acc=Util_Tests.crearCuentaAsegurado('RP123456', 'RP123456', 'email', '12345678Z', 'PR123456', 'primerApellido', 'segundoApellido');   
        acc.CUE_SEL_Tipo_de_Profesional__c = '01';
        acc.CUE_EMA_Email__c='test@email.com';
        acc.CUE_TXT_Identificador__c='RP123456';
        acc.RecordTypeId = rt.Id;
        acc.CUE_SEL_Direccion_Territorial__c = 'A7';
        acc.CUE_LKP_Cuenta_principal__c = Null;
        acc.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        acc.Name = 'PR123456';
        system.debug('ID CUENTA'+acc.CUE_TXT_Identificador__c);
        insert acc;
        acc.CUE_SEL_Estado__c = '02';
        update acc;
        
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :acc.Id ];
        
        system.debug('ID CUENTA'+acc.CUE_TXT_Identificador__c);
        system.debug(acc1 + 'acc1');
        
        String tipoBatch = 'MiembrosTerritorio';
        ServiceResource serv = new ServiceResource();
        serv.IsActive = true;
        serv.RSE_LKP_Cuenta__c=acc.Id;
        serv.RSE_SEL_Gremio__c='01'; 
       	system.debug(serv.RSE_LKP_Cuenta__r + ' NO VAAAAA');
       	Profesional_Gremio__c profGrem = new Profesional_Gremio__c();
       	profGrem.PRG_LKP_Cuenta_Profesional__c=acc.Id;
       	profGrem.PRG_TXT_Identificador__c='hf9184jg091864k';
       	profGrem.PRG_NUM_Lim_OT_en_Curso__c=2;
       	profGrem.PRG_SEL_Gremio__c='01';
       	insert profGrem;
        serv.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        serv.RelatedRecordId = UserInfo.getUserId();
        serv.RSE_TXT_Codigo_Recurso__c = '1242141';
        serv.RSE_LKP_Profesional_Gremio__c=profGrem.Id;
        insert serv;
        system.debug(serv + ' ResourceService');
        
        
         

        Poblacion__c poblacion = new Poblacion__c();
        poblacion.Name = 'MADRID';
        poblacion.POB_TXT_Identificador__c = '28';
        poblacion.POB_SEL_Provincia__c = '28';
 
        insert poblacion;
        
        
        
        OperatingHours op = new OperatingHours();
        op.Name = 'Horario por defecto';
        op.TimeZone = 'Europe/Paris';
        insert op;
        
        ServiceTerritory servTerritory = new ServiceTerritory();
        servTerritory.IsActive = true;
        servTerritory.Name = '28000 MADRID';
        servTerritory.OperatingHoursId = op.Id;
        servTerritory.PostalCode = '28000';
        servTerritory.TDS_TXT_Identificador__c = '28000#MADRID';
        servTerritory.TDS_SEL_Provincia__c = '28';
        system.debug('se lanza');
        insert servTerritory;
        
       
       
        
        Festivos__c festivo = new Festivos__c();
        festivo.FES_CAS_Procesado__c = false;
        festivo.FES_DAT_Fecha__c = system.today();
        festivo.FES_SEL_Tipo_de_Festivo__c = 'Local';
        festivo.FES_LKP_Territorio__c = servTerritory.Id;
        
        
        insert festivo;
        
        ServiceTerritoryMember serviceTerritory = new ServiceTerritoryMember();
        serviceTerritory.MTS_CAS_Procesado_Festivo__c = false;
        serviceTerritory.ServiceResourceId = serv.Id;
        serviceTerritory.MTS_TXT_Identificador__c = '1242141_46920#MISLATA';
        serviceTerritory.ServiceTerritoryId = servTerritory.Id;
        serviceTerritory.EffectiveStartDate = System.today();
        serviceTerritory.PostalCode = '28041';
		serviceTerritory.State='01';
        

        insert serviceTerritory;
        system.debug(serviceTerritory.ServiceResourceId + ' prueba Alberto');
      
        
        /*ServiceTerritoryMember serviceTerritory2 = new ServiceTerritoryMember();
        serviceTerritory2.MTS_CAS_Procesado_Festivo__c = false;
        serviceTerritory2.ServiceResourceId = ID.valueOf('12345678');
        serviceTerritory2.MTS_TXT_Identificador__c = '1242141_46920#MISLATA';
        serviceTerritory2.ServiceTerritoryId = ID.valueOf('12345678');
        serviceTerritory2.EffectiveStartDate = Date.newInstance(1960, 2, 17);
        serviceTerritory2.EffectiveEndDate = Date.newInstance(1961, 2, 17);
        insert serviceTerritory2;*/

        Test.startTest();

            BATCH_Festivos obj = new BATCH_Festivos(tipoBatch);

            DataBase.executeBatch(obj); 

        Test.stopTest();
    }
    
     static testMethod void profesionalTest(){
        
        Festivos__c festivo = new Festivos__c();
        festivo.FES_CAS_Procesado__c = false;
        festivo.FES_DAT_Fecha__c = system.today();
        festivo.FES_SEL_Tipo_de_Festivo__c = 'Nacional';
        
        insert festivo;
         
        Festivos__c festivoL = new Festivos__c();
        festivoL.FES_CAS_Procesado__c = false;
        festivoL.FES_DAT_Fecha__c = system.today()+7;
        festivoL.FES_SEL_Tipo_de_Festivo__c = 'Local';
        
        insert festivoL;
         
        String tipoBatch = 'Profesional';
          
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('Julian','1018','X1234567X');
        Insert cuentaPrincipal; 
        RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        Account acc=Util_Tests.crearCuentaAsegurado('RP123456', 'RP123456', 'email', '12345678Z', 'PR123456', 'primerApellido', 'segundoApellido');   
        acc.CUE_SEL_Tipo_de_Profesional__c = '01';
        acc.CUE_EMA_Email__c='test@email.com';
        acc.CUE_TXT_Identificador__c='RP123456';
        acc.RecordTypeId = rt.Id;
        acc.Name = 'PR123456';
        acc.CUE_SEL_Direccion_Territorial__c = 'A7';
        acc.CUE_LKP_Cuenta_principal__c = Null;
        acc.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        system.debug('ID CUENTA'+acc.CUE_TXT_Identificador__c);
        insert acc;
        acc.CUE_SEL_Estado__c = '02';
        update acc;
        
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :acc.Id ];
        
        system.debug('ID CUENTA'+acc.CUE_TXT_Identificador__c);
        
        Profesional_Gremio__c profGrem = new Profesional_Gremio__c();
       	profGrem.PRG_LKP_Cuenta_Profesional__c=acc1.Id;
       	profGrem.PRG_TXT_Identificador__c='8fjdlsjeoqh632j';
       	profGrem.PRG_NUM_Lim_OT_en_Curso__c=2;
       	profGrem.PRG_SEL_Gremio__c='01';
       	insert profGrem;
        ServiceResource serv = new ServiceResource();
        serv.IsActive = true;
        serv.RSE_LKP_Cuenta__c=acc.Id;
        serv.RSE_SEL_Gremio__c='01'; 
        serv.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        serv.RelatedRecordId = UserInfo.getUserId();
        serv.RSE_TXT_Codigo_Recurso__c = '1242141';
        serv.RSE_LKP_Profesional_Gremio__c=profGrem.Id;
        insert serv;
         
        
        
            Poblacion__c poblacion = new Poblacion__c();
        poblacion.Name = 'MADRID';
        poblacion.POB_TXT_Identificador__c = '28';
        poblacion.POB_SEL_Provincia__c = '28';
        insert poblacion;
        
        OperatingHours op = new OperatingHours();
        op.Name = 'Horario por defecto';
        op.TimeZone = 'Europe/Paris';
        insert op;
        
        
        ServiceTerritory servTerritory = new ServiceTerritory();
        servTerritory.IsActive = true;
        servTerritory.Name = '28000 MADRID';
        servTerritory.OperatingHoursId = op.Id;
        servTerritory.PostalCode = '28000';
        servTerritory.TDS_TXT_Identificador__c = '28000#MADRID';
        servterritory.TDS_SEL_Provincia__c = '28';
        //servTerritory.TDS_LKP_Poblacion__c = poblacion.Id;
        
        insert servTerritory;
        
        ServiceResource serviceResource = [SELECT id, RSE_TXT_Codigo_Recurso__c from ServiceResource where RSE_TXT_Codigo_Recurso__c = '1242141'];
        
        ServiceTerritoryMember serviceTerritoryM = new ServiceTerritoryMember();
        serviceTerritoryM.MTS_CAS_Procesado_Festivo__c = true;
        serviceTerritoryM.ServiceResourceId = serviceResource.Id;
        serviceTerritoryM.MTS_TXT_Identificador__c = '1242141_46920#MISLATA';
        serviceTerritoryM.ServiceTerritoryId = servTerritory.Id;
        serviceTerritoryM.EffectiveStartDate = System.today();
        insert serviceTerritoryM;
         
        
        Test.startTest();

            BATCH_Festivos obj = new BATCH_Festivos(tipoBatch);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}