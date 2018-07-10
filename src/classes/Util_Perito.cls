public without sharing class Util_Perito {
	/**
	 * Asigna el perito, devuelve el caso actualizado
	 */
	public static Case procesoAsignacion(Case caso){
		system.debug('>>>>Caso: ' + caso);
		if(caso.CAS_CAS_Requiere_Perito__c && caso.CAS_LKP_Perito__c == null){
			// Se busca al perito correcto para asignar al caso
			//Perito__c per = Util_Perito.asignacionAutomatica(caso.CAS_LKP_Compania__c);
			System.debug('Util_Perito: procesoAsignacion: dentro del if: '+(caso.CAS_CAS_Requiere_Perito__c && caso.CAS_LKP_Perito__c == null));
			Perito__c per = Util_Perito.asignacionAutomatica(caso.CAS_LKP_Compania__c,caso.CAS_SEL_DirRiesgo_Estado_Provincia__c);
			System.debug('Util_Perito: procesoAsignacion: despues asignacionAutomatica: '+(caso.CAS_CAS_Requiere_Perito__c && caso.CAS_LKP_Perito__c == null));
			if(per != null){
				// Se asigna el perito al caso
				caso.CAS_LKP_Perito__c = per.Id;
				// Se cambia el estado perito del caso
				caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_INFORME_PRELIMINAR;
				// Enviar mail con info del caso
				//correoPerito(caso, per, Label.PLANTILLA_EMAIL_PERITO_IP);
			}
			//system.debug('<<<< perito' + caso.CAS_LKP_Perito__c);
		}
		return caso;    	
	}


	/*
	*	Método que devuelve peritos obtenidos de un set de Ids de Salesforce
	*  @param setIdPeritos
	*  @return mapa de peritos
	*/
	public static Map<Id, Perito__c>  getPeritoById(Set<Id> setIdPeritos){
		Map<Id, Perito__c> mapaPerito=new Map<Id, Perito__c>();
		if(!setIdPeritos.isEmpty()) {
	        for(List<Perito__c> listaPeritoAux:[SELECT	Name,
	                                            		PER_TLF_Telefono__c,
	                                            		PER_EMA_Email__c
		                                                FROM	Perito__c
		                                                WHERE	Id IN :setIdPeritos]) {
	            mapaPerito.putAll(listaPeritoAux);
	        }
		}
        return mapaPerito;
    }



	public static Map<Id, Perito_Provincia__c>  peritoByIdCompaniaAndProvincia(Set<Id> idCompania, Set<String> provincia){
		Map<Id, Perito_Provincia__c> mapaPerito=new Map<Id, Perito_Provincia__c>();
		if(!idCompania.isEmpty() && !provincia.isEmpty()) {
	        for(List<Perito_Provincia__c> listaPeritoAux:[SELECT
	        							PERP_FOR_Desvio_Asignacion__c,
	        							PERP_NUM_Siniestros_Asignados__c,
	        							PERP_NUM_Sini_Provincia_Compania__c,
	        							PERP_LKP_Perito__c,
	        							PERP_LKP_Perito__r.Name,
	        							PERP_LKP_Perito__r.PER_EMA_Email__c,
	        							PERP_LKP_Perito__r.PER_TLF_Telefono__c
								FROM    Perito_Provincia__c
								WHERE   PERP_LKP_Perito__r.PER_LKP_Compania__c IN :idCompania AND PERP_SEL_Provincia__c IN :provincia
								ORDER BY    PERP_FOR_Desvio_Asignacion__c ASC]) {
	            mapaPerito.putAll(listaPeritoAux);
	        }
		}
        return mapaPerito;
    }
    
    public static Map<Id, Perito_Provincia__c>  peritoByIdCompaniaAndProvinciaSinOrder(Set<Id> idCompania, Set<String> provincia){
		Map<Id, Perito_Provincia__c> mapaPerito=new Map<Id, Perito_Provincia__c>();
		if(!idCompania.isEmpty() && !provincia.isEmpty()) {
	        for(List<Perito_Provincia__c> listaPeritoAux:[SELECT PERP_NUM_Siniestros_Asignados__c, PERP_NUM_Sini_Provincia_Compania__c 
		                                     FROM Perito_Provincia__c 
		                                     WHERE PERP_SEL_Provincia__c = :provincia AND PERP_LKP_Perito__r.PER_LKP_Compania__c = :idCompania]) {
	            mapaPerito.putAll(listaPeritoAux);
	        }
		}
        return mapaPerito;
    }

	public static Perito__c asignacionAutomatica(Id idCompania, String provincia){
		Perito__c peritoAsignado;
		Decimal totalSiniestros = 0.0;
		if(idCompania != null && !String.isBlank(provincia)){

			/*List<Perito_Provincia__c> ppCia = [
			                                   SELECT  PERP_NUM_Siniestros_Asignados__c, PERP_FOR_Desvio_Asignacion__c, PERP_LKP_Perito__c
			                                   FROM    Perito_Provincia__c
			                                   WHERE   PERP_LKP_Perito__r.PER_LKP_Compania__c = :idCompania AND PERP_SEL_Provincia__c = :provincia
			                                   ORDER BY    PERP_FOR_Desvio_Asignacion__c ASC];*/
			List<Perito_Provincia__c> ppCia = peritoByIdCompaniaAndProvincia(new Set<Id>{idCompania}, new Set<String>{provincia}).values();
			if(!ppCia.isEmpty()){

				Perito_Provincia__c perP = ppCia.get(0);
				if(perP.PERP_NUM_Siniestros_Asignados__c != null){
					perP.PERP_NUM_Siniestros_Asignados__c++;
				}else{
					perP.PERP_NUM_Siniestros_Asignados__c = 1;
				}

				for(Perito_Provincia__c pp: ppCia){
					if(pp.PERP_NUM_Siniestros_Asignados__c!=null)
						totalSiniestros += pp.PERP_NUM_Siniestros_Asignados__c;
				}

				for(Perito_Provincia__c pp: ppCia){
					pp.PERP_NUM_Sini_Provincia_Compania__c = totalSiniestros;
				}
		  
				update ppCIA;

				peritoAsignado = new Perito__c(Id=perP.PERP_LKP_Perito__c,
				Name = perP.PERP_LKP_Perito__r.Name,
				PER_TLF_Telefono__c = perP.PERP_LKP_Perito__r.PER_TLF_Telefono__c,
				PER_EMA_Email__c = perP.PERP_LKP_Perito__r.PER_EMA_Email__c);
			} 
		}
		return peritoAsignado;
	}
	
	
	/*public static Perito__c asignacionAutomatica(Id idCompania){
    	Perito__c peritoAsignado;
    	if(idCompania != null){
    		List<Perito__c> peritosCia = new List<Perito__c>([
    			SELECT	PER_NUM_Siniestros_Asignados__c, PER_FOR_Desvio_Asignacion__c
    			FROM	Perito__c
    			WHERE	PER_LKP_Compania__c = :idCompania
    			ORDER BY	PER_FOR_Desvio_Asignacion__c ASC]);

			if(!peritosCia.isEmpty()){
				// Lista ordenada
				peritoAsignado = peritosCia.get(0);
				if(peritoAsignado.PER_NUM_Siniestros_Asignados__c != null){
					peritoAsignado.PER_NUM_Siniestros_Asignados__c++;
				}else{
					peritoAsignado.PER_NUM_Siniestros_Asignados__c = 1;
				}
				update peritoAsignado;
			}
    	}
    	return peritoAsignado;
    }*/

	/**
	 * Devuelve el mensaje del subtítulo indicando que se debe responder al mismo correo electrónico.
	 *
	 * @return String con el mensaje del subtítulo
	 */
	private static String subtitulo(){
		return '<p class="mail-subtitle">ES NECESARIO RESPONDER SOBRE ESTE CORREO PARA PODER VINCULAR LA RESPUESTA AL MISMO HILO DE CORREO ELECTRÓNICO</p>';
	}

	/**
	 * Construye la cabecera del correo al Perito.
	 *
	 * @return String cabecera de Email
	 */
	private static String formarCabeceraEmail(Case caso){
		// Nº7 Marcar en Rojo datos Incorrectos de Email - 25_06_2018 - SMM: En la línea siguiente se modifica el 'width' subiéndolo de 600 a 1200

		String estilos = '<style>.mail-subtitle {margin:0mm;padding:0.5mm;color:gray;font-size:0.8em;}</style>';

		String html2 = estilos+subtitulo()+'<table border="0" cellpadding="30" cellspacing="0" height="100%" width="1200" style="background-color: #fff; width:600px; padding: 0; margin: 0 auto; font-family: Arial, Helvetica; -webkit-text-size-adjust:none !important;">';
		html2 +='<tr><td align="center" valign="top">';
		html2 +='<table style="width:100%; background-color:white; border-bottom:1px solid #e7342c; border-top:1px solid #e7342c; margin: 0;" cellpadding="20" cellspacing="0">';
		html2 += '<tr style="">';
		html2 += '<td style="width:25%; text-align: left;">';
		html2 += '<img style="width:120px;" alt="HomeServe" src="https://www.homeserve.es/img/logo-homeserve.png" />';
		html2 +='</td>';
		html2 +='<td style="color: #e7342c;width: 50%; text-align: right;padding: 0 12px 0 0;font-size: 12px;font-weight: normal;">';
		html2 += 'Asistencias HomeServe';
		html2 +='</td>';
		html2 +='<td  style="width:25%; text-align:right; white-space: nowrap;">';
		html2 +='</td>';
		html2 +='</tr>';
		html2 +='</table>';
		return html2;
	}

	public static void correoPerito(Case caso, Perito__c perito, String template){
		String nombrePerito = null;
		String tlfPerito = null;
		String emailPerito = null;
		if(perito != null){
			nombrePerito = perito.Name;
			tlfPerito = perito.PER_TLF_Telefono__c;
			emailPerito = perito.PER_EMA_Email__c;
		}
		else if(caso != null && caso.CAS_LKP_Perito__r.PER_EMA_Email__c != null){
			nombrePerito = caso.CAS_LKP_Perito__r.Name;
			tlfPerito = caso.CAS_LKP_Perito__r.PER_TLF_Telefono__c;
			emailPerito = caso.CAS_LKP_Perito__r.PER_EMA_Email__c;
		}
		String correoRemitente;
		List<Buzon_CIA__c> listaBuzonCIA = new List<Buzon_CIA__c>(
				[SELECT Id, BUZ_EMA_Direccion__c
				 FROM Buzon_CIA__c
				 WHERE BUZ_LKP_Cuenta__c = :caso.CAS_LKP_Compania__c
				 AND BUZ_SEL_Tipo_Programa__c INCLUDES (:Label.CON_TIPO_PROGRAMA_PERITO)
				 AND BUZ_EMA_Direccion__c != NULL]);
		if(!listaBuzonCIA.isEmpty()){
			correoRemitente = listaBuzonCIA.get(0).BUZ_EMA_Direccion__c;
		}
		System.debug('@@@@@Antes de enviar correo: ' + correoRemitente + template);
		if(caso != null && emailPerito != null && template != null && correoRemitente != null){
			//String correoRemitente = Util_Correo_Electronico.getEmailToSalesforce((caso.OwnerId));
			Contact contactoDest = Util_Correo_Electronico.generarDummyContact(nombrePerito, nombrePerito, emailPerito, tlfPerito, null);
			System.debug('@@@@@Antes de enviar correo: ' + contactoDest + correoRemitente + template);
			Util_Correo_Electronico.enviarSingleEmailMessage(JSON.serialize(caso), null, null, contactoDest, correoRemitente, null, template, null);
		}
	}

	/**
	 * Envía un correo con los comentarios de un caso a un Perito.
	 *
	 * @param caso: Objeto Case asociado a los comentarios
	 * @param per: Objeto Perito__c del destinatario
	 */
	public static void correoIPPerito(Case caso, Perito__c per){
		Messaging.SingleEmailMessage correoPerito = new Messaging.SingleEmailMessage();
		String destinatario = Util_Correo_Electronico.getEmailToSalesforce((caso.OwnerId));
		System.debug('@@@@UTIL_PERITO: OwnerId: '+caso.OwnerId);
		System.debug('@@@@UTIL_PERITO: destinatario: '+destinatario);
		if(per.PER_EMA_Email__c != null & destinatario!=null){
			correoPerito.setToAddresses(new String[] {per.PER_EMA_Email__c,destinatario});
			//correoPerito.setToAddresses(new String[] {'santiago.benito.montoya@everis.com', Label.EMAIL_TO_SALESFORCE});
			//correoPerito.setBccAddresses(new String[] {'emailtosalesforce@z-ysv5n4euyb62t0xvodftw79mgky67e3b6jtuta9kslkmv0w4d.9e-ckpuai.cs88.le.sandbox.salesforce.com'});
			correoPerito.setSenderDisplayName('Salesforce');
			correoPerito.setSubject(Label.TAR_ASUNTO_RECORDATORIO_IP);
			String cabecera = formarCabeceraEmail(caso);
			String cuerpoCorreo = cabecera;
			cuerpoCorreo += '<p style="width: 100%; font-size: 12px; font-weight: normal;">Es necesario el Informe Preliminar para el siniestro: '+caso.CaseNumber+', adjúntelo a la respuesta a este correo electrónico</p>';
			cuerpoCorreo += '<table>';
			for(Comentario_caso__c c : [SELECT Id,CMC_TXT_Comentario__c FROM Comentario_caso__c WHERE CMC_LKP_Caso__c =: caso.Id AND CMC_SEL_Tipo__c = '08']){
				cuerpoCorreo += '<tr><td><b>Comentario del gestor: </b></td><td>' + c.CMC_TXT_Comentario__c+'</td></tr>';
			}
			cuerpoCorreo += '</table>';
			//correoPerito.setPlainTextBody(cuerpoCorreo);
			correoPerito.setHTMLBody(cuerpoCorreo);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {correoPerito});
		}
	}

	public static void correoIDPerito(Case caso, Perito__c per){
		Messaging.SingleEmailMessage correoPerito = new Messaging.SingleEmailMessage();
		correoPerito.setToAddresses(new String[] {per.PER_EMA_Email__c, Label.EMAIL_TO_SALESFORCE});
		//correoPerito.setToAddresses(new String[] {'santiago.benito.montoya@everis.com', Label.EMAIL_TO_SALESFORCE});
		//correoPerito.setBccAddresses(new String[] {'emailtosalesforce@z-ysv5n4euyb62t0xvodftw79mgky67e3b6jtuta9kslkmv0w4d.9e-ckpuai.cs88.le.sandbox.salesforce.com'});
		correoPerito.setSenderDisplayName('Salesforce');
		correoPerito.setSubject(Label.TAR_ASUNTO_RECORDATORIO_ID);
		String cuerpoCorreo = 'Es necesario el Informe Definitivo para el siniestro: CASENUMBER, adjúntelo a la respuesta a este correo electrónico\n\n';
		cuerpoCorreo += 'ref: ' + caso.Id;
		correoPerito.setPlainTextBody(cuerpoCorreo);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {correoPerito});
	}

	public static void correoResPerito(Case caso, Perito__c per){
		Messaging.SingleEmailMessage correoPerito = new Messaging.SingleEmailMessage();
		correoPerito.setToAddresses(new String[] {per.PER_EMA_Email__c, Label.EMAIL_TO_SALESFORCE});
		//correoPerito.setToAddresses(new String[] {'santiago.benito.montoya@everis.com', Label.EMAIL_TO_SALESFORCE});
		//correoPerito.setBccAddresses(new String[] {'emailtosalesforce@z-ysv5n4euyb62t0xvodftw79mgky67e3b6jtuta9kslkmv0w4d.9e-ckpuai.cs88.le.sandbox.salesforce.com'});
		correoPerito.setSenderDisplayName('Salesforce');
		correoPerito.setSubject(Label.TAR_ASUNTO_RECORDATORIO_RES);
		String cuerpoCorreo = 'Es necesario el Informe Definitivo para el siniestro: CASENUMBER, adjúntelo a la respuesta a este correo electrónico\n\n';
		cuerpoCorreo += 'ref: ' + caso.Id;
		correoPerito.setPlainTextBody(cuerpoCorreo);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {correoPerito});
	}

	public static void correoMinutaPerito(Case caso, Perito__c per){
		Messaging.SingleEmailMessage correoPerito = new Messaging.SingleEmailMessage();
		correoPerito.setToAddresses(new String[] {per.PER_EMA_Email__c, Label.EMAIL_TO_SALESFORCE});
		//correoPerito.setToAddresses(new String[] {'santiago.benito.montoya@everis.com', Label.EMAIL_TO_SALESFORCE});
		//correoPerito.setBccAddresses(new String[] {'emailtosalesforce@z-ysv5n4euyb62t0xvodftw79mgky67e3b6jtuta9kslkmv0w4d.9e-ckpuai.cs88.le.sandbox.salesforce.com'});
		correoPerito.setSenderDisplayName('Salesforce');
		correoPerito.setSubject(Label.TAR_ASUNTO_RECORDATORIO_MINUTA);
		String cuerpoCorreo = 'Es necesario la minuta del siniestro: CASENUMBER, adjúntelo a la respuesta a este correo electrónico\n\n';
		cuerpoCorreo += 'ref: ' + caso.Id;
		correoPerito.setPlainTextBody(cuerpoCorreo);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {correoPerito});
	}

	public static List<Task> controlInformesPerito(Case caso, Map<Id, Case> triggerOldMap, Map<Id, List<Task>> mapaTareasCaso){
		List<Task> listaTareasACerrar = new List<Task>();
		Case casoOld;
		if(trigger.isUpdate){
			casoOld = triggerOldMap.get(caso.Id);

			// Si se ha marcado el campo Informe Preliminar Recibido
			if(caso.CAS_CAS_Informe_Preliminar_Recibido__c
					&& (caso.CAS_CAS_Informe_Preliminar_Recibido__c != casoOld.CAS_CAS_Informe_Preliminar_Recibido__c)){
				if(trigger.isBefore){
					caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_VAL_PER;
				}else{
					// Se cierran todas las tareas en curso de Recordatorio de Envio de IP si se ha marcado la casilla
					listaTareasACerrar.addAll(Util_Tarea.cerrarTareasCaso(caso, Label.TAR_ASUNTO_RECORDATORIO_IP, mapaTareasCaso));
				}
			}

			// Si se ha marcado el campo Informe Preliminar Tramitado
			if(caso.CAS_CAS_Informe_Preliminar_Tramitado__c
					&& (caso.CAS_CAS_Informe_Preliminar_Tramitado__c != casoOld.CAS_CAS_Informe_Preliminar_Tramitado__c)){
				if(trigger.isBefore){
					caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_INFORME_DEFINITIVO;
				}else{
					// Se cierran todas las tareas en curso de Recordatorio de Revisión de IP si se ha marcado la casilla
					listaTareasACerrar.addAll(Util_Tarea.cerrarTareasCaso(caso, Label.TAR_ASUNTO_REVISION_IP, mapaTareasCaso));
				}
			}
			// Si se ha marcado el campo Informe Definitivo Recibido
			if(caso.CAS_CAS_Informe_Definitivo_Recibido__c
					&& (caso.CAS_CAS_Informe_Definitivo_Recibido__c != casoOld.CAS_CAS_Informe_Definitivo_Recibido__c)){
				if(trigger.isBefore){
					caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_VAL_PER;
				}else{
					// Se cierran todas las tareas en curso de Recordatorio de Envio de ID si se ha marcado la casilla
					listaTareasACerrar.addAll(Util_Tarea.cerrarTareasCaso(caso, Label.TAR_ASUNTO_RECORDATORIO_ID, mapaTareasCaso));
				}
			}

			// Si se ha marcado el campo Informe Definitivo Tramitado
			if(caso.CAS_CAS_Informe_Definitivo_Tramitado__c
					&& (caso.CAS_CAS_Informe_Definitivo_Tramitado__c != casoOld.CAS_CAS_Informe_Definitivo_Tramitado__c)){
				if(trigger.isBefore){
					caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_INFORME_COMPLEMENTARIO;
				}else{
					// Se cierran todas las tareas en curso de Recordatorio de Revisión de ID si se ha marcado la casilla
					listaTareasACerrar.addAll(Util_Tarea.cerrarTareasCaso(caso, Label.TAR_ASUNTO_REVISION_ID, mapaTareasCaso));
				}
			}

			// Si se ha marcado el campo Informe Definitivo Recibido
			/*if(caso.CAS_CAS_Informe_Definitivo_Recibido__c){
				if(caso.CAS_DIV_Pago_de_Minuta__c != null	// Si se ha informado el importe del pago de la minuta
				 || caso.CAS_DIV_Importe_Reserva_Perito__c != null){	// O el importe de la reserva del perito
					if(trigger.isBefore){
						if(caso.CAS_DIV_Pago_de_Minuta__c != null
						 && caso.CAS_DIV_Importe_Reserva_Perito__c != null){
						 	// El estado perito pasa a Cerrado si se han informado el importe del pago de la minuta y de la reserva
							caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_CERRADO;	
						}
					}else if(casoOld == null
					 || (casoOld != null 
					  && (caso.CAS_CAS_Informe_Definitivo_Recibido__c != casoOld.CAS_CAS_Informe_Definitivo_Recibido__c
					   || caso.CAS_DIV_Pago_de_Minuta__c != casoOld.CAS_DIV_Pago_de_Minuta__c))){
					   	// Se cierran todas las tareas en curso de Recordatorio de Minuta si se ha informado el importe
						listaTareasACerrar.addAll(Util_Tarea.cerrarTareasCaso(caso, Label.TAR_ASUNTO_RECORDATORIO_MINUTA, mapaTareasCaso));
					}else if(casoOld == null
					 || (casoOld != null 
					  && (caso.CAS_CAS_Informe_Definitivo_Recibido__c != casoOld.CAS_CAS_Informe_Definitivo_Recibido__c
					   || caso.CAS_DIV_Importe_Reserva_Perito__c != casoOld.CAS_DIV_Importe_Reserva_Perito__c))){
					   	// Se cierran todas las tareas en curso de Recordatorio de Reserva si se ha informado el importe
						listaTareasACerrar.addAll(Util_Tarea.cerrarTareasCaso(caso, Label.TAR_ASUNTO_RECORDATORIO_RES, mapaTareasCaso));
					}
				}
				else if(casoOld == null // Si es nuevo
				 || caso.CAS_CAS_Informe_Definitivo_Recibido__c != casoOld.CAS_CAS_Informe_Definitivo_Recibido__c){	// O si ha variado el valor
					if(trigger.isBefore){
						caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_VAL_PER;
					}else{
						// Se cierran todas las tareas en curso de Recordatorio de Envio de ID si se ha marcado la casilla
						listaTareasACerrar.addAll(Util_Tarea.cerrarTareasCaso(caso, Label.TAR_ASUNTO_RECORDATORIO_ID, mapaTareasCaso));
					}
				}
			}*/
		}
		
		return listaTareasACerrar;
	}

	public static Case fechaSolicitudPerito(Case caso, Case casoOld,Perito__c Perito, Procedencia__c procedencia){
		//1.2.0. Si está marcado el check de solicitar perito y el campo fecha está vacío
		if(caso.CAS_CAS_Requiere_Perito__c && casoOld.CAS_CAS_Requiere_Perito__c!=caso.CAS_CAS_Requiere_Perito__c){
			caso.CAS_DAT_Fecha_Asignacion_Perito__c = System.now();
		}
		//1.2.1. Si está marcado el check de Presolicitud de Perito y el campo fecha está vacío
		if(caso.CAS_CAS_Presolicitud_Perito__c  && casoOld.CAS_CAS_Presolicitud_Perito__c!=caso.CAS_CAS_Presolicitud_Perito__c){
			caso.CAS_DAT_Fecha_Solicitud_Perito__c = System.now();
		}
		//1.2.2. Si está marcado el check de Informe Preliminar Recibido y el campo fecha está vacío
		if(caso.CAS_CAS_Informe_Preliminar_Recibido__c  && casoOld.CAS_CAS_Informe_Preliminar_Recibido__c!=caso.CAS_CAS_Informe_Preliminar_Recibido__c){
			caso.CAS_DAT_Fecha_Informe_Preli_Recibido__c = System.now();
		}
		//1.2.3. Si está marcado el check de Informe Preliminar Tramitado y el campo fecha está vacío
		System.debug('@@@Util_Perito:fechasolicitud informe pre tramitado' + caso.CAS_CAS_Informe_Preliminar_Tramitado__c);
		if(caso.CAS_CAS_Informe_Preliminar_Tramitado__c  && casoOld.CAS_CAS_Informe_Preliminar_Tramitado__c!=caso.CAS_CAS_Informe_Preliminar_Tramitado__c){
			caso.CAS_DAT_Fecha_Informe_Preli_Tramitado__c = System.now();
			System.debug('@@@@@@Util_Perito: fechasolicitud: Antes de llamada a correoPerito');
			//correoPerito(caso, perito, Label.PLANTILLA_EMAIL_PERITO_ID);
			caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_INFORME_DEFINITIVO;
		}
		//1.2.4. Si está marcado el check de Informe Definitivo Recibido y el campo fecha está vacío
		if(caso.CAS_CAS_Informe_Definitivo_Recibido__c  && casoOld.CAS_CAS_Informe_Definitivo_Recibido__c!=caso.CAS_CAS_Informe_Definitivo_Recibido__c){
			caso.CAS_DAT_Fecha_Informe_Def_Recibido__c = System.now();
		}
		//1.2.5. Si está marcado el check de Informe Definitivo Tramitado y el campo fecha está vacío
		if(caso.CAS_CAS_Informe_Definitivo_Tramitado__c && casoOld.CAS_CAS_Informe_Definitivo_Tramitado__c!=caso.CAS_CAS_Informe_Definitivo_Tramitado__c){
			caso.CAS_DAT_Fecha_Informe_Pericial__c = Date.Today();
			if(!procedencia.PROC_CAS_Requiere_Pago_Minuta__c) {
				caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_CERRADO;
			}
		}
		//1.2.6. Si está marcado el check de Informe Complementario Recibido y el campo fecha está vacío
		if(caso.CAS_CAS_Informe_Complementario_Recibido__c && casoOld.CAS_CAS_Informe_Complementario_Recibido__c!=caso.CAS_CAS_Informe_Complementario_Recibido__c
				&& caso.CAS_DAT_Fecha_Informe_Compl_Recibido__c == null){
			caso.CAS_DAT_Fecha_Informe_Compl_Recibido__c = System.now();
		}
		//1.2.7. Si está marcado el check de Informe Complementario Tramitado y el campo fecha está vacío
		if(caso.CAS_CAS_Informe_Complementario_Tramitado__c  && casoOld.CAS_CAS_Informe_Complementario_Tramitado__c!=caso.CAS_CAS_Informe_Complementario_Tramitado__c
				&& caso.CAS_DAT_Fecha_Informe_Compl_Tramitado__c == null){
			caso.CAS_DAT_Fecha_Informe_Compl_Tramitado__c = System.now();
		}
		return caso;
	}
}