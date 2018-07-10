@isTest
public without sharing class Test_Util_CTI {
	private static VDN_Compania__c vdn {get; set;}
	private static Account compania{get; set;}
	
	@isTest private static void testQuerys() {
		inicializarVariables();
		List<VDN_Compania__c> listaVDN = Util_CTI.queryMapVDN(new Set<String>{vdn.Name}).values();
		//List<VDN_Compania__c> listaVDN = Util_CTI.queryVDN(vdn.Name);
		List<Telefonos_Transfer_CIA__c> listaTrans = Util_CTI.queryTransferPhoneByCia(new Set<Id>{compania.Id}).values();
	}
	
	private static void inicializarVariables() {
		compania = Util_Tests.crearCuentaCompania('segur','1018','U0241731I');
		insert compania;
		vdn = Util_Tests.crearVDNCompania('AGC', compania.Id);
		insert vdn;
		Telefonos_Transfer_CIA__c transfer = Util_Tests.nuevoTransferCIA ('91 111 60 21', compania.Id, '91 111 60 21');
		insert transfer;
	}
}