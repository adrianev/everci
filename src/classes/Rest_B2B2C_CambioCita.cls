/**
 * Clase que se utilizará para cambiar la fecha de la Cita de Servicio 
 * @author everis
 * @version 1.0
 */

@RestResource(urlMapping='/cambioCitaB2B2C')
global without sharing class Rest_B2B2C_CambioCita {
	
	/**
	 * Clase de respuesta.
	 *
	 */

	global class Resultado {
		public String code = '';
		public String message = '';
		public String CAS_LKP_Punto_de_venta = '';
		public String IdCaso = '';
	}

	/**
	 * Devuelve el código y el mensaje de si la cita ha sido o no cambiada correctamente.
	 *
	 * @param OTR_DAT_Fecha_Ultima_Cita : Fecha seleccionada
	 * @param OTR_SEL_Rango_Ultima_Cita : Rango horas seleccionado
	 * @param codigoCita : Número de la Cita de Servicio
	 * @param comentario : comentario
	 * @param CAS_DAT_Recepcion_Producto_b2b2c : Fecha de entrega
	 *
	 * @return código y mensaje de si la cita de Servicio ha sido o no cambiada con éxito.
	 *
	 */
	@HttpPatch
	global static Resultado setAppointment(String OTR_DAT_Fecha_Ultima_Cita, String OTR_SEL_Rango_Ultima_Cita, String codigoCita, String comentario, Date CAS_DAT_Recepcion_Producto_b2b2c){
		
		Resultado resultado = new Resultado();
		ContentVersion cv = new ContentVersion();
		
		system.debug('---- SVV. OTR_DAT_Fecha_Ultima_Cita: '+ OTR_DAT_Fecha_Ultima_Cita);
		system.debug('---- SVV. OTR_SEL_Rango_Ultima_Cita: '+ OTR_SEL_Rango_Ultima_Cita);
		system.debug('---- SVV. codigoCita: '+ codigoCita);
		system.debug('---- SVV. comentario: '+ comentario);
		system.debug('---- SVV. CAS_DAT_Recepcion_Producto_b2b2c: '+ CAS_DAT_Recepcion_Producto_b2b2c);
		
		//Se comprueba que los datos obligatorios vengan informados
		if (String.isEmpty(OTR_DAT_Fecha_Ultima_Cita) || String.isEmpty(OTR_SEL_Rango_Ultima_Cita) || String.isEmpty(codigoCita) || String.isEmpty(String.valueOf(CAS_DAT_Recepcion_Producto_b2b2c)) 
			|| OTR_DAT_Fecha_Ultima_Cita.length() > 24 || OTR_SEL_Rango_Ultima_Cita.length() > 2 || codigoCita.length() > 20 || String.valueOf(CAS_DAT_Recepcion_Producto_b2b2c).length() > 10) {
				resultado.code = 'API-004';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug('>>>> Respuesta: ' + resultado);
				return resultado;
		}
		
		try {
			
			List<ServiceAppointment> citaServicio = [SELECT Id, ParentRecordId, EarliestStartTime, DueDate, CSE_SEL_Gremio__c FROM ServiceAppointment WHERE AppointmentNumber =: codigoCita AND Status !=: Label.CIT_ESTADO_ANULADA_POR_CAMBIO];
			
			if (citaServicio == null || citaServicio.size() == 0) {
					resultado.code = 'API-020'; 
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
					system.debug('>>>> Respuesta: ' + resultado);
					return resultado;
			}
			
			ServiceAppointment sa = citaServicio.get(0);
			sa.Status = Label.CIT_ESTADO_ANULADA_POR_CAMBIO;
			Baipas.establecerVariableControl();
			update sa;
			Baipas.deshabilitarVariableControl();
			
				
			List<WorkOrder> ordenTrabajo = [SELECT Id, CaseId, OTR_LKP_Primera_Cita__c FROM WorkOrder WHERE Id =: sa.ParentRecordId];
			List<Case> caso = [SELECT Id, CAS_DAT_Recepcion_Producto_b2b2c__c, CAS_LKP_Punto_de_venta__c FROM Case WHERE Id =: ordenTrabajo[0].CaseId];
			//Se setea la fecha de entrega a la que me hayan pasado por la landing
			caso[0].CAS_DAT_Recepcion_Producto_b2b2c__c = CAS_DAT_Recepcion_Producto_b2b2c;
			update caso[0];
			
			List<Contact> contactos = [SELECT Id FROM Contact WHERE AccountId =: caso[0].CAS_LKP_Punto_de_venta__c AND Email != null];
			
			String rangoLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Rango_Ultima_Cita__c').get(OTR_SEL_Rango_Ultima_Cita);
			String[] arrRango = rangoLiteral.split('-');

			String[] hora1 = arrRango[0].split(':');
			hora1[1] = hora1[1].trim();
			if (hora1[0] == '00') {
				hora1[0] = String.valueOf(0);
			}
			if (hora1[1] == '00') {
				hora1[1] = String.valueOf(0);
			}

			String[] hora2 = arrRango[1].split(':');
			hora2[0] = hora2[0].trim();
			if (hora2[0] == '00') {
				hora2[0] = String.valueOf(0);
			}
			if (hora2[1] == '00') {
				hora2[1] = String.valueOf(0);
			}

			Date fecha = date.valueOf(OTR_DAT_Fecha_Ultima_Cita);
			Time intervalo1 = Time.newInstance(integer.valueOf(hora1[0]), integer.valueOf(hora1[1]), 0, 0);
			Time intervalo2 = Time.newInstance(integer.valueOf(hora2[0]), integer.valueOf(hora2[1]), 0, 0);

			DateTime intervaloInicial = DateTime.newInstance(fecha, intervalo1);
			DateTime intervaloFinal = DateTime.newInstance(fecha, intervalo2);
			
			ServiceAppointment citaNueva = new ServiceAppointment();
			citaNueva.ArrivalWindowStartTime = intervaloInicial;
			citaNueva.ArrivalWindowEndTime = intervaloFinal;
			citaNueva.ParentRecordId = sa.ParentRecordId;
			citaNueva.EarliestStartTime = sa.EarliestStartTime;
			citaNueva.DueDate = sa.DueDate;
			citaNueva.CSE_SEL_Gremio__c = sa.CSE_SEL_Gremio__c;
			citaNueva.Description = comentario;
			insert citaNueva;
			
			//Creo la relación entre la Wo y la cita nueva
			ordenTrabajo[0].OTR_LKP_Primera_Cita__c = citaNueva.Id;
			update ordenTrabajo[0];
			
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
					WHERE Id = : ordenTrabajo[0].CaseId];

			//Se crea un documento
			cv = null;
			
			Map<String,String> argumentos = new Map<String,String>();
			argumentos.put('FechaCita', string.valueOf(date.valueOf(caso[0].CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime)));
			argumentos.put('RangoCita', string.valueOf(caso[0].CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime.time()).left(5)+'-'+string.valueOf(caso[0].CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime.time()).left(5));
			cv = Util_Documentacion.crearPDFDesdeVF(ordenTrabajo[0].CaseId, null, Label.PDF_TIPO_COMPROBANTE, Label.IDE_WORTEN, null, caso[0].CaseNumber, null, null, argumentos);
			
			//Se envía el email con adjunto
			NotificacionMail.filtroNotificaciones(contactos, ordenTrabajo[0].CaseId, caso[0].CAS_LKP_Compania__c,cv);
			
			caso[0].Status = Label.CAS_ESTADO_EN_CURSO; 
			caso[0].CAS_DAT_Fecha_Apertura__c = datetime.now();
			caso[0].RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
			update caso[0];

			resultado.code = 'API-001';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			resultado.CAS_LKP_Punto_de_venta = caso[0].CAS_LKP_Punto_de_venta__c;
			resultado.IdCaso = ordenTrabajo[0].CaseId;
		}
		catch(Exception e){
			system.debug('>>>>>>>EXCEPTION: ' + e + ' ' + e.getStackTraceString());
			resultado.code = 'API-014';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
		}
		system.debug('>>>> Respuesta: ' + resultado);
		return resultado;
	}
}