@isTest
public without sharing class Test_TRG_Handler_ContentVersion {
	
	/*@testSetup
	public static void test(){
		TestSetup loadData = new Test_TRG_Handler_ContentVersion();
		loadData.setTestData();
	}*/
	
	@isTest
	public static void testing(){
		String versionDataTXT = 'UEsDBBQABgAIAAAAIQCUD9E51wEAA';
		Blob versionData = Blob.valueOf(versionDataTXT);
		
		Factura__c factura1 = new Factura__c();
		factura1.Name = 'primeraFactura';
		factura1.FAC_TXT_Numero_factura__c = '06032018';
		system.debug('>>>>>verFactura1: ' + factura1);
		upsert factura1;
		system.debug('>>>>>verFactura1: ' + factura1);
		
		Factura__c factura2 = new Factura__c();
		factura2.Name = 'segundaFactura';
		factura2.FAC_TXT_Numero_factura__c = '06032018';
		system.debug('>>>>>verFactura2: ' + factura2);
		upsert factura2;
		system.debug('>>>>>verFactura2: ' + factura2);
		
		//List<Factura__c> facturas = new List<Factura__c>([Select Id, Name, FAC_TXT_Numero_factura__c FROM Factura__c WHERE Name = 'primeraFactura']);
		//Factura__c factura1 = new Factura__c();
		//factura1 = facturas.get(0);
		
		ContentVersion insercion = new ContentVersion();
		insercion.Title = 'testContentVersion';
		insercion.PathOnClient = '.pdf';
		insercion.FirstPublishLocationId = factura1.Id;
		insercion.VersionData = versionData;
		insert insercion;
		
		system.debug('insercion: ' + insercion);
		
		List<ContentVersion> listaInserciones = new List<ContentVersion>();
		listaInserciones.add(insercion);
		system.debug('>>>>>listaInserciones.size: ' + listaInserciones.size());
		
		Test.startTest();
		//TRG_Handler_ContentVersion.obtenerFactura(listaInserciones);
		Test.stopTest();
		
	}
}