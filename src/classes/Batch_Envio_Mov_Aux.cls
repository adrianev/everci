/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:             everis
Company:        everis España
Description:    <Clase auxiliar para Batch_Envio_Mov>

History:  <DESCRIPCIÓN DEL CAMBIO, REQUISITO, INCIDENCIA, CORRECTIVO O MEJORA QUE HIZO ACTUALIZAR/CREAR LA CLASE>

<27/11/2017>                      everis                       <Inicio de clase>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public without sharing class Batch_Envio_Mov_Aux {
	private static List<INT_Bitacora__c> listaBitacora;
	private static Boolean manual;
	private static Callout_Centinela_Generacion callout= new Callout_Centinela_Generacion();

	/**
	 * Busca en la tabla de INT_Envio_Programado__c las tareas que 
	 * cumplen los criterios para la hora y día que es invocado.  
	 *
	 * @return      devuelve una lista de objetos bitácora. 
	 * Una por cada envío programado activo para la ejecución.
	 */
	public static List<INT_Bitacora__c> listaMovDia(List<INT_Envio_Programado__c> listaEnvioProg){
		INT_Bitacora__c bitacora;
		List<Id> listaIdConfig = new List<Id>();
		listaBitacora = new List<INT_Bitacora__c>();
		String diaSemana = getDiaSemana();
		if(listaEnvioProg==null){
			manual=false;
			listaEnvioProg = [SELECT Id,ENV_LKP_Fichero__c, ENV_SEL_Hora__c,ENV_NUM_Contador_Lote__c, ENV_LKP_Fichero__r.FIC_LKP_Compania__r.Id, ENV_LKP_Fichero__r.Name, ENV_LKP_Fichero__r.FIC_TXT_Query__c 
			                  FROM INT_Envio_Programado__c 
			                  WHERE ENV_CAS_Activo__c = true AND (ENV_DAT_Fecha_Inicio__c <= TODAY OR ENV_DAT_Fecha_Inicio__c = null) 
			                  AND (ENV_SEL_Dias_Semana__c includes (:diaSemana) OR ENV_DAT_Fecha_Puntual__c = TODAY)];
		} else{
			manual=true;
		}

		for (Integer i = listaEnvioProg.size()-1; i >= 0 ; i--) {
			if(manual==false && !Batch_Envio_Mov_Aux.compruebaRango(listaEnvioProg[i].ENV_SEL_Hora__c)){//Si es programado y no cumple el rango de horas programadas NO se envía
				listaEnvioProg.remove(i);
			} else {
				//Callout centinela para ver si el fichero ha sido recogido
				//comentado el centinela para desarrollo
			//	if(callout.updateDatos(listaEnvioProg[i].ENV_LKP_Fichero__r.Name)){
					//Creo objeto bitácora
					bitacora = new INT_Bitacora__c();
					bitacora.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO);
					bitacora.BIT_LKP_Compania__c = listaEnvioProg.get(i).ENV_LKP_Fichero__r.FIC_LKP_Compania__r.Id;
					bitacora.BIT_SEL_Estado__c = label.BIT_ESTADO_NO_ENVIADO;
					//if(!manual){//Ver cómo se asigna el número de Lote para envíos 'bajo demanda' 
						bitacora.BIT_NUM_Lote__c = listaEnvioProg.get(i).ENV_NUM_Contador_Lote__c;
					//}
					bitacora.BIT_TXT_Nombre_Fichero__c = listaEnvioProg.get(i).ENV_LKP_Fichero__r.Name;
					bitacora.BIT_SEL_Tipo_Integracion__c = label.BIT_TIPO_ENVIO_FICHERO;
					bitacora.BIT_LKP_Envio_Programado_CIA__c = listaEnvioProg.get(i).Id;
					bitacora.putSObject('BIT_LKP_Compania__r',listaEnvioProg.get(i).ENV_LKP_Fichero__r.FIC_LKP_Compania__r);
		    		bitacora.putSObject('BIT_LKP_Envio_Programado_CIA__r', listaEnvioProg.get(i));
					listaBitacora.add(bitacora);
				//}
			}
		}
		insert listaBitacora;
		marcaMovimientos();
		actualizaNumLote(listaEnvioProg);
		return listaBitacora;

	}
	//Comprueba si la hora de envío está en un rango de +-60 min
	//Cambiar cuando entre en producción
	/**
	 * Comprueba si un String de formato 'HH:MM' está en un rango
	 * de 60 minutos del momento actual.
	 *
	 * @param  t  	hora en formato 'HH:MM'.
	 * @return      true si está en rango, false si no lo está.
	 */
	public static Boolean compruebaRango(String t){
		final Integer TIEMPOMARGEN = 30;
		String[] horaMinutos = t.split(':');
		Time horaEnvio = Time.newInstance(integer.valueOf(horaMinutos[0]),integer.valueOf(horaMinutos[1]),0,0);
		Time horaNowTop = Datetime.now().time().addMinutes(TIEMPOMARGEN);
		Time horaNowBottom = Datetime.now().time().addMinutes(-TIEMPOMARGEN);
		Integer dia = 0;
		//Compruebo si estamos en horas críticas(que exista un cambio de día por el addMinutes)
		if (horaNowTop < Datetime.now().time()){
			dia = 1;
		} else if(horaNowBottom > Datetime.now().time()){
			dia = -1;
		}
		System.debug('Hora envio: ' + horaEnvio);
		System.debug('Hora Now Top: ' + horaNowTop);
		System.debug('Hora Now Bottom: ' + horaNowBottom);
		if (dia == 0){
			if (horaNowTop >= horaEnvio && horaNowBottom <= horaEnvio){
				System.debug('Hora válida');
				return true;
			}
		} else if(dia > 0){
			if (horaNowBottom <= horaEnvio){
				System.debug('Hora válida');
				return true;
			}
		} else {
			if (horaNowTop >= horaEnvio){
				System.debug('Hora válida');
				return true;
			}
		}
		System.debug('Hora no válida');
		return false;
	}

	/**
	 * Monta el JSON para la Request a partir de una lista de INT_Bitacora__c.
	 *
	 * @param  lista  	listado de INT_Bitacora__c.
	 * @return      	String conteniendo el JSON.
	 */
	public static List<String> montarPeticion(List<INT_Bitacora__c> lista){
		//@@@@Cambios 10/04 para pasar bitácora a error en caso de respuesta negativa de Callout
		listaBitacora = lista;
		//Hasta aquí
		Batch_Envio_Mov_RQ elemEnvio;
		String idFichero;
		List<Batch_Envio_Mov_RQ> listaElemEnvio = new List<Batch_Envio_Mov_RQ>();
		System.debug('***************Lista Bitácora: '+lista);
		List<INT_Bitacora__c> listaQuery = [SELECT Name, BIT_FOR_Id_Fichero__c,BIT_NUM_Lote__c, BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__r.FIC_TXT_Query__c FROM INT_Bitacora__c WHERE Id IN : lista];
		System.debug('***************Lista Query: '+listaQuery);
		List<String> toReturn = new List<String>();
		for (INT_Bitacora__c e : listaQuery){
			elemEnvio = new Batch_Envio_Mov_RQ();
			elemEnvio.idFichero = e.BIT_FOR_Id_Fichero__c;
			elemEnvio.idBitacora = e.Name;
			elemEnvio.numeroLote = String.valueOf(e.BIT_NUM_Lote__c);
			elemEnvio.queryMovimientos = e.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__r.FIC_TXT_Query__c;
			toReturn.add(JSON.serialize(elemEnvio));
		}
		return toReturn;
	}
	/**
	 * Devuelve el String correspondiente al día de la semana.
	 *
	 * @return      	String conteniendo el día de la semana.
	 */
	public static String getDiaSemana(){
		Date hoyDate = Date.today();
		String[] diasSemana = new String[]{'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'};
		Integer intDiaSemana = hoyDate.ToStartOfWeek().DaysBetween(hoyDate);
		return diasSemana[intDiaSemana];
	}

	/**
	 * Callout movimientos para aseguradoras.
	 *
	 */
	public static void invocarCallout (List<String> JsonEnvio) {
		Map<String,String> enviosError =new Map<String,String>();//Clave:Bitacora.Name contenido:errorMessage
		System.debug('Entra en el Callout');
		Batch_Envio_Mov_RP resultado = new Batch_Envio_Mov_RP();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		WS_Info__mdt ws_CBEM = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{'Callout_Batch_Envio_Mov'}).values().get(0);
		//WS_Info__mdt ws_CBEM = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Batch_Envio_Mov'][0];
		request.setEndPoint(ws_CBEM.EndPoint__c);
		request.setHeader('content-type',ws_CBEM.Content_Type__c);
		request.setMethod(ws_CBEM.Method__c);
		request.setTimeout(Integer.valueOf(ws_CBEM.TimeOut__c));
		Boolean tokenCorrecto= true;
		try{
			String returnToken = new GetTokenPSI().getToken();
			if(returnToken != ''){
        		request.setHeader('Authorization',returnToken);
        	}
		}catch(Exception e){
			system.debug('********** EXCEPTION en getTokenPSI : ' + e);
			system.debug('va a editar bitácora: '+ ((Batch_Envio_Mov_RQ)JSON.deserialize(JsonEnvio[0], Batch_Envio_Mov_RQ.class)).idBitacora);
			system.debug('con error: ' + e.getMessage());
			for(String envio:JsonEnvio){
				enviosError.put(((Batch_Envio_Mov_RQ)JSON.deserialize(envio, Batch_Envio_Mov_RQ.class)).idBitacora,e.getMessage());
			}
			informaErrores(enviosError);
			tokenCorrecto = false;
		}
		
		if(tokenCorrecto){
			for(String envio:JsonEnvio){
				request.setBody(envio);
				System.debug('>>>>>>>>>>Request: ' + request.getBody());
				HttpResponse response = http.send(request);
				System.debug('>>>>>>>>>>Response: ' + response.getBody());
				JSONParser parser = JSON.createParser(response.getBody());
				resultado = analizarRespuesta(parser);
				system.debug('>>>>>>>>>>Mensaje de error: ' + resultado.errorMessage);
				if(resultado.errorMessage !=''){
					system.debug(resultado.errorMessage);
					enviosError.put(((Batch_Envio_Mov_RQ)JSON.deserialize(envio, Batch_Envio_Mov_RQ.class)).idBitacora,resultado.errorMessage);
				} else{
					system.debug('>>>>>>>>>>Sin errorMessage en la response');
				}
			}
		}
		informaErrores(enviosError);
	}
	/**
	 * Pone en error las bitácoras con problemas en el Callout
	 */
	private static void informaErrores(Map<String,String> nombreBitError){
		system.debug('entra a informar con nombreBitError: ' + nombreBitError);
		List<INT_Bitacora__c> bitError = new List<INT_Bitacora__c>();
		for(INT_Bitacora__c bit:[SELECT Id,Name,BIT_TXT_Error__c,BIT_SEL_Estado__c FROM INT_Bitacora__c WHERE Name IN :nombreBitError.keySet()]){
			system.debug('ha encontrado resultados');
			bit.BIT_TXT_Error__c='Error en Callout: ' + nombreBitError.get(bit.Name);
			bit.BIT_SEL_Estado__c = Label.BIT_ESTADO_ERROR;
			bitError.add(bit);
		}
		system.debug('va a hacer update de: '+ bitError);
		update bitError;
		system.debug('ha hecho el update!!!');
	}
	/**
	 * Monta la Response
	 *
	 * @param  response  	JSON de la response.
	 * @return      	Batch_Envio_Mov_RP la response.
	 */
	private static Batch_Envio_Mov_RP analizarRespuesta(JSONParser response){
		Batch_Envio_Mov_RP res = new Batch_Envio_Mov_RP();
		while(response.nextToken() != null){
			String gett = response.getText();
			/*if(gett == 'resultado'){
				response.nextToken();
				res.resultado = response.getText();
			}*/
			if(gett == 'errorMessage'){
				response.nextToken();
				res.errorMessage = response.getText();
			}
			if(gett == 'errorCode'){
				response.nextToken();
				res.errorCode = response.getText();
			}
		}

		return res;
	}
	/**
	 * Añade a los movimientos su bitácora correspondiente
	 *
	 * @param  lista  	lista de elementos a enviar.
	 */
	public static void marcaMovimientos(){
		List<INT_Movimiento_CIA__c> listaMov = new List<INT_Movimiento_CIA__c>();
		for(INT_Bitacora__c bit : listaBitacora){
			//Va dentro del primer for porque por cada envio programado asociado a cada bitácora la query cambia
			//Va dentro del segundo for porque un envío programado puede tener varias querys concatenadas
			system.debug('<<<<<<<<<<<<listaBitacora>>>>>>>>>>>>' +listaBitacora);
			system.debug('<<<<<<<<<<<<bit>>>>>>>>>>>>' +bit);
			List<INT_Movimiento_CIA__c> listaMovFichero = new List<INT_Movimiento_CIA__c>();
			for(String consulta : bit.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__r.FIC_TXT_Query__c.split(';')){
				System.debug('Query' + consulta);
				listaMovFichero.addAll((List<INT_Movimiento_CIA__c>) database.query(queryMaker(consulta)));

			}
			for(Integer i=0;i<listaMovFichero.size();i++){
				listaMovFichero.get(i).MOV_LKP_Bitacora__c = bit.Id;
			}		
			system.debug('movFichero add ' + listaMovFichero);
			listaMov.addAll(listaMovFichero);
		}
		system.debug('************************Marcado de movimientos');
		System.debug(listaMov);
		update listaMov;
	}

	/**
	 * Modifica la query para traer MOV_LKP_Bitacora de movimientos
	 *
	 * @param  sentencia  	query del fichero de envío programado.
	 */
	private static String queryMaker(String sentencia){
		system.debug('>>>>>>>>>>Sentencia a queryzar: ' + sentencia);
		String retorno = 'SELECT Id, MOV_LKP_Bitacora__c, ' + sentencia.substringAfter('SELECT').replace('MOV_LKP_Bitacora__c!=null','MOV_LKP_Bitacora__c=null');
		system.debug('>>>>>>>>>>Sentencia queryzada: ' + retorno);
		return retorno;
	}
	/**
	 * Devuelve un mapa con los último numero de lote del envío de ficheros para cada tipo de envío
	 *
	 * @param  idFich  	Id del Configuración Fichero CIA a enviar.
	 *
	 * @return Nº del último lote enviado
	 */
	public static void actualizaNumLote(List<INT_Envio_Programado__c> envioProgList){
		List<INT_Envio_Programado__c> listaAux = new List<INT_Envio_Programado__c>();
		Id control;
		for(INT_Envio_Programado__c envProg : envioProgList){
			envProg.ENV_NUM_Contador_Lote__c++;
			listaAux.add(envProg);
		}
		update listaAux;
	}
}