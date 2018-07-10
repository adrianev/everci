/**
 * Clase utilizada para la creación de un servicio de tipo Servicio_B2B_B2B2C
 *
 * @author EVERIS
 *
 */
@RestResource(urlMapping='/creacionServicioB2BB2B2C')
global without sharing class Rest_B2BB2B2C_CreacionServicio {

	/**
	 * Devuelve el identificador del caso, de la orden de trabajo, de la cita de servicio y sus franjas horarias disponibles.
	 *
	 * @param AccountId : Identificador de la compañía/cuenta que solicita el servicio
	 * @param CAS_LKP_Compania : Identificador de la compañía/cuenta principal cuya cuenta secundaria solicita el servicio
	 * @param CAS_LKP_Punto_de_venta : Identificador de la cuenta-dirección utilizada como Punto de venta
	 * @param CAS_SEL_Gremio_Principal : Gremio al que pertenece
	 * @param CAS_SEL_origen_web : Origen web
	 * @param Description: Descripción
	 *
	 * @return código de respuesta, descripción de respuesta, identificador del caso abierto, identificador del caso orden de trabajo abierta, 
	 *       código de la cita previa generada automáticamente y listado de franjas horarias para esa cita de servicio.
	 */

	@HttpPost
	global static Rest_B2BB2B2C_CreacionServicio_RP doPost(String AccountId, String CAS_LKP_Compania, String CAS_LKP_Punto_de_venta, String CAS_SEL_Gremio_Principal, 
			String CAS_SEL_origen_web, String Description, String CAS_LKP_Baremo, Boolean urgente, Boolean olaCalor){


		Rest_B2BB2B2C_CreacionServicio_RP respuesta = new Rest_B2BB2B2C_CreacionServicio_RP();
		List<Account> cuentaPrincipal = new List<Account>();
		String IdentificadorAux;
		try{ 
			if (CAS_SEL_origen_web != Label.CAS_ORIGEN_LANDING_B2B2C) {
				respuesta.code = 'API-004';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				system.debug('>>>>>>>doPost.respuesta: ' + respuesta);
				return respuesta;
			}

			List<Account> cliente = [SELECT Id, CUE_TXT_Identificador__c, CUE_TXT_Nombre__c, CUE_TXT_PrimerApellido__c, CUE_TXT_SegundoApellido__c, CUE_EMA_Email__c,
				Phone FROM Account WHERE Id =: AccountId];
			if (cliente ==  null || cliente.size() == 0) {
				respuesta.code = 'API-002';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				system.debug('>>>>>>>doPost.respuesta: ' + respuesta);
				return respuesta;
			}
			
			/*Cambios añadidos para Worten II - 16/05/2018*/
			if (olaCalor == true) {
				cliente[0].CUE_CAS_Ola_calor__c = true;
			}
			else {
				cliente[0].CUE_CAS_Ola_calor__c = false;
			}
			update cliente[0];
			/*Final de cambios para Worten II - 16/05/2018*/
			
			IdentificadorAux = cliente[0].CUE_TXT_Identificador__c;
			if (!String.isEmpty(CAS_LKP_Compania)) {
				cuentaPrincipal = [SELECT Id, CUE_TXT_Identificador__c FROM Account WHERE Id =: CAS_LKP_Compania];
				IdentificadorAux = cuentaPrincipal[0].CUE_TXT_Identificador__c;
			}

			//Se comprueba si existe el gremio pasado en la RQ
			DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Case').getDescribe();
			DescribeFieldResult campoGremio = obj.fields.getMap().get('CAS_SEL_Sondeo_Gremios__c').getDescribe(); 
			List<Schema.PicklistEntry> listaPicklistGremios = campoGremio.getPicklistValues();
			String gremioValor = '';
			Boolean gremio = false;
			for (Schema.PicklistEntry valorCampoGremio : listaPicklistGremios){
				gremioValor = valorCampoGremio.getValue();
				if (gremioValor == CAS_SEL_Gremio_Principal) {
					gremio = true;
					break;
				}  
			}
			if (gremio == false) {
				respuesta.code = 'API-005';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				system.debug('>>>>>>>doPost.respuesta: ' + respuesta);
				return respuesta;
			}

			//Se crea el caso, seteando sus valores
			Case caso = new Case();
			caso.AccountId = AccountId;
			caso.Origin = Label.CAS_ORIGIN_WEB;
			caso.CAS_SEL_Gremio_Principal__c = CAS_SEL_Gremio_Principal;
			if (IdentificadorAux == Label.IDE_WORTEN && !String.isEmpty(Description)) {
				List<String> descripcionSplit = description.split('\\|');
				
				//Prueba de si me pasan una fecha anterior a la de hoy. En caso de que si, pongo la fecha de hoy, si no, la que esta
				if (date.valueOf(descripcionSplit[0]) < Date.today()) {
					caso.CAS_DAT_Recepcion_Producto_b2b2c__c = date.today();
				}
				else {
					caso.CAS_DAT_Recepcion_Producto_b2b2c__c = date.valueOf(descripcionSplit[0]);
				}
				if (descripcionSplit.size() > 1) {
					caso.Description = descripcionSplit[1];
				}
			}
			else {
				caso.Description = Description;
			}
			caso.CAS_SEL_origen_web__c = CAS_SEL_origen_web;
			//caso.Status = Label.CAS_ESTADO_EN_CURSO; 
			//caso.CAS_DAT_Fecha_Apertura__c = datetime.now(); 
			caso.Type = Label.CAS_TIPO_CORRECTIVO;
			caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
			caso.CAS_LKP_Compania__c = CAS_LKP_Compania;
			if (!String.isEmpty(CAS_LKP_Punto_de_venta)) {
				caso.CAS_LKP_Punto_de_venta__c = CAS_LKP_Punto_de_venta;
			}
			if (!String.isEmpty(CAS_LKP_Baremo)) {
				List<Baremo__c> listaBaremo = [SELECT Id FROM Baremo__c WHERE BAR_TXT_Identificador__c =: CAS_LKP_Baremo AND BAR_SEL_Gremio__c =: CAS_SEL_Gremio_Principal LIMIT 1];
				if (listaBaremo.isEmpty()) {
					respuesta.code = 'API-004';
					respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
					system.debug('>>>>>>>doPost.respuesta: ' + respuesta);
					return respuesta;
				}
				caso.CAS_LKP_Baremo__c = listaBaremo[0].Id;
			}
			if (urgente == true) {
				caso.CAS_CAS_Urgente__c = true;
			}
			else {
				caso.CAS_CAS_Urgente__c = false;
			}
			insert caso;
			
			String IdCaso = caso.Id;
			//Se llama a la función BookingFranjas para devolver las franjas horarias disponibles.
			List<Rest_Franja_RP> franjas = Util_Booking.BookingFranjas(AccountId, IdCaso, null, CAS_SEL_origen_web);
			List<WorkOrder> listWOAux = [SELECT Id FROM WorkOrder WHERE CaseId =: IdCaso AND RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)];
			String woID = listWOAux[0].Id;
			
			respuesta.listadoFranjas = franjas;
			respuesta.codigoCita = Util_Booking.NumeroCita(woID);
			respuesta.Id = caso.Id;
			respuesta.identificadorUnicoOrden = woID;
			respuesta.code = 'API-001';
			respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
		}
		catch(Exception e){
			system.debug('>>>>>>>EXCEPTION: ' + e + ' ' + e.getStackTraceString());
			respuesta.code = 'API-014';
			respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
		}
		system.debug('>>>>>>>doPost.respuesta: ' + respuesta);
		return respuesta;
	}

}