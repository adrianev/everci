/**
 * Clase controladora de la Visualforce "RechazoAlbaran" encargada de rechazar el albarán de una orden de trabajo.
 * 
 * @author EVERIS
 */
public without sharing class RechazoAlbaran {

	public WorkOrder wo {get;set;}
	public User profesional {get;set;}
	public List<Resultado> motivoList {get;set;}
	public Map<String,String> motivoValores {get;set;}

	public String direccionProfesional {get;set;}
	public Boolean mailInterno;
	public String asuntoInterno {get;set;}
	public String cuerpoCorreo {get;set;}
	public String direccionesExtra {get;set;}

	/**
	  * Constructor de la clase.
	  * 
	  * @param stdCtr: [PENDIENTE]
	  */
	public RechazoAlbaran(ApexPages.standardController stdCtr){

		PageReference paginaActual = ApexPages.currentPage();
		mailInterno = false;
		direccionesExtra = '';

		Apexpages.getMessages().clear();

		if(paginaActual.getParameters().containsKey('id')){
			Id woId = stdCtr.getRecord().Id;
			direccionProfesional = '';
			system.debug('-------woId: ' + woId);
			//QUERY SUSTITUIDA POR queryMapOTById(Set ids): List<WorkOrder> woList = Util_Orden_Trabajo.queryOT(woId,null,null);
			List<WorkOrder> woList = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).values();
			//List<WorkOrder> woList = [Select Id,WorkOrderNumber,OwnerId,ParentWorkOrderId,ParentWorkOrder.WorkOrderNumber,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_LKP_Recurso_Servicio__c from WorkOrder where id = :woId];
			system.debug('-----woList: '+woList);
			if(!woList.isEmpty())
				wo = woList[0];
			//OwnerId se usa como lookup para la visual
			wo.OwnerId = null;

			ServiceResource recProfesional = null;
			if(wo.OTR_LKP_Recurso_Servicio__c == null){
				//String filtro1 = 'Id in (Select ServiceResourceId from AssignedResource where ServiceAppointment.ParentRecordId = \''+wo.ParentWorkOrderId+'\')';
				//List<ServiceResource> recList = Util_Service_Resource.queryMapSR(filtro1).values();
				List<ServiceResource> recList = Util_Service_Resource.queryMapSRByWoIds(new Set<Id>{wo.ParentWorkOrderId}).values();
				//List<ServiceResource> recList = Util_Documentacion.querySR(filtro1);
				//List<ServiceResource> recList = [select id, RelatedRecordId from ServiceResource where Id in (Select ServiceResourceId from AssignedResource where ServiceAppointment.ParentRecordId = :wo.ParentWorkOrderId)];
				if(!recList.isEmpty())
					recProfesional = recList[0];

			} else {
				//String filtro2 = 'Id = \''+wo.OTR_LKP_Recurso_Servicio__c+'\'';
				//List<ServiceResource> recList = Util_Service_Resource.queryMapSR(filtro2).values();
				List<ServiceResource> recList = Util_Service_Resource.queryMapSRByRsIds(new Set<Id>{wo.OTR_LKP_Recurso_Servicio__c}).values();
				//List<ServiceResource> recList = Util_Documentacion.querySR(filtro2);
				//List<ServiceResource> recList = [Select id, RelatedRecordId from ServiceResource where id = :wo.OTR_LKP_Recurso_Servicio__c];
				if(!recList.isEmpty())
					recProfesional = recList[0];
			}

			if(recProfesional != null){
				profesional = Util_Perfiles_Usuario.queryMapUsuario(new Set<Id>{recProfesional.RelatedRecordId}).get(recProfesional.RelatedRecordId);
				//profesional = Util_Usuarios.queryUsuarioById(recProfesional.RelatedRecordId);
				//List<User> profList = [Select id, Name, Street,city,state,postalcode,country,Address, Email from User where id = :recProfesional.RelatedRecordId];
				if(profesional != null){
					//profesional = profList[0];
					if(profesional.Address != null)
						direccionProfesional = profesional.Street + ', ' + profesional.city + ', ' + profesional.state + ', ' + profesional.postalcode + ', ' + profesional.country;
				}
			}


		}
		motivoValores = getValoresCampo('OTR_SEL_Motivos_de_Rechazo_de_Albaran__c');
		system.debug('------motivos: '+motivoValores);
		motivoList = new List<Resultado>();

		for(String motivo: motivoValores.keySet()){
			if(motivo != 'Otros' && motivo != 'Describa los trabajos realizados.' && motivo != 'Aporte fotografías.')
				motivoList.add(new Resultado(false,motivo,false));
			else
				motivoList.add(new Resultado(false,motivo,true));
		}
		
		asuntoInterno = 'Rechazo albarán orden de trabajo '+wo.ParentWorkOrder.WorkOrderNumber;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param campoAPI: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	public static Map<String,String> getValoresCampo(String campoAPI){
		Map<String,String> options = new Map<String,String>();
		Schema.DescribeFieldResult fieldResult = null;

		if(campoAPI.equals('OTR_SEL_Motivos_de_Rechazo_de_Albaran__c'))
			fieldResult = WorkOrder.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for(Schema.PicklistEntry f : ple)
			options.put(f.getLabel(),f.getValue());

		return options;

	}

	/**
	  * [PENDIENTE]
	  * 
	  * @return página a navegar tras ejecutar la cancelación
	  */
	public PageReference cancelar() {
		PageReference paginaRedireccion = new PageReference('/' + wo.Id);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	public PageReference rechazoInterno(){

		if(wo.OwnerId == null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se han seleccionado usuario para el envío de correo interno'));
			return null;
		} 

		return rechazo(LABEL.OTR_SUBESTADO_REVISADO_EN_ESPERA_HOMESERVE,wo.OwnerId,true);

	}

	/**
	  * [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	public PageReference rechazoProfesional(){

		if(profesional == null || profesional.Id == null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha encontrado profesional para esta orden de trabajo'));
			return null;
		}

		return rechazo(LABEL.OTR_SUBESTADO_REVISADO_ALBARAN_DEVUELTO_PROFESIONAL,profesional.Id,false);

	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param subestado: [PENDIENTE]
	  * @param destinatarioId: [PENDIENTE]
	  * @param esInterno: [PENDIENTE]
	  * 
	  * @return página a navegar tras ejecutar el rechazo
	  */
	public PageReference rechazo(String subestado,Id destinatarioId, Boolean esInterno){

		Boolean hayMotivos = false;
		for(Resultado res: motivoList)
			if(res.seleccionado){
				hayMotivos = true;
				break;
			}

		if(!esInterno && !hayMotivos){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se han seleccionado motivos'));
			return null;
		}

		PageReference paginaRedireccion = new PageReference('/'+wo.ParentWorkOrderId);
		paginaRedireccion.setRedirect(true);

		Savepoint sp = Database.setSavepoint();

		try{
            
            if(esInterno)
				copiarOTenPadre(subestado,destinatarioId);
			else
				copiarOTenPadre(subestado,null);

			system.debug('---Test envío mail, receptor: '+destinatarioId);
			//TODO: El mail no está definido
			enviarMail(destinatarioId,esInterno);
		} catch(DmlException e){
				Database.rollBack(sp);
				return null;
            	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            	}
     		} catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
			Database.rollBack(sp);
			return null;
		}

		system.debug('-----------OID: '+wo.OwnerId);
		for(Resultado res: motivoList)
			system.debug(res);

		return paginaRedireccion; 
	}


	/**
	  * [PENDIENTE]
	  * 
	  */
	public void readMotivos(){

		String pickListResult = '';

		for(Resultado res: motivoList){
			if(res.seleccionado)
				pickListResult += motivoValores.get(res.motivo) + ';';
		}

		wo.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = pickListResult;

		WorkOrder woUpdate = new WorkOrder();
		woUpdate.Id = wo.Id;
		woUpdate.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = wo.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c;

		update woUpdate;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param usuario: [PENDIENTE]
	  * @param interno: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	public void enviarMail(Id usuario, Boolean interno){
		//List<String> direcciones = new List<String>();
		//direcciones.add(email);

		User destinatario = Util_Perfiles_Usuario.queryMapUsuario(new Set<Id>{usuario}).get(usuario);
		//User destinatario = Util_Usuarios.queryUsuarioById(usuario);
		//User destinatario = [Select id,FirstName,LastName,Email,Phone from User where id = :usuario limit 1];

		Baipas.establecerVariableControl(); //Ahorrar queries para un contacto que se va a eliminar al final del método
		Contact contactoDestinatario = Util_Correo_Electronico.generarDummyContact(destinatario.FirstName,destinatario.LastName,destinatario.Email,null,null);		
		Baipas.deshabilitarVariableControl();
		


		String body = '';
		List<String> ccDirecciones = new List<String>{UserInfo.getUserEmail()};
		
		List<Id> adjuntos = new List<Id>();
		
		String asunto = 'Rechazo albarán orden de trabajo '+wo.ParentWorkOrder.WorkOrderNumber;
		
		if(interno){
			
			asunto = asuntoInterno;
			
			body = cuerpoCorreo.replace('\r\n','<br/>').replace('\n','<br/>');
			if(!String.isBlank(direccionesExtra)){
				ccDirecciones.addAll(direccionesExtra.split(';'));
			} /*else {
				ccDirecciones = new List<String>();
			}
			ccDirecciones.add(UserInfo.getUserEmail());*/
			//ccDirecciones = new List<String>{UserInfo.getUserEmail()};
		} else {

			body = '<p>Buenos días: <br/><br/> El presente correo, lleva adjunto el Albarán que se ha rechazado y que tiene que revisar, y volver a enviar.<br/><br/>Un saludo</p>';
			
			/*body = '<p>Se ha rechazado el albarán de la orden de trabajo '+wo.ParentWorkOrder.WorkOrderNumber+' por los siguientes motivos:</p>';
	
			body += '<ul>';
	
			for(Resultado res: motivoList){
				if(res.seleccionado){
					body += '<li>'+res.motivo+'</li>';
					if(res.tieneComentarios && !String.isBlank(res.comentarios)){
						body += '<ul><li>'+res.comentarios+'</li></ul>';
					}
				}
			}
	
			body += '</ul>';*/
			
			ContentVersion cv = generarPDFRechazo();
			
			if(cv != null)
				adjuntos.add(cv.Id);
		}
		List<ServiceAppointment> citasPadre = Util_Cita_Servicio.getMapCitasByOTs(new Set<Id>{wo.ParentWorkOrderId}).values();
		Set<Id> idsCitasPadre = new Set<Id>();

		for(ServiceAppointment cita: citasPadre){
			idsCitasPadre.add(cita.Id);
		}

		String prefijo = Label.PDF_TIPO_ALBARAN+'%';
		system.debug('-------------wo.ParentWorkOrderId: '+ wo.ParentWorkOrderId);
		//List<ContentVersion> albaranes = [Select id from contentversion where id in (select contentversiondocumentid from ServiceReport where ParentId = :wo.ParentWorkOrderId or ParentId in :idsCitasPadre) order by createddate desc];
		List<ContentDocumentLink> albaranes = Util_Documentacion.queryCDLByLinkedEntityAndLikeTitle(new Set<Id>{wo.ParentWorkOrderId},prefijo).values();
		//String filtro = 'LinkedEntityId = \''+wo.ParentWorkOrderId+'\' AND ContentDocument.Title LIKE \''+prefijo+'\'';
		//List<ContentDocumentLink> albaranes = Util_Documentacion.queryCDL(filtro);
		//List<ContentDocumentLink> albaranes = [Select id, ContentDocumentId, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId = :wo.ParentWorkOrderId and ContentDocument.Title like :prefijo];

		
		if(!albaranes.isEmpty())
			adjuntos.add(albaranes[0].ContentDocument.LatestPublishedVersionId);
			
		system.debug('---------ccDirecciones:' + ccDirecciones);

		//List<String> ccDirecciones = new List<String>{destinatario.Email};
		
			String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);

			//Util_Correo_Electronico.enviarSingleEmailSinPlantilla(wo.ParentWorkOrderId,asunto,body,'HTML',usuario,ccDirecciones,albaran,null);
			
			if(!Test.isRunningTest()) Util_Correo_Electronico.enviarSingleEmailSinPlantilla(wo.ParentWorkOrderId,asunto,body,'HTML',contactoDestinatario.Id,ccDirecciones,adjuntos,correoRemitente,null); 
			//Util_Correo_Electronico.enviarSingleEmailSinPlantilla(wo.ParentWorkOrderId,asunto,body,'HTML',null,ccDirecciones,albaran,null);

			//String filtroTareas = '(Status = \'Completed\' OR Status = \'Finalizado\') AND WhatId = \''+wo.ParentWorkOrderId+'\' ORDER BY CreatedDate DESC';
			//List<Task> tareas = Util_Tarea.queryTarea(filtroTareas);
			List<Task> tareas = Util_Tarea.getTareaByIdAndInStatusOrStatus(new Set<Id>{wo.ParentWorkOrderId},new Set<String>{wo.Status}).values();
			/*List<Task> tareas = [Select id,
									Priority,
									Subject,
									OwnerId,
									Description,
									IsRecurrence,
									CallDurationInSeconds,
									ActivityDate,
									CallObject,
									RecurrenceInterval,
									WhoId,
									IsVisibleInSelfService,
									IsReminderSet,
									WhatId,
									RecurrenceRegeneratedType,
									CallDisposition,
									TaskSubtype,
									Type,
									CallType,
									RecordTypeId,
									TAR_LKP_Compania__c,
									TAR_SEL_Prioridad__c,
									TAR_LKP_Orden_Trabajo__c
									from task where (Status = 'Completed' or Status = 'Finalizado') and WhatId = :wo.ParentWorkOrderId order by createddate desc];*/
									
			if(!tareas.isEmpty()){
				Task clonTarea = tareas[0].clone();
				clonTarea.WhatId = wo.Id;
				clonTarea.Status = 'Completed';
				if(clonTarea.Subject.contains('Correo electrónico:'))
					insert clonTarea;
			}
									
			



			/*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setTemplateId(template.Id);
            mail.setTargetObjectId(usuario);
            //mail.setToAddresses(direcciones);
            mail.setSubject('Rechazo albarán orden de trabajo '+wo.WorkOrderNumber);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            mail.setHTMLBody(body);
            if(interno){
                List<String> ccDirecciones = new List<String>{UserInfo.getUserEmail()};
                mail.setccAddresses(ccDirecciones);
            }
            //List<Messaging.Emailfileattachment> adjuntos = new List<Messaging.Emailfileattachment>();
            if(!interno){
        		List<Attachment> attList = [Select id from attachment where ParentId = :wo.Id];
        		List<ServiceReport> albaranes = [Select id,ContentVersionDocumentId from ServiceReport where ParentId = :wo.Id];
        		List<String> attIds = new List<String>();
        		for(Attachment att: attList){
        			attIds.add(att.Id);
        		}
        		for(ServiceReport alb: albaranes){
        			attIds.add(alb.ContentVersionDocumentId);
        		}


        		mail.setEntityAttachments(attIds);
        	}


        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(mail);

        Messaging.sendEmail(mails);*/
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param subestado: [PENDIENTE]
	  */
	public void copiarOTenPadre(String subestado, Id gestorRechazo){
		Id idPadre = wo.ParentWorkOrderId;
		Id idHija = wo.Id;

		//WorkOrder woHija = new WorkOrder();
		//WorkOrder woPadre = new WorkOrder();
		WorkOrder woHija = null;
		WorkOrder woPadre = null;

		List<WorkOrder> listaWOHija = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{idHija}).values();
		//List<WorkOrder> listaWOHija = Util_Orden_Trabajo.queryOT(idHija,null,null);
		/*List<WorkOrder> listaWOHija = new List<WorkOrder>([SELECT Id, 
		                                                   AccountId,
		                                                   City,
		                                                   Country,
		                                                   CreatedDate,
		                                                   Description,
		                                                   OTR_RES_Importe_partidas__c,
		                                                   OTR_CAS_Asignar_Mizad__c,
		                                                   OTR_CAS_Urgente__c,
		                                                   OTR_DAT_Fecha_Primera_Cita__c,
		                                                   OTR_LKP_Linea_Contrato__c,
		                                                   OTR_LKP_Recurso_Servicio__c,
		                                                   OTR_SEL_Gremio__c,
		                                                   OTR_SEL_Rango_Primera_Cita__c,
		                                                   OTR_SEL_Subestado__c,
		                                                   OTR_SEL_Tipo_Red__c,
		                                                   OTR_SEL_Motivo_de_rectificacion__c,
		                                                   OTR_SEL_Penalizacion__c,
		                                                   OTR_TXT_rectificacion__c,
		                                                   OwnerId,
		                                                   PostalCode,
		                                                   ParentWorkOrderId,
		                                                   ServiceTerritoryId,
		                                                   State,
		                                                   Status,
		                                                   Street,
		                                                   WorkTypeId,
		                                                   RecordTypeId
		                                                   FROM WorkOrder
		                                                   WHERE Id = :idHija]);*/
		List<WorkOrder> listaWOPadre = new List<WorkOrder>(Util_Orden_Trabajo.queryMapOTById(new Set<Id>{idPadre}).values());
		//List<WorkOrder> listaWOPadre = new List<WorkOrder>(Util_Orden_Trabajo.queryOT(idPadre,null,null));                                                
		/*List<WorkOrder> listaWOPadre = new List<WorkOrder>([SELECT Id,
		                                                    OTR_RES_Facturar_Cliente_AI__c,
		                                                    OTR_RES_Subtotal_Partidas__c,
		                                                    OTR_RES_Liquidar_prof_AI__c,
		                                                    ParentWorkOrderId,
		                                                    OTR_CAS_Partidas_Modificadas_Revision__c,
		                                                    RecordTypeId
		                                                    FROM WorkOrder
		                                                    WHERE Id = :idPadre]);*/


		system.debug(listaWOHija.get(0));
		system.debug(listaWOPadre.get(0));
		if(!listaWOHija.isEmpty()){
			woHija = listaWOHija.get(0);
			system.debug('---- woHijaRt: '+woHija.RecordtypeId);
		}

		woPadre = woHija.clone(false,true);
		woPadre.id = idPadre;
		WorkOrder woPadreOrig = new WorkOrder();
		if(!listaWOPadre.isEmpty()){
			woPadre.ParentWorkOrderId = listaWOPadre.get(0).ParentWorkOrderId;
			woPadre.RecordTypeId = listaWOPadre.get(0).RecordtypeId;
			woPadre.OTR_SEL_Motivo_de_rectificacion__c = '';
			woPadre.OTR_SEL_Penalizacion__c = '';
			woPadre.OTR_TXT_rectificacion__c = '';
			woPadre.OTR_TXT_Comentario_Auditoria__c = '';
			woPadreOrig = listaWOPadre.get(0);
		}

		woPadre.Status = LABEL.OTR_ESTADO_PDTE_AUDIT_GESTION;
		woHija.Status = LABEL.OTR_ESTADO_PDTE_AUDIT_GESTION;
		//woPadre.OTR_SEL_Subestado__c = Label.OTR_SUBESTADO_REVISADO_CON_ALBARAN;
		//woHija.OTR_SEL_Subestado__c = Label.OTR_SUBESTADO_REVISADO_CON_ALBARAN;
		woPadre.OTR_SEL_Subestado__c = subestado;
		woHija.OTR_SEL_Subestado__c = subestado;
		woPadre.OTR_LKP_Gestor_revision__c = UserInfo.getUserId();
		woHija.OTR_LKP_Gestor_revision__c = UserInfo.getUserId();
		woPadre.OTR_DAT_Fecha_rechazo__c = System.today();
		woHija.OTR_DAT_Fecha_rechazo__c = System.today();

		system.debug('---- woHijaRt: '+woHija.RecordtypeId);
		system.debug('---- wopadreRt: '+woPadre.RecordtypeId);
		system.debug('---- woPadreOrigRt: '+woPadreOrig.RecordtypeId);

		//clonePartidas(woHija,woPadreOrig);
		//copiarUltimoAlbaran(woHija,woPadreOrig);

		woPadre.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '';
		for(Resultado res: motivoList){
			if(res.seleccionado){
				woPadre.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = (woPadre.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c + motivoValores.get(res.motivo) + ';');
			}
			
		}
		woPadre.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = woPadre.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c.removeEnd(';');
		system.debug('------woPadre.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c: ' + woPadre.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c);

		woPadre.OTR_CAS_Partidas_Modificadas_Revision__c = woPadreOrig.OTR_CAS_Partidas_Modificadas_Revision__c;
		
		
		system.debug('PADRE HIJA:'+woPadre);
		system.debug(woHija);

		if(gestorRechazo != null){
			List<User> gRech = [Select Id,Name from user where id = :gestorRechazo];
			if(!gRech.isEmpty()){
				woPadre.OTR_TXT_Gestor_Rechazo__c = gRech[0].Name;
				woHija.OTR_TXT_Gestor_Rechazo__c = gRech[0].Name;
			}
		}

		Baipas.establecerVariableControl();
		update(new List<WorkOrder>{woHija,woPadre});
		Baipas.deshabilitarVariableControl();
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param wo: [PENDIENTE]
	  * @param woPadre: [PENDIENTE]
	  */
	/*private void clonePartidas(WorkOrder wo, WorkOrder woPadre){

		List <WorkOrderLineItem> listaItemsHija = new List<WorkOrderLineItem>([SELECT
		                                                                       Id,
		                                                                       PAR_NUM_Altura__c,
			                                                                   PAR_NUM_Ancho__c,
			                                                                   PAR_TXT_Ceco__c,
			                                                                   PAR_TXT_Baremo_Desc__c,
			                                                                   PAR_CAS_Orden_Trabajo_Anulada__c,
			                                                                   PAR_TXT_Detalle_Venta__c,
			                                                                   PAR_POR_Materiales__c,
			                                                                   PAR_DIV_Precio_Unitario_Venta__c,
			                                                                   PAR_FOR_Precio_Unitario_Venta_Cli__c,
			                                                                   PAR_DIV_Cantidad_Venta__c,
			                                                                   PAR_TXT_Unidades_Medida_Gastos__c,
			                                                                   PAR_SEL_Unidades_Medida__c,
			                                                                   PAR_POR_Descuento__c,
			                                                                   Discount,
			                                                                   PAR_SEL_Codigo_Impuesto_Venta__c,
			                                                                   PAR_CAS_Danos_Esteticos__c,
			                                                                   PAR_POR_Impuesto_Prof__c,
			                                                                   PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
			                                                                   PAR_DIV_ListPrice__c,
			                                                                   PAR_DIV_UnitPrice__c,
			                                                                   PAR_DIV_Facturacion_Total_AI__c,
			                                                                   PAR_DIV_Facturacion_Total_DI__c,
		                                                                       Description,
		                                                                       PAR_TXT_Baremo_Codigo__c,
		                                                                       PAR_DIV_Liquidar_Prof_DI__c,
		                                                                       PAR_DIV_Cargar_Cliente_AI__c,
			                                                                   PAR_DIV_Cargar_Comp_AI__c,
			                                                                   PAR_DIV_Liquidar_Prof_AI__c,
			                                                                   PAR_TXT_Detalle_WOLI__c,
																			   PAR_NUM_Unidades__c,
		                                                                       Status,
		                                                                       PAR_SEL_Danios_Del__c,
		                                                                       WorkOrderId,
		                                                                       WorkOrder.OTR_RES_Facturar_Cliente_AI__c,
		                                                                       WorkOrder.OTR_RES_Subtotal_Partidas__c,
		                                                                       WorkOrder.OTR_RES_Liquidar_prof_AI__c
		                                                                       FROM WorkOrderLineItem 
		                                                                       WHERE WorkOrderId = :wo.Id]);
		List <WorkOrderLineItem> listaItemsPadre = new List<WorkOrderLineItem>([SELECT
		                                                                        Id
		                                                                        FROM WorkOrderLineItem 
		                                                                        WHERE WorkOrderId = :wo.ParentWorkOrderId]);

		List <WorkOrderLineItem> newItemsPadre = new List<WorkOrderLineItem>();

		Boolean hayModificacion = false;

		if(!listaItemsHija.isEmpty()){
			for(WorkOrderLineItem it:listaItemsHija){
				WorkOrderLineItem woliClon = it.clone(false,true);
				woliClon.WorkOrderId = wo.ParentWorkOrderId;
				newItemsPadre.add(woliClon);
				if(it.WorkOrder.OTR_RES_Facturar_Cliente_AI__c != woPadre.OTR_RES_Facturar_Cliente_AI__c ||
						it.WorkOrder.OTR_RES_Subtotal_Partidas__c != woPadre.OTR_RES_Subtotal_Partidas__c ||
						it.WorkOrder.OTR_RES_Liquidar_prof_AI__c != woPadre.OTR_RES_Liquidar_prof_AI__c){
					hayModificacion = true;
				} 
			} 

			try{
				Baipas.establecerVariableControl();//Ahorrar queries
				delete listaItemsPadre;
				Baipas.deshabilitarVariableControl();
				upsert newItemsPadre;
				

				if(hayModificacion){
					woPadre.OTR_CAS_Partidas_Modificadas_Revision__c = true;
					if(wo.OTR_SEL_Penalizacion__c != 'No procede') {
						crearPropuestaEvento(woPadre);
					}
					Util_Orden_Trabajo.avisoModificacionPartidas(new Set<Id>{wo.ParentWorkOrderId});
				}

			}catch(Exception e){
				system.debug('Excepción al insertar las líneas del clon de la WO: ' + e.getMessage());
			}
		}

	}*/


	/**
	  * [PENDIENTE]
	  * 
	  * @param wo: [PENDIENTE]
	  * @param woPadre: [PENDIENTE]
	  */
	/*private void copiarUltimoAlbaran(WorkOrder wo, WorkOrder woPadre){

		List<ServiceReport> albaranesHija = [SELECT ContentVersionDocumentId,DocumentBody,DocumentContentType,DocumentName,Id,ParentId,ServiceReportNumber,Template 
		                                     FROM ServiceReport 
		                                     where ParentId = :wo.Id];

		if(!albaranesHija.isEmpty()){
			ServiceReport aClone = albaranesHija.get(0).clone();
			aClone.ParentId = woPadre.Id;
			insert aClone;
		}

	}*/
	
	private ContentVersion generarPDFRechazo(){
		List<WorkOrder> lista_woPadre = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.ParentWorkOrderId}).values();
		//List<WorkOrder> lista_woPadre = Util_Orden_Trabajo.queryOT(wo.ParentWorkOrderId,null,null);
		WorkOrder woPadre = (!lista_woPadre.isEmpty()) ? (lista_woPadre.get(0)) : null;
		//WorkOrder woPadre = [Select id, WorkOrderNumber from WorkOrder where Id = :wo.ParentWorkOrderId limit 1];
		
		ContentVersion cv = null;
		
		String plantillaPDF = 'RechazoAlbaran'; //TODO: LABEL
		
		Map<String,String> argumentos = new Map<String,String>{'resultados'=>JSON.serialize(motivoList)};
		
		cv = Util_Documentacion.crearPDFDesdeVF(woPadre.Id,null,plantillaPDF,'0000',null,woPadre.WorkOrderNumber,String.valueOf(DateTime.now().getTime()),null,argumentos);

		/*cv = new ContentVersion();
		PageReference pdf = new PageReference('/apex/' + plantillaPDF);

		cv.Title = 'MotivosRechazo_'+woPadre.WorkOrderNumber+'_'+DateTime.now().getTime()+'.pdf';

		try {
			cv.FirstPublishLocationId = woPadre.Id;
			cv.PathOnClient = cv.Title;
			pdf.getParameters().put('id', woPadre.Id);
			pdf.getParameters().put('resultados', JSON.serialize(motivoList));
			if (!Test.isRunningTest()) {
				cv.VersionData = pdf.getContent();
			}
			else {
				//Si es un test le introducimos el Blob de un documento de texto con un caracter 'a'
				cv.VersionData = EncodingUtil.base64Decode('YQ==');
			}
			insert cv;
			system.debug('>>>>>>>>>>>>>>cv: ' + cv);
		}
		catch (exception e) {
			system.debug('>>>>>>>>>>>>>>Excepcion: ' + e.getStackTraceString());
			throw new Util_Documentacion_Exception('Se ha producido un error al generar el documento PDF de ' + plantillaPDF + '.');
		}*/
		return cv;	
	}
	
	
	/*private static void crearPropuestaEvento(WorkOrder ot) {
		String importe = ot.OTR_SEL_Penalizacion__c.replaceAll('€', '');
		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
        evento.EV_AB_LKP_Imputar_a_profesional__c = ot.OTR_LKP_Recurso_Servicio__c;
		evento.EV_AB_DIV_Importe_profesional__c = decimal.valueOf(importe.replaceAll(',', '.'));
		evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
		evento.EV_AB_SEL_Descripcion__c = 'E19';
		evento.EV_AB_LKP_Orden_de_Trabajo__c = ot.Id;
		evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
		evento.EV_AB_SEL_Estado__c = '02';
		evento.EV_AB_LKP_Caso__c = ot.CaseId;
		insert evento;
	}*/

	/**
	  * [PENDIENTE]
	  * 
	  */
	public without sharing class Resultado{
		public Boolean seleccionado {get; set;}
		public String motivo {get; set;}
		public String comentarios {get; set;}
		public Boolean tieneComentarios {get; set;}

		/**
		  * [PENDIENTE]
		  * 
		  * @param seleccionado: [PENDIENTE]
		  * @param motivo: [PENDIENTE]
		  * @param tieneComentarios: [PENDIENTE]
		  */
		public Resultado(Boolean seleccionado, String motivo, Boolean tieneComentarios){
			this.seleccionado = seleccionado;
			this.motivo = motivo;
			this.tieneComentarios = tieneComentarios;
		}
	}

}