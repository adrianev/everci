@isTest
public without sharing class Test_ContentDocumentRelatedList{
    


    @isTest static void testOperario(){

        Test.startTest();
		Account account = Util_Tests.crearCuentaB2BPpal('SegurCaixa','1018','X1234567X');
        insert account;
        
       
        Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;
																																												
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];

        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDoc.Id;
        contentLink.ShareType = 'V';
        contentLink.LinkedEntityId = account.Id;

        insert contentLink;

        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        ContentDocumentRelatedListController contentDocController = new ContentDocumentRelatedListController(sc);
        contentDocController.goToUser();
        contentDocController.openNuevo();
        contentDocController.cancelNuevo();
        contentDocController.modifyDocument();
        
		
        Contentversion cv1 = new Contentversion();
        cv1.Title = 'ABC';
        cv1.PathOnClient = 'test';
        cv1.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv1;

        ApexPages.currentPage().getParameters().put('idRegistro',cv.Id);

        contentDocController.adjuntoId = cv1.Id;
        contentDocController.saveNewDocument();
        contentDocController.cancelModifyDocument();
        contentDocController.saveDocument();
        contentDocController.closePopup();
        contentDocController.showPopup();
        contentDocController.deleteRow();
        
        Util_ContentVersion.queryCVById(new Set<Id>{cv.Id});
        Test.stopTest();

    }
    
}