public without sharing class Visor_Ayuda {
	public Ayuda__c ayuda {get;set;}

	public Visor_Ayuda(ApexPages.standardController stdCtr){
		PageReference paginaActual = ApexPages.currentPage();
		if(paginaActual.getParameters().containsKey('id')){
			List<String> fields = new List<String>{'Id','AYU_TXT_Descripcion__c','AYU_SEL_Tipo__c'};
			stdCtr.addFields(fields);
			ayuda = (Ayuda__c) stdCtr.getRecord();
		}
	}
}