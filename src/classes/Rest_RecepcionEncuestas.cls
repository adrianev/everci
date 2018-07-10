/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:             everis
Company:        everis España
Description:    Clase que se utilizará para recibir un listado de respuestas de encuestas

History:  Eliminación de duplicidad de insert. Además se retoca para que inserte las preguntas correctas y deseche las incorrectas. Hasta ahora se insertaba todo solo si estaba todo correcto.
 
24/04/2018                      everis                       Cambios marcados como "24/04/2018"
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/recepcionEncuesta')
global without sharing class Rest_RecepcionEncuestas {
	global static List<Rest_RecepcionEncuestas_RP> listResultados = new List<Rest_RecepcionEncuestas_RP>();
	global static Datetime fechaHoraGMT;
	/**
	 * Devuelve un listado de respuestas de encuestas
	 *
	 * @param listRespuestasEncuestas : listado de encuestas, con el número de orden de trabajo, la pregunta y la respuesta
	 * @param idCaso : Identificador del caso
	 * @param tipoEncuesta : tipo de encuesta
	 * @param codMovimiento : Código de movimiento
	 * @param motivoRetirada : motivo de la retirada
	 * @param duracion : duración
	 * @param fechaHora : fecha/hora
	 * @param gestor : gestor
	 *
	 * @return listado de respuestas de encuestas
	 *
	 */
	@HttpPost
	global static List<Rest_RecepcionEncuestas_RP> doPost (
			List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas,
			String idCaso,
			String tipoEncuesta,
			String codMovimiento,
			String motivoRetirada,
			Integer duracion,
			Datetime fechaHora,
			String gestor
			) {

		List<Case> casos = [SELECT Id, CAS_CAS_Siniestro_Encuestado__c FROM Case WHERE Id =: idCaso LIMIT 1];
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID, ENT_TXT_Identificador__c FROM ENC_Encuesta_Tipo__c WHERE ENT_TXT_Identificador__c =: tipoEncuesta LIMIT 1];
		List<ENC_Respuesta__c> listRespuestas = new List<ENC_Respuesta__c>();
		List<ENC_Pregunta__c> listPreguntas = [SELECT Id, ENP_TXT_Identificador__c, ENP_LKP_Encuesta_Tipo__c FROM ENC_Pregunta__c];

		// INI - everis - 24/04/2018 - flag para insertar encuesta
		Boolean insertarEncuesta = false;
		// FIN - everis - 24/04/2018 - flag para insertar encuesta
		//Creamos un mapa para las preguntas IDENTIFICADOR que coinciden con el tipo de encuesta que recibimos, para optimizar el código
		Map<String, ENC_Pregunta__c> mapaPreguntasId = new Map<String, ENC_Pregunta__c>();
		fechaHoraGMT = fechaGMT(fechaHora);
		for (ENC_Pregunta__c p:listPreguntas){
			if(!listTipoEncuesta.isEmpty() && listTipoEncuesta[0].Id == p.ENP_LKP_Encuesta_Tipo__c){
				mapaPreguntasId.put(p.ENP_TXT_Identificador__c,p);
			}
		}
		List<String> listaNumeroWO = new List<String>();
		for (Rest_RecepcionEncuestas_RQ listWOAux : listRespuestasEncuestas) {
			if (String.isNotBlank(listWOAux.numOrdenTrabajo)){
				listaNumeroWO.add(listWOAux.numOrdenTrabajo);   
			}
		}
		//Creamos un mapa para las WorkOrder, para optimizar el código
		List<WorkOrder> listOrdenes = [SELECT Id, OTR_TXT_Num_OrdenTrabajo_HS__c, OTR_CAS_Servicio_Encuestado__c FROM WorkOrder WHERE OTR_TXT_Num_OrdenTrabajo_HS__c IN: listaNumeroWO AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)];
		Map<String, WorkOrder> mapaOrdenes = new Map<String, WorkOrder>();
		for (WorkOrder o:listOrdenes){
			mapaOrdenes.put(o.OTR_TXT_Num_OrdenTrabajo_HS__c,o);
		}
		ENC_Encuesta__c encuesta = new ENC_Encuesta__c();
		// Comprobamos si el idCaso que recibimos existe
		if (casos.isEmpty()){
			Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
			resultado.code = 'ENC-002';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code)+' '+idCaso;
			montaRespuestas(resultado);
		}
		Boolean encuestaExiste = true;
		// Comprobamos si el tipoEncuesta existe
		if (listTipoEncuesta.isEmpty()){
			encuestaExiste = false;
			Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
			resultado.code = 'ENC-003';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code)+' '+tipoEncuesta;
			montaRespuestas(resultado);
		}
		Boolean respuestaErronea = false;
		// INI - everis - 24/04/2018 -  flag para ver que todas las preguntas están mal, en cuyo caso no se insertará nada
		Boolean todasRespuestasErroneas = true;
		// en esta lista guardaremos las respuestas correctas (con pregunta y Work Order), de modo que se inserten. Hasta ahora se insertaban todas o ninguna.
		List<Rest_RecepcionEncuestas_RQ> respuestasCorrectas = new List<Rest_RecepcionEncuestas_RQ>();
		// FIN - everis - 24/04/2018 
		// Si el codigo movimiento vale 2, significa que las encuestas van a venir con respuestas. Si vale 1, la encuesta vendrá sin respuestas y no habrá que hacer comporbaciones
		if(codMovimiento == '2'){
			// Comprobamos si las preguntas y workOrders recibidos existen
			for(Rest_RecepcionEncuestas_RQ respuesta:listRespuestasEncuestas){
				respuestaErronea = false;
				Boolean contienePregunta = mapaPreguntasId.containsKey(respuesta.pregunta);

				if(!contienePregunta && encuestaExiste){
					Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
					resultado.code = 'ENC-004';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code)+' ' +respuesta.pregunta;
					montaRespuestas(resultado);
					respuestaErronea = true;
				}
				Boolean contieneOrden = mapaOrdenes.containsKey(respuesta.numOrdenTrabajo);
				if(!(contieneOrden || respuesta.numOrdenTrabajo == '' || respuesta.numOrdenTrabajo == null)){
					Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
					resultado.code = 'ENC-007';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code)+' ' +respuesta.numOrdenTrabajo;
					montaRespuestas(resultado);
					respuestaErronea = true;
				}
				if (respuestaErronea == false){
					 todasRespuestasErroneas = false;
					 respuestasCorrectas.add(respuesta);
				}
			}
			// INI - everis - 24/04/2018 - se quita de la condición el flag "preguntaTipo, ya que no se le da valor en ningún lado
			// Si las comprobaciones de errores son correctas se inserta la encuesta. Se utiliza el flag para evitar dos inserciones en la clase. se utiiza el flag
			// "todasRespuestasErroneas" en lugar de "respuestasErroneas". Se encapsula el código repetido en la función "setValoresEncuesta"
			if (!casos.isEmpty() && !listTipoEncuesta.isEmpty() && !todasRespuestasErroneas){
				encuesta = setValoresEncuesta(encuesta, idCaso, listTipoEncuesta, codMovimiento, motivoRetirada, duracion, gestor);
			} else {
				return listResultados;
			}
			insertarEncuesta = true;
		}else if(codMovimiento == '1'){
			if (!casos.isEmpty() && !listTipoEncuesta.isEmpty()){
				encuesta = setValoresEncuesta(encuesta, idCaso, listTipoEncuesta, codMovimiento, motivoRetirada, duracion, gestor);
			} else {
				return listResultados;		
			}	
			insertarEncuesta = true;
		}else{
			Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
			resultado.code = 'ENC-006';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code)+' '+codMovimiento;
			montaRespuestas(resultado);
			return listResultados;
		}
		// FIN - everis - 24/04/2018
		
		// INI - everis - 24/04/2018 - si el flag para insertar encuesta está a true, se inserta, y si es movimiento 2, se insertan las respuestas
		if(insertarEncuesta) {
			//try{
			system.debug(encuesta);
			system.debug(casos);
			system.debug(listOrdenes);
				encuesta = insertaEncuesta(encuesta, casos, listOrdenes);
			/*}catch(Exception e){
				Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
				resultado.code = 'ENC-008';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				montaRespuestas(resultado);
				return listResultados;
			}*/
			
			if(codMovimiento == '2'){
				listRespuestas = ponerValoresRespuestas(encuesta, respuestasCorrectas, listPreguntas, listOrdenes);
				// Insertamos el listado de respuestas en caso de que todo el listado recibido esté correcto
				try{
					insert listRespuestas;
				}catch(Exception e){
					Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
					resultado.code = 'ENC-009';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
					montaRespuestas(resultado);
					return listResultados;
				}
			}
		}
		// FIN - everis - 24/04/2018
		Rest_RecepcionEncuestas_RP resultado = new Rest_RecepcionEncuestas_RP();
		resultado.code = 'ENC-001';
		resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
		montaRespuestas(resultado);
		return listResultados;
	}
	
	private static void montaRespuestas(Rest_RecepcionEncuestas_RP respuesta){
		if(listResultados.isEmpty()){
			listResultados.add(respuesta);
		}else{
			if(!listResultados.get(0).code.contains(respuesta.code) || !listResultados.get(0).message.contains(respuesta.message)){
				listResultados.get(0).code+=';'+respuesta.code;
				listResultados.get(0).message+=';'+respuesta.message;
			}
		}
	}
	/**
	 * Pasa la fecha al huso horario GMT(Para guardar fechas en BBDD)
	 */
	private static DateTime fechaGMT(Datetime fecha){
		Date d = fecha.dateGmt();
		Time t = fecha.timeGmt();
		return Datetime.newInstance(d,t);
	}
	
	//INI - everis - 24/04/2018 - funciones nuevas para encapsular código.
	/**
	 * inserta una encuesta, así como actualiza el valor de "encuestado" a true, en su caso y sus órdenes. Devuelve la propia encuesta con su id asignada.
	 *
	 * @param encuesta : encuesta a insertar
	 * @param casos : lista de casos relacionados con la encuesta para marcar
	 * @param listOrdenes : lista de ordenes relacionados con la encuesta para marcar
	 *
	 * @return encuesta insertada, con su id ya asignada.
	 */
	private static ENC_Encuesta__c insertaEncuesta(ENC_Encuesta__c encuesta, List<Case> casos, List<WorkOrder> listOrdenes){
		insert encuesta;
		casos[0].CAS_CAS_Siniestro_Encuestado__c = true;
		for(Integer i = 0;i<listOrdenes.size();i++){
			listOrdenes.get(i).OTR_CAS_Servicio_Encuestado__c = true;
		}
		update casos;
		update listOrdenes;
		return encuesta;	
	}
	
	/**
	 * Setea los valores de las respuestas. Recibe la encuesta, las respuestas correctas recibidas, las preguntas y las ordenes.
	 Devuelve una lista de instancias del objeto respuesta.
	 *
	 * @param encuesta : encuesta a editar.
	 * @param respuestasCorrectas : lista de respuestas correctas del json recibido
	 * @param listPreguntas : lista de preguntas
	 * @param listOrdenes : lista de ordenes
	 *
	 * @return lista de instancias del objeto respuesta.
	 */
	private static List<ENC_Respuesta__c> ponerValoresRespuestas(ENC_Encuesta__c encuesta, List<Rest_RecepcionEncuestas_RQ> respuestasCorrectas, List<ENC_Pregunta__c> listPreguntas, List<WorkOrder> listOrdenes){
		List<ENC_Respuesta__c> listRespuestas = new List<ENC_Respuesta__c>();
		for(Rest_RecepcionEncuestas_RQ respuesta:respuestasCorrectas){
			ENC_Respuesta__c nuevaRespuesta = new ENC_Respuesta__c();
			for(ENC_Pregunta__c pregunta:listPreguntas){
				if(pregunta.ENP_TXT_Identificador__c == respuesta.pregunta){
					nuevaRespuesta.ENR_LKP_Resp_Pregunta__c = pregunta.Id;
				}
			}
			for(WorkOrder orden:listOrdenes){
				if(orden.OTR_TXT_Num_OrdenTrabajo_HS__c == respuesta.numOrdenTrabajo){
					nuevaRespuesta.ENR_LKP_WorkOrder__c = orden.Id;
				}
			}
			nuevaRespuesta.ENR_TXT_Respuesta__c = respuesta.respuesta;
			nuevaRespuesta.ENR_LKP_Encuesta_Realizada__c = encuesta.Id;
			listRespuestas.add(nuevaRespuesta);
		}
		return listRespuestas;
	}

	/**
	 * Da valor a ciertos campos de la encuesta, preparándola para ser insertada. Devuelve la propia encuesta actualizada.
	 *
	 * @param encuesta : encuesta a editar.
	 * @param idCaso : caso relacionado con la encuesta.
	 * @param listTipoEncuesta : lista con el tipo de la encuesta.
	 * @param codMovimiento : codigo de movimiento.
	 * @param motivoRetirada : motivo de la retirada.
	 * @param duracion : duración
	 * @param gestor : gestor
	 *
	 * @return encuesta con los campos actualizados.
	 */
	private static ENC_Encuesta__c setValoresEncuesta(ENC_Encuesta__c encuesta,String idCaso, List<ENC_Encuesta_Tipo__c> listTipoEncuesta, String codMovimiento, String motivoRetirada, Integer duracion, String gestor){
		encuesta.ENC_LKP_Caso__c = idCaso;
		encuesta.ENC_LKP_Encuesta_Tipo__c = listTipoEncuesta[0].Id;
		encuesta.ENC_TXT_Codigo_Mov__c = codMovimiento;
		encuesta.ENC_TXT_Motivo_Retirada__c = motivoRetirada;
		encuesta.ENC_NUM_Duracion__c = duracion;
		encuesta.ENC_DAT_Fecha_Hora__c = fechaHoraGMT;
		encuesta.ENC_TXT_Gestor__c = gestor;
		return encuesta;		
	}
	// FIN - everis - 24/04/2018
}