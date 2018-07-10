@isTest
public without sharing class Test_TRG_Handler_ContentDocumentLink {

    private static Account cuentaDireccion;

	public static List<ContentDocumentLink> createContentDocumentLinkCase(){
        Baipas.establecerVariableControl();
        List<ContentDocumentLink> lContentDocumentLinkCase = new List<ContentDocumentLink>();
        
        String sInputEmail = 'homeserveGestor@cliente.com';
        
        List<User> lUsers = [SELECT Name,UserRoleId FROM User WHERE UserRoleId != ''];
		//Create Test Account
		Baipas.establecerVariableControl();

        Account compania = new Account();
        compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018', 'J5340931D');
		Account asegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1019','email@gmail.es', '46595659M','Miguel', 'Sagrado', 'Corazón');
		insert compania;
		asegurado.CUE_LKP_Cuenta_principal__c = compania.Id;
		asegurado.Type='02';
		insert asegurado;
        Baipas.deshabilitarVariableControl();
        
		//Create Test Contact
		Contact c = new Contact();
        c = Util_Tests.crearContacto('Manuel', 'Rosas Castillo', asegurado.Id, '53568187A');
        c.CON_TXT_Identificador__c = 'CON78545421';
		insert c;


        cuentaDireccion=Util_Tests.crearCuentaB2BPpal('Name', '1234563', 'X4455667X');
        cuentaDireccion.Type=Label.CUE_TIPO_DIRECCION;
        insert cuentaDireccion;
        
        Case caseObj = new Case(
                        ContactId = c.Id,
                        AccountId = asegurado.Id,
                        Status = 'Working',
             			CAS_LKP_Compania__c=compania.id,
                        CAS_LKP_Cliente_contable_cliente__c=cuentaDireccion.Id,
                        Origin = 'Phone');
        
        insert caseObj;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        Boolean aux2 = Baipas.deshabilitarVariableControl();
        insert cv;
        //String contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].Id;
        
        ContentDocumentLink contentDocumentLinkCaseUser = new ContentDocumentLink();
        contentDocumentLinkCaseUser.ShareType='V';
        contentDocumentLinkCaseUser.Visibility='InternalUsers';
        contentDocumentLinkCaseUser.ContentDocumentId=cv.Id;
        contentDocumentLinkCaseUser.LinkedEntityId=caseObj.id;
        
        lContentDocumentLinkCase.add(contentDocumentLinkCaseUser);
        
        ContentDocumentLink contentDocumentLinkCase = new ContentDocumentLink();
        contentDocumentLinkCase.ShareType='I';
        contentDocumentLinkCase.Visibility='AllUsers';
        contentDocumentLinkCase.ContentDocumentId=cv.Id;
        contentDocumentLinkCase.LinkedEntityId=caseObj.id;
        
        lContentDocumentLinkCase.add(contentDocumentLinkCase);
        
		return lContentDocumentLinkCase;
	}
    
	public static List<ContentDocumentLink> createContentDocumentLinkWO(){
        Baipas.establecerVariableControl();
        List<ContentDocumentLink> lContentDocumentLinkWorkOrder = new List<ContentDocumentLink>();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        insert wo;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        //String contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].Id;
        
        ContentDocumentLink contentDocumentLinkWOUser = new ContentDocumentLink();
        contentDocumentLinkWOUser.ShareType='V';
        contentDocumentLinkWOUser.Visibility='InternalUsers';
        contentDocumentLinkWOUser.ContentDocumentId=cv.Id;
        contentDocumentLinkWOUser.LinkedEntityId=wo.id;
        
        lContentDocumentLinkWorkOrder.add(contentDocumentLinkWOUser);
        
        ContentDocumentLink contentDocumentLinkWO = new ContentDocumentLink();
        contentDocumentLinkWO.ShareType='I';
        contentDocumentLinkWO.Visibility='AllUsers';
        contentDocumentLinkWO.ContentDocumentId=cv.Id;
        contentDocumentLinkWO.LinkedEntityId=wo.id;
        
        lContentDocumentLinkWorkOrder.add(contentDocumentLinkWO);
        
        return lContentDocumentLinkWorkOrder;
	}
    
    public static List<ContentDocumentLink> createContentDocumentLinkAccount(){
    	Baipas.establecerVariableControl();
        List<ContentDocumentLink> lContentDocumentLinkAccount = new List<ContentDocumentLink>();
        
        String sInputEmail = 'homeserveGestor@cliente.com';
        
        List<User> lUsers = [SELECT Name,UserRoleId FROM User WHERE UserRoleId != ''];
		//Create Test Account
		Account newAccount = new Account(Name='TestAccount', CUE_EMA_Gestor_Comunidad__c = sInputEmail,CUE_TXT_Identificador__c='00001', OwnerId = lUsers.get(0).Id,
                                        CUE_TXT_Numero_Documento__c = 'X1234567X', CUE_SEL_Tipo_Documento__c = 'C');
		//insert newAccount;
        
        Baipas.deshabilitarVariableControl();
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        //String contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].Id;
        
        ContentDocumentLink contentDocumentLinkAccountUser = new ContentDocumentLink();
        contentDocumentLinkAccountUser.ShareType='V';
        contentDocumentLinkAccountUser.Visibility='InternalUsers';
        contentDocumentLinkAccountUser.ContentDocumentId=cv.Id;
        contentDocumentLinkAccountUser.LinkedEntityId=newAccount.id;
        
        lContentDocumentLinkAccount.add(contentDocumentLinkAccountUser);
        
        ContentDocumentLink contentDocumentLinkAccount = new ContentDocumentLink();
        contentDocumentLinkAccount.ShareType='I';
        contentDocumentLinkAccount.Visibility='AllUsers';
        contentDocumentLinkAccount.ContentDocumentId=cv.Id;
        contentDocumentLinkAccount.LinkedEntityId=newAccount.id;
        
        lContentDocumentLinkAccount.add(contentDocumentLinkAccount);
        
        return lContentDocumentLinkAccount;
	}
    
    @isTest()
    public static void testActualizarVisibilityForCase(){
        List<ContentDocumentLink> lcreateContentDocumentLinkCase = createContentDocumentLinkCase();
        TRG_Handler_ContentDocumentLink.actualizarVisibility(lcreateContentDocumentLinkCase);
        for(ContentDocumentLink contentDocumentLink:lcreateContentDocumentLinkCase){
			system.assertEquals(contentDocumentLink.Visibility, 'AllUsers');

		}
    }
    
     
    @isTest()
    public static void testActualizarVisibilityForOthers(){
        List<ContentDocumentLink> lcreateContentDocumentLinkOther = createContentDocumentLinkAccount();
        TRG_Handler_ContentDocumentLink.actualizarVisibility(lcreateContentDocumentLinkOther);       
		for(ContentDocumentLink contentDocumentLink:lcreateContentDocumentLinkOther){
			system.assertEquals(contentDocumentLink.Visibility, 'AllUsers');

		}
    }  
       
}