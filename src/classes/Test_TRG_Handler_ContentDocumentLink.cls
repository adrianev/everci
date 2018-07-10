@isTest
public without sharing class Test_TRG_Handler_ContentDocumentLink {

	public static List<ContentDocumentLink> createContentDocumentLinkCase(){
        system.debug('hasta aqui llega');
        Baipas.establecerVariableControl();
        List<ContentDocumentLink> lContentDocumentLinkCase = new List<ContentDocumentLink>();
        system.debug('hasta aqui llega');
        String sInputEmail = 'homeserveGestor@cliente.com';
        
        List<User> lUsers = [SELECT Name,UserRoleId FROM User WHERE UserRoleId != ''];
		//Create Test Account
		Account newAccount = new Account(Name='TestAccount', CUE_EMA_Gestor_Comunidad__c = sInputEmail,CUE_TXT_Identificador__c='00001', OwnerId = lUsers.get(0).Id,
                                        CUE_TXT_Numero_Documento__c = 'X1234567X', CUE_SEL_Tipo_Documento__c = 'C');
		insert newAccount;
        system.debug('hasta aqui llega');
		//Create Test Contact
		Contact c = new Contact(firstname='first',lastname='last',AccountId=newAccount.Id);
		c.CON_TXT_Identificador__c = 'CON78545421';system.debug('hasta aqui llega');
		insert c;
        
        Case caseObj = new Case(
                        ContactId = c.Id,
                        AccountId = newAccount.Id,
                        Status = 'Working',
                        Origin = 'Phone');
        
        insert caseObj;
        system.debug('CASE COMO OBJETO: '+caseObj);
        system.debug([SELECT Id FROM Case]);
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
		insert newAccount;
        
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
    
    @isTest(SeeAllData=true)
    public static void testActualizarVisibilityForCase(){
        List<ContentDocumentLink> lcreateContentDocumentLinkCase = createContentDocumentLinkCase();
        system.debug('METODO DE TEST');
        system.debug('Antes: ' + lcreateContentDocumentLinkCase);
        TRG_Handler_ContentDocumentLink.actualizarVisibility(lcreateContentDocumentLinkCase);
        system.debug('Despues: ' + lcreateContentDocumentLinkCase);
    }
    
    @isTest(SeeAllData=true)
    public static void testActualizarVisibilityForWO(){
        List<ContentDocumentLink> lcreateContentDocumentLinkWO = createContentDocumentLinkWO();
        system.debug('Antes: ' + lcreateContentDocumentLinkWO);
        TRG_Handler_ContentDocumentLink.actualizarVisibility(lcreateContentDocumentLinkWO);
        system.debug('Despues: ' + lcreateContentDocumentLinkWO);
        
        system.assertEquals(lcreateContentDocumentLinkWO.get(0).Visibility, 'AllUsers');
        system.assertEquals(lcreateContentDocumentLinkWO.get(1).Visibility, 'AllUsers');
    }
    
    @isTest(SeeAllData=true)
    public static void testActualizarVisibilityForOthers(){
        List<ContentDocumentLink> lcreateContentDocumentLinkOther = createContentDocumentLinkAccount();
        system.debug('Antes: ' + lcreateContentDocumentLinkOther);
        TRG_Handler_ContentDocumentLink.actualizarVisibility(lcreateContentDocumentLinkOther);
		system.debug('Despues: ' + lcreateContentDocumentLinkOther);

        system.assertEquals(lcreateContentDocumentLinkOther.get(0).Visibility, 'InternalUsers');
        system.assertEquals(lcreateContentDocumentLinkOther.get(1).Visibility, 'AllUsers');
    }
        
}