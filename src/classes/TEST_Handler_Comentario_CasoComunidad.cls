@isTest
public class TEST_Handler_Comentario_CasoComunidad {
    
    	public static ServiceContract crearPolizaContrato2(String nombre, Id compania, Id asegurado, Id productoCIA){
		ServiceContract poliza=new ServiceContract();
        poliza.Name=nombre;
        poliza.POL_LKP_Compania__c = compania;
        poliza.AccountId = asegurado;
        poliza.POL_LKP_Producto_Cia__c = productoCIA;
        insert poliza;

        Version_ContratoServicio__c nuevaVersion = new Version_ContratoServicio__c();
        nuevaVersion.POLV_LKP_PolizaContrato__c = poliza.Id;
        nuevaVersion.POLV_SEL_Pais__c = 'ES';
        nuevaVersion.POLV_SEL_Idioma__c = '2';
        nuevaVersion.POLV_DAT_FechaFin__c = Date.newInstance(2018, 5, 6);
        nuevaVersion.POLV_DAT_FechaInicio__c = Date.newInstance(2018, 5, 6).addDays(2);
        Insert nuevaVersion;


        poliza.POL_LKP_Version_Actual__c= nuevaVersion.id; 
        update poliza;

        return poliza;
	} 
    
    @isTest static void ComentarioCasoComunidad(){
 		
		
		Id ProfileID = [ Select id from Profile where Name =: Label.PERFIL_ADMINISTRADOR].id;
	
     
        User newUser = new User();
		newUser.FirstName = 'Manolo';
		newUser.LastName = 'tena';
		newUser.Email = 'manolo@manolo.com';
		newUser.Alias = 'Manolo';
		newUser.ProfileId = ProfileID;
		newUser.Username = ' john784poi@acme7.com';
		newUser.CommunityNickname = 'pepe';
		newUser.TimeZoneSidKey = 'Europe/Paris';
		newUser.LocaleSidKey = system.UserInfo.getLocale();
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.LanguageLocaleKey = 'es';
        newUser.ContactId = '0039E00000V1Xn7QAF';
        

		insert newUser;
        
      
        

        System.RunAs(newUser){
        Test.startTest();

      
       	Account cuentaPrincipal = new Account();
        cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1021', 'X1234567X');
        insert cuentaPrincipal;
  

		Account compania = Util_Tests.crearCuentaCompania('Pepito','1020','X1224567X');
        compania.type = '01';
		insert compania;
            
        Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '73661110E','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_LKP_Cuenta_principal__c = compania.id;
        asegurado.type  = '01';
		insert asegurado; 
            
        Contact contactoPrincipal = new Contact();
		contactoPrincipal = new Contact(AccountId = asegurado.id, lastname = 'lastname');
		insert contactoPrincipal;
		Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
            

        ServiceContract poliza = crearPolizaContrato2('alberto', compania.id,asegurado.Id,productoCIA.Id);


        
		Case casoTest1= new Case();
        casoTest1 = Util_Tests.crearCasoB2B(poliza.Id, asegurado.Id, compania.Id);
        casoTest1.CAS_LKP_Compania__c = compania.Id;
        casoTest1.ContactId  =contactoPrincipal.Id;
		//casoTest1.Status = '999';
		insert casoTest1;

            
        CaseComment comentarioCaso =  new CaseComment();
		comentarioCaso.CommentBody = 'Comentario del caso' ;   
		comentarioCaso.ParentId = casoTest1.Id;
        insert comentarioCaso;
           
        Test.stopTest();
                
        }
            
            
            
            
            
            

	}
}