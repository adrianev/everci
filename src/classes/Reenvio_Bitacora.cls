public without sharing class Reenvio_Bitacora {
	private INT_Bitacora__c bitacora;
	public String mensajeError {get; set;}
	public Reenvio_Bitacora(ApexPages.StandardController stdController) {
		bitacora = (INT_Bitacora__c)stdController.getRecord();
	}

	public PageReference autoRun() {
		Id theId = ApexPages.currentPage().getParameters().get('id');

		//LLM
		Callout_Centinela_Generacion callout = new Callout_Centinela_Generacion();
		//FLLM
		
		if (theId == null) {
			return null;
		}
		List<INT_Bitacora__c> bitList = new List<INT_Bitacora__c>();
		INT_Bitacora__c bitacoraQuery = Util_Bitacora.queryBitacora(new Set<Id>{theId}).get(theId);
		system.debug('CONDICIONES: '+bitacoraQuery != null);
		system.debug(Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO));
		system.debug(bitacoraQuery.RecordTypeId); //NULL POINTER EXCEPTION
		system.debug(bitacoraQuery.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO));
		
		//LLM
		//if(callout.updateDatos(bitacoraQuery.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__r.Name)){
		//FLLM
			if(bitacoraQuery != null && bitacoraQuery.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO)){//Compruebo que me ha traído algo y es de tipo fichero
				bitacoraQuery.BIT_SEL_Estado__c=label.BIT_ESTADO_NO_ENVIADO;
				bitacoraQuery.BIT_TXT_Error__c = '';
				update bitacoraQuery;
				bitList.add(bitacoraQuery);
				Batch_Envio_Mov myBatchObject = new Batch_Envio_Mov(null,bitList);
				Id batchId = Database.executeBatch(myBatchObject);
				PageReference pageRef = new PageReference('/' + theId);
				pageRef.setRedirect(true);
				return pageRef;
			}
		//LLM
		/*}else{
			mensajeError = 'Fichero de envío duplicado en destino.';
		}*/
		//FLLM
		return null;
	}
}