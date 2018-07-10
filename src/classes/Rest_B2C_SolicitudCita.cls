/**
 * Clase que se utilizará para solicitar/cambiar la Cita de Servicio para un cliente B2B.
 *
 * @author EVERIS
 * 
 */
@RestResource(urlMapping='/solicitudCitaB2B')
global without sharing class Rest_B2C_SolicitudCita {

	/**
	 * Devuelve un código y un mensaje de respuesta, dependiendo de si la cita ha sido o no programada
	 *
	 * @param OTR_DAT_Fecha_Ultima_Cita : fecha seleccionada
	 * @param OTR_SEL_Rango_Ultima_Cita : rango horas seleccionado
	 * @param CAS_SEL_origen_web : origen web
	 * @param IdCaso : identificador único del caso abierto
	 * @param IdContacto : identificador único del contacto
	 * @param IdCliente : identificador único del cliente
	 * @param CAS_TXT_Nombre : nombre del contacto
	 * @param CAS_TXT_Apellidos : apellidos del contacto
	 * @param CAS_EMA_Solicitud_Email : email del contacto al que se debe informar
	 * @param CAS_TFN_Solicitud_Telefono : móvil de contacto al que se debe informar
	 * @param CAS_TFN_Telefono_1 : teléfono del contacto al que se debe informar
	 * @param codigoCita : código de cita del servicio profesional
	 *
	 * @return código y descripción de la respuesta.
	 *
	 */
	@HttpPatch
	global static Rest_B2C_SolicitudCita_RP setAppointment(String OTR_DAT_Fecha_Ultima_Cita, 
			String OTR_SEL_Rango_Ultima_Cita, String CAS_SEL_origen_web, String IdCaso, String IdContacto, 
			String IdCliente, String CAS_TXT_Nombre, String CAS_TXT_Apellidos, String CAS_TXT_Apellidos_2, String CAS_EMA_Solicitud_Email, 
			String CAS_TFN_Solicitud_Telefono, String CAS_TFN_Telefono_1, String codigoCita) {
				
		system.debug('--- SVV. OTR_DAT_Fecha_Ultima_Cita: ' + OTR_DAT_Fecha_Ultima_Cita);
		system.debug('--- SVV. OTR_SEL_Rango_Ultima_Cita: ' + OTR_SEL_Rango_Ultima_Cita);
		system.debug('--- SVV. CAS_SEL_origen_web: ' + CAS_SEL_origen_web);
		system.debug('--- SVV. IdCaso: ' + IdCaso);
		system.debug('--- SVV. IdContacto: ' + IdContacto);
		system.debug('--- SVV. IdCliente: ' + IdCliente);
		system.debug('--- SVV. CAS_TXT_Nombre: ' + CAS_TXT_Nombre);
		system.debug('--- SVV. codigoCita: ' + codigoCita);
		
		Rest_B2C_SolicitudCita_RP respuesta = new Rest_B2C_SolicitudCita_RP();
		
		//Se comprueba que los datos obligatorios vengan informados
		if (String.isEmpty(OTR_DAT_Fecha_Ultima_Cita) || String.isEmpty(OTR_SEL_Rango_Ultima_Cita) || String.isEmpty(CAS_SEL_origen_web) || 
			String.isEmpty(IdCaso) || String.isEmpty(codigoCita)) {
				respuesta.code = 'API-004';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				return respuesta;
		}
		
		try {
			FSL.ScheduleResult scheduleResult =  new FSL.ScheduleResult();
			List<Contact> cuentaContacto;
			List<Contact> contactos;
			String identificadorCuenta;
			ContentVersion cv = new ContentVersion();

			List<Case> caso = [SELECT AccountId,
									  CaseNumber,
									  ContactId,
									  CAS_EMA_Solicitud_Email__c,
									  CAS_TFN_Solicitud_Telefono__c,
									  CAS_TFN_Telefono_1__c,
									  CAS_TXT_Apellidos__c,
									  CAS_TXT_Apellidos_2__c,
									  CAS_TXT_Nombre__c,
									  CAS_LKP_Compania__c,
									  CAS_LKP_Punto_de_venta__c
							  FROM Case
							  WHERE Id = :IdCaso];
			
			if (caso.isEmpty()) {
				respuesta.code = 'API-007';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				return respuesta;
			}

			//Se comprueba si vienen los campos de Contacto, Cliente y Solicitante vacíos
			if (String.isEmpty(IdContacto) && String.isEmpty(IdCliente) && String.isEmpty(CAS_TXT_Nombre)) {
				system.debug('---- SVV. Solo me están pasando el caso ----');
				contactos = [SELECT Id FROM Contact WHERE AccountId =: caso[0].CAS_LKP_Punto_de_venta__c AND Email != null];
			}
			//Cuando el IdCliente viene relleno
			else if (!String.isEmpty(IdCliente)) {
				List<Account> cliente = [SELECT CUE_LKP_Cuenta_principal__c, RecordTypeId, Type FROM Account WHERE Id =: IdCliente];
				if (cliente[0].RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2) && cliente[0].Type == Label.CUE_TIPO_CLIENTEFINAL 
					&& cliente[0].CUE_LKP_Cuenta_principal__c == caso[0].CAS_LKP_Compania__c) {
						caso[0].AccountId = IdCliente;
						update caso[0];
				}
				else {
					respuesta.code = 'API-002';
					respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
					return respuesta;
				}
			}
			//Si me llega el contacto en la RQ, se tiene que comprobar que existe dicho contacto y que coincide con el cliente
			else if (IdContacto != null && IdContacto.length() != 0) {
				cuentaContacto = [SELECT AccountId FROM Contact WHERE Id =: IdContacto];
				if (cuentaContacto == null || cuentaContacto.size() == 0) {
					respuesta.code = 'API-003';
					respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
					return respuesta;
				}
				if (caso[0].AccountId != cuentaContacto[0].AccountId) {
					respuesta.code = 'API-003';
					respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
					return respuesta;
				}
				//Existe el contacto. Se tiene que comprobar el nombre del RecordType, porque si es un cliente secundario el email tambien se tiene
				//que mandar a los contactos de la cuenta principal
				List<Account> cuentaRT = [SELECT RecordType.DeveloperName, CUE_LKP_Cuenta_principal__c FROM Account WHERE Id =: cuentaContacto[0].AccountId];
				contactos = [SELECT Id FROM Contact WHERE AccountId =: cuentaContacto[0].AccountId AND Email != null];
				if (cuentaRT[0].RecordType.DeveloperName == Label.RT_CUE_CLIENTEB2B_2.replace('Account:','')) {
					List<Contact> contactSec = [SELECT Id FROM Contact WHERE AccountId =: cuentaRT[0].CUE_LKP_Cuenta_principal__c AND Email != null];
					contactos.addall(contactSec);
				}
			}
			else {
				//No tengo el contacto en la RQ, se setea el caso con los valores pasados en la request
				caso[0].CAS_TXT_Nombre__c = CAS_TXT_Nombre;
				caso[0].CAS_TXT_Apellidos__c = CAS_TXT_Apellidos;
				caso[0].CAS_TXT_Apellidos_2__c = CAS_TXT_Apellidos_2;
				caso[0].CAS_EMA_Solicitud_Email__c = CAS_EMA_Solicitud_Email;
				caso[0].CAS_TFN_Solicitud_Telefono__c = CAS_TFN_Solicitud_Telefono;
				caso[0].CAS_TFN_Telefono_1__c = CAS_TFN_Telefono_1;
				Baipas.establecerVariableControl();
				update caso[0];
				Baipas.deshabilitarVariableControl();
			}
			
			respuesta = Util_Booking.setAppointment(OTR_DAT_Fecha_Ultima_Cita, OTR_SEL_Rango_Ultima_Cita, codigoCita, CAS_SEL_origen_web);
			
			caso = [SELECT AccountId,
						   CaseNumber,
						   ContactId,
						   CAS_EMA_Solicitud_Email__c,
						   CAS_TFN_Solicitud_Telefono__c,
						   CAS_TFN_Telefono_1__c,
						   CAS_TXT_Apellidos_2__c,
						   CAS_TXT_Apellidos__c,
						   CAS_TXT_Nombre__c,
						   CAS_LKP_Compania__c,
						   CAS_LKP_Punto_de_venta__c,
						   CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
						   CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime
					FROM Case
					WHERE Id = :IdCaso];

			
			//Se crea un documento cuando no me pasen IdContacto, IdCliente y datos de solicitante
			cv = null;
			if (String.isEmpty(IdContacto) && String.isEmpty(IdCliente) && String.isEmpty(CAS_TXT_Nombre)) {
				Map<String,String> argumentos = new Map<String,String>();
				argumentos.put('FechaCita', string.valueOf(date.valueOf(caso[0].CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime)));
				argumentos.put('RangoCita', string.valueOf(caso[0].CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime.time()).left(5)+'-'+string.valueOf(caso[0].CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime.time()).left(5));
				cv = Util_Documentacion.crearPDFDesdeVF(IdCaso, null, Label.PDF_TIPO_COMPROBANTE, Label.IDE_WORTEN, null, caso[0].CaseNumber, null, null, argumentos);
			}
			
			//Se envía el email con adjunto cuando no me pasen IdContacto, IdCliente y datos de solicitante
			if ((String.isEmpty(IdContacto) && String.isEmpty(IdCliente) && String.isEmpty(CAS_TXT_Nombre))) {
				system.debug('---- SVV. Se envia a una lista de contactos ----');
				system.debug('---- SVV. Contactos: ' + contactos);
				NotificacionMail.filtroNotificaciones(contactos, IdCaso, caso[0].CAS_LKP_Compania__c,cv);
			}
			else if (!String.isEmpty(IdContacto)) {
				NotificacionMail.filtroNotificaciones(contactos, IdCaso, caso[0].CAS_LKP_Compania__c,null);
			}
			else {
				//Para notificar el email, si no existe el contacto se tiene que enviar el caso (es donde esta la información)
				NotificacionMail.filtroNotificaciones(caso, IdCaso, caso[0].CAS_LKP_Compania__c,null);
			}

			caso[0].Status = Label.CAS_ESTADO_EN_CURSO; 
			caso[0].CAS_DAT_Fecha_Apertura__c = datetime.now();
			caso[0].RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
			update caso[0];

			respuesta.code = 'API-001';
			respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
		}
		catch (Exception e){
			system.debug('>>>>>>>EXCEPTION: ' + e + ' ' + e.getStackTraceString());
			//Comprobamos si están los datos mal formados
			if (OTR_DAT_Fecha_Ultima_Cita.length() > 24 || OTR_SEL_Rango_Ultima_Cita.length() > 255 || CAS_SEL_origen_web.length() > 255 || IdCaso.length() > 18 ||
				(IdContacto != null && IdContacto.length() > 18) || (IdCliente != null && IdCliente.length() > 18) || (CAS_TXT_Nombre != null && CAS_TXT_Nombre.length() > 40) || 
				(CAS_TXT_Apellidos != null && CAS_TXT_Apellidos.length() > 80) || (CAS_TXT_Apellidos_2 != null && CAS_TXT_Apellidos_2.length() > 100) || 
				(CAS_EMA_Solicitud_Email != null && CAS_EMA_Solicitud_Email.contains('@') == false) || (CAS_TFN_Solicitud_Telefono != null && CAS_TFN_Solicitud_Telefono.length() > 40) ||
				(CAS_TFN_Telefono_1 != null && CAS_TFN_Telefono_1.length() > 40) || codigoCita.length() > 20) {
					respuesta.code = 'API-004';
					respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
			}
			else {
				respuesta.code = 'API-014';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
			}
		}
		system.debug('>>>>>>>doPost.respuesta: ' + respuesta);
		return respuesta;
	}

}