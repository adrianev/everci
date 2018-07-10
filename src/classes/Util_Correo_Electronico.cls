/**
 * Clase de funciones relativas al Envio de emails.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Correo_Electronico {

	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  */
	public static void envioMasivoTemplate(String IdCaso, Id identificadorCIA, String tipoDePrograma, String idioma, List<Contact> listaContactos,
										   String remitente, ContentVersion documento, String template, String tipoDestino){
		if(listaContactos == null || listaContactos.isEmpty())
			throw new Util_Correo_Electronico_Exception('No se ha especificado destinatario del correo');

		ID[] CasoId = new ID[listaContactos.size()];
		Integer z = 0;
		for (z = 0; z < listaContactos.size(); z++) {
			CasoId[z++] = IdCaso;
		}

		ID[] ContactosIds = new ID[listaContactos.size()];
		Integer i = 0;
		for (Contact c: listaContactos) {
			ContactosIds[i++] = c.Id;
		}
		Id templateId = devolverTemplateId(new Case(id=IdCaso,CAS_LKP_Compania__c=identificadorCIA), tipoDePrograma, idioma, template, tipoDestino);

		if(templateId == null)
			throw new Util_Correo_Electronico_Exception('No se ha encontrado plantilla para este correo');

		Id direccionRemitente = null;

		List<Messaging.SendEmailResult> resultMail = new List<Messaging.SendEmailResult>();

		if(documento == null && remitente == null && IdCaso == null){
			Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
			mail.setTargetObjectIds(ContactosIds);
			mail.setTemplateId(templateId);
			Baipas.establecerVariableControl();
			resultMail = Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
			Baipas.deshabilitarVariableControl();
		}
		else {
			if(remitente != null){
                system.debug(remitente + 'remitenteeeeeeeeeeeeee');
                OrgWideEmailAddress[] owea = getOWEmailAddressByAddress(new Set<String>{remitente}).values();
				/*OrgWideEmailAddress[] owea = [  SELECT Id 
												FROM OrgWideEmailAddress 
												WHERE Address = :remitente];*/
				if(owea.size() > 0){
					direccionRemitente = owea.get(0).Id;
				}
				else {
					throw new Util_Correo_Electronico_Exception('No se ha encontrado la dirección de organización remitente especificada');
				}
			}

			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

			for(Integer j = 0;j < contactosIds.size(); j++){
				Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
				correo.setTargetObjectId(contactosIds[j]);
				correo.setTemplateId(templateId);
				if(documento != null)
					correo.setEntityAttachments(new Id[] {documento.Id});
				if(remitente != null)
					correo.setOrgWideEmailAddressId(direccionRemitente);

				correo.setWhatId(IdCaso);

				mails.add(correo);
			}
			Baipas.establecerVariableControl();			
			resultMail = Messaging.sendEmail(mails);
			Baipas.deshabilitarVariableControl();
		}

		Boolean error = false;
		String errores = 'Se han encontrado los siguientes errores al enviar correos: ';
		for(Messaging.SendEmailResult resultado: resultMail){
			if(!resultado.isSuccess()){
				error = true;
				errores += resultado.getErrors().get(0).getMessage() + '; ';
			}  
		}

		if(error)
			throw new Util_Correo_Electronico_Exception(errores);
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  */
	public static void enviarSingleEmailMessage(String casoSerializado, String tipoDePrograma, String idioma, Contact contacto, String remitente, ContentVersion documento, String template, String tipoDestino){
		if(contacto == null)
			throw new Util_Correo_Electronico_Exception('No se ha especificado destinatario del correo');

		Case caso = (Case)JSON.deserialize(casoSerializado, Case.class);
		Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
		Id templateId = devolverTemplateId(caso, tipoDePrograma, idioma, template, tipoDestino);
		if(templateId != null){
			correo.setTemplateId(templateId);
		}
		else {
			throw new Util_Correo_Electronico_Exception('No se ha encontrado plantilla para este correo');
		}
		if(remitente != null){
			OrgWideEmailAddress[] owea = getOWEmailAddressByAddress(new Set<String>{remitente}).values();
			/*OrgWideEmailAddress[] owea = [	SELECT Id 
										  	FROM OrgWideEmailAddress 
										  	WHERE Address = :remitente];*/
			if(owea.size() > 0){
				correo.setOrgWideEmailAddressId(owea.get(0).Id);
			} else {
				throw new Util_Correo_Electronico_Exception('No se ha encontrado la dirección de organización remitente especificada');
			}
		}

		if(documento != null){
			correo.setEntityAttachments(new Id[] {documento.Id});	
		}
		correo.setWhatId(caso.Id);
		correo.setTargetObjectId(contacto.Id);
		//Send Email
		Baipas.establecerVariableControl();			
		List<Messaging.SendEmailResult> resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {correo});
		Baipas.deshabilitarVariableControl();
		if(contacto.CON_CAS_ContactoDummy__c){
			List<Task> tareasEmail = Util_Tarea.getTareaByWhoId(new Set<Id>{contacto.Id}).values();
			//List<Task> tareasEmail = [Select id, whoId from Task where whoId = :contacto.Id];
			//Si borramos el contacto y se ha creado una tarea al mandar el correo, también se 
			//borrará a menos que borremos el whoId de la tarea
			if(!tareasEmail.isEmpty()){
				for(Task t: tareasEmail)
					t.WhoId = null;
				Baipas.establecerVariableControl();			
				update tareasEmail;
				Baipas.deshabilitarVariableControl();
			}

			Baipas.establecerVariableControl();			
			delete contacto;
			Baipas.deshabilitarVariableControl();
		}

		Boolean error = false;
		String errores = 'Se han encontrado los siguientes errores al enviar correos: ';
		for(Messaging.SendEmailResult resultado: resultMail){
			if(!resultado.isSuccess()){
				error = true;
				errores += resultado.getErrors().get(0).getMessage() + '; ';
			}  
		}

		if(error)
			throw new Util_Correo_Electronico_Exception(errores);

	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */  
	public static void enviarSingleEmailSinPlantilla(Id objetoRelacionado, String asunto, String cuerpo, String tipoCuerpo, Id destinatario, List<String> ccDestinatarios, List<Id> adjunto, String remitente,String remitenteCustom){
		if(destinatario == null && (ccDestinatarios == null || ccDestinatarios.isEmpty()))
			throw new Util_Correo_Electronico_Exception('No se ha especificado destinatario del correo');

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		mail.setTargetObjectId(destinatario);
		//mail.setToAddresses(destinatarios);
		mail.setCCAddresses(ccDestinatarios);
		mail.setSubject(asunto);

		Contact contacto = null;

		if(destinatario != null){
			if(Schema.Contact.SObjectType != destinatario.getSObjectType()){
				mail.setSaveAsActivity(false);
			}
			else {
				contacto = Util_Contacto.getContactById(new Set<Id>{destinatario}).get(destinatario);
				//contacto = [Select id, CON_CAS_ContactoDummy__c from contact where id = :destinatario limit 1];
			}
		}
		mail.setUseSignature(false);
		if(tipoCuerpo == 'HTML')
			mail.setHTMLBody(cuerpo);
		else
			mail.setPlainTextBody(cuerpo);

		if(remitente != null){
			OrgWideEmailAddress[] owea = getOWEmailAddressByAddress(new Set<String>{remitente}).values();
			/*OrgWideEmailAddress[] owea = [  SELECT Id 
											FROM OrgWideEmailAddress 
											WHERE Address = :remitente];*/
			if(owea.size() > 0){
				mail.setOrgWideEmailAddressId(owea.get(0).Id);
			}
			else {
				throw new Util_Correo_Electronico_Exception('No se ha encontrado la dirección de organización remitente especificada');
			}
		}
        if(remitenteCustom !=null) {
            mail.setSenderDisplayName(remitenteCustom);
        }

		mail.setWhatId(objetoRelacionado);
		if(adjunto != null){
			mail.setEntityAttachments(adjunto);   
		}

		Baipas.establecerVariableControl();
		List<Messaging.SendEmailResult> resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		Baipas.deshabilitarVariableControl();

		if(contacto != null && contacto.CON_CAS_ContactoDummy__c){
			List<Task> tareasEmail = Util_Tarea.getTareaByWhoId(new Set<Id>{contacto.Id}).values();
			//List<Task> tareasEmail = [Select id, whoId from Task where whoId = :contacto.Id];
			//Si borramos el contacto y se ha creado una tarea al mandar el correo, también se 
			//borrará a menos que borremos el whoId de la tarea
			if(!tareasEmail.isEmpty()){
				for(Task t: tareasEmail)
					t.WhoId = null;
				Baipas.establecerVariableControl();
				update tareasEmail;
				Baipas.deshabilitarVariableControl();
			}

			Baipas.establecerVariableControl();
			delete contacto;
			Baipas.deshabilitarVariableControl();
		}

		Boolean error = false;
		String errores = 'Se han encontrado los siguientes errores al enviar correos: ';
		for(Messaging.SendEmailResult resultado: resultMail){
			if(!resultado.isSuccess()){
				error = true;
				errores += resultado.getErrors().get(0).getMessage() + '; ';
			}  
		}

		if(error)
			throw new Util_Correo_Electronico_Exception(errores);
	}

	public static List<Contact> getListaContactos(Id idCuenta, String codigoCIA, String tipoPrograma){
		List<Contact> lista = new List<Contact>();
		if(codigoCIA != null){
			if(tipoPrograma != null){
				lista = Util_Contacto.getContactByIdExtCueAndTipoProg(new Set<String>{codigoCIA},tipoPrograma).values();
				/*lista = new List<Contact>(
					[SELECT Id, CON_CAS_ContactoDummy__c
					 FROM Contact
					 WHERE Account.CUE_TXT_Identificador__c = :codigoCIA
					 AND CON_SEL_Tipo_Programa__c INCLUDES (:tipoPrograma)
					 AND Email != null]);*/
			}
			else {
				lista = Util_Contacto.getContactByIdExtCue(new Set<String>{codigoCIA}).values();
				/*lista = new List<Contact>(
					[SELECT Id, CON_CAS_ContactoDummy__c
					 FROM Contact
					 WHERE Account.CUE_TXT_Identificador__c = :codigoCIA
					 AND Email != null]);*/		
			}
		}
		else if(idCuenta != null){
			if(tipoPrograma != null){
				lista = Util_Contacto.getContactByCuentaAndTipoProg(new Set<Id>{idCuenta},tipoPrograma).values();
				/*lista = new List<Contact>(
					[SELECT Id, CON_CAS_ContactoDummy__c
					 FROM Contact
					 WHERE AccountId = :idCuenta
					 AND CON_SEL_Tipo_Programa__c INCLUDES (:tipoPrograma)
					 AND Email != null]);*/
			}
			else {
				lista = Util_Contacto.getContactByCuenta(new Set<Id>{idCuenta}).values();
				/*lista = new List<Contact>(
					[SELECT Id, CON_CAS_ContactoDummy__c
					 FROM Contact
					 WHERE AccountId = :idCuenta
					 AND Email != null]);*/			
			}
		}
		return lista;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	public static String getBuzonCIA(String codCia, String tipoPrograma){
		String buzon = null;
		if(codCia != null && tipoPrograma != null){
			List<Buzon_CIA__c> listaBuzonCIA = getBuzonCIAByIdExtCueAndTipoProg(new Set<String>{codCia},tipoPrograma).values();
			/*List<Buzon_CIA__c> listaBuzonCIA = new List<Buzon_CIA__c>(
					[SELECT Id, BUZ_EMA_Direccion__c
					 FROM Buzon_CIA__c
					 WHERE BUZ_LKP_Cuenta__r.CUE_TXT_Identificador__c = :codCia
					 AND BUZ_SEL_Tipo_Programa__c INCLUDES (:tipoPrograma)
					 AND BUZ_EMA_Direccion__c != NULL]);*/
			if(!listaBuzonCIA.isEmpty()){
				buzon = listaBuzonCIA.get(0).BUZ_EMA_Direccion__c;
			}
		}
		return buzon;
	}
	
		/**
	  * Método que obtiene los Buzones asociados a un conjunto de direcciones de Email
	  * 
	  * @param direccionesMail: conjunto de direcciones de Email de las que obtener un buzon
	  * 
	  * @return Mapa de objetos Buzon_CIA__c que corresponden al conjunto de direcciones proporcionadas como input
	  */
	public static Map<Id,Buzon_CIA__c> getBuzonCIAByDireccionEmail(Set<String> direccionesMail){
		Map<Id,Buzon_CIA__c> mapa = new Map<Id,Buzon_CIA__c>();
		if(direccionesMail != null && !direccionesMail.isEmpty()){
			for(List<Buzon_CIA__c> lista: [SELECT Id,
												BUZ_LKP_Cuenta__c,
												BUZ_EMA_Direccion__c
											 FROM Buzon_CIA__c
											 WHERE BUZ_EMA_Direccion__c IN :direccionesMail]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	
	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	private static Id devolverTemplateId(Case caso, String tipoDePrograma, String idioma, String template, String tipoDestino){
		Id idEmailTemplate = null;
		List<EmailTemplate> listaTemplate = new List<EmailTemplate>();
		if(template == null){
			if(idioma != null){
				idioma = '_' + idioma;
			}
			else {
				idioma = '';
			}
			if(tipoDestino != null){
				tipoDestino = '_' + tipoDestino;
			}
			else {
				tipoDestino = '';
			}
			List<Account> listaCIA = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.CAS_LKP_Compania__c}).values();
			/*List<Account> listaCIA = [SELECT CUE_TXT_Identificador__c
									  FROM Account 
									  WHERE Id = :caso.CAS_LKP_Compania__c];*/
			String codigoCIA = '';
			if(!listaCIA.isEmpty()){
				codigoCIA = listaCIA.get(0).CUE_TXT_Identificador__c;
			}
			
			List<String> nombresAPIPlantilla = new List<String>();
			// Buscar plantilla con CIA
			nombresAPIPlantilla.add('PCE_' + codigoCIA + '_' + tipoDePrograma + idioma + tipoDestino);
			// Buscar plantilla con CIA HomeServe
			nombresAPIPlantilla.add('PCE_' + Label.IDE_HOMESERVE + '_' + tipoDePrograma + idioma + tipoDestino);
			// Buscar plantilla con CIA con idioma por defecto
			nombresAPIPlantilla.add('PCE_' + codigoCIA + '_' + tipoDePrograma + Label.IDIOMA_POR_DEFECTO + tipoDestino);
			// Buscar plantilla con CIA HomeServe con idioma por defecto
			nombresAPIPlantilla.add('PCE_' + Label.IDE_HOMESERVE + '_' + tipoDePrograma + Label.IDIOMA_POR_DEFECTO + tipoDestino);
			
			for(String nombre : nombresAPIPlantilla){
				if(listaTemplate.isEmpty()){
					listaTemplate = getEmailTemplateByDevNameAndActive(new Set<String>{nombre},true).values();
					/*listaTemplate = [SELECT Id
									 FROM EmailTemplate
							 		 WHERE IsActive = true
									 AND DeveloperName = :nombre];*/
				}
			}
		}
		else {
			listaTemplate = getEmailTemplateByDevNameAndActive(new Set<String>{template},true).values();
			/*listaTemplate = [SELECT Id
							 FROM EmailTemplate 
							 WHERE IsActive = true
							 AND DeveloperName = :template];*/
		}
		System.debug('util correo electronico tempate'+ listaTemplate);
		if(!listaTemplate.isEmpty()){
			idEmailTemplate = listaTemplate.get(0).Id;
		}
		return idEmailTemplate;
	}

	public static Contact generarDummyContact(String nombre, String apellidos, String correo, String telefono, String telefono1){
		Contact con = new Contact();
		con.FirstName = nombre;
		con.LastName = apellidos;
		con.Email = correo;
		con.Phone = telefono;
		con.OtherPhone = telefono1;
		con.CON_CAS_ContactoDummy__c=true;
		con.CON_TXT_Identificador__c = 'Dummy'+Datetime.now().getTime();
		Baipas.establecerVariableControl();
		insert con;
		Baipas.deshabilitarVariableControl();
		return con;
	}

	/**
	 * Devuelve los OrgWideEmailAddress filtrados por el remitente.
	 *
	 * @param setAddress: conjunto de remitentes
	 *
	 * @return mapa que contiene los OrgWideEmailAddress encontrados
	 */
	public static Map<Id,OrgWideEmailAddress> getOWEmailAddressByAddress(Set<String> setAddress){
		Map<Id,OrgWideEmailAddress> mapa = new Map<Id,OrgWideEmailAddress>();
		if(setAddress != null && !setAddress.isEmpty()){
			for(List<OrgWideEmailAddress> lista:[SELECT Id FROM OrgWideEmailAddress WHERE Address IN :setAddress]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los EmailTemplates filtrados por IsActive y DeveloperName.
	 *
	 * @param setDevName: conjunto de DeveloperNames
	 * @param boolActive: true si está activo, false en otro caso
	 *
	 * @return mapa que contiene los EmailTemplates encontrados
	 */
	public static Map<Id,EmailTemplate> getEmailTemplateByDevNameAndActive(Set<String> setDevName, Boolean boolActive){
		Map<Id,EmailTemplate> mapa = new Map<Id,EmailTemplate>();
		if(setDevName != null && !setDevName.isEmpty() && boolActive != null){
			for(List<EmailTemplate> lista:[SELECT Id FROM EmailTemplate WHERE IsActive = :boolActive AND DeveloperName IN :setDevName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve los EmailTemplates filtrados por  DeveloperName.
	 *
	 * @param setDevName: conjunto de DeveloperNames
	 *
	 * @return mapa que contiene los EmailTemplates encontrados
	 */
	public static Map<Id,EmailTemplate> getEmailTemplateByDevName(Set<String> setDevName){
		Map<Id,EmailTemplate> mapa = new Map<Id,EmailTemplate>();
		if(setDevName != null && !setDevName.isEmpty() ){
			for(List<EmailTemplate> lista:[SELECT Id, Body, Subject FROM EmailTemplate WHERE  DeveloperName IN :setDevName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Buzon_CIA__c filtrados por los identificadores externos de Cuenta y el tipo de programa.
	 *
	 * @param setIdentificadorCuenta: conjunto de identificadores externos de Cuenta
	 * @param tipoPrograma: tipo de programa
	 *
	 * @return mapa que contiene los Buzon_CIA__c encontrados
	 */
	public static Map<Id,Buzon_CIA__c> getBuzonCIAByIdExtCueAndTipoProg(Set<String> setIdentificadorCuenta, String tipoPrograma){
		Map<Id,Buzon_CIA__c> mapa = new Map<Id,Buzon_CIA__c>();
		if(setIdentificadorCuenta != null && !setIdentificadorCuenta.isEmpty() && tipoPrograma != null){
			for(List<Buzon_CIA__c> lista:[SELECT Id,BUZ_EMA_Direccion__c,BUZ_LKP_Cuenta__c
											FROM Buzon_CIA__c
											WHERE BUZ_LKP_Cuenta__r.CUE_TXT_Identificador__c IN :setIdentificadorCuenta
											AND BUZ_SEL_Tipo_Programa__c INCLUDES (:tipoPrograma)
											AND BUZ_EMA_Direccion__c != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/*
	*   getBuzonCIABy_TXTIdCuenta_AND_TipoPrograma: Consulta de Buzon asociado a un set de cuenta y a un tipo de programa
	*
	*        @param codCia: set de códigos identificadores de compañía
	*   @param setTipoPrograma: set de tipos de programa asociados.
	
	*        @return Mapa de buzones obtenidos
	*/
	public static  Map<Id,Buzon_CIA__c> getBuzonCIABy_TXTIdCuenta_AND_TipoPrograma(Set<String> codCia, Set<String> setTipoPrograma){
	        Map <Id,Buzon_CIA__c> mapaBuzon = new Map<Id,Buzon_CIA__c> ();
	        
	        String includeStatement ;
	
	        if(codCia != null && !codCia.isEmpty() && setTipoPrograma != null && !setTipoPrograma.isEmpty()){
	                
	                //Generamos el statement de include A;B;C ....
	                Integer i = 0;
	                
	                for(String tipoPrograma: setTipoPrograma){
	                        includeStatement += tipoPrograma;
	                        if(i<setTipoPrograma.size()){ //Si no es el último elemento del set, entonces añadimos ';'
	                        includeStatement +=';';
	                            system.debug(includeStatement + ' includeStatement');
	                        }
	                        i++;
	                }
	                for(List<Buzon_CIA__c> listaBuzonCIA :
	                                [SELECT Id, BUZ_EMA_Direccion__c
	                                 FROM Buzon_CIA__c
	                                 WHERE BUZ_LKP_Cuenta__r.CUE_TXT_Identificador__c IN :codCia
	                                 AND BUZ_SEL_Tipo_Programa__c INCLUDES (:includeStatement)
	                                 AND BUZ_EMA_Direccion__c != NULL]){
	                                         mapaBuzon.putAll(listaBuzonCIA);
	                                 }
	        }
	    system.debug(mapaBuzon + ' mapaBuzon');
	                return mapaBuzon;
	}

	/**
	 * Consulta Correos electrónicos proporcionado un set de  Ids
	 *
	 * @param setIdEmail: conjunto de identificadores externos de Email
	 *
	 * @return mapa que contiene los EmailMessage encontrados
	 */
	public static Map<Id,EmailMessage> getEmailMessageById(Set<String> setIdEmail){
		Map<Id,EmailMessage> mapa = new Map<Id,EmailMessage>();
		if(setIdEmail != null && !setIdEmail.isEmpty() ){
			for(List<EmailMessage> lista:[SELECT ToAddress
											FROM EmailMessage
											WHERE Id IN :setIdEmail]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	public static String getEmailToSalesforce(Id OwnerId){
		List<EmailServicesAddress> listaMail = new List<EmailServicesAddress>([SELECT EmailDomainName FROM EmailServicesAddress WHERE RunAsUserId = :OwnerId]);
		String retorno;
		if(listaMail!=null && !listaMail.isEmpty()){
			retorno='emailtosalesforce@'+listaMail.get(0).EmailDomainName;
		}
		return retorno;
	}
}