/**
 * Clase de funciones auxiliares relativas a los metadatos.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Metadatos {

	private static final Map<Id, Orden_de_trabajo__mdt> mapaOT = getMapaOT();
	private static final Map<Id, Casos__mdt> mapaCasos = getMapaCasos();
	private static final Map<Id, Tareas__mdt> mapaTareas = getMapaTareas();
	private static final Map<Id, Naturaleza__mdt> mapaNaturaleza = getMapaNaturaleza();
	private static final Map<Id, Tipo_de_Reclamacion__mdt> mapaTipoReclamacion = getMapaTipoReclamacion();
	private static final Map<Id, Causa_de_la_reclamacion__mdt> mapaCausaReclamacion = getMapaCausaReclamacion();
	
	public static final Map<String, Configuracion_General__mdt> CONFIG_GENERAL = getMapaConfGeneral();
	public static final Map<String, Orden_de_trabajo__mdt> mapaOTEstadoCIA = getMapaOTEstadoCIA();
	public static final Map<String, Casos__mdt> mapaCasosEstadoCIA = getMapaCasoEstadoCIA();
	public static final Map<String, Tareas__mdt> mapaTareaTipo = getMapaTareaTipo();
	public static final Map<String, List<Naturaleza__mdt>> mapaNaturalezaCIA = getMapaNaturalezaCIA();
	public static final Map<String, List<Tipo_de_Reclamacion__mdt>> mapaTipoReclamacionCIA = getMapaTipoReclamacionCIA();
	public static final Map<String, List<Causa_de_la_reclamacion__mdt>> mapaCausaReclClave = getMapaCausaReclClave();

	/**
	 * Devuelve las configuraciones filtradas por el DeveloperName.
	 *
	 * @param setDevName: conjunto de DeveloperName's
	 *
	 * @return mapa que contiene las configuraciones encontradas
	 */
	public static Map<Id,Configuracion_VDN__mdt> getConfVDNMetadataByDevName(Set<String> setDevName){
		Map<Id,Configuracion_VDN__mdt> mapa = new Map<Id,Configuracion_VDN__mdt>();
		if(setDevName != null && !setDevName.isEmpty()){
			for(List<Configuracion_VDN__mdt> lista:[SELECT Distancia_prioridad__c,LoadId__c,ServiceId__c FROM Configuracion_VDN__mdt WHERE DeveloperName IN :setDevName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los objetos de Integración de Movimiento CIA filtrados por los identificadores CIA y las acciones.
	 *
	 * @param setIdentificadorCIA: conjunto de identificadores CIA
	 * @param setAccion: conjunto de acciones
	 *
	 * @return mapa que contiene los objetos de Integración de Movimiento CIA encontrados
	 */
	public static Map<Id,Integracion_Movimiento_CIA__mdt> getIntMovCIAMetadata(Set<String> setIdentificadorCIA, Set<String> setAccion){
		Map<Id,Integracion_Movimiento_CIA__mdt> mapa = new Map<Id,Integracion_Movimiento_CIA__mdt>();
		if(setIdentificadorCIA != null && !setIdentificadorCIA.isEmpty() && setAccion != null && !setAccion.isEmpty()){
			for(List<Integracion_Movimiento_CIA__mdt> lista:[SELECT Id,MasterLabel,Identificador_CIA__c,Codigo_de_Movimiento__c,Codigo_de_Modificacion__c,Accion__c FROM Integracion_Movimiento_CIA__mdt WHERE Identificador_CIA__c IN :setIdentificadorCIA AND Accion__c IN :setAccion]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve la Metadata de WS_Info__mdt filtrada por las MasterLabels.
	 *
	 * @param setMasterLabel: conjunto de MasterLabels
	 *
	 * @return mapa que contiene la Metadata de WS_Info__mdt encontrada
	 */
	public static Map<Id,WS_Info__mdt> getWSInfoMetadataByMasterLabel(Set<String> setMasterLabel){
		Map<Id,WS_Info__mdt> mapa = new Map<Id,WS_Info__mdt>();
		if(setMasterLabel != null && !setMasterLabel.isEmpty()){
			for(List<WS_Info__mdt> lista:[SELECT Id,MasterLabel,Content_Type__c,EndPoint__c,Method__c,TimeOut__c FROM WS_Info__mdt WHERE MasterLabel IN :setMasterLabel]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelven los Excepciones_Servicios__mdt filtrados por TXT_Codigo_Error__c.
	 *
	 * @param setCodErr: conjunto de códigos de error
	 *
	 * @return mapa que contiene objetos Excepciones_Servicios__mdt encontrados
	 */
	public static Map<Id,Excepciones_Servicios__mdt> getExpServiciosByCodError(Set<String> setCodErr){
		Map<Id,Excepciones_Servicios__mdt> mapa = new Map<Id,Excepciones_Servicios__mdt>();
		if(setCodErr != null && !setCodErr.isEmpty()){
			for(List<Excepciones_Servicios__mdt> lista:[SELECT TXT_Codigo_Error__c,TXT_Descripcion_Error__c FROM Excepciones_Servicios__mdt WHERE TXT_Codigo_Error__c IN :setCodErr LIMIT 1]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Se crea un mapa con los metadatos de configuración general
	 * 
	 * @return mapa con los metadatos de configuración general
	 */
	private static Map<String, Configuracion_General__mdt> getMapaConfGeneral(){
		Map<String, Configuracion_General__mdt> mapaRetorno = CONFIG_GENERAL;	
		if(mapaRetorno == null){
			mapaRetorno = new Map<String, Configuracion_General__mdt>();
			List<Configuracion_General__mdt> lista = new List<Configuracion_General__mdt>(
				[SELECT Id,
						CF_DAT_Valor__c,
						CF_DEC_Valor__c,
						CF_NUM_Valor__c,
						CF_SEL_Categoria_Habilidad__c,
						CF_SEL_Unidad_Medida__c,
						CF_TXT_Valor__c,
						DeveloperName,
						Label
				 FROM Configuracion_General__mdt]);
			for(Configuracion_General__mdt registro : lista){
				mapaRetorno.put(registro.DeveloperName, registro);
			}
		}
		return mapaRetorno;
	}
	
	/**
	 * Se crea un mapa con los metadatos de orden de trabajo
	 * 
	 * @return mapa con los metadatos de órdenes de trabajo
	 */
	private static Map<Id, Orden_de_trabajo__mdt> getMapaOT(){
		Map<Id, Orden_de_trabajo__mdt> mapaRetorno = new Map<Id, Orden_de_trabajo__mdt>(
				[SELECT MTD_OTR_TXT_Compania__c, 
				 MTD_OTR_NUM_Horas_amarillo__c,
				 MTD_OTR_NUM_Horas_verde__c,
				 MTD_OTR_NUM_Duracion_estimada__c,
				 MTD_OTR_TXT_Estado__c,
				 MTD_OTR_SEL_Prioridad__c,
				 MTD_OTR_TXT_Descripcion_Tarea__c,
				 MTD_OTR_CAS_Tarea__c,
				 MTD_OTR_TXT_Tipo_Tarea__c,
				 MTD_OTR_CAS_Bloquea_Semaforo__c,
				 //MTD_OTR_CAS_Requiere_Fecha_Para_Cuando__c,
				 MTD_OTR_CAS_Evento__c,
				 MTD_OTR_CAS_Espera_Bloqueo__c
				 FROM Orden_de_trabajo__mdt]);
		return mapaRetorno;
	}

	/**
	 * Se crea un mapa con los metadatos de caso
	 * 
	 * @return mapa con los metadatos de caso
	 */
	private static Map<Id, Casos__mdt> getMapaCasos(){
		Map<Id, Casos__mdt> mapaRetorno = new Map<Id, Casos__mdt>(
			[SELECT MTD_CAS_TXT_Compania__c,
					MTD_CAS_NUM_Dias_amarillo__c,
					MTD_CAS_NUM_Dias_verde__c,
					MTD_CAS_NUM_Duracion_estimada__c,
					MTD_CAS_SEL_Estado_c__c,
					MTD_CAS_SEL_Prioridad__c,
					MTD_CAS_TXT_Descripcion_Tarea__c,
					MTD_CAS_CAS_Tarea__c
			 FROM Casos__mdt]);
		return mapaRetorno;
	}

	 /**
	  * Se crea un mapa con los metadatos de tarea
	  * 
	  * @return mapa con los metadatos de tarea
	  */
	private static Map<Id, Tareas__mdt> getMapaTareas(){
		Map<Id, Tareas__mdt> mapaRetorno = new Map<Id, Tareas__mdt>(
			[SELECT MTD_TAR_SEL_Prioridad__c,
					MTD_TAR_TXT_Tipo_Tarea__c
			 FROM Tareas__mdt]);
		return mapaRetorno;
	}

	/**
	 * Se crea un mapa con los metadatos de naturaleza
	 *
	 * @return mapa con los metadatos de naturaleza
	 */
	private static Map<Id, Naturaleza__mdt> getMapaNaturaleza(){
		Map<Id, Naturaleza__mdt> mapaRetorno = new Map<Id, Naturaleza__mdt>(
			[SELECT MTD_NAT_TXT_Identificador__c,
					MTD_NAT_TXT_Naturaleza_cia__c,
					MTD_NAT_TXT_Naturaleza_HS__c
			 FROM Naturaleza__mdt]);
		return mapaRetorno;
	}

	/**
	 * Se crea un mapa con los metadatos de tipo de reclamación
	 *
	 * @return mapa con los metadatos de tipo de reclamación
	 */
	private static Map<Id, Tipo_de_Reclamacion__mdt> getMapaTipoReclamacion(){
		Map<Id, Tipo_de_Reclamacion__mdt> mapaRetorno = new Map<Id, Tipo_de_Reclamacion__mdt>(
			[SELECT MTD_TIPORECL_TXT_Identificador__c,
					MTD_TIPORECL_TXT_Tipo_de_la_Reclamacion__c
			 FROM Tipo_de_Reclamacion__mdt]);
		return mapaRetorno;
	}

	/**
	  * Se crea un mapa con los metadatos de causa de la reclamación
	  * 
	  * @return mapa con los metadatos de causa de la reclamación
	  */
	private static Map<Id, Causa_de_la_reclamacion__mdt> getMapaCausaReclamacion(){
		Map<Id, Causa_de_la_reclamacion__mdt> mapaRetorno = new Map<Id, Causa_de_la_reclamacion__mdt>(
				[SELECT MTD_CAUSA_TXT_Causa_de_la_reclamacion__c,
						MTD_CAUSA_TXT_Naturaleza__c,
						MTD_CAUSA_TXT_Reclamacion__c,
						MTD_CAUSA_TXT_Tipologia__c
				 FROM Causa_de_la_reclamacion__mdt]);
		return mapaRetorno;
	}

	/**
	 * Se crea un mapa que relaciona la compañía con órdenes de trabajo y estado
	 *
	 * @return mapa que relaciona la compañía  con las órdenes de trabajo y estado
	 */
	private static Map<String, Orden_de_trabajo__mdt> getMapaOTEstadoCIA(){
		Map<String, Orden_de_trabajo__mdt> mapaRetorno = new Map<String, Orden_de_trabajo__mdt>();
		for(Orden_de_trabajo__mdt ot : mapaOT.values()){
			String estadoCIA = ot.MTD_OTR_TXT_Estado__c + '' + ot.MTD_OTR_TXT_Compania__c;
			mapaRetorno.put(estadoCIA, ot);
		}
		return mapaRetorno;
	}

	/**
	 * Se crea un mapa que relaciona la compañía con casos
	 *
	 * @return mapa que relaciona la compañía  con casos
	 */
	private static Map<String, Casos__mdt> getMapaCasoEstadoCIA(){
		Map<String, Casos__mdt> mapaRetorno = new Map<String, Casos__mdt>();
		for(Casos__mdt caso : mapaCasos.values()){
			String estadoCIA = String.valueOf(caso.MTD_CAS_SEL_Estado_c__c) + String.valueOf(caso.MTD_CAS_TXT_Compania__c);
			mapaRetorno.put(estadoCIA, caso);
		}
		return mapaRetorno;
	}

	/**
	 * Se crea un mapa que relaciona el tipo de tarea con su prioridad
	 *
	 * @return mapa que relaciona el tipo de tarea con su prioridad
	 */
	private static Map<String, Tareas__mdt> getMapaTareaTipo(){
		Map<String, Tareas__mdt> mapaRetorno = new Map<String, Tareas__mdt>();
		for(Tareas__mdt tarea : mapaTareas.values()){
			String tipo = tarea.MTD_TAR_TXT_Tipo_Tarea__c;
			mapaRetorno.put(tipo, tarea);
		}
		return mapaRetorno;
	}

	/**
	 * Se crea un mapa que relaciona la compañía con sus naturalezas
	 *
	 * @return mapa 
	 */
	private static Map<String, List<Naturaleza__mdt>> getMapaNaturalezaCIA(){
		Map<String, List<Naturaleza__mdt>> mapaRetorno = new Map<String, List<Naturaleza__mdt>>();
		for(Naturaleza__mdt natur : mapaNaturaleza.values()){
			String cia = natur.MTD_NAT_TXT_Identificador__c;
			List<Naturaleza__mdt> tempList = mapaRetorno.get(cia);
			if(tempList == null)
				tempList = new List<Naturaleza__mdt>();
			templist.add(natur);
			mapaRetorno.put(cia, templist);
		}
		return mapaRetorno;
	}
	  
	/**
	 * Se crea un mapa que relaciona la compañía con sus tipos de reclamación
	 *
	 * @return mapa 
	 */
	private static Map<String, List<Tipo_de_Reclamacion__mdt>> getMapaTipoReclamacionCIA(){
		Map<String, List<Tipo_de_Reclamacion__mdt>> mapaRetorno = new Map<String, List<Tipo_de_Reclamacion__mdt>>();
		for(Tipo_de_Reclamacion__mdt tRec : mapaTipoReclamacion.values()){
			String cia = tRec.MTD_TIPORECL_TXT_Identificador__c;
			List<Tipo_de_Reclamacion__mdt> tempList = mapaRetorno.get(cia);
			if(tempList == null){
				tempList = new List<Tipo_de_Reclamacion__mdt>();
			}
			templist.add(tRec);
			mapaRetorno.put(cia, templist);
		}
		return mapaRetorno;
	}


	/**
	 * Se crea un mapa que tipología, fundada y naturaleza con su causa de reclamación
	 *
	 * @return mapa 
	 */
	private static Map<String, List<Causa_de_la_reclamacion__mdt>> getMapaCausaReclClave(){
		Map<String, List<Causa_de_la_reclamacion__mdt>> mapaRetorno = new Map<String, List<Causa_de_la_reclamacion__mdt>>();
		for(Causa_de_la_reclamacion__mdt causa : mapaCausaReclamacion.values()){
			String tipol = causa.MTD_CAUSA_TXT_Tipologia__c;
			String fund = causa.MTD_CAUSA_TXT_Reclamacion__c;
			String natur = causa.MTD_CAUSA_TXT_Naturaleza__c;
			String clave = tipol+fund+natur;
			List<Causa_de_la_reclamacion__mdt> tempList = mapaRetorno.get(clave);
			if(tempList == null){
				tempList = new List<Causa_de_la_reclamacion__mdt>();
			}
			templist.add(causa);
			mapaRetorno.put(clave, tempList);
		}
		return mapaRetorno;
	}

	/**
	 * Devuelve el mapa de traduciones cuyo valor es la traducción y
	 * como clave tendrá la concatenación de Idioma, código de CIA, Campo y Valor.
	 *
	 * @return mapa
	 */
	public static Map<String,String> getMapaTraduccion(String objeto){
		String clave;
		Map<String,String> mapa = new Map<String,String>();
		List<INT_TraduccionSistExt__mdt> listMdtTraduccion = new List<INT_TraduccionSistExt__mdt>(
				[SELECT CodigoIdioma__c,
						IdSistemaExterno__c,
						Campo__c,
						ValorExterno__c,
						ValorSalesforce__c
				 FROM INT_TraduccionSistExt__mdt WHERE Objeto__c =:objeto]);
		for(INT_TraduccionSistExt__mdt mdt : listMdtTraduccion){
			clave = mdt.CodigoIdioma__c +  mdt.IdSistemaExterno__c + mdt.Campo__c + mdt.ValorSalesforce__c;
			mapa.put(clave,mdt.ValorExterno__c);
		}
		return mapa;
	}
	
	/**
	 * Devuelve el mapa de traduciones cuyo valor es la traducción y
	 * como clave tendrá la concatenación de Idioma, código de CIA, Campo y Valor.
	 *
	 *@param setObjeto: Nombre del objeto
	 *
	 * @return mapa
	 */
	public static Map<String,String> getMapaTraduccion(set<String> setObjeto){
		String clave;
		Map<String,String> mapa = new Map<String,String>();
		Map<Id,INT_TraduccionSistExt__mdt> mapaTrad = new Map<Id,INT_TraduccionSistExt__mdt>();
		for(List<INT_TraduccionSistExt__mdt> listMdtTraduccion : 
			[SELECT CodigoIdioma__c,
				IdSistemaExterno__c,
				Campo__c,
				ValorExterno__c,
				ValorSalesforce__c
				FROM INT_TraduccionSistExt__mdt WHERE Objeto__c IN :setObjeto]){
			mapaTrad.putAll(listMdtTraduccion);
		}

		for(INT_TraduccionSistExt__mdt mdt : mapaTrad.values()){
			clave = mdt.CodigoIdioma__c +  mdt.IdSistemaExterno__c + mdt.Campo__c + mdt.ValorSalesforce__c;
			mapa.put(clave,mdt.ValorExterno__c);
		}
		return mapa;
	}
	

	/**
	 * Devuelve la programación de citas filtrando por los identificadores, las segmentaciones y por si es capital de provincia.
	 *
	 * @param setIdentificadorCIA: conjunto de identificadores de la programación de citas
	 * @param setSegmentacion: conjunto de segmentaciones de la programación de citas
	 * @param capitalProvincia: si es capital de provincia o no
	 *
	 * @return mapa que contiene la programación de citas encontradas
	 */
	public static Map<Id,Programacion_cita__mdt> getProgCitaByIdCIAAndSegmentAndCapitalProv(Set<String> setIdentificadorCIA, Set<String> setSegmentacion, Boolean capitalProvincia){
		Map<Id,Programacion_cita__mdt> mapa = new Map<Id,Programacion_cita__mdt>();
		if(setIdentificadorCIA != null && !setIdentificadorCIA.isEmpty() && setIdentificadorCIA != null && !setIdentificadorCIA.isEmpty() && capitalProvincia != null){
			for(List<Programacion_cita__mdt> lista : [SELECT PRC_TXT_Identificador_CIA__c,PRC_TXT_Segmentacion__c,PRC_CAS_Capital_Provincia__c,PRC_NUM_Plazo__c FROM Programacion_cita__mdt WHERE PRC_TXT_Identificador_CIA__c IN :setIdentificadorCIA AND PRC_TXT_Segmentacion__c IN :setSegmentacion AND PRC_CAS_Capital_Provincia__c = :capitalProvincia AND PRC_NUM_Plazo__c != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve la programación de citas filtrando por los identificadores, las segmentaciones.
	 *
	 * @param setIdentificadorCIA: conjunto de identificadores de la programación de citas
	 * @param setSegmentacion: conjunto de segmentaciones de la programación de citas
	 *
	 * @return mapa que contiene la programación de citas encontradas
	 */
	public static Map<Id,Programacion_cita__mdt> getProgCitaByIdCIAAndSegment(Set<String> setIdentificadorCIA, Set<String> setSegmentacion){
		Map<Id,Programacion_cita__mdt> mapa = new Map<Id,Programacion_cita__mdt>();
		if(setIdentificadorCIA != null && !setIdentificadorCIA.isEmpty() && setIdentificadorCIA != null && !setIdentificadorCIA.isEmpty()){
			for(List<Programacion_cita__mdt> lista : [SELECT PRC_TXT_Identificador_CIA__c,PRC_TXT_Segmentacion__c,PRC_CAS_Capital_Provincia__c,PRC_NUM_Plazo__c FROM Programacion_cita__mdt WHERE PRC_TXT_Identificador_CIA__c IN :setIdentificadorCIA AND PRC_TXT_Segmentacion__c IN :setSegmentacion AND PRC_NUM_Plazo__c != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve la programación de citas filtrando por los identificadores y gremios.
	 *
	 * @param setIdentificadorCIA: conjunto de identificadores de la programación de citas
	 * @param gremioFiltro: filtro LIKE para los gremios
	 *
	 * @return mapa que contiene la programación de citas encontradas
	 */
	public static Map<Id,Programacion_cita__mdt> queryProgramacionCitaByIdCIAAndLikeGremio(Set<String> setIdentificadorCIA, String gremioFiltro){
		Map<Id,Programacion_cita__mdt> mapa = new Map<Id,Programacion_cita__mdt>();
		if(setIdentificadorCIA != null && !setIdentificadorCIA.isEmpty() && gremioFiltro != null){
			for(List<Programacion_cita__mdt> lista : [SELECT PRC_TXT_Identificador_CIA__c,PRC_TXT_Segmentacion__c,PRC_CAS_Capital_Provincia__c,PRC_NUM_Plazo__c FROM Programacion_cita__mdt WHERE PRC_TXT_Identificador_CIA__c IN :setIdentificadorCIA AND PRC_TXT_Gremios__c LIKE :gremioFiltro]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve la programación de citas en base al identificador y a un filtro de gremios.
	 *
	 * @param identificador: identificador de la programación de citas
	 * @param gremioFiltro: subcadena buscada en el gremio en formato filtro de operador 'LIKE'
	 * @return lista de programación de citas encontradas
	 */
	public static List<Programacion_cita__mdt> queryProgramacionCita(String identificador,String gremioFiltro){
		List<Programacion_cita__mdt> registros = new List<Programacion_cita__mdt>();
		registros = [SELECT	PRC_TXT_Identificador_CIA__c,
							PRC_TXT_Segmentacion__c,
							PRC_CAS_Capital_Provincia__c,
							PRC_NUM_Plazo__c
					 FROM Programacion_cita__mdt
					 WHERE PRC_TXT_Identificador_CIA__c = :identificador
					 AND PRC_TXT_Gremios__c LIKE :gremioFiltro];
		return registros;
	}

	/**
	 * Devuelve la configuración VDN en base al DeveloperName o al VDN_Number.
	 *
	 * @param devName: DeveloperName de la configuración VDN a buscar
	 * @param VDNNum: VDN_Number de la configuración VDN a buscar
	 *
	 * @return lista de configuraciones VDN encontradas
	 */
	 //METODO QUE NO SE USA
	/*public static List<Configuracion_VDN__mdt> queryConfiguracionVDN(String devName,String VDNNum){
		List<Configuracion_VDN__mdt> registros = new List<Configuracion_VDN__mdt>();
		if(devName != null || VDNNum != null){
			String sentencia = 'SELECT Id,';
			sentencia += ' DeveloperName,';
			sentencia += ' VDN_Number__c,';
			sentencia += ' Distancia_prioridad__c,';
			sentencia += ' LoadId__c,';
			sentencia += ' ServiceId__c';
			sentencia += ' FROM Configuracion_VDN__mdt';
			sentencia += ' WHERE ';
			if(devName != null){
				sentencia += 'DeveloperName = \''+devName+'\'';
			}
			else{
				sentencia += 'VDN_Number__c = \''+VDNNum+'\'';
			}
			system.debug('>>>>>>>>>>>>>>>>>>Util_Metadatos.queryConfiguracionVDN.sentencia: ' + sentencia);
			registros = database.query(sentencia);
		}
		return registros;
	}*/


	public static Map<String, Relacion_Campos__mdt> queryRelacionCamposByIdentificador(Set<String> setIdentificadores) {
		Map<String, Relacion_Campos__mdt> mapRelacionCampos=new Map<String, Relacion_Campos__mdt>();
		if(!setIdentificadores.isEmpty()) {
			for(List<Relacion_Campos__mdt> listRelacionCampos:[SELECT Campos__c, Longitudes__c FROM Relacion_Campos__mdt WHERE Identificador__c IN : setIdentificadores]) {
				mapRelacionCampos.putAll(listRelacionCampos);
			}
		}
		return mapRelacionCampos;
	}
	
	/**
	* Devuelve un mapa de Id y Cambios_a_Cita_Manual_Motor__mdt según un DeveloperName
	*
	* @param setName: campo DeveloperName
	*
	* @return mapa que contiene los Cambios_a_Cita_Manual_Motor__mdt
	*/
	public static Map<Id,Cambios_a_Cita_Manual_Motor__mdt> getCitMan (set<String> setName){
	    Map<Id,Cambios_a_Cita_Manual_Motor__mdt> mapa = new Map<Id,Cambios_a_Cita_Manual_Motor__mdt>();
	    if(setName != null && !setName.isEmpty()){
	        for(List<Cambios_a_Cita_Manual_Motor__mdt> lista:[SELECT CCM_DEC_Tiempo__c FROM Cambios_a_Cita_Manual_Motor__mdt WHERE DeveloperName IN : setName LIMIT 1]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}
	
	/**
	* Devuelve un mapa de Id y Cambios_a_Cita_Manual_Motor__mdt según un cp, franja horaria, gremio, cia, suceso y urgencia
	*
	* @param setCP: set de codigoPostal
	* @param setGremio: Gremio
	* @param setCia: CIA
	* @param setSuceso: suceso
	* @param urgencia: urgencia
	*
	* @return mapa que contiene los Cambios_a_Cita_Manual_Motor__mdt
	*/
	public static Map<Id,Cambios_a_Cita_Manual_Motor__mdt> getCitManExt (set<String> setCP,set<String> setGremio,set<String> setCia,set<String> setSuceso,Boolean urgencia){
	    Map<Id,Cambios_a_Cita_Manual_Motor__mdt> mapa = new Map<Id,Cambios_a_Cita_Manual_Motor__mdt>();
	    if(setCP != null && !setCP.isEmpty() && setGremio != null && !setGremio.isEmpty() && setCia != null && !setCia.isEmpty() && setSuceso != null && !setSuceso.isEmpty() && urgencia != null){
	        for(List<Cambios_a_Cita_Manual_Motor__mdt> lista:[SELECT CCM_TXT_CP__c, CCM_SEL_Franja_Horaria__c, CCM_TXT_Gremio__c, 
																	 CCM_TXT_Identificador_CIA__c, CCM_TXT_Suceso__c, CCM_DEC_Tiempo__c,
																	 CCM_CAS_Urgencia__c
															  FROM Cambios_a_Cita_Manual_Motor__mdt
															  WHERE CCM_TXT_CP__c =: setCP AND
															  		CCM_TXT_Gremio__c =: setGremio AND
															  		CCM_TXT_Identificador_CIA__c  =: setCia AND
															  		CCM_TXT_Suceso__c  =: setSuceso AND
															  		CCM_CAS_Urgencia__c =: urgencia]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}
	
	/**
	 * Devuelve los metadatos de Borrado Periódico filtrados por activo/no activo.
	 * @param estaActivo: booleano true si está activo, false en otro caso
	 *
	 * @return mapa que contiene la Metadata de Borrado Periódico encontrados
	 */
	public static Map<Id,Borrado_Periodico__mdt> getBorradoPeriodicoMetadataByActivo(Boolean estaActivo){
		Map<Id,Borrado_Periodico__mdt> mapa = new Map<Id,Borrado_Periodico__mdt>();
		if(estaActivo != null){
			for(List<Borrado_Periodico__mdt> lista:[SELECT Query__c,Dias_desde_creacion__c FROM Borrado_Periodico__mdt WHERE Activo__c = :estaActivo]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}