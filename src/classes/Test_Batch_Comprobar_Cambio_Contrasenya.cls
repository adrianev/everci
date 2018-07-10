@isTest
public without sharing class Test_Batch_Comprobar_Cambio_Contrasenya{
  
    private static Account cuentaPrincipal {get; set;}
    private static testMethod void comprobarCambioContrasenya(){
        
        EmailTemplate emailT = new EmailTemplate();
        emailT.Body = 'Hi {!Receiving_User.FirstName}, Welcome to {!Community_Name}! To get started, go to {!Community_Url} Username: {!Receiving_User.Username} Thanks, {!Organization.Name}';
        emailT.Description = 'Notification that user has been added to a community';
        emailT.DeveloperName = 'ClicHogar_UsuarioNoCambioPassword';
        emailT.Name = 'Communities: New Member Welcome Email';
        emailT.TemplateType = 'text';
        emailT.FolderId = UserInfo.getUserId();
        
        insert emailT;
        
         User newUser = new User();
		newUser.FirstName = 'Manolo';
		newUser.LastName = 'tena';
		newUser.Email = 'manolo@manolo.com';
		newUser.Alias = 'Manolo';
		newUser.ProfileId = system.UserInfo.getProfileId();
		newUser.Username = ' john784poi@acme7.com';
		newUser.CommunityNickname = 'pepe';
		newUser.TimeZoneSidKey = 'Europe/Paris';
		newUser.LocaleSidKey = system.UserInfo.getLocale();
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.LanguageLocaleKey = 'es';

		insert newUser;
        
        
        
        system.runAs(newUser){
            Account compania = Util_Tests.crearCuentaCompania('CuentaCompañia', '1019', 'X1264567X');
            compania.CUE_TXT_Identificador__c = Label.IDE_SEGURCAIXA;
            insert compania;
            
            /*
            Account cuenta = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1018','X1234567X');
            insert cuenta;
            Account cuenta1 = Util_Tests.crearCuentaB2BPpal('B2BPrincipal',Label.IDE_ALMUDENA,'X1234568X');
            insert cuenta1;
            Account cuenta2 = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1041','X1234569X');
            insert cuenta2;
            Account cuenta3 = Util_Tests.crearCuentaB2BPpal('B2BPrincipal',Label.IDE_NATIONALE_NETHERLANDEN,'X1234562X');
            insert cuenta3;
        	*/
            Account cuentaSecundaria = Util_Tests.crearCuentaB2BSec('Alberto2','1080', compania.Id);
            cuentaSecundaria.CUE_TXT_Numero_Documento__c = '89074907R';
            cuentaSecundaria.CUE_SEL_Tipo_Documento__c = 'N';
            insert cuentaSecundaria;
            Contact contacto1 = Util_Tests.crearContacto('Nombre Cuenta Principal', 'Apellido Cuenta Principal', compania.Id ,'Ident_Cont1');
            contacto1.CON_CAS_Contacto_principal__c=true;
            contacto1.MobilePhone='623456789';
            contacto1.Phone='678954321';
            contacto1.HomePhone='987654321';
            
            insert contacto1;
            /*
            Contact contacto2 = Util_Tests.crearContacto('Guille', 'Lex', cuenta1.Id ,'Ident_Cont2');
            contacto2.CON_CAS_Contacto_principal__c=true;
            contacto2.MobilePhone='623455789';
            contacto2.Phone='678954121';
            contacto2.HomePhone='987644321';
            
            insert contacto2;
            
            Contact contacto3 = Util_Tests.crearContacto('Lebron', 'James', cuenta2.Id ,'Ident_Cont3');
            contacto3.CON_CAS_Contacto_principal__c=true;
            contacto3.MobilePhone='623455789';
            contacto3.Phone='678954121';
            contacto3.HomePhone='987644321';
            
            insert contacto3;
            
         
            Contact contacto4 = Util_Tests.crearContacto('Cristiano', 'Ronaldo', cuenta3.Id ,'Ident_Cont4');
            contacto4.CON_CAS_Contacto_principal__c=true;
            contacto4.MobilePhone='623455789';
            contacto4.Phone='678954121';
            contacto4.HomePhone='987644321';
            
            insert contacto4;
            
            */
            
         
            Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0,0,0,0,0,compania.Id,'101444',Label.PROCEDENCIA_SERVICIO_B2C);
			procedencia.PROC_SEL_Gremios_Disp__c = '02';
			insert procedencia;
            
            Baipas.establecerVariableControl();
            Case caso = new Case();
            caso.AccountId = compania.Id;
            caso.CAS_TXT_Usuario_Clic_Hogar__c = newUser.Id;
            caso.CreatedDate = date.today() -3;
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.ContactId = contacto1.id;
            
            insert caso;
            system.debug(caso.ContactId + ' Valor de ContactId');
            
            caso.CAS_TXT_Password_Clic_Hogar__c = caso.Id;
            
            update caso;
           /*
            Case caso1 = new Case();
            caso1.AccountId = cuenta1.Id;
            caso1.CAS_TXT_Usuario_Clic_Hogar__c = newUser.Id;
            caso1.CreatedDate = date.today() -3;
            caso1.CAS_LKP_Compania__c = cuenta1.Id;
            caso1.CAS_LKP_Procedencia__c = procedencia.Id;
            caso1.ContactId = contacto2.id;
            
            insert caso1;
            
             caso1.CAS_TXT_Password_Clic_Hogar__c = caso1.Id;
            
            update caso1;
            
            
            
            Case caso2 = new Case();
            caso2.AccountId = cuenta2.Id;
            caso2.CAS_TXT_Usuario_Clic_Hogar__c = newUser.Id;
            caso2.CreatedDate = date.today() -3;
            caso2.CAS_LKP_Compania__c = cuenta2.Id;
            caso2.CAS_LKP_Procedencia__c = procedencia.Id;
            caso2.ContactId = contacto3.id;
            
            insert caso2;
            
             caso2.CAS_TXT_Password_Clic_Hogar__c = caso2.Id;

            update caso2;
            
            
    
            Case caso3 = new Case();
            caso3.AccountId = cuenta3.Id;
            caso3.CAS_TXT_Usuario_Clic_Hogar__c = newUser.Id;
            caso3.CreatedDate = date.today() -3;
            caso3.CAS_LKP_Compania__c = cuenta3.Id;
            caso3.CAS_LKP_Procedencia__c = procedencia.Id;
            caso3.ContactId = contacto4.id;
            
            insert caso3;
            
             caso3.CAS_TXT_Password_Clic_Hogar__c = caso3.Id;
            
            update caso3;
*/
    		Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
			insert tipoProductoCIA;
			Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
			insert productoCIA;
         
            ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaSecundaria.Id, compania.Id, productoCIA.Id);
            poliza.POL_TXT_Cliente_Ensura__c = 'ensura';
			insert poliza;
            /*
            ServiceContract poliza1 = new ServiceContract();
            poliza1.Name='Alberto2';
        	poliza1.POL_SEL_Estado_Provincia__c='28';
            poliza1.AccountId = contacto2.AccountId;
            poliza1.POL_TXT_Cliente_Ensura__c= 'ensura1';
            poliza1.POL_TXT_Id_Version_Poliza__c = '02';
        	insert poliza1;
            
            ServiceContract poliza2 = new ServiceContract();
            poliza2.Name='Alberto3';
        	poliza2.POL_SEL_Estado_Provincia__c='28';
            poliza2.AccountId = contacto3.AccountId;
            poliza2.POL_TXT_Cliente_Ensura__c= 'ensura2';
            poliza2.POL_TXT_Id_Version_Poliza__c = '03';
        	insert poliza2;
            
            ServiceContract poliza3 = new ServiceContract();
            poliza3.Name='Alberto4';
        	poliza3.POL_SEL_Estado_Provincia__c='28';
            poliza3.AccountId = contacto4.AccountId;
            poliza3.POL_TXT_Cliente_Ensura__c= 'ensura3';
            poliza3.POL_TXT_Id_Version_Poliza__c = '04';
        	insert poliza3;
*/            
            
            
        }
        
        Test.startTest();
        
        Batch_Comprobar_Cambio_Contrasenya_CH comprobarCambio = new Batch_Comprobar_Cambio_Contrasenya_CH();
        comprobarCambio.execute(null);
           
        Test.stopTest();

    }
    
      /*  private static testMethod void comprobarCambioContrasenya2(){
        
        EmailTemplate emailT = new EmailTemplate();
        emailT.Body = 'Hi {!Receiving_User.FirstName}, Welcome to {!Community_Name}! To get started, go to {!Community_Url} Username: {!Receiving_User.Username} Thanks, {!Organization.Name}';
        emailT.Description = 'Notification that user has been added to a community';
        emailT.DeveloperName = 'ClicHogar_UsuarioNoCambioPassword';
        emailT.Name = 'Communities: New Member Welcome Email';
        emailT.TemplateType = 'text';
        emailT.FolderId = UserInfo.getUserId();
        
        insert emailT;
            
        Test.startTest();
        
        Batch_Comprobar_Cambio_Contrasenya_CH comprobarCambio = new Batch_Comprobar_Cambio_Contrasenya_CH();
        comprobarCambio.execute(null);
            
        Test.stopTest();
    }*/
}