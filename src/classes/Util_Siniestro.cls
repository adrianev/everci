/**
 * Clase de funciones auxiliares relativas a los Siniestros.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Siniestro {


	/*
	 *  Devuelve una lista con los resultados de la query construida en funcion de los parámetros
	 *  
	 *  @param Id idCaso		- Id del caso a buscar
	 *  @param Id idPadre	   - Id del caso padre
	 *  @param Integer tipo	 - Tipo de búsqueda: 
	 *								  - 1 - Se busca el que tenga el Id de idCaso
	 *								  - 2 - Se busca el que tenga el ParentId del idPadre
	 *								  - 3 - Se busca el que tenga el id del idPadre
	 *
	 *  @return listaCasos  - Lista con los casos resultantes de la Query
	 **/
	/*public static List<Case> queryCaso(Id idCaso, Id idPadre, Integer tipo){
		List<Case> listaCasos = new List<Case>();
		if(!(idPadre == null && idCaso == null)){
			String sentenciaCaso = 'SELECT Id,';
			sentenciaCaso += ' AccountId,';
			sentenciaCaso += ' Account.Name,';
			sentenciaCaso += ' Account.CUE_TXT_Identificador__c,';
			sentenciaCaso += ' Account.RecordType.Name,';
			sentenciaCaso += ' CAS_CAS_Confirmado__c,';
			sentenciaCaso += ' CAS_CAS_Requiere_Perito__c,';
			sentenciaCaso += ' CAS_CAS_Danos_Propios__c,';
			sentenciaCaso += ' CAS_CAS_Danos_Perjudicado__c,';
			sentenciaCaso += ' CAS_CAS_Tercero_Causante__c,';
			sentenciaCaso += ' CAS_CAS_Siniestro_Grave__c,';
			sentenciaCaso += ' CAS_CAS_Supera_Limite_Actuacion__c,';
			sentenciaCaso += ' CAS_DAT_Fecha_Apertura__c,';
			sentenciaCaso += ' CAS_DAT_Primera_Cita__c,';
			sentenciaCaso += ' CAS_DIV_Importe_Total__c,';
			sentenciaCaso += ' CAS_DIV_Total_Facturar_CIA_AI__c,';
			sentenciaCaso += ' CAS_DIV_Total_Facturar_Cliente_AI__c,';
			sentenciaCaso += ' CAS_DIV_Total_Facturar_Profesional__c,';
			sentenciaCaso += ' CAS_EMA_Email__c,';
			sentenciaCaso += ' CAS_EMA_Solicitud_Email__c,';
			sentenciaCaso += ' CAS_FOR_Direccion_Riesgo__c,';
			sentenciaCaso += ' CAS_FOR_EsB2C__c,';
			sentenciaCaso += ' CAS_FOR_Importe_Total__c,';
			sentenciaCaso += ' CAS_FOR_Limite_Actuacion__c,';
			sentenciaCaso += ' CAS_FOR_Nombre_Solicitud__c,';
			sentenciaCaso += ' CAS_FOR_OT_Principal_Urgente__c,';
			sentenciaCaso += ' CAS_FOR_RTDevName__c,';
			sentenciaCaso += ' CAS_FOR_Tipo_Caso__c,';
			sentenciaCaso += ' CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c,';
			sentenciaCaso += ' CAS_LKP_Ayuda_Indemnizable__c,';
			sentenciaCaso += ' CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,';
			sentenciaCaso += ' CAS_LKP_Compania__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_TXT_Identificador__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.Name,';
			sentenciaCaso += ' CAS_LKP_Orden_Trabajo_Principal__c,';
			sentenciaCaso += ' CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,';
			sentenciaCaso += ' CAS_LKP_Perito__c,';
			sentenciaCaso += ' CAS_LKP_PolizaContrato__c,';
			sentenciaCaso += ' CAS_LKP_PolizaContrato__r.Name,';
			sentenciaCaso += ' CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,';
			sentenciaCaso += ' CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,';
			sentenciaCaso += ' CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c,';
			sentenciaCaso += ' CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,';
			sentenciaCaso += ' CAS_LKP_Procedencia__c,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.Name,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,';
			sentenciaCaso += ' CAS_LKP_Tipo_Trabajo__c,';
			sentenciaCaso += ' CAS_TXT_Causante_Poblacion__c,';
			sentenciaCaso += ' CAS_NUM_Id_Actuacion_SondeoExt__c,';
			sentenciaCaso += ' CAS_SEL_Causa_Averia__c,';
			sentenciaCaso += ' CAS_SEL_Causante_Compania__c,';
			sentenciaCaso += ' CAS_SEL_Causante_Provincia__c,';
			sentenciaCaso += ' CAS_SEL_Causante_Responsable__c,';
			sentenciaCaso += ' CAS_SEL_Causante_Tipo_Documento__c,';
			sentenciaCaso += ' CAS_SEL_Detalle_Averia__c,';
			sentenciaCaso += ' CAS_SEL_DirRiesgo_Estado_Provincia__c,';
			sentenciaCaso += ' CAS_SEL_Gremio_Principal__c,';
			sentenciaCaso += ' CAS_SEL_Grupo_Causa__c,';
			sentenciaCaso += ' CAS_SEL_Motivo_No_Apertura__c,';
			sentenciaCaso += ' CAS_SEL_Otros_Danos__c,';
			sentenciaCaso += ' CAS_SEL_Rango_Cita__c,';
			sentenciaCaso += ' CAS_SEL_Sondeo_DocIndemSug__c,';
			sentenciaCaso += ' CAS_SEL_Sondeo_Gremios__c,';
			sentenciaCaso += ' CAS_SEL_Situacion_Danos_Propios__c,';
			sentenciaCaso += ' CAS_SEL_Tipo_Averia__c,';
			sentenciaCaso += ' CAS_SEL_Tipo_Interlocutor__c,';
			sentenciaCaso += ' CAS_TFN_Telefono_1__c,';
			sentenciaCaso += ' CAS_TFN_Telefono_2__c,';
			sentenciaCaso += ' CAS_TXT_Ayuda_Ind_Apertura__c,';
			sentenciaCaso += ' CAS_TXT_Num_Caso_HS__c,';
			sentenciaCaso += ' CAS_TXT_Num_Caso_CIA__c,';
			sentenciaCaso += ' CAS_TXT_Codigo_Postal__c,';
			sentenciaCaso += ' CAS_TXT_Direccion__c,';
			sentenciaCaso += ' CAS_TXT_Causante_Direccion__c,';
			sentenciaCaso += ' CAS_TXT_Causante_N_Documento__c,';
			sentenciaCaso += ' CAS_TXT_Causante_N_exp_Stro__c,';
			sentenciaCaso += ' CAS_TXT_Causante_Poliza_R_C__c,';
			sentenciaCaso += ' CAS_TXT_Nombre__c,';
			sentenciaCaso += ' CAS_TXT_Apellidos__c,';
			sentenciaCaso += ' CAS_TXT_Apellidos_2__c,';
			sentenciaCaso += ' CAS_TXT_DirRiesgo_CP__c,';
			sentenciaCaso += ' CAS_TXT_DirRiesgo_Pais__c,';
			sentenciaCaso += ' CAS_TXT_DirRiesgo_Poblacion__c,';
			sentenciaCaso += ' CAS_TXT_Persona_que_llama__c,';
			sentenciaCaso += ' CAS_LKP_Cliente_contable__c,';
			sentenciaCaso += ' CAS_LKP_Cliente_contable_cliente__c,';
			sentenciaCaso += ' CAS_TXT_Sondeo_Causa__c,';
			sentenciaCaso += ' CAS_TXT_Subestado_Caso__c,';
			sentenciaCaso += ' CAS_TXT_Subestado_Codigo__c,';
			sentenciaCaso += ' CaseNumber,';
			sentenciaCaso += ' CreatedDate,';
			sentenciaCaso += ' ContactId,';
			sentenciaCaso += ' ContactEmail,';
			sentenciaCaso += ' Origin,';
			sentenciaCaso += ' OwnerId,';
			sentenciaCaso += ' Parent.Type,';
			sentenciaCaso += ' ParentId,';
			sentenciaCaso += ' RecordTypeId,';
			sentenciaCaso += ' RecordType.Name,';
			sentenciaCaso += ' Status,';
			sentenciaCaso += ' Type,';
			sentenciaCaso += ' CAS_SEL_Sondeo_Fase__c';
			sentenciaCaso += ' FROM Case';
			//Si se informa el ID del caso padre, hago la query para obtener los datos del hijo tipo indemnizable de ese padre
			if(idPadre != null && tipo == 2){
				//Se consulta 
				sentenciaCaso += ' WHERE ParentId = \'' + idPadre + '\' AND Type = \'' + Label.CAS_TIPO_INDEMNIZABLE + '\'';
			}else if(idCaso != null && tipo == 1){
				//Si solo se informa el idCaso, hago la query para obtener los datos de ese caso
				sentenciaCaso += ' WHERE Id = \'' + idCaso + '\'';
			}else if(idPadre != null && tipo == 3){
				sentenciaCaso += ' WHERE Id = \'' + idPadre + '\'';
			}
			listaCasos = database.query(sentenciaCaso);
		}
		return listaCasos;
	}*/

	/*
	 *  Devuelve una lista con los resultados de la query construida en funcion de los parámetros
	 *  
	 *  @param Id idConfirmacion- Id del objeto confirmacion a buscar
	 *
	 *  @return listaCasos  - Lista con los casos resultantes de la Query
	 **/
	//ICA 08/06/2018 Sobra método
	/*public static List<Confirmacion__c> queryConfirmacion(Id idConfirmacion){
		List<Confirmacion__c> listaConfirmaciones = new List<Confirmacion__c>();
		String sentenciaConfirmacion = 'SELECT Id,';
		sentenciaConfirmacion += ' CNF_CAS_Confirmado__c,';
		sentenciaConfirmacion += ' CNF_CAS_Requiere_Perito__c,';
		sentenciaConfirmacion += ' CNF_CAS_Danos_Propios__c,';
		sentenciaConfirmacion += ' CNF_CAS_Danos_Perjudicado__c,';
		sentenciaConfirmacion += ' CNF_CAS_Siniestro_Grave__c,';
		sentenciaConfirmacion += ' CNF_CAS_Tercero_Causante__c,';
		sentenciaConfirmacion += ' CNF_EMA_Email__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Compania__r.Name,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Orden_Trabajo_Principal__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Perito__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.Name,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Procedencia__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Procedencia__r.Name,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Tipo_Trabajo__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.ParentId,';
		sentenciaConfirmacion += ' CNF_NUM_Id_Actuacion_SondeoExt__c,';
		sentenciaConfirmacion += ' CNF_SEL_Causa_Averia__c,';
		sentenciaConfirmacion += ' CNF_SEL_Causante_Compania__c,';
		sentenciaConfirmacion += ' CNF_SEL_Causante_Provincia__c,';
		sentenciaConfirmacion += ' CNF_SEL_Causante_Responsable__c,';
		sentenciaConfirmacion += ' CNF_SEL_Causante_Tipo_Documento__c,';
		sentenciaConfirmacion += ' CNF_SEL_Detalle_Averia__c,';
		sentenciaConfirmacion += ' CNF_SEL_Estado__c,';
		sentenciaConfirmacion += ' CNF_SEL_Grupo_Causa__c,';
		sentenciaConfirmacion += ' CNF_SEL_Motivo_Rechazo__c,';
		//sentenciaConfirmacion += ' CNF_SEL_Otros_Danos__c,';
		sentenciaConfirmacion += ' CNF_SEL_Sondeo_DocIndemSug__c,';
		sentenciaConfirmacion += ' CNF_SEL_Sondeo_Fase__c,';
		sentenciaConfirmacion += ' CNF_SEL_Sondeo_Gremios__c,';
		sentenciaConfirmacion += ' CNF_SEL_Situacion_Danos_Propios__c,';
		sentenciaConfirmacion += ' CNF_SEL_Tipo__c,';
		sentenciaConfirmacion += ' CNF_SEL_Tipo_Averia__c,';
		sentenciaConfirmacion += ' CNF_TFN_Telefono_1__c,';
		sentenciaConfirmacion += ' CNF_TFN_Telefono_2__c,';
		sentenciaConfirmacion += ' CNF_TXT_Codigo_Postal__c,';
		sentenciaConfirmacion += ' CNF_TXT_Causante_Direccion__c,';
		sentenciaConfirmacion += ' CNF_TXT_Causante_N_Documento__c,';
		sentenciaConfirmacion += ' CNF_TXT_Causante_N_exp_Stro__c,';
		sentenciaConfirmacion += ' CNF_TXT_Causante_Poliza_R_C__c,';
		sentenciaConfirmacion += ' CNF_TXT_Causante_Poblacion__c,';
		sentenciaConfirmacion += ' CNF_TXT_Nombre__c,';
		sentenciaConfirmacion += ' CNF_TXT_Apellidos__c,';
		sentenciaConfirmacion += ' CNF_TXT_Apellidos2__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Cliente_contable__c,';
		sentenciaConfirmacion += ' CNF_LKP_ParentId__r.CAS_LKP_Cliente_contable_cliente__c,';
		sentenciaConfirmacion += ' CNF_TXT_Sondeo_Causa__c,';
		sentenciaConfirmacion += ' RecordTypeId,';
		sentenciaConfirmacion += ' RecordType.Name';
		sentenciaConfirmacion += ' FROM Confirmacion__c';
		
		//Si se informa el ID de la confirmación, hago la query para obtener los datos de dicha confirmación
		if(idConfirmacion != null){
			//Se consulta 
			sentenciaConfirmacion += ' WHERE Id = \'' + idConfirmacion + '\'';
		}
			
		listaConfirmaciones = database.query(sentenciaConfirmacion);
		return listaConfirmaciones;
	}*/
	


	/**
	 * Devuelve el tipo de actuación en función del código
	 *  @param num  -   String que contiene el número que indica el tipo de actuación
	 *  @param parent  -   Id del Caso padre
	 *  
	 *  @return	 -   String que devuelve el literal del tipo de actuación
	 */
	public static String devolverTipoActuacion(String num, Id parent){
		String retorno;
		if(num == Label.CAS_TIPO_REPARABLE){
			//retorno = 'Siniestro Reparable';
			retorno = Label.CAS_TIPOACT_REPARABLE;
		}else if(num == Label.CAS_TIPO_MIXTO){
			//retorno = 'Mixto: Parte Reparable';
			retorno = Label.CAS_TIPOACT_MIXTO_PARTE_REPARABLE ;
		}else if(num == Label.CAS_TIPO_INDEMNIZABLE && parent != null){
			//retorno = 'Mixto: Parte Indemnizable';
			retorno = Label.CAS_TIPOACT_MIXTO_PARTE_INDEMNIZABLE;
		}else if(num == Label.CAS_TIPO_INDEMNIZABLE && parent == null){
			//retorno = 'Siniestro Indemnizable';
			retorno = Label.CAS_TIPOACT_INDEMNIZABLE;
		}else if(num == Label.CAS_TIPO_RECHAZADO){
			//retorno = 'Rechazado';
			retorno = Label.CAS_TIPOACT_RECHAZADO;
		}else if(num == Label.CAS_TIPO_ASISTENCIA_COBERTURA){
			//retorno = 'Asistencia con Cobertura';
			retorno = Label.CAS_TIPOACT_ASISTENCIA_CON_COBERTURA;
		}
		else if( num == Label.CAS_TIPO_SERVICIO_ESPECIAL_REP){
			//retorno = 'Siniestro Servicio Especial Reparable';
			retorno = Label.CAS_TIPOACT_SINI_ESPECIAL_REPARABLE ;
		}
		else if(num == Label.RT_CAS_SOLIC_SINIESTRO){
			//retorno = 'Solicitud de Siniestro';
			retorno = Label.CAS_TIPOACT_SOLIC_SINIESTRO;
		}
		else if( num == Label.CAS_TIPO_MANITAS){
			//retorno = 'Manitas';
			retorno = Label.CAS_TIPOACT_SINI_MANITAS;
		}
		else{
			system.debug('@Alejandro Util_Siniestro num: '+num + 'Id parent:'+ parent ); /* [ELIMINAR TRAS PRUEBAS] */
			if(num==''){
				retorno = '[ERROR] Campo Type No informados desde VESTA';
			}
			else{
			retorno = '[ERROR] Valor inesperado desde VESTA'; 
			}
		}
		return retorno;
	}// FIN String devolverTipoActuacion

	/**
	 * Obtiene a partir de un Caso de Siniestro Reparable Mixto, el caso correspondiente a su parte Indemnizable.
	 * 
	 * @param idSiniestroMixto Id del Siniestro Mixto padre
	 * @return objeto Case correspondiente a la parte Indemnizable
	 */
	public static Case obtenerHijoSiniestroMixto(Id idSiniestroMixto){
		Case siniestroHijo = null;
		if (idSiniestroMixto != null){
			List<Case> listaCasos = Util_Caso.getCaseByParentId(new Set<Id>{idSiniestroMixto}).values();
			//List<Case> listaCasos = queryCaso(null, idSiniestroMixto, 2);
			if (!listaCasos.isEmpty()){
				siniestroHijo = listaCasos.get(0);
			}
		}
		return siniestroHijo;
	} // FIN obtenerHijoSiniestroMixto

	/**
	 * Obtiene a partir de una lista de Casos de Siniestro Reparable Mixto, los casos correspondientes a sus partes Indemnizables.
	 * 
	 * @param Set<Id> Ids de los Siniestros Mixtos padres
	 * @return Map<Id, Case> Mapa con la clave del padre y como valor su caso correspondiente a la parte Indemnizable
	 */
	public static Map<Id, Case> obtenerHijosSiniestrosMixtos(Set<Id> idsSiniestrosMixtos){
		Map<Id, Case> siniestrosHijos = new Map<Id, Case>();
		if (idsSiniestrosMixtos != null
				&& !idsSiniestrosMixtos.isEmpty()){		
			//PREV:	
			/*List<Case> listaCasosHijos = new List<Case>([
														 SELECT ParentId
														 FROM   Case
														 WHERE  ParentId IN :idsSiniestrosMixtos]);
			*/  
			//NEW:
			List<Case> listaCasosHijos = new List<Case>(Util_Caso.getMapaCasosHijosByParentId(idsSiniestrosMixtos).values());
			for(Case hijo : listaCasosHijos){
				siniestrosHijos.put(hijo.ParentId, hijo);
			}
		}
		return siniestrosHijos;
	} // FIN obtenerHijosSiniestrosMixtos

	/**
	 * Crea un Siniestro (hijo) a partir de la clonación de un Siniestro (padre).
	 * Ej: Siniestro Indemnizable Mixto a partir de Siniestro Reparable Mixto
	 * 
	 * @param siniestroPadre Objeto Case del Siniestro a clonar
	 * @param estadoNuevo Estado a establecer en el Siniestro nuevo
	 * @param tipoActuacionNuevo Tipo de Actuación a establecer en el Siniestro nuevo
	 * @return objeto Case correspondiente al nuevo Siniestro hijo
	 */
	public static Case clonarSiniestro(Case siniestroPadre, String estadoNuevo, String tipoActuacionNuevo, Account compania)
	{
		Case siniestroHijo = null;
		if (siniestroPadre != null)
		{
			siniestroHijo = siniestroPadre.clone(false,true);
			siniestroHijo.Status = estadoNuevo;
			siniestroHijo.Type = tipoActuacionNuevo;
			siniestroHijo.CAS_SEL_Sondeo_Fase__c = null;
			siniestroHijo.ParentId = siniestroPadre.Id;
			siniestroHijo.CAS_TXT_Identificador__c = null;
			siniestroHijo.RecordTypeId = Util_Caso.getIdTipoDeRegistro(siniestroHijo.RecordTypeId, tipoActuacionNuevo, compania, estadoNuevo);
		}
		return siniestroHijo;
	} // FIN clonarSiniestro


	/**
	 * Copia los campos de la Dirección de Riesgo de una Póliza en un Siniestro.
	 * 
	 * @param siniestro Siniestro a actualizar
	 * @param poliza Poliza de la que heredar la Dirección de Riesgo
	 * @return objeto Case del Siniestro actualizado
	 */
	public static Case heredarDireccionRiesgoPoliza(Case siniestro, ServiceContract poliza){
		//¿Porqué se hace tanto en B2B, como en Siniestros en el trigger?
		System.debug('Util_Siniestro: heredarDireccionRiesgoPoliza: siniestro: '+siniestro);
		System.debug('Util_Siniestro: heredarDireccionRiesgoPoliza: siniestro: '+poliza);
		if(siniestro != null && poliza != null){
			siniestro.CAS_TXT_DirRiesgo_CP__c = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Codigo_Postal__c;
			siniestro.CAS_TXT_Direccion__c = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Calle__c;
			siniestro.CAS_TXT_DirRiesgo_Poblacion__c  = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Poblacion__c;
			siniestro.CAS_SEL_DirRiesgo_Estado_Provincia__c = poliza.POL_LKP_Version_Actual__r.POLV_SEL_Estado_Provincia__c;
			siniestro.CAS_TXT_DirRiesgo_Pais__c = Util_Listas_Seleccion.getLabelDesdeAPI('Version_ContratoServicio__c', 'POLV_SEL_Pais__c').get(poliza.POL_LKP_Version_Actual__r.POLV_SEL_Pais__c);
		}
		return siniestro;
	} // FIN heredarDireccionRiesgoPoliza

	/*
	 * Se encarga de realizar las validaciones y las acciones necesarias para finalizar 
	 * el proceso de apertura del siniestro:
	 * 
	 * @param Case siniestro	- Caso sobre el cuál se procede a la finalización del proceso de apertura.
	 * 
	 **/
	public static void finalizarAperturaSiniestro(Case siniestro){
		
		Id recordTypeIdSini = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			List<Case> listaCasosActualizar = new List<Case>();
			// 1. ********************PENDIENTE VALIDAR LIMITE PERITOS

			// 2. Generar Nº de Siniestro HS.
			Procedencia__c procedencia = (Util_Procedencia.queryProcedencia(siniestro.CAS_LKP_Procedencia__c)).get(0);
			system.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RecordType:'+ siniestro.RecordType.Name+'   '+siniestro.Status);
			String numHs = Util_Identificadores.generarNumeroHS(siniestro, null, procedencia);
			siniestro.CAS_TXT_Num_Caso_HS__c = numHs;
			siniestro.RecordTypeId = recordTypeIdSini;
			siniestro.CAS_TXT_Identificador__c = Util_Identificadores.generarIdExternoCaso(siniestro.RecordTypeId, siniestro.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, siniestro.CAS_TXT_Num_Caso_HS__c);
			update procedencia;

			// 3. Generar Nº de Siniestro CIA
			siniestro.CAS_TXT_Num_Caso_CIA__c = Util_Identificadores.generarNumIntervencionCIA(siniestro, procedencia);

			// 4. Propagar cambios a Siniestro Hijo
			if (siniestro.Type == Label.CAS_TIPO_MIXTO)
			{
				Case siniestroHijo = obtenerHijoSiniestroMixto(siniestro.Id);
				if (siniestroHijo != null)
				{
					siniestroHijo.CAS_TXT_Num_Caso_CIA__c = siniestro.CAS_TXT_Num_Caso_CIA__c;
					siniestroHijo.CAS_TXT_Num_Caso_HS__c = siniestro.CAS_TXT_Num_Caso_HS__c;
					siniestroHijo.CAS_TXT_Identificador__c = siniestro.CAS_TXT_Identificador__c + '_Indem';
					siniestroHijo.CAS_CAS_Siniestro_Grave__c = siniestro.CAS_CAS_Siniestro_Grave__c;
					siniestroHijo.CAS_DAT_Fecha_Apertura__c = datetime.now();
					if(siniestroHijo.Type == Label.CAS_TIPO_INDEMNIZABLE 
							&& siniestroHijo.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_RGA){
						siniestroHijo.Status = Label.CAS_ESTADO_CERRADO;
						siniestroHijo.CAS_CAS_Transferido__c = true;
					}
					listaCasosActualizar.add(siniestroHijo);
				}
			}else if(siniestro.Type == Label.CAS_TIPO_INDEMNIZABLE 
					&& siniestro.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_RGA){
				siniestro.Status = Label.CAS_ESTADO_CERRADO;
				siniestro.CAS_CAS_Transferido__c = true;
			}
			siniestro.CAS_DAT_Fecha_Apertura__c = datetime.now();
			listaCasosActualizar.add(siniestro);
			update listaCasosActualizar;


			// 5. ********************PENDIENTE INSERTAR EN TABLA DE MOVIMIENTOS EL EVENTO DE APERTURA		  
			system.debug('>>>>>>>>>>>>>>>>finalizarAperturaSiniestro: generando movimiento apertura');
			Util_Movimientos.compruebaEnviable(siniestro.Id,siniestro.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'1');
			system.debug('>>>>>>>>>>>>>>>>finalizarAperturaSiniestro: finalizada generación de movimiento apertura');
		}
		catch(Exception e)
		{
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>>>>finalizarAperturaSiniestro exception:' + e.getStackTraceString());
			throw e;
		}
	}//FIN FUNCION FINALIZAR


	/*
	 * Se encarga de realizar las validaciones y las acciones necesarias para finalizar 
	 * el proceso de confirmación del siniestro:
	 * 
	 * @param Case siniestro	- Caso sobre el cuál se procede a la confirmación del proceso de apertura.
	 * 
	 **/
	public static void finalizarConfirmacionSiniestro(Case siniestro){
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try
		{
			List<Case> listaCasosActualizar = new List<Case>();
			// 1. ********************PENDIENTE VALIDAR LIMITE PERITOS

			//VALIDAR LIMITE DE ACTUACION

			// 2. Si el check de daños propios no está marcado: blanquear campos del Caso de daños propios 
			//(situación daños y otros daños)
			if(!siniestro.CAS_CAS_Danos_Propios__c){
				siniestro.CAS_SEL_Situacion_Danos_Propios__c = null;
				siniestro.CAS_SEL_Otros_Danos__c = null;
			}

			// 3. Si el check de daños perjudicados no está marcado: 
			//eliminar todos los registros de perjudicado vinculados al Caso
			if(!siniestro.CAS_CAS_Danos_Perjudicado__c){
				//PREV:
				/*List<Perjudicado_Siniestro__c> listaPerjudicados = new List<Perjudicado_Siniestro__c>(
						[   SELECT Id
							FROM Perjudicado_Siniestro__c
							WHERE PRJ_LKP_Siniestro__c = :siniestro.Id]);
							*/
				//NEW:
				List<Perjudicado_Siniestro__c> listaPerjudicados = new List<Perjudicado_Siniestro__c>(queryPerjudicadosSini(new Set<Id>{siniestro.Id}).values());
				delete listaPerjudicados;
			}

			// 4. Si el check de tercero causante no está marcado: 
			//blanquear campos del Caso de Causante
			if(!siniestro.CAS_CAS_Tercero_Causante__c){
				siniestro.CAS_SEL_Causante_Compania__c = null;
				siniestro.CAS_TXT_Causante_Direccion__c = '';
				siniestro.CAS_TXT_Causante_N_Documento__c = '';
				siniestro.CAS_TXT_Causante_N_exp_Stro__c = '';
				siniestro.CAS_TXT_Causante_Poliza_R_C__c = '';
				siniestro.CAS_TXT_Causante_Poblacion__c = '';
				siniestro.CAS_SEL_Causante_Provincia__c = null;
				siniestro.CAS_SEL_Causante_Responsable__c = null;
				siniestro.CAS_CAS_Tercero_Causante__c = false;
				siniestro.CAS_SEL_Causante_Tipo_Documento__c = null;
				siniestro.CAS_TXT_Nombre__c = '';
				siniestro.CAS_TXT_Apellidos__c = '';
				siniestro.CAS_TXT_Apellidos_2__c = '';
			}

			// 5. Propagar cambios a Siniestro Hijo
			if (siniestro.Type == Label.CAS_TIPO_MIXTO)
			{
				Case siniestroHijo = obtenerHijoSiniestroMixto(siniestro.Id);
				if (siniestroHijo != null)
				{
					siniestroHijo.CAS_CAS_Confirmado__c = true;
					siniestroHijo.Status = Label.CAS_ESTADO_EN_CURSO;
					if(siniestroHijo.Type == Label.CAS_TIPO_INDEMNIZABLE 
							&& siniestroHijo.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_RGA){
						siniestroHijo.Status = Label.CAS_ESTADO_CERRADO;
						siniestroHijo.CAS_CAS_Transferido__c = true;
					}
					listaCasosActualizar.add(siniestroHijo);
				}
			}

			siniestro.CAS_CAS_Confirmado__c = true;
			siniestro.Status = Label.CAS_ESTADO_EN_CURSO;

			listaCasosActualizar.add(siniestro);
			upsert listaCasosActualizar;
		}
		catch(Exception e)
		{
			Database.rollback(puntoGuardado);
			throw e;
			system.debug(e.getStackTraceString());
		}
	}//FIN finalizarConfirmacionSiniestro

	/**
	 * Recibe un objeto Case y devuelve un Boolean: 
	 * True si el límite de graves es menor que el importe total del siniestro.
	 * False si es límite es mayor que el importe total o tiene valor null o 0.
	 *
	 * @param Case caso -   Caso que se desea comprobar si es Grave o no
	 * @return  bol	 -   Variable que devuelve si el siniestro es grave o no
	 */
	public static Boolean validarCondicionesSiniGrave(Case siniestro)
	{
		Configuracion_General__mdt configGeneral = Util_Metadatos.CONFIG_GENERAL.get('NumGremiosGraves');
		//PREV: List<WorkOrder> listaGremios = new List<WorkOrder>([SELECT Id FROM WorkOrder WHERE CaseId = :siniestro.Id AND RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)]);
		//NEW:
		List<WorkOrder> listaGremios = new List<WorkOrder>(Util_Orden_Trabajo.getWorkOrderByCaseAndRecordType(new Set<Id>{siniestro.Id}, new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)}).values() );
		// Nº de Gremios
		Integer numGremios = listaGremios.size();
		// Importe total
		Double total = siniestro.CAS_DIV_Importe_Total__c;

		if (siniestro.Type == Label.CAS_TIPO_MIXTO)
		{
			Case siniestroHijo = obtenerHijoSiniestroMixto(siniestro.Id);
			if (siniestroHijo != null && siniestroHijo.CAS_DIV_Importe_Total__c != null){
				// Si existe un Siniestro Hijo: sumamos el importe total de la parte indemnizable
				total += siniestroHijo.CAS_DIV_Importe_Total__c;
			}
		}
		// Por alguna razón, en los Tests la sentencia Util_Compania.CIA_BY_IDSF siempre devuelve un mapa vacío:
		system.debug('Util_Siniestro : validarCondicionesSiniGrave : Util_Compania.CIA_BY_IDSF : '+Util_Compania.CIA_BY_IDSF);
		system.debug('Util_Siniestro : validarCondicionesSiniGrave : Util_Cuentas.queryMapCuentaByRT(new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA),Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1)}) : '+Util_Cuentas.queryMapCuentaByRT(new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA),Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1)}));
		//Double lim = Util_Compania.CIA_BY_IDSF.get(siniestro.CAS_LKP_Compania__c).CUE_DIV_Limite_Graves__c;
		Double lim = Util_Cuentas.queryMapCuentaByRT(new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA),Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1)}).get(siniestro.CAS_LKP_Compania__c).CUE_DIV_Limite_Graves__c;	
		system.debug('Util_Siniestro : validarCondicionesSiniGrave : lim : '+lim+' : '+((lim != null)?'Cumple':'NO cumple')+' la condición');
		system.debug('Util_Siniestro : validarCondicionesSiniGrave : total : '+total+' : '+((total > lim)?'Cumple':'NO cumple')+' la condición');
		system.debug('Util_Siniestro : validarCondicionesSiniGrave : numGremios : '+numGremios);
		system.debug('Util_Siniestro : validarCondicionesSiniGrave : configGeneral.CF_NUM_Valor__c : '+configGeneral.CF_NUM_Valor__c+' : '+((numGremios >= configGeneral.CF_NUM_Valor__c)?'Cumple':'NO cumple')+' la condición');
		system.debug('Util_Siniestro : validarCondicionesSiniGrave : return : '+((lim != null && lim > 0 && total > lim) || (numGremios >= configGeneral.CF_NUM_Valor__c)));
		// Si el límite no es nulo ni 0 y el importe total es mayor que el límite o el nº de gremios es mayor que el nº de gremios máximo
		return ((lim != null && lim > 0 && total > lim) || (numGremios >= configGeneral.CF_NUM_Valor__c));
	}// FIN validarCondicionesSiniGrave

	/**
	 * ****************Actualizar comentario parametro entrada  
	 * Método que recibe un objeto Caso. Proceso:
	 *	  1) Crear nueva Orden de Trabajo con Gremio "Siniestro Grave" y tipo de trabajo "Siniestro Grave" 
	 *		  vinculada al Caso como Orden de Trabajo principal
	 *	  2) Vincular Partidas de las Ordenes de Trabajo del Caso que no están Cerradas 
	 *		  (estado <> 'Anulado' y estado <> 'Cerrado')
	 *	  3) Eliminar Ordenes de Trabajo del Caso en estado 'Inactivo'
	 *	  4) Anular Ordenes de Trabajo del Caso que no están Cerradas ni Anuladas
	 *  
	 *
	 *  @param Case caso	- Siniestro que se va a comprobar si tiene que pasar a ser Siniestro Grave o no
	 *
	 *
	 */
	public static void conversionASiniGrave(Map<Id, Case> mapaCasos, Map<Id, Case> mapaCasosOld, 
			Map<Id, List<WorkOrder>> mapaOTsDeCasos, Map<Id, WorkOrderLineItem> mapaPartidasOTs, Map<Id, WorkOrder> mapaOTs){
		system.debug(' \n\n ******DENTRO DE FUNCION CONVERTIRASINIGRAVE *****');
		Id idSucesoGrave;
		List<WorkOrder> listaOTsGraves = new List<WorkOrder>();
		List<WorkOrderLineItem> listaWOLI = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> listaWOLIActualizar = new List<WorkOrderLineItem>();  
		Map<Id, List<WorkOrderLineItem>> mapaPartidasCaso = new Map<Id, List<WorkOrderLineItem>>();
		List<WorkOrder> wOCerradoAnuladoInactivo = new List<WorkOrder>();
		List<WorkOrder> listaOTActualizar = new List<WorkOrder>();
		List<WorkOrder> listaOTEliminar = new List<WorkOrder>();
		Set<Id> listaWONoCerAnu = new Set<Id>();
		Set<Id> listaWOInactivas = new Set<Id>();
		for(Case caso : mapaCasos.values()){
			Case casoOld = mapaCasosOld.get(caso.Id);
			// Si se ha marcado el check de Grave en el Siniestro Reparable Puro o en el Padre si es Mixto y no estaba marcado previamente:
			if(esSiniestro(caso) && caso.CAS_CAS_Siniestro_Grave__c
					&& !casoOld.CAS_CAS_Siniestro_Grave__c
					&& caso.Type != Label.CAS_TIPO_INDEMNIZABLE 
					&& caso.Parent == null){
				system.debug('>>>>DENTRO DE IF GRAVE');
				//PUNTO 1 - GENERO LA ORDEN DE TRABAJO NUEVA DE SINIESTRO GRAVE
				if(idSucesoGrave == null){
					List<WorkType> listaWT = Util_TipoTrabajo.getWorkTypeByName(new Set<String>{Label.SINI_SUCESO_GRAVES}).values();
					/*List<WorkType> listaWT = new List<WorkType>([
																 SELECT	 Id 
																 FROM   WorkType 
																 WHERE  Name = :Label.SINI_SUCESO_GRAVES]);*/
					if (!listaWT.isEmpty()){	// Si existe el worktype de siniestro grave
						idSucesoGrave = listaWT.get(0).Id;  //Se guarda su Id en la variable
					}
				}

				//Creo la orden de trabajo pasando los argumentos correspondientes
				WorkOrder otGrave = Util_Orden_Trabajo.crearOrdenDeTrabajo(caso, null, Label.SINI_GREMIO_GRAVES, idSucesoGrave, null, false);
				listaOTsGraves.add(otGrave);

				//Se comprueba si el caso tiene alguna otra orden de trabajo relacionada
				List<WorkOrder> listaOTsDelCaso = mapaOTsDeCasos.get(caso.Id);
				if(listaOTsDelCaso != null){
					//Se recorre la lista de las órdenes de trabajo relacionadas
					for(WorkOrder ordTbjo : listaOTsDelCaso){
						//Si el estado de la OT es distinto de Cerrado y de Anulado
						if(ordTbjo.Status != Label.OTR_ESTADO_CERRADO 
								&& ordTbjo.Status != Label.OTR_ESTADO_ANULADO
								&& ordTbjo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO){
							//Lo agrego a un set
							listaWONoCerAnu.add(ordTbjo.Id);
						}
						//Si el estado de la OT es Inactivo se guardan en un set para borrarlas
						if(ordTbjo.Status != Label.OTR_ESTADO_INACTIVO){
							listaWOInactivas.add(ordTbjo.Id);
						}
					}
				}			   
			}
		}	   

		try {
			// Inserto las nuevas OTs que tendrán como WT (suceso) Siniestro Grave
			// Inserción en trigger.before, necesaria para reducir la complejidad del trigger
			insert listaOTsGraves;
		}
		catch(Exception e){
			system.debug('*************** EXCEPTION: ' + e);
		}	   

		//PUNTO 2 - VINCULO TODAS LAS OTL's DE LAS OT's QUE NO TENGAN COMO ESTADO DE OTL NI 'Anulado' ni 'Cerrado'
		// Se almacenan las OTL's que se van a guardar
		// Se almacenan todas las OTL's de las órdenes de trabajo que no estén ni cerradas ni anuladas
		// Mapa con todas las partidas de los casos
		for(WorkOrderLineItem woli : mapaPartidasOTs.values()){
			if(listaWONoCerAnu.contains(woli.WorkOrderId)){
				List<WorkOrderLineItem> listaPartidas;
				if(mapaPartidasCaso.containsKey(woli.WorkOrder.CaseId)){
					listaPartidas = mapaPartidasCaso.get(woli.WorkOrder.CaseId);
				}else{
					listaPartidas = new List<WorkOrderLineItem>();
				}
				listaPartidas.add(woli);
				mapaPartidasCaso.put(woli.WorkOrder.CaseId, listaPartidas);
			}
		}

		for(WorkOrder ordTbjo : listaOTsGraves){
			Case caso = mapaCasos.get(ordTbjo.CaseId);
			//Pongo la OT que se ha creado como OT Principal
			caso.CAS_LKP_Orden_Trabajo_Principal__c = ordTbjo.Id;
			caso.CAS_SEL_Gremio_Principal__c = Label.SINI_GREMIO_GRAVES;
			caso.CAS_LKP_Tipo_Trabajo__c = idSucesoGrave;

			List<WorkOrderLineItem> partidasDeOTsCaso = mapaPartidasCaso.get(caso.Id);
			if(partidasDeOTsCaso != null){
				for(WorkOrderLineItem woli : partidasDeOTsCaso){
					WorkOrderLineItem woliNueva = new WorkOrderLineItem();
					woliNueva = woli.clone(false, true);
					woliNueva.WorkOrderId = ordTbjo.Id;
					woliNueva.Status = Label.OTR_ESTADO_INACTIVO;
					listaWOLIActualizar.add(woliNueva); 
				}
			}
		}

		if(!listaWOInactivas.isEmpty()){
			//PREV:
			/*wOCerradoAnuladoInactivo = new List<WorkOrder>([
															SELECT  Status
															FROM	WorkOrder
															WHERE   Id IN :listaWONoCerAnu
															OR Id IN :listaWOInactivas]);
			*/
			//NEW:
			Set<Id> setIds = new Set<Id>(listaWONoCerAnu);
			setIds.addAll(listaWOInactivas);
			wOCerradoAnuladoInactivo = new List<WorkOrder>(Util_Orden_Trabajo.queryMapOTByCase(setIds).values());
			//END_NEW
		}

		for(WorkOrder ordTbjo : wOCerradoAnuladoInactivo){
			if(!listaWOInactivas.contains(ordTbjo.Id)){
				ordTbjo.Status = Label.OTR_ESTADO_ANULADO;
				listaOTActualizar.add(ordTbjo);
			}else{
				listaOTEliminar.add(ordTbjo);
			}
		}

		system.debug('******* listaWOLI NUEVAS : ' + listaWOLIActualizar);
		//Actualizo las OT'S y las OTL's y borro las que esten inactivas
		try{
			upsert listaOTActualizar;
			system.debug('********** listaOTActualizar : ' + listaOTActualizar);
			upsert listaWOLIActualizar;
			system.debug('********** listaWOLIActualizar : ' + listaWOLIActualizar);
			system.debug('********** listaOTEliminar : ' + listaOTEliminar);
			delete listaOTEliminar;
		}catch(Exception e){
			system.debug('********** EXCEPTION : ' + e);
			system.debug('********************** EXCEPTION UPSERT listaOTActualizar : ' + listaOTActualizar);
			system.debug('********************** EXCEPTION UPSERT listaWOLIActualizar : ' + listaWOLIActualizar);
			system.debug('********************** EXCEPTION delete listaWOInactivas : ' + listaWOInactivas);
		}

		// Es necesario actualizar los mapas: mapaOTsPorCaso y mapaOTs para que se puedan seguir utilizando correctamente en el trigger sin necesidad
		// de realizar una nueva consulta a base de datos
		for(WorkOrder wo : listaOTActualizar){
			if(wo.CaseId != null){
				mapaOTs.put(wo.Id, wo);
			}

			List<WorkOrder> listaWO;
			if(mapaOTsDeCasos.containsKey(wo.CaseId)){
				listaWO = mapaOTsDeCasos.get(wo.CaseId);
			}else{
				listaWO = new List<WorkOrder>();
			}
			Integer indiceWO = listaWO.indexOf(wo);
			if(indiceWO >= 0){
				listaWO.remove(indiceWO);
			}
			listaWO.add(wo);
			mapaOTsDeCasos.put(wo.CaseId, listaWO);
		}
		system.debug(' \n\n ******SALIENDO DE FUNCION CONVERTIRASINIGRAVE *****');
	}//FIN conversionASiniGrave

	/**
	 *  Convierte en Solicitud de Siniestro No Abierta un siniestro cancelado antes de finalizar su apertura.
	 *
	 *  @param siniestro  Siniestro que se ha cancelado antes de finalizar su apertura
	 */
	public static void cancelarAperturaSiniestro(Case siniestro)
	{
		// Si se cancela una vez iniciado el proceso de apertura: establecemos la Solicitud de Siniestro como "No Abierta"
		if (siniestro.status != Label.SINI_ESTADO_PDTESONDEO){
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try
			{
				// 1. Establecemos el Siniestro como No Abierto
				siniestro.Status = Label.SINI_ESTADO_NO_ABIERTO;
				//siniestro.CAS_SEL_Motivo_No_Apertura__c = Label.SINI_MOTIVO_CANCEL;
				siniestro.CAS_SEL_Motivo_No_Apertura__c = Label.SINI_MOTIVO_CANCEL_USUARIO;

				// 2. Si es mixto: eliminamos el Caso Hijo
				if (siniestro.Type == Label.CAS_TIPO_MIXTO)
				{
					Case siniestroHijo = obtenerHijoSiniestroMixto(siniestro.Id);
					if (siniestroHijo != null)
					{
						delete siniestroHijo;
					}
				}
				siniestro.Type = Label.CAS_TIPO_NOABIERTO;
				// 3. Establecemos el RecordType de Solicitud de Siniestro
				siniestro.RecordTypeId = Util_Caso.getIdTipoDeRegistro(siniestro.RecordTypeId, siniestro.Type, null, siniestro.Status);
				upsert siniestro;

				// 4. Si existen citas en curso asociadas al sinestro, notificar al cliente y al profesional asociado - PENDIENTE

				// 5. Eliminamos las Ordenes de Trabajo
				//PREV: List<WorkOrder> listaWorkOrder = Util_Orden_Trabajo.queryOT(null, siniestro.Id, null);
				List<WorkOrder> listaWorkOrder = Util_Orden_Trabajo.queryMapOTByCase(new Set<Id>{siniestro.Id}).values();
				delete listaWorkOrder;

				// 6. Se genera un comentario asociado al caso
				Comentario_caso__c comentarioCasoInsertar = Util_Caso.crearComentarioCaso(siniestro.Id, Label.SINI_COMENTARIO_CANCELACION);
				insert comentarioCasoInsertar;
			}
			catch(Exception e)
			{
				Database.rollback(puntoGuardado);
				throw e;
				system.debug(e.getStackTraceString());
			}
		}
	}


	/*
	 * Comprueba si hay partidas reparables obligatorias.
	 * Si no hay ninguna partida reparable obligatoria, devuelve mensaje de error
	 * 
	 * @param Case caso		 - Caso sobre el cuál se procede a la finalización del proceso de apertura.
	 * 
	 * @return otRetornoError   - Devuelve el mensaje de error o null en caso de que no haya errores
	 **/
	public static String partidasObligatoriasReparable(Case caso){
		String otRetornoError;
		String gremiosError = '';
		//PREV:
		//Map<Id, WorkOrder> oTCaso = new Map<Id, WorkOrder>([SELECT OTR_SEL_Gremio__c FROM WorkOrder WHERE CaseId = :caso.Id AND RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)]);
		//List<WorkOrderLineItem> lineasOT = new List<WorkOrderLineItem>([SELECT WorkOrderId FROM WorkOrderLineItem WHERE WorkOrderId IN :oTCaso.keySet()/* AND PAR_DIV_Liquidar_Prof_DI__c >= 1*/]);
		//NEW:
		Map<Id, WorkOrder> oTCaso = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordType(new Set<Id>{caso.Id}, new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)});
		List<List<WorkOrderLineItem>> listaLineasOT = Util_Orden_Trabajo.getMapaPartidasOTs(oTCaso.keySet()).values();
		system.debug('Util_Siniestro : partidasObligatoriasReparable : listaLineasOT : '+listaLineasOT);
		List<WorkOrderLineItem> lineasOT = (listaLineasOT != null && !listaLineasOT.isEmpty()) ? listaLineasOT[0] : (new List<WorkOrderLineItem>());
		system.debug('Util_Siniestro : partidasObligatoriasReparable : lineasOT : '+lineasOT);
		//END_NEW
		
		Map<Id, WorkOrderLineItem> mapaOTLineas = new Map<Id, WorkOrderLineItem>();
		for(WorkOrderLineItem linea : lineasOT){
			if(linea.WorkOrderId != null){
				mapaOTLineas.put(linea.WorkOrderId, linea);
			}
		}
		system.debug('Util_Siniestro : partidasObligatoriasReparable : oTCaso.values() : '+oTCaso.values());
		system.debug('Util_Siniestro : partidasObligatoriasReparable : mapaOTLineas : '+mapaOTLineas);
		for(WorkOrder ot : oTCaso.values()){
			WorkOrderLineItem linea = mapaOTLineas.get(ot.Id);
			system.debug('Util_Siniestro : partidasObligatoriasReparable : linea : '+linea);
			if(linea == null){
				gremiosError += Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Gremio__c').get(ot.OTR_SEL_Gremio__c) + ', ';
				system.debug('Util_Siniestro : partidasObligatoriasReparable : gremiosError : '+gremiosError);
			}
		}
		if(gremiosError.length() > 0){
			gremiosError = gremiosError.removeEnd(', ');
			//otRetornoError = 'Es necesario incluir, al menos, una partida con importe mayor a 1 para los gremios ' + gremiosError;
			otRetornoError = 'Es necesario incluir, al menos, una partida para los gremios ' + gremiosError;
		}
		return otRetornoError;
	}

	/*
	 * Devuelve true si el caso recibido es un siniestro
	 * 
	 * @param Case siniestro		 - Caso sobre el cuál se valida
	 * 
	 * @return Devuelve true si el caso recibido es un siniestro
	 **/
	public static Boolean esSiniestro(Case siniestro){
		Boolean esSiniestro = false;
		if(siniestro != null){
			String nombreTR = Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(siniestro.RecordTypeId);
			system.debug(nombreTR + ' NOMBRETR');
			if(nombreTR == Label.RT_CAS_SINIESTRO.replace('Case:','')
					|| nombreTR == Label.RT_CAS_SINIESTRO_MEMB.replace('Case:','')
					|| nombreTR == Label.RT_CAS_SOLIC_SINIESTRO.replace('Case:','')){
				esSiniestro = true;
			}
		}
		return esSiniestro;
	}

	public static void comprobarPendienteGestor(List<WorkOrder> ordenesTrabajoCasos, 
			Map<Id, Case> mapaCasos, Map<Id, Case> mapaCasosAct){
		Map<Id, WorkOrder> mapaOTCasos = Util_Orden_Trabajo.ordenesTrabajoDeCaso(ordenesTrabajoCasos);
		Map<Id, Boolean> mapaPendientesGestorCasos = new Map<Id, Boolean>();
		List<Case> listaCasosAct = new List<Case>();
		for(WorkOrder ot : mapaOTCasos.values()){
			system.debug('>>>>Orden de trabajo (mapaOTCasos): ' + ot);
			if(ot.Status == Label.OTR_ESTADO_EN_ESPERA_CONF_GEST
					/*|| ot.Status == Label.OTR_ESTADO_INACTIVO
			 || ot.Status == Label.OTR_ESTADO_CERRADO
			 || ot.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO
			 || ot.Status == Label.OTR_ESTADO_REVISADO*/){
				mapaPendientesGestorCasos.put(ot.CaseId, true);
			}else{
				mapaPendientesGestorCasos.put(ot.CaseId, false);
			}
		}

		for(Id idCaso : mapaPendientesGestorCasos.keySet()){
			if(mapaPendientesGestorCasos.get(idCaso)){
				Case casoOrig = mapaCasos.get(idCaso);
				Case casoAct;
				if(mapaCasosAct.containsKey(idCaso)){
					casoAct = mapaCasosAct.get(idCaso);
				}else{
					casoAct = mapaCasos.get(idCaso);
				}
				if(esSiniestro(casoOrig)
						&& casoOrig.Status != Label.CAS_ESTADO_ESPERA_GESTOR_CONFIRMACION){
					casoAct.Status = Label.CAS_ESTADO_ESPERA_GESTOR_CONFIRMACION;
					casoAct.CAS_CAS_Requiere_Perito__c = true;
					casoAct.CAS_LKP_Compania__c = casoOrig.CAS_LKP_Compania__c;
					casoAct.CAS_SEL_DirRiesgo_Estado_Provincia__c = casoOrig.CAS_SEL_DirRiesgo_Estado_Provincia__c;
					system.debug('>>>>casoAct ' + casoAct);
					// Se comprueba si el caso necesita un perito, en caso afirmativo se le asiganara uno automaticamente
					casoAct = Util_Perito.procesoAsignacion(casoAct);
					mapaCasosAct.put(casoAct.Id, casoAct);
				}
			}
		}
	}

	public static void comprobacionSondeo(Case caso){
		// 1.2.3. Si se ha realizado el sondeo de una Solicitud de Siniestro (APERTURA) o de un Siniestro (CONFIRMACIÓN)
		if (caso.CAS_SEL_Sondeo_Fase__c != null 
				&& caso.Status != Label.SINI_ESTADO_NO_ABIERTO 
				&& caso.Status != Label.CAS_ESTADO_CERRADO){
			system.debug('>>>>Si se ha realizado el sondeo de una Solicitud de Siniestro (APERTURA) o de un Siniestro (CONFIRMACIÓN)');
			system.debug('>>>>caso.CAS_SEL_Sondeo_Fase__c: ' + caso.CAS_SEL_Sondeo_Fase__c);
			system.debug('>>>>caso.Status: ' + caso.Status);
			system.debug('>>>>caso.Type: ' + caso.Type);

			/*// 1.2.3.2. Cambiamos el estado "Cubierto" devuelto por el Sondeo a estado real "En Curso"
			Util_variablesGlobales.estadoVueltaSondeo = caso.Status;
			if (caso.Status != Label.CAS_ESTADO_CERRADO 
					&& caso.Status != Label.SINI_ESTADO_PDTE_DOC_INI 
					&& caso.Status != Label.SINI_ESTADO_NO_ABIERTO){
				caso.Status = Label.CAS_ESTADO_EN_CURSO;
			}*/

			// 1.2.3.3. Blanqueamos el retorno del Sondeo en el Caso
			Util_variablesGlobales.faseVueltaSondeo = caso.CAS_SEL_Sondeo_Fase__c;
			caso.CAS_SEL_Sondeo_Fase__c = null;
		}
	}

	public static Case postSondeo(Case caso, Map<Id, Case> triggerOldMap, Map<Id, Case> mapaHijosPorPadre,
			Map<Id, Account> mapaCuentas){
		// 2.2. Acciones post-sondeo en APERTURA/CONFIRMACIÓN
		// Si se ha realizado el sondeo de una Solicitud de Siniestro (APERTURA) o de un Siniestro (CONFIRMACIÓN)
		// Si la Fecha de Ocurrencia No es Válida: No se genera Siniestro, se actualiza el estado a "No Abierto" desde el WS. Solo aplica en APERTURA
		// Si no: se genera Siniestro (APERTURA)
		Case casoIndemni;
		if (Util_variablesGlobales.faseVueltaSondeo != null 
				&& Util_variablesGlobales.estadoVueltaSondeo != Label.SINI_ESTADO_NO_ABIERTO){

			// Si el estado devuelto por el Sondeo es 'Cubierto' o
			// el Siniestro es Indemnizable y lo hemos cambiado a Pdte. Documentación Inicial:
			if (Util_variablesGlobales.estadoVueltaSondeo == Label.SINI_ESTADO_CUBIERTO 
					|| caso.Status == Label.SINI_ESTADO_PDTE_DOC_INI){

				// 2.3.1. Generar parte Indemnizable de Siniestro Mixto
				// Si el Tipo de Actuación es 'Mixto': el Caso original se queda con la parte Reparable
				// y se debe generar otro Caso para la parte Indemnizable
				if (caso.Type == Label.CAS_TIPO_MIXTO
						&& (mapaHijosPorPadre.get(caso.Id) == null  // Se genera el hijo indemnizable si no tuviera
						|| triggerOldMap.get(caso.Id).Type != Label.CAS_TIPO_MIXTO))  // O, si antes de guardar, el caso no era mixto
				{
					casoIndemni = clonarSiniestro(caso, Label.CAS_ESTADO_EN_CURSO, Label.CAS_TIPO_INDEMNIZABLE, 
							mapaCuentas.get(caso.CAS_LKP_Compania__c));
				} //FIN Si el Tipo de Actuación es "Mixto"
			}//FIN Si el estado devuelto por el Sondeo es 'Cubierto'
		}//FIN IF 
		return casoIndemni; 
	}

	
	public static List<WorkOrder> generarOTsIndemnizables(List<Case> listaCasos){
		// 2.3. Generar las Órdenes de Trabajo Indemnizables (aplica a APERTURA y a CONFIRMACION) y las Órdenes de Trabajo Reparables (solo aplica a CONFIRMACION)
		List<WorkOrder> listaOrdenesTrabajo = new List<WorkOrder>();
		if (Util_variablesGlobales.faseVueltaSondeo != null){
			for (Case caso : listaCasos){
				system.debug('**************** Util_variablesGlobales.faseVueltaSondeo: ' + Util_variablesGlobales.faseVueltaSondeo);
				system.debug('**************** caso.Type: ' + caso.Type);
				system.debug('**************** caso.CAS_SEL_Sondeo_DocsIndemnizable__c: ' + caso.CAS_SEL_Sondeo_DocsIndemnizable__c);
				system.debug('**************** caso.CAS_SEL_Sondeo_Gremios__c: ' + caso.CAS_SEL_Sondeo_Gremios__c);
				system.debug('**************** caso.CAS_CAS_Siniestro_Grave__c: ' + caso.CAS_CAS_Siniestro_Grave__c);

				// 2.2.1. Generar Órdenes de Trabajo reparables a partir de los gremios devueltos en el sondeo (solo aplica en CONFIRMACION si el siniestro no es grave)
				if (Util_variablesGlobales.faseVueltaSondeo == Label.SINI_FASE_CONFIRMACION 
						&& caso.CAS_SEL_Sondeo_Gremios__c != null 
						&& (caso.Type == Label.CAS_TIPO_REPARABLE 
						|| caso.Type == Label.CAS_TIPO_MIXTO) 
						&& !caso.CAS_CAS_Siniestro_Grave__c
						&& (Util_variablesGlobales.estadoVueltaSondeo == Label.SINI_ESTADO_CUBIERTO
						|| caso.Status == Label.SINI_ESTADO_PDTE_DOC_INI))
				{
					for (String gremio : caso.CAS_SEL_Sondeo_Gremios__c.split(';'))
					{
						if(gremio != caso.CAS_SEL_Gremio_Principal__c){
							listaOrdenesTrabajo.add(Util_Orden_Trabajo.crearOrdenDeTrabajo(caso, Label.OTR_ESTADO_INACTIVO, 
									gremio, null, null, false));
						}
					}
				}

				// 2.2.2. Generar Órdenes de Trabajo indemnizables a partir de los documentos devueltos en el sondeo
				else if (caso.Type == Label.CAS_TIPO_INDEMNIZABLE 
						&& caso.CAS_SEL_Sondeo_DocsIndemnizable__c != null){
					system.debug('>>>>listaDocs ' + caso.CAS_SEL_Sondeo_DocsIndemnizable__c.split(';'));
					for (String documento : caso.CAS_SEL_Sondeo_DocsIndemnizable__c.split(';'))
					{
						WorkOrder ordenTrabajoIndem = Util_Orden_Trabajo.crearOrdenDeTrabajo(caso, Label.OTR_ESTADO_INACTIVO, 
								null, null, documento, false);
						listaOrdenesTrabajo.add(ordenTrabajoIndem);
					}
				}
			}//FIN FOR
		}//FIN IF
		return listaOrdenesTrabajo;
	}
	
	

	public static Boolean terceroModificado(Case caso, Case casoOld){
		Boolean retorno = false;
		if(caso.CAS_CAS_Tercero_Causante__c == true){
			if(Trigger.isInsert){
				retorno = true;
			}
			if(Trigger.isUpdate){
				if(casoOld.CAS_CAS_Tercero_Causante__c == false
						||caso.CAS_TXT_Causante_N_Documento__c != casoOld.CAS_TXT_Causante_N_Documento__c
						|| caso.CAS_SEL_Causante_Responsable__c != casoOld.CAS_SEL_Causante_Responsable__c){
					retorno = true;
				}
			}
		}
		return retorno;
	}
	
	/**
	 * Obtiene a partir de un siniestro, el listado de perjudicados asociados
	 *
	 *
	 * @param setIdSini
	 * @return mapa de perjudicados asociadas a siniestros
	 */
	public static Map<Id, Perjudicado_Siniestro__c> queryPerjudicadosSini(Set<Id> setIdSini) {
		Map<Id, Perjudicado_Siniestro__c> mapaPerjudicados=new Map<Id, Perjudicado_Siniestro__c>();
		if(!setIdSini.isEmpty()) {
			for(List<Perjudicado_Siniestro__c> listaPerjudicadosAux:[SELECT Id,Name,PRJ_EMA_Email__c,PRJ_LKP_Siniestro__c,PRJ_SEL_Otros_Danos__c,PRJ_SEL_Perjudicado_Tipo_Documento__c,PRJ_SEL_Provincia__c,PRJ_SEL_Situacion_Danos__c,PRJ_SEL_Tipo_Perjudicado__c,PRJ_TFN_Movil__c,PRJ_TFN_Telefono_1__c,PRJ_TFN_Telefono_Adicional__c,PRJ_TXT_Apellido_1__c,PRJ_TXT_Apellido_2__c,PRJ_TXT_Cbanc_Codigo_Entidad__c,PRJ_TXT_Cbanc_Digito_Control__c,PRJ_TXT_Cbanc_Digito_Control_IBAN__c,PRJ_TXT_Cbanc_Numero__c,PRJ_TXT_Cbanc_Pais__c,PRJ_TXT_Cbanc_Sucursal_Oficina__c,PRJ_TXT_Codigo_Postal__c,PRJ_TXT_Direccion__c,PRJ_TXT_Nombre__c,PRJ_TXT_Pais__c,PRJ_TXT_Perjudicado_N_Documento__c,PRJ_TXT_Poblacion__c
																	 FROM Perjudicado_Siniestro__c
																	 WHERE PRJ_LKP_Siniestro__c IN :setIdSini]) {
			   mapaPerjudicados.putAll(listaPerjudicadosAux);
			}
		}
		return mapaPerjudicados;
	}
	
	/**
	 * Obtiene a partir de un siniestro, el listado de garantías
	 *
	 *
	 * @param setIdSini
	 * @return mapa de garantías asociadas a siniestros
	 */
	public static Map<Id, Garantia_Siniestro__c> queryGarantiasExistentes(Set<Id> setIdSini) {
		Map<Id, Garantia_Siniestro__c> mapaGarantias=new Map<Id, Garantia_Siniestro__c>();
		if(!setIdSini.isEmpty()) {
			for(List<Garantia_Siniestro__c> listaGarantiasAux:[SELECT Id,GSIN_LKP_Garantia__r.GAR_DIV_Importe_Reserva_Media__c,GSIN_FOR_Descripcion_Garantia__c,GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c,GSIN_LKP_Caso__c,GSIN_LKP_Garantia__c
																FROM Garantia_Siniestro__c
																WHERE GSIN_LKP_Caso__c IN :setIdSini]) {
			   mapaGarantias.putAll(listaGarantiasAux);
			}
		}
		return mapaGarantias;
	}
	
	/**
	 * Obtiene a partir de un siniestro, el listado de perjudicados asociados
	 *
	 *
	 * @param setIdSini
	 * @return mapa de perjudicados asociadas a siniestros
	 */
	public static Map<String, Garantia__c> queryGarantiasSini(Set<String> garantias) {
		Map<String, Garantia__c> mapaGarantias=new Map<String, Garantia__c>();
		if(!garantias.isEmpty()) {
			for(List<Garantia__c> listaGarantiasAux:[SELECT Id,GAR_TXT_Codigo_Garantia__c FROM Garantia__c WHERE GAR_TXT_Codigo_Garantia__c IN :garantias]) {
			   for(Garantia__c g:listaGarantiasAux){
				  mapaGarantias.put(g.GAR_TXT_Codigo_Garantia__c,g);
			   }
			}
		}
		return mapaGarantias;
	}
	
	/**
	 * Obtiene a partir de un siniestro, el listado de garantías
	 *
	 *
	 * @param setIdSini IdCase o IdConfirmación
	 * @return mapa de garantías asociadas a siniestros/confirmaciones
	 */
	public static Map<Id, List<Garantia_Siniestro__c>> queryIdCasoGarantiasExistentes(Set<Id> setIdSini) {
		Map<Id, List<Garantia_Siniestro__c>> mapaGarantias=new Map<Id, List<Garantia_Siniestro__c>>();
		Id clave;
		if(!setIdSini.isEmpty()) {
        	for(List<Garantia_Siniestro__c> listaGarantiasAux:[SELECT Id,GSIN_LKP_Garantia__r.GAR_DIV_Importe_Reserva_Media__c,GSIN_FOR_Descripcion_Garantia__c,GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c,GSIN_LKP_Caso__c,GSIN_LKP_Garantia__c
        														FROM Garantia_Siniestro__c
        														WHERE GSIN_LKP_Caso__c IN :setIdSini]) {
         	   for(Garantia_Siniestro__c g : listaGarantiasAux){
     			   mapaGarantias.put(g.GSIN_LKP_Caso__c,new List<Garantia_Siniestro__c>{g});
         	   }
       		}
		}
        return mapaGarantias;
	}
	
	public static Map<Id,Confirmacion__c> queryConfirmacionesPorCasoPadreYRT(String usuario,set<Id> setIdCaso){
		Id RTProf = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(usuario);
		
		return new Map<Id,Confirmacion__c>([SELECT Id,CNF_CAS_Confirmado__c,CNF_CAS_Danos_Perjudicado__c,CNF_CAS_Danos_Propios__c,CNF_CAS_Rechazo_Parcial__c,
											CNF_CAS_Requiere_Perito__c,CNF_CAS_Siniestro_Grave__c,CNF_CAS_Tercero_Causante__c,CNF_EMA_Email__c,CNF_LKP_ParentId__c,
											CNF_LKP_ParentId__r.CAS_LKP_Argumentario_Rechazo__c,CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
											CNF_LKP_ParentId__r.CAS_LKP_Orden_Trabajo_Principal__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__c,
											CNF_LKP_ParentId__r.OwnerId,CNF_LKP_ParentId__r.ParentId,CNF_NUM_Id_Actuacion_SondeoExt__c,CNF_SEL_Causa_Averia__c,
											CNF_SEL_Causante_Compania__c,CNF_SEL_Causante_Provincia__c,CNF_SEL_Causante_Responsable__c,CNF_SEL_Causante_Tipo_Documento__c,
											CNF_SEL_Detalle_averia__c,CNF_SEL_Estado__c,CNF_SEL_Grupo_Causa__c,CNF_SEL_Motivo_Rechazo__c,CNF_SEL_Otros_Danos__c,
											CNF_SEL_Situacion_Danos_Propios__c,CNF_SEL_Sondeo_DocIndemSug__c,CNF_SEL_Sondeo_DocsIndemnizable__c,CNF_SEL_Sondeo_Fase__c,
											CNF_SEL_Sondeo_Gremios__c,CNF_SEL_Tipo__c,CNF_SEL_Tipo_Averia__c,CNF_TFN_Telefono_1__c,CNF_TFN_Telefono_2__c,CNF_TXT_Apellidos__c,
											CNF_TXT_Apellidos2__c,CNF_TXT_Causante_Direccion__c,CNF_TXT_Causante_N_Documento__c,CNF_TXT_Causante_N_exp_Stro__c,
											CNF_TXT_Causante_Poblacion__c,CNF_TXT_Causante_Poliza_R_C__c,CNF_TXT_Codigo_Postal__c,CNF_TXT_Nombre__c,CNF_TXT_S_Garantias__c,
											CNF_TXT_Sondeo_Causa__c,CNF_TXT_Comentario__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,RecordTypeId
											FROM Confirmacion__c 
											WHERE CNF_LKP_ParentId__c IN: setIdCaso AND RecordTypeId =: RTProf]);
	}

	public static Map<Id,Confirmacion__c> queryConfirmacionesPorCasoPadre(Set<Id> setIdCaso){
		return new Map<Id,Confirmacion__c>([SELECT Id,CNF_CAS_Confirmado__c,CNF_CAS_Danos_Perjudicado__c,CNF_CAS_Danos_Propios__c,CNF_CAS_Rechazo_Parcial__c,
											CNF_CAS_Requiere_Perito__c,CNF_CAS_Siniestro_Grave__c,CNF_CAS_Tercero_Causante__c,CNF_EMA_Email__c,CNF_LKP_ParentId__c,
											CNF_LKP_ParentId__r.CAS_LKP_Argumentario_Rechazo__c,CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
											CNF_LKP_ParentId__r.CAS_LKP_Orden_Trabajo_Principal__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__c,
											CNF_LKP_ParentId__r.OwnerId,CNF_LKP_ParentId__r.ParentId,CNF_NUM_Id_Actuacion_SondeoExt__c,CNF_SEL_Causa_Averia__c,
											CNF_SEL_Causante_Compania__c,CNF_SEL_Causante_Provincia__c,CNF_SEL_Causante_Responsable__c,CNF_SEL_Causante_Tipo_Documento__c,
											CNF_SEL_Detalle_averia__c,CNF_SEL_Estado__c,CNF_SEL_Grupo_Causa__c,CNF_SEL_Motivo_Rechazo__c,CNF_SEL_Otros_Danos__c,
											CNF_SEL_Situacion_Danos_Propios__c,CNF_SEL_Sondeo_DocIndemSug__c,CNF_SEL_Sondeo_DocsIndemnizable__c,CNF_SEL_Sondeo_Fase__c,
											CNF_SEL_Sondeo_Gremios__c,CNF_SEL_Tipo__c,CNF_SEL_Tipo_Averia__c,CNF_TFN_Telefono_1__c,CNF_TFN_Telefono_2__c,CNF_TXT_Apellidos__c,
											CNF_TXT_Apellidos2__c,CNF_TXT_Causante_Direccion__c,CNF_TXT_Causante_N_Documento__c,CNF_TXT_Causante_N_exp_Stro__c,
											CNF_TXT_Causante_Poblacion__c,CNF_TXT_Causante_Poliza_R_C__c,CNF_TXT_Comentario__c,CNF_TXT_Codigo_Postal__c,CNF_TXT_Nombre__c,CNF_TXT_S_Garantias__c,
											CNF_TXT_Sondeo_Causa__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,RecordTypeId,
											CNF_LKP_Gestor_Apertura__c, CNF_DAT_Fecha_Apertura__c
											FROM Confirmacion__c 
											WHERE CNF_LKP_ParentId__c IN: setIdCaso]);
	}
	
	public static Map<Id,Confirmacion__c> queryConfirmacionesPorCasoPadreYEstado(Set<Id> setIdCaso,Set<String> setEstados){
		return new Map<Id,Confirmacion__c>([SELECT Id,CNF_CAS_Confirmado__c,CNF_CAS_Danos_Perjudicado__c,CNF_CAS_Danos_Propios__c,CNF_CAS_Rechazo_Parcial__c,
											CNF_CAS_Requiere_Perito__c,CNF_CAS_Siniestro_Grave__c,CNF_CAS_Tercero_Causante__c,CNF_EMA_Email__c,CNF_LKP_ParentId__c,
											CNF_LKP_ParentId__r.CAS_LKP_Argumentario_Rechazo__c,CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
											CNF_LKP_ParentId__r.CAS_LKP_Orden_Trabajo_Principal__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__c,
											CNF_LKP_ParentId__r.OwnerId,CNF_LKP_ParentId__r.ParentId,CNF_NUM_Id_Actuacion_SondeoExt__c,CNF_SEL_Causa_Averia__c,
											CNF_SEL_Causante_Compania__c,CNF_SEL_Causante_Provincia__c,CNF_SEL_Causante_Responsable__c,CNF_SEL_Causante_Tipo_Documento__c,
											CNF_SEL_Detalle_averia__c,CNF_SEL_Estado__c,CNF_SEL_Estado_Confirmacion__c,CNF_SEL_Grupo_Causa__c,CNF_SEL_Motivo_Rechazo__c,CNF_SEL_Otros_Danos__c,
											CNF_SEL_Situacion_Danos_Propios__c,CNF_SEL_Sondeo_DocIndemSug__c,CNF_SEL_Sondeo_DocsIndemnizable__c,CNF_SEL_Sondeo_Fase__c,
											CNF_SEL_Sondeo_Gremios__c,CNF_SEL_Tipo__c,CNF_SEL_Tipo_Averia__c,CNF_TFN_Telefono_1__c,CNF_TFN_Telefono_2__c,CNF_TXT_Apellidos__c,
											CNF_TXT_Apellidos2__c,CNF_TXT_Causante_Direccion__c,CNF_TXT_Causante_N_Documento__c,CNF_TXT_Causante_N_exp_Stro__c,
											CNF_TXT_Causante_Poblacion__c,CNF_TXT_Causante_Poliza_R_C__c,CNF_TXT_Codigo_Postal__c,CNF_TXT_Nombre__c,CNF_TXT_S_Garantias__c,
											CNF_TXT_Sondeo_Causa__c,CNF_TXT_Comentario__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,RecordTypeId
											FROM Confirmacion__c 
											WHERE CNF_LKP_ParentId__c IN: setIdCaso AND CNF_SEL_Estado_Confirmacion__c IN: setEstados]);
	}


	public static Map<Id,Confirmacion__c> queryConfirmacionesPorId(Set<Id> setIdConfirmacion){
		return new Map<Id,Confirmacion__c>([SELECT Id,CNF_CAS_Confirmado__c,CNF_CAS_Danos_Perjudicado__c,CNF_CAS_Danos_Propios__c,CNF_CAS_Rechazo_Parcial__c,
											CNF_CAS_Requiere_Perito__c,CNF_CAS_Siniestro_Grave__c,CNF_CAS_Tercero_Causante__c,CNF_EMA_Email__c,CNF_LKP_ParentId__c,
											CNF_LKP_ParentId__r.CAS_LKP_Argumentario_Rechazo__c,CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
											CNF_LKP_ParentId__r.CAS_LKP_Orden_Trabajo_Principal__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__c,
											CNF_LKP_ParentId__r.OwnerId,CNF_LKP_ParentId__r.ParentId,CNF_NUM_Id_Actuacion_SondeoExt__c,CNF_SEL_Causa_Averia__c,
											CNF_SEL_Causante_Compania__c,CNF_SEL_Causante_Provincia__c,CNF_SEL_Causante_Responsable__c,CNF_SEL_Causante_Tipo_Documento__c,
											CNF_SEL_Detalle_averia__c,CNF_SEL_Estado__c,CNF_SEL_Grupo_Causa__c,CNF_SEL_Motivo_Rechazo__c,CNF_SEL_Otros_Danos__c,
											CNF_SEL_Situacion_Danos_Propios__c,CNF_SEL_Sondeo_DocIndemSug__c,CNF_SEL_Sondeo_DocsIndemnizable__c,CNF_SEL_Sondeo_Fase__c,
											CNF_SEL_Sondeo_Gremios__c,CNF_SEL_Tipo__c,CNF_SEL_Tipo_Averia__c,CNF_TFN_Telefono_1__c,CNF_TFN_Telefono_2__c,CNF_TXT_Apellidos__c,
											CNF_TXT_Apellidos2__c,CNF_TXT_Causante_Direccion__c,CNF_TXT_Causante_N_Documento__c,CNF_TXT_Causante_N_exp_Stro__c,
											CNF_TXT_Causante_Poblacion__c,CNF_TXT_Causante_Poliza_R_C__c,CNF_TXT_Codigo_Postal__c,CNF_TXT_Nombre__c,CNF_TXT_S_Garantias__c,
											CNF_TXT_Sondeo_Causa__c,CNF_TXT_Comentario__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,RecordTypeId,CNF_SEL_Estado_Confirmacion__c
											FROM Confirmacion__c 
											WHERE Id IN: setIdConfirmacion]);
	}


	public static Map<Id,Confirmacion__c> queryConfirmacionesPorCasoYRecordType(Set<Id> setIdCaso,Set<String> setRecordTypeIds){
		return new Map<Id,Confirmacion__c>([SELECT Id,CNF_CAS_Confirmado__c,CNF_CAS_Danos_Perjudicado__c,CNF_CAS_Danos_Propios__c,CNF_CAS_Rechazo_Parcial__c,
											CNF_CAS_Requiere_Perito__c,CNF_CAS_Siniestro_Grave__c,CNF_CAS_Tercero_Causante__c,CNF_EMA_Email__c,CNF_LKP_ParentId__c,
											CNF_LKP_ParentId__r.CAS_LKP_Argumentario_Rechazo__c,CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
											CNF_LKP_ParentId__r.CAS_LKP_Orden_Trabajo_Principal__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__c,
											CNF_LKP_ParentId__r.OwnerId,CNF_LKP_ParentId__r.ParentId,CNF_NUM_Id_Actuacion_SondeoExt__c,CNF_SEL_Causa_Averia__c,
											CNF_SEL_Causante_Compania__c,CNF_SEL_Causante_Provincia__c,CNF_SEL_Causante_Responsable__c,CNF_SEL_Causante_Tipo_Documento__c,
											CNF_SEL_Detalle_averia__c,CNF_SEL_Estado__c,CNF_SEL_Grupo_Causa__c,CNF_SEL_Motivo_Rechazo__c,CNF_SEL_Otros_Danos__c,
											CNF_SEL_Situacion_Danos_Propios__c,CNF_SEL_Sondeo_DocIndemSug__c,CNF_SEL_Sondeo_DocsIndemnizable__c,CNF_SEL_Sondeo_Fase__c,
											CNF_SEL_Sondeo_Gremios__c,CNF_SEL_Tipo__c,CNF_SEL_Tipo_Averia__c,CNF_TFN_Telefono_1__c,CNF_TFN_Telefono_2__c,CNF_TXT_Apellidos__c,
											CNF_TXT_Apellidos2__c,CNF_TXT_Causante_Direccion__c,CNF_TXT_Causante_N_Documento__c,CNF_TXT_Causante_N_exp_Stro__c,
											CNF_TXT_Causante_Poblacion__c,CNF_TXT_Causante_Poliza_R_C__c,CNF_TXT_Codigo_Postal__c,CNF_TXT_Nombre__c,CNF_TXT_S_Garantias__c,
											CNF_TXT_Sondeo_Causa__c,CNF_TXT_Comentario__c,CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,RecordTypeId, RecordType.DeveloperName
											FROM Confirmacion__c 
											WHERE CNF_LKP_ParentId__c IN: setIdCaso AND RecordTypeId IN :setRecordTypeIds]);
	}
		
	/**
	 * Obtiene a partir de una poliza, grupo de causas y fecha minima los siniestros anteriores
	 *
	 *
	 * @param setIdRecordType
	 * @param setGrupoCausa
	 * @param setIdPoliza
	 * @param fechaMinima
	 * @return mapa de casos ya existentes con esa póliza
	 */
	public static Map<Id, Case> querySiniestrosAnteriores(Set<Id> setIdRecordtype, Set<String> setGrupoCausa, Set<Id> setIdPoliza, Date fechaMinima) {
		Map<Id, Case> mapaSiniestros=new Map<Id, Case>();
		if(!setIdRecordType.isEmpty() && !setGrupoCausa.isEmpty() && !setIdPoliza.isEmpty() && fechaMinima!=null) {
			for(List<Case> listaSiniestrosAux:[SELECT Id FROM Case 
											WHERE RecordTypeId IN :setIdRecordType
											AND CAS_SEL_Grupo_Causa__c   IN :setGrupoCausa 
											AND CAS_LKP_PolizaContrato__c IN :setIdPoliza 
											AND day_only(CreatedDate)>= :fechaMinima]) {
				mapaSiniestros.putAll(listaSiniestrosAux);
			}
		}
		return mapaSiniestros;
	}
	
	// Nº49 - 07 Junio 2018 / MDVG
	/**
	 * Crea un mapa relacionando cada Gremio con el límite de servicios permitidos para ese gremio y un tipo de producto concreto
	 * 
	 * @param Case caso
	 * @param Set<String> setGremios gremios sugeridos para el siniestro
	 *
	 * @return mapaLimiteManitasPorGremio mapa de gremio, límite de servicios permitidos
	 */
	public static Map<String, Integer> getMapaLimiteManitasPorGremio(Case caso, Set<String> setGremios){
		Map<String, Integer> mapaLimiteManitasPorGremio = new Map<String, Integer>();
		if(setGremios != null && caso != null){
			List<Tipo_Producto_CIA_Gremio__c> listaTiposProdGremio = new List<Tipo_Producto_CIA_Gremio__c>(
					[SELECT Id,
							TPRG_SEL_Gremio__c, 
							TPRG_NUM_Limite_Servicios__c 
							FROM Tipo_Producto_CIA_Gremio__c 
							WHERE TPRG_LKP_Tipo_Producto_CIA__c = : caso.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__c
							AND TPRG_SEL_Gremio__c IN :setGremios]);
			for(Tipo_Producto_CIA_Gremio__c tipoProdGremio : listaTiposProdGremio){
				if(tipoProdGremio.TPRG_NUM_Limite_Servicios__c != null){
					Integer limiteServicios = Integer.ValueOf(tipoProdGremio.TPRG_NUM_Limite_Servicios__c);
					mapaLimiteManitasPorGremio.put(tipoProdGremio.TPRG_SEL_Gremio__c,limiteServicios);
				}				
			}
		}
		return mapaLimiteManitasPorGremio;
	}// FIN Nº49

	// Nº49 - 07 Junio 2018 / MDVG
	/**
	 * Verifica si el número de siniestros de una póliza supera el límite permitido
	 *
	 * @param Case siniestro
	 *
	 * @return boolean que indica si supera el límite de siniestros tipo manitas permitidos (true) o no (false)
	 */	
	public static Boolean verificarLimiteManitas(Case siniestro){
		Boolean superaLimitePermitido = false;
		if(Util_Caso.getNumeroCasosByPoliza(siniestro) != null){
			Integer numeroSiniestros = Util_Caso.getNumeroCasosByPoliza(siniestro);
			system.debug('Util_Siniestro : verificarLimiteManitas : numeroSiniestros : '+numeroSiniestros);
			system.debug('Util_Siniestro : verificarLimiteManitas : siniestro.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_NUM_Limite_Servicios_Manitas__c : '+siniestro.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_NUM_Limite_Servicios_Manitas__c);
			system.debug('Util_Siniestro : verificarLimiteManitas : ¿Cumple la Condición? : '+(numeroSiniestros >= siniestro.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_NUM_Limite_Servicios_Manitas__c));
			if(numeroSiniestros >= siniestro.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_NUM_Limite_Servicios_Manitas__c){
				system.debug('Util_Siniestro : verificarLimiteManitas : Supera el Límite Permitido');
				superaLimitePermitido = true;
			}
		}
		return superaLimitePermitido;
	}// FIN Nº49
	
	// Nº49 - 07 Junio 2018 / MDVG
	/**
	 * Verifica si el número de servicios de una póliza y un gremio concreto supera el límite permitido
	 *
	 * @param Case siniestro
	 *
	 * @return boolean que indica si supera el límite de servicios permitidos para el gremio (true) o no (false)
	 */	
	public static Boolean verificarLimiteManitasGremio(Case siniestro, String gremio, Integer limitePermitido){
		Boolean superaLimitePermitido = false;
		if(Util_Orden_Trabajo.getNumeroServiciosByPolizaAndGremio(siniestro, gremio) != null){
			Integer numeroServicios = Util_Orden_Trabajo.getNumeroServiciosByPolizaAndGremio(siniestro, gremio);
			system.debug('[amc]numeroServicios' + numeroServicios);
			if(numeroServicios >= limitePermitido){
				superaLimitePermitido = true;
			}
		}
		return superaLimitePermitido;
	}// FIN Nº49// FIN Nº49
	/**
	*	Obtiene el Id de la cuenta del Cliente Contable según la compañía y el tipo
	*
	* @param: id de la compañía
	* @param: tipo de compañía
	*
	**/
	public static String asignarClienteContable(Id cia, String tipo) {
		System.debug('SiniRetornoSondeoExternoController: asignarClienteContable: cia: '+cia);
		System.debug('SiniRetornoSondeoExternoController: asignarClienteContable: tipo: '+tipo);
		Map<Id,Account> clienteContable = new Map<Id,Account>();
		String resultado = '';
		clienteContable = Util_Cuentas.queryCuentasByCIAAndType(new set<Id>{cia}, new set<String>{tipo});
		if(!clienteContable.isEmpty()) {
			system.debug('clienteContable.values siniSondeoExterno'+clienteContable.values().get(0).id);
			resultado=clienteContable.values().get(0).id;
		}
		return resultado;
	}
	/**
	* Obtiene una lista de garantías de una confirmacion clonadas de las garantías de su siniestro correspondiente 
	*
	* @param: idConfirmacion id de la confirmacion
	* @param: idCaso id del siniestro
	*
	* return lista de garantías
	**/
	public static List<Garantia_Siniestro__c> getGarantiasConfirmacion(Id idConfirmacion, Id idCaso){	        
        List<Garantia_Siniestro__c> listaGarantias = Util_Siniestro.queryGarantiasExistentes(new set<Id>{idCaso}).values();
		List<Garantia_Siniestro__c> listaGarantiasConf = new List<Garantia_Siniestro__c>();
		if(listaGarantias != null && !listaGarantias.isEmpty()){
	        for(Garantia_Siniestro__c garantia: listaGarantias){
	        	Garantia_Siniestro__c garantiaConf = new Garantia_Siniestro__c(GSIN_LKP_Garantia__c = garantia.GSIN_LKP_Garantia__c, GSIN_LKP_Caso__c = idConfirmacion);
	        	listaGarantiasConf.add(garantiaConf);
	        }
        }
        return listaGarantiasConf;
	}
}//FIN CLASS SINIESTRO