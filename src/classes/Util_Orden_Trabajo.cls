/**
 * Clase de funciones auxiliares relativas a las Órdenes de Trabajo.
 * 
 * @author EVERIS
 *
 * TO DO : Revisar queries duplicadas de Objetos
 * 
 */
public without sharing class Util_Orden_Trabajo {

	public static final Set<String> SET_ESTADOS_NO_ENCURSO = new Set<String>{
		Label.OTR_ESTADO_INACTIVO,
		Label.OTR_ESTADO_INACTIVO_CLIENTE,
		Label.OTR_ESTADO_ANULADO,
		Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO,
		Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO,
		Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN,
		Label.OTR_ESTADO_REVISADO,
		Label.OTR_ESTADO_CERRADO
	};

	public static final Set<String> SET_ESTADOS_CERRADOS = new Set<String>{
		Label.OTR_ESTADO_ANULADO,
		Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO,
		Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO,
		Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN,
		Label.OTR_ESTADO_REVISADO,
		Label.OTR_ESTADO_CERRADO
	};
	
	public static final Set<String> SET_ESTADOS_PDTE_PROFESIONAL = new Set<String>{
		Label.OTR_ESTADO_EN_ESPERA_CONF_PROF,
		Label.OTR_ESTADO_EN_ESPERA_PROF_AVERIA,
		Label.OTR_ESTADO_EN_ESPERA_PROF_COBRO_FRANQ,
		Label.OTR_ESTADO_EN_ESPERA_PROF_COMPL_MAQUINA,
		Label.OTR_ESTADO_EN_ESPERA_PROF_FECHA_INICIO,
		Label.OTR_ESTADO_EN_ESPERA_PROF_MATERIAL,
		Label.OTR_ESTADO_EN_ESPERA_PROF_MEJORA_TIEMPO,
		Label.OTR_ESTADO_EN_ESPERA_PROF_OTRO_GREMIO,
		Label.OTR_ESTADO_EN_ESPERA_PROF_REC_MAQUINA,
		Label.OTR_ESTADO_EN_ESPERA_PROF_SECADO,
		Label.OTR_ESTADO_EN_ESPERA_PROF_VALORACION,
		Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR,
		Label.OTR_ESTADO_PDTE_ATENCION_PROF
	};

	public static final Set<String> SET_ESTADOS_ANULADOS = new Set<String>{
		Label.OTR_ESTADO_ANULADO,
		Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO
	};

	//Variable que almacena una lista con las políticas de planificación posibles para las órdenas de trabajo
	private static List<FSL__Scheduling_Policy__c> politicasFLS = new List<FSL__Scheduling_Policy__c>();

	//Variable que almacena la lista de metadatos de OT
	private static List<Orden_de_trabajo__mdt> listaMetadatosOt = new List<Orden_de_trabajo__mdt>();


	/*
	 *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
	 *  
	 *  @param Set<Id> setIdOT		- Set de Ids de las órdenes de trabajo a buscar
	 *  
	 *  @return mapaOTs  - Mapa con las órdenes de trabajo resultantes de la Query
	 **/
	public static Map<Id, WorkOrder> queryMapOTById(Set<Id> setIdOT){
		Map<Id, WorkOrder> mapa = new Map<Id, WorkOrder>();
		if(setIdOT != null && !setIdOT.isEmpty()){
			mapa = new Map<Id, WorkOrder>(
				[SELECT Id,
						AccountId,
						Case.Account.CUE_SEL_Idioma__c,
						Case.Account.CUE_SEL_Procedencias_bloq__c,
						Case.Account.CUE_SEL_Tipo_de_red__c,
						Case.Account.CUE_TXT_Establecimiento__c,
						Case.Account.Name,
						Case.AccountId,
						Case.CAS_CAS_Confirmado__c,
						Case.CAS_CAS_Urgente__c,
						Case.CAS_DAT_Fecha_Modificacion_Estado__c,
						Case.CAS_DAT_Recepcion_Producto_b2b2c__c,
						Case.CAS_DIV_Honorarios_Perito__c,
						Case.CAS_LKP_Compania__c,
						Case.CAS_LKP_Compania__r.CUE_CAS_BOManual__c,
						Case.CAS_LKP_Compania__r.CUE_CAS_Requiere_Confirmacion__c,
						Case.CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
						Case.CAS_LKP_Compania__r.CUE_DIV_Limite_Actuacion__c,
						Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
						Case.CAS_LKP_Compania__r.Name,
						Case.CAS_LKP_Perito__c,
						Case.CAS_LKP_PolizaContrato__c,
						Case.CAS_LKP_Procedencia__c,
						Case.CAS_LKP_Procedencia__r.PROC_CAS_No_Requiere_Albaran__c,
						Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Declaracion_Resp__c,
						Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Informe_Cierre_Cita__c,
						Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Pago_Minuta__c,
						Case.CAS_LKP_Procedencia__r.PROC_NUM_Numero_Fotos_Requeridas__c,
						Case.CAS_LKP_Orden_Trabajo_Principal__c,
						Case.CAS_LKP_Recl_Orden_Trabajo__c,
						Case.CAS_LKP_Recl_Orden_Trabajo__r.OTR_LKP_Recurso_Servicio__c,
						Case.CAS_LKP_Recl_Orden_Trabajo__r.OTR_LKP_Recurso_Servicio__r.Relatedrecordid,
						Case.CAS_NUM_Contador_Pdte_Cierre__c,
						Case.CAS_TXT_DirRiesgo_CP__c,
						Case.OwnerId,
						Case.ParentId,
						Case.Recordtype.Name,
						Case.RecordTypeId,
						Case.Status,
						Case.Type,
						CaseId,
						City,
						ContactId,
						Country,
						CreatedDate,
						Description,
						EndDate,
						LastModifiedDate,
						Latitude,
						Longitude,
						OTR_CAS_AplicaRevision__c,
						OTR_CAS_Asignar_Como_Franquiciado__c,
						OTR_CAS_Asignar_Mizad__c,
						OTR_CAS_Asignar_territorio_prim_no_franq__c,
						OTR_CAS_Confianza_en_la_red__c,
						OTR_CAS_Lim_Tramitacion_Expres_Superado__c,
						OTR_CAS_Orden_Trabajo_Facturada__c,
						OTR_CAS_Orden_Trabajo_Liquidada__c,
						OTR_CAS_Partidas_Modificadas_Revision__c,
						OTR_CAS_Servicio_Revisado__c,
						OTR_CAS_Urgente__c,
						OTR_CAS_Vetado_Orden_Trabajo__c,
						OTR_DAT_Fecha_cambio_estado__c,
						OTR_DAT_Fecha_Cierre_servicio__c,
						OTR_DAT_Fecha_Despertar__c,
						OTR_DAT_Fecha_Primera_Cita__c,
						OTR_DAT_Fecha_Recepcion_Albaran__c,
						OTR_DAT_Fecha_revision__c,
						OTR_DAT_Fecha_ultimo_C2C__c,
						OTR_DIV_Importe_diferencia__c,
						OTR_DIV_Importe_nuevo__c,
						OTR_DIV_Importe_original__c,
						OTR_FOR_Codigo_Profesional__c,
						OTR_FOR_Compania__c,
						OTR_FOR_DT__c,
						OTR_FOR_Gremio_Ppal_Caso__c,
						OTR_FOR_Identificador_CIA__c,
						OTR_FOR_Provincia__c,
						OTR_FOR_Tipo_de_Caso__c,
						OTR_LKP_Gestor_revision__c,
						OTR_LKP_Linea_Contrato__c,
						OTR_LKP_Primera_Cita__c,
						OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
						OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
						OTR_LKP_Primera_Cita__r.Status,
						OTR_LKP_Profesional_Programado__c,
						OTR_LKP_Recurso_Servicio__c,
						OTR_LKP_Recurso_Servicio__r.Name,
						OTR_LKP_Recurso_Servicio__r.RelatedRecordId,
						OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,
						OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,
						OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,
						OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,
						OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,
						OTR_NUM_Duracion_de_citas_completadas__c,
						OTR_NUM_Numero_C2C__c,
						OTR_NUM_Numero_de_citas_completadas__c,
						OTR_RES_Facturar_Cliente_AI__c,
						OTR_RES_Facturar_Cliente_DI__c,
						OTR_RES_Facturar_Compania_DI__c,
						OTR_RES_Importe_partidas__c,
						OTR_RES_Liquidar_prof_AI__c,
						OTR_RES_Subtotal_Partidas__c,
						OTR_RES_Total_Facturar_AI__c,
						OTR_RES_Total_Facturar_DI__c,
						OTR_SEL_Bloqueo_Eventos__c,
						OTR_SEL_Categoria_del_Profesional__c,
						OTR_SEL_Eventos_bloqueados_Proc__c,
						OTR_SEL_Gremio__c,
						OTR_SEL_Motivo_Anulacion__c,
						OTR_SEL_Motivo_de_rectificacion__c,
						OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,
						OTR_SEL_Penalizacion__c,
						OTR_SEL_Procedencias_bloqueadas__c,
						OTR_SEL_Rango_Primera_Cita__c,
						OTR_SEL_Subestado__c,
						OTR_SEL_Tipo_de_red_prof__c,
						OTR_SEL_Tipo_Red__c,
						OTR_SEL_Tipologia_de_Servicio__c,
						OTR_TEL_Telefono_C2C__c,
						OTR_TXT_Aviso_Auditoria__c,
						OTR_TXT_Codigo_de_baremo__c,
						OTR_TXT_Comentario_Auditoria__c,
						OTR_TXT_Estado_Anterior__c,
						OTR_TXT_Id_Recurso_Anterior__c,
						OTR_TXT_Identificador_DLC__c,
						OTR_TXT_Num_OrdenTrabajo_HS__c,
						OTR_TXT_Rango_Primera_Cita__c,
						OTR_TXT_rectificacion__c,
						OwnerId,
						ParentWorkOrder.Case.AccountId,
						ParentWorkOrder.OTR_FOR_DT__c,
						ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,
						ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,
						ParentWorkorder.OTR_RES_Subtotal_Partidas__c,
						ParentWorkorder.ParentWorkorderId,
						ParentWorkOrder.WorkOrderNumber,
						ParentWorkOrderId,
						PostalCode,
						RecordType.Name,
						RecordTypeId,
						ServiceTerritory.Name,
						ServiceTerritory.PostalCode,
						ServiceTerritoryId,
						State,
						Status,
						Street,
						WorkOrderNumber,
						WorkType.Name,
						WorkType.TDT_TXT_Identificador__c,
						WorkTypeId,
						(SELECT Status
							FROM ServiceAppointments
							WHERE Status NOT IN :Util_Cita_Servicio.SET_ESTADOS_CERRADOS
							AND Status NOT IN :Util_Cita_Servicio.SET_ESTADOS_ANULADOS),
						(SELECT Id, RelatedRecordId, ServiceResourceId, PreferenceType
							FROM ResourcePreferences)
				 FROM WorkOrder
				 WHERE Id IN :setIdOT]);
		}
		return mapa;
	}


	/**
	 * Devuelve las OTs contando los IDs y filtrando por profesionales y estados.
	 *
	 * @param setProfesionales: conjunto de IDs de profesionales
	 * @param setNotInStatus: conjunto de estados a los que no pertenecen los registros buscados
	 *
	 * @return mapa que contiene las OTs encontradas
	 */
	public static Map<Id,AggregateResult> getOTCountIdByProfesionalAndNotInStatus(Set<Id> setProfesionales, Set<String> setNotInStatus){
		Map<Id,AggregateResult> mapa = new Map<Id,AggregateResult>();
		if(setProfesionales != null && !setProfesionales.isEmpty() && setNotInStatus != null && !setNotInStatus.isEmpty()){
			for(List<AggregateResult> lista:[SELECT count(Id)numWO,OTR_LKP_Recurso_Servicio__c
												FROM WorkOrder 
												WHERE OTR_LKP_Recurso_Servicio__c IN :setProfesionales
												AND Status not IN :setNotInStatus
												GROUP BY OTR_LKP_Recurso_Servicio__c]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las OTs contando los IDs y filtrando por profesionales con fecha de creación de este mes.
	 *
	 * @param setProfesionales: conjunto de IDs de profesionales
	 *
	 * @return mapa que contiene las OTs encontradas
	 */
	public static Map<Id,AggregateResult> getOTCountIdByProfesionalEsteMes(Set<Id> setProfesionales){
		Map<Id,AggregateResult> mapa = new Map<Id,AggregateResult>();
		if(setProfesionales != null && !setProfesionales.isEmpty()){
			for(List<AggregateResult> lista:[SELECT count(Id)numWO,OTR_LKP_Recurso_Servicio__c
												FROM WorkOrder 
												WHERE OTR_LKP_Recurso_Servicio__c IN :setProfesionales
												AND CreatedDate = THIS_MONTH
												GROUP BY OTR_LKP_Recurso_Servicio__c]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las OTs filtradas por los IDs que tengan código de compañía, segmentación de compañía y código postal.
	 *
	 * @param idsOTs: conjunto de IDs de OT
	 *
	 * @return mapa que contiene las OTs encontradas
	 */
	public static Map<Id,WorkOrder> getOTByIdConCodPostalYCompania(Set<Id> idsOTs){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(idsOTs != null && !idsOTs.isEmpty()){
			for(List<WorkOrder> lista:[SELECT Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,ServiceTerritory.PostalCode,OTR_CAS_Urgente__c
										FROM WorkOrder
										WHERE Id IN :idsOTs
										AND Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c != null
										AND ServiceTerritory.PostalCode != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los Casos y el estado.
	 *
	 * @param setIdCase: conjunto de IDs de Caso
	 * @param setStatus: conjunto de estados en los que no debe encontrarse el Servicio
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByCaseAndNotInStatus(Set<Id> setIdCase, Set<String> setStatus){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdCase != null && !setIdCase.isEmpty() && setStatus != null && !setStatus.isEmpty()){
			for(List<WorkOrder> lista:[Select Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c
										from workorder
										where CaseId IN :setIdCase AND Status NOT IN :setStatus AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los Casos y el estado.
	 *
	 * @param setIdCase: conjunto de IDs de Caso
	 * @param setStatus: conjunto de estados en los que no debe encontrarse el Servicio
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByCaseAndNotStatus(Set<Id> setIdCase, Set<String> setStatus){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdCase != null && !setIdCase.isEmpty() && setStatus != null && !setStatus.isEmpty()){
			for(List<WorkOrder> lista:[select id from WorkOrder WHERE CaseId IN :setIdCase  AND Status NOT IN :setStatus]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los WorkOrderNumber.
	 *
	 * @param setWONum: conjunto de WorkOrderNumber's
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByWorkOrderNumber(Set<String> setWONum){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setWONum != null && !setWONum.isEmpty()){
			for(List<WorkOrder> lista:[Select Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c
										from workorder
										where WorkOrderNumber IN :setWONum AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los ParentWorkorderId y RecordTypeId.
	 *
	 * @param setIdParentWO: conjunto de IDs de ParentWorkorderId
	 * @param setIdParentWO: conjunto de RecordTypeId
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByParentWorkorderAndRT(Set<Id> setIdParentWO, Set<Id> setRecordType){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdParentWO != null && !setIdParentWO.isEmpty() && setRecordType != null && !setRecordType.isEmpty()){
			for(List<WorkOrder> lista:[Select Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c
										from workorder
										where ParentWorkorderId IN :setIdParentWO and RecordTypeId IN :setRecordType order by createddate desc]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los ParentWorkorderId.
	 *
	 * @param setIdParentWO: conjunto de IDs de ParentWorkorderId
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByParentWorkorder(Set<Id> setIdParentWO){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdParentWO != null && !setIdParentWO.isEmpty()){
			for(List<WorkOrder> lista:[Select Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c
										from workorder
										where ParentWorkorderId IN :setIdParentWO]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los ParentWorkorderId y los ParenWorkorder.ParentWorkOrderId's.
	 *
	 * @param setIdParentWO: conjunto de IDs de ParentWorkorderId
	 * @param setIdParentParentWO: conjunto de IDs de ParentWorkorder.ParentWorkorderId
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByParentWOOrParentParentWO(Set<Id> setIdParentWO, Set<Id> setIdParentParentWO){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdParentWO != null && !setIdParentWO.isEmpty() && setIdParentParentWO != null && !setIdParentParentWO.isEmpty()){
			for(List<WorkOrder> lista:[Select Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c
										from workorder
										where ParentWorkorderId IN :setIdParentWO OR ParentWorkorder.ParentWorkorderId IN :setIdParentParentWO]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los CaseId, los RecordTypeId y los gremios.
	 *
	 * @param setIdCase: conjunto de IDs de Case
	 * @param setRecordTypeId: conjunto de IDs de RecordType
	 * @param setGremio: conjunto de gremios
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByCaseAndRecordTypeAndGremio(Set<Id> setIdCase, Set<Id> setRecordTypeId, Set<String> setGremio){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdCase != null && !setIdCase.isEmpty() && setRecordTypeId != null && !setRecordTypeId.isEmpty() && setGremio != null && !setGremio.isEmpty()){
			mapa = new Map<Id,WorkOrder>(
				[SELECT Id,
						AccountId,
						Case.Account.CUE_SEL_Idioma__c,
						Case.AccountId,
						Case.CAS_DAT_Fecha_Modificacion_Estado__c,
						Case.CAS_LKP_Compania__c,
						Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
						Case.CAS_LKP_Procedencia__c,
						Case.CAS_NUM_Contador_Pdte_Cierre__c,
						Case.CaseNumber,
						Case.OwnerId,
						Case.RecordTypeId,
						CaseId,
						City,
						Country,
						CreatedDate,
						Description,
						EndDate,
						Latitude,
						Longitude,
						OTR_CAS_AplicaRevision__c,
						OTR_CAS_Asignar_Como_Franquiciado__c,
						OTR_CAS_Asignar_Mizad__c,
						OTR_CAS_Asignar_territorio_prim_no_franq__c,
						OTR_CAS_Lim_Tramitacion_Expres_Superado__c,
						OTR_CAS_Orden_Trabajo_Facturada__c,
						OTR_CAS_Orden_Trabajo_Liquidada__c,
						OTR_CAS_Partidas_Modificadas_Revision__c,
						OTR_CAS_Servicio_Revisado__c,
						OTR_CAS_Urgente__c,
						OTR_DAT_Fecha_cambio_estado__c,
						OTR_DAT_Fecha_Cierre_servicio__c,
						OTR_DAT_Fecha_Despertar__c,
						OTR_DAT_Fecha_Primera_Cita__c,
						OTR_DAT_Fecha_Recepcion_Albaran__c,
						OTR_DAT_Fecha_revision__c,
						OTR_DAT_Fecha_ultimo_C2C__c,
						OTR_DIV_Importe_diferencia__c,
						OTR_DIV_Importe_nuevo__c,
						OTR_DIV_Importe_original__c,
						OTR_FOR_Codigo_Profesional__c,
						OTR_FOR_Compania__c,
						OTR_FOR_DT__c,
						OTR_FOR_Gremio_Ppal_Caso__c,
						OTR_FOR_Identificador_CIA__c,
						OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,
						OTR_FOR_Limite_Actuacion_CIA__c,
						OTR_FOR_Provincia__c,
						OTR_FOR_Tipo_de_Caso__c,
						OTR_LKP_Gestor_revision__c,
						OTR_LKP_Linea_Contrato__c,
						OTR_LKP_Primera_Cita__c,
						OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
						OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
						OTR_LKP_Primera_Cita__r.Status,
						OTR_LKP_Recurso_Servicio__c,
						OTR_LKP_Recurso_Servicio__r.Name,
						OTR_LKP_Recurso_Servicio__r.RelatedRecordId,
						OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,
						OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,
						OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,
						OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,
						OTR_NUM_Numero_C2C__c,
						OTR_RES_Facturar_Cliente_AI__c,
						OTR_RES_Facturar_Cliente_DI__c,
						OTR_RES_Facturar_Compania_DI__c,
						OTR_RES_Importe_partidas__c,
						OTR_RES_Liquidar_prof_AI__c,
						OTR_RES_Subtotal_Partidas__c,
						OTR_RES_Total_Facturar_AI__c,
						OTR_RES_Total_Facturar_DI__c,
						OTR_SEL_Categoria_del_Profesional__c,
						OTR_SEL_Gremio__c,
						OTR_SEL_Motivo_Anulacion__c,
						OTR_SEL_Motivo_de_rectificacion__c,
						OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,
						OTR_SEL_Penalizacion__c,
						OTR_SEL_Rango_Primera_Cita__c,
						OTR_SEL_Subestado__c,
						OTR_SEL_Tipo_Red__c,
						OTR_SEL_Tipologia_de_Servicio__c,
						OTR_TEL_Telefono_C2C__c,
						OTR_TXT_Codigo_de_baremo__c,
						OTR_TXT_Comentario_Auditoria__c,
						OTR_TXT_Estado_Anterior__c,
						OTR_TXT_Identificador_DLC__c,
						OTR_TXT_Num_OrdenTrabajo_HS__c,
						OTR_TXT_Rango_Primera_Cita__c,
						OTR_TXT_rectificacion__c,
						OwnerId,
						ParentWorkOrder.Case.AccountId,
						ParentWorkOrder.OTR_FOR_DT__c,
						ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,
						ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,
						ParentWorkorder.OTR_RES_Subtotal_Partidas__c,
						ParentWorkorder.ParentWorkorderId,
						ParentWorkOrder.WorkOrderNumber,
						ParentWorkOrderId,
						PostalCode,
						RecordType.Name,
						RecordTypeId,
						ServiceTerritory.Name,
						ServiceTerritory.PostalCode,
						ServiceTerritoryId,
						State,
						Status,
						Street,
						WorkOrderNumber,
						WorkType.Name,
						WorkType.TDT_TXT_Identificador__c,
						WorkTypeId
				FROM WorkOrder
				WHERE RecordTypeId IN :setRecordTypeId
				AND CaseId IN :setIdCase
				AND OTR_SEL_Gremio__c IN :setGremio]);
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los CaseId y los RecordTypeId.
	 *
	 * @param setIdCase: conjunto de IDs de Case
	 * @param setRecordTypeId: conjunto de IDs de RecordType
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByCaseAndRecordType(Set<Id> setIdCase, Set<Id> setRecordTypeId){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdCase != null && !setIdCase.isEmpty() && setRecordTypeId != null && !setRecordTypeId.isEmpty()){
			for(List<WorkOrder> lista:[Select Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c
										FROM WorkOrder
										WHERE RecordTypeId IN :setRecordTypeId AND CaseId IN :setIdCase]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por el siguiente filtro: CaseId IN :setIdCase AND RecordTypeId IN :setRecordTypeId AND ((Status NOT IN :setStringNotInStatus AND OTR_DAT_Fecha_Primera_Cita__c != null) OR Status IN :setStringInStatus).
	 *
	 * @param setIdCase: conjunto de IDs de Case
	 * @param setRecordTypeId: conjunto de IDs de RecordType
	 * @param setStringNotInStatus: conjunto de estados que NO pueden tener las órdenes de trabajo
	 * @param setStringInStatus: conjunto de estados que pueden tener las órdenes de trabajo
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByCaseAndRecordTypeAndStatus(Set<Id> setIdCase, Set<Id> setRecordTypeId, Set<String> setStringNotInStatus, Set<String> setStringInStatus){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setIdCase != null && !setIdCase.isEmpty() && setRecordTypeId != null && !setRecordTypeId.isEmpty() && setStringNotInStatus != null && !setStringNotInStatus.isEmpty() && setStringInStatus != null && !setStringInStatus.isEmpty()){
			for(List<WorkOrder> lista:[SELECT Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c
										FROM WorkOrder
										WHERE CaseId IN :setIdCase AND RecordTypeId IN :setRecordTypeId AND ((Status NOT IN :setStringNotInStatus AND OTR_DAT_Fecha_Primera_Cita__c != null) OR Status IN :setStringInStatus)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene los Servicios devueltos por la query filtrando por los estados.
	 *
	 * @param setStatus: conjunto de estados de los Servicios
	 *
	 * @return mapa que contiene los Servicios encontrados
	 */
	public static Map<Id,WorkOrder> getWorkOrderByInStatus(Set<String> setStatus){
		Map<Id,WorkOrder> mapa = new Map<Id,WorkOrder>();
		if(setStatus != null && !setStatus.isEmpty()){
			for(List<WorkOrder> lista:[Select Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,WorkType.TDT_TXT_Identificador__c,ContactId,OTR_CAS_Vetado_Orden_Trabajo__c,LastModifiedDate,Account.CUE_TXT_Establecimiento__c
										from workorder
										where Status IN :setStatus]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Método privado para factorizar el cuerpo SELECT <campos> FROM WorkOrder de los métodos de Query de la OT. Devuelve el cuerpo SELECT y FROM con todos los campos de OT.
	 *
	 * @return cadena con la concatenación de los campos del SELECT y el FROM en las queries de OT
	 */
	private static String getSelectCamposFromOT(){
		String sentenciaOT = 'SELECT Id,';
		sentenciaOT += ' AccountId,';
		sentenciaOT += ' CaseId,';
		sentenciaOT += ' Case.AccountId,';
		sentenciaOT += ' Case.CAS_LKP_Compania__c,';
		sentenciaOT += ' Case.CAS_LKP_Procedencia__c,';
		sentenciaOT += ' Case.CAS_DAT_Fecha_Modificacion_Estado__c,'; 
		sentenciaOT += ' Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,';
		sentenciaOT += ' Case.CAS_NUM_Contador_Pdte_Cierre__c,'; 
		sentenciaOT += ' Case.OwnerId,';
		sentenciaOT += ' Case.RecordTypeId,';
		sentenciaOT += ' City,';
		sentenciaOT += ' Country,';
		sentenciaOT += ' CreatedDate,';
		sentenciaOT += ' Description,';
		sentenciaOT += ' EndDate,';
		sentenciaOT += ' OTR_CAS_Asignar_territorio_prim_no_franq__c,';
		sentenciaOT += ' OTR_CAS_Asignar_Como_Franquiciado__c,';
		sentenciaOT += ' OTR_CAS_Asignar_Mizad__c,';   
		sentenciaOT += ' OTR_CAS_Orden_Trabajo_Facturada__c,';
		sentenciaOT += ' OTR_CAS_Orden_Trabajo_Liquidada__c,';
		sentenciaOT += ' OTR_CAS_Urgente__c,';
		sentenciaOT += ' OTR_CAS_Partidas_Modificadas_Revision__c,';
		sentenciaOT += ' OTR_DAT_Fecha_cambio_estado__c,';
		sentenciaOT += ' OTR_DAT_Fecha_Primera_Cita__c,';
		sentenciaOT += ' OTR_DAT_Fecha_Despertar__c,';
		sentenciaOT += ' OTR_DAT_Fecha_Cierre_servicio__c,';
		sentenciaOT += ' OTR_DAT_Fecha_Recepcion_Albaran__c,';
		sentenciaOT += ' OTR_DAT_Fecha_ultimo_C2C__c,';
		sentenciaOT += ' OTR_DIV_Importe_diferencia__c,';
		sentenciaOT += ' OTR_FOR_Identificador_CIA__c,';
		sentenciaOT += ' OTR_FOR_Codigo_Profesional__c,';
		sentenciaOT += ' OTR_FOR_Compania__c,';
		sentenciaOT += ' OTR_FOR_DT__c,';
		sentenciaOT += ' OTR_FOR_Gremio_Ppal_Caso__c,';
		sentenciaOT += ' OTR_FOR_Limite_Actuacion_CIA__c,';
		sentenciaOT += ' OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,';
		sentenciaOT += ' OTR_FOR_Tipo_de_Caso__c,';
		sentenciaOT += ' OTR_FOR_Provincia__c,';
		sentenciaOT += ' OTR_LKP_Linea_Contrato__c,';
		sentenciaOT += ' OTR_LKP_Primera_Cita__c,';
		sentenciaOT += ' OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,';
		sentenciaOT += ' OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,';
		sentenciaOT += ' OTR_LKP_Primera_Cita__r.Status,';
		sentenciaOT += ' OTR_LKP_Recurso_Servicio__c,';
		sentenciaOT += ' OTR_LKP_Recurso_Servicio__r.Name,';
		sentenciaOT += ' OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,';
		sentenciaOT += ' OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,';
		sentenciaOT += ' OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,';
		sentenciaOT += ' OTR_LKP_Recurso_Servicio__r.RelatedRecordId,';
		sentenciaOT += ' OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,';
		sentenciaOT += ' OTR_NUM_Numero_C2C__c,';
		sentenciaOT += ' OTR_RES_Facturar_Cliente_AI__c,';
		sentenciaOT += ' OTR_RES_Facturar_Cliente_DI__c,';
		sentenciaOT += ' OTR_RES_Facturar_Compania_DI__c,';
		sentenciaOT += ' OTR_RES_Liquidar_prof_AI__c,';
		sentenciaOT += ' OTR_RES_Subtotal_Partidas__c,';
		sentenciaOT += ' OTR_RES_Total_Facturar_AI__c,';
		sentenciaOT += ' OTR_RES_Total_Facturar_DI__c,';
		sentenciaOT += ' OTR_RES_Importe_partidas__c,';
		sentenciaOT += ' OTR_SEL_Gremio__c,';
		sentenciaOT += ' OTR_SEL_Motivo_Anulacion__c,';
		sentenciaOT += ' OTR_SEL_Rango_Primera_Cita__c,';
		sentenciaOT += ' OTR_SEL_Tipo_Red__c,';
		sentenciaOT += ' OTR_SEL_Categoria_del_Profesional__c,';
		sentenciaOT += ' OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,';
		sentenciaOT += ' OTR_SEL_Subestado__c,';
		sentenciaOT += ' OTR_SEL_Motivo_de_rectificacion__c,';
		sentenciaOT += ' OTR_SEL_Penalizacion__c,';
		sentenciaOT += ' OTR_SEL_Bloqueo_Eventos__c,';
		sentenciaOT += ' OTR_TEL_Telefono_C2C__c,';
		sentenciaOT += ' OTR_TXT_Codigo_de_baremo__c,';
		sentenciaOT += ' OTR_TXT_Num_OrdenTrabajo_HS__c,';
		sentenciaOT += ' OTR_TXT_Estado_Anterior__c,';
		sentenciaOT += ' OTR_TXT_Identificador_DLC__c,';
		sentenciaOT += ' OTR_TXT_Rango_Primera_Cita__c,';
		sentenciaOT += ' OTR_TXT_rectificacion__c,';
		sentenciaOT += ' OTR_TXT_Comentario_Auditoria__c,';
		sentenciaOT += ' OTR_CAS_Lim_Tramitacion_Expres_Superado__c,';
		sentenciaOT += ' Latitude,';
		sentenciaOT += ' Longitude,';
		sentenciaOT += ' OwnerId,';
		sentenciaOT += ' ParentWorkOrderId,';
		sentenciaOT += ' ParentWorkOrder.Case.AccountId,';
		sentenciaOT += ' ParentWorkOrder.WorkOrderNumber,';
		sentenciaOT += ' ParentWorkOrder.OTR_FOR_DT__c,';
		sentenciaOT += ' ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,';
		sentenciaOT += ' PostalCode,';
		sentenciaOT += ' RecordType.Name,';
		sentenciaOT += ' RecordTypeId,';
		sentenciaOT += ' ServiceTerritory.Name,';
		sentenciaOT += ' ServiceTerritoryId,';
		sentenciaOT += ' ServiceTerritory.PostalCode,';
		sentenciaOT += ' State,';
		sentenciaOT += ' Status,';
		sentenciaOT += ' Street,';
		sentenciaOT += ' WorkOrderNumber,';
		sentenciaOT += ' WorkType.Name,';
		sentenciaOT += ' WorkTypeId';
		sentenciaOT += ' FROM WorkOrder';
		return sentenciaOT;
	}

	/*
	 *  Devuelve una lista con los resultados de la query construida en funcion de los parámetros
	 *  
	 *  @param Id idOT		- Id del caso a buscar
	 *  @param Id idCaso	   - Id del caso padre
	 *  @param String filtro	 - Otras condiciones del Where
	 *  
	 *  @return listaOTs  - Lista con las órdenes de trabajo resultantes de la Query
	 **/
	public static List<WorkOrder> queryOT(Id idOT, Id idCaso, String filtro)
	{
		List<WorkOrder> listaOTs = new List<WorkOrder>();
		if(!(idOT == null && idCaso == null && filtro == null))
		{
			String sentenciaOT = getSelectCamposFromOT();
			String sentenciaOT_where = ' WHERE ';
			if(idOT != null)
			{
				sentenciaOT_where += 'Id = \'' + idOT + '\'';
			}
			else
			{
				if(idCaso != null)
				{
					sentenciaOT_where += 'CaseId = \'' + idCaso + '\'';
					sentenciaOT_where += ' AND ';
					sentenciaOT_where += 'RecordTypeId != \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) + '\'';
				}
				if(filtro != null)
				{
					if(sentenciaOT_where != ' WHERE ')
					{
						sentenciaOT_where += ' AND ';
					}
					sentenciaOT_where += '(' + filtro + ')';
				}
			}
			sentenciaOT += sentenciaOT_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Orden_Trabajo.queryOT.sentenciaOT: ' + sentenciaOT);
			listaOTs = database.query(sentenciaOT);
		}
		return listaOTs;
	}
	
	/*
	 *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
	 *  
	 *  @param Set<Id> setIdOT		- Set de Ids de las órdenes de trabajo a buscar
	 *  @param Set<Id> setIdCaso	  - Set de Ids de los casos padre
	 *  @param String filtro		  - Otras condiciones del Where
	 *  
	 *  @return mapaOTs  - Mapa con las órdenes de trabajo resultantes de la Query
	 **/
	/*public static Map<Id, WorkOrder> queryOTBySet(Set<Id> setIdOT, Set<Id> SetIdCaso, String filtro){
		Map<Id, WorkOrder> mapaOTs = new Map<Id, WorkOrder>();
		List<WorkOrder> listaOTs = new List<WorkOrder>();
		if ((setIdOT != null && !setIdOT.isEmpty()) || (setIdCaso != null && !setIdCaso.isEmpty()) || filtro != null)
		{
			String sentenciaOT = getSelectCamposFromOT();
			String sentenciaOT_where = ' WHERE ';
			if ((setIdOT != null && !setIdOT.isEmpty()) && (setIdCaso == null || setIdCaso.isEmpty())){
				sentenciaOT_where += 'Id IN :setIdOT';
			} else if ((setIdOT == null || setIdOT.isEmpty()) && (setIdCaso != null && !setIdCaso.isEmpty())){
				sentenciaOT_where += 'CaseId IN :setIdCaso';
			} else if ((setIdOT != null && !setIdOT.isEmpty()) && (setIdCaso != null && !setIdCaso.isEmpty())){
				sentenciaOT_where += '(Id IN :setIdOT';
				sentenciaOT_where += ' OR ';
				sentenciaOT_where += 'CaseId IN :setIdCaso)';
			}
			if (filtro != null) {
				if(sentenciaOT_where != ' WHERE ')
				{
					sentenciaOT_where += ' AND ';
				}
				sentenciaOT_where += '(' + filtro + ')';
			}
			sentenciaOT += sentenciaOT_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Orden_Trabajo.queryOTBySet.sentenciaOT: ' + sentenciaOT);
			listaOTs = database.query(sentenciaOT);
			for (WorkOrder wo: listaOTs){
				mapaOTs.put(wo.Id, wo);
			}
		}
		return mapaOTs;
	}*/

	/*
	 *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
	 *  
	 *  @param Set<Id> setIdCaso		- Set de Ids de los Casos de las órdenes de trabajo a buscar
	 *  
	 *  @return Mapa con las órdenes de trabajo resultantes de la Query
	 **/
	public static Map<Id, WorkOrder> queryMapOTByCase(Set<Id> setIdCaso){
				Map<Id, WorkOrder> mapaOTs = new Map<Id, WorkOrder>();
		if(setIdCaso != null && !setIdCaso.isEmpty()){
			for (List<WorkOrder> listaOTs : [SELECT Id,
											 OTR_LKP_Recurso_Servicio__r.RSE_SEL_Gremio__c,
											 Account.CUE_TXT_Establecimiento__c,
											 AccountId,
											 Case.Account.CUE_SEL_Idioma__c,
											 Case.AccountId,
											 Case.CAS_CAS_Confirmado__c,
											 Case.CAS_CAS_Urgente__c,
											 Case.CAS_DAT_Fecha_Modificacion_Estado__c,
											 Case.CAS_LKP_Compania__c,
											 Case.CAS_LKP_Compania__r.CUE_CAS_Requiere_Confirmacion__c,
											 Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
											 Case.CAS_LKP_Procedencia__c,
											 Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Declaracion_Resp__c,
											 Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Informe_Cierre_Cita__c,
											 Case.CAS_NUM_Contador_Pdte_Cierre__c,
											 Case.OwnerId,
											 Case.Recordtype.Name,
											 Case.RecordTypeId,
											 Case.Type,
											 CaseId,
											 City,
											 ContactId,
											 Country,
											 CreatedDate,
											 Description,
											 EndDate,
											 LastModifiedDate,
											 Latitude,
											 Longitude,
											 OTR_CAS_AplicaRevision__c,
											 OTR_CAS_Asignar_Como_Franquiciado__c,
											 OTR_CAS_Asignar_Mizad__c,
											 OTR_CAS_Asignar_territorio_prim_no_franq__c,
											 OTR_CAS_Confianza_en_la_red__c,
											 OTR_CAS_Lim_Tramitacion_Expres_Superado__c,
											 OTR_CAS_Orden_Trabajo_Facturada__c,
											 OTR_CAS_Orden_Trabajo_Liquidada__c,
											 OTR_CAS_Partidas_Modificadas_Revision__c,
											 OTR_CAS_Servicio_Revisado__c,
											 OTR_CAS_Urgente__c,
											 OTR_CAS_Vetado_Orden_Trabajo__c,
											 OTR_DAT_Fecha_cambio_estado__c,
											 OTR_DAT_Fecha_Cierre_servicio__c,
											 OTR_DAT_Fecha_Despertar__c,
											 OTR_DAT_Fecha_Primera_Cita__c,
											 OTR_DAT_Fecha_Recepcion_Albaran__c,
											 OTR_DAT_Fecha_revision__c,
											 OTR_DAT_Fecha_ultimo_C2C__c,
											 OTR_DIV_Importe_diferencia__c,
											 OTR_DIV_Importe_nuevo__c,
											 OTR_DIV_Importe_original__c,
											 OTR_FOR_Codigo_Profesional__c,
											 OTR_FOR_Compania__c,
											 OTR_FOR_DT__c,
											 OTR_FOR_Gremio_Ppal_Caso__c,
											 OTR_FOR_Identificador_CIA__c,
											 OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,
											 OTR_FOR_Limite_Actuacion_CIA__c,
											 OTR_FOR_Provincia__c,
											 OTR_FOR_Tipo_de_Caso__c,
											 OTR_LKP_Gestor_revision__c,
											 OTR_LKP_Linea_Contrato__c,
											 OTR_LKP_Primera_Cita__c,
											 OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
											 OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
											 OTR_LKP_Primera_Cita__r.Status,
											 OTR_LKP_Profesional_Programado__c,
											 OTR_LKP_Recurso_Servicio__c,
											 OTR_LKP_Recurso_Servicio__r.Name,
											 OTR_LKP_Recurso_Servicio__r.RelatedRecordId,
											 OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,
											 OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,
											 OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,
											 OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,
											 OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,
											 OTR_NUM_Duracion_de_citas_completadas__c,
											 OTR_NUM_Numero_C2C__c,
											 OTR_NUM_Numero_de_citas_completadas__c,
											 OTR_RES_Facturar_Cliente_AI__c,
											 OTR_RES_Facturar_Cliente_DI__c,
											 OTR_RES_Facturar_Compania_DI__c,
											 OTR_RES_Importe_partidas__c,
											 OTR_RES_Liquidar_prof_AI__c,
											 OTR_RES_Subtotal_Partidas__c,
											 OTR_RES_Total_Facturar_AI__c,
											 OTR_RES_Total_Facturar_DI__c,
											 OTR_SEL_Bloqueo_Eventos__c,
											 OTR_SEL_Categoria_del_Profesional__c,
											 OTR_SEL_Gremio__c,
											 OTR_SEL_Motivo_Anulacion__c,
											 OTR_SEL_Motivo_de_rectificacion__c,
											 OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,
											 OTR_SEL_Penalizacion__c,
											 OTR_SEL_Rango_Primera_Cita__c,
											 OTR_SEL_Subestado__c,
											 OTR_SEL_Tipo_Red__c,
											 OTR_SEL_Tipologia_de_Servicio__c,
											 OTR_TEL_Telefono_C2C__c,
											 OTR_TXT_Aviso_Auditoria__c,
											 OTR_TXT_Codigo_de_baremo__c,
											 OTR_TXT_Comentario_Auditoria__c,
											 OTR_TXT_Estado_Anterior__c,
											 OTR_TXT_Identificador_DLC__c,
											 OTR_TXT_Num_OrdenTrabajo_HS__c,
											 OTR_TXT_Rango_Primera_Cita__c,
											 OTR_TXT_rectificacion__c,
											 OwnerId,
											 ParentWorkOrder.Case.AccountId,
											 ParentWorkOrder.OTR_FOR_DT__c,
											 ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,
											 ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,
											 ParentWorkorder.OTR_RES_Subtotal_Partidas__c,
											 ParentWorkorder.ParentWorkorderId,
											 ParentWorkOrder.WorkOrderNumber,
											 ParentWorkOrderId,
											 PostalCode,
											 RecordType.Name,
											 RecordTypeId,
											 ServiceTerritory.Name,
											 ServiceTerritory.PostalCode,
											 ServiceTerritoryId,
											 State,
											 Status,
											 Street,
											 WorkOrderNumber,
											 WorkType.Name,
											 WorkType.TDT_TXT_Identificador__c,
											 WorkTypeId,
											 (SELECT Status FROM ServiceAppointments WHERE Status NOT IN :Util_Cita_Servicio.SET_ESTADOS_CERRADOS and Status NOT IN :Util_Cita_Servicio.SET_ESTADOS_ANULADOS),
													(SELECT Id, RelatedRecordId, ServiceResourceId, PreferenceType FROM ResourcePreferences)
											 FROM WorkOrder
											 WHERE CaseId IN :setIdCaso AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]){
				mapaOTs.putAll(listaOTs);
			}
		}
		return mapaOTs;
	}


	/*
	 *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
	 *  
	 *  @param Set<Id> setIdCaso		- Set de Ids de los Casos de las órdenes de trabajo a buscar
	 *  
	 *  @return Mapa con las órdenes de trabajo resultantes de la Query relacionadas con la Id del caso
	 **/
	public static Map<Id, List<WorkOrder>> queryMapIdCaseOTByCase(Set<Id> setIdCaso){
		Map<Id, List<WorkOrder>> mapaOTs = new Map<Id, List<WorkOrder>>();
		if(setIdCaso != null && !setIdCaso.isEmpty()){
			for (List<WorkOrder> listaOTs : [SELECT Id,WorkOrderNumber,OTR_TEL_Telefono_C2C__c,OTR_DAT_Fecha_Primera_Cita__c,CaseId
											 FROM WorkOrder
											 WHERE CaseId IN :setIdCaso AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]){
				for(WorkOrder wo:listaOTs){
					if(!mapaOTs.containsKey(wo.CaseId)){
						mapaOTs.put(wo.CaseId, new List<WorkOrder>{wo});
					}else{
						mapaOTs.get(wo.CaseId).add(wo);
					}
				}
			}
		}
		return mapaOTs;
	}
		/*
	 *  Devuelve un mapa con los resultados de la query con set de Ids de OT and sets de CaseIds
	 *  
	 *  @param Set<Id> setIdOT		- Set de Ids de las órdenes de trabajo a buscar
	 *  @param Set<Id> setCaseIds  - Set de Ids de caso sobre los que iterar 
	 *
	 *  @return mapaOTs  - Mapa con las órdenes de trabajo resultantes de la Query
	 **/
	public static Map<Id, WorkOrder> queryMapOTByIdOrCaseId(Set<Id> setIdOT,Set<Id> setCaseIds){
				Map<Id, WorkOrder> mapaOTs = new Map<Id, WorkOrder>();
		if((setIdOT != null && !setIdOT.isEmpty()) || (setCaseIds != null && !setCaseIds.isEmpty())){
			for (List<WorkOrder> listaOTs : [SELECT Id,Account.CUE_TXT_Establecimiento__c,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_CAS_Requiere_Confirmacion__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Declaracion_Resp__c,Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Informe_Cierre_Cita__c,Case.CAS_LKP_Recl_Orden_Trabajo__c,Case.CAS_LKP_Recl_Orden_Trabajo__r.OTR_LKP_Recurso_Servicio__c,Case.CAS_LKP_Recl_Orden_Trabajo__r.OTR_LKP_Recurso_Servicio__r.Relatedrecordid,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.Recordtype.Name,Case.RecordTypeId,Case.Type,CaseId,City,ContactId,Country,CreatedDate,Description,EndDate,LastModifiedDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Confianza_en_la_red__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_CAS_Vetado_Orden_Trabajo__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Profesional_Programado__c,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_NUM_Duracion_de_citas_completadas__c,OTR_NUM_Numero_C2C__c,OTR_NUM_Numero_de_citas_completadas__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Bloqueo_Eventos__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Aviso_Auditoria__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkType.TDT_TXT_Identificador__c,WorkTypeId,
													(SELECT Status FROM ServiceAppointments WHERE Status NOT IN :Util_Cita_Servicio.SET_ESTADOS_CERRADOS and Status NOT IN :Util_Cita_Servicio.SET_ESTADOS_ANULADOS),
													(SELECT Id, RelatedRecordId, ServiceResourceId, PreferenceType FROM ResourcePreferences)
											 FROM WorkOrder
											 WHERE (Id IN :setIdOT OR CaseId IN : setCaseIds) AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]){
				mapaOTs.putAll(listaOTs);
			}
		}
		return mapaOTs;
	}
	
	/** 
	 * Devuelve el número de WorkOrder filtrados por id de poliza, caso tipo manitas, caso estado no anulado y gremio.
	 *
	 * @param Case caso
	 * @param String gremio
	 *
	 * @return integer con el número de workorder recogidos
	 */	
	public static Integer getNumeroServiciosByPolizaAndGremio(Case caso, String gremio){
		Integer numServicios = 0;
		if(caso != null && gremio != null){
			List<AggregateResult> listaAgregados = [SELECT count(Id)numero 
													FROM WorkOrder 
													WHERE OTR_SEL_Gremio__c = :gremio
													AND Case.CAS_LKP_PolizaContrato__c = :caso.CAS_LKP_PolizaContrato__c
													AND CaseId != :caso.Id
													AND Case.Status != :Label.CAS_ESTADO_ANULADO
													AND Case.Type = :Label.CAS_TIPO_MANITAS];
			System.debug('[amc]listaAgregados' + listaAgregados );
			numServicios = Integer.valueOf(listaAgregados[0].get('numero'));
		}
		return numServicios;
	} 
	

	/**
	 * Obtiene a partir de un tipo de actuación y un estado de una Orden de Trabajo,
	 * el Tipo de Registro de Orden de Trabajo correspondiente.
	 * 
	 * @param recordTypeId Id del Tipo de Registo actual de la Orden de Trabajo
	 * @param tipoActuacion Tipo de Actuación del Siniestro
	 * @return id del Tipo de Registro de la Orden de Trabajo
	 */
	public static Id obtenerIdTipoDeRegistroOT(Id recordTypeId, String tipoActuacion){
		Id retRecordTypeId = recordTypeId;
		String recordTypeName = null;
		Boolean enRevision = (recordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION));

		if(!enRevision){
			// Orden de Trabajo Reparable -- Valor Por Defecto
			recordTypeName = Label.RT_OT_REPA;
		}
		if(recordTypeName != null){
			retRecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(recordTypeName);
		}
		return retRecordTypeId;
	} // FIN obtenerIdTipoDeRegistroOT


	/**
	 * Crea un comentario nuevo vinculado a una Orden de Trabajo.
	 * 
	 * @param idOrdenTrabajo Id de la Orden de Trabajo
	 * @param comentario Texto del comentario
	 * @return objeto Comentario_Orden_de_Trabajo correspondiente al nuevo comentario
	 */
	public static Comentario_Orden_de_Trabajo__c crearComentarioOrdenTrabajo(Id idOrdenTrabajo, String comentario)
	{
		Comentario_Orden_de_Trabajo__c comentarioOrdenTrabajo = null;
		if(idOrdenTrabajo != null && comentario != null && comentario != '')
		{
			comentarioOrdenTrabajo = new Comentario_Orden_de_Trabajo__c();
			comentarioOrdenTrabajo.COT_LKP_Orden_de_trabajo__c = idOrdenTrabajo;
			comentarioOrdenTrabajo.COT_TXT_Comentario__c = comentario;
		}
		return comentarioOrdenTrabajo;
	} // FIN crearComentarioOrdenTrabajo

	/**
	 * Devuelve los comentarios de una OT.
	 * 
	 * @param idsOTs: IDs de las OTs
	 * @return lista de comentarios de OTs
	 */ 
	public static Map<Id,Comentario_Orden_de_Trabajo__c> getComentariosOT_Old(Set<Id> idsOTs){
		Map<Id,Comentario_Orden_de_Trabajo__c> mapaComentariosOT = new Map<Id,Comentario_Orden_de_Trabajo__c>();
		List<Comentario_Orden_de_Trabajo__c> listaComentariosOTAux = new List<Comentario_Orden_de_Trabajo__c>();
		if(idsOTs != null && (!idsOTs.isEmpty())){
			listaComentariosOTAux = [SELECT Id,
							Name,
							COT_SEL_Tipo__c,
							COT_LKP_Orden_de_trabajo__c,
							COT_TXT_Comentario__c,
							CreatedDate,
							CreatedBy.Name
					 FROM Comentario_Orden_de_Trabajo__c
					 WHERE COT_LKP_Orden_de_trabajo__c IN :idsOTs
					 ORDER BY COT_LKP_Orden_de_trabajo__c, CreatedDate DESC];
			for(Comentario_Orden_de_Trabajo__c com : listaComentariosOTAux){
				mapaComentariosOT.put(com.Id,com);
			}
		}
		return mapaComentariosOT;
	}
	
	/**
	 * Devuelve los comentarios de una OT.
	 * 
	 * @param idsOTs: IDs de las OTs
	 * @return lista de comentarios de OTs
	 */
	public static List<Comentario_Orden_de_Trabajo__c> getComentariosOT(Set<Id> idsOTs){
		List<Comentario_Orden_de_Trabajo__c> lista = new List<Comentario_Orden_de_Trabajo__c>();
		if(idsOTs != null && (!idsOTs.isEmpty())){
			lista = [SELECT Id,
							COT_SEL_Tipo__c,
							Name,
							COT_LKP_Orden_de_trabajo__c,
							COT_TXT_Comentario__c,
							CreatedDate,
							CreatedBy.Name
					 FROM Comentario_Orden_de_Trabajo__c
					 WHERE COT_LKP_Orden_de_trabajo__c IN :idsOTs
					 ORDER BY COT_LKP_Orden_de_trabajo__c, CreatedDate DESC];
		}
		return lista;
	}

	/**
	 * Crea una Orden de Trabajo a partir de un Caso.
	 * 
	 * @param caso Objeto Case del Caso padre
	 * @param estadoOT Estado inicial de la nueva Orden de Trabajo
	 * @param gremio Gremio de la nueva Orden de Trabajo
	 * @param idTipoTrabajo Id del Tipo de Trabajo de la nueva Orden de Trabajo
	 * @param tipoDocumentoIndem Tipo de Documento Indemnizable de la nueva Orden de Trabajo
	 * @param urgente True si la nueva Orden de Trabajo es urgente
	 * @return objeto WorkOrder creado
	 */
	public static WorkOrder crearOrdenDeTrabajo(Case caso, String estadoOT, String gremio,
			Id idTipoTrabajo, String tipoDocumentoIndem,
			Boolean urgente){
		system.debug('***************** crearOrdenDeTrabajo_case: ' + caso);
		WorkOrder ordenTrabajo = new WorkOrder();
		ordenTrabajo.CaseId = caso.Id;
		ordenTrabajo.WorkTypeId = idTipoTrabajo;
		ordenTrabajo.OTR_SEL_Gremio__c = gremio;
		ordenTrabajo.OTR_CAS_Urgente__c = urgente;
		if(estadoOT != null){
			ordenTrabajo.Status = estadoOT;
		}
		return ordenTrabajo;
	} // FIN crearOrdenDeTrabajo

	/**
	 * Valida si se puede reservar la primera cita de una Orden de Trabajo:
	 * - Condición1: El Caso tiene un cliente vinculado
	 * - Condición2: La Orden de Trabajo no está anulada
	 * - Condición3: La primera cita de la Orden de Trabajo no ha sido reservada
	 * 
	 * @param ordenTrabajo Objeto de la Orden de Trabajo
	 * @return error mensaje de error con la condición que no permite reservar la primera cita
	 */
	public static String permiteReservaPrimeraCita(WorkOrder ordenTrabajo){
		String ret = Label.ERROR_RESERVACITA;
		if(ordenTrabajo == null){
			ret += ' ' + Label.ERROR_RESERVACITA_OTNULA;
		}
		// Condición1: El Caso tiene un cliente vinculado
		else if(ordenTrabajo.Case.AccountId == null){
			ret += ' ' + Label.ERROR_RESERVACITA_CLIENTE;
		}
		// Condición2: La Orden de Trabajo no está anulada
		else if(ordenTrabajo.Status == Label.OTR_ESTADO_ANULADO 
				|| ordenTrabajo.Status == Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO){
			ret += ' ' + Label.ERROR_RESERVACITA_OTANULADA;
		}
		// Condición3: La primera cita de la Orden de Trabajo no ha sido reservada
		else if(!Test.isRunningTest() && ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c != null){
			ret += ' ' + Label.ERROR_RESERVACITA_CITAEXIST;
		}
		else {
			ret = null;
		}
		return ret;
	}

	/**
	 * Valida si se puede cerrar una Orden de Trabajo:
	 * - Condición1: La Orden de Trabajo está en curso
	 * - Condición2: Todas las citas están completadas o anuladas (Aplica a Gestor y Prof)
	 * - Condición3a: Si el caso no es reclamación, existe alguna partida aceptada (Aplica a Gestor y Prof)
	 * - Condición3b: Si el caso es reclamación, no necesita tener partidas, pero todas tienen que tener imputación (Aplica a Gestor y Prof)
	 * - Condición4: El Albarán tiene que estar generado si lo requiere la Procedencia (Solo aplica a Prof)
	 * - Condición5: Deben de adjuntarse 3 fotografías si lo requiere la Procedencia (Solo aplica a Prof)
	 * - Condición6: Debe informarse el importe de la minuta al Perito si hay perito asignado y lo requiere la Procedencia (Aplica a Gestor y Prof, cuando es profesional se genera una tarea al gestor)
	 * 
	 * @param ordenTrabajo Objeto de la Orden de Trabajo
	 * @param esProfesional Indica si el usuario es un Profesional
	 * @param ultimoAlbaran Documento de ultimo albarán generado
	 * @param todoCerrado Documento de ultimo albarán generado
	 * @return error mensaje de error con la condición que no permite cerrar la Orden de Trabajo
	 */
	public static String permiteCerrarOrdenTrabajo(WorkOrder ordenTrabajo, Boolean esProfesional, ContentVersion ultimoAlbaran, Boolean todoCerrado){
		String ret = null;
		String errorMsg = Label.ERROR_CERRAR_OT;
		Boolean esReclamacion = (ordenTrabajo.Case.RecordtypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION));
		if(ordenTrabajo == null){
			errorMsg += ' ' + Label.ERROR_RESERVACITA_OTNULA;
		}
		// Condición1: La Orden de Trabajo está en curso
		else if(SET_ESTADOS_NO_ENCURSO.contains(ordenTrabajo.Status) ||
			ordenTrabajo.Status == Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL ||
			ordenTrabajo.Status == Label.OTR_ESTADO_PDTE_ATENCION_PROF ||
			ordenTrabajo.Status == Label.OTR_ESTADO_ANULADO_POR_PROF){
			errorMsg += ' ' + Label.ERROR_CERRAR_OT_ENCURSO;
		}
		else {
			// Condición2: Todas las citas están completadas o anuladas
			if(!Util_Cita_Servicio.getListCitasOTsNotInStatus(ordenTrabajo.Id, Util_Cita_Servicio.SET_ESTADOS_CERRADOS).isEmpty()){
				errorMsg += ' ' + Label.ERROR_CERRAR_OT_CITASABIERTAS;
			}
			else {
				Boolean partidasAceptadas = false;
				Boolean partidasImputadas = true;
				List<WorkorderLineItem> partidas = getListaPartidasOT(ordenTrabajo.Id, true);
				//if(!esReclamacion){
					// Condición3a: Si el caso no es reclamación, existe alguna partida aceptada
					for(WorkOrderLineItem woli : partidas){
						if(Util_Partida.SET_ESTADOS_ACEPTADOS.contains(woli.Status)){
							partidasAceptadas = true;
							break;
						}
					}
				/*} else {
					// Condición3b: Si el caso es reclamación, no necesita tener partidas, pero todas tienen que tener imputación
					for(WorkOrderLineItem woli : partidas){
						if((woli.PAR_DIV_Importe_a_Imputar_prof1__c == null || woli.PAR_DIV_Importe_a_Imputar_prof1__c == 0)
							&& (woli.PAR_DIV_Importe_a_Imputar_prof2__c == null || woli.PAR_DIV_Importe_a_Imputar_prof2__c == 0)
							&& (woli.PAR_DIV_Importe_a_Imputar_prof3__c == null || woli.PAR_DIV_Importe_a_Imputar_prof3__c == 0)
							&& (woli.PAR_DIV_Importe_a_Imputar_gestor1__c == null || woli.PAR_DIV_Importe_a_Imputar_gestor1__c == 0)
							&& (woli.PAR_DIV_Importe_a_Imputar_gestor2__c == null || woli.PAR_DIV_Importe_a_Imputar_gestor2__c == 0)
							&& (woli.PAR_DIV_Importe_a_Imputar_gestor3__c == null || woli.PAR_DIV_Importe_a_Imputar_gestor3__c == 0)
							&& woli.PAR_LKP_Imputar_a_prof1__c == null
							&& woli.PAR_LKP_Imputar_a_prof2__c == null
							&& woli.PAR_LKP_Imputar_a_prof3__c == null
							&& woli.PAR_LKP_Imputar_a_gestor1__c == null
							&& woli.PAR_LKP_Imputar_a_gestor2__c == null
							&& woli.PAR_LKP_Imputar_a_gestor3__c == null){
								
							partidasImputadas = false;
							break;
						}
					}
				}*/
				if(!esReclamacion && !partidasAceptadas){
					errorMsg += ' ' + Label.ERROR_CERRAR_OT_PARTIDAS;
				//} else if(esReclamacion && !partidasImputadas){
				//  errorMsg += ' ' + 'Existen partidas sin imputar';
				}
				// Condición4: El Albarán tiene que estar generado si lo requiere la Procedencia
				else if(esProfesional && (!ordenTrabajo.Case.CAS_LKP_Procedencia__r.PROC_CAS_No_Requiere_Albaran__c) &&
						ultimoAlbaran == null){
					errorMsg += ' ' + Label.ERROR_CERRAR_OT_ALBARAN;	
				}
				// Condición5: Deben de adjuntarse 3 fotografías si lo requiere la Procedencia
				else if(esProfesional && ordenTrabajo.Case.CAS_LKP_Procedencia__r.PROC_NUM_Numero_Fotos_Requeridas__c != null &&
					getListaImagenesOT(ordenTrabajo.Id).size() < ordenTrabajo.Case.CAS_LKP_Procedencia__r.PROC_NUM_Numero_Fotos_Requeridas__c){
					errorMsg += ' ' + Label.ERROR_CERRAR_OT_FOTOS;
					errorMsg += ' Adjuntadas ' + getListaImagenesOT(ordenTrabajo.Id).size() + ' de ' + ordenTrabajo.Case.CAS_LKP_Procedencia__r.PROC_NUM_Numero_Fotos_Requeridas__c + '.';
				}
				
				// Condición6: Debe informarse el importe de la minuta al Perito si hay perito asignado y lo requiere la Procedencia
				else if(todoCerrado && ordenTrabajo.Case.CAS_LKP_Perito__c != null &&
						ordenTrabajo.Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Pago_Minuta__c && ordenTrabajo.Case.CAS_DIV_Honorarios_Perito__c == null){
					if(esProfesional) {
						insert Util_tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_PAGO_MINUTA_PERITO, Label.TAR_ESTADO_EN_CURSO,
													null, ordenTrabajo.Case.OwnerId, ordenTrabajo.Case.Id, ordenTrabajo.Case.AccountId);
					}
					errorMsg += ' ' + Label.ERROR_REQUIERE_MINUTA;
				}
			}
		}
		if(errorMsg != Label.ERROR_CERRAR_OT){
			ret = errorMsg;
		}
		return ret;
	}


	public static Map<Id, WorkOrder> ordenesTrabajoDePartidas(List<WorkOrderLineItem> listaPartidasOT){
		Map<Id, WorkOrder> mapaOrdenesTrabajo = new Map<Id, WorkOrder>();
		if(listaPartidasOT != null){
			Set<Id> setIdWO = new set<Id>();
			for(WorkOrderLineItem woli: listaPartidasOT){
				setIdWO.add(woli.WorkOrderId);
			}
			/*mapaOrdenesTrabajo = new Map<Id, WorkOrder>([
														 SELECT  CaseId, OTR_RES_Subtotal_Partidas__c, OTR_FOR_Limite_Actuacion_CIA__c, 
														 OTR_FOR_Limite_Graves_CIA__c, OTR_SEL_Gremio__c, OwnerId, OTR_LKP_Recurso_Servicio__c, WorkOrderNumber,OTR_FOR_Compania__c,
														 Status,RecordTypeId,OTR_TXT_Codigo_de_baremo__c, Case.RecordtypeId, OTR_RES_Facturar_Compania_DI__c, OTR_RES_Facturar_Cliente_DI__c,
														 Case.CAS_LKP_Compania__c
														 FROM	WorkOrder 
														 WHERE   Id in : setIdWO]);*/
			 mapaOrdenesTrabajo = new Map<Id, WorkOrder>();
			 mapaOrdenesTrabajo = queryMapOTById(setIdWO);
		}
		return mapaOrdenesTrabajo;
	}


	public static void crearOTparaCaso(List<Case> triggerNew, Map<Id,Case> triggerOldMap, Map<Id, WorkOrder> mapaOTs){
		if(triggerNew != null){
			Id idRecl = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
			Map<Id, Case> mapaOtCasos = new Map<Id,Case>();
			List<WorkOrder>listaOtUpt = new List<WorkOrder>();
			List<Task> tareasDurmientes = new List<Task>();
			for(Case caso :triggerNew){
				if(caso.RecordTypeId == idRecl 
						&& caso.CAS_SEL_Requiere_profesional__c == '01'
						//&& caso.CAS_LKP_Recl_Orden_Trabajo__c != null
						&& (triggerOldMap == null 
						|| triggerOldMap.get(caso.Id).CAS_SEL_Requiere_profesional__c != caso.CAS_SEL_Requiere_profesional__c
						|| triggerOldMap.get(caso.Id).recordTypeId != caso.recordTypeId)){
					//WorkOrder otMapa = mapaOTs.get(caso.CAS_LKP_Recl_Orden_Trabajo__c);
					//if(otMapa != null){
						//String gremio = otMapa.OTR_SEL_Gremio__c;
						//if(!String.isBlank(caso.CAS_SEL_Gremio_Principal__c))
						system.debug('---------elGremio: '+caso.CAS_SEL_Gremio_Principal__c);
							String gremio = caso.CAS_SEL_Gremio_Principal__c;
						WorkOrder ot = Util_Orden_Trabajo.crearOrdenDeTrabajo(caso, Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL,
								gremio, null, null, caso.CAS_CAS_Solicitud_Urgente__c);


						//Se crea tarea al gestor si el caso está marcado como solicitud urgente
						//TODO: definir parámetros tarea
						if(caso.CAS_CAS_Solicitud_Urgente__c){
							Task tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN,'Solicitud de reclamación urgente',Label.TAR_ESTADO_EN_CURSO,null,caso.OwnerId,caso.Id,caso.AccountId);
						}

						listaOtUpt.add(ot);
					//}
				}
			}
			insert listaOtUpt;
			if(!tareasDurmientes.isEmpty())
				insert(tareasDurmientes);
			// Actualizar mapaOTs
			for(WorkOrder ot : listaOtUpt){
				mapaOTs.put(ot.Id, ot);
			}
		}
	}


	public static void avisoModificacionPartidas(Set<Id> ordenes){
		List<WorkOrder> wos = queryMapOTById(ordenes).values();
		//List<WorkOrder> wos = [Select id,OTR_LKP_Recurso_Servicio__c,WorkOrderNumber from workOrder where id in:ordenes AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)];
		avisoModificacionPartidas(wos);
	}


	public static void avisoModificacionPartidas(List<WorkOrder> ordenes){

		Set<Id> profesionalRecurso = new Set<Id>();
		Set<Id> woSinProfesional = new Set<Id>();
		Map<Id,Id> profesionalPorWo = new Map<Id,Id>();
		for(WorkOrder wo: ordenes){
			if(wo.OTR_LKP_Recurso_Servicio__c != null){
				profesionalRecurso.add(wo.OTR_LKP_Recurso_Servicio__c);
				profesionalPorWo.put(wo.Id,wo.OTR_LKP_Recurso_Servicio__c);
			}else
				woSinProfesional.add(wo.Id);
		}

		if(!woSinProfesional.isEmpty()){
			List<AssignedResource> recursos = Util_Service_Resource.getMapAssignedResourcesByWO(woSinProfesional).values();
			//List<AssignedResource> recursos = [Select ServiceResourceId, ServiceAppointment.ParentRecordId from AssignedResource where ServiceAppointment.ParentRecordId in :woSinProfesional];
			for(AssignedResource res: recursos){
				profesionalRecurso.add(res.ServiceResourceId);
				profesionalPorWo.put(res.ServiceAppointment.ParentRecordId,res.ServiceResourceId);
			}
		}

		List<ServiceResource> recList = Util_Service_Resource.queryMapSRByRsIds(profesionalRecurso).values();
		//List<ServiceResource> recList = [Select id, RelatedRecordId from ServiceResource where id in :profesionalRecurso];
		Map<Id,Id> profPorRecurso = new Map<Id,Id>();
		for(ServiceResource rec: recList){
			profPorRecurso.put(rec.Id,rec.RelatedRecordId); 
		}

		Map<String,String> cuerpoCorreoPorWOProfesional = new Map<String,String>();
		for(WorkOrder wo: ordenes){
			Id profesional = profPorRecurso.get(profesionalPorWo.get(wo.Id));
			String cuerpoCorreo = '';

			cuerpoCorreo = '<p>Estimado colaborador,</p><p>Se ha procedido a la revisión de su albarán tras realizar las siguientes modificaciones:</p>';

			cuerpoCorreo += '<p>Motivo de rectificación: '+wo.OTR_SEL_Motivo_de_rectificacion__c+'</p><p>Texto ampliado: '+wo.OTR_TXT_rectificacion__c+'</p>';
			
			cuerpoCorreo += '<p>Para cualquier consulta adicional puede consultar en su aplicativo.</p>';
			cuerpoCorreo += '<p>Un saludo</p>';
			
			cuerpoCorreoPorWOProfesional.put(wo.WorkOrderNumber+';'+profesional,cuerpoCorreo);
		}

			
		//TODO: BULK
		String prefijo = Label.PDF_TIPO_ALBARAN + '%';
		List<Id> adjuntos = new List<Id>();
		List<ContentDocumentLink> albaranes = [Select id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Createddate from ContentDocumentLink where LinkedEntityId = :ordenes[0].Id and ContentDocument.Title like :prefijo order by ContentDocument.LatestPublishedVersion.Createddate desc];
		if(!albaranes.isEmpty())
			adjuntos.add(albaranes[0].ContentDocument.LatestPublishedVersionId);
			
		List<String> ccDirecciones = new List<String>{UserInfo.getUserEmail()};
		
		system.debug('---------antesFor');
		//system.debug('---------cuerpoCorreoPorProfesional: '+cuerpoCorreoPorProfesional);
		for(String woProf: cuerpoCorreoPorWOProfesional.keySet()){
			//Util_Correo_Electronico.enviarMail(prof,'Aviso modificación albarán',cuerpoCorreoPorProfesional.get(prof));
			List<String> claves = woProf.split(';');
			String woNum = claves[0];
			system.debug(woNum + ' ??');
			Id prof = Id.valueOf(claves[1]);
			String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
			Util_Correo_Electronico.enviarSingleEmailSinPlantilla(null, 'Aviso albarán modificado servicio nº '+woNum, cuerpoCorreoPorWOProfesional.get(woProf), 'HTML', prof, ccDirecciones, adjuntos, correoRemitente, null);
		}

	}


	/*
		Cada vez que se inserta/actualiza una Orden de Trabajo se debe setear en la tabla 
		relacionanada de skillsRequirements de la OT la correspondiente a la compañía del caso.
		El metodo recibe del trigger la lista de WorkOrder y devuelve una lista de 
		SkillRequirement apuntando a la OT y a la Skill para insertar
	 */
	public static List<SkillRequirement> insertaCiasEnOrden(List<WorkOrder> listaOrdenTrabajo){
		Set<String> cias = new Set<String>();
		List<SkillRequirement> listaHabilidadesReq = new List<SkillRequirement>();
		Map<Id,Skill> mapaOrdenesTrabajo_Habilidades = new Map<Id,Skill>();
		Map<String,Skill> mapaHabilidades = new Map<String,Skill>();

		for(WorkOrder wo : listaOrdenTrabajo){
			if(wo.OTR_FOR_RTDevName__c == Label.RT_OT_REPA &&
					wo.OTR_FOR_Identificador_CIA__c != null &&
					wo.OTR_FOR_Identificador_CIA__c != ''){
				String ciaBuscar = 'CIA_' + wo.OTR_FOR_Identificador_CIA__c; 
				cias.add(ciaBuscar);
			}
		}

		List<Skill> habilidades= Util_FSL.getSkillBySetDevName(cias).values();
		//List<Skill> habilidades= [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName IN :cias];

		if(!habilidades.isEmpty()){
			for(Skill habilidad : habilidades){
				mapaHabilidades.put(habilidad.DeveloperName, habilidad);
			}
			for(WorkOrder wo : listaOrdenTrabajo){
				if(wo.OTR_FOR_RTDevName__c == Label.RT_OT_REPA &&
						wo.OTR_FOR_Identificador_CIA__c != null &&
						wo.OTR_FOR_Identificador_CIA__c != ''){
					String ciaBuscar = 'CIA_' + wo.OTR_FOR_Identificador_CIA__c;
					SkillRequirement sR = new SkillRequirement();
					Skill hab = mapaHabilidades.get(ciaBuscar);
					if(hab != null){
						sR.SkillId = hab.Id;
						sR.RelatedRecordId = wo.Id;
						listaHabilidadesReq.add(sR);
					}
				}
			}
		}
		return listaHabilidadesReq;
	}

	/**
	 * Devuelve un mapa de Tipos de Trabajo vinculados a un conjunto de Ordenes de Trabajo.
	 * 
	 * @param setIds: Conjunto de Ids de Ordenes de Trabajo
	 * @return mapa de Tipos de Trabajo vinculados a las Ordenes de Trabajo de los Ids
	 */
	public static Map<Id, WorkType> getMapaTiposTrabajo(Set<Id> setIds){
		Map<Id, WorkType> mapa = new Map<Id, WorkType>();
		if(setIds != null && (!setIds.isEmpty())){
			mapa = Util_TipoTrabajo.getWorkTypeById(setIds);
			//mapa = new Map<Id, WorkType>([SELECT Id, Name FROM WorkType WHERE Id IN :setIds]);
		}
		return mapa;
	}

	/**
	 * Devuelve una lista de Partidas de una Orden de Trabajo.
	 * 
	 * @param idOrdenTrabajo: Id de Orden de Trabajo
	 * @param noRechazadas: True para indicar que solo se devuelvan Partidas no rechazadas
	 * @return lista de Partidas de la Orden de Trabajo
	 */
	public static List<WorkOrderLineItem> getListaPartidasOT(Id idOrdenTrabajo, Boolean noRechazadas){
		List<WorkOrderLineItem> lista = new List<WorkOrderLineItem>();
		Set<Id> setIds = new Set<Id>();
		if(idOrdenTrabajo != null){
			setIds.add(idOrdenTrabajo);
		}
		Map<Id, List<WorkOrderLineItem>> mapa = null;
		if(noRechazadas){
			mapa = getMapaPartidasOTs(setIds);
		}
		else {
			mapa = getMapaPartidasOTsFull(setIds);
		}
		if(mapa.get(idOrdenTrabajo) != null){
			lista = mapa.get(idOrdenTrabajo);
		}
		return lista;
	}


	/**
	 * Devuelve un mapa de Ordenes de Trabajo con sus Partidas no rechazadas.
	 * 
	 * @param setIds: Conjunto de Ids de Ordenes de Trabajo
	 * @return mapa de Ordenes de Trabajo con sus Partidas
	 */
	public static Map<Id, List<WorkOrderLineItem>> getMapaPartidasOTs(Set<Id> setIds){
		Map<Id, List<WorkOrderLineItem>> mapa = new Map<Id, List<WorkOrderLineItem>>();
		if(setIds != null && (!setIds.isEmpty())){
			List<WorkOrderLineItem> lista = Util_Partida.queryMapPartidasOTByNotInStatusOT(setIds,Util_Partida.SET_ESTADOS_RECHAZADOS).values();
			/*List<WorkOrderLineItem> lista = new List<WorkOrderLineItem>(
					[SELECT Id,
							Description,
							PAR_DIV_Cargar_Cliente_AI__c,
							PAR_DIV_Cargar_Comp_AI__c,
							PAR_DIV_Facturacion_Total_AI__c,
							PAR_DIV_Facturacion_Total_DI__c,
							PAR_DIV_Importe_a_Imputar_gestor1__c,
							PAR_DIV_Importe_a_Imputar_gestor2__c,
							PAR_DIV_Importe_a_Imputar_gestor3__c,
							PAR_DIV_Importe_a_Imputar_prof1__c,
							PAR_DIV_Importe_a_Imputar_prof2__c,
							PAR_DIV_Importe_a_Imputar_prof3__c,
							PAR_DIV_Importe_a_imputar_Departamento__c,
							PAR_DIV_Liquidar_Prof_AI__c,
							PAR_DIV_Liquidar_Prof_DI__c,
							PAR_DIV_Precio_Unitario_Venta__c,
							PAR_FOR_Cargar_Cliente_DI__c,
							PAR_FOR_Cargar_Comp_DI__c,
							PAR_FOR_Precio_Unitario_Venta_Cli__c,
							PAR_LKP_Imputar_a_gestor1__c,
							PAR_LKP_Imputar_a_gestor2__c,
							PAR_LKP_Imputar_a_gestor3__c,
							PAR_LKP_Imputar_a_prof1__c,
							PAR_LKP_Imputar_a_prof2__c,
							PAR_LKP_Imputar_a_prof3__c,
							PAR_NUM_Unidades__c,
							PAR_POR_Impuesto_Prof__c,
							PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
							PAR_SEL_Departamento_Imputacion__c,
							PAR_TXT_Baremo_Codigo__c,
							PAR_TXT_Detalle_WOLI__c,
							Status,
							WorkOrderId
					 FROM WorkOrderLineItem WHERE WorkOrderId IN :setIds
					 //AND Status != :Label.PAR_ESTADO_RECHAZADA
					 AND Status NOT IN :Util_Partida.SET_ESTADOS_RECHAZADOS
					 ORDER BY WorkOrderId ASC]);*/
			for(WorkOrderLineItem registro : lista){
				List<WorkOrderLineItem> listaAux = mapa.get(registro.WorkOrderId);
				if(listaAux == null){
					listaAux = new List<WorkOrderLineItem>();
				}
				listaAux.add(registro);
				mapa.put(registro.WorkOrderId, listaAux);
			}
		}
		return mapa;
	}
	
	
/**
 * getMapaPartidasOTByWorkOrderId: Devuelve un mapa de Partidas indexadas por id
 * 
 * @param setIds: Conjunto de Ids de Ordenes de Trabajo
 * @return mapa de Partidas 
 */
	public static Map<Id, WorkOrderLineItem> getMapaPartidasOTByWorkOrderId(Set<Id> setIds){
		Map<Id, WorkOrderLineItem> mapa = new Map<Id, WorkOrderLineItem>();
		if(setIds != null && (!setIds.isEmpty())){
			for(List<WorkOrderLineItem> lista :[SELECT Id,
						Description,
						PAR_DIV_Cargar_Cliente_AI__c,
						PAR_DIV_Cargar_Comp_AI__c,
						PAR_DIV_Liquidar_Prof_DI__c,
						PAR_NUM_Altura__c,
						PAR_NUM_Ancho__c,
						PAR_NUM_Unidades__c,
						PAR_TXT_Baremo_Codigo__c,
						PAR_TXT_Baremo_Desc__c,
						PAR_TXT_Detalle_WOLI__c,
						Status,
						WorkOrderId,
						WorkOrder.CaseId
				 FROM WorkOrderLineItem
				 WHERE WorkOrderId IN :setIds]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	
	/**
	 * Devuelve un mapa de Ordenes de Trabajo con todas sus Partidas
	 * 
	 * @param setIds: Conjunto de Ids de Ordenes de Trabajo
	 * @return mapa de Ordenes de Trabajo con sus Partidas
	 */
	public static Map<Id, List<WorkOrderLineItem>> getMapaPartidasOTsFull(Set<Id> setIds){
		Map<Id, List<WorkOrderLineItem>> mapa = new Map<Id, List<WorkOrderLineItem>>();
		if(setIds != null && (!setIds.isEmpty())){
			List<WorkOrderLineItem> lista = Util_Partida.queryMapPartidasOTByWorkOrder(setIds).values();
			/*List<WorkOrderLineItem> lista = new List<WorkOrderLineItem>(
					[SELECT Id,
							Description,
							PAR_DIV_Cargar_Cliente_AI__c,
							PAR_DIV_Cargar_Comp_AI__c,
							PAR_DIV_Facturacion_Total_AI__c,
							PAR_DIV_Facturacion_Total_DI__c,
							PAR_DIV_Importe_a_Imputar_gestor1__c,
							PAR_DIV_Importe_a_Imputar_gestor2__c,
							PAR_DIV_Importe_a_Imputar_gestor3__c,
							PAR_DIV_Importe_a_Imputar_prof1__c,
							PAR_DIV_Importe_a_Imputar_prof2__c,
							PAR_DIV_Importe_a_Imputar_prof3__c,
							PAR_DIV_Liquidar_Prof_AI__c,
							PAR_DIV_Liquidar_Prof_DI__c,
							PAR_DIV_Precio_Unitario_Venta__c,
							PAR_FOR_Cargar_Cliente_DI__c,
							PAR_FOR_Cargar_Comp_DI__c,
							PAR_FOR_Precio_Unitario_Venta_Cli__c,
							PAR_LKP_Imputar_a_gestor1__c,
							PAR_LKP_Imputar_a_gestor2__c,
							PAR_LKP_Imputar_a_gestor3__c,
							PAR_LKP_Imputar_a_prof1__c,
							PAR_LKP_Imputar_a_prof2__c,
							PAR_LKP_Imputar_a_prof3__c,
							PAR_NUM_Unidades__c,
							PAR_POR_Impuesto_Prof__c,
							PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
							PAR_TXT_Baremo_Codigo__c,
							PAR_TXT_Detalle_WOLI__c,
							Status,
							WorkOrderId
					 FROM WorkOrderLineItem WHERE WorkOrderId IN :setIds
					 ORDER BY WorkOrderId ASC]);*/
			for(WorkOrderLineItem registro : lista){
				List<WorkOrderLineItem> listaAux = mapa.get(registro.WorkOrderId);
				if(listaAux == null){
					listaAux = new List<WorkOrderLineItem>();
				}
				listaAux.add(registro);
				mapa.put(registro.WorkOrderId, listaAux);
			}
		}
		return mapa;
	}


	/**
	 * Devuelve el último albarán generado en la última cita de servicio no anulada de una Orden de Trabajo.
	 * 
	 * @param idOrdenTrabajo: Id de la Orden de Trabajo
	 * @return último albarán generado en la última cita de servicio no anulada de una Orden de Trabajo
	 */
	public static ContentVersion getUltimoAlbaranOT(Id idOrdenTrabajo){
		ContentVersion ultimoAlbaran = null;
		String prefijo = Label.PDF_TIPO_ALBARAN + '%';
		if(idOrdenTrabajo != null){
			// Obtener el útlimo albarán asociado a la última Cita de Servicio no anulada
			List<ServiceAppointment> listaCitas = Util_Cita_Servicio.getListCitasOTsNotInStatus(idOrdenTrabajo, Util_Cita_Servicio.SET_ESTADOS_ANULADOS);
			system.debug('>>>>>>>getUltimoAlbaranOT.listaCitas: ' + listaCitas);
			if(!listaCitas.isEmpty()){
				List<ContentVersion> listaAlbaranes = new List<ContentVersion>(
					[SELECT Id,
							FirstPublishLocationId,
							CreatedDate,
							ContentDocumentId
					 FROM ContentVersion
					 WHERE FirstPublishLocationId = :listaCitas.get(0).Id
					 AND Title LIKE :prefijo
					 ORDER BY CreatedDate DESC]);
				system.debug('>>>>>>>getUltimoAlbaranOT.listaAlbaranes CITAS: ' + listaAlbaranes);
				if(!listaAlbaranes.isEmpty()){
					ultimoAlbaran = listaAlbaranes.get(0);
					system.debug('>>>>>>>getUltimoAlbaranOT.ultimoAlbaran CITA: ' + ultimoAlbaran);
				}
				// Obtener el útlimo albarán asociado a la OT
				
				if(ultimoAlbaran != null){
					List<ContentDocumentLink> albaranesOT = [Select Id from ContentDocumentLink where LinkedEntityId = :idOrdenTrabajo and ContentDocument.Title like :prefijo];
					delete albaranesOT;
					ContentDocumentLink albaranOT = new ContentDocumentLink(ContentDocumentId=ultimoAlbaran.ContentDocumentId,LinkedEntityId=idOrdenTrabajo,ShareType='V');			 
					insert albaranOT;
					system.debug('>>>>>>>getUltimoAlbaranOT.ultimoAlbaran ' + ultimoAlbaran + ' insertado en OT: ' + idOrdenTrabajo);
					system.debug('>>>>>>> albaranOT-->'+albaranOT);
				}
			}
		}
		return ultimoAlbaran;
	}


	/**
	 * Devuelve true si el profesional recibido tiene asociado como Skill el Gremio recibido.
	 * 
	 * @param idUsuarioProf: Id de usuario del Profesional
	 * @param codigoGremio: Código del Gremio
	 * @return true si el profesional recibido tiene asociado como Skill el Gremio recibido
	 */
	public static Boolean profesionalTieneGremio(Id idUsuarioProf, String codigoGremio){
		Boolean tieneGremio = false;
		if(idUsuarioProf != null && codigoGremio != null){
			codigoGremio = 'G_' + codigoGremio;
			List<ServiceResourceSkill> lista = new List<ServiceResourceSkill>(Util_Service_Resource.getSRSkillByGremProf(new Set<Id>{idUsuarioProf},new Set<String>{codigoGremio}).values());
					/*[SELECT Id
					 FROM ServiceResourceSkill
					 WHERE ServiceResource.RelatedRecordId = :idUsuarioProf
					 AND Skill.DeveloperName = :codigoGremio]);*/
			tieneGremio = !lista.isEmpty();
		}
		return tieneGremio;
	}


	/**
	 * Carga una lista de selección de estados de la Orden de Trabajo transitables
	 * desde el estado recibido para el perfil de usuario.
	 * 
	 * @param estadoActual: Estado origen para validar transiciones
	 * @param perfilUsuario: Perfil del usuario actual
	 * @param codigoCIA: Código de Compañía
	 *
	 * @return lista de selección de estados de la Orden de Trabajo transitables
	 * desde el estado recibido
	 */
	public static List<SelectOption> cargarListaEstadosSel(String estadoActual, String perfilUsuario, String codigoCIA){
		system.debug('>>>>>>>>>>>>>>>>>>>cargarListaEstadosSel.estadoActual: ' + estadoActual);
		system.debug('>>>>>>>>>>>>>>>>>>>cargarListaEstadosSel.perfilUsuario: ' + perfilUsuario);
		system.debug('>>>>>>>>>>>>>>>>>>>cargarListaEstadosSel.codigoCIA: ' + codigoCIA);
		List<SelectOption> listaEstadosSel = new List<SelectOption>();
		if(estadoActual != null){
			String estadosDisponibles = getConfigEstadosManualesCIA(perfilUsuario, codigoCIA);
			// Procesar la configuración obtenida
			if(estadosDisponibles != ''){
				estadosDisponibles = ';' + estadosDisponibles + ';';
				system.debug('>>>>>>>>>>>>>>>>>>>cargarListaEstadosSel.estadosDisponibles: ' + estadosDisponibles);
				DescribeSObjectResult objeto = Schema.getGlobalDescribe().get('WorkOrder').getDescribe();
				DescribeFieldResult campo = objeto.fields.getMap().get('Status').getDescribe();
				List<SelectOption> listaEstadosSelAux = new List<SelectOption>();
				for(Schema.PicklistEntry valorPicklist : campo.getPicklistValues()){
					String estadoNuevo = valorPicklist.getValue();
					if(estadoNuevo == estadoActual){
						listaEstadosSel.add(new SelectOption(estadoNuevo, valorPicklist.getLabel()));
					}
					else if(estadosDisponibles.contains(';' + estadoNuevo + ';')){
						listaEstadosSelAux.add(new SelectOption(estadoNuevo, valorPicklist.getLabel()));
					}
				}
				listaEstadosSel.addAll(listaEstadosSelAux);
			}
		}
		system.debug('>>>>>>>>>>>>>>>>>>>cargarListaEstadosSel.listaEstadosSel: ' + listaEstadosSel);
		return listaEstadosSel;
	}   


	public static String getConfigEstadosManualesCIA(String perfilUsuario, String codigoCIA){
		String estadosDisponibles = '';
		// Nombre de la configuración en función del perfil del usuario
		String configEstadosManuales = 'EstadosManualesOT_UsuariosInt';
		if(perfilUsuario != null && perfilUsuario == Label.PERFIL_PROFESIONAL){
			configEstadosManuales = 'EstadosManualesOT_Profesional';
		}
		// Nombre de la configuración en función de la CIA
		if(codigoCIA == null){
			codigoCIA = Label.IDE_HOMESERVE;
		}
		// Obtener la configuración específica para la CIA
		String configEstadosManualesCIA = configEstadosManuales + '_' + codigoCIA;
		Configuracion_General__mdt confGeneral = Util_Metadatos.CONFIG_GENERAL.get(configEstadosManualesCIA);
		if(confGeneral == null){
			// Si no existe: Obtener la configuración genérica para la CIA HomeServe
			configEstadosManualesCIA = configEstadosManuales + '_' + Label.IDE_HOMESERVE;
			confGeneral = Util_Metadatos.CONFIG_GENERAL.get(configEstadosManualesCIA);
		}
		if(confGeneral != null && confGeneral.CF_TXT_Valor__c != null){
			estadosDisponibles = ';' + confGeneral.CF_TXT_Valor__c + ';';
		}
		return estadosDisponibles;
	}


	public static List<ContentDocumentLink> getListaImagenesOT(Id idOrdenTrabajo){
		List<ContentDocumentLink> lista = new List<ContentDocumentLink>();
		Set<Id> setIds = new Set<Id>();
		if(idOrdenTrabajo != null){
			setIds.add(idOrdenTrabajo);
		}
		Map<Id, List<ContentDocumentLink>> mapa = getMapaArchivosOT(setIds);
		if(mapa.get(idOrdenTrabajo) != null){
			Configuracion_General__mdt confGeneral = Util_Metadatos.CONFIG_GENERAL.get('ExtensionesArchivoImagen');
			if(confGeneral != null && confGeneral.CF_TXT_Valor__c != null){
				String extensionesImagen = ';' + confGeneral.CF_TXT_Valor__c + ';';
				for(ContentDocumentLink cdl : mapa.get(idOrdenTrabajo)){
					if(extensionesImagen.contains(';' + cdl.ContentDocument.FileType + ';')){
						lista.add(cdl);
					}
				}
			}
		}
		return lista;
	}

	/**
	 * Devuelve un mapa de Órdenes de Trabajo con su lista de archivos adjuntos.
	 * 
	 * @param setIds: conjunto de ids de Órdenes de Trabajo
	 * @return mapa relacionando el Id de cada orden de trabajo con su lista de archivos
	 */
	public static Map<Id, List<ContentDocumentLink>> getMapaArchivosOT(Set<Id> setIds){	 
		Map<Id,List<ContentDocumentLink>> mapa = new Map<Id,List<ContentDocumentLink>>();   
		if(setIds != null && (!setIds.isEmpty())){
			List<ContentdocumentLink> lista = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.FileType
										  FROM ContentDocumentLink
										  WHERE LinkedEntityId IN :setIds];									   
			for(ContentDocumentLink registro : lista){
				List<ContentDocumentLink> listaAux = mapa.get(registro.LinkedEntityId);
				if(listaAux == null){
					listaAux = new List<ContentDocumentLink>();
				}
				listaAux.add(registro);
				mapa.put(registro.LinkedEntityId, listaAux);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve un mapa de Órdenes de Trabajo con su lista de shares manuales.
	 * 
	 * @param setIds: conjunto de ids de Órdenes de Trabajo
	 * @return mapa relacionando el Id de cada orden de trabajo con su lista de shares manuales
	 */
	public static Map<Id, List<WorkOrderShare>> getMapaSharesOT(Set<Id> setIds){		
		Map<Id,List<WorkOrderShare>> mapa = new Map<Id,List<WorkOrderShare>>(); 
		if(setIds != null && (!setIds.isEmpty())){
			List<WorkOrderShare> lista = [SELECT Id, ParentId, UserOrGroupId
										  FROM WorkOrderShare
										  WHERE ParentId IN :setIds
										  AND RowCause = 'Manual'
										  ORDER BY ParentId];										 
			for(WorkOrderShare registro : lista){
				List<WorkOrderShare> listaAux = mapa.get(registro.ParentId);
				if(listaAux == null){
					listaAux = new List<WorkOrderShare>();
				}
				listaAux.add(registro);
				mapa.put(registro.ParentId, listaAux);
			}
		}
		return mapa;
	}
	
	/**
	 * Recalcula la compartición de profesionales para un set de wo y sus citas de servicio.
	 * 
	 * @param setIds: conjunto de ids de wo
	 * 
	 */
	/*public static void recalcularShares(Set<Id> ordenes){
		Map<Id, List<WorkOrderShare>> mapaSharesWO = getMapaSharesOT(ordenes);
		List<AssignedResource> recursos = [Select Id, ServiceResourceId, ServiceResource.RelatedRecordId,ServiceAppointmentId, ServiceAppointment.ParentRecordId from AssignedResource where ServiceAppointMent.ParentRecordId in: ordenes];
		
		Map<Id,Set<Id>> srPorWO = new Map<Id,Set<Id>>();
		for(AssignedResource recurso: recursos){
			Set<Id> srTemp = srPorWO.get(recurso.ServiceAppointment.ParentRecordId);
			if(srTemp == null)
				srTemp = new Set<Id>();
				
			srTemp.add(recurso.ServiceResource.RelatedRecordId);
			srPorWO.put(recurso.ServiceAppointment.ParentRecordId,srTemp);
		}
		
		List<sObject> sharesBorrar = new List<sObject>();
		List<sObject> sharesInsertar = new List<sObject>();
		for(List<WorkOrderShare> listaShare: mapaSharesWO.values()){
			for(WorkOrderShare woSH: listaShare){
				if(woSH.getSObjectType() != Group.getSobjecttype())
					sharesBorrar.addAll(listaShare);
			}
		}
		
		for(Id woId: ordenes){
			Set<Id> srTemp = srPorWO.get(woId);
			if(srTemp != null && !srTemp.isEmpty()){
				for(Id recurso: srTemp){
					sharesInsertar.add(new WorkOrderShare(ParentId=woId,UserOrGroupId=recurso,RowCause='Manual',AccessLevel='Edit'));
				}
			}
		}
		
		delete(sharesBorrar);
		insert(sharesInsertar);
	}*/
	
	public static void recalcularShares(Set<Id> ordenesTrabajo){
		
		List<Workorder> ots = [Select id, CaseId from Workorder where Id in :ordenesTrabajo];
		
		Set<Id> casosID = new Set<Id>();
		for(Workorder ot: ots){
			if(ot.CaseId != null)
				casosId.add(ot.CaseId);
		}
		
		Util_Caso.recalcularShares(casosId);
		
	}
	
	
	public static void insertShares(List<WorkOrder> wos){
		
		system.debug('---here');
		
		List<WorkorderShare> insertarWOS = new List<WorkOrderShare>();
		for(WorkOrder wo: wos){
			system.debug('---wo.OwnerId: '+wo.OwnerId);
			system.debug('---UserInfo.getUserId(): '+UserInfo.getUserId());
			if(wo.OwnerId != UserInfo.getUserId() && UserInfo.getLastName() != 'Data.com Clean'){
				insertarWOS.add(new WorkOrderShare(ParentId=wo.Id,UserOrGroupId=UserInfo.getUserId(),RowCause='Manual',AccessLevel='Edit'));
				system.debug('---bsailrbskjgrbrskj');
			}   
		}
		
		insert insertarWOS;
	}
	
	public static List<Database.saveResult> insertShares(List<WorkorderShare> lista){
		return Database.Insert(lista,false);
	}
	
		
	public static List<Database.saveResult> insertShares(List<ServiceAppointmentShare> lista){
		return Database.Insert(lista,false);
	}
	
	/**
	 * Método que devuelve un mapa que relaciona los gremios con su correspondiente WorkType por defecto.
	 * @return mapa que relaciona los gremios con su correspondiente WorkType por defecto
	 */
	public static Map<String,WorkType> getMapaGremiosTipoTrabajoTextoManual(){
		Map<String,WorkType> mapaGremiosWT = new Map<String,WorkType>();
		List<WorkType> listaWT = [SELECT Id,TDT_SEL_Gremio__c,Name FROM WorkType WHERE Name = :Label.TDT_TEXTO_MANUAL];
		if(!listaWT.isEmpty()){
			for(WorkType wt : listaWT){
				mapaGremiosWT.put(wt.TDT_SEL_Gremio__c,wt);
			}
		}
		else{
			system.debug('No se encontraron tipos de trabajo de texto manual');
		}
		return mapaGremiosWT;
	}
	
	/**
	 * Método que te devuelve un mapa de las órdenes de trabajo asociadas a los casos.
	 *
	 * @param idCasos: conjunto de ids de casos a filtrar
	 * @return Mapa de órdenes de trabajo asociadas a los casos
	 */
	public static Map<Id,List<WorkOrder>> getMapCasosOTRelacionadas(Set<Id> idCasos){
		Map<Id,List<WorkOrder>> mapCasosOT = new Map<Id,List<WorkOrder>>();
		if(idCasos != null && !idCasos.isEmpty()){
			List<WorkOrder> listaWO = [SELECT Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,ContactId,OTR_CAS_Vetado_Orden_Trabajo__c,LastModifiedDate,Account.CUE_TXT_Establecimiento__c,WorkType.TDT_TXT_Identificador__c
										FROM WorkOrder
										WHERE Status != :Label.OTR_ESTADO_ANULADO AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) AND CaseId IN :idCasos];
			for(WorkOrder wo : listaWO){
				List<WorkOrder> listaAux = mapCasosOT.get(wo.CaseId);
				if(listaAux == null){
					listaAux = new List<WorkOrder>();
				}
				
				listaAux.add(wo);
				mapCasosOT.put(wo.CaseId,listaAux);
			}
		}
		return mapCasosOT;
	}

	/**
	 * Método que te devuelve una lista con los skill filtrados por su serviceResource
	 * [A ELIMINAR]
	 * @param ServiceResourceId: id del serviceResource
	 * @return Lista de ServiceResourceSkill
	 */
	public static List<ServiceResourceSkill> getServiceResourceSkillBySR(Id ServiceResourceId){

		List<ServiceResourceSkill> serviceResourceSkillList = new List<ServiceResourceSkill>([SELECT SkillId, Skill.DeveloperName FROM ServiceResourceSkill WHERE ServiceResourceId = :ServiceResourceId]);

		return serviceResourceSkillList;
	}
	
/**
 * Método que te devuelve un mapa con los skill filtrados por su serviceResource
 *
 * @param ServiceResId: id del serviceResource
 * @return Mapa de ServiceResourceSkill
 */
public static Map<Id,ServiceResourceSkill> getMapServiceResourceSkillBySR(Set<Id> ServiceResId){
		Map <Id,ServiceResourceSkill> mapaSkills = new Map <Id,ServiceResourceSkill>();
		if(!ServiceResId.isEmpty() && ServiceResId!=null){
			for(List<ServiceResourceSkill> lista: [SELECT SkillId, Skill.DeveloperName FROM ServiceResourceSkill WHERE ServiceResourceId IN :ServiceResId]){
				mapaSkills.putAll(lista);	   
			}
		}
		return mapaSkills;
}
	
	
	

	/**
	 * Método que te devuelve una lista con los eventos de una wo
	 *
	 * @param woIds: set de ids de wo
	 * @return eventos por id wo
	 */
	public static Map<Id, List<Propuesta_de_evento__c>> pEventosByWO(Set<Id> woIds){
		Map<Id, List<Propuesta_de_evento__c>> resultados = new Map<Id,List<Propuesta_de_evento__c>>();
		if(!woIds.isEmpty() && woIds!=null){
			List<Propuesta_de_evento__c> propEv = Util_Propuesta_de_evento.queryPropEvByWoId(woIds).values();
			for(Propuesta_de_evento__c evt: propEv){
				List<Propuesta_de_evento__c> temp = resultados.get(evt.EV_AB_LKP_Orden_de_Trabajo__c);
				if(temp == null)
					temp = new List<Propuesta_de_Evento__c>();
					
				temp.add(evt);
				resultados.put(evt.EV_AB_LKP_Orden_de_Trabajo__c,temp);
			}
		}
		return resultados;
	}
	
	/**
	 * Método que te devuelve una lista con los abonos de una wo
	 *
	 * @param woIds: set de ids de wo
	 * @return abonos por id wo
	 */
	public static Map<Id, List<Propuesta_de_abono__c>> pAbonosByWO(Set<Id> woIds){
		
		Map<Id, List<Propuesta_de_abono__c>> resultados = new Map<Id,List<Propuesta_de_abono__c>>();
		if(woIds != null && !woIds.isEmpty()) {
			List<Propuesta_de_abono__c> propAb = Util_Propuesta_de_abono.queryPropAbByWo(woIds).values();
			for(Propuesta_de_abono__c ab: propAb){
				List<Propuesta_de_abono__c> temp = resultados.get(ab.AB_LKP_Orden_de_Trabajo__c);
				if(temp == null)
					temp = new List<Propuesta_de_abono__c>();
					
				temp.add(ab);
				resultados.put(ab.AB_LKP_Orden_de_Trabajo__c,temp);
			}
		}
		return resultados;
	}
	
	
	/**
	 * Método que marca los checks facturado/liquidado de workorder usando la lógica de eventos y abonos
	 *
	 * @param woFacturar: set de ids de wo
	 * @param eventosDeWO: map de eventos por workorder
	 * @param abonosDeWO: map de abonos por workorder
	 * @param woUpdate: mapa donde se almacenan las wo a actualizar
	 *
	 * @return wo a actualizar
	 */
	public static Map<Id, Workorder> facturarWOEventosAbonos(Set<Id> woFacturar, Map<Id,List<Propuesta_de_Evento__c>> eventosDeWO, 
															Map<Id,List<Propuesta_de_abono__c>> abonosDeWO, Map<Id,Workorder> woUpdate){
																
		for(Id woId: woFacturar){
			List<Propuesta_de_evento__c> eventosWo = eventosDeWo.get(woId);
			List<Propuesta_de_abono__c> abonosWo = abonosDeWo.get(woId);
			Map<String,Integer> nEventosPorTipo = new Map<String,Integer>{'Pago'=>0,'Cobro'=>0};
			Boolean facturar = true;
			Boolean liquidar = true;
			Boolean todos = true;
			if(eventosWo != null && !eventosWo.isEmpty()){
				for(Propuesta_de_evento__c evt: eventosWo){
					if(nEventosPorTipo.containsKey(evt.EV_AB_SEL_Tipo_de_Evento__c))
						nEventosPorTipo.put(evt.EV_AB_SEL_Tipo_de_Evento__c,nEventosPorTipo.get(evt.EV_AB_SEL_Tipo_de_Evento__c)+1);
						
					if(!evt.EV_AB_CAS_Evento_Ab_Facturado__c && evt.EV_AB_SEL_Tipo_de_Evento__c == 'Cobro'){
						liquidar = false;
						todos = false;
					} else if(!evt.EV_AB_CAS_Evento_Ab_Liquidado__c && evt.EV_AB_SEL_Tipo_de_Evento__c == 'Pago'){
						liquidar = false;
						todos = false;
					}
				}
			}
			
			if(abonosWo != null && !abonosWo.isEmpty()){
				for(Propuesta_de_abono__c ab: abonosWo){
					if(!ab.AB_CAS_Abono_Liquidado__c){
						liquidar = false;
						todos = false;
					}
				}
			}
			
			if((eventosWo == null || eventosWo.isEmpty() || nEventosPorTipo.get('Pago') == 0)
			&& (abonosWo == null || abonosWo.isEmpty())){
				liquidar = false;
			}
			
			if(eventosWo == null || eventosWo.isEmpty() || nEventosPorTipo.get('Cobro') == 0){
				facturar = false;
			}
			
			if((eventosWo == null || eventosWo.isEmpty())
			&& (abonosWo == null || abonosWo.isEmpty())){
				todos = false;	  
			}
			
			if(facturar || liquidar){
				
				WorkOrder wo = woUpdate.get(woId);
				if(wo == null){
					wo = new WorkOrder();
				}
				wo.Id = woId;
				
				if(facturar){
					wo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
				}
				if(liquidar){
					wo.OTR_CAS_Orden_Trabajo_Liquidada__c = true;
				}
				
				if(todos){
					wo.Status = LABEL.OTR_ESTADO_CERRADO;
				}
				
				woUpdate.put(wo.Id,wo);
			}
				
		}										   
		
		return woUpdate;	
	}
	
	

	/**
	 * Método que te devuelve una lista con las políticas de planificación FLS. Solamente se debe calcular una vez en la transacción
	 *
	 * @return lista de Políticas FLS
	 */
	public static List<FSL__Scheduling_Policy__c> getPoliticasFLS(){
		//Si todavía no se han recuperados las políticas de planificación
		if(politicasFLS.isEmpty()){
			politicasFLS=[SELECT Id, Name FROM FSL__Scheduling_Policy__c 
					 WHERE Name = :Label.OT_POLITICA_PROGRAMACION_MIZAD_URGENTE 
					 OR Name = 'Política de Asignación – Geolocalización - Primario'
					 OR Name = 'Política de Asignación – Geolocalización'];
		}
		return politicasFLS;
	}

	/**
	 * Método que te devuelve una lista con los metadatos que cumplen la condición Mizad
	 *
	 * @return lista de metadatos asociados a OT
	 */
	public static List<Orden_de_trabajo__mdt> getMetadatosOt(String configuracion){
		configuracion='%'+configuracion+'%';
		System.debug('[getMetadatosOt] configuracion='+configuracion);
	// Recoge los metadatos que cumplen con esta condición de configuración Mizad
		if(listaMetadatosOt.isEmpty()){
			listaMetadatosOt = [SELECT MTD_OTR_TXT_Codigo_Postal__c, MTD_OTR_SEL_Gremio__c, MTD_OTR_TXT_Suceso__c
					 FROM Orden_de_trabajo__mdt
					 WHERE DeveloperName LIKE :configuracion];
		}
		return listaMetadatosOt;
	}
	
	/**
	 * [PENDIENTE]
	 * 
	 * @param mapaOTs: [PENDIENTE]
	 * @param mapaCitas: [PENDIENTE]
	 * @param mapaCitasActualizar: [PENDIENTE]
	 * 
	 * @return [PENDIENTE]
	 */
	public static Map<Id, ServiceAppointment> heredarDatosOTCita(Map<Id, WorkOrder> mapaOTs, Map<Id, List<ServiceAppointment>> mapaCitas, Map<Id,ServiceAppointment> mapaCitasActualizar){
		//Si se ha cambiado la direccion de alguna WO, actualizar las direcciones de las citas vinculadas a esa WO
		for(List<ServiceAppointment> citas : mapaCitas.values()){
			for(ServiceAppointment sa: citas){
				ServiceAppointment saAct = mapacitasActualizar.get(sa.Id);
				if(saAct == null){
					saAct = new ServiceAppointment(Id=sa.Id);
				}
				if(sa.ParentRecordType == 'WorkOrder'){
					WorkOrder wo = mapaOTs.get(sa.ParentRecordId);
					if(wo != null){
						Boolean actualizarSa = false;
						if(sa.Street != wo.Street){
							saAct.Street = wo.Street;
							actualizarSa = true;
						}
						if(sa.City != wo.City){
							saAct.City = wo.City;
							actualizarSa = true;
						}
						if(sa.State != wo.State){
							saAct.State = wo.State;
							actualizarSa = true;
						}
						if(sa.Country != wo.Country){
							saAct.Country = wo.Country;
							actualizarSa = true;
						}
						if(sa.PostalCode != wo.PostalCode){
							saAct.PostalCode = wo.PostalCode;
							actualizarSa = true;
						}
						if(sa.OwnerId != wo.OwnerId && wo.OwnerId.getSObjectType() != Schema.Group.getSObjectType()){
							saAct.OwnerId = wo.OwnerId;
							actualizarSa = true;
						}
						if(actualizarSa){
							mapaCitasActualizar.put(saAct.Id, saAct);
						}
					}
				}		   
			}
		}
		return mapaCitasActualizar;
	}

	
	/**
	 *  Cambia el estado de las OTs de un caso
	 */
	public static void cambiarEstadoOTsCaso(List<Case> listaCaso, String estado){
		if(listaCaso != null && estado != null){
			Set <Id> idCasos = new Set<Id>();
			for(Case caso :listaCaso){
				if(caso.Id != null){
					idCasos.add(caso.Id);
				}
			}
			List<WorkOrder> listaOTsCaso = new List<WorkOrder>(
					[SELECT Status
					 FROM WorkOrder
					 WHERE CaseId IN :idCasos
					 AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]);
			List<WorkOrder> listaOTsActualizar = new List<WorkOrder>();
			for(WorkOrder ot : listaOTsCaso){
				if(!Util_Orden_Trabajo.SET_ESTADOS_NO_ENCURSO.contains(ot.Status) &&
						ot.Status != estado){
					ot.Status = estado;
					listaOTsActualizar.add(ot);
				}
			}
			update listaOTsActualizar;
		}
	}


	/**
	 * Calcula si se supera el límite de actuacion de la CIA
	 * NO APLICA: SE CALCULA EN EL TRIGGER HANDLER DE ORDEN DE TRABAJO
	 */
	public static Boolean superaLimiteActuacionCIA(List<WorkOrder> listaOrdTrabajo){
		Boolean superaLimite = false;
		if(listaOrdTrabajo != null
				&& !listaOrdTrabajo.isEmpty()){
			Decimal sumatorio = 0;
			Decimal limiteActuacionCIA = listaOrdTrabajo.get(0).OTR_FOR_Limite_Actuacion_CIA__c;
			for(WorkOrder ordTrabajo : listaOrdTrabajo){
				if(ordTrabajo.OTR_RES_Subtotal_Partidas__c != null){
					sumatorio += ordTrabajo.OTR_RES_Subtotal_Partidas__c;
				}
			}
			if(sumatorio > limiteActuacionCIA){
				superaLimite = true;
			}
		}
		return superaLimite;
	}


	public static Map<Id, WorkOrder> ordenesTrabajoDeCaso(List<WorkOrder> listaOT){
		Map<Id, WorkOrder> mapaOrdenesTrabajo = new Map<Id, WorkOrder>();
		if(listaOT != null){
			Set<Id> idsCaso = new Set<Id>();
			for(WorkOrder ot : listaOT){
				if(!idsCaso.contains(ot.CaseId)){
					idsCaso.add(ot.CaseId);
				}
			}
			mapaOrdenesTrabajo = new Map<Id, WorkOrder>([
														 SELECT  CaseId, Status
														 FROM   WorkOrder 
														 WHERE   CaseId in : idsCaso AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]);
		}
		return mapaOrdenesTrabajo;
	}

	/*
	* Método par arecuperar las órdens de trabajo.
	* @param setWONumHS: Conjunto de números de WO HomeServe
	*/
	public static Map<Id, WorkOrder> queryOrdenTrabajoByNumHs(Set<String> setWONumHS) {
		Map<Id, WorkOrder> mapaOrdenesTrabajo=new Map<Id, WorkOrder>();
		if(!setWONumHS.isEmpty()) {
			for(List<WorkOrder> listOrdenesTrabajo:[SELECT Id,AccountId,Case.Account.CUE_SEL_Idioma__c,Case.AccountId,Case.CAS_DAT_Fecha_Modificacion_Estado__c,Case.CAS_LKP_Compania__c,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.CAS_LKP_Procedencia__c,Case.CAS_NUM_Contador_Pdte_Cierre__c,Case.OwnerId,Case.RecordTypeId,CaseId,City,Country,CreatedDate,Description,EndDate,Latitude,Longitude,OTR_CAS_AplicaRevision__c,OTR_CAS_Asignar_Como_Franquiciado__c,OTR_CAS_Asignar_Mizad__c,OTR_CAS_Asignar_territorio_prim_no_franq__c,OTR_CAS_Lim_Tramitacion_Expres_Superado__c,OTR_CAS_Orden_Trabajo_Facturada__c,OTR_CAS_Orden_Trabajo_Liquidada__c,OTR_CAS_Partidas_Modificadas_Revision__c,OTR_CAS_Servicio_Revisado__c,OTR_CAS_Urgente__c,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Cierre_servicio__c,OTR_DAT_Fecha_Despertar__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Recepcion_Albaran__c,OTR_DAT_Fecha_revision__c,OTR_DAT_Fecha_ultimo_C2C__c,OTR_DIV_Importe_diferencia__c,OTR_DIV_Importe_nuevo__c,OTR_DIV_Importe_original__c,OTR_FOR_Codigo_Profesional__c,OTR_FOR_Compania__c,OTR_FOR_DT__c,OTR_FOR_Gremio_Ppal_Caso__c,OTR_FOR_Identificador_CIA__c,OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,OTR_FOR_Limite_Actuacion_CIA__c,OTR_FOR_Provincia__c,OTR_FOR_Tipo_de_Caso__c,OTR_LKP_Gestor_revision__c,OTR_LKP_Linea_Contrato__c,OTR_LKP_Primera_Cita__c,OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,OTR_LKP_Primera_Cita__r.Status,OTR_LKP_Recurso_Servicio__c,OTR_LKP_Recurso_Servicio__r.Name,OTR_LKP_Recurso_Servicio__r.RelatedRecordId,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,OTR_NUM_Numero_C2C__c,OTR_RES_Facturar_Cliente_AI__c,OTR_RES_Facturar_Cliente_DI__c,OTR_RES_Facturar_Compania_DI__c,OTR_RES_Importe_partidas__c,OTR_RES_Liquidar_prof_AI__c,OTR_RES_Subtotal_Partidas__c,OTR_RES_Total_Facturar_AI__c,OTR_RES_Total_Facturar_DI__c,OTR_SEL_Categoria_del_Profesional__c,OTR_SEL_Gremio__c,OTR_SEL_Motivo_Anulacion__c,OTR_SEL_Motivo_de_rectificacion__c,OTR_SEL_Motivos_de_Rechazo_de_Albaran__c,OTR_SEL_Penalizacion__c,OTR_SEL_Rango_Primera_Cita__c,OTR_SEL_Subestado__c,OTR_SEL_Tipo_Red__c,OTR_SEL_Tipologia_de_Servicio__c,OTR_TEL_Telefono_C2C__c,OTR_TXT_Codigo_de_baremo__c,OTR_TXT_Comentario_Auditoria__c,OTR_TXT_Estado_Anterior__c,OTR_TXT_Identificador_DLC__c,OTR_TXT_Num_OrdenTrabajo_HS__c,OTR_TXT_Rango_Primera_Cita__c,OTR_TXT_rectificacion__c,OwnerId,ParentWorkOrder.Case.AccountId,ParentWorkOrder.OTR_FOR_DT__c,ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,ParentWorkorder.OTR_RES_Subtotal_Partidas__c,ParentWorkorder.ParentWorkorderId,ParentWorkOrder.WorkOrderNumber,ParentWorkOrderId,PostalCode,RecordType.Name,RecordTypeId,ServiceTerritory.Name,ServiceTerritory.PostalCode,ServiceTerritoryId,State,Status,Street,WorkOrderNumber,WorkType.Name,WorkTypeId,ContactId,OTR_CAS_Vetado_Orden_Trabajo__c,LastModifiedDate,Account.CUE_TXT_Establecimiento__c,WorkType.TDT_TXT_Identificador__c
													FROM WorkOrder
													WHERE OTR_TXT_Num_OrdenTrabajo_HS__c IN :setWONumHS AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]) {
				mapaOrdenesTrabajo.putAll(listOrdenesTrabajo);	  
			}
		}
		return mapaOrdenesTrabajo;
	}
	
	/*
	* Método para recuperar las órdenes de trabajo MKT
	*
	* @param setIdMKT: Conjunto de Ids de las órdenes de trabajo
	*/
	public static Map<Id, Work_Order_MKT__c> queryWorkOrderMKT(Set<Id> setIdMKT) {
		Map<Id, Work_Order_MKT__c> mapaOrdenesTrabajo=new Map<Id, Work_Order_MKT__c>();
		if(!setIdMKT.isEmpty()) {
			for(List<Work_Order_MKT__c> listOrdenesTrabajo:
				[SELECT Id,
				OTR_LKP_OrdenTrabajo__c,
				OTR_MKT_LKP_Contacto__c
				FROM Work_Order_MKT__c
				WHERE OTR_LKP_OrdenTrabajo__c IN :setIdMKT
				ORDER BY OTR_LKP_OrdenTrabajo__c]) {
					mapaOrdenesTrabajo.putAll(listOrdenesTrabajo);	  
			}
		}
		return mapaOrdenesTrabajo;
	}
	
	/**
	 * Devuelve un mapa de Casos con sus Listas de Ordenes de Trabajo no anuladas.
	 * 
	 * @param setIds: Conjunto de Ids de Casos
	 * @return mapa de Casos con sus Listas de Ordenes de Trabajo no anuladas
	 */
	public static Map<Id, List<WorkOrder>> getMapaOTsCasos(Set<Id> setIds){
		Map<Id, List<WorkOrder>> mapa = new Map<Id, List<WorkOrder>>();
		if(setIds != null && (!setIds.isEmpty())){
			List<WorkOrder> lista = new List<WorkOrder>(
				[SELECT Id,
						Status,
						CaseId,
						OTR_CAS_Orden_Trabajo_Facturada__c,
						OTR_CAS_Orden_Trabajo_Liquidada__c,
						OTR_CAS_Urgente__c,
						OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,
						OTR_RES_Subtotal_Partidas__c,
						OTR_RES_Facturar_Cliente_AI__c,
						OTR_RES_Liquidar_prof_AI__c,
						OTR_RES_Total_Facturar_AI__c,
						OTR_TXT_Estado_Anterior__c
				 FROM WorkOrder WHERE CaseId IN :setIds
				 AND Status NOT IN (:Label.OTR_ESTADO_ANULADO,:Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO)
				 AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) 
				 ORDER BY CaseId ASC]);
			for(WorkOrder registro : lista){
				List<WorkOrder> listaAux = mapa.get(registro.CaseId);
				if(listaAux == null){
					listaAux = new List<WorkOrder>();
				}
				listaAux.add(registro);
				mapa.put(registro.CaseId, listaAux);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve un mapa de Casos con sus Listas de todas sus Ordenes de Trabajo.
	 * 
	 * @param setIds: Conjunto de Ids de Casos
	 * @return mapa de Casos con sus Listas de todas sus Ordenes de Trabajo
	 */
	public static Map<Id, List<WorkOrder>> getMapaOTsCasosFull(Set<Id> setIds){
		Map<Id, List<WorkOrder>> mapa = new Map<Id, List<WorkOrder>>();
		if(setIds != null && (!setIds.isEmpty())){
			List<WorkOrder> lista = new List<WorkOrder>(
				[SELECT Id,
						Status,
						CaseId,
						OTR_CAS_Orden_Trabajo_Facturada__c,
						OTR_CAS_Orden_Trabajo_Liquidada__c,
						OTR_CAS_Urgente__c,
						OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,
						OTR_LKP_Recurso_Servicio__c,
						OTR_LKP_Recurso_Servicio__r.RelatedRecordId,
						OTR_RES_Subtotal_Partidas__c,
						OTR_RES_Facturar_Cliente_AI__c,
						OTR_RES_Liquidar_prof_AI__c,
						OTR_RES_Total_Facturar_AI__c,
						OTR_TXT_Estado_Anterior__c,
						OwnerId,
						Case.OwnerId
				 FROM WorkOrder WHERE CaseId IN :setIds
				 AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) 
				 ORDER BY CaseId ASC]);
			for(WorkOrder registro : lista){
				List<WorkOrder> listaAux = mapa.get(registro.CaseId);
				if(listaAux == null){
					listaAux = new List<WorkOrder>();
				}
				listaAux.add(registro);
				mapa.put(registro.CaseId, listaAux);
			}
		}
		return mapa;
	}
}