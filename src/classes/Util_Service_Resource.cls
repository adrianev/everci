/**
 * Clase de funciones auxiliares relativas a Recurso de Servicio.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Service_Resource {

	/**
	 * Devuelve los recursos asignados por cita
	 * 
	 * @param setIdCitas: conjuntos de ID de citas
	 *
	 * @return mapa con los recursos asignados devueltos por la query
	 */
	public static Map<Id,AssignedResource> getMapAssignedResourcesByCita(Set<Id> setIdCitas){
		Map<Id,AssignedResource> mapa = new Map<Id,AssignedResource>();
		if(setIdCitas != null && !setIdCitas.isEmpty()){
			mapa = new Map<Id,AssignedResource>(
				[SELECT ServiceAppointmentId,
						ServiceResourceId,
						ServiceResource.RSE_CAS_Asignacion_Directa__c
				 FROM AssignedResource 
				 WHERE ServiceAppointmentId IN :setIdCitas]);
		}
		return mapa;
	}


	/**
	 * Devuelve los Service Resource cuyo RelatedRecord nno sea nulo y filtrando por los IDs .
	 *
	 * @param setIdsProfesionales: conjunto de IDs de Service Resource
	 *
	 * @return mapa que contiene los Service Resource encontrados
	 */
	public static Map<Id,ServiceResource> getSRByIdAndRelatedRecordNotNull(Set<Id> setIdsProfesionales){
		Map<Id,ServiceResource> mapa = new Map<Id,ServiceResource>();
		if(setIdsProfesionales != null && !setIdsProfesionales.isEmpty()){
			for(List<ServiceResource> lista:[SELECT RelatedRecordId,Id,
												RSE_LKP_Cuenta__c,
												 RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c,
												 RSE_LKP_Cuenta__r.CUE_SEL_Tipo_de_red__c ,
												 RSE_LKP_Cuenta__r.CUE_CAS_Confianza_en_la_red__c
												FROM ServiceResource
												WHERE  Id IN :setIdsProfesionales
												AND RelatedRecordId != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los ResourceAbsence filtrados por los ResourceId, RecordType y la fecha Start.
	 *
	 * @param setTodosProfesionalesNUEVAS: conjunto de todos los profesionales nuevos
	 * @param setAusenciaRecordTypeId: conjunto de RecordTypeId's
	 * @param dateStartIni: fecha Start inicial
	 * @param dateStartFin: fecha Start final
	 *
	 * @return mapa que contiene los ResourceAbsence encontrados
	 */
	public static Map<Id,ResourceAbsence> getResourceAbsenceByResourceAndRecordTypeAndStartDate(Set<Id> setTodosProfesionalesNUEVAS, Set<Id> setAusenciaRecordTypeId, Datetime dateStartIni, Datetime dateStartFin){
		Map<Id,ResourceAbsence> mapa = new Map<Id,ResourceAbsence>();
		if(setTodosProfesionalesNUEVAS != null && !setTodosProfesionalesNUEVAS.isEmpty() && setAusenciaRecordTypeId != null && !setAusenciaRecordTypeId.isEmpty() && dateStartIni != null && dateStartFin != null){
			for(List<ResourceAbsence> lista:[SELECT ResourceId,Start,RecordTypeId FROM ResourceAbsence WHERE ResourceId IN :setTodosProfesionalesNUEVAS AND RecordTypeId IN :setAusenciaRecordTypeId AND Start >= :dateStartIni AND Start <= :dateStartFin]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}


	public static Map<Id,ResourceAbsence> getResourceAbsenceByIdAndType(Set<Id> setId){
		Map<Id,ResourceAbsence> mapa = new Map<Id,ResourceAbsence>();
		if(setId != null && !setId.isEmpty()){
			for(List<ResourceAbsence> lista:[SELECT ResourceId
        				 FROM ResourceAbsence
        				 WHERE ResourceId in :setId
        				 AND Type =: Label.ABS_Tipo_Festivo_LocalProvincial]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve las OperatingHours filtrando por los nombres.
	 *
	 * @param setName: conjunto de Names
	 *
	 * @return mapa que contiene las OperatingHours encontradas
	 */
	public static Map<Id,OperatingHours> getOperatingHoursByName(Set<String> setName){
		Map<Id,OperatingHours> mapa = new Map<Id,OperatingHours>();
		if(setName != null && !setName.isEmpty()){
			for(List<OperatingHours> lista:[SELECT Id,Name,(SELECT EndTime,StartTime,Type,DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE Name IN :setName]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Método privado para construir el cuerpo SELECT <campos> FROM Guardia__c.
	 *
	 * @return String con el cuerpo 'SELECT <campos> FROM Guardia__c'
	 */
	/*private static String getSelectFieldsFromGuardia(){
		String sql = 'SELECT Id,';
		sql += 'GUA_DAT_Fecha_Inicio__c,';
		sql += 'GUA_DAT_Fecha_Fin__c,';
		sql += 'GUA_LKP_Profesional__c,';
		sql += 'GUA_LKP_Territorio__c';
		sql += ' FROM Guardia__c';
		return sql;
	}*/

	/**
	 * Devuelve las Guardias filtrando por los Profesionales y la fecha de fin.
	 *
	 * @param setProfesional: conjunto de IDs de Profesionales
	 * @param fechaFin: fecha de fin
	 *
	 * @return mapa que contiene las Guardias encontradas
	 */
	public static Map<Id,Guardia__c> getGuardiaByProfesionalAndFechaFin(Set<Id> setProfesional, Date fechaFin){
		Map<Id,Guardia__c> mapa = new Map<Id,Guardia__c>();
		if(setProfesional != null && !setProfesional.isEmpty() && fechaFin != null){
			for(List<Guardia__c> lista:[SELECT GUA_LKP_Territorio__c,GUA_LKP_Profesional__c,GUA_DAT_Fecha_Inicio__c,GUA_DAT_Fecha_Fin__c
										FROM Guardia__c
										WHERE GUA_DAT_Fecha_Fin__c >= :fechaFin AND GUA_LKP_Profesional__c IN :setProfesional]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las Guardias filtrando por los Profesionales, los Territorios, la fecha máxima de inicio y la fecha mínima de fin.
	 *
	 * @param setProfesional: conjunto de IDs de Profesionales
	 * @param setTerritorio: conjunto de IDs de Territorios
	 * @param maxFechaInicio: máxima fecha de inicio
	 * @param minFechaFin: mínima fecha de fin
	 *
	 * @return mapa que contiene las Guardias encontradas
	 */
	public static Map<Id,Guardia__c> getGuardiaByProfesionalAndTerritorioAndMaxFechaInicioAndMinFechaFin(Set<Id> setProfesional, Set<Id> setTerritorio, Date maxFechaInicio, Date minFechaFin){
		Map<Id,Guardia__c> mapa = new Map<Id,Guardia__c>();
		if(setProfesional != null && !setProfesional.isEmpty() && setTerritorio != null && !setTerritorio.isEmpty() && maxFechaInicio != null && minFechaFin != null){
			for(List<Guardia__c> lista:[SELECT Id,GUA_DAT_Fecha_Inicio__c,GUA_DAT_Fecha_Fin__c,GUA_LKP_Profesional__c,GUA_LKP_Territorio__c
										FROM Guardia__c
										WHERE GUA_LKP_Profesional__c  IN :setProfesional
										AND GUA_DAT_Fecha_Inicio__c <= :maxFechaInicio
										AND GUA_DAT_Fecha_Fin__c >= :minFechaFin
										AND GUA_LKP_Territorio__c IN :setTerritorio]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las guardias dados unos conjuntos de IDs de profesionales y territorios, cuya fecha de inicio sea menor que la indicada y cuya fecha de fin sea mayor que la indicada.
	 *
	 * @param setIdProfesional: conjunto de IDs de profesionales
	 * @param setIdTerritorio: conjunto de IDs de territorios
	 * @param fechaInicio: fecha de inicio
	 * @param fechaFin: fecha de fin
	 *
	 * return mapa que contiene las guardias encontradas
	 */
	/*public static Map<Id,Guardia__c> queryMapGuardias(Set<Id> setIdProfesional, Set<Id> setIdTerritorio, Date fechaInicio, Date fechaFin){
		Map<Id,Guardia__c> mapa = new Map<Id,Guardia__c>();
		if(setIdProfesional != null && !setIdProfesional.isEmpty() && setIdTerritorio != null && !setIdTerritorio.isEmpty() && fechaInicio != null && fechaFin != null){
			String sql = getSelectFieldsFromGuardia()+' WHERE';
			sql += ' GUA_LKP_Profesional__c IN :setIdProfesional';
			sql += ' AND GUA_LKP_Territorio__c IN :setIdTerritorio';
			sql += ' AND GUA_DAT_Fecha_Inicio__c <= :fechaInicio';
			sql += ' AND GUA_DAT_Fecha_Fin__c >= :fechaFin';
			system.debug('>>>> Util_Guardia.queryMapGuardias.sql: '+sql);
			for(List<Guardia__c> lista : database.query(sql)){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}*/

	/**
	 * Devuelve las guardias dados un conjunto de IDs de profesionales, cuya fecha de fin sea mayor que la indicada.
	 *
	 * @param setIdProfesional: conjunto de IDs de profesionales
	 * @param fechaFin: fecha de fin
	 *
	 * return mapa que contiene las guardias encontradas
	 */
	/*public static Map<Id,Guardia__c> queryMapGuardias(Set<Id> setIdProfesional, Date fechaFin){
		Map<Id,Guardia__c> mapa = new Map<Id,Guardia__c>();
		if(setIdProfesional != null && !setIdProfesional.isEmpty() && fechaFin != null){
			String sql = getSelectFieldsFromGuardia()+' WHERE';
			sql += ' GUA_LKP_Profesional__c IN :setIdProfesional';
			sql += ' AND GUA_DAT_Fecha_Fin__c >= :fechaFin';
			system.debug('>>>> Util_Guardia.queryMapGuardias.sql: '+sql);
			for(List<Guardia__c> lista : database.query(sql)){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}*/

	/**
	 * Método que devuelve los recursos de servicio filtrados por un where.
	 *
	 * @param filtroWhere: filtro where de la sentencia sql
	 * @return mapa con los recursos de servicio devueltos por la query
	 */
	public static Map<Id,ServiceResource> queryMapSR(String filtroWhere){
		Map<Id,ServiceResource> mapa = new Map<Id,ServiceResource>();
		if(filtroWhere != null){
			String sentencia = 'SELECT Id,';
			sentencia += ' Name,';
			sentencia += ' IsActive,';
			sentencia += ' RelatedRecordId,';
			sentencia += ' RSE_TXT_Codigo_Recurso__c,';
			sentencia += ' RSE_CAS_Asignacion_Directa__c,';
			sentencia += ' RSE_LKP_Cuenta__c,';
			sentencia += ' RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c,';
			sentencia += ' RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c,';
			sentencia += ' RSE_FOR_Categoria_del_profesional__c,';
			sentencia += ' RSE_DAT_Fecha_Baja__c,';
			sentencia += ' RSE_DAT_Fecha_BajaTemp_Venc__c,';
			sentencia += ' RSE_DAT_Fecha_activacion__c';
			sentencia += ' FROM ServiceResource';
			String sentencia_where = ' WHERE ';
			sentencia_where += filtroWhere;
			sentencia += sentencia_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Documentacion.queryMapSR.sentencia: '+sentencia);
			for(List<ServiceResource> lista: database.query(sentencia)){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Método que devuelve los recursos de servicio filtrados por la oorden de trabajo de la cita.
	 *
	 * @param WoId: filtro where de la sentencia sql
	 * @return mapa con los recursos de servicio devueltos por la query
	*/
	public static Map<Id,ServiceResource> queryMapSRByWoIds(Set<ID> woIds){
		Map<Id,ServiceResource> mapa = new Map<Id,ServiceResource>();
		if(!woIds.isEmpty()){
			for(List<ServiceResource> listaServicioAux :[SELECT Id,
													       Name,
													       IsActive,
													       RelatedRecordId,
													       RSE_TXT_Codigo_Recurso__c,
													       RSE_CAS_Asignacion_Directa__c,
													       RSE_LKP_Cuenta__c,
													       RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c,
													       RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c,
													       RSE_FOR_Categoria_del_profesional__c,
													       RSE_DAT_Fecha_Baja__c,
													       RSE_DAT_Fecha_BajaTemp_Venc__c,
													       RSE_DAT_Fecha_activacion__c
													       FROM ServiceResource
													       WHERE 
													       Id IN (SELECT ServiceResourceId FROM AssignedResource WHERE ServiceAppointment.ParentRecordId IN :woIds)]) {
				mapa.putAll(listaServicioAux);
			}
		}
		return mapa;
	}

	/**
	 * Crea un mapa de Recursos de Servicio a partir de un Set de Ids
	 * 
	 * @param rsIds IDs de recursos a buscar
	 * @return mapa de Rescursos de Servicio
	 */
	public static Map<Id,ServiceResource> queryMapSRByRsIds(Set<ID> rsIds){
		Map<Id,ServiceResource> mapa = new Map<Id,ServiceResource>();
		if(!rsIds.isEmpty()){
			for(List<ServiceResource> listaServicioAux :[SELECT Id,
													       Name,
													       IsActive,
													       RelatedRecordId,
													       RSE_TXT_Codigo_Recurso__c,
													       RSE_CAS_Asignacion_Directa__c,
													       RSE_LKP_Cuenta__c,
													       RSE_LKP_Cuenta__r.CUE_SEL_Bloqueo_Eventos__c,
														   RSE_LKP_Cuenta__r.CUE_CAS_Confianza_en_la_red__c,
														   RSE_LKP_Cuenta__r.CUE_TXT_Aviso_Auditoria__c,	
														   RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c,
														   RSE_LKP_Cuenta__r.CUE_SEL_Eventos_bloqueados_Proc__c,       
														   RSE_LKP_Cuenta__r.CUE_SEL_Tipo_de_red__c,       
													       RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c,
													       RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c,
													       RSE_FOR_Categoria_del_profesional__c,
													       RSE_DAT_Fecha_Baja__c,
													       RSE_DAT_Fecha_BajaTemp_Venc__c,
													       RSE_DAT_Fecha_activacion__c,
													       RSE_LKP_Cuenta__r.CUE_LKP_contacto_principal__r.Id,
													       RSE_SEL_Tipo_Documento__c
													       FROM ServiceResource
													       WHERE 
													       Id IN :rsIds]) {
				mapa.putAll(listaServicioAux);
			}
		}
		return mapa;
	}
	/**
	 * Método que devuelve los recursos de servicio filtrados por un where.
	 *
	 * @param filtroWhere: filtro where de la sentencia sql
	 * @return lista de recursos de servicio devueltos por la query
	 */
	/*public static List<ServiceResource> querySR(String filtroWhere){
		List<ServiceResource> recursos = new List<ServiceResource>();
		if(filtroWhere != null){
			String sentenciaOT = 'SELECT Id,';
			sentenciaOT += ' Name,';
			sentenciaOT += ' IsActive,';
			sentenciaOT += ' RelatedRecordId,';
			sentenciaOT += ' RSE_TXT_Codigo_Recurso__c,';
			sentenciaOT += ' RSE_CAS_Asignacion_Directa__c,';
			sentenciaOT += ' RSE_LKP_Cuenta__c,';
			sentenciaOT += ' RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c,';
			sentenciaOT += ' RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c,';
			sentenciaOT += ' RSE_FOR_Categoria_del_profesional__c,';
			sentenciaOT += ' RSE_DAT_Fecha_Baja__c,';
			sentenciaOT += ' RSE_DAT_Fecha_BajaTemp_Venc__c,';
			sentenciaOT += ' RSE_DAT_Fecha_activacion__c';
			sentenciaOT += ' FROM ServiceResource';
			String sentenciaOT_where = ' WHERE ';
			sentenciaOT_where += filtroWhere;
			sentenciaOT += sentenciaOT_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Documentacion.querySR.sentenciaOT: ' + sentenciaOT);
			recursos = database.query(sentenciaOT);
		}
		return recursos;
	}*/
	
	/**
	* Método que devuelve los profesionales activos
	*
	* @param estaActivo: booleano true si está activo, false en otro caso
	*
	* @return mapaActivos que contiene los profesionales activos
	*/
	public static Map<Id,ServiceResource> getProfAct(Boolean estaActivo){
	    Map<Id,ServiceResource> mapaActivos = new Map<Id,ServiceResource>();
	    if(estaActivo != null){
	        for(List<ServiceResource> lista:[SELECT Id, RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c FROM ServiceResource WHERE IsActive = :estaActivo]){
	            mapaActivos.putAll(lista);
	        }  	
	    }               
	    return mapaActivos;
	}
	
	/**
	 * Crea un mapa de Profesionales Contrato a partir de un Set de Ids
	 * 
	 * @param setIdProfesionales IDs de cuentas a buscar
	 * @return mapaProfesionales mapa de ProfesionalesContrato
	 */
	public static Map<Id, Account> queryMapProfesionales(Set<Id> setIdProfesionales){
		Map<Id, Account> mapaProfesionales = new Map<Id, Account>();
		if(setIdProfesionales != null && !setIdProfesionales.isEmpty()){
			for(List<Account> listaProfesionales : [SELECT Id,
															Name,
															CUE_CAS_Activado__c,
															CUE_CAS_Dada_de_Baja__c,
															CUE_DAT_Fecha_de_Activacion__c,
															CUE_DAT_Fecha_BajaTemp_Venc__c,
															CUE_TXT_Identificador__c,
															CUE_TXT_Observaciones_BajaTemp__c,
															CUE_SEL_Estado__c,
															CUE_SEL_Tipo_de_Profesional__c,
															CUE_SEL_Motivo_Baja_Temp__c,
															CUE_LKP_contacto_principal__c
													FROM Account
													WHERE Id IN :setIdProfesionales
													AND CUE_FOR_RTDevName__c = :Label.RT_CUE_PROFESIONAL_CONTRATO]){
				mapaProfesionales.putAll(listaProfesionales);
			}
		}
		return mapaProfesionales;
	}
	
	/**
	 * Crea un mapa de Recursos de Servicio a partir de un Set de Ids de Profesionales
	 * 
	 * @param setCuentas IDs de cuentas
	 * @return mapaSR de Rescursos de Servicio
	 */
	public static Map<Id,ServiceResource> queryMapRecursosServicio(Set<ID> setCuentas){
		Map<Id,ServiceResource> mapaSR = new Map<Id,ServiceResource>();
		if(!setCuentas.isEmpty()){
			for(List<ServiceResource> listaSR :[SELECT Id,
												       Name,
												       IsActive,
												       RelatedRecordId,
												       RSE_LKP_Cuenta__c
												       FROM ServiceResource
												       WHERE RSE_LKP_Cuenta__c IN :setCuentas]) {
				mapaSR.putAll(listaSR);
			}
		}
		return mapaSR;
	}
	
	/**
	 * Crea un mapa relacionando cada Id de cuenta (Profesional Contrato) con una lista de Recursos de Servicios vinculados
	 * 
	 * @param setIdCuentas Set de Ids de Cuentas
	 * @return mapaRecursosServicio mapa de Recursos de Servicio
	 */
	public static Map<Id, List<ServiceResource>> getMapaRecursosServicio(Set<Id> setIdCuentas){
		Map <Id, List<ServiceResource>> mapaRetorno = new Map<Id, List<ServiceResource>>();
		List<ServiceResource> listaAux;
		if(setIdCuentas != null && !setIdCuentas.isEmpty()){
			List<ServiceResource> listaRecursos = new List<ServiceResource>(
					[SELECT Id,IsActive,RSE_DAT_Fecha_Baja__c,RSE_DAT_Fecha_BajaTemp_Venc__c,RSE_DAT_Fecha_activacion__c,RSE_SEL_Tipo_de_red__c,RSE_LKP_Cuenta__c,RSE_SEL_Gremio__c,RelatedRecordId
					 FROM ServiceResource WHERE RSE_LKP_Cuenta__c IN :setIdCuentas]);
			for(ServiceResource recurso : listaRecursos){
				if(mapaRetorno.get(recurso.RSE_LKP_Cuenta__c)==null){
					listaAux = new List<ServiceResource>();
					listaAux.add(recurso);
					mapaRetorno.put(recurso.RSE_LKP_Cuenta__c,listaAux);
				}
				else {
					mapaRetorno.get(recurso.RSE_LKP_Cuenta__c).add(recurso);
				}
			}
		}
		return mapaRetorno;
	}
			
	/**
	 * Crea un mapa de Usuarios a partir de un Set de Ids
	 * 
	 * @param setIdUsuarios IDs de usuarios a buscar
	 * @return mapaUsuarios mapa de Usuarios
	 */
	/*public static Map<Id, User> queryMapUsuarios(Set<Id> setIdUsuarios){
		Map<Id, User> mapaUsuarios = new Map<Id, User>();
		if(setIdUsuarios != null && !setIdUsuarios.isEmpty()){
			for(List<User> listaUsuarios : [SELECT Id,
													Name,
													IsActive,
													USR_SEL_Motivo_de_desactivacion__c
											FROM User
											WHERE Id IN :setIdUsuarios]){
				mapaUsuarios.putAll(listaUsuarios);
			}
		}
		return mapaUsuarios;
	}*/

	/**
	 * Devuelve los documentos profesionales filtrados por los profesionales de contrato.
	 *
	 * @param setIdCuentas: conjunto de IDs de profesionales de contrato
	 *
	 * @return mapa que contiene los documentos profesionales encontrados
	 */
	public static Map<Id,Documentos_Profesionales_Contrato__c> getDocProfesionalByProfContrato(Set<Id> setIdProfContrato){
		Map<Id,Documentos_Profesionales_Contrato__c> mapa = new Map<Id,Documentos_Profesionales_Contrato__c>();
		if(setIdProfContrato != null && !setIdProfContrato.isEmpty()){
			for(List<Documentos_Profesionales_Contrato__c> lista:[SELECT Id,DPC_LKP_Profesional_Contrato__c,DPC_LKP_Tipo_de_Documento__c,DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c,DPC_LKP_Tipo_de_Documento__r.DOC_SEL_Gremio__c, DPC_LKP_Tipo_de_Documento__r.DOC_NUM_Dias_para_Baja__c,DPC_DAT_Fecha_Entrega__c,DPC_DAT_Fecha_Expiracion__c
																	FROM Documentos_Profesionales_Contrato__c
																	WHERE DPC_LKP_Profesional_Contrato__c IN :setIdProfContrato]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve los documentos profesionales a partir del profesional y el tipo de documento.
	 *
	 * @param setIdProfesionales: conjunto de IDs de profesionales
	 * @param setIdTipoDocumento: conjunto de IDs de tipos de documento
	 *
	 * @return mapa que contiene los documentos profesionales encontrados
	 */
	public static Map<Id,Documentos_Profesionales_Contrato__c> getDocProfesionalByProfesionalAndTipoDocumento(Set<Id> setIdProfesionales, Set<Id> setIdTipoDocumento){
		Map<Id,Documentos_Profesionales_Contrato__c> mapa = new Map<Id,Documentos_Profesionales_Contrato__c>();
		if(setIdProfesionales != null && !setIdProfesionales.isEmpty() && setIdTipoDocumento != null && !setIdTipoDocumento.isEmpty()){
			for(List<Documentos_Profesionales_Contrato__c> lista:[SELECT Id,DPC_TXT_Identificador__c,DPC_LKP_Profesional_Contrato__c,DPC_LKP_Profesional_Contrato__r.Name,DPC_LKP_Tipo_de_Documento__c,DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c
																	FROM Documentos_Profesionales_Contrato__c
																	WHERE DPC_LKP_Profesional_Contrato__c IN :setIdProfesionales
																	AND DPC_LKP_Tipo_de_Documento__c IN :setIdTipoDocumento]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Crea un mapa relacionando cada Id de cuenta (Profesional Contrato) con una lista de Documentos de Profesional Contrato vinculados
	 * 
	 * @param setIdCuentas Set de Ids de Cuentas
	 * @return mapaDocumentosPR mapa de Documentos de Profesional Contrato
	 */
	public static Map<Id, List<Documentos_Profesionales_Contrato__c>> getMapaDocumentosPR(Set<Id> setIdCuentas){
		Map <Id, List<Documentos_Profesionales_Contrato__c>> mapaDocumentosPR = new Map<Id, List<Documentos_Profesionales_Contrato__c>>();
		List<Documentos_Profesionales_Contrato__c> listaAux;
		if(setIdCuentas != null && !setIdCuentas.isEmpty()){
			List<Documentos_Profesionales_Contrato__c> listaDocumentosPR = getDocProfesionalByProfContrato(setIdCuentas).values();
			/*List<Documentos_Profesionales_Contrato__c> listaDocumentosPR = new List<Documentos_Profesionales_Contrato__c>(
					[SELECT Id,DPC_LKP_Profesional_Contrato__c,DPC_LKP_Tipo_de_Documento__c,DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c,DPC_LKP_Tipo_de_Documento__r.DOC_SEL_Gremio__c, DPC_LKP_Tipo_de_Documento__r.DOC_NUM_Dias_para_Baja__c,DPC_DAT_Fecha_Entrega__c,DPC_DAT_Fecha_Expiracion__c
					 FROM Documentos_Profesionales_Contrato__c WHERE DPC_LKP_Profesional_Contrato__c IN :setIdCuentas]);*/
			for(Documentos_Profesionales_Contrato__c documento : listaDocumentosPR){
				if(mapaDocumentosPR.get(documento.DPC_LKP_Profesional_Contrato__c)==null){
					listaAux = new List<Documentos_Profesionales_Contrato__c>();
					listaAux.add(documento);
					mapaDocumentosPR.put(documento.DPC_LKP_Profesional_Contrato__c,listaAux);
				}
				else {
					mapaDocumentosPR.get(documento.DPC_LKP_Profesional_Contrato__c).add(documento);
				}
			}
		}
		return mapaDocumentosPR;
	}
		
	/**
	 * Crea un mapa de Documentos a partir de un Set de Ids
	 * 
	 * @param setIdDocumentos IDs de documentos a buscar
	 * @return mapaDocumentos mapa de Documentos
	 */
	public static Map<Id, Tipo_de_documento__c> queryMapDocumentos(Set<Id> setIdDocumentos){
		Map<Id, Tipo_de_documento__c> mapaDocumentos = new Map<Id, Tipo_de_documento__c>();
		if(setIdDocumentos != null && !setIdDocumentos.isEmpty()){
			for(List<Tipo_de_documento__c> listaDocumentos : [SELECT Id,
															Name,
															DOC_NUM_Dias_para_Baja__c,
															DOC_SEL_Gremio__c,
															DOC_SEL_Tipo_de_Profesional__c,
															DOC_CAS_Validez__c,
															DOC_CAS_Estado_Documento__c,
															DOC_DAT_Fecha_Inicio_Vigencia__c,
															DOC_TXT_Identificador__c,
															DOC_TXT_Texto_Email__c
													FROM Tipo_de_documento__c
													WHERE Id IN :setIdDocumentos]){
				mapaDocumentos.putAll(listaDocumentos);
			}
		}
		return mapaDocumentos;
	}
	
	/**
	 * Crea un mapa relacionando cada tipo de Profesional Contrato con los tipos de Documentos que requiere
	 * 
	 * @param setTiposProfesional Set de String de los tipos de Profesional
	 * @return mapaDocumentosTipoProf mapa de Documentos 
	 */
	public static Map<String, List<Tipo_de_documento__c>> getMapaDocumentosPorTipoProfesional(Set<String> setTiposProfesional){
		List<String> tiposProfesional=new List<String>();
		tiposProfesional.addAll(setTiposProfesional);
		Map <String, List<Tipo_de_documento__c>> mapaDocumentosTipoProf = new Map<String, List<Tipo_de_documento__c>>();
		List<Tipo_de_documento__c> listaAux;
		if(tiposProfesional != null && !tiposProfesional.isEmpty()){
			List<Tipo_de_documento__c> listaDocumentos = new List<Tipo_de_documento__c>();
			String sentenciaDoc = 'SELECT Id, Name, DOC_NUM_Dias_para_Baja__c, DOC_SEL_Gremio__c, DOC_SEL_Tipo_de_Profesional__c, DOC_CAS_Validez__c, DOC_TXT_Identificador__c FROM Tipo_de_Documento__c';
			sentenciaDoc += ' WHERE DOC_CAS_Estado_Documento__c = true AND DOC_DAT_Fecha_Inicio_Vigencia__c <= TODAY AND DOC_SEL_Tipo_de_Profesional__c INCLUDES (';
			for(String tipo : tiposProfesional){
				if(tipo != tiposProfesional.get(0)){
					sentenciaDoc += ',';
				}
				sentenciaDoc += '\'';
				sentenciaDoc += tipo;
				sentenciaDoc += '\'';
			}
			sentenciaDoc += ')';
			listaDocumentos = database.query(sentenciaDoc);
			for(Tipo_de_documento__c tipoDocumento : listaDocumentos){
				List<String> profesionales = tipoDocumento.DOC_SEL_Tipo_de_Profesional__c.split(';');
				for(String tipo: tiposProfesional){
					if(profesionales.contains(tipo)){
						if(mapaDocumentosTipoProf.get(tipo) == null){
							listaAux = new List<Tipo_de_documento__c>();
							listaAux.add(tipoDocumento);
							mapaDocumentosTipoProf.put(tipo,listaAux);
						}
						else {
							mapaDocumentosTipoProf.get(tipo).add(tipoDocumento);
						}
					}
				}
			}
		}
		return mapaDocumentosTipoProf;
	}
	
	/**
	 * Devuelve los recursos de servicio filtrados por el campo RelatedRecordId.
	 *
	 * @param setRelatedRecordId: conjunto de IDs de RelatedRecord
	 *
	 * @return mapa con los recursos de servicio devueltos por la query
	 */
	public static Map<Id,ServiceResource> getMapaRecursoRelatedId(Set<Id> setRelatedRecordId){
		Map<Id,ServiceResource> mapa = new Map<Id,ServiceResource>();
		if(setRelatedRecordId != null && !setRelatedRecordId.isEmpty()){
			for(List<ServiceResource> lista:[SELECT Id,
											       Name,
											       IsActive,
											       RelatedRecordId,
											       RSE_TXT_Codigo_Recurso__c,
											       RSE_CAS_Asignacion_Directa__c,
											       RSE_LKP_Cuenta__c,
											       RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c,
											       RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c,
											       RSE_FOR_Categoria_del_profesional__c,
											       RSE_DAT_Fecha_Baja__c,
											       RSE_DAT_Fecha_BajaTemp_Venc__c,
											       RSE_DAT_Fecha_activacion__c,
											       RSE_FOR_Recurso_Servicio_Principal__c
				FROM ServiceResource
				WHERE RelatedRecordId IN :setRelatedRecordId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve los recursos asignados a las citas de un set de OTs
	 *
	 * @param setIdOTs: conjunto de IDs de OTs
	 *
	 * @return mapa con los recursos asignados devueltos por la query
	 */
	public static Map<Id,AssignedResource> getMapAssignedResourcesByWO(Set<Id> setIdOTs){
		Map<Id,AssignedResource> mapa = new Map<Id,AssignedResource>();
		if(setIdOTs != null && !setIdOTs.isEmpty()){
			for(List<AssignedResource> lista:[SELECT Id,ServiceResourceId,ServiceResource.RelatedRecordId, ServiceAppointment.ParentRecordId
												FROM AssignedResource
												WHERE ServiceAppointment.ParentRecordId IN :setIdOTs]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	
	/**
	 * Devuelve los recursos asignados por Ids de recurso de servicio, status y start and end times
	 * 
	 * @param ServiceResourceIds
	 * @param ServiceResourceIds
	 * @param StartTime
	 * @param SchedStartTime
	 * @param EndTime
	 * @param schedEndTime
	 *
	 * @return mapa con los recursos asignados devueltos por la query
	 */
	public static Map<Id,AssignedResource> getMapAssignedResourcesByServiceResourceIdAndStatusAndFechas(Set<Id> ServiceResourceIds, Set<String> status, DateTime StartTime, DateTime schedStartTime, DateTime EndTime, DateTime schedEndTime  ){
		Map<Id,AssignedResource> mapa = new Map<Id,AssignedResource>();
		if(ServiceResourceIds != null && !ServiceResourceIds.isEmpty() && !status.isEmpty() && StartTime!=null && schedStartTime!=null && EndTime!=null && schedEndTime!=null){
			for(List<AssignedResource> lista:[SELECT ServiceAppointmentId, 
						 		ServiceResourceId,
						 		ServiceAppointment.SchedStartTime,
						 		ServiceAppointment.SchedEndTime 
						 FROM AssignedResource 
						 WHERE ServiceResourceId IN :ServiceResourceIds
						 AND ServiceAppointment.Status IN :status
						 AND ((ServiceAppointment.SchedStartTime >=: StartTime 
						 AND ServiceAppointment.SchedStartTime <=: schedStartTime)
						 OR (ServiceAppointment.SchedEndTime >=: EndTime 
						 AND ServiceAppointment.SchedEndTime <=: schedEndTime))]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
		
	/**
	 * getResourceAbsenceByResourceIdAndRecordTypeAndStartDateAndEndDateTardios Devuelve los ResourceAbsence filtrados por los ResourceId, y la fecha Start and start fin
	 *
	 * @param setResourceIds: conjunto de todos los profesionales nuevos
	 * @param dateStartIni: fecha Start inicial
	 * @param dateStartFin: fecha Start final
	 *
	 * @return mapa que contiene los ResourceAbsence encontrados
	 */
	public static Map<Id,ResourceAbsence> getResourceAbsenceByResourceIdAndRecordTypeAndStartDateAndEndDateTardios(Set<Id> setResourceIds, Datetime dateStartIni, Datetime dateStartFin){
		Map<Id,ResourceAbsence> mapa = new Map<Id,ResourceAbsence>();
		if(setResourceIds != null && !setResourceIds.isEmpty() && dateStartIni != null && dateStartFin != null){
			for(List<ResourceAbsence> lista:[SELECT Start, 
					 		End,
					 		ResourceId 
					 FROM ResourceAbsence 
					 WHERE ResourceId IN :setResourceIds
					 AND ((Start >= :dateStartIni 
					 AND Start <= :dateStartFin) 
					 OR (End >= :dateStartIni
					 AND End <= :dateStartFin))]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los ResourcePreference filtrados por RelatedRecord y tipos de preferencia.
	 *
	 * @param setRelatedRecordId: conjunto de RelatedRecordId's
	 * @param args: conjunto de tipos de preferencia
	 *
	 * @return mapa que contiene los ResourcePreference encontrados
	 */
	public static Map<Id,ResourcePreference> getRPByRelatedRecordAndPreferenceType(Set<Id> setRelatedRecordId, Set<String> setPreferenceType){
		Map<Id,ResourcePreference> mapa = new Map<Id,ResourcePreference>();
		if(setRelatedRecordId != null && !setRelatedRecordId.isEmpty() && setPreferenceType != null && !setPreferenceType.isEmpty()){
			for(List<ResourcePreference> lista:[SELECT id,ServiceResourceId,RelatedRecordId,PreferenceType,ServiceResource.RelatedRecordId
												FROM ResourcePreference
												WHERE RelatedRecordId IN :setRelatedRecordId AND PreferenceType IN :setPreferenceType]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve los ServiceResourceSkill según el id de un profesional y un gremio asociado a s Skill
	 *
	 * @param setIdUsuarioProf: Id de usuario del Profesional
	 * @param setCodigoGremio: Código del Gremio
	 *
	 * @return mapa que contiene los ResourcePreference encontrados
	 */
	public static Map<Id,ServiceResourceSkill> getSRSkillByGremProf(Set<Id> setIdUsuarioProf, Set<String> setCodigoGremio){
		Map<Id,ServiceResourceSkill> mapa = new Map<Id,ServiceResourceSkill>();
		if(setIdUsuarioProf != null && !setIdUsuarioProf.isEmpty() && setCodigoGremio != null && !setCodigoGremio.isEmpty()){
			for(List<ServiceResourceSkill> lista:[SELECT Id
													 FROM ServiceResourceSkill
													 WHERE ServiceResource.RelatedRecordId IN :setIdUsuarioProf
													 AND Skill.DeveloperName IN :setCodigoGremio]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Crea un mapa de Recursos de Servicio a partir de un Set de Ids de ServiceResource
	 * 
	 * @param resId IDs de recursos de Servicio
	 * @return mapaSR de Rescursos de Servicio
	 */
	public static Map<Id,ServiceResource> getServiceResById(Set<Id> resId){
		Map<Id,ServiceResource> mapaSR = new Map<Id,ServiceResource>();
		if(!resId.isEmpty() && resId != null){
			for(List<ServiceResource> listaSR :[SELECT Id,
												RSE_LKP_Cuenta__r.CUE_SEL_Eventos_bloqueados_Proc__c,
												 RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c,
												 RSE_LKP_Cuenta__r.CUE_SEL_Tipo_de_red__c ,
												 RSE_LKP_Cuenta__r.CUE_CAS_Confianza_en_la_red__c,
												RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c,
												RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c,
												RSE_FOR_Categoria_del_profesional__c,
												RSE_LKP_Cuenta__c,
												RSE_LKP_Cuenta__r.CUE_SEL_Bloqueo_Eventos__c,
												RSE_SEL_Gremio__c,
												RelatedRecordId
												FROM ServiceResource
                                                WHERE Id IN :resId]) {
				mapaSR.putAll(listaSR);
			}
		}
		return mapaSR;
	}
	
	/**
	 * Crea un mapa de Profesionales Gremio a partir de un Set de Ids
	 * 
	 * @param setIdProfesionales IDs de cuentas a buscar
	 * @return mapaProfesionalesGremio mapa de Profesionales Gremio
	 */
	public static Map<String, Id> queryMapProfesionalesGremio(Set<Id> setIdProfesionales){
		Map<String,Id> mapProfesionalGremio = new Map<String,Id>();
		if(setIdProfesionales != null && !setIdProfesionales.isEmpty()){
			for(Profesional_Gremio__c listaProfesionalesGremio : [SELECT Id,
																		Name
																		FROM Profesional_Gremio__c
																		WHERE PRG_LKP_Cuenta_Profesional__c IN :setIdProfesionales]){
				mapProfesionalGremio.put(listaProfesionalesGremio.Name, listaProfesionalesGremio.Id);
			}
		}
		return mapProfesionalGremio;
	}
	
	/**
	  * Método para insertar las CIAs como habilidades del Recurso de Servicio en su inserción
	  * 
	  * @param recurso: recursos de servicio al que se le van a insertar las habilidades
	  * @param listaHabilidadesCIAs: lista con las habilidades de las CIAs
	  * @return List<ServiceResourceSkill>: lista de las habilidades de recursos de servicio a insertar
	  */
	public static List<ServiceResourceSkill> anyadirCIAs(ServiceResource recurso, List<Skill> listaHabilidadesCIAs){
		List<ServiceResourceSkill> listaSRS = new List<ServiceResourceSkill>();
		if(trigger.isInsert && recurso.isActive){
			for(Skill habilidadCIA : listaHabilidadesCIAs){
				ServiceResourceSkill srs = new ServiceResourceSkill(ServiceResourceId=recurso.Id,SkillId=habilidadCIA.Id,EffectiveStartDate=Date.newInstance(2015, 1, 1));
				listaSRS.add(srs);
			}
		}
		return listaSRS;
	}
	
	/**
	  * Método para actualizar el número de recursos activos para un determinado profesional_gremio
	  * 
	  * @param actualizarSRActivos: lista de recursos de servicio que han modificado su isActive
	  * @return List<Profesional_Gremio__c>: lista con los profesional_gremio a actualizar el valor del campo PRG_NUM_Recursos_de_Servicio_Activos__c
	  */
	public static List<Profesional_Gremio__c> actualizarRecursosActivos(List<ServiceResource> actualizarSRActivos){
		//Creamos un set con los profesionales_gremio
		Set<Id> profesionalesGremiosId = new Set<Id>();
		for(ServiceResource recurso: actualizarSRActivos){
			profesionalesGremiosId.add(recurso.RSE_LKP_Profesional_Gremio__c);
		}
		//Almacenamos en gremioProfesionalAActualizar los profesional_gremio a actualizar
		List<Profesional_Gremio__c> gremioProfesionalAActualizar = [SELECT id, PRG_NUM_Recursos_de_Servicio_Activos__c FROM Profesional_Gremio__c WHERE Id in :profesionalesGremiosId];
		//Nos traemos una tupla con el id de los profesional_gremio a actualizar y el valor que tiene que llevar el campo PRG_NUM_Recursos_de_Servicio_Activos__c
		AggregateResult[] listaProfesionalCapacidad = [Select RSE_LKP_Profesional_Gremio__r.Id, Count(RSE_LKP_Profesional_Gremio__c) srActivos 
															from ServiceResource where RSE_LKP_Profesional_Gremio__c in :profesionalesGremiosId and 
															IsActive = true group by RSE_LKP_Profesional_Gremio__r.Id];
		if(!listaProfesionalCapacidad.isEmpty()){
			for(Profesional_Gremio__c gp :gremioProfesionalAActualizar){
				for(AggregateResult ar : listaProfesionalCapacidad ){
					if(gp.Id==ar.get('Id')){
						gp.PRG_NUM_Recursos_de_Servicio_Activos__c = ((decimal)ar.get('srActivos')).intValue();
						}
				}
			}
		}
		return gremioProfesionalAActualizar;
	}
	
	/**
	  * Método para actualizar el número de recursos activos para un determinado profesional_gremio de forma asíncrona
	  * 
	  * @param actualizarSRActivosSerializado: lista serializada de recursos de servicio que han modificado su isActive
	  */
	@future
	public static void actualizarRecursosActivosFuture(String actualizarSRActivosSerializado){
		//Desserializar los datos
		List<ServiceResource> actualizarSRActivos = (List<ServiceResource>)JSON.deserialize(actualizarSRActivosSerializado, List<ServiceResource>.class);
		//LLamada al método actualizarRecursosActivos de forma síncrona
		List<Profesional_Gremio__c> gremioProfesionalAActualizar = actualizarRecursosActivos(actualizarSRActivos);
		if(!gremioProfesionalAActualizar.isEmpty()){
			update gremioProfesionalAActualizar;
		}
	}
}