/**
  * Handler del Trigger TRG_EmailMessage.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_EmailMessage {

	private static Map<Id, Case> mapaCasos;
	private static final Id recordTypeIdReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
	private static Set<String> buzonesPeritos;
	private static Map<Id, Perito__c> mapaPeritos;
	
	/**
	  * Tratamiento para el caso before del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto EmailMessage a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto EmailMessage
	  * @param triggerOldMap: mapa de registros antiguos del objeto EmailMessage a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto EmailMessage
	  */
	public static void tratamientoBefore(Map<Id, EmailMessage> triggerNewMap, List<EmailMessage> triggerNew, 
			Map<Id, EmailMessage> triggerOldMap, List<EmailMessage> triggerOld){

		if(Trigger.isInsert){
			List<Case> listaCasosModif = new List<Case>();
			if(mapaCasos == null)
				inicializaVariables(triggerNew);

			Set<String> caseNumber = new Set<String>();
			List<EmailMessage> paraReclamaciones = new List<EmailMessage>();
			List<Case> borrar = new List<Case>();
			List<Task> tareasInsertar = new List<Task>();

			for(EmailMessage em: triggerNew){
				
				if(em.Incoming){
					System.debug('@@@TRG_Email: Ha llegado un correo: ' + em);
					if(!String.isBlank(em.Subject)){
						List<String> splitSubject = em.Subject.split(':');
						if(splitSubject.size() == 2 && splitSubject[0] == 'Reclamación'){
							caseNumber.add(splitSubject[1]);
							paraReclamaciones.add(em);
						}else if(buzonesPeritos!=null && buzonesPeritos.contains(em.ToAddress)){//Es un correo del circuito de peritos--> Le cambio el estado y creo tarea
							System.debug('@@@TRG_Email: Ha llegado un correo de peritos: ' + em);
							mapaCasos.get(em.ParentId).CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_REV_RESP_PER;
							System.debug('@@@TRG_Email: Caso: ' + mapaCasos.get(em.ParentId).CaseNumber + mapaCasos.get(em.ParentId).CAS_SEL_Estado_Perito__c);
							listaCasosModif.add(mapaCasos.get(em.ParentId));
							//tareasInsertar.add(Util_tarea.crearTarea(Label.RT_TAR_COMUN,'Revisión correo perito(Pendiente de etiqueta)', Label.TAR_ESTADO_EN_CURSO, null,mapaCasos.get(em.ParentId).OwnerId,mapaCasos.get(em.ParentId).Id,mapaCasos.get(em.ParentId).CAS_LKP_Compania__c));
						}
					}
				}
			}


			if(!paraReclamaciones.isEmpty()){

				//Map<Id,Case> reclamaciones = new Map<Id,Case>([Select Id, CAS_TXT_Num_Caso_HS__c, OwnerId from Case where CAS_TXT_Num_Caso_HS__c in :caseNumber]);

				/*Map<Id,Case> reclamaciones = new Map<Id,Case>([Select Id,
															   CaseNumber,
															   Parent.CaseNumber,
															   CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
															   CAS_TXT_Num_Caso_CIA__c,
															   OwnerId, 
															   recordTypeId,
															   Parent.CAS_TXT_Num_Caso_CIA__c, 
															   CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
															   AccountId
															   from Case 
															   where CAS_TXT_Num_Caso_CIA__c in :caseNumber 
															   or (RecordtypeId = :recordTypeIdReclamacion
															   and (Parent.CAS_TXT_Num_Caso_CIA__c in :caseNumber
																	   or CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c in :caseNumber)
															   and Status != :Label.CAS_ESTADO_CERRADO_FACTURADO
															   and Status != :Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR
															   and Status != :Label.CAS_ESTADO_CERRADO)
															   or CaseNumber in :caseNumber 
															   or (RecordtypeId = :recordTypeIdReclamacion
															   and (Parent.CaseNumber in :caseNumber
																	   or CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber in :caseNumber)
															   and Status != :Label.CAS_ESTADO_CERRADO_FACTURADO
															   and Status != :Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR
															   and Status != :Label.CAS_ESTADO_CERRADO)]);*/
				Map<Id,Case> reclamaciones = Util_Caso.queryCasosTRGEmailMessage(caseNumber,new Set<Id>{recordTypeIdReclamacion});

				Map<String,Case> casosPadrePorNumero = new Map<String,Case>();
				Map<String,List<Case>> reclamacionesPorNumero = new Map<String,List<Case>>();

				for(Case rec: reclamaciones.values()){
					if(rec.RecordTypeId != recordTypeIdReclamacion){
						if(caseNumber.contains(rec.CAS_TXT_Num_Caso_CIA__c)){
							casosPadrePorNumero.put(rec.CAS_TXT_Num_Caso_CIA__c,rec);
						} else {
							casosPadrePorNumero.put(rec.CaseNumber,rec);
						}
					} else {
						String numeroCIA = '';
						if(rec.Parent.CAS_TXT_Num_Caso_CIA__c != null && caseNumber.contains(rec.Parent.CAS_TXT_Num_Caso_CIA__c)){
							numeroCIA = rec.Parent.CAS_TXT_Num_Caso_CIA__c;
						} else if(rec.CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c != null && caseNumber.contains(rec.CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c)){
							numeroCIA = rec.CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c;
						} else if(rec.Parent.CaseNumber != null && caseNumber.contains(rec.Parent.CaseNumber)){
							numeroCIA = rec.Parent.CaseNumber;
						} else if(rec.CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber != null && caseNumber.contains(rec.CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber)){
							numeroCIA = rec.CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber;
						}

						List<Case> lAux= reclamacionesPorNumero.get(numeroCIA);

						if(lAux == null)
							lAux = new List<Case>();

						lAux.add(rec);
						reclamacionesPorNumero.put(numeroCIA,lAux);
					}
				}


				for(EmailMessage em: paraReclamaciones){

					String numeroCIA = em.Subject.split(':')[1];

					Case caso = null;

					List<Case> lAux = reclamacionesPorNumero.get(numeroCIA);
					if(lAux != null && lAux.size() == 1)
						caso = lAux[0];

					if(caso == null)
						caso = casosPadrePorNumero.get(numeroCIA);

					//Case caso = reclamacionesPorNumero.get(em.Subject.split(':')[1]);
					if(caso != null){
						Id casoAsignado = caso.Id;
						if(em.ParentId != null && em.ParentId != casoAsignado && mapaCasos.get(em.ParentId).Createddate == mapaCasos.get(em.ParentId).LastModifieddate){
							borrar.add(new Case(Id=em.ParentId));
						}

						em.ParentId = casoAsignado;

						Task tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN,'Recibido correo consulta de reclamación',Label.TAR_ESTADO_EN_CURSO,null,caso.OwnerId,caso.Id,caso.AccountId);
						tareasInsertar.add(tarea);
					} else {
						if(em.ParentId != null && mapaCasos.get(em.ParentId).Createddate == mapaCasos.get(em.ParentId).LastModifieddate){
							borrar.add(new Case(Id=em.ParentId));
							em.ParentId = null;
						}
					}
				}  
			}

			delete borrar; 
			insert tareasInsertar;
			System.debug('TRG_Email: Casos a actualizar: ' + listaCasosModif);
			update listaCasosModif;
		}

	}

	/**
	 * Tratamiento para el caso after.
	 *
	 * @param triggerNewMap: mapa de registros nuevos del objeto EmailMessage a partir del Id
	 * @param triggerNew: lista de registros nuevos del objeto EmailMessage
	 * @param triggerOldMap: mapa de registros antiguos del objeto EmailMessage a partir del Id
	 * @param triggerOld: lista de registros antiguos del objeto EmailMessage
	 */
	public static void tratamientoAfter(Map<Id, EmailMessage> triggerNewMap, List<EmailMessage> triggerNew, 
		 Map<Id, EmailMessage> triggerOldMap, List<EmailMessage> triggerOld){
		if(Trigger.isInsert){
			if(mapaCasos == null)
				inicializaVariables(triggerNew);
				
			List<Case> actualizarCasos = new List<Case>();
			for(EmailMessage em : triggerNew){
				Case caso = mapaCasos.get(em.ParentId);
				//for(Id id : mapaCasos.keySet()){
					if(caso != null && caso.RecordtypeId != recordTypeIdReclamacion && em.Incoming){
						actualizarCasos.add(new Case(Id=caso.Id,SourceId=em.Id));
					}
				//}
			}
			update actualizarCasos;
			
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param correos: [PENDIENTE]
	  * 
	  */
	private static void inicializaVariables(List<EmailMessage> correos){
		Set<Id> idCasos = new Set<Id>();
		Set<String> setRemitentes = new Set<String>();
		for(EmailMessage em: correos){
			idCasos.add(em.ParentId);
			setRemitentes.add(em.ToAddress);
		}

		if(!idCasos.isEmpty()){
			mapaCasos = new Map<Id,Case>([Select Id,
									  CreatedDate,
									  SourceId,
									  LastModifieddate,
									  OwnerId,
									  RecordtypeId
									  from case where id in: idCasos]);
		}
		buzonesPeritos=new Set<String>();
		for(Buzon_CIA__c s:[SELECT Id,BUZ_EMA_Direccion__c FROM Buzon_CIA__c WHERE BUZ_EMA_Direccion__c IN: setRemitentes AND BUZ_SEL_Tipo_Programa__c =: Label.CON_TIPO_PROGRAMA_PERITO]){
			buzonesPeritos.add(s.BUZ_EMA_Direccion__c);
		}
	}
}