/**
 * Clase de funciones auxiliares relativas a la generación de Documentación.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Documentacion {
	public static final String PREFIJO_VISUALFORCE_PDF = 'PDF_';
	public static final String EXTENSION_PDF = '.pdf';
	
	/**
	 * Devuelve un ContentVersion resultante de generar un documento PDF mediante una plantilla VisualForce.
	 *
	 * @param idControlador: Id del Objeto principal del controlador del PDF
	 * @param idPadre: Id del Objeto padre (si el objeto es diferente del objeto del controlador)
	 * @param tipoPlantilla: tipo de plantilla PDF a utilizar
	 * @param codigoCIA: código de la CIA en HomeServe
	 * @param idioma: código del Idioma
	 * @param identificadorDoc: texto identificador para el título del documento
	 * @param sufijoDoc: texto sufijo para el título del documento
	 * @param tipoDestino: variable que indica si el documento es para un cliente o para una compañia
	 *
	 * @return documento PDF generado mediante una plantilla VisualForce
	 */
	public static ContentVersion crearPDFDesdeVF(Id idControlador, Id idPadre, String tipoPlantilla, String codigoCIA, 
												String idioma, String identificadorDoc, String sufijoDoc, String tipoDestino) {

		return crearPDFDesdeVF(idControlador,idPadre,tipoPlantilla,codigoCIA,idioma,identificadorDoc,sufijoDoc,tipoDestino,null);
	}


	/**
	 * Devuelve un ContentVersion resultante de generar un documento PDF mediante una plantilla VisualForce.
	 *
	 * @param idControlador: Id del Objeto principal del controlador del PDF
	 * @param idPadre: Id del Objeto padre (si el objeto es diferente del objeto del controlador)
	 * @param tipoPlantilla: tipo de plantilla PDF a utilizar
	 * @param codigoCIA: código de la CIA en HomeServe
	 * @param idioma: código del Idioma
	 * @param identificadorDoc: texto identificador para el título del documento
	 * @param sufijoDoc: texto sufijo para el título del documento
	 * @param tipoDestino: variable que indica si el documento es para un cliente o para una compañia
	 * @param argumentos: mapa de parámetros adicionales para la plantilla visualForce
	 *
	 * @return documento PDF generado mediante una plantilla VisualForce
	 */ 
	public static ContentVersion crearPDFDesdeVF(Id idControlador, Id idPadre, String tipoPlantilla, String codigoCIA, 
												String idioma, String identificadorDoc, String sufijoDoc, String tipoDestino, Map<String,String> argumentos) {
		ContentVersion cv = null;
		if (tipoPlantilla != null) {
			// 1. Obtener VisualForce fuente de la plantilla del documento a generar
			String vfPlantilla = getVFPlantillaPDF(tipoPlantilla, codigoCIA, idioma);
			if (vfPlantilla == null) {
				throw new Util_Documentacion_Exception('No se ha encontrado ningún archivo fuente para la plantilla de PDF de tipo ' + tipoPlantilla + '.');
			}
			else {
				cv = new ContentVersion();
				PageReference pdf = new PageReference('/apex/' + vfPlantilla);

				// 2. Establecer nombre del documento a generar
				cv.Title = getNombreDocumentoPDF(tipoPlantilla, identificadorDoc, sufijoDoc);

				// 3. Establecer registro padre del documento a generar
				String locationId = idControlador;
				if (idPadre != null) {
					locationId = idPadre;
				}
				if (locationId == null) {
					throw new Util_Documentacion_Exception('No se ha especificado el registro padre del PDF generado.');
				}
				else {
					try {
						cv.FirstPublishLocationId = locationId;
						cv.PathOnClient = cv.Title;
						pdf.getParameters().put('id', idControlador);
						if(tipoDestino != null){
							pdf.getParameters().put('tipoDestino', tipoDestino);
						}
						if(idioma != null){
							pdf.getParameters().put('idioma', idioma);
						}
						if(argumentos != null && !argumentos.isEmpty()){
							for(String param: argumentos.keySet()){
								pdf.getParameters().put(param,argumentos.get(param));
							}
						}
						if (!Test.isRunningTest()) {
							cv.VersionData = pdf.getContent();
						}
						else {
							//Si es un test le introducimos el Blob de un documento de texto con un caracter 'a'
							cv.VersionData = EncodingUtil.base64Decode('YQ==');
						}
						insert cv;
						cv = Util_ContentVersion.queryCVById(new Set<Id>{cv.Id}).get(cv.Id);
						//cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :cv.Id];
						ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = UserInfo.getOrganizationId(),
																		  ContentDocumentId=cv.ContentDocumentId,
																		  ShareType = 'C',
																		  Visibility = 'AllUsers');
						insert cdl;
					}
					catch (exception e) {
						system.debug('exception: '+ e.getStackTraceString());
						throw new Util_Documentacion_Exception('Se ha producido un error al generar el documento PDF de ' + tipoPlantilla + '.');
					}
				}
			}
		}
		return cv;
	}

	/**
	 * Construye un nombre de documento PDF a partir del tipo de plantilla, un identificador y un sufijo.
	 * @param tipoPlantilla: tipo de plantilla
	 * @param identificadorDoc: texto identificador
	 * @param sufijo: texto sufijo (por ejemplo un timestamp)
	 * 
	 * @return nombre de documento PDF: tipoPlantilla_identificador_sufijo.pdf
	 */
	private static String getNombreDocumentoPDF(String tipoPlantilla, String identificadorDoc, String sufijoDoc) {
		String nombreDoc = tipoPlantilla;
		if (identificadorDoc != null) {
			nombreDoc += '_' + identificadorDoc;
		}
		if (sufijoDoc != null) {
			nombreDoc += '_' + sufijoDoc;
		}
		nombreDoc += EXTENSION_PDF;
		return nombreDoc;
	}

	/**
	 * Devuelve los baremos IEC que coincidan con los IDs pasados por parámetro.
	 *
	 * @param setIdBaremo: conjunto de IDs de los baremos relacionados con los baremos IEC buscados
	 *
	 * @return mapa que contiene los baremos IEC coincidentes
	 */
	public static Map<Id,Baremo_IEC__c> queryMapBaremoIEC(Set<Id> setIdBaremo){
		Map<Id,Baremo_IEC__c> mapa = new Map<Id,Baremo_IEC__c>();
		if(setIdBaremo != null && !setIdBaremo.isEmpty()){
			for(List<Baremo_IEC__c> lista : [SELECT Id,
													BAR_IEC_TXT_Texto__c, 
													BAR_IEC_SEL_Tipo__c, Name
											FROM Baremo_IEC__c
											WHERE BAR_IEC_LKP_Baremo__c IN :setIdBaremo
											ORDER BY BAR_IEC_NUM_Ordenacion__c]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los baremos IEC que coincidan con un determinado ID de baremos.
	 *
	 * @param idBaremo: ID del baremo relacionado con los baremos IEC buscados
	 *
	 * @return lista de baremos IEC coincidentes
	 */
	/*public static List<Baremo_IEC__c> queryBaremoIEC(Id idBaremo){
		List<Baremo_IEC__c> registros = new List<Baremo_IEC__c>();
		if(idBaremo != null){
			registros = [SELECT Id,
								BAR_IEC_TXT_Texto__c, 
								BAR_IEC_SEL_Tipo__c, Name
						 FROM Baremo_IEC__c
						 WHERE BAR_IEC_LKP_Baremo__c = :idBaremo
						 ORDER BY BAR_IEC_NUM_Ordenacion__c];
		}
		return registros;
	}*/

	/**
	 * Devuelve los ContentDocumentLink que coincidan con el filtro pasado por parámetro.
	 *
	 * @param filtro: filtro aplicado a la búsqueda de objetos ContentDocumentLink
	 *
	 * @return lista que contiene los ContentDocumentLink encontrados con el filtro
	 */
	/*public static List<ContentDocumentLink> queryCDL(String filtro){
		List<ContentDocumentLink> registros = new List<ContentDocumentLink>();
		if(filtro != null){
			String query = 'SELECT Id,';
			query += ' ContentDocumentId,';
			query += ' ContentDocument.FileType,';
			query += ' ContentDocument.LatestPublishedVersionId,';
			query += ' ContentDocument.LatestPublishedVersion.Createddate,';
			query += ' ContentDocument.Title,';
			query += ' LinkedEntityId';
			query += ' FROM ContentDocumentLink WHERE '+filtro;
			system.debug('>>>>Util_Documentacion.queryCDL.query: '+query);
			registros = database.query(query);
		}
		return registros;
	}*/

	/**
	 * Devuelve los ContentDocumentLink's filtrando por los LinkedEntityId's.
	 *
	 * @param setLinkedEntityId: conjunto de LinkedEntityId's
	 *
	 * @return mapa que contiene los ContentDocumentLink's encontrados
	 */
	public static Map<Id,ContentDocumentLink> queryCDLByLinkedEntity(Set<Id> setLinkedEntityId){
		Map<Id,ContentDocumentLink> mapa = new Map<Id,ContentDocumentLink>();
		if(setLinkedEntityId != null && !setLinkedEntityId.isEmpty()){
			for(List<ContentDocumentLink> lista:[Select id,
														ContentDocumentId,
														ContentDocument.LatestPublishedVersionId,
														ContentDocument.LatestPublishedVersion.Createddate
													from ContentDocumentLink
													where LinkedEntityId IN :setLinkedEntityId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los ContentDocumentLink's filtrando por los LinkedEntityId's y un prefijo del título.
	 *
	 * @param setLinkedEntityId: conjunto de LinkedEntityId's
	 * @param prefijo: prefijo del Title en notación LIKE
	 *
	 * @return mapa que contiene los ContentDocumentLink's encontrados
	 */
	public static Map<Id,ContentDocumentLink> queryCDLByLinkedEntityAndLikeTitle(Set<Id> setLinkedEntityId, String prefijo){
		Map<Id,ContentDocumentLink> mapa = new Map<Id,ContentDocumentLink>();
		if(setLinkedEntityId != null && !setLinkedEntityId.isEmpty() && prefijo != null){
			for(List<ContentDocumentLink> lista:[Select id,
														ContentDocumentId,
														ContentDocument.LatestPublishedVersionId,
														ContentDocument.LatestPublishedVersion.Createddate
													from ContentDocumentLink
													where LinkedEntityId IN :setLinkedEntityId
													and ContentDocument.Title like :prefijo order by ContentDocument.LatestPublishedVersion.Createddate desc]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el nombre de la página VisualForce que se va a utiliar para generar el PDF
	 * a partir del tipo de plantilla, el código de la CIA y el código del idioma.
	 * @param tipoPlantilla: tipo de plantilla
	 * @param codigoCIA: identificador de la CIA en HomeServe
	 * @param idioma: código de idioma
	 * 
	 * @return página VisualForce que se va a utiliar para generar el PDF
	 */
	private static String getVFPlantillaPDF(String tipoPlantilla, String codigoCIA, String idioma) {
		String plantillaExistente = null;
		if (idioma != null) {
			idioma = '_' + idioma;
		}
		else {
			idioma = '';
		}
		
		if(codigoCIA == null){
			codigoCIA = '';
		}
		
		if (tipoPlantilla != null) {
			List<String> nombresPlantilla = new List<String>();
			// Buscar plantilla con CIA
			nombresPlantilla.add(PREFIJO_VISUALFORCE_PDF + tipoPlantilla + '_' + codigoCIA + idioma);
			// Buscar plantilla con CIA HomeServe
			nombresPlantilla.add(PREFIJO_VISUALFORCE_PDF + tipoPlantilla + '_' + Label.IDE_HOMESERVE + idioma);
			// Buscar plantilla sin CIA
			nombresPlantilla.add(PREFIJO_VISUALFORCE_PDF + tipoPlantilla + idioma);
			// Buscar plantilla con CIA y sin idioma
			nombresPlantilla.add(PREFIJO_VISUALFORCE_PDF + tipoPlantilla + '_' + codigoCIA + '_' + Label.IDIOMA_POR_DEFECTO);
			// Buscar plantilla con CIA HomeServe y sin idioma
			nombresPlantilla.add(PREFIJO_VISUALFORCE_PDF + tipoPlantilla + '_' + Label.IDE_HOMESERVE + '_' + Label.IDIOMA_POR_DEFECTO);
			// Buscar plantilla sin CIA y sin idioma
			nombresPlantilla.add(PREFIJO_VISUALFORCE_PDF + tipoPlantilla + '_' + Label.IDIOMA_POR_DEFECTO);
			
			List<ApexPage> listaApexPage = new List<ApexPage>();
			
			/*for(String nombre: nombresPlantilla){
				if(listaApexPage.isEmpty()){
					listaApexPage = [SELECT Name
									 FROM ApexPage
									 WHERE Name = :nombre];
				} 
			}*/
			listaApexPage=[SELECT Name FROM ApexPage WHERE Name IN :nombresPlantilla];
			if(!listaApexPage.isEmpty()){
				plantillaExistente = listaApexPage.get(0).Name;
			}
		}
		return plantillaExistente;
	}
}