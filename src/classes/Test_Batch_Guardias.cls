@isTest
public without sharing class Test_Batch_Guardias{

    private static testMethod void guardias(){
        
        Date hoy=Date.today();
        Date ayer=hoy.addDays(-1);
        //RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        Account acp = Util_Tests.crearCuentaCompania('CuentaVerdadera','1029','C4110110S');
        insert acp;

        Account acc= Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',acp.Id);
        acc.CUE_SEL_Tipo_de_Profesional__c = '01';
        acc.CUE_EMA_Email__c='test@email.com';
        insert acc;
        acc.CUE_CAS_Activado__c = true;
        acc.CUE_SEL_Estado__c = '02';
        update acc;
        Account acc2=new Account();
        acc2.Name='Test2';
        acc2.CUE_TXT_Numero_Documento__c='12345677J';
        acc2.CUE_SEL_Estado__c='02';
        acc2.CUE_SEL_Tipo_Documento__c='P';
        acc2.CUE_LKP_Cuenta_principal__c = acp.id;
        insert acc2;
        
        Account acc3=new Account();
        acc3.Name='Test2';
        acc3.CUE_TXT_Numero_Documento__c='12345567H';
        acc3.CUE_SEL_Estado__c='02';
        acc3.CUE_SEL_Tipo_Documento__c='P';
        acc3.CUE_LKP_Cuenta_principal__c = acp.id;
        
        insert acc3;
        
        User u = new User();
		u.FirstName = 'Manolo';
		u.LastName = 'tena';
		u.Email = 'manolo@manolo.com';
		u.Alias = 'Manolo';
		u.ProfileId = system.UserInfo.getProfileId();
		u.Username = ' john784poi@acme7.com';
		u.CommunityNickname = 'pepe';
		u.TimeZoneSidKey = 'Europe/Paris';
		u.LocaleSidKey = system.UserInfo.getLocale();
		u.EmailEncodingKey = 'ISO-8859-1';
		u.LanguageLocaleKey = 'es';
        insert u;
        
        User u2 = new User();
		u2.FirstName = 'Manole';
		u2.LastName = 'tena';
		u2.Email = 'manole@manolo.com';
		u2.Alias = 'Manole';
		u2.ProfileId = system.UserInfo.getProfileId();
		u2.Username = ' john784pol@acme7.com';
		u2.CommunityNickname = 'pepa';
		u2.TimeZoneSidKey = 'Europe/Paris';
		u2.LocaleSidKey = system.UserInfo.getLocale();
		u2.EmailEncodingKey = 'ISO-8859-1';
		u2.LanguageLocaleKey = 'es';
        
        insert u2;
        
        User u3 = new User();
		u3.FirstName = 'Maasdfe';
		u3.LastName = 'tefda';
		u3.Email = 'manosae@manolo.com';
		u3.Alias = 'Manoxs';
		u3.ProfileId = system.UserInfo.getProfileId();
		u3.Username = ' johsddf84pol@acme7.com';
		u3.CommunityNickname = 'peea';
		u3.TimeZoneSidKey = 'Europe/Paris';
		u3.LocaleSidKey = system.UserInfo.getLocale();
		u3.EmailEncodingKey = 'ISO-8859-1';
		u3.LanguageLocaleKey = 'es';
        
        insert u3;
        
        Account accUp = [SELECT Id,Name,CUE_TXT_Identificador__c FROM Account WHERE Id=: acc.Id];
        
        ServiceResource serv = new ServiceResource();
        serv.IsActive = true;
        serv.Name = accUp.CUE_TXT_Identificador__c + '_01_1';
        serv.RelatedRecordId = u.Id;
        serv.RSE_TXT_Codigo_Recurso__c = '1242141';
        serv.RSE_LKP_Cuenta__c=accUp.Id;
        
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
        OperatingHours opHC = new OperatingHours();
        opHC.Name = 'Horario completo';
        opHC.TimeZone = 'Europe/Paris';
        insert opHC;
        
        ServiceTerritory servTerritory = new ServiceTerritory();
        servTerritory.IsActive = true;
        servTerritory.Name = '28000 MADRID';
        servTerritory.OperatingHoursId = op.Id;
        servTerritory.PostalCode = '28000';
        servTerritory.TDS_TXT_Identificador__c = '28000#MADRID';
        
        insert servTerritory;
        
        
        ServiceTerritory servTerritory2 = new ServiceTerritory();
        servTerritory2.IsActive = true;
        servTerritory2.Name = '13000 BARCELONA';
        servTerritory2.OperatingHoursId = op.Id;
        servTerritory2.PostalCode = '13000';
        servTerritory2.TDS_TXT_Identificador__c = '13000#MADRID';
        
        insert servTerritory2;
        
        ServiceTerritory servTerritory3 = new ServiceTerritory();
        servTerritory3.IsActive = true;
        servTerritory3.Name = '12487 MURCIA';
        servTerritory3.OperatingHoursId = op.Id;
        servTerritory3.PostalCode = '12487';
        servTerritory3.TDS_TXT_Identificador__c = '12877#MURCIA';
        
        insert servTerritory3;
        
        ServiceTerritoryMember serviceTerritory = new ServiceTerritoryMember();
        serviceTerritory.MTS_CAS_Procesado_Festivo__c = false;
        serviceTerritory.ServiceResourceId = serv.Id;
        serviceTerritory.MTS_TXT_Identificador__c = '1242141_46920#MISLATA';
        serviceTerritory.ServiceTerritoryId = servTerritory.Id;
        serviceTerritory.EffectiveStartDate = hoy;
        serviceTerritory.TerritoryType='P';
        insert serviceTerritory;
        
        Guardia__c guardia = new Guardia__c();
        guardia.GUA_CAS_Tratada_Fin__c = false;
        guardia.GUA_CAS_Tratada_Inicio__c = false;
        guardia.GUA_DAT_Fecha_Fin__c = hoy.addDays(3);
        guardia.GUA_DAT_Fecha_Inicio__c = hoy;
        guardia.GUA_LKP_Territorio__c = servTerritory.Id;
        guardia.GUA_LKP_Profesional__c = serv.Id;
        
        insert guardia;
        
        Guardia__c guardia2 = new Guardia__c();
        guardia2.GUA_CAS_Tratada_Fin__c = false;
        guardia2.GUA_CAS_Tratada_Inicio__c = false;
        guardia2.GUA_DAT_Fecha_Fin__c = ayer;
        guardia2.GUA_DAT_Fecha_Inicio__c = hoy.addDays(3);
        guardia2.GUA_LKP_Territorio__c = servTerritory.Id;
        guardia2.GUA_LKP_Profesional__c = serv.Id;
        
        insert guardia2;
        
        Guardia__c guardia3 = new Guardia__c();
        guardia3.GUA_CAS_Tratada_Fin__c = false;
        guardia3.GUA_CAS_Tratada_Inicio__c = false;
        guardia3.GUA_DAT_Fecha_Fin__c = ayer;
        guardia3.GUA_DAT_Fecha_Inicio__c = hoy.addDays(1);
        guardia3.GUA_LKP_Territorio__c = servTerritory.Id;
        guardia3.GUA_LKP_Profesional__c = serv.Id;
        
        insert guardia3;
        
        Guardia__c guardia4 = new Guardia__c();
        guardia4.GUA_CAS_Tratada_Fin__c = false;
        guardia4.GUA_CAS_Tratada_Inicio__c = false;
        guardia4.GUA_DAT_Fecha_Fin__c = ayer;
        guardia4.GUA_DAT_Fecha_Inicio__c = hoy.addDays(2);
        guardia4.GUA_LKP_Territorio__c = servTerritory.Id;
        guardia4.GUA_LKP_Profesional__c = serv.Id;
        
        insert guardia4;
        
        Guardia__c guardia5 = new Guardia__c();
        guardia5.GUA_CAS_Tratada_Fin__c = false;
        guardia5.GUA_CAS_Tratada_Inicio__c = false;
        guardia5.GUA_DAT_Fecha_Fin__c = hoy.addDays(3);
        guardia5.GUA_DAT_Fecha_Inicio__c = hoy;
        guardia5.GUA_LKP_Territorio__c = servTerritory2.Id;
        guardia5.GUA_LKP_Profesional__c = serv.Id;
        
        insert guardia5;
        
        Test.startTest();

            BATCH_Guardias obj = new BATCH_Guardias();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
}