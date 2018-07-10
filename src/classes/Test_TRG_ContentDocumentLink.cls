@isTest
public without sharing class Test_TRG_ContentDocumentLink extends TestSetup{
	@isTest static void testTRG(){
		ContentVersion cv = new ContentVersion();
		cv.Title = 'CV';
		cv.PathOnClient = 'Home_1430x650.jpg';
		cv.VersionData = EncodingUtil.base64Decode('YQ==');
		insert cv;
		List<ContentVersion> listaCV = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
		Factura__c factura = new Factura__c();
		factura.FAC_TXT_Numero_factura__c = '2';
		insert factura;
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = listaCV.get(0).ContentDocumentId;
		cdl.LinkedEntityId = factura.Id;
		cdl.ShareType = 'V';
		insert cdl;
	}
}