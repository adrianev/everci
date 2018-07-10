/**
 * Clase de funciones auxiliares relativas a las listas de selección.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Listas_Seleccion {
	// ESTE MAPA TENDRÁ LA LABEL COMO KEY Y EL API NAME COMO VALUE
	private static Map<String, Map<String, String>> mapa_Api_Label;
	// ESTE MAPA TENDRÁ EL API NAME COMO KEY Y LA LABEL COMO VALUE
	private static Map<String, Map<String, String>> mapa_Label_Api;
	// ESTE MAPA TENDRÁ LOS NUEVOS VALORES DE PICKLIST QUE HAYA QUE INSERTAR EN SALESFORCE
	public static Map<String, Set<String>> nuevosValoresPickList;

	/**
	 * Recoge la etiqueta de un valor de lista de seleccion a partir de su valor API
	 * 
	 * @param objeto Objeto en el que se realiza la búsqueda
	 * @param campoDelObjeto Key con la que se realiza la búsqueda
	 * @return mapa que relaciona las etiquetas de valores de la lista con su valor API
	 */
	public static Map<String, String> getLabelDesdeAPI(String objeto, String campoDelObjeto){
		Map<String, String> mapaLabel = new Map<String, String>();
		if(objeto != null
				&& campoDelObjeto != null){
			if(mapa_Label_Api == null){
				mapa_Label_Api = new Map<String, Map<String, String>>();
			}
			if(!mapa_Label_Api.containsKey(campoDelObjeto)){
				DescribeSObjectResult obj = Schema.getGlobalDescribe().get(objeto).getDescribe();
				DescribeFieldResult campo = obj.fields.getMap().get(campoDelObjeto).getDescribe();
				for(Schema.PicklistEntry valorCampo : campo.getPicklistValues()){
					mapaLabel.put(valorCampo.getValue(), valorCampo.getLabel());
				}
				mapa_Label_Api.put(campoDelObjeto, mapaLabel);
			}
			mapaLabel = mapa_Label_Api.get(campoDelObjeto);
		}
		//system.debug('>>>>Mapa Label - API ' + mapaLabel);
		return mapaLabel;
	}//FIN getLabelDesdeAPI

	/**
	 * Recoge el valor API de un valor de lista de seleccion a partir de su etiqueta
	 * 
	 * @param objeto Objeto en el que se realiza la búsqueda
	 * @param campoDelObjeto Key para el que se realiza la búsqueda
	 * @param valor Valor a buscar
	 * @return valor API buscado a partir de la etiqueta
	 */
	public static String getValorAPIDesdeLabel(String objeto, String campoDelObjeto, String valor){
		String valorApi;
		if(objeto != null
				&& campoDelObjeto != null
				&& valor != null){
			if(mapa_Api_Label == null){
				mapa_Api_Label = new Map<String, Map<String, String>>();
			}
			if(!mapa_Api_Label.containsKey(campoDelObjeto)){
				Map<String, String> mapaLabelApi = new Map<String, String>();
				DescribeSObjectResult obj = Schema.getGlobalDescribe().get(objeto).getDescribe();
				DescribeFieldResult campo = obj.fields.getMap().get(campoDelObjeto).getDescribe();
				for(Schema.PicklistEntry valorCampo : campo.getPicklistValues()){
					mapaLabelApi.put(valorCampo.getLabel(), valorCampo.getValue());
				}
				//system.debug('>>>>Mapa API - Label ' + mapaLabelApi);
				mapa_Api_Label.put(campoDelObjeto, mapaLabelApi);
			}
			valorApi = mapa_Api_Label.get(campoDelObjeto).get(valor);
		}
		//System.debug('>>>>valorApi: ' + valorApi);
		return valorApi;
	}//FIN getValorAPIDesdeLabel

	/**
	 * Existen listas en las que no se restringen los valores que se pueden insertar
	 * En estos casos se busca si el valor introducido coincide con uno de los nombres API de los valores de la lista 
	 * de seleccion y, si no existe, se busca si coincide con las etiquetas
	 * Si coincide con alguna de las etiquetas, se actualiza el campo del objeto poniendo el valor correcto, el API
	 *
	 * @param objeto Objeto en el que se realizan las posibles correcciones
	 * @param campos Campos en los que se van a realizar las posibles correcciones
	 */
	public static void corregirListasSeleccion(SObject objeto, List<String> campos){
		if(objeto != null
				&& campos != null){
			String tipoObjeto = objeto.getSobjectType().getDescribe().getName();
			//system.debug('>>>>tipoObjeto ' + tipoObjeto);
			if(nuevosValoresPickList == null){
				nuevosValoresPickList = new Map<String, Set<String>>();
			}
			for(String campo : campos){
				String valorTotalCampo = String.valueOf(objeto.get(campo));
				//system.debug('>>>>Campo ' + campo + ': ' + valorTotalCampo);
				if(valorTotalCampo != null){
					objeto.put(campo, '');
					for(String valorCampo : valorTotalCampo.split(';')){
						//system.debug('>>>>valorCampo ' + valorCampo);
						String valorInsertar;
						String valorCampoFormateado = limpiarAcentos(valorCampo);
						Boolean esValorApi = getLabelDesdeAPI(tipoObjeto, campo).containsKey(valorCampoFormateado);
						//system.debug('>>>>esValorApi ' + esValorApi);
						// ¿El valor se corresponde con algun valor API de la lista de seleccion?
						if(esValorApi){
							valorInsertar = valorCampoFormateado;
						}
						else{
							String apiValorCampo = Util_Listas_Seleccion.getValorAPIDesdeLabel(tipoObjeto, campo, valorCampoFormateado);
							// ¿El valor se corresponde con una etiqueta de algun valor de la lista de seleccion?
							if(apiValorCampo != null){
								valorInsertar = apiValorCampo;
							}
							// Para las listas de gremios, se debe de haber encontrado, si no = error
							// Para el resto de listas, se agrega un nuevo valor a la lista de seleccion via metadatos
							else if(campo != 'ADL_SEL_S_Gremios__c'
									/*&& campo != 'ADL_SEL_S_Gremio_Limite_Cobertura__c'*/){
								valorInsertar = valorCampoFormateado;
								// Comprobar si ya se tiene en cuenta el valor para crearse como entrada en el campo lista de seleccion
								//system.debug('>>>>NUEVA ENTRADA');
								Set<String> setValores;
								if(nuevosValoresPickList.containsKey(campo)){
									setValores = nuevosValoresPickList.get(campo);
								}else{
									setValores = new Set<String>();
								}
								//system.debug('>>>>setValores ' + setValores);
								if(!setValores.contains(valorCampoFormateado)){
									// Crear nueva entrada para la lista de seleccion
									setValores.add(valorCampoFormateado);
									nuevosValoresPickList.put(campo, setValores);
								}
							}else{
								objeto.addError('Valor inapropiado para el campo ' + campo + ': [' + valorCampoFormateado + ']');
							}
						}
						//system.debug('>>>>valorInsertar ' + valorInsertar);
						objeto.put(campo, objeto.get(campo) + valorInsertar + ';');
					}
					// Se elimina el ';' final de la cadena
					objeto.put(campo, String.valueOf(objeto.get(campo)).removeEnd(';'));
				}else{
					objeto.put(campo, null);
				}
				//system.debug('>>>>Valor insertado en campo ' + objeto.get(campo));
			}
		}
	}

	/**
	 * Limpia una cadena de texto de acentos y espacios al principio y fin
	 * @param cadena Cadena de texto a limpiar
	 * @return Cadena de texto limpia de acentos y espacios
	 */
	public static String limpiarAcentos(String cadena) {
		String limpio = null;
		if (cadena != null) {
			limpio = cadena.trim().toUpperCase();
			// Normalizar texto para eliminar tildes y dieresis 
			limpio = limpio.replace('Á', 'A');
			limpio = limpio.replace('É', 'E');
			limpio = limpio.replace('Í', 'I');
			limpio = limpio.replace('Ó', 'O');
			limpio = limpio.replace('Ú', 'U');
			limpio = limpio.replace('Ü', 'U');
		}
		//system.debug('>>>>Valor formateado ' + limpio);
		return limpio;
	}

	/**
	 * Si la lista de seleccion contiene los valores SI y NO, si se informa un SI, se toma el valor SI, 
	 * en caso contrario, se toma NO
	 * @param objeto en el que se van a realizar las correcciones
	 * @param campos Campos en los que se van a realizar las correcciones
	 */
	public static void corregirListasDecision(SObject objeto, List<String> campos){
		if(campos != null){
			String tipoObjeto = objeto.getSobjectType().getDescribe().getName();
			//system.debug('>>>>tipoObjeto ' + tipoObjeto);
			for(String campo : campos){
				String valorCampo = String.valueOf(objeto.get(campo));
				//system.debug('>>>>Campo ' + campo + ': ' + valorCampo);
				String valorInsertar;
				if(valorCampo != null){
					//system.debug('>>>>valorCampo ' + valorCampo);
					String valorCampoFormateado = limpiarAcentos(valorCampo);
					if(valorCampoFormateado.equals('SI')){
						valorInsertar = valorCampoFormateado;
					}
					else{
						valorInsertar = 'NO';
					}

				}else{
					valorInsertar = null;
				}
				//system.debug('>>>>valorInsertar ' + valorInsertar);
				objeto.put(campo, valorInsertar);
				//system.debug('>>>>Valor insertado en campo ' + objeto.get(campo));
			}
		}
	}

	/**
	 * Funciones para insertar un nuevo valor de lista de selección en un campo
	 * @param sessionID id de sesión del usuario
	 * @return metadata
	 */
	public static MetadataService.MetadataPort createService(String sessionId)
	{
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = sessionId;
		return service;
	} 

	/**
	 * Método privado que devuelve la ruta del servicio tooling asociado al Customfield de la picklist con valores nuevos.
	 *
	 * @param campo: campo con los nuevos valores de la picklist
	 * @param sessionId: Id de la sesión
	 */
	private static String getCustomFieldURL(String campo, String sessionId){
		String customFieldURL = null;
		//Map<String,Set<String>> nuevosValoresPickList = (Map<String,Set<String>>)JSON.deserialize(nuevosValoresPickListJSON,Map<String, Set<String>>.class);
		if(campo != null && sessionId != null){
			system.debug('>>>> campo: ' + campo);
			list<map<string,object>> results = new list<map<string,object>>();
			
			campo = campo.replace('__c','');
			string instanceURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
			
			HttpRequest req = new HttpRequest();
			req.setHeader('Authorization', 'Bearer ' + sessionId);
			req.setHeader('Content-Type', 'application/json');
			
			String toolingendpoint = 'https://'+instanceURL+'/services/data/v41.0/tooling/';
			//String toolingendpoint = '/services/data/v28.0/tooling/';
			
			//query for custom fields
			toolingendpoint += 'query/?q=Select+id,DeveloperName,FullName+from+CustomField+where+DeveloperName+=+\''+campo+'\'';
			req.setEndpoint(toolingendpoint);
			req.setMethod('GET');
			system.debug('>>>> req: '+req);
			Http h = new Http();
			HttpResponse res = h.send(req);
			system.debug('>>>> res.getBody(): '+res.getBody());
			//convert the original data structure into a map of objects. The data we want is in the records property of this object
			map<string,object> reqData = (map<string,object>) json.deserializeUntyped(res.getBody());
			
			//now create a list of objects from the records property. This serialize/deserialize trick is the only way I know to convert a generic object
			//into something else when the source data is 'salesforce Map encoded' (no quotes around field names or values, parenthesis to denote open and close, etc)
			list<object> fieldData = (list<object>) JSON.deserializeUntyped(JSON.serialize(reqData.get('records')));	
			
			//iterate over each object in the list and create a map of string to object out of it and add it to the list
			for(object thisObj : fieldData)
			{
				map<string, object> thisFieldData =  (map<string, object>) json.deserializeUntyped(JSON.serialize(thisObj));
				results.add(thisFieldData);
			}
			system.debug('RESULTADO: '+results);
			map<string, object> urlData = (map<string, object>)json.deserializeUntyped(JSON.serialize(results.get(0).get('attributes')));
			customFieldURL = String.valueOf(urlData.get('url'));
		}
		return customFieldURL;
	}

	/**
	 * Método privado que construye y devuelve el JSON de actualización para la Tolling API.
	 *
	 * @param toolingURL: URL del servicio REST para acceder a la Picklist por Tooling API
	 * @param objeto: objeto donde se encuentra la picklist a actualizar
	 * @param campo: campo con los nuevos valores de la picklist
	 * @param 
	 * @param sessionId: Id de la sesión
	 *
	 * @return JSON de actualización para el método que actualiza la Picklist por Tooling API
	 */
	private static String getActualizacionJSON(String toolingURL, String objeto, String campo, Set<String> valoresNuevos, String sessionId){
		String actualizacionJSON = null;
		//List<String> nuevosValoresPickList = new List<String>();
		String JSONOriginal = '';
		String nodosNuevosJSON = '';
		String etiquetaCampo = Schema.getGlobalDescribe().get(objeto).getDescribe().fields.getMap().get(campo).getDescribe().getLabel();
		Set<Map<String,String>> pickListItems = new Set<Map<String,String>>();
		if(toolingURL != null && campo != null && valoresNuevos != null && !valoresNuevos.isEmpty() && sessionId != null){
			system.debug('>>>>>>>> toolingURL: '+toolingURL);
			system.debug('>>>>>>>> campo: '+campo);
			system.debug('>>>>>>>> valoresNuevos: '+valoresNuevos);
			system.debug('>>>>>>>> sessionId: '+sessionId);
			system.debug('>>>>>>>> etiquetaCampo: '+etiquetaCampo);
			HttpRequest req = new HttpRequest();
			try{
				String tempJSON = '';
				Map<String,Object> tempJSONData = null;
				req.setEndPoint(toolingURL);
				req.setMethod('GET');
				req.setHeader('Content-Type','application/json');
				req.setHeader('Authorization','OAuth '+sessionId);
				Http h = new Http();
				HttpResponse res = h.send(req);
				JSONOriginal = JSON.serialize(((Map<String,Object>) JSON.deserializeUntyped(res.getBody())).get('Metadata'));//res.getBody();
				system.debug('>>>>>>>>>>> Metadata: '+JSONOriginal);
				// Se obtiene un conjunto con los nodos del JSON correspondientes a los valores existentes en la Picklist
				tempJSON = JSONOriginal;
				tempJSONData = (Map<String,Object>) JSON.deserializeUntyped(tempJSON);
				tempJSON = JSON.serialize(tempJSONData.get('valueSet'));
				tempJSONData = (Map<String,Object>) JSON.deserializeUntyped(tempJSON);
				tempJSON = JSON.serialize(tempJSONData.get('valueSetDefinition'));
				tempJSONData = (Map<String,Object>) JSON.deserializeUntyped(tempJSON);
				tempJSON = JSON.serialize(tempJSONData.get('value'));
				pickListItems = (Set<Map<String,String>>) JSON.deserialize(tempJSON,Set<Map<String,String>>.class);
				// Se concatenan los nodos nuevos a añadir en el JSON (los valores nuevos de la Picklist)
				for(String valorNuevo : valoresNuevos){
					if(nodosNuevosJSON != ''){
						nodosNuevosJSON += ',';
					}
					nodosNuevosJSON += '{"color":null,"default":false,"description":null,"isActive":null,"label":"'+valorNuevo+'","urls":null,"valueName":"'+valorNuevo+'"}';
				}
				if(pickListItems.size() > 0){
					nodosNuevosJSON += ',';
				}
				// Insertar la subcadena en el JSON
				actualizacionJSON = '{"Metadata":{"externalId":false,"label":"'+etiquetaCampo+'","required":false,"trackTrending":false,"type":"Picklist","valueSet":{"restricted":false,"valueSetDefinition":{"sorted":true,"value":['+nodosNuevosJSON+JSONOriginal.substringAfter('"value":[')+',"FullName":"'+objeto+'.'+campo+'"}';				
			}catch(Exception e){
				system.debug(e.getMessage());
			}
		}
		system.debug('>>>>>>>> Nodos Nuevos JSON: '+nodosNuevosJSON);
		system.debug('>>>>>>>> RESULTADO - actualizacionJSON: '+actualizacionJSON);
		return actualizacionJSON;
	}

	/**
	 * Inserta los nuevos valores de Picklist en la metadata del objeto especificado.
	 *
	 * @param objeto: objeto donde se encuentra la picklist a actualizar
	 * @param nuevosValoresPickListJSON: Json con los nuevos valores de la picklist
	 * @param sessionId: Id de la sesión
	 */
	@future (callout = true)   
	public static void createPicklistFieldTooling(String objeto, String nuevosValoresPickListJSON, String sessionId){
		system.debug('>>>> createPicklistFieldTooling.objeto: '+objeto);
		system.debug('>>>> createPicklistFieldTooling.nuevosValoresPickListJSON: '+nuevosValoresPickListJSON);
		system.debug('>>>> createPicklistFieldTooling.sessionId: '+sessionId);
		if(objeto != null && nuevosValoresPickListJSON != null && sessionId != null){
			Map<String, Set<String>> nuevosValoresPickList = (Map<String, Set<String>>) JSON.deserialize(nuevosValoresPickListJSON, Map<String, Set<String>>.class);
			for(String campo : nuevosValoresPickList.keySet()){
				Set<String> valoresNuevos = nuevosValoresPickList.get(campo);
				String rootURL = URL.getSalesforceBaseUrl().toExternalForm();
				String customFieldURL = getCustomFieldURL(campo,sessionId);
				String endPointPrefix = rootURL+customFieldURL;
				String actualizacionJSON = getActualizacionJSON(endPointPrefix,objeto,campo,valoresNuevos,sessionId);
				system.debug('>>>> createPicklistFieldTooling.valoresNuevos: '+valoresNuevos);
				system.debug('>>>> createPicklistFieldTooling.endPointPrefix: '+endPointPrefix);
				system.debug('>>>> createPicklistFieldTooling.actualizacionJSON: '+actualizacionJSON);
				if(endPointPrefix != null && actualizacionJSON != null){
					HttpRequest req = new HttpRequest();
					try{
						req.setEndPoint(endPointPrefix+'?_HttpMethod=PATCH');
						req.setMethod('POST');
						req.setHeader('Content-Type', 'application/json');
						req.setHeader('Authorization', 'OAuth '+sessionId);
						req.setBody(actualizacionJSON);
						system.debug('createPicklistFieldTooling.REQ: '+req);
						Http h = new Http();
						HttpResponse res = h.send(req);
						system.debug('createPicklistFieldTooling.GET_BODY: '+res.getBody());
					}catch(Exception e){
						system.debug(e.getMessage());
					}
				}
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */  

	@future (callout = true)   
	public static void createPicklistField(String objeto, String nuevosValoresPickListJSON, String sessionId)
	{
		if(objeto != null
				&& nuevosValoresPickListJSON != null){
			MetadataService.MetadataPort service = createService(sessionId);
			system.debug('>>>>objeto ' + objeto);
			system.debug('>>>>nuevosValoresPickListJSON ' + nuevosValoresPickListJSON);
			Map<String, Set<String>> nuevosValoresPickList = (Map<String, Set<String>>) JSON.deserialize(nuevosValoresPickListJSON, Map<String, Set<String>>.class);
			for(String campo : nuevosValoresPickList.keySet()){
				system.debug('>>>>campo ' + campo);
				Set<String> valoresLista = nuevosValoresPickList.get(campo);
				DescribeFieldResult descripcionCampo = Schema.getGlobalDescribe().get(objeto).getDescribe().fields.getMap().get(campo).getDescribe();
				String labelObjeto = descripcionCampo.getLabel();
				system.debug('>>>>descripcionCampo ' + descripcionCampo);
				List<MetadataService.PicklistValue> listaValores = new List<MetadataService.PicklistValue>();
				for(String valor : valoresLista){
					system.debug('>>>>valor ' + valor);
					MetadataService.PicklistValue pval = new MetadataService.PicklistValue();
					pval.fullName = valor;
					pval.default_x = false;
					listaValores.add(pval);
				}
				MetadataService.CustomField customField = new MetadataService.CustomField();
				customField.fullName = objeto + '.' + campo;
				customField.label = labelObjeto;
				if(String.valueOf(descripcionCampo.getType()) == 'MULTIPICKLIST'){
					system.debug('>>>>Multipicklist');
					customField.type_x = 'MultiselectPicklist';
					customField.visibleLines = 4;
				}else{
					system.debug('>>>>Picklist');
					customField.type_x = 'Picklist';
				}
				MetadataService.Picklist sown = new MetadataService.Picklist();
				sown.sorted = true;
				sown.picklistValues = listaValores;
				customField.picklist = sown;
				system.debug('>>>>customField ' + customField);
				if(!Test.isRunningTest()){
					List<MetadataService.SaveResult> results = 
							service.updateMetadata(
									new MetadataService.Metadata[] { customField });
					system.debug('>>>>results ' + results);
				}
			}
		}
	}
}//FIN Util_Listas_Seleccion