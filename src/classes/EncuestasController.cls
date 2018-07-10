/**
 * Clase controladora de la Visualforce "Encuestas" encargada de visualizar/editar una encuesta.
 * 
 * @author EVERIS
 */
public without sharing class EncuestasController {
	// Modelo de encuesta
	public ENC_Encuesta_Tipo__c encuestaTipo {get;set;}
	// Mapa de preguntas del modelo de encuesta
	public Map<Id, ENC_Pregunta__c> mapaPreguntasTipo {get;set;}
	// Lista de preguntas mostradas del modelo de encuesta
	public List<ENC_Pregunta__c> listaPreguntasMostradas {get;set;}
	// Mapa de respuestas posibles para cada pregunta
	public Map<Id, Util_Encuestas.RespuestaTipoVF> mapaRespuestasTipo {get;set;}
	// Encuesta realizada para la Intervención
	public ENC_Encuesta__c encuestaRealizada {get;set;}
	// Mapa de respuestas realizadas
	public Map<Id, ENC_Respuesta__c> mapaRespuestasRealizada {get;set;}
	// Intervención vinculada a la encuesta realizada
	public Case caso {get;set;}
	public Account cuenta {get; set;}
	public Boolean esB2C {get; set;}
	public Integer tipoCaso {get; set;}
	// Lista de Servicios de la Intervención
	public List<WorkOrder> listaGremios {get;set;}
	// Id de la pregunta en uso
	public Id idPreguntaActual {get;set;}

	/**
	 * Constructor de la clase.
	 */
	public EncuestasController(){
		PageReference paginaActual = ApexPages.currentPage();
		Id idEncuestaRealizada = null;
		Id idCaso = null;
		Id idEncuestaTipo = null;
		encuestaRealizada = new ENC_Encuesta__c();
		
		// Encuesta realizada
		if(paginaActual.getParameters().containsKey('id')){
			idEncuestaRealizada = paginaActual.getParameters().get('id');
			encuestaRealizada = Util_Encuestas.getEncuestaRealizadaById(idEncuestaRealizada);
			if(encuestaRealizada != null){
				idCaso = encuestaRealizada.ENC_LKP_Caso__c;
				idEncuestaTipo = encuestaRealizada.ENC_LKP_Encuesta_Tipo__c;
			}
		}
		// Encuesta nueva
		else {
			if(paginaActual.getParameters().containsKey('idCaso')){
				idCaso = (Id) paginaActual.getParameters().get('idCaso');
				encuestaRealizada.ENC_LKP_Caso__c = idCaso;
			}
			if(paginaActual.getParameters().containsKey('idEncuestaTipo')){
				idEncuestaTipo = (Id) paginaActual.getParameters().get('idEncuestaTipo');
				encuestaRealizada.ENC_LKP_Encuesta_Tipo__c = idEncuestaTipo;
			}
		}
		
		// Obtener datos de la Intervención
		if(idCaso != null){
			Set<Id> setIdCaso = new Set<Id>{idCaso};
			caso = Util_Caso.getCaseById(setIdCaso).get(idCaso);
			if(Util_Siniestro.esSiniestro(caso)){
				tipoCaso = 1;
			}
			else {
				tipoCaso = 2;
			}
			esB2C = caso.CAS_FOR_EsB2C__c;
			cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
			listaGremios = Util_Orden_Trabajo.getWorkOrderByCaseAndNotInStatus(setIdCaso, Util_Orden_Trabajo.SET_ESTADOS_ANULADOS).values();
		}
		// Obtener datos del modelo de Encuesta
		if(idEncuestaTipo != null){
			encuestaTipo = Util_Encuestas.getEncuestaTipo(idEncuestaTipo, null);
		}
		else if(idEncuestaTipo != null){
			encuestaTipo = Util_Encuestas.getEncuestaTipo(null, caso.CAS_TXT_Tipo_Encuesta__c);
			if(encuestaTipo != null){
				idEncuestaTipo = encuestaTipo.Id;
			}
		}

		// Obtener las preguntas del modelo de Encuesta
		mapaPreguntasTipo = Util_Encuestas.getMapaPreguntasByEncuestaTipo(idEncuestaTipo);
		system.debug('>>>>>>>>>mapaPreguntasTipo: ' + mapaPreguntasTipo);

		// Obtener las respuestas posibles para cada pregunta del modelo de Encuesta
		mapaRespuestasTipo = Util_Encuestas.getMapaRespuestasTipoVFByPreguntas(mapaPreguntasTipo.keySet());
		system.debug('>>>>>>>>>mapaRespuestasTipo: ' + mapaRespuestasTipo);

		// Obtener las respuestas realizadas para cada pregunta del modelo de Encuesta
		mapaRespuestasRealizada = Util_Encuestas.getMapaRespuestasRealByEncuestaReal(idEncuestaRealizada, mapaPreguntasTipo.keySet());		
		system.debug('>>>>>>>>>mapaRespuestasRealizada: ' + mapaRespuestasRealizada);

		// Inicializar la lista de preguntas mostradas en función de las respuestas realizadas
		listaPreguntasMostradas = new List<ENC_Pregunta__c>();
		idPreguntaActual = encuestaTipo.ENT_LKP_PrimeraPregunta__c;
		if(idPreguntaActual != null){
			listaPreguntasMostradas.add(mapaPreguntasTipo.get(idPreguntaActual));
			while(idPreguntaActual != null){
				cargarSiguientePregunta();
			}
		}

		system.debug('>>>>>>>>>listaPreguntasMostradas: ' + listaPreguntasMostradas);
	}


	/**
	 * A partir del identificador de una pregunta, carga y/o elimina las preguntas siguientes de forma que
	 * la última mostrada siempre es la siguiente a la recibida.
	 */
	public void cargarSiguientePregunta(){
		Id idPreguntaActualAux = idPreguntaActual;
		idPreguntaActual = null;
		ENC_Pregunta__c preguntaActual = null;
		ENC_Respuesta__c respuestaRealizada = mapaRespuestasRealizada.get(idPreguntaActualAux);
		Util_Encuestas.RespuestaTipoVF respuestaTipo = mapaRespuestasTipo.get(idPreguntaActualAux);
		// Obtener pregunta siguiente a partir de la respuesta realizada
		if(respuestaRealizada != null && respuestaRealizada.ENR_TXT_Respuesta__c != null && respuestaTipo != null){
			idPreguntaActual = respuestaTipo.idPreguntaDestIndividual;
			if(respuestaTipo.tipoRespuesta == 'Lista de Opciones'){
				// Si la pregunta tiene varias respuestas posibles, la pregunta siguiente es la correspondiente a la respuesta realizada
				idPreguntaActual = respuestaTipo.mapaPreguntasDestMultiple.get(respuestaRealizada.ENR_TXT_Respuesta__c);
			}
			if(idPreguntaActual != null){
				preguntaActual = mapaPreguntasTipo.get(idPreguntaActual);
			}
		}

		if(preguntaActual != null){
			Boolean preguntaAnterior = true;
			List<ENC_Pregunta__c> listaPreguntasTipoAux = new List<ENC_Pregunta__c>();
			// Recorrer todas las preguntas mostradas
			for(ENC_Pregunta__c pregunta : listaPreguntasMostradas){
				if(preguntaAnterior){
					// Mantener las preguntas anteriores
					listaPreguntasTipoAux.add(pregunta);
				}
				else {
					// Eliminar las respuestas posteriores
					mapaRespuestasRealizada.put(pregunta.Id, new ENC_Respuesta__c());
				}
				if(pregunta.Id == idPreguntaActualAux){
					preguntaAnterior = false;
				}
			}
			listaPreguntasTipoAux.add(preguntaActual);
			listaPreguntasMostradas = listaPreguntasTipoAux;
		}		
		system.debug('>>>>>>>>>cargarSiguientePregunta().listaPreguntasMostradas: ' + listaPreguntasMostradas);
	}


	// TODO
	public PageReference guardar(){
		PageReference paginaRedireccion = null;
		
		return paginaRedireccion;
	}

	
	/**
	 * Navega a la página correspondiente al abandonar la pantalla actual.
     * 
     * @return navegación correspondiente al abandonar la pantalla actual
     */
	public PageReference volver(){
		PageReference paginaRedireccion = new PageReference('/' + caso.Id);
		return paginaRedireccion;		
	}	
}