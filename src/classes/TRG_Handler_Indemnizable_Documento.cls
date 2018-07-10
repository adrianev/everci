/**
  * Clase handler del trigger del Trigger TRG_Handler_Indemnizable_Documento.
  * 
  * @author EVERIS
  */
public without sharing class TRG_Handler_Indemnizable_Documento {
	 
	 
public static void tratamientoBefore(Map<Id,Indemnizable_Documento__c> triggerNewMap,
									 List<Indemnizable_Documento__c> triggerNew,
									 Map<Id, Indemnizable_Documento__c> triggerOldMap,
									 List<Indemnizable_Documento__c> triggerOld){
		  
				Set<Id> setIdsCasos = new Set<Id>();
				Set<Id> setIdsTiposTrabajo = new Set<Id>();
				Map<Id, String> mapaTiposDocumentoOT = new Map<Id, String>();
		  
				List<String> pickListValuesList= new List<String>();
				Schema.DescribeFieldResult fieldResult = Indemnizable_Documento__c.IND_SEL_Estado__c.getDescribe();

				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

				for( Schema.PicklistEntry pickListVal : ple){

				 pickListValuesList.add(pickListVal.getLabel());

				}	 


				if(triggerNew != null){
					 
				for(Indemnizable_Documento__c indem_doc : triggerNew){
					 Indemnizable_Documento__c indem_docOld;
					 
					 if(triggerOldMap != null){
						  indem_docOld = triggerOldMap.get(indem_doc.Id);
					 }
				
					// Crear un mapa con los Tipos de Documento de las OTs indemnizables
					// en las que se ha marcado el check de Documentación recibida
					// PREV:if(indem_doc.IND_SEL_Tipo_Documento__c != null && indem_doc.IND_SEL_Estado__c && G
										 //(indem_docOld == null || (!indem_docOld.IND_SEL_Estado__c))){
										 
										 
					if(indem_doc.IND_SEL_Estado__c != pickListValuesList[2] /*'Rechazada'*/ ){  //
						mapaTiposDocumentoOT.put(indem_doc.Id, indem_doc.IND_SEL_Tipo_Documento__c);
					}
					
					// Crear un mapa que contiene el tipo de documento requerido y sus partidas
					Map<Id, List<Indemnizable_Partida__c>> mapaDocIndemnReq = new Map<Id, List<Indemnizable_Partida__c>>();
					String docIndemnReq = '';
					if(!mapaTiposDocumentoOT.isEmpty()){
							  // Obtener de la configuración la lista que contiene los Tipos de Documento Indemnizables que requieren partidas
							  Configuracion_General__mdt confDocIndemnReq = Util_Metadatos.CONFIG_GENERAL.get('DocumentosRequeridos');
							  if(confDocIndemnReq != null && confDocIndemnReq.CF_TXT_Valor__c != null){
										 docIndemnReq = ';' + confDocIndemnReq.CF_TXT_Valor__c + ';';
							  }
	 
							  List<Indemnizable_Partida__c> listaPartIndemn = new List<Indemnizable_Partida__c>(
													[SELECT Id, INDP_LKP_Documento_Indemnizable__c FROM Indemnizable_Partida__c WHERE INDP_LKP_Documento_Indemnizable__c IN :mapaTiposDocumentoOT.keySet()]);								 
							  if(!listaPartIndemn.isEmpty() && docIndemnReq != null){
										 mapaDocIndemnReq = new Map<Id, List<Indemnizable_Partida__c>>();
										 for(Indemnizable_Partida__c indem_docli : listaPartIndemn){
													if(docIndemnReq.contains(';' + mapaTiposDocumentoOT.get(indem_docli.INDP_LKP_Documento_Indemnizable__c) + ';')){
															  List<Indemnizable_Partida__c> docIndemReqWo;
															  if(mapaDocIndemnReq.containsKey(indem_docli.INDP_LKP_Documento_Indemnizable__c)){
																		 docIndemReqWo = mapaDocIndemnReq.get(indem_docli.INDP_LKP_Documento_Indemnizable__c);
															  }
															  else {
																		 docIndemReqWo = new List<Indemnizable_Partida__c>();
															  }
															  docIndemReqWo.add(indem_docli);
															  mapaDocIndemnReq.put(indem_docli.INDP_LKP_Documento_Indemnizable__c, docIndemReqWo);
													}
										 }
							  }
					}
					// [Before-InsertUpdate] VALIDACIÓN DE CHECK DE DOCUMENTACION RECIBIDA EN OTs INDEMNIZABLES
					system.debug('[Before-InsertUpdate] VALIDACIÓN DE CHECK DE DOCUMENTACION RECIBIDA EN DOCS INDEMNIZABLES');
					// Si se ha marcado el check de Documentación Recibida: se valida si el Tipo de Documento
					// de la OT requiere partidas y si las tiene en ese caso
					// PREV: if(indem_doc.IND_SEL_Tipo_Documento__c != null && indem_doc.IND_SEL_Estado__c
								  //	  && (indem_docOld == null || (!indem_docOld.IND_SEL_Estado__c))
									//	 && docIndemnReq != null
									 //	&& docIndemnReq.contains(';' + indem_doc.IND_SEL_Tipo_Documento__c + ';')){
									 
						 /* if(indem_doc.IND_SEL_Tipo_Documento__c == 'Recibido' 
							 && (indem_docOld == null || (!indem_docOld.IND_SEL_Estado__c == 'Recibido')) ) { */
									 
							if(indem_doc.IND_SEL_Tipo_Documento__c == pickListValuesList[1] 
							 && (indem_docOld == null || (indem_docOld.IND_SEL_Estado__c != pickListValuesList[1] )) ) {
									 
									 
									 
							  if(Trigger.isInsert
													|| mapaDocIndemnReq == null
													|| mapaDocIndemnReq.get(indem_doc.Id) == null
													|| mapaDocIndemnReq.get(indem_doc.Id).isEmpty()){
										 indem_doc.addError(Label.ERROR_DOC_REQUERIDA);
							  }
					}//FIN: [Before-InsertUpdate] VALIDACIÓN DE CHECK DE DOCUMENTACION RECIBIDA EN OTs INDEMNIZABLES
			}
		}
	}
}