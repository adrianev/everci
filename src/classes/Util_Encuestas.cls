/**
 * Clase de funciones auxiliares relativas a las encuestas.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Encuestas {
	
	public class RespuestaTipoVF {
		public Id idPregunta {get;set;}
		public String tipoRespuesta {get;set;}
		public List<SelectOption> listaOpciones {get;set;}
		public Id idPreguntaDestIndividual {get;set;}
		public Map<String, Id> mapaPreguntasDestMultiple {get;set;}
		public RespuestaTipoVF(Id idPregunta, String tipoRespuesta, List<SelectOption> listaOpciones,
							   Id idPreguntaDestIndividual, Map<String, Id> mapaPreguntasDestMultiple){
			this.idPregunta = idPregunta;
			this.tipoRespuesta = tipoRespuesta;
			this.listaOpciones = listaOpciones;
			this.idPreguntaDestIndividual = idPreguntaDestIndividual;
			this.mapaPreguntasDestMultiple = mapaPreguntasDestMultiple;
		}
	}

	/**
	 * Devuelve las encuestas de los IDs especificados.
	 *
	 * @param setIdEncuesta: IDs de las encuestas a buscar
	 * @return mapa que contiene las encuestas encontradas
	 */
	public static Map<Id,ENC_Encuesta_Tipo__c> queryMapEncuestaTipo(Set<Id> setIdEncuesta){
		Map<Id,ENC_Encuesta_Tipo__c> mapa = new Map<Id,ENC_Encuesta_Tipo__c>();
		if(setIdEncuesta != null && !setIdEncuesta.isEmpty()){
			for(List<ENC_Encuesta_Tipo__c> lista : [SELECT Id,Name,ENT_LKP_Cuenta__c,ENT_TXT_Identificador__c,ENT_SEL_Long_Encuesta__c
													FROM ENC_Encuesta_Tipo__c
													WHERE Id IN :setIdEncuesta]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve una encuesta a partir de su ID.
	 *
	 * @param idEncuesta: ID de la encuesta a buscar
	 * @return encuesta encontrada
	 */
	/*public static ENC_Encuesta_Tipo__c queryEncuestaTipoById(Id idEncuesta){
		ENC_Encuesta_Tipo__c encuesta = null;
		List<ENC_Encuesta_Tipo__c> lista = new List<ENC_Encuesta_Tipo__c>();
		if(idEncuesta != null){
			lista = [SELECT Id,Name,ENT_LKP_Cuenta__c,ENT_TXT_Identificador__c,ENT_SEL_Long_Encuesta__c FROM ENC_Encuesta_Tipo__c WHERE Id = :idEncuesta];
		}
		if(!lista.isEmpty()){
			encuesta = lista.get(0);
		}
		return encuesta;
	}*/




	public static ENC_Encuesta__c getEncuestaRealizadaById(Id idEncuestaRealizada){
		ENC_Encuesta__c registro = null;
		if(idEncuestaRealizada != null){
			List<ENC_Encuesta__c> lista = [SELECT Id,
												  ENC_DAT_Fecha_Hora__c,
												  ENC_LKP_Caso__c,
												  ENC_LKP_Encuesta_Tipo__c,
												  (SELECT Id FROM RespuestasRealizadas__r)
										   FROM ENC_Encuesta__c
										   WHERE Id = :idEncuestaRealizada];
			if(!lista.isEmpty()){
				registro = lista.get(0);
			}
		}
		return registro;
	}


	public static ENC_Encuesta_Tipo__c getEncuestaTipo(Id idEncuestaTipo, String nameEncuestaTipo){
		ENC_Encuesta_Tipo__c registro = null;
		List<ENC_Encuesta_Tipo__c> lista = new List<ENC_Encuesta_Tipo__c>();
		if(idEncuestaTipo != null){
			lista = [SELECT Id,
							Name,
							ENT_LKP_Cuenta__c,
							ENT_LKP_PrimeraPregunta__c,
							ENT_TXT_Identificador__c,
							ENT_SEL_Long_Encuesta__c,
							(SELECT Id FROM Preguntas__r)
					FROM ENC_Encuesta_Tipo__c
					WHERE Id = :idEncuestaTipo];
		}
		else if(nameEncuestaTipo != null){
			lista = [SELECT Id,
							Name,
							ENT_LKP_Cuenta__c,
							ENT_LKP_PrimeraPregunta__c,
							ENT_TXT_Identificador__c,
							ENT_SEL_Long_Encuesta__c,
							(SELECT Id FROM Preguntas__r)
					FROM ENC_Encuesta_Tipo__c
					WHERE Name = :nameEncuestaTipo];
		}
		if(!lista.isEmpty()){
			registro = lista.get(0);
		}
		return registro;
	}


	public static Map<Id,ENC_Pregunta__c> getMapaPreguntasByEncuestaTipo(Id idEncuestaTipo){
		Map<Id,ENC_Pregunta__c> mapa = new Map<Id,ENC_Pregunta__c>();
		if(idEncuestaTipo != null){
			mapa = new Map<Id,ENC_Pregunta__c>(
				[SELECT Id,
						Name,
						ENP_CAS_Pregunta_Gremio__c,
						ENP_FOR_PrimeraPregunta__c,
						ENP_LKP_Encuesta_Tipo__c,
						ENP_LKP_Pregunta__c,
						ENP_SEL_Tipo_Respuesta__c,
						ENP_TXT_Identificador__c,
						ENP_TXT_Pregunta__c,
						(SELECT Id FROM PreguntasSecundarias__r),
						(SELECT Id FROM RespuestasTipo__r)
				 FROM ENC_Pregunta__c
				 WHERE ENP_LKP_Encuesta_Tipo__c = :idEncuestaTipo
 				 ORDER BY ENP_LKP_Pregunta__c]);
		}
		return mapa;
	}


	public static Map<Id,RespuestaTipoVF> getMapaRespuestasTipoVFByPreguntas(Set<Id> idPreguntas){
		Map<Id,RespuestaTipoVF> mapa = new Map<Id,RespuestaTipoVF>();
		if(idPreguntas != null && !idPreguntas.isEmpty()){
			List<ENC_Respuesta_Tipo__c> lista = [SELECT Id,
														Name,
														ENRT_FOR_Tipo_Respuesta__c,
														ENRT_LKP_PreguntaDestino__c,
														ENRT_LKP_Pregunta__c,
														ENRT_NUM_Ordenacion__c,
														ENRT_TXT_Valor__c
										   		 FROM ENC_Respuesta_Tipo__c
												 WHERE ENRT_LKP_Pregunta__c IN :idPreguntas
		 										 ORDER BY ENRT_LKP_Pregunta__c, ENRT_NUM_Ordenacion__c ASC];
			for(ENC_Respuesta_Tipo__c registro : lista){
				RespuestaTipoVF registroVF = mapa.get(registro.ENRT_LKP_Pregunta__c);
				if(registroVF == null){
					List<SelectOption> listaOpciones = new List<SelectOption>();
					listaOpciones.add(new SelectOption('', '--'));
					registroVF = new RespuestaTipoVF(registro.ENRT_LKP_Pregunta__c, registro.ENRT_FOR_Tipo_Respuesta__c,
													 listaOpciones, registro.ENRT_LKP_PreguntaDestino__c, new Map<String, Id>());
				}
				if(registroVF.tipoRespuesta == 'Lista de Opciones' || registroVF.tipoRespuesta == 'Lista de Opciones (múltiple)'){
					registroVF.listaOpciones.add(new SelectOption(registro.ENRT_TXT_Valor__c, registro.ENRT_TXT_Valor__c));
					registroVF.mapaPreguntasDestMultiple.put(registro.ENRT_TXT_Valor__c, registro.ENRT_LKP_PreguntaDestino__c);
				}
				mapa.put(registro.ENRT_LKP_Pregunta__c, registroVF);
			}
		}
		return mapa;
	}
	

	public static Map<Id,ENC_Respuesta__c> getMapaRespuestasRealByEncuestaReal(Id idEncuestaRealizada, Set<Id> setIdPreguntas){
		Map<Id,ENC_Respuesta__c> mapa = new Map<Id, ENC_Respuesta__c>();
		if(idEncuestaRealizada != null){
			List<ENC_Respuesta__c> lista = [SELECT Id,
												   Name,
												   ENR_LKP_Encuesta_Realizada__c,
												   ENR_LKP_Resp_Pregunta__c,
												   ENR_LKP_WorkOrder__c,
												   ENR_TXT_Respuesta__c
										    FROM ENC_Respuesta__c
											WHERE ENR_LKP_Encuesta_Realizada__c = :idEncuestaRealizada
						 					ORDER BY ENR_LKP_Resp_Pregunta__c];	
			for(ENC_Respuesta__c registro : lista){
				mapa.put(registro.ENR_LKP_Resp_Pregunta__c, registro);
			}
		}
		for(Id idPregunta : setIdPreguntas){
			if(!mapa.containsKey(idPregunta)){
				mapa.put(idPregunta, new ENC_Respuesta__c());				
			}
		}
		return mapa;
	}
}