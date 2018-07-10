/**
 * Clase de funciones auxiliares relativas a los Casos.
 * 
 * @author EVERIS
 */
public without sharing class Util_Caso {

	/**
	 * Obtiene los Casos devueltos por query filtrando por los IDs.
	 *
	 * @param setIdCase: conjunto de IDs de Caso
	 *
	 * @return mapa que contiene los Casos devueltos por la query 
	 */
	public static Map<Id,Case> getCaseById(Set<Id> setIdCase){
		Map<Id,Case> mapa = new Map<Id,Case>();
		if(setIdCase != null && !setIdCase.isEmpty()){
			mapa = new Map<Id,Case>(
				[SELECT Id,
						Account.CUE_EMA_Email__c,
						Account.CUE_FOR_DireccionEnvio__c,
						Account.CUE_FOR_IBAN__c,
						Account.CUE_FOR_RTDevName__c,
						Account.CUE_LKP_Cuenta_principal__c,
						Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
						Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
						Account.CUE_SEL_Idioma__c,
						Account.CUE_SEL_Pais__c,
						Account.CUE_SEL_Procedencias_bloq__c,
						Account.CUE_SEL_Provincia__c,
						Account.CUE_SEL_Tipo_de_red__c,
						Account.CUE_SEL_Tipo_Documento__c,
						Account.CUE_TXT_Condicion_Pago__c,
						Account.CUE_TXT_Establecimiento__c,
						Account.CUE_TXT_Identificador__c,
						Account.CUE_TXT_Metodo_Pago__c,
						Account.CUE_TXT_Nombre__c,
						Account.CUE_TXT_Numero_Documento__c,
						Account.CUE_TXT_Presentacion__c,
						Account.CUE_TXT_PrimerApellido__c,
						Account.CUE_TXT_SegundoApellido__c,
						Account.Name,
						Account.Phone,
						Account.RecordType.Name,
						Account.ShippingCity,
						Account.ShippingCountry,
						Account.ShippingPostalCode,
						Account.ShippingState,
						Account.ShippingStreet,
						Account.Type,AccountId,
						CAS_CAS_Apertura_Parcial__c,
						CAS_CAS_Confirmado__c,
						CAS_CAS_Danos_Perjudicado__c,
						CAS_CAS_Danos_Propios__c,
						CAS_CAS_Generar_Presupuesto__c,
						CAS_CAS_Informe_Definitivo_Recibido__c,
						CAS_CAS_Informe_Preliminar_Recibido__c,
						CAS_CAS_Liquidado__c,
						CAS_CAS_Presolicitud_Perito__c,
						CAS_CAS_Reclamacion_Vinculada__c,
						CAS_CAS_Requiere_Perito__c,
						CAS_CAS_Siniestro_Consorciable__c,
						CAS_CAS_Siniestro_Encuestado__c,
						CAS_CAS_Siniestro_Facturado__c,
						CAS_CAS_Siniestro_Grave__c,
						CAS_CAS_Supera_Limite_Actuacion__c,
						CAS_CAS_Tercero_Causante__c,
						CAS_DAT_Fecha_Apertura__c,
						CAS_DAT_Fecha_de_Aplazamiento__c,
						CAS_DAT_Fecha_Informe_Pericial__c,
						CAS_DAT_Fecha_Modificacion_Estado__c,
						CAS_DAT_Fecha_Ocurrencia__c,
						CAS_DAT_Fecha_Pago_Minuta__c,
						CAS_DAT_Primera_Cita__c,
						CAS_DIV_Importe_Total__c,
						CAS_DIV_Pago_de_Minuta__c,
						CAS_DIV_Total_Facturar_CIA_AI__c,
						CAS_DIV_Total_Facturar_Cliente_AI__c,
						CAS_DIV_Total_Facturar_Profesional__c,
						CAS_EMA_Email__c,
						CAS_EMA_Solicitud_Email__c,
						CAS_FOR_Codigo_de_barras__c,
						CAS_FOR_Descripcion_Baremo__c,
						CAS_FOR_Direccion_Riesgo__c,
						CAS_FOR_EsB2C__c,
						CAS_FOR_Fecha_Cita_Reservada__c,
						CAS_FOR_Importe_Total__c,
						CAS_FOR_Limite_Actuacion__c,
						CAS_FOR_Nombre_Solicitud__c,
						CAS_FOR_OT_Principal_Urgente__c,
						CAS_FOR_Producto__c,
						CAS_FOR_Rango_Cita_Reservada__c,
						CAS_FOR_RTDevName__c,
						CAS_FOR_Tipo_Caso__c,
						CAS_LKP_Ayuda_Indemnizable__c,
						CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
						CAS_LKP_Baremo__c,
						CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
						CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
						CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
						CAS_LKP_Cliente_contable__c,
						CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c,
						CAS_LKP_Cliente_contable__r.Name,
						CAS_LKP_Cliente_contable__r.Type,
						CAS_LKP_Cliente_contable_cliente__c,
						CAS_LKP_Cliente_contable_cliente__r.Name,
						CAS_LKP_Compania__c,
						CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
						CAS_LKP_Compania__r.CUE_CAS_No_Permite_Servicio_B2C__c,
						CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
						CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
						CAS_LKP_Compania__r.CUE_DIV_Limite_Actuacion__c,
						CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
						CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
						CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
						CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
						CAS_LKP_Compania__r.CUE_SEL_Motivo_Reapertura__c,
						CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
						CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
						CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
						CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
						CAS_LKP_Compania__r.Name,
						CAS_LKP_Gestor_Apertura__c,
						CAS_LKP_Linea_de_Contrato__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
						CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
						CAS_LKP_Orden_Trabajo_Principal__c,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
						CAS_LKP_Perito__c,
						CAS_LKP_Perito__r.Name,
						CAS_LKP_Perito__r.PER_TLF_Telefono__c,
						CAS_LKP_Perito__r.PER_EMA_Email__c,
						CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
						CAS_LKP_PolizaContrato__c,
						CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
						CAS_LKP_PolizaContrato__r.name,
						CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_NUM_Limite_Servicios_Manitas__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
						CAS_LKP_Procedencia__c,
						CAS_LKP_Procedencia__r.Name,
						CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
						CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
						CAS_LKP_Punto_de_venta__c,
						CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
						CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
						CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
						CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
						CAS_LKP_Responsable_Reclamacion__c,
						CAS_LKP_Tipo_Trabajo__c,
						CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_FOR_Segmentacion__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
						CAS_NUM_Contador_Analisis__c,
						CAS_NUM_Contador_Clic_Hogar__c,
						CAS_NUM_Id_Actuacion_SondeoExt__c,
						CAS_SEL_Causa_Averia__c,
						CAS_SEL_Causante_Compania__c,
						CAS_SEL_Causante_Provincia__c,
						CAS_SEL_Causante_Responsable__c,
						CAS_SEL_Causante_Tipo_Documento__c,
						CAS_SEL_Comunicador_Recl__c,
						CAS_SEL_Conformidad_del_Cliente__c,
						CAS_SEL_Conformidad_del_Cliente_2__c,
						CAS_SEL_Conformidad_del_Cliente_3__c,
						CAS_SEL_Detalle_Averia__c,
						CAS_SEL_Direccion_Territorial__c,
						CAS_SEL_DirRiesgo_Estado_Provincia__c,
						CAS_SEL_Encuestador__c,
						CAS_SEL_Estado_Perito__c,
						CAS_SEL_Gremio_Principal__c,
						CAS_SEL_Grupo_Causa__c,
						CAS_SEL_Metodo_de_pago__c,
						CAS_SEL_Motivo_anulacion_reclamacion__c,
						CAS_SEL_Motivo_de_Cierre__c,
						CAS_SEL_Motivo_Indemnizable__c,
						CAS_SEL_Motivo_No_Apertura__c,
						CAS_SEL_Motivo_Peticion_Perito__c,
						CAS_SEL_Motivo_Reapertura__c,
						CAS_SEL_Motivo_Rechazo__c,
						CAS_SEL_Motivo_rechazo_presupuesto__c,
						CAS_SEL_Naturaleza__c,
						CAS_SEL_Otros_Danos__c,
						CAS_SEL_Padre_reclamacion__c,
						CAS_SEL_Perito_de_RGA__c,
						CAS_SEL_Rango_Cita__c,
						CAS_SEL_Reclamacion__c,
						CAS_SEL_Situacion_Danos_Propios__c,
						CAS_SEL_Sondeo_DocIndemSug__c,
						CAS_SEL_Sondeo_DocsIndemnizable__c,
						CAS_SEL_Sondeo_Fase__c,
						CAS_SEL_Sondeo_Gremios__c,
						CAS_SEL_Tipo_Averia__c,
						CAS_SEL_Tipo_Interlocutor__c,
						CAS_SEL_Tipo_Llamada__c,
						CAS_TFN_Solicitud_Telefono__c,
						CAS_TFN_Telefono_1__c,
						CAS_TFN_Telefono_2__c,
						CAS_TXT_Apellidos__c,
						CAS_TXT_Apellidos_2__c,
						CAS_TXT_Ayuda_Ind_Apertura__c,
						CAS_TXT_Causante_Direccion__c,
						CAS_TXT_Causante_N_Documento__c,
						CAS_TXT_Causante_N_exp_Stro__c,
						CAS_TXT_Causante_Poblacion__c,
						CAS_TXT_Causante_Poliza_R_C__c,
						CAS_TXT_Codigo_Apertura__c,
						CAS_TXT_Codigo_Campania_Origen__c,
						CAS_TXT_Codigo_Comercial__c,
						CAS_TXT_Codigo_Postal__c,
						CAS_TXT_Direccion__c,
						CAS_TXT_DirRiesgo_CP__c,
						CAS_TXT_DirRiesgo_Pais__c,
						CAS_TXT_DirRiesgo_Poblacion__c,
						CAS_TXT_Estado_Anterior__c,
						CAS_TXT_Gestor_Cierra_Reclamacion__c,
						CAS_TXT_Identificador__c,
						CAS_TXT_Identificador_DLC__c,
						CAS_TXT_Motivo_Llamada__c,
						CAS_TXT_Motivo_Reapertura__c,
						CAS_TXT_Nombre__c,
						CAS_TXT_Num_Caso_CIA__c,
						CAS_TXT_Num_Caso_HS__c,
						CAS_TXT_Password_Clic_Hogar__c,
						CAS_TXT_Persona_que_llama__c,
						CAS_TXT_Sondeo_Causa__c,
						CAS_TXT_Sondeo_Grupo_Causa__c,
						CAS_TXT_Sondeo_Tipo_de_Carta__c,
						CAS_TXT_Subestado_Caso__c,
						CAS_TXT_Subestado_Codigo__c,
						CAS_TXT_Submotivo_Perito__c,
						CAS_TXT_texto_observaciones_RGA__c,
						CAS_TXT_Tipo_Encuesta__c,
						CAS_TXT_Usuario_Clic_Hogar__c,
						CAS_TXT_WF_Compania__c,
						CaseNumber,
						ClosedDate,
						Contact.CON_CAS_ContactoDummy__c,
						ContactEmail,
						ContactId,
						CreatedDate,
						LastModifiedDate,
						Origin,
						Owner.Name,
						Owner.Type,
						OwnerId,
						Parent.CAS_TXT_Num_Caso_CIA__c,
						Parent.CaseNumber,
						Parent.Type,
						ParentId,
						recordtype.DeveloperName,
						RecordType.Name,
						RecordTypeId,
						Status,
						Type
				 FROM Case
				 WHERE Id IN :setIdCase]);
		  }
		  return mapa;
	 }


	/**
	 * Obtiene los Casos devueltos por query filtrando por los IDs.
	 *
	 * @param setIdCase: conjunto de IDs de Caso
	 *
	 * @return mapa que contiene los Casos devueltos por la query 
	 */
	public static Map<Id,Case> getCaseFactById(Set<Id> setIdCase){
		Map<Id,Case> mapa = new Map<Id,Case>();
		if(setIdCase != null && !setIdCase.isEmpty()){
			mapa = new Map<Id,Case>(
				[SELECT AccountId,
						Id, CAS_LKP_PolizaContrato__c,CAS_FOR_RTDevName__c,CaseNumber,Status,Type,CAS_SEL_Grupo_Causa__c,
                 		RecordType.DeveloperName,CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,Account.Name,
                 		CAS_TXT_Num_Caso_HS__c,CAS_CAS_Siniestro_Grave__c,CAS_DAT_Fecha_Ocurrencia__c,
                 		CAS_FOR_Producto__c,CAS_SEL_Direccion_Territorial__c,Owner.Name,CAS_DIV_Pago_de_Minuta__c,
                 		CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
                 		CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
						CAS_LKP_Cliente_contable__r.ShippingCity,CAS_LKP_Cliente_contable__r.ShippingPostalCode,
						CAS_LKP_Cliente_contable__r.ShippingState,
						CAS_LKP_Cliente_contable__r.ShippingStreet,
						CAS_LKP_Cliente_contable__c,
						RecordTypeId,RecordType.Name,
						CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
                 		CAS_LKP_Cliente_contable__r.Id,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
						CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
						CAS_LKP_Cliente_contable__r.Phone,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
						CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
						CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
						CAS_LKP_Cliente_contable__r.Name,
						CAS_LKP_Cliente_contable__r.ShippingCountry,
						CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
						CAS_LKP_Cliente_contable_cliente__r.Name,
						CAS_LKP_Cliente_contable_cliente__r.CUE_FOR_RTDevName__c,
						CAS_LKP_Cliente_contable_cliente__r.Type,
						CAS_LKP_Cliente_contable_cliente__r.Id, 
						CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Tipo_Documento__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Numero_Documento__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
						CAS_LKP_Cliente_contable_cliente__r.Phone,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Condicion_Pago__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Metodo_Pago__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Digito_Control__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Numero__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_FOR_IBAN__c,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Pais__c,
						CAS_LKP_Cliente_contable_cliente__r.ShippingStreet,
						CAS_LKP_Cliente_contable_cliente__r.ShippingPostalCode,
						CAS_LKP_Cliente_contable_cliente__r.ShippingState,
						CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Pais__c,
						CAS_LKP_Cliente_contable_cliente__r.ShippingCity,
						CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c,
						CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c,
						CAS_LKP_Cliente_contable__r.Type
				 FROM Case
				 WHERE Id IN :setIdCase]);
		  }
		  return mapa;
	 }

	/**
	 * Obtiene los Casos devueltos por query filtrando por los ParentId's.
	 *
	 * @param setParentId: conjunto de ParentId's del Caso
	 *
	 * @return mapa que contiene los Casos devueltos por la query
	 */
	public static Map<Id,Case> getCaseByParentId(Set<Id> setParentId){
		Map<Id,Case> mapa = new Map<Id,Case>();
		if(setParentId != null && !setParentId.isEmpty()){
			mapa = new Map<Id,Case>(
				[SELECT Id,
						Account.CUE_EMA_Email__c,
						Account.CUE_FOR_DireccionEnvio__c,
						Account.CUE_FOR_IBAN__c,
						Account.CUE_FOR_RTDevName__c,
						Account.CUE_LKP_Cuenta_principal__c,
						Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
						Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
						Account.CUE_SEL_Idioma__c,
						Account.CUE_SEL_Pais__c,
						Account.CUE_SEL_Provincia__c,
						Account.CUE_SEL_Tipo_Documento__c,
						Account.CUE_TXT_Cbanc_Codigo_Entidad__c,
						Account.CUE_TXT_Cbanc_Digito_Control__c,
						Account.CUE_TXT_Cbanc_Numero__c,
						Account.CUE_TXT_Cbanc_Pais__c,
						Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,
						Account.CUE_TXT_Condicion_Pago__c,
						Account.CUE_TXT_Establecimiento__c,
						Account.CUE_TXT_Identificador__c,
						Account.CUE_TXT_Metodo_Pago__c,
						Account.CUE_TXT_Nombre__c,
						Account.CUE_TXT_Numero_Documento__c,
						Account.CUE_TXT_Presentacion__c,
						Account.CUE_TXT_PrimerApellido__c,
						Account.CUE_TXT_SegundoApellido__c,
						Account.Name,
						Account.Phone,
						Account.RecordType.Name,
						Account.ShippingCity,
						Account.ShippingCountry,
						Account.ShippingPostalCode,
						Account.ShippingState,
						Account.ShippingStreet,
						Account.Type,
						AccountId,
						CAS_CAS_Apertura_Parcial__c,
						CAS_CAS_Confirmado__c,
						CAS_CAS_Danos_Perjudicado__c,
						CAS_CAS_Danos_Propios__c,
						CAS_CAS_Generar_Presupuesto__c,
						CAS_CAS_Informe_Definitivo_Recibido__c,
						CAS_CAS_Informe_Preliminar_Recibido__c,
						CAS_CAS_Liquidado__c,
						CAS_CAS_Reclamacion_Vinculada__c,
						CAS_CAS_Requiere_Perito__c,
						CAS_CAS_Siniestro_Consorciable__c,
						CAS_CAS_Siniestro_Encuestado__c,
						CAS_CAS_Siniestro_Facturado__c,
						CAS_CAS_Siniestro_Grave__c,
						CAS_CAS_Supera_Limite_Actuacion__c,
						CAS_CAS_Tercero_Causante__c,
						CAS_DAT_Fecha_Apertura__c,
						CAS_DAT_Fecha_de_Aplazamiento__c,
						CAS_DAT_Fecha_Informe_Pericial__c,
						CAS_DAT_Fecha_Modificacion_Estado__c,
						CAS_DAT_Fecha_Ocurrencia__c,
						CAS_DAT_Fecha_Pago_Minuta__c,
						CAS_DAT_Primera_Cita__c,
						CAS_DIV_Importe_Total__c,
						CAS_DIV_Pago_de_Minuta__c,
						CAS_DIV_Total_Facturar_CIA_AI__c,
						CAS_DIV_Total_Facturar_Cliente_AI__c,
						CAS_DIV_Total_Facturar_Profesional__c,
						CAS_EMA_Email__c,
						CAS_EMA_Solicitud_Email__c,
						CAS_FOR_Codigo_de_barras__c,
						CAS_FOR_Descripcion_Baremo__c,
						CAS_FOR_Direccion_Riesgo__c,
						CAS_FOR_EsB2C__c,
						CAS_FOR_Fecha_Cita_Reservada__c,
						CAS_FOR_Importe_Total__c,
						CAS_FOR_Limite_Actuacion__c,
						CAS_FOR_Nombre_Solicitud__c,
						CAS_FOR_OT_Principal_Urgente__c,
						CAS_FOR_Producto__c,
						CAS_FOR_Rango_Cita_Reservada__c,
						CAS_FOR_RTDevName__c,
						CAS_FOR_Tipo_Caso__c,
						CAS_LKP_Ayuda_Indemnizable__c,
						CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
						CAS_LKP_Baremo__c,
						CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
						CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
						CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
						CAS_LKP_Cliente_contable__c,
						CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
						CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
						CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
						CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,
						CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
						CAS_LKP_Cliente_contable__r.Name,
						CAS_LKP_Cliente_contable__r.Phone,
						CAS_LKP_Cliente_contable__r.ShippingCity,
						CAS_LKP_Cliente_contable__r.ShippingCountry,
						CAS_LKP_Cliente_contable__r.ShippingPostalCode,
						CAS_LKP_Cliente_contable__r.ShippingState,
						CAS_LKP_Cliente_contable__r.ShippingStreet,
						CAS_LKP_Cliente_contable_cliente__c,
						CAS_LKP_Cliente_contable_cliente__r.Name,
						CAS_LKP_Compania__c,
						CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
						CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
						CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
						CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
						CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
						CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
						CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
						CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
						CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
						CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
						CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
						CAS_LKP_Compania__r.Name,
						CAS_LKP_Linea_de_Contrato__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
						CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
						CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
						CAS_LKP_Orden_Trabajo_Principal__c,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
						CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
						CAS_LKP_Perito__c,
						CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
						CAS_LKP_PolizaContrato__c,
						CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
						CAS_LKP_PolizaContrato__r.name,
						CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
						CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
						CAS_LKP_Procedencia__c,
						CAS_LKP_Procedencia__r.Name,
						CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
						CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
						CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
						CAS_LKP_Punto_de_venta__c,
						CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
						CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
						CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
						CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
						CAS_LKP_Responsable_Reclamacion__c,
						CAS_LKP_Tipo_Trabajo__c,
						CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
						CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
						CAS_NUM_Contador_Analisis__c,
						CAS_NUM_Contador_Clic_Hogar__c,
						CAS_NUM_Id_Actuacion_SondeoExt__c,
						CAS_SEL_Causa_Averia__c,
						CAS_SEL_Causante_Compania__c,
						CAS_SEL_Causante_Provincia__c,
						CAS_SEL_Causante_Responsable__c,
						CAS_SEL_Causante_Tipo_Documento__c,
						CAS_SEL_Comunicador_Recl__c,
						CAS_SEL_Conformidad_del_Cliente__c,
						CAS_SEL_Conformidad_del_Cliente_2__c,
						CAS_SEL_Conformidad_del_Cliente_3__c,
						CAS_SEL_Detalle_Averia__c,
						CAS_SEL_Direccion_Territorial__c,
						CAS_SEL_DirRiesgo_Estado_Provincia__c,
						CAS_SEL_Encuestador__c,
						CAS_SEL_Estado_Perito__c,
						CAS_SEL_Gremio_Principal__c,
						CAS_SEL_Grupo_Causa__c,
						CAS_SEL_Metodo_de_pago__c,
						CAS_SEL_Motivo_anulacion_reclamacion__c,
						CAS_SEL_Motivo_de_Cierre__c,
						CAS_SEL_Motivo_Indemnizable__c,
						CAS_SEL_Motivo_No_Apertura__c,
						CAS_SEL_Motivo_Peticion_Perito__c,
						CAS_SEL_Motivo_Reapertura__c,
						CAS_SEL_Motivo_Rechazo__c,
						CAS_SEL_Motivo_rechazo_presupuesto__c,
						CAS_SEL_Naturaleza__c,
						CAS_SEL_Otros_Danos__c,
						CAS_SEL_Padre_reclamacion__c,
						CAS_SEL_Perito_de_RGA__c,
						CAS_SEL_Rango_Cita__c,
						CAS_SEL_Reclamacion__c,
						CAS_SEL_Situacion_Danos_Propios__c,
						CAS_SEL_Sondeo_DocIndemSug__c,
						CAS_SEL_Sondeo_DocsIndemnizable__c,
						CAS_SEL_Sondeo_Fase__c,
						CAS_SEL_Sondeo_Gremios__c,
						CAS_SEL_Tipo_Averia__c,
						CAS_SEL_Tipo_Interlocutor__c,
						CAS_SEL_Tipo_Llamada__c,
						CAS_TFN_Solicitud_Telefono__c,
						CAS_TFN_Telefono_1__c,
						CAS_TFN_Telefono_2__c,
						CAS_TXT_Apellidos__c,
						CAS_TXT_Apellidos_2__c,
						CAS_TXT_Ayuda_Ind_Apertura__c,
						CAS_TXT_Causante_Direccion__c,
						CAS_TXT_Causante_N_Documento__c,
						CAS_TXT_Causante_N_exp_Stro__c,
						CAS_TXT_Causante_Poblacion__c,
						CAS_TXT_Causante_Poliza_R_C__c,
						CAS_TXT_Codigo_Apertura__c,
						CAS_TXT_Codigo_Campania_Origen__c,
						CAS_TXT_Codigo_Comercial__c,
						CAS_TXT_Codigo_Postal__c,
						CAS_TXT_Direccion__c,
						CAS_TXT_DirRiesgo_CP__c,
						CAS_TXT_DirRiesgo_Pais__c,
						CAS_TXT_DirRiesgo_Poblacion__c,
						CAS_TXT_Estado_Anterior__c,
						CAS_TXT_Identificador__c,
						CAS_TXT_Identificador_DLC__c,
						CAS_TXT_Motivo_Llamada__c,
						CAS_TXT_Motivo_Reapertura__c,
						CAS_TXT_Nombre__c,
						CAS_TXT_Num_Caso_CIA__c,
						CAS_TXT_Num_Caso_HS__c,
						CAS_TXT_Password_Clic_Hogar__c,
						CAS_TXT_Persona_que_llama__c,
						CAS_TXT_Sondeo_Causa__c,
						CAS_TXT_Sondeo_Grupo_Causa__c,
						CAS_TXT_Sondeo_Tipo_de_Carta__c,
						CAS_TXT_Subestado_Caso__c,
						CAS_TXT_Subestado_Codigo__c,
						CAS_TXT_Submotivo_Perito__c,
						CAS_TXT_texto_observaciones_RGA__c,
						CAS_TXT_Tipo_Encuesta__c,
						CAS_TXT_Usuario_Clic_Hogar__c,
						CAS_TXT_WF_Compania__c,
						CaseNumber,
						ClosedDate,
						Contact.CON_CAS_ContactoDummy__c,
						ContactEmail,
						ContactId,
						CreatedDate,
						LastModifiedDate,
						Origin,
						Owner.Name,
						Owner.Type,
						OwnerId,
						Parent.CAS_TXT_Num_Caso_CIA__c,
						Parent.CaseNumber,
						Parent.Type,
						ParentId,
						recordtype.DeveloperName,
						RecordType.Name,
						RecordTypeId,
						Status,
						Type
				 FROM Case
				 WHERE ParentId IN :setParentId]);
		  }
		  return mapa;
	 }


	 /**
	  * Devuelve los Casos con usuario y password filtrados por la fecha de creación.
	  *
	  * @param fechaCreacion: fecha de creación para filtrar el día (DAY_ONLY(CreatedDate))
	  *
	  * @return mapa que contiene los Casos encontrados
	  */
	 public static Map<Id,Case> getCaseByCreatedDateUsrPassNotNull(Date fechaCreacion){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(fechaCreacion != null){
				for(List<Case> lista:[SELECT Id,
											 ContactId,
											 CAS_LKP_Compania__c,
											 CAS_LKP_Procedencia__c,
											 CreatedDate,
											 CAS_TXT_Usuario_Clic_Hogar__c,
											 CAS_NUM_Contador_Clic_Hogar__c,
											 CAS_TXT_Password_Clic_Hogar__c,
											 CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c
										FROM Case
										WHERE DAY_ONLY(CreatedDate) = :fechaCreacion
										AND CAS_TXT_Usuario_Clic_Hogar__c != null
										AND CAS_TXT_Password_Clic_Hogar__c != null]){
					 mapa.putAll(lista);
				}
		  }
		  return mapa;
	 }

	 /**
	  * Obtiene los Casos devueltos por query filtrando por los CaseNumber
	  *
	  * @param setCaseNumber: conjunto de CaseNumber de Caso
	  *
	  * @return mapa que contiene los Casos devueltos por la query
	  */
	 public static Map<Id,Case> getCaseByCaseNumber(Set<String> setCaseNumber){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setCaseNumber != null && !setCaseNumber.isEmpty()){
				for(List<Case> lista : [SELECT Id,
												Account.CUE_EMA_Email__c,
												Account.CUE_FOR_DireccionEnvio__c,
												Account.CUE_FOR_IBAN__c,
												Account.CUE_FOR_RTDevName__c,
												Account.CUE_LKP_Cuenta_principal__c,
												Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
												Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
												Account.CUE_SEL_Idioma__c,
												Account.CUE_SEL_Pais__c,
												Account.CUE_SEL_Provincia__c,
												Account.CUE_SEL_Tipo_Documento__c,
												Account.CUE_TXT_Cbanc_Codigo_Entidad__c,
												Account.CUE_TXT_Cbanc_Digito_Control__c,
												Account.CUE_TXT_Cbanc_Numero__c,
												Account.CUE_TXT_Cbanc_Pais__c,
												Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,
												Account.CUE_TXT_Condicion_Pago__c,
												Account.CUE_TXT_Establecimiento__c,
												Account.CUE_TXT_Identificador__c,
												Account.CUE_TXT_Metodo_Pago__c,
												Account.CUE_TXT_Nombre__c,
												Account.CUE_TXT_Numero_Documento__c,
												Account.CUE_TXT_Presentacion__c,
												Account.CUE_TXT_PrimerApellido__c,
												Account.CUE_TXT_SegundoApellido__c,
												Account.Name,
												Account.Phone,
												Account.RecordType.Name,
												Account.ShippingCity,
												Account.ShippingCountry,
												Account.ShippingPostalCode,
												Account.ShippingState,
												Account.ShippingStreet,
												Account.Type,
												AccountId,
												CAS_CAS_Apertura_Parcial__c,
												CAS_CAS_Confirmado__c,
												CAS_CAS_Danos_Perjudicado__c,
												CAS_CAS_Danos_Propios__c,
												CAS_CAS_Generar_Presupuesto__c,
												CAS_CAS_Liquidado__c,
												CAS_CAS_Reclamacion_Vinculada__c,
												CAS_CAS_Requiere_Perito__c,
												CAS_CAS_Siniestro_Consorciable__c,
												CAS_CAS_Siniestro_Encuestado__c,
												CAS_CAS_Siniestro_Facturado__c,
												CAS_CAS_Siniestro_Grave__c,
												CAS_CAS_Supera_Limite_Actuacion__c,
												CAS_CAS_Tercero_Causante__c,
												CAS_DAT_Fecha_Apertura__c,
												CAS_DAT_Fecha_de_Aplazamiento__c,
												CAS_DAT_Fecha_Informe_Pericial__c,
												CAS_DAT_Fecha_Modificacion_Estado__c,
												CAS_DAT_Fecha_Ocurrencia__c,
												CAS_DAT_Fecha_Pago_Minuta__c,
												CAS_DAT_Primera_Cita__c,
												CAS_DIV_Importe_Total__c,
												CAS_DIV_Pago_de_Minuta__c,
												CAS_DIV_Total_Facturar_CIA_AI__c,
												CAS_DIV_Total_Facturar_Cliente_AI__c,
												CAS_DIV_Total_Facturar_Profesional__c,
												CAS_EMA_Email__c,
												CAS_EMA_Solicitud_Email__c,
												CAS_FOR_Codigo_de_barras__c,
												CAS_FOR_Descripcion_Baremo__c,
												CAS_FOR_Direccion_Riesgo__c,
												CAS_FOR_EsB2C__c,
												CAS_FOR_Fecha_Cita_Reservada__c,
												CAS_FOR_Importe_Total__c,
												CAS_FOR_Limite_Actuacion__c,
												CAS_FOR_Nombre_Solicitud__c,
												CAS_FOR_OT_Principal_Urgente__c,
												CAS_FOR_Producto__c,
												CAS_FOR_Rango_Cita_Reservada__c,
												CAS_FOR_RTDevName__c,
												CAS_FOR_Tipo_Caso__c,
												CAS_LKP_Ayuda_Indemnizable__c,
												CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
												CAS_LKP_Baremo__c,
												CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
												CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
												CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
												CAS_LKP_Cliente_contable__c,
												CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
												CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
												CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
												CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
												CAS_LKP_Cliente_contable__r.Name,
												CAS_LKP_Cliente_contable__r.Phone,
												CAS_LKP_Cliente_contable__r.ShippingCity,
												CAS_LKP_Cliente_contable__r.ShippingCountry,
												CAS_LKP_Cliente_contable__r.ShippingPostalCode,
												CAS_LKP_Cliente_contable__r.ShippingState,
												CAS_LKP_Cliente_contable__r.ShippingStreet,
												CAS_LKP_Cliente_contable_cliente__c,
												CAS_LKP_Cliente_contable_cliente__r.Name,
												CAS_LKP_Compania__c,
												CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
												CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
												CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
												CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
												CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
												CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
												CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
												CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
												CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
												CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
												CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
												CAS_LKP_Compania__r.Name,
												CAS_LKP_Linea_de_Contrato__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
												CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
												CAS_LKP_Orden_Trabajo_Principal__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
												CAS_LKP_Perito__c,
												CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
												CAS_LKP_PolizaContrato__c,
												CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
												CAS_LKP_PolizaContrato__r.name,
												CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_NUM_Limite_Servicios_Manitas__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
												CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
												CAS_LKP_Procedencia__c,
												CAS_LKP_Procedencia__r.Name,
												CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
												CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
												CAS_LKP_Punto_de_venta__c,
												CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
												CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
												CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
												CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
												CAS_LKP_Responsable_Reclamacion__c,
												CAS_LKP_Tipo_Trabajo__c,
												CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
												CAS_NUM_Contador_Analisis__c,
												CAS_NUM_Contador_Clic_Hogar__c,
												CAS_NUM_Id_Actuacion_SondeoExt__c,
												CAS_SEL_Causa_Averia__c,
												CAS_SEL_Causante_Compania__c,
												CAS_SEL_Causante_Provincia__c,
												CAS_SEL_Causante_Responsable__c,
												CAS_SEL_Causante_Tipo_Documento__c,
												CAS_SEL_Comunicador_Recl__c,
												CAS_SEL_Conformidad_del_Cliente__c,
												CAS_SEL_Conformidad_del_Cliente_2__c,
												CAS_SEL_Conformidad_del_Cliente_3__c,
												CAS_SEL_Detalle_Averia__c,
												CAS_SEL_Direccion_Territorial__c,
												CAS_SEL_DirRiesgo_Estado_Provincia__c,
												CAS_SEL_Encuestador__c,
												CAS_SEL_Estado_Perito__c,
												CAS_SEL_Gremio_Principal__c,
												CAS_SEL_Grupo_Causa__c,
												CAS_SEL_Metodo_de_pago__c,
												CAS_SEL_Motivo_anulacion_reclamacion__c,
												CAS_SEL_Motivo_de_Cierre__c,
												CAS_SEL_Motivo_Indemnizable__c,
												CAS_SEL_Motivo_No_Apertura__c,
												CAS_SEL_Motivo_Peticion_Perito__c,
												CAS_SEL_Motivo_Reapertura__c,
												CAS_SEL_Motivo_Rechazo__c,
												CAS_SEL_Motivo_rechazo_presupuesto__c,
												CAS_SEL_Naturaleza__c,
												CAS_SEL_Otros_Danos__c,
												CAS_SEL_Padre_reclamacion__c,
												CAS_SEL_Perito_de_RGA__c,
												CAS_SEL_Rango_Cita__c,
												CAS_SEL_Reclamacion__c,
												CAS_SEL_Situacion_Danos_Propios__c,
												CAS_SEL_Sondeo_DocIndemSug__c,
												CAS_SEL_Sondeo_DocsIndemnizable__c,
												CAS_SEL_Sondeo_Fase__c,
												CAS_SEL_Sondeo_Gremios__c,
												CAS_SEL_Tipo_Averia__c,
												CAS_SEL_Tipo_Interlocutor__c,
												CAS_SEL_Tipo_Llamada__c,
												CAS_TFN_Solicitud_Telefono__c,
												CAS_TFN_Telefono_1__c,
												CAS_TFN_Telefono_2__c,
												CAS_TXT_Apellidos__c,
												CAS_TXT_Apellidos_2__c,
												CAS_TXT_Ayuda_Ind_Apertura__c,
												CAS_TXT_Causante_Direccion__c,
												CAS_TXT_Causante_N_Documento__c,
												CAS_TXT_Causante_N_exp_Stro__c,
												CAS_TXT_Causante_Poblacion__c,
												CAS_TXT_Causante_Poliza_R_C__c,
												CAS_TXT_Codigo_Apertura__c,
												CAS_TXT_Codigo_Campania_Origen__c,
												CAS_TXT_Codigo_Comercial__c,
												CAS_TXT_Codigo_Postal__c,
												CAS_TXT_Direccion__c,
												CAS_TXT_DirRiesgo_CP__c,
												CAS_TXT_DirRiesgo_Pais__c,
												CAS_TXT_DirRiesgo_Poblacion__c,
												CAS_TXT_Estado_Anterior__c,
												CAS_TXT_Identificador__c,
												CAS_TXT_Identificador_DLC__c,
												CAS_TXT_Motivo_Llamada__c,
												CAS_TXT_Motivo_Reapertura__c,
												CAS_TXT_Nombre__c,
												CAS_TXT_Num_Caso_CIA__c,
												CAS_TXT_Num_Caso_HS__c,
												CAS_TXT_Password_Clic_Hogar__c,
												CAS_TXT_Persona_que_llama__c,
												CAS_TXT_Sondeo_Causa__c,
												CAS_TXT_Sondeo_Grupo_Causa__c,
												CAS_TXT_Sondeo_Tipo_de_Carta__c,
												CAS_TXT_Subestado_Caso__c,
												CAS_TXT_Subestado_Codigo__c,
												CAS_TXT_Submotivo_Perito__c,
												CAS_TXT_texto_observaciones_RGA__c,
												CAS_TXT_Tipo_Encuesta__c,
												CAS_TXT_Usuario_Clic_Hogar__c,
												CAS_TXT_WF_Compania__c,
												CaseNumber,
												ClosedDate,
												Contact.CON_CAS_ContactoDummy__c,
												ContactEmail,
												ContactId,
												CreatedDate,
												LastModifiedDate,
												Origin,
												Owner.Name,
												Owner.Type,
												OwnerId,
												Parent.CAS_TXT_Num_Caso_CIA__c,
												Parent.CaseNumber,
												Parent.Type,
												ParentId,
												recordtype.DeveloperName,
												RecordType.Name,
												RecordTypeId,
												Status,
												Type
										FROM Case
										WHERE CaseNumber IN :setCaseNumber]){
					 mapa.putAll(lista);
				}
		  }
		  return mapa;
	 }

	 /**
	  * Obtiene los Casos devueltos por query filtrando por los DeveloperName del RT y los estados de la OT relacionada.
	  *
	  * @param setRTDevName: conjunto de DeveloperName's de los RecordTypes
	  * @param setStatus: conjunto de estados de las OT's relacionadas
	  *
	  * @return mapa que contiene los Casos devueltos por la query
	  */
	 public static Map<Id,Case> getCaseByRTDevNameAndInStatusOT(Set<String> setRTDevName, Set<String> setStatus){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setRTDevName != null && !setRTDevName.isEmpty() && setStatus != null && !setStatus.isEmpty()){
				for(List<Case> lista:[SELECT Id,
												Account.CUE_EMA_Email__c,
												Account.CUE_FOR_DireccionEnvio__c,
												Account.CUE_FOR_IBAN__c,
												Account.CUE_FOR_RTDevName__c,
												Account.CUE_LKP_Cuenta_principal__c,
												Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
												Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
												Account.CUE_SEL_Idioma__c,
												Account.CUE_SEL_Pais__c,
												Account.CUE_SEL_Provincia__c,
												Account.CUE_SEL_Tipo_Documento__c,
												Account.CUE_TXT_Cbanc_Codigo_Entidad__c,
												Account.CUE_TXT_Cbanc_Digito_Control__c,
												Account.CUE_TXT_Cbanc_Numero__c,
												Account.CUE_TXT_Cbanc_Pais__c,
												Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,
												Account.CUE_TXT_Condicion_Pago__c,
												Account.CUE_TXT_Establecimiento__c,
												Account.CUE_TXT_Identificador__c,
												Account.CUE_TXT_Metodo_Pago__c,
												Account.CUE_TXT_Nombre__c,
												Account.CUE_TXT_Numero_Documento__c,
												Account.CUE_TXT_Presentacion__c,
												Account.CUE_TXT_PrimerApellido__c,
												Account.CUE_TXT_SegundoApellido__c,
												Account.Name,
												Account.Phone,
												Account.RecordType.Name,
												Account.ShippingCity,
												Account.ShippingCountry,
												Account.ShippingPostalCode,
												Account.ShippingState,
												Account.ShippingStreet,
												Account.Type,
												AccountId,
												CAS_CAS_Apertura_Parcial__c,
												CAS_CAS_Confirmado__c,
												CAS_CAS_Danos_Perjudicado__c,
												CAS_CAS_Danos_Propios__c,
												CAS_CAS_Generar_Presupuesto__c,
												CAS_CAS_Liquidado__c,
												CAS_CAS_Reclamacion_Vinculada__c,
												CAS_CAS_Requiere_Perito__c,
												CAS_CAS_Siniestro_Consorciable__c,
												CAS_CAS_Siniestro_Encuestado__c,
												CAS_CAS_Siniestro_Facturado__c,
												CAS_CAS_Siniestro_Grave__c,
												CAS_CAS_Supera_Limite_Actuacion__c,
												CAS_CAS_Tercero_Causante__c,
												CAS_DAT_Fecha_Apertura__c,
												CAS_DAT_Fecha_de_Aplazamiento__c,
												CAS_DAT_Fecha_Informe_Pericial__c,
												CAS_DAT_Fecha_Modificacion_Estado__c,
												CAS_DAT_Fecha_Ocurrencia__c,
												CAS_DAT_Fecha_Pago_Minuta__c,
												CAS_DAT_Primera_Cita__c,
												CAS_DIV_Importe_Total__c,
												CAS_DIV_Pago_de_Minuta__c,
												CAS_DIV_Total_Facturar_CIA_AI__c,
												CAS_DIV_Total_Facturar_Cliente_AI__c,
												CAS_DIV_Total_Facturar_Profesional__c,
												CAS_EMA_Email__c,
												CAS_EMA_Solicitud_Email__c,
												CAS_FOR_Codigo_de_barras__c,
												CAS_FOR_Descripcion_Baremo__c,
												CAS_FOR_Direccion_Riesgo__c,
												CAS_FOR_EsB2C__c,
												CAS_FOR_Fecha_Cita_Reservada__c,
												CAS_FOR_Importe_Total__c,
												CAS_FOR_Limite_Actuacion__c,
												CAS_FOR_Nombre_Solicitud__c,
												CAS_FOR_OT_Principal_Urgente__c,
												CAS_FOR_Producto__c,
												CAS_FOR_Rango_Cita_Reservada__c,
												CAS_FOR_RTDevName__c,
												CAS_FOR_Tipo_Caso__c,
												CAS_LKP_Ayuda_Indemnizable__c,
												CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
												CAS_LKP_Baremo__c,
												CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
												CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
												CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
												CAS_LKP_Cliente_contable__c,
												CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
												CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
												CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
												CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
												CAS_LKP_Cliente_contable__r.Name,
												CAS_LKP_Cliente_contable__r.Phone,
												CAS_LKP_Cliente_contable__r.ShippingCity,
												CAS_LKP_Cliente_contable__r.ShippingCountry,
												CAS_LKP_Cliente_contable__r.ShippingPostalCode,
												CAS_LKP_Cliente_contable__r.ShippingState,
												CAS_LKP_Cliente_contable__r.ShippingStreet,
												CAS_LKP_Cliente_contable_cliente__c,
												CAS_LKP_Cliente_contable_cliente__r.Name,
												CAS_LKP_Compania__c,
												CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
												CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
												CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
												CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
												CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
												CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
												CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
												CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
												CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
												CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
												CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
												CAS_LKP_Compania__r.Name,
												CAS_LKP_Linea_de_Contrato__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
												CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
												CAS_LKP_Orden_Trabajo_Principal__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
												CAS_LKP_Perito__c,
												CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
												CAS_LKP_PolizaContrato__c,
												CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
												CAS_LKP_PolizaContrato__r.name,
												CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
												CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
												CAS_LKP_Procedencia__c,
												CAS_LKP_Procedencia__r.Name,
												CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
												CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
												CAS_LKP_Punto_de_venta__c,
												CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
												CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
												CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
												CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
												CAS_LKP_Responsable_Reclamacion__c,
												CAS_LKP_Tipo_Trabajo__c,
												CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
												CAS_NUM_Contador_Analisis__c,
												CAS_NUM_Contador_Clic_Hogar__c,
												CAS_NUM_Id_Actuacion_SondeoExt__c,
												CAS_SEL_Causa_Averia__c,
												CAS_SEL_Causante_Compania__c,
												CAS_SEL_Causante_Provincia__c,
												CAS_SEL_Causante_Responsable__c,
												CAS_SEL_Causante_Tipo_Documento__c,
												CAS_SEL_Comunicador_Recl__c,
												CAS_SEL_Conformidad_del_Cliente__c,
												CAS_SEL_Conformidad_del_Cliente_2__c,
												CAS_SEL_Conformidad_del_Cliente_3__c,
												CAS_SEL_Detalle_Averia__c,
												CAS_SEL_Direccion_Territorial__c,
												CAS_SEL_DirRiesgo_Estado_Provincia__c,
												CAS_SEL_Encuestador__c,
												CAS_SEL_Estado_Perito__c,
												CAS_SEL_Gremio_Principal__c,
												CAS_SEL_Grupo_Causa__c,
												CAS_SEL_Metodo_de_pago__c,
												CAS_SEL_Motivo_anulacion_reclamacion__c,
												CAS_SEL_Motivo_de_Cierre__c,
												CAS_SEL_Motivo_Indemnizable__c,
												CAS_SEL_Motivo_No_Apertura__c,
												CAS_SEL_Motivo_Peticion_Perito__c,
												CAS_SEL_Motivo_Reapertura__c,
												CAS_SEL_Motivo_Rechazo__c,
												CAS_SEL_Motivo_rechazo_presupuesto__c,
												CAS_SEL_Naturaleza__c,
												CAS_SEL_Otros_Danos__c,
												CAS_SEL_Padre_reclamacion__c,
												CAS_SEL_Perito_de_RGA__c,
												CAS_SEL_Rango_Cita__c,
												CAS_SEL_Reclamacion__c,
												CAS_SEL_Situacion_Danos_Propios__c,
												CAS_SEL_Sondeo_DocIndemSug__c,
												CAS_SEL_Sondeo_DocsIndemnizable__c,
												CAS_SEL_Sondeo_Fase__c,
												CAS_SEL_Sondeo_Gremios__c,
												CAS_SEL_Tipo_Averia__c,
												CAS_SEL_Tipo_Interlocutor__c,
												CAS_SEL_Tipo_Llamada__c,
												CAS_TFN_Solicitud_Telefono__c,
												CAS_TFN_Telefono_1__c,
												CAS_TFN_Telefono_2__c,
												CAS_TXT_Apellidos__c,
												CAS_TXT_Apellidos_2__c,
												CAS_TXT_Ayuda_Ind_Apertura__c,
												CAS_TXT_Causante_Direccion__c,
												CAS_TXT_Causante_N_Documento__c,
												CAS_TXT_Causante_N_exp_Stro__c,
												CAS_TXT_Causante_Poblacion__c,
												CAS_TXT_Causante_Poliza_R_C__c,
												CAS_TXT_Codigo_Apertura__c,
												CAS_TXT_Codigo_Campania_Origen__c,
												CAS_TXT_Codigo_Comercial__c,
												CAS_TXT_Codigo_Postal__c,
												CAS_TXT_Direccion__c,
												CAS_TXT_DirRiesgo_CP__c,
												CAS_TXT_DirRiesgo_Pais__c,
												CAS_TXT_DirRiesgo_Poblacion__c,
												CAS_TXT_Estado_Anterior__c,
												CAS_TXT_Identificador__c,
												CAS_TXT_Identificador_DLC__c,
												CAS_TXT_Motivo_Llamada__c,
												CAS_TXT_Motivo_Reapertura__c,
												CAS_TXT_Nombre__c,
												CAS_TXT_Num_Caso_CIA__c,
												CAS_TXT_Num_Caso_HS__c,
												CAS_TXT_Password_Clic_Hogar__c,
												CAS_TXT_Persona_que_llama__c,
												CAS_TXT_Sondeo_Causa__c,
												CAS_TXT_Sondeo_Grupo_Causa__c,
												CAS_TXT_Sondeo_Tipo_de_Carta__c,
												CAS_TXT_Subestado_Caso__c,
												CAS_TXT_Subestado_Codigo__c,
												CAS_TXT_Submotivo_Perito__c,
												CAS_TXT_texto_observaciones_RGA__c,
												CAS_TXT_Tipo_Encuesta__c,
												CAS_TXT_Usuario_Clic_Hogar__c,
												CAS_TXT_WF_Compania__c,
												CaseNumber,
												ClosedDate,
												Contact.CON_CAS_ContactoDummy__c,
												ContactEmail,
												ContactId,
												CreatedDate,
												LastModifiedDate,
												Origin,
												Owner.Name,
												Owner.Type,
												OwnerId,
												Parent.CAS_TXT_Num_Caso_CIA__c,
												Parent.CaseNumber,
												Parent.Type,
												ParentId,
												recordtype.DeveloperName,
												RecordType.Name,
												RecordTypeId,
												Status,
												Type
										FROM Case
										WHERE RecordType.DeveloperName IN :setRTDevName AND Id IN (SELECT CaseId FROM WorkOrder WHERE Status IN :setStatus)]){
					 mapa.putAll(lista);
				}
		  }
		  return mapa;
	 }

	 /**
	  * Método base para realizar queries sobre el objeto Caso pasando un filtro de búsqueda.
	  *
	  * @param filter: filtro del where de la query a ejecutar
	  * @return Mapa que contiene los Casos devueltos por la query
	  */
	 /*public static Map<Id,Case> queryMapCaseByFilter(String filter){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  String sql = 'SELECT Id,';
		  sql += ' Account.CUE_EMA_Email__c,';
		  sql += ' Account.CUE_FOR_DireccionEnvio__c,';
		  sql += ' Account.CUE_FOR_IBAN__c,';
		  sql += ' Account.CUE_FOR_RTDevName__c,';
		  sql += ' Account.CUE_LKP_Cuenta_principal__c,';
		  sql += ' Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,';
		  sql += ' Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,';
		  sql += ' Account.CUE_SEL_Idioma__c,';
		  sql += ' Account.CUE_SEL_Pais__c,';
		  sql += ' Account.CUE_SEL_Provincia__c,';
		  sql += ' Account.CUE_SEL_Tipo_Documento__c,';
		  sql += ' Account.CUE_TXT_Cbanc_Codigo_Entidad__c,';
		  sql += ' Account.CUE_TXT_Cbanc_Digito_Control__c,';
		  sql += ' Account.CUE_TXT_Cbanc_Numero__c,';
		  sql += ' Account.CUE_TXT_Cbanc_Pais__c,';
		  sql += ' Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,';
		  sql += ' Account.CUE_TXT_Condicion_Pago__c,';
		  sql += ' Account.CUE_TXT_Establecimiento__c,';
		  sql += ' Account.CUE_TXT_Identificador__c,';
		  sql += ' Account.CUE_TXT_Metodo_Pago__c,';
		  sql += ' Account.CUE_TXT_Nombre__c,';
		  sql += ' Account.CUE_TXT_Numero_Documento__c,';
		  sql += ' Account.CUE_TXT_Presentacion__c,';
		  sql += ' Account.CUE_TXT_PrimerApellido__c,';
		  sql += ' Account.CUE_TXT_SegundoApellido__c,';
		  sql += ' Account.Id,';
		  sql += ' Account.Name,';
		  sql += ' Account.Phone,';
		  sql += ' Account.RecordType.Name,';
		  sql += ' Account.ShippingCity,';
		  sql += ' Account.ShippingCountry,';
		  sql += ' Account.ShippingPostalCode,';
		  sql += ' Account.ShippingState,';
		  sql += ' Account.ShippingStreet,';
		  sql += ' Account.Type,';
		  sql += ' AccountId,';
		  sql += ' CAS_CAS_Apertura_Parcial__c,';
		  sql += ' CAS_CAS_Confirmado__c,';
		  sql += ' CAS_CAS_Danos_Perjudicado__c,';
		  sql += ' CAS_CAS_Danos_Propios__c,';
		  sql += ' CAS_CAS_Generar_Presupuesto__c,';
		  sql += ' CAS_CAS_Liquidado__c,';
		  sql += ' CAS_CAS_Reclamacion_Vinculada__c,';
		  sql += ' CAS_CAS_Requiere_Perito__c,';
		  sql += ' CAS_CAS_Siniestro_Consorciable__c,';
		  sql += ' CAS_CAS_Siniestro_Encuestado__c,';
		  sql += ' CAS_CAS_Siniestro_Facturado__c,';
		  sql += ' CAS_CAS_Siniestro_Grave__c,';
		  sql += ' CAS_CAS_Supera_Limite_Actuacion__c,';
		  sql += ' CAS_CAS_Tercero_Causante__c,';
		  sql += ' CAS_DAT_Fecha_Apertura__c,';
		  sql += ' CAS_DAT_Fecha_de_Aplazamiento__c,';
		  sql += ' CAS_DAT_Fecha_Informe_Pericial__c,';
		  sql += ' CAS_DAT_Fecha_Modificacion_Estado__c,';
		  sql += ' CAS_DAT_Fecha_Ocurrencia__c,';
		  sql += ' CAS_DAT_Fecha_Pago_Minuta__c,';
		  sql += ' CAS_DAT_Primera_Cita__c,';
		  sql += ' CAS_DIV_Importe_Total__c,';
		  sql += ' CAS_DIV_Pago_de_Minuta__c,';
		  sql += ' CAS_DIV_Total_Facturar_CIA_AI__c,';
		  sql += ' CAS_DIV_Total_Facturar_Cliente_AI__c,';
		  sql += ' CAS_DIV_Total_Facturar_Profesional__c,';
		  sql += ' CAS_EMA_Email__c,';
		  sql += ' CAS_EMA_Solicitud_Email__c,';
		  sql += ' CAS_FOR_Codigo_de_barras__c,';
		  sql += ' CAS_FOR_Descripcion_Baremo__c,';
		  sql += ' CAS_FOR_Direccion_Riesgo__c,';
		  sql += ' CAS_FOR_EsB2C__c,';
		  sql += ' CAS_FOR_Fecha_Cita_Reservada__c,';
		  sql += ' CAS_FOR_Importe_Total__c,';
		  sql += ' CAS_FOR_Limite_Actuacion__c,';
		  sql += ' CAS_FOR_Nombre_Solicitud__c,';
		  sql += ' CAS_FOR_OT_Principal_Urgente__c,';
		  sql += ' CAS_FOR_Producto__c,';
		  sql += ' CAS_FOR_Rango_Cita_Reservada__c,';
		  sql += ' CAS_FOR_RTDevName__c,';
		  sql += ' CAS_FOR_Tipo_Caso__c,';
		  sql += ' CAS_LKP_Ayuda_Indemnizable__c,';
		  sql += ' CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,';
		  sql += ' CAS_LKP_Baremo__c,';
		  sql += ' CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,';
		  sql += ' CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,';
		  sql += ' CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,';
		  sql += ' CAS_LKP_Cliente_contable__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,';
		  sql += ' CAS_LKP_Cliente_contable__r.Name,';
		  sql += ' CAS_LKP_Cliente_contable__r.Phone,';
		  sql += ' CAS_LKP_Cliente_contable__r.ShippingCity,';
		  sql += ' CAS_LKP_Cliente_contable__r.ShippingCountry,';
		  sql += ' CAS_LKP_Cliente_contable__r.ShippingPostalCode,';
		  sql += ' CAS_LKP_Cliente_contable__r.ShippingState,';
		  sql += ' CAS_LKP_Cliente_contable__r.ShippingStreet,';
		  sql += ' CAS_LKP_Cliente_contable_cliente__c,';
		  sql += ' CAS_LKP_Cliente_contable_cliente__r.Name,';
		  sql += ' CAS_LKP_Compania__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_TXT_Identificador__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,';
		  sql += ' CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,';
		  sql += ' CAS_LKP_Compania__r.Name,';
		  sql += ' CAS_LKP_Linea_de_Contrato__c,';
		  sql += ' CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,';
		  sql += ' CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,';
		  sql += ' CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,';
		  sql += ' CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,';
		  sql += ' CAS_LKP_Linea_de_Contrato__r.RecordTypeId,';
		  sql += ' CAS_LKP_Orden_Trabajo_Principal__c,';
		  sql += ' CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,';
		  sql += ' CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,';
		  sql += ' CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,';
		  sql += ' CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,';
		  sql += ' CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,';
		  sql += ' CAS_LKP_Perito__c,';
		  sql += ' CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,';
		  sql += ' CAS_LKP_PolizaContrato__c,';
		  sql += ' CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,';
		  sql += ' CAS_LKP_PolizaContrato__r.Name,';
		  sql += ' CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,';
		  sql += ' CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,';
		  sql += ' CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,';
		  sql += ' CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,';
		  sql += ' CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,';
		  sql += ' CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,';
		  sql += ' CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,';
		  sql += ' CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c,';
		  sql += ' CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,';
		  sql += ' CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,';
		  sql += ' CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,';
		  sql += ' CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,';
		  sql += ' CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,';
		  sql += ' CAS_LKP_Procedencia__c,';
		  sql += ' CAS_LKP_Procedencia__r.Name,';
		  sql += ' CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,';
		  sql += ' CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,';
		  sql += ' CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,';
		  sql += ' CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,';
		  sql += ' CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,';
		  sql += ' CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,';
		  sql += ' CAS_LKP_Punto_de_venta__c,';
		  sql += ' CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,';
		  sql += ' CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,';
		  sql += ' CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,';
		  sql += ' CAS_LKP_Recl_Orden_Trabajo__r.CaseId,';
		  sql += ' CAS_LKP_Responsable_Reclamacion__c,';
		  sql += ' CAS_LKP_Tipo_Trabajo__c,';
		  sql += ' CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,';
		  sql += ' CAS_LKP_VersionPolizaContrato__c,';
		  sql += ' CAS_NUM_Contador_Analisis__c,';
		  sql += ' CAS_NUM_Contador_Clic_Hogar__c,';
		  sql += ' CAS_NUM_Id_Actuacion_SondeoExt__c,';
		  sql += ' CAS_SEL_Causa_Averia__c,';
		  sql += ' CAS_SEL_Causante_Compania__c,';
		  sql += ' CAS_SEL_Causante_Provincia__c,';
		  sql += ' CAS_SEL_Causante_Responsable__c,';
		  sql += ' CAS_SEL_Causante_Tipo_Documento__c,';
		  sql += ' CAS_SEL_Comunicador_Recl__c,';
		  sql += ' CAS_SEL_Conformidad_del_Cliente__c,';
		  sql += ' CAS_SEL_Conformidad_del_Cliente_2__c,';
		  sql += ' CAS_SEL_Conformidad_del_Cliente_3__c,';
		  sql += ' CAS_SEL_Detalle_Averia__c,';
		  sql += ' CAS_SEL_Direccion_Territorial__c,';
		  sql += ' CAS_SEL_DirRiesgo_Estado_Provincia__c,';
		  sql += ' CAS_SEL_Encuestador__c,';
		  sql += ' CAS_SEL_Estado_Perito__c,';
		  sql += ' CAS_SEL_Gremio_Principal__c,';
		  sql += ' CAS_SEL_Grupo_Causa__c,';
		  sql += ' CAS_SEL_Metodo_de_pago__c,';
		  sql += ' CAS_SEL_Motivo_anulacion_reclamacion__c,';
		  sql += ' CAS_SEL_Motivo_de_Cierre__c,';
		  sql += ' CAS_SEL_Motivo_Indemnizable__c,';
		  sql += ' CAS_SEL_Motivo_No_Apertura__c,';
		  sql += ' CAS_SEL_Motivo_Peticion_Perito__c,';
		  sql += ' CAS_SEL_Motivo_Rechazo__c,';
		  sql += ' CAS_SEL_Motivo_rechazo_presupuesto__c,';
		  sql += ' CAS_SEL_Naturaleza__c,';
		  sql += ' CAS_SEL_Otros_Danos__c,';
		  sql += ' CAS_SEL_Padre_reclamacion__c,';
		  sql += ' CAS_SEL_Perito_de_RGA__c,';
		  sql += ' CAS_SEL_Rango_Cita__c,';
		  sql += ' CAS_SEL_Reclamacion__c,';
		  sql += ' CAS_SEL_Situacion_Danos_Propios__c,';
		  sql += ' CAS_SEL_Sondeo_DocIndemSug__c,';
		  sql += ' CAS_SEL_Sondeo_DocsIndemnizable__c,';
		  sql += ' CAS_SEL_Sondeo_Fase__c,';
		  sql += ' CAS_SEL_Sondeo_Gremios__c,';
		  sql += ' CAS_SEL_Tipo_Averia__c,';
		  sql += ' CAS_SEL_Tipo_Interlocutor__c,';
		  sql += ' CAS_SEL_Tipo_Llamada__c,';
		  sql += ' CAS_TFN_Solicitud_Telefono__c,';
		  sql += ' CAS_TFN_Telefono_1__c,';
		  sql += ' CAS_TFN_Telefono_2__c,';
		  sql += ' CAS_TXT_Apellidos__c,';
		  sql += ' CAS_TXT_Apellidos_2__c,';
		  sql += ' CAS_TXT_Ayuda_Ind_Apertura__c,';
		  sql += ' CAS_TXT_Causante_Direccion__c,';
		  sql += ' CAS_TXT_Causante_N_Documento__c,';
		  sql += ' CAS_TXT_Causante_N_exp_Stro__c,';
		  sql += ' CAS_TXT_Causante_Poblacion__c,';
		  sql += ' CAS_TXT_Causante_Poliza_R_C__c,';
		  sql += ' CAS_TXT_Codigo_Apertura__c,';
		  sql += ' CAS_TXT_Codigo_Campania_Origen__c,';
		  sql += ' CAS_TXT_Codigo_Comercial__c,';
		  sql += ' CAS_TXT_Codigo_Postal__c,';
		  sql += ' CAS_TXT_Direccion__c,';
		  sql += ' CAS_TXT_DirRiesgo_CP__c,';
		  sql += ' CAS_TXT_DirRiesgo_Pais__c,';
		  sql += ' CAS_TXT_DirRiesgo_Poblacion__c,';
		  sql += ' CAS_TXT_Estado_Anterior__c,';
		  sql += ' CAS_TXT_Identificador__c,';
		  sql += ' CAS_TXT_Identificador_DLC__c,';
		  sql += ' CAS_TXT_Motivo_Llamada__c,';
		  sql += ' CAS_TXT_Motivo_Reapertura__c,';
		  sql += ' CAS_TXT_Nombre__c,';
		  sql += ' CAS_TXT_Num_Caso_CIA__c,';
		  sql += ' CAS_TXT_Num_Caso_HS__c,';
		  sql += ' CAS_TXT_Password_Clic_Hogar__c,';
		  sql += ' CAS_TXT_Persona_que_llama__c,';
		  sql += ' CAS_TXT_Sondeo_Causa__c,';
		  sql += ' CAS_TXT_Sondeo_Grupo_Causa__c,';
		  sql += ' CAS_TXT_Sondeo_Tipo_de_Carta__c,';
		  sql += ' CAS_TXT_Subestado_Caso__c,';
		  sql += ' CAS_TXT_Subestado_Codigo__c,';
		  sql += ' CAS_TXT_Submotivo_Perito__c,';
		  sql += ' CAS_TXT_texto_observaciones_RGA__c,';
		  sql += ' CAS_TXT_Tipo_Encuesta__c,';
		  sql += ' CAS_TXT_Usuario_Clic_Hogar__c,';
		  sql += ' CAS_TXT_WF_Compania__c,';
		  sql += ' CaseNumber,';
		  sql += ' ClosedDate,';
		  sql += ' Contact.CON_CAS_ContactoDummy__c,';
		  sql += ' ContactEmail,';
		  sql += ' ContactId,';
		  sql += ' CreatedDate,';
		  sql += ' LastModifiedDate,';
		  sql += ' Origin,';
		  sql += ' Owner.Name,';
		  sql += ' Owner.Type,';
		  sql += ' OwnerId,';
		  sql += ' Parent.CAS_TXT_Num_Caso_CIA__c,';
		  sql += ' Parent.CaseNumber,';
		  sql += ' Parent.Type,';
		  sql += ' ParentId,';
		  sql += ' recordtype.DeveloperName,';
		  sql += ' Recordtype.Name,';
		  sql += ' RecordTypeId,';
		  sql += ' Status,';
		  sql += ' Type';
		  sql += ' FROM Case';
		  if(filter != null && !filter.equals('')){
				sql += ' WHERE '+filter;
		  }
		  system.debug('>>>> Util_Caso.queryMapCaseByFilter.sql: '+sql);
		  for(List<Case> lista : database.query(sql)){
				mapa.putAll(lista);
		  }
		  return mapa;
	 }*/

	 /**
	  * Devuelve un mapa de Casos a partir de un conjunto de Ids.
	  * 
	  * @param setIds: Conjunto de Ids de Casos
	  * @return mapa de Casos vinculados a los Ids
	  */
	 /*public static Map<Id,Case> getMapaCasos(Set<Id> setIds){
		  if(setIds != null && (!setIds.isEmpty())){
				return queryMapCaseByFilter('Id IN (\''+String.join(new List<Id>(setIds),'\',\'')+'\')');
		  }
		  return new Map<Id,Case>();
		  Map<Id, Case> mapa = new Map<Id, Case>();
		  if(setIds != null && (!setIds.isEmpty())){
				mapa = new Map<Id, Case>(
					 [SELECT Id,
								AccountId,
								Account.Name,
								Account.CUE_FOR_DireccionEnvio__c,
								Account.CUE_EMA_Email__c,
								Account.Phone,
								CAS_CAS_Generar_Presupuesto__c,
								CAS_CAS_Liquidado__c,
								CAS_CAS_Siniestro_Facturado__c,
								CAS_CAS_Supera_Limite_Actuacion__c,
								CAS_DAT_Fecha_Apertura__c,
								CAS_DAT_Fecha_Modificacion_Estado__c,
								CAS_DAT_Fecha_de_Aplazamiento__c,
								CAS_DAT_Primera_Cita__c,
								CAS_DIV_Total_Facturar_CIA_AI__c,
								CAS_DIV_Total_Facturar_Cliente_AI__c,
								CAS_DIV_Total_Facturar_Profesional__c,
								CAS_EMA_Solicitud_Email__c,
								CAS_FOR_EsB2C__c,
								CAS_FOR_Importe_Total__c,
								CAS_FOR_Limite_Actuacion__c,
								CAS_FOR_RTDevName__c,
								CAS_FOR_Descripcion_Baremo__c,
								CAS_FOR_Fecha_Cita_Reservada__c,
								CAS_FOR_Rango_Cita_Reservada__c,
								CAS_LKP_Compania__c,
								CAS_LKP_PolizaContrato__c,
								CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
								CAS_LKP_Orden_Trabajo_Principal__c,
								CAS_LKP_Procedencia__c,
								CAS_LKP_Baremo__c,
								CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
								CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
								CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
								CAS_LKP_Responsable_Reclamacion__c,
								CAS_NUM_Id_Actuacion_SondeoExt__c,
								CAS_NUM_Contador_Analisis__c,
								CAS_SEL_Comunicador_Recl__c,
								CAS_SEL_Conformidad_del_Cliente__c,
								CAS_SEL_Conformidad_del_Cliente_2__c,
								CAS_SEL_Conformidad_del_Cliente_3__c,
								CAS_SEL_DirRiesgo_Estado_Provincia__c,
								CAS_SEL_Padre_reclamacion__c,
								CAS_SEL_Motivo_de_Cierre__c,
								CAS_SEL_Motivo_rechazo_presupuesto__c,
								CAS_SEL_Motivo_anulacion_reclamacion__c,
								CAS_SEL_Motivo_Indemnizable__c,
								CAS_SEL_Naturaleza__c,
								CAS_SEL_Reclamacion__c,
								CAS_SEL_Gremio_Principal__c,
								CAS_SEL_Rango_Cita__c,
								CAS_TXT_Direccion__c,
								CAS_TXT_DirRiesgo_CP__c,
								CAS_TXT_DirRiesgo_Pais__c,
								CAS_TXT_DirRiesgo_Poblacion__c,
								CAS_TXT_Estado_Anterior__c,
								CAS_TXT_Num_Caso_HS__c,
								CAS_TXT_Subestado_Caso__c,
								CAS_TXT_Subestado_Codigo__c,
								CAS_TXT_Identificador__c,
								CAS_CAS_Confirmado__c,
								CAS_TFN_Telefono_1__c,
								CAS_TFN_Solicitud_Telefono__c,
								CaseNumber,
								OwnerId,
								RecordTypeId,
								Recordtype.Name,
								Status,
								Type,
								ClosedDate,
								CAS_LKP_Procedencia__r.Name,
								CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c
					  FROM Case WHERE Id IN :setIds]);
		  }
		  return mapa;
	 }*/

	 /**
	  * Devuelve los Casos resultantes de la query construida en funcion de los parámetros.
	  *  
	  * @param setIdCaso: conjunto de IDs de los casos a buscar
	  * @param setIdPadre: conjunto de IDs de los casos padre
	  * @param tipo: tipo de búsqueda: 
	  *											 - 1 - Se buscan el que tenga los IDs de setIdCaso
	  *											 - 2 - Se buscan el que tenga los ParentId del setIdPadre
	  *											 - 3 - Se buscan el que tenga los IDs del setIdPadre
	  *
	  * @return mapa con los casos resultantes de la Query
	  */
	 /*public static Map<Id,Case> queryMapSiniCaso(Set<Id> setIdCaso, Set<Id> setIdPadre, Integer tipo){
		  if(tipo == 1 && setIdCaso != null && !setIdCaso.isEmpty()){
				return Util_Caso.queryMapCaseByFilter('Id IN (\''+String.join(new List<Id>(setIdCaso),'\',\'')+'\')');
		  }
		  if(tipo == 2 && setIdPadre != null && !setIdPadre.isEmpty()){
				return Util_Caso.queryMapCaseByFilter('ParentId IN (\''+String.join(new List<Id>(setIdPadre),'\',\'')+'\') AND Type = \''+Label.CAS_TIPO_INDEMNIZABLE+'\'');
		  }
		  if(tipo == 3 && setIdPadre != null && !setIdPadre.isEmpty()){
				return Util_Caso.queryMapCaseByFilter('Id IN (\''+String.join(new List<Id>(setIdPadre),'\',\'')+'\')');
		  }
		  return new Map<Id,Case>();
	 }*/

	 /**
	  * Devuelve los Casos filtrados por IDs, CUE_CAS_Permite_Servicio_CodActivac__c y CUE_TXT_Identificador__c.
	  *
	  * @param setIdCaso: IDs de casos
	  * @param permiteCodActivac: valor de CUE_CAS_Permite_Servicio_CodActivac__c
	  * @param identificadorComp: valor de CUE_TXT_Identificador__c
	  *
	  * @return mapa que contienen los Casos devueltos
	  */
	 public static Map<Id,Case> getCasosByIdServicioCodActivac(Set<Id> setIdCaso, Boolean permiteCodActivac, Set<String> identificadorComp){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setIdCaso != null && !setIdCaso.isEmpty() && permiteCodActivac != null && identificadorComp != null && !identificadorComp.isEmpty()){
				for(List<Case> lista : [SELECT Id,
												Account.CUE_EMA_Email__c,
												Account.CUE_FOR_DireccionEnvio__c,
												Account.CUE_FOR_IBAN__c,
												Account.CUE_FOR_RTDevName__c,
												Account.CUE_LKP_Cuenta_principal__c,
												Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
												Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
												Account.CUE_SEL_Idioma__c,
												Account.CUE_SEL_Pais__c,
												Account.CUE_SEL_Provincia__c,
												Account.CUE_SEL_Tipo_Documento__c,
												Account.CUE_TXT_Cbanc_Codigo_Entidad__c,
												Account.CUE_TXT_Cbanc_Digito_Control__c,
												Account.CUE_TXT_Cbanc_Numero__c,
												Account.CUE_TXT_Cbanc_Pais__c,
												Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,
												Account.CUE_TXT_Condicion_Pago__c,
												Account.CUE_TXT_Establecimiento__c,
												Account.CUE_TXT_Identificador__c,
												Account.CUE_TXT_Metodo_Pago__c,
												Account.CUE_TXT_Nombre__c,
												Account.CUE_TXT_Numero_Documento__c,
												Account.CUE_TXT_Presentacion__c,
												Account.CUE_TXT_PrimerApellido__c,
												Account.CUE_TXT_SegundoApellido__c,
												Account.Name,
												Account.Phone,
												Account.RecordType.Name,
												Account.ShippingCity,
												Account.ShippingCountry,
												Account.ShippingPostalCode,
												Account.ShippingState,
												Account.ShippingStreet,
												Account.Type,
												AccountId,
												CAS_CAS_Apertura_Parcial__c,
												CAS_CAS_Confirmado__c,
												CAS_CAS_Danos_Perjudicado__c,
												CAS_CAS_Danos_Propios__c,
												CAS_CAS_Generar_Presupuesto__c,
												CAS_CAS_Liquidado__c,
												CAS_CAS_Reclamacion_Vinculada__c,
												CAS_CAS_Requiere_Perito__c,
												CAS_CAS_Siniestro_Consorciable__c,
												CAS_CAS_Siniestro_Encuestado__c,
												CAS_CAS_Siniestro_Facturado__c,
												CAS_CAS_Siniestro_Grave__c,
												CAS_CAS_Supera_Limite_Actuacion__c,
												CAS_CAS_Tercero_Causante__c,
												CAS_DAT_Fecha_Apertura__c,
												CAS_DAT_Fecha_de_Aplazamiento__c,
												CAS_DAT_Fecha_Informe_Pericial__c,
												CAS_DAT_Fecha_Modificacion_Estado__c,
												CAS_DAT_Fecha_Ocurrencia__c,
												CAS_DAT_Fecha_Pago_Minuta__c,
												CAS_DAT_Primera_Cita__c,
												CAS_DIV_Importe_Total__c,
												CAS_DIV_Pago_de_Minuta__c,
												CAS_DIV_Total_Facturar_CIA_AI__c,
												CAS_DIV_Total_Facturar_Cliente_AI__c,
												CAS_DIV_Total_Facturar_Profesional__c,
												CAS_EMA_Email__c,
												CAS_EMA_Solicitud_Email__c,
												CAS_FOR_Codigo_de_barras__c,
												CAS_FOR_Descripcion_Baremo__c,
												CAS_FOR_Direccion_Riesgo__c,
												CAS_FOR_EsB2C__c,
												CAS_FOR_Fecha_Cita_Reservada__c,
												CAS_FOR_Importe_Total__c,
												CAS_FOR_Limite_Actuacion__c,
												CAS_FOR_Nombre_Solicitud__c,
												CAS_FOR_OT_Principal_Urgente__c,
												CAS_FOR_Producto__c,
												CAS_FOR_Rango_Cita_Reservada__c,
												CAS_FOR_RTDevName__c,
												CAS_FOR_Tipo_Caso__c,
												CAS_LKP_Ayuda_Indemnizable__c,
												CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
												CAS_LKP_Baremo__c,
												CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
												CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
												CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
												CAS_LKP_Cliente_contable__c,
												CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
												CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
												CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
												CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,
												CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
												CAS_LKP_Cliente_contable__r.Name,
												CAS_LKP_Cliente_contable__r.Phone,
												CAS_LKP_Cliente_contable__r.ShippingCity,
												CAS_LKP_Cliente_contable__r.ShippingCountry,
												CAS_LKP_Cliente_contable__r.ShippingPostalCode,
												CAS_LKP_Cliente_contable__r.ShippingState,
												CAS_LKP_Cliente_contable__r.ShippingStreet,
												CAS_LKP_Cliente_contable_cliente__c,
												CAS_LKP_Cliente_contable_cliente__r.Name,
												CAS_LKP_Compania__c,
												CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
												CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
												CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
												CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
												CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
												CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
												CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
												CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
												CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
												CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
												CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
												CAS_LKP_Compania__r.Name,
												CAS_LKP_Linea_de_Contrato__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
												CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
												CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
												CAS_LKP_Orden_Trabajo_Principal__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
												CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
												CAS_LKP_Perito__c,
												CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
												CAS_LKP_PolizaContrato__c,
												CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
												CAS_LKP_PolizaContrato__r.name,
												CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
												CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
												CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
												CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
												CAS_LKP_Procedencia__c,
												CAS_LKP_Procedencia__r.Name,
												CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
												CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
												CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
												CAS_LKP_Punto_de_venta__c,
												CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
												CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
												CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
												CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
												CAS_LKP_Responsable_Reclamacion__c,
												CAS_LKP_Tipo_Trabajo__c,
												CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
												CAS_NUM_Contador_Analisis__c,
												CAS_NUM_Contador_Clic_Hogar__c,
												CAS_NUM_Id_Actuacion_SondeoExt__c,
												CAS_SEL_Causa_Averia__c,
												CAS_SEL_Causante_Compania__c,
												CAS_SEL_Causante_Provincia__c,
												CAS_SEL_Causante_Responsable__c,
												CAS_SEL_Causante_Tipo_Documento__c,
												CAS_SEL_Comunicador_Recl__c,
												CAS_SEL_Conformidad_del_Cliente__c,
												CAS_SEL_Conformidad_del_Cliente_2__c,
												CAS_SEL_Conformidad_del_Cliente_3__c,
												CAS_SEL_Detalle_Averia__c,
												CAS_SEL_Direccion_Territorial__c,
												CAS_SEL_DirRiesgo_Estado_Provincia__c,
												CAS_SEL_Encuestador__c,
												CAS_SEL_Estado_Perito__c,
												CAS_SEL_Gremio_Principal__c,
												CAS_SEL_Grupo_Causa__c,
												CAS_SEL_Metodo_de_pago__c,
												CAS_SEL_Motivo_anulacion_reclamacion__c,
												CAS_SEL_Motivo_de_Cierre__c,
												CAS_SEL_Motivo_Indemnizable__c,
												CAS_SEL_Motivo_No_Apertura__c,
												CAS_SEL_Motivo_Peticion_Perito__c,
												CAS_SEL_Motivo_Reapertura__c,
												CAS_SEL_Motivo_Rechazo__c,
												CAS_SEL_Motivo_rechazo_presupuesto__c,
												CAS_SEL_Naturaleza__c,
												CAS_SEL_Otros_Danos__c,
												CAS_SEL_Padre_reclamacion__c,
												CAS_SEL_Perito_de_RGA__c,
												CAS_SEL_Rango_Cita__c,
												CAS_SEL_Reclamacion__c,
												CAS_SEL_Situacion_Danos_Propios__c,
												CAS_SEL_Sondeo_DocIndemSug__c,
												CAS_SEL_Sondeo_DocsIndemnizable__c,
												CAS_SEL_Sondeo_Fase__c,
												CAS_SEL_Sondeo_Gremios__c,
												CAS_SEL_Tipo_Averia__c,
												CAS_SEL_Tipo_Interlocutor__c,
												CAS_SEL_Tipo_Llamada__c,
												CAS_TFN_Solicitud_Telefono__c,
												CAS_TFN_Telefono_1__c,
												CAS_TFN_Telefono_2__c,
												CAS_TXT_Apellidos__c,
												CAS_TXT_Apellidos_2__c,
												CAS_TXT_Ayuda_Ind_Apertura__c,
												CAS_TXT_Causante_Direccion__c,
												CAS_TXT_Causante_N_Documento__c,
												CAS_TXT_Causante_N_exp_Stro__c,
												CAS_TXT_Causante_Poblacion__c,
												CAS_TXT_Causante_Poliza_R_C__c,
												CAS_TXT_Codigo_Apertura__c,
												CAS_TXT_Codigo_Campania_Origen__c,
												CAS_TXT_Codigo_Comercial__c,
												CAS_TXT_Codigo_Postal__c,
												CAS_TXT_Direccion__c,
												CAS_TXT_DirRiesgo_CP__c,
												CAS_TXT_DirRiesgo_Pais__c,
												CAS_TXT_DirRiesgo_Poblacion__c,
												CAS_TXT_Estado_Anterior__c,
												CAS_TXT_Identificador__c,
												CAS_TXT_Identificador_DLC__c,
												CAS_TXT_Motivo_Llamada__c,
												CAS_TXT_Motivo_Reapertura__c,
												CAS_TXT_Nombre__c,
												CAS_TXT_Num_Caso_CIA__c,
												CAS_TXT_Num_Caso_HS__c,
												CAS_TXT_Password_Clic_Hogar__c,
												CAS_TXT_Persona_que_llama__c,
												CAS_TXT_Sondeo_Causa__c,
												CAS_TXT_Sondeo_Grupo_Causa__c,
												CAS_TXT_Sondeo_Tipo_de_Carta__c,
												CAS_TXT_Subestado_Caso__c,
												CAS_TXT_Subestado_Codigo__c,
												CAS_TXT_Submotivo_Perito__c,
												CAS_TXT_texto_observaciones_RGA__c,
												CAS_TXT_Tipo_Encuesta__c,
												CAS_TXT_Usuario_Clic_Hogar__c,
												CAS_TXT_WF_Compania__c,
												CaseNumber,
												ClosedDate,
												Contact.CON_CAS_ContactoDummy__c,
												ContactEmail,
												ContactId,
												CreatedDate,
												LastModifiedDate,
												Origin,
												Owner.Name,
												Owner.Type,
												OwnerId,
												Parent.CAS_TXT_Num_Caso_CIA__c,
												Parent.CaseNumber,
												Parent.Type,
												ParentId,
												recordtype.DeveloperName,
												RecordType.Name,
												RecordTypeId,
												Status,
												Type
										FROM Case
										WHERE Id IN :setIdCaso AND (CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c = :permiteCodActivac OR CAS_LKP_Compania__r.CUE_TXT_Identificador__c = :identificadorComp)]){
					 mapa.putAll(lista);
				}			  
		  }
		  return mapa;
	 }


 /**
 * getMapaCasosHijosByParentId: Devuelve un mapa de Casos asociados a los padres tienen un id contenido en el set que se pasa como argumento
 * 
 * @param setIds: Conjunto de Ids de Casos padre
 * @return mapa de Casos con padre en el set de ids
 */
	 public static Map<Id, Case> getMapaCasosHijosByParentId(Set<Id> setParentIds){
		  Map<Id, Case> mapa = new Map<Id, Case>();
		  if(setParentIds != null && (!setParentIds.isEmpty())){
				for(List<Case> registro : 
					 [ SELECT	 Id,
								AccountId,
								Account.Name,
								Account.CUE_FOR_DireccionEnvio__c,
								Account.CUE_EMA_Email__c,
								Account.Phone,
								CAS_CAS_Generar_Presupuesto__c,
								CAS_CAS_Liquidado__c,
								CAS_CAS_Siniestro_Facturado__c,
								CAS_CAS_Supera_Limite_Actuacion__c,
								CAS_DAT_Fecha_Apertura__c,
								CAS_DAT_Fecha_Modificacion_Estado__c,
								CAS_DAT_Fecha_de_Aplazamiento__c,
								CAS_DAT_Primera_Cita__c,
								CAS_DIV_Total_Facturar_CIA_AI__c,
								CAS_DIV_Total_Facturar_Cliente_AI__c,
								CAS_DIV_Total_Facturar_Profesional__c,
								CAS_EMA_Solicitud_Email__c,
								CAS_FOR_EsB2C__c,
								CAS_FOR_Importe_Total__c,
								CAS_FOR_Limite_Actuacion__c,
								CAS_FOR_RTDevName__c,
								CAS_FOR_Descripcion_Baremo__c,
								CAS_FOR_Fecha_Cita_Reservada__c,
								CAS_FOR_Rango_Cita_Reservada__c,
								CAS_LKP_Compania__c,
								CAS_LKP_PolizaContrato__c,
								CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
								CAS_LKP_Orden_Trabajo_Principal__c,
								CAS_LKP_Procedencia__c,
								CAS_LKP_Baremo__c,
								CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
								CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
								CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
								CAS_NUM_Id_Actuacion_SondeoExt__c,
								CAS_NUM_Contador_Analisis__c,
								CAS_SEL_Comunicador_Recl__c,
								CAS_SEL_Conformidad_del_Cliente__c,
								CAS_SEL_Conformidad_del_Cliente_2__c,
								CAS_SEL_Conformidad_del_Cliente_3__c,
								CAS_SEL_DirRiesgo_Estado_Provincia__c,
								CAS_SEL_Padre_reclamacion__c,
								CAS_SEL_Motivo_de_Cierre__c,
								CAS_SEL_Motivo_rechazo_presupuesto__c,
								CAS_SEL_Motivo_anulacion_reclamacion__c,
								CAS_SEL_Motivo_Indemnizable__c,
								CAS_SEL_Naturaleza__c,
								CAS_SEL_Reclamacion__c,
								CAS_SEL_Gremio_Principal__c,
								CAS_SEL_Rango_Cita__c,
								CAS_TXT_Direccion__c,
								CAS_TXT_DirRiesgo_CP__c,
								CAS_TXT_DirRiesgo_Pais__c,
								CAS_TXT_DirRiesgo_Poblacion__c,
								CAS_TXT_Estado_Anterior__c,
								CAS_TXT_Num_Caso_HS__c,
								CAS_TXT_Subestado_Caso__c,
								CAS_TXT_Subestado_Codigo__c,
								CAS_TXT_Identificador__c,
								CAS_CAS_Confirmado__c,
								CAS_TFN_Telefono_1__c,
								CAS_TFN_Solicitud_Telefono__c,
								CaseNumber,
								CAS_CAS_Reclamacion_Vinculada__c,
								OwnerId,
								RecordTypeId,
								Recordtype.Name,
								Status,
								Type,
								ParentId
					  FROM	Case
					 WHERE	ParentId IN :setParentIds]
					  ){
					 mapa.putAll(registro);
				}
		  }
		  return mapa;
	 }


	/*
	 * getMapaSiniestrosHijosNoCerrados: Devuelve un mapa de Casos asociados a los padres tienen un id contenido en el set que se pasa como argumento y con un set de record types
	 * 
	 * @param setParentIds: Conjunto de Ids de Casos padre
	 * @param setrecordTypeIdReclamacion: 
	 * @return mapa de Casos con padre en el set de ids y los cuales no están cerrados.
	 */
	public static Map<Id, Case> getMapaSiniestrosHijosNoCerrados(Set<Id> setParentIds, Set<Id> setrecordTypeIdReclamacion){
		Map<Id, Case> mapa = new Map<Id, Case>();
		if(setParentIds != null && (!setParentIds.isEmpty()) && setrecordTypeIdReclamacion!=null && (!setrecordTypeIdReclamacion.isEmpty())){
			mapa = new Map<Id, Case>(
				[SELECT	Id,
						AccountId,
						Account.Name,
						Account.CUE_FOR_DireccionEnvio__c,
						Account.CUE_EMA_Email__c,
						Account.Phone,
						CAS_CAS_Generar_Presupuesto__c,
						CAS_CAS_Liquidado__c,
						CAS_CAS_Siniestro_Facturado__c,
						CAS_CAS_Supera_Limite_Actuacion__c,
						CAS_DAT_Fecha_Apertura__c,
						CAS_DAT_Fecha_Modificacion_Estado__c,
						CAS_DAT_Fecha_de_Aplazamiento__c,
						CAS_DAT_Primera_Cita__c,
						CAS_DIV_Total_Facturar_CIA_AI__c,
						CAS_DIV_Total_Facturar_Cliente_AI__c,
						CAS_DIV_Total_Facturar_Profesional__c,
						CAS_EMA_Solicitud_Email__c,
						CAS_FOR_EsB2C__c,
						CAS_FOR_Importe_Total__c,
						CAS_FOR_Limite_Actuacion__c,
						CAS_FOR_RTDevName__c,
						CAS_FOR_Descripcion_Baremo__c,
						CAS_FOR_Fecha_Cita_Reservada__c,
						CAS_FOR_Rango_Cita_Reservada__c,
						CAS_LKP_Compania__c,
						CAS_LKP_PolizaContrato__c,
						CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
						CAS_LKP_Orden_Trabajo_Principal__c,
						CAS_LKP_Procedencia__c,
						CAS_LKP_Baremo__c,
						CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
						CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
						CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
						CAS_NUM_Id_Actuacion_SondeoExt__c,
						CAS_NUM_Contador_Analisis__c,
						CAS_SEL_Comunicador_Recl__c,
						CAS_SEL_Conformidad_del_Cliente__c,
						CAS_SEL_Conformidad_del_Cliente_2__c,
						CAS_SEL_Conformidad_del_Cliente_3__c,
						CAS_SEL_DirRiesgo_Estado_Provincia__c,
						CAS_SEL_Padre_reclamacion__c,
						CAS_SEL_Motivo_de_Cierre__c,
						CAS_SEL_Motivo_rechazo_presupuesto__c,
						CAS_SEL_Motivo_anulacion_reclamacion__c,
						CAS_SEL_Motivo_Indemnizable__c,
						CAS_SEL_Naturaleza__c,
						CAS_SEL_Reclamacion__c,
						CAS_SEL_Gremio_Principal__c,
						CAS_SEL_Rango_Cita__c,
						CAS_TXT_Direccion__c,
						CAS_TXT_DirRiesgo_CP__c,
						CAS_TXT_DirRiesgo_Pais__c,
						CAS_TXT_DirRiesgo_Poblacion__c,
						CAS_TXT_Estado_Anterior__c,
						CAS_TXT_Num_Caso_HS__c,
						CAS_TXT_Subestado_Caso__c,
						CAS_TXT_Subestado_Codigo__c,
						CAS_TXT_Identificador__c,
						CAS_CAS_Confirmado__c,
						CAS_TFN_Telefono_1__c,
						CAS_TFN_Solicitud_Telefono__c,
						CaseNumber,
						CAS_CAS_Reclamacion_Vinculada__c,
						OwnerId,
						RecordTypeId,
						CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
						Recordtype.Name,
						Status,
						Type,
						ParentId
				 FROM Case
				 WHERE RecordTypeId IN :setrecordTypeIdReclamacion
				 AND Status != :Label.CAS_ESTADO_CERRADO_FACTURADO
				 AND Status != :Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR
				 AND Status != :Label.CAS_ESTADO_CERRADO
				 AND (ParentId IN :setParentIds OR CAS_LKP_Recl_Orden_Trabajo__r.CaseId IN :setParentIds)]);
		  }
		  return mapa;
	 }


	 /**
	  * Obtiene a partir de un tipo de actuación, una Compañía y un estado de un Siniestro,
	  * el Tipo de Registro de Caso correspondiente.
	  * 
	  * @param recordTypeId Id del Tipo de Registro actual del Siniestro
	  * @param tipoActuacion Tipo de Actuación del Siniestro
	  * @param compania Objeto Compañía del Siniestro
	  * @param estado Estado del Siniestro
	  * @return id del Tipo de Registro de Caso de Siniestro
	  */
	 public static Id getIdTipoDeRegistro(Id recordTypeId, String tipoActuacion, Account compania, String estado){
		  Id retRecordTypeId = recordTypeId;
		  String recordTypeName = null;
		  Boolean esSolicSiniestro = (estado == Label.SINI_ESTADO_NO_ABIERTO || estado == Label.SINI_ESTADO_PDTESONDEO || estado == Label.SINI_ESTADO_CUBIERTO);
		  Boolean esSiniestro = (tipoActuacion == Label.CAS_TIPO_REPARABLE 
					 || tipoActuacion == Label.CAS_TIPO_MIXTO
					 || tipoActuacion == Label.CAS_TIPO_INDEMNIZABLE 
					 || tipoActuacion == Label.CAS_TIPO_RECHAZADO
					 || tipoActuacion == Label.CAS_TIPO_ASISTENCIA_COBERTURA
					 || tipoActuacion == Label.CAS_TIPO_MANITAS
					 || tipoActuacion == Label.CAS_TIPO_SERVICIO_ESPECIAL_REP);
		  Boolean esMembership = (compania != null && compania.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP);

		  if(esSolicSiniestro){
				// Solicitud de Siniestro
				recordTypeName = Label.RT_CAS_SOLIC_SINIESTRO;
		  }
		  else if(esSiniestro && esMembership){
				// Siniestro Membership
				recordTypeName = Label.RT_CAS_SINIESTRO_MEMB;
		  }
		  else if(esSiniestro && (!esMembership)){
				// Siniestro
				recordTypeName = Label.RT_CAS_SINIESTRO;
		  } 
		  if(recordTypeName != null){
				retRecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(recordTypeName);
		  }
		  return retRecordTypeId;
	 } // FIN obtenerIdTipoDeRegistro

	 /**
	  * Setear la Dirección Territorial a partir de la Provincia de Riesgo
	  * @param caso Caso a actualizar
	  * @return caso actualizado
	  */
	 public static String devolverDireccionTerritorial(Case caso){
		  String ret = null;
		  if(caso != null && caso.CAS_SEL_DirRiesgo_Estado_Provincia__c != null){
				String provincia = caso.CAS_SEL_DirRiesgo_Estado_Provincia__c;
				if(provincia == '08'
						  ||provincia == '17' 
						  || provincia == '22' 
						  || provincia == '25' 
						  || provincia == '43'){
					 ret = Label.DT_BARCELONA;
				}
				else if(provincia == '02'
						  ||provincia == '03' 
						  || provincia == '07' 
						  || provincia == '12' 
						  || provincia == '16'
						  || provincia == '30'
						  || provincia == '44'
						  || provincia == '46'){
					 ret = Label.DT_VALENCIA;
				}
				else if(provincia == '04'
						  ||provincia == '06' 
						  || provincia == '10' 
						  || provincia == '11' 
						  || provincia == '13' 
						  || provincia == '14'
						  || provincia == '18'
						  || provincia == '21'
						  || provincia == '23'
						  || provincia == '29'
						  || provincia == '41'
						  || provincia == '51'
						  || provincia == '52'){
					 ret = Label.DT_SEVILLA;
				}
				else if(provincia == '05'
						  ||provincia == '19' 
						  || provincia == '28' 
						  || provincia == '40' 
						  || provincia == '45'){
					 ret = Label.DT_MADRID;
				}
				else if(provincia == '15'
						  ||provincia == '24' 
						  || provincia == '27' 
						  || provincia == '32' 
						  || provincia == '33'
						  || provincia == '34'
						  || provincia == '36'
						  || provincia == '37'
						  || provincia == '47'
						  || provincia == '49'){
					 ret = Label.DT_ASTURIAS;
				}
				else if(provincia == '01'
						  ||provincia == '09' 
						  || provincia == '20' 
						  || provincia == '26' 
						  || provincia == '31'
						  || provincia == '39'
						  || provincia == '42'
						  || provincia == '48'
						  || provincia == '50'){
					 ret = Label.DT_BILBAO;
				}
				else if(provincia == '35'
						  ||provincia == '38'){
					 ret = Label.DT_CANARIAS;
				}
		  }
		  return ret;
	 }// FIN devolverDireccionTerritorial

	 /**
	   * [PENDIENTE]
	   * 
	   * @param listaOT: [PENDIENTE]
	   * 
	   * @return [PENDIENTE]
	   */
	 public static Map<Id, Case> casosDeOT(List<WorkOrder> listaOT){
		  Map<Id, Case> mapaCasos = new Map<Id, Case>();
		  if(listaOT != null){
				Set<Id> setIdsCasos = new Set<Id>();
				for(WorkOrder wo: listaOT){
					 if(wo.CaseId != null){
						  setIdsCasos.add(wo.CaseId);
					 }
				}
				mapaCasos = new Map<Id, Case>(
					 [SELECT Id,
								Type,
								RecordTypeId,
								CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
								AccountId,
								CAS_LKP_Baremo__c
					 FROM Case
					 WHERE Id IN :setIdsCasos]);
		  }
		  return mapaCasos;
	 }

	 /**
	   * [PENDIENTE]
	   * 
	   * @param triggerNew: [PENDIENTE]
	   * @param mapaCuentas: [PENDIENTE]
	   * 
	   */
	 public static void completarDatosSemaforo(List<Case> triggerNew, Map<Id, Account> mapaCuentas){
		  //Cuando se ponga en estado 'En curso' el servicio recoge los números de días del semáforo desde metadatos.
		  system.debug('>>>>Completando Datos semaforo');
		  for(Case caso : triggerNew){
				system.debug('>>>>CompaniasMapa.get(caseNew.AccountId) : ' + mapaCuentas.get(caso.AccountId));
				//Las reclamaciones tienen sus propios contadores de tiempo
				if(caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
					 caso.CAS_DAT_Generar_Tarea_Semaforo__c = Datetime.newInstance(System.today().addDays(27),System.now().time()); //TODO: Label para dias?
				}else if(mapaCuentas.get(caso.AccountId) != null){
					 Casos__mdt casoMDT = Util_Metadatos.mapaCasosEstadoCIA.get(string.valueof(caso.Status) + String.valueOf(mapaCuentas.get(caso.AccountId).CUE_TXT_Identificador__c));
					 system.debug('>>>>CasoMDT ' + casoMDT);
					 if(casoMDT != null){
						  caso.CAS_NUM_Dias_Amarillo__c = casoMDT.MTD_CAS_NUM_Dias_amarillo__c;
						  caso.CAS_NUM_Dias_Verde__c = casoMDT.MTD_CAS_NUM_Dias_verde__c;  
						  if(casoMDT.MTD_CAS_CAS_Tarea__c){
								caso.CAS_DAT_Generar_Tarea_Semaforo__c = Datetime.newInstance(System.today().addDays(Integer.valueOf(casoMDT.MTD_CAS_NUM_Dias_verde__c)),System.now().time());
						  }
						  //caso.CAS_DAT_Fecha_Semaforo_Rojo__c = Datetime.newInstance(System.today().addDays(Integer.valueOf(casoMDT.MTD_CAS_NUM_Dias_verde__c + casoMDT.MTD_CAS_NUM_Dias_amarillo__c)),System.now().time());
					 }	
				}
		  }
	 }//FIN completarDatosSemaforo()


	 /**
	   * [PENDIENTE]
	   * 
	   * @param caseNew: [PENDIENTE]
	   * @param caseOld: [PENDIENTE]
	   * 
	   */
	 public static void actualizarFechasParo(Case caseNew, Case caseOld){
		  //Cuando pasa el caso a un estado pendiente de cliente/CIA, el contador del semáforo se para
		  if(caseOld != null){
				if((caseNew.Status != LABEL.CAS_ESTADO_EN_CURSO 
						  || !String.isBlank(caseNew.CAS_TXT_Subestado_Codigo__c)) 
						  && caseOld.Status == LABEL.CAS_ESTADO_EN_CURSO 
						  && String.isBlank(caseOld.CAS_TXT_Subestado_Codigo__c)){

					 if(caseNew.CAS_DAT_Fecha_Activacion_Contador__c != null){
						  caseNew.CAS_NUM_Tiempo_Acumulado__c += caseNew.CAS_DAT_Fecha_Activacion_Contador__c.date().daysBetween(date.today());
					 }
					 caseNew.CAS_DAT_Fecha_Activacion_Contador__c = null;
					 caseNew.CAS_DAT_Generar_Tarea_Semaforo__c = null;
					 //caseNew.CAS_DAT_Fecha_Semaforo_Rojo__c = null;
				}
				else if(caseNew.Status == LABEL.CAS_ESTADO_EN_CURSO 
						  && String.isBlank(caseNew.CAS_TXT_Subestado_Codigo__c) 
						  && (caseOld.Status != LABEL.CAS_ESTADO_EN_CURSO 
						  || !String.isBlank(caseOld.CAS_TXT_Subestado_Codigo__c))){
					 caseNew.CAS_DAT_Fecha_Activacion_Contador__c = date.today();
				}
		  }
	 }


	 /**
	   * [PENDIENTE]
	   * 
	   * @param mapaCasos: [PENDIENTE]
	   * @param mapaOTs: [PENDIENTE]
		* @param mapaWOActualizar: [PENDIENTE]
	   * 
	   * @return [PENDIENTE]
	   */
	 public static Map<Id, WorkOrder> heredarDatosCaseOT(Map<Id, Case> mapaCasos, Map<Id, WorkOrder> mapaOTs, Map<Id,Workorder> mapaWOActualizar){
		  //Map<Id, WorkOrder> mapaWODirecCambiadas = new Map<Id, WorkOrder>();
		  //Si se ha cambiado la direccion de algun caso, actualizar las direcciones de las WO vinculadas a ese caso
		  for(WorkOrder wo : mapaOTs.values()){
				
				Workorder woAct = mapaWOActualizar.get(wo.Id);
				if(woAct == null)
					 woAct = new Workorder(Id=wo.Id);
				
				
				Case caso = mapaCasos.get(wo.CaseId);
				if(caso != null){
					 String provincia = Util_Listas_seleccion.getLabelDesdeAPI('Case','CAS_SEL_DirRiesgo_Estado_Provincia__c').get(caso.CAS_SEL_DirRiesgo_Estado_Provincia__c);
					 Boolean actualizarWo = false;
					 if(wo.Street != caso.CAS_TXT_Direccion__c){
						  woAct.Street = caso.CAS_TXT_Direccion__c;
						  actualizarWo = true;
					 }
					 if(wo.City != caso.CAS_TXT_DirRiesgo_Poblacion__c){
						  woAct.City = caso.CAS_TXT_DirRiesgo_Poblacion__c;
						  actualizarWo = true;
					 }
					 if(wo.State != provincia){
						  woAct.State = provincia;
						  actualizarWo = true;
					 }
					 if(wo.Country != caso.CAS_TXT_DirRiesgo_Pais__c){
						  woAct.Country = caso.CAS_TXT_DirRiesgo_Pais__c;
						  actualizarWo = true;
					 }
					 if(wo.PostalCode != caso.CAS_TXT_DirRiesgo_CP__c){
						  woAct.PostalCode = caso.CAS_TXT_DirRiesgo_CP__c;
						  actualizarWo = true;
					 }
					 if(wo.OwnerId != caso.OwnerId && caso.OwnerId.getSObjectType() != Schema.Group.getSObjectType()){
						  woAct.OwnerId = caso.OwnerId;
						  actualizarWo = true;
					 }
					 
					 if(actualizarWo){
						  mapaWOActualizar.put(woAct.Id, woAct);
					 }
				}
		  }
		  return mapaWOActualizar;
	 }

	 /**
	   * [PENDIENTE]
	   * 
	   * @param listaOTs: [PENDIENTE]
	   * 
	   * @return [PENDIENTE]
	   */
	 public static Decimal calcularTotalFacturarCIA(List<WorkOrder> listaOTs){
		  Decimal importeTotal = 0.0;
		  if(listaOTs != null){
				for(WorkOrder wo : listaOTs){
					 if(wo.Status != Label.OTR_ESTADO_ANULADO &&
								wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO &&
								wo.OTR_RES_Subtotal_Partidas__c != null){
						  importeTotal += wo.OTR_RES_Subtotal_Partidas__c;
					 }	
				}
		  }
		  return importeTotal;
	 }


	 /**
	   * [PENDIENTE]
	   * 
	   * @param listaOTs: [PENDIENTE]
	   * 
	   * @return [PENDIENTE]
	   */
	 public static Decimal calcularTotalFacturarCliente(List<WorkOrder> listaOTs){
		  Decimal importeTotal = 0.0;
		  if(listaOTs != null){
				for(WorkOrder wo : listaOTs){
					 if(wo.Status != Label.OTR_ESTADO_ANULADO &&
								wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO &&
								wo.OTR_RES_Facturar_Cliente_AI__c != null){
						  importeTotal += wo.OTR_RES_Facturar_Cliente_AI__c;
					 }	
				}
		  }
		  return importeTotal;
	 }


	 /**
	   * [PENDIENTE]
	   * 
	   * @param listaOTs: [PENDIENTE]
	   * 
	   * @return [PENDIENTE]
	   */
	 public static Decimal calcularTotalFacturarProfesional(List<WorkOrder> listaOTs){
		  Decimal importeTotal = 0.0;
		  if(listaOTs != null){
				for(WorkOrder wo : listaOTs){
					 if(wo.Status != Label.OTR_ESTADO_ANULADO &&
								wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO &&
								wo.OTR_RES_Liquidar_prof_AI__c != null){
						  importeTotal += wo.OTR_RES_Liquidar_prof_AI__c;
					 }	
				}
		  }
		  return importeTotal;
	 }

	 /**
	   * [PENDIENTE]
	   * 
	   * @param idCaso: [PENDIENTE]
	   * 
	   * @return [PENDIENTE]
	   */
	 public static List<WorkOrder> getListaOTsCaso(Id idCaso){
		  List<WorkOrder> lista = new List<WorkOrder>();
		  Set<Id> setIds = new Set<Id>();
		  if(idCaso != null){
				setIds.add(idCaso);
		  }
		  Map<Id, List<WorkOrder>> mapa = Util_Orden_Trabajo.getMapaOTsCasos(setIds);
		  if(mapa.get(idCaso) != null){
				lista = mapa.get(idCaso);
		  }
		  return lista;
	 }

	 /**
	  * Devuelve un mapa de Casos con sus Listas de Ordenes de Trabajo no anuladas.
	  * 
	  * @param setIds: Conjunto de Ids de Casos
	  * @return mapa de Casos con sus Listas de Ordenes de Trabajo no anuladas
	  *
	  * *************METODO DUPLICADO, AHORA SE USA EL DE UTIL_ORDEN_TRABAJO********************
	  *//*
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
								OTR_FOR_Proc_No_Requiere_Albaran__c,
								OTR_FOR_Proc_Numero_Fotos_Requeridas__c,
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
	 }*/
	 
	 /**
	  * Devuelve un mapa de Casos con sus Listas de todas sus Ordenes de Trabajo.
	  * 
	  * @param setIds: Conjunto de Ids de Casos
	  * @return mapa de Casos con sus Listas de todas sus Ordenes de Trabajo
	  *
	  * *************METODO DUPLICADO, AHORA SE USA EL DE UTIL_ORDEN_TRABAJO********************
	  *//*
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
								OTR_FOR_Proc_No_Requiere_Albaran__c,
								OTR_FOR_Proc_Numero_Fotos_Requeridas__c,
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
	 }*/
	 

	 /**
	   * [PENDIENTE]
	   * 
	   * @param idCaso: [PENDIENTE]
	   * 
	   * @return [PENDIENTE]
	   */
	 public static List<WorkOrderLineItem> getListaPartidasCaso(Id idCaso){
		  List<WorkOrderLineItem> lista = new List<WorkOrderLineItem>();
		  Set<Id> setIds = new Set<Id>();
		  if(idCaso != null){
				setIds.add(idCaso);
		  }
		  Map<Id, List<WorkOrderLineItem>> mapa = getMapaPartidasCasos(setIds);
		  if(mapa.get(idCaso) != null){
				lista = mapa.get(idCaso);
		  }
		  return lista;
	 }


	 /**
	  * Devuelve un mapa de Casos con sus Partidas no rechazadas.
	  * 
	  * @param setIds: Conjunto de Ids de Casos
	  * @return mapa de Casos con sus Partidas no rechazadas
	  */
	 public static Map<Id, List<WorkOrderLineItem>> getMapaPartidasCasos(Set<Id> setIds){
		  Map<Id, List<WorkOrderLineItem>> mapa = new Map<Id, List<WorkOrderLineItem>>();
		  system.debug(setIds + ' seteamos el id');
		  //List<WorkOrder> Prueba = [select id from WorkOrder WHERE WorkOrder.CaseId IN :setIds  AND Status NOT IN :Util_Partida.SET_ESTADOS_RECHAZADOS];
		  List<WorkOrder> Prueba = Util_Orden_Trabajo.getWorkOrderByCaseAndNotStatus(setIds,Util_Partida.SET_ESTADOS_RECHAZADOS).values(); 
		  system.debug(Prueba + ' ver si devuelve algo');
		  if(setIds != null && (!setIds.isEmpty())){
				List<WorkOrderLineItem> lista = new List<WorkOrderLineItem>();
				lista = Util_Partida.getWorkOrderLineItenByCaseAndNotStatus(setIds,Util_Partida.SET_ESTADOS_RECHAZADOS).values();
				/*List<WorkOrderLineItem> lista = new List<WorkOrderLineItem>(
					 [SELECT Id, 
								Status, 
								PAR_DIV_Facturacion_Total_AI__c,
								PAR_DIV_Facturacion_Total_DI__c,
								PAR_DIV_Cargar_Cliente_AI__c,
								PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
								PAR_FOR_Cargar_Comp_DI__c,
								PAR_FOR_Cargar_Cliente_DI__c,
								PAR_DIV_Cargar_Comp_AI__c,
								PAR_TXT_Detalle_WOLI__c,
								PAR_NUM_Unidades__c,
								Description,
								PAR_TXT_Baremo_Codigo__c,
								PAR_TXT_Baremo_Desc__c,
								PAR_DIV_Importe_a_Imputar_prof1__c,
								PAR_DIV_Importe_a_Imputar_prof2__c,
								PAR_DIV_Importe_a_Imputar_prof3__c,
								PAR_DIV_Importe_a_Imputar_gestor1__c,
								PAR_DIV_Importe_a_Imputar_gestor2__c,
								PAR_DIV_Importe_a_Imputar_gestor3__c,
								PAR_LKP_Imputar_a_prof1__c,
								PAR_LKP_Imputar_a_prof2__c,
								PAR_LKP_Imputar_a_prof3__c,
								PAR_LKP_Imputar_a_gestor1__c,
								PAR_LKP_Imputar_a_gestor2__c,
								PAR_LKP_Imputar_a_gestor3__c,
								WorkOrderId,
								WorkOrder.CaseId,
								WorkOrder.Status,
								WorkOrder.OTR_CAS_Urgente__c,
								WorkOrder.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,
								WorkOrder.OTR_SEL_Gremio__c,
								WorkOrder.OTR_TXT_Num_OrdenTrabajo_HS__c,
								WorkOrder.WorkOrderNumber
					  FROM WorkOrderLineItem WHERE WorkOrder.CaseId IN :setIds
					  //AND Status != :Label.PAR_ESTADO_RECHAZADA
					  AND Status NOT IN :Util_Partida.SET_ESTADOS_RECHAZADOS
					  ORDER BY WorkOrder.CaseId ASC]);*/
				for(WorkOrderLineItem registro : lista){
					 List<WorkOrderLineItem> listaAux = mapa.get(registro.WorkOrder.CaseId);
					 if(listaAux == null){
						  listaAux = new List<WorkOrderLineItem>();
					 }
					 listaAux.add(registro);
					 mapa.put(registro.WorkOrder.CaseId, listaAux);
				}
		  }
		  return mapa;
	 }



	 /**
	  * Actualiza caso y emite mensaje de error en caso de error(Para VF).
	  * 
	  * @param caso: Caso a actualizar
	  */
	 public static Boolean guardarCaso(Case caso){
		  Boolean exito = false;
		  system.Savepoint puntoGuardado = Database.setSavepoint();
		  try {
				update caso;
				exito = true;
		  }
		  catch(DMLException e){ //Este catch está para que las excepciones por validación de campo se muestren correctamente en la visual
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getDMLMessage(0)));
				system.debug(e.getStackTraceString());
		  }
		  catch(Exception e){
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				system.debug(e.getStackTraceString());
		  }
		  return exito;
	 }


	 /**
	  * Crea un comentario nuevo vinculado a un caso.
	  * 
	  * @param idCaso Id del Caso
	  * @param comentario Texto del comentario
	  * @return objeto Comentario_caso__c correspondiente al nuevo comentario
	  */
	 public static Comentario_caso__c crearComentarioCaso(Id idCaso, String comentario)
	 {
		  Comentario_caso__c comentarioCaso = null;
		  if(idCaso != null && comentario != null && comentario != '')
		  {
				comentarioCaso = new Comentario_caso__c();
				comentarioCaso.CMC_LKP_Caso__c = idCaso;
				comentarioCaso.CMC_TXT_Comentario__c = comentario;
		  }
		  return comentarioCaso;
	 } // FIN crearComentarioCaso


	 /**
	  * Devuelve un mapa de Casos con sus Partidas no rechazadas.
	  * 
	  * @param setIds: Conjunto de Ids de Casos
	  * @return mapa de Casos con sus Partidas no rechazadas
	  *
	  *********** METODO DUPLICADO, AHORA SE USA EL DE UTIL_TAREA*************************
	  */
	 /*public static Map<Id, List<Task>> getMapaTareasCaso(Set<Id> setIds){
		  Map<Id, List<Task>> mapa = new Map<Id, List<Task>>();
		  if(setIds != null && (!setIds.isEmpty())){
				List<Task> lista = new List<Task>(
					 [SELECT Id,
								Status,
								WhatId,
								ownerId
					  FROM Task WHERE whatId IN :setIds
					  AND Status = :Label.TAR_ESTADO_EN_CURSO
					  ORDER BY whatId ASC]);
				for(Task registro : lista){
					 List<Task> listaAux = mapa.get(registro.whatId);
					 if(listaAux == null){
						  listaAux = new List<Task>();
					 }
					 listaAux.add(registro);
					 mapa.put(registro.whatId, listaAux);
				}
		  }
		  return mapa;
	 }*/

	 /**
	  * Devuelve un mapa de Casos con su último Presupuesto.
	  * 
	  * @param setIds: Conjunto de Ids de Casos
	  * @return mapa de Casos con su último Presupuesto
	  ******* METODO DUPLICADO, AHORA SE USA EL DE UTIL_PRESUPUESTO *****************
	  */
	 /*public static Map<Id, Presupuesto__c> getMapaUltPresupCasos(Set<Id> setIds){
		  Map<Id, Presupuesto__c> mapa = new Map<Id, Presupuesto__c>();
		  if(setIds != null && (!setIds.isEmpty())){
				List<Presupuesto__c> lista = new List<Presupuesto__c>(
					 [SELECT Id,
								CreatedDate,
								Name,
								PRE_LKP_Caso__c,
								PRE_NUM_Version__c,
								PRE_RES_Importe_total__c,
								PRE_RES_Importe_Total_Cia_AI__c,
								PRE_RES_Importe_Total_Cia_DI__c,
								PRE_RES_Importe_Total_Cliente_AI__c,
								PRE_RES_Importe_Total_Cliente_DI__c,
								PRE_RES_Importe_Total_DI__c,
								PRE_RES_Porcentaje_Imp_Cia_Cliente__c,
								PRE_SEL_Motivo_Rechazo__c,
								PRE_SEL_Estado__c,
								PRE_SEL_Estado_Anterior__c,
								PRE_TXT_Identificador__c,
								PRE_TXT_MotivoAprobacion__c
					  FROM Presupuesto__c WHERE PRE_LKP_Caso__c IN :setIds
					  ORDER BY PRE_LKP_Caso__c ASC, PRE_NUM_Version__c DESC]);
				for(Presupuesto__c registro : lista){
					 if(mapa.get(registro.PRE_LKP_Caso__c) == null){
						  mapa.put(registro.PRE_LKP_Caso__c, registro);
					 }
				}
		  }
		  return mapa;
	 }*/
	 
	 /**
	  * Devuelve un mapa de Casos con su lista de shares manuales.
	  * 
	  * @param setIds: conjunto de ids de Casos
	  * @return mapa relacionando el Id de cada Caso con su lista de shares manuales
	  */
	 public static Map<Id, List<CaseShare>> getMapaSharesCaso(Set<Id> setIds){		 
		  Map<Id,List<CaseShare>> mapa = new Map<Id,List<CaseShare>>();	
		  if(setIds != null && (!setIds.isEmpty())){
				List<CaseShare> lista = [SELECT Id, CaseId, UserOrGroupId
														FROM CaseShare
														WHERE CaseId IN :setIds
														AND RowCause = 'Manual'];													
				for(CaseShare registro : lista){
					 List<CaseShare> listaAux = mapa.get(registro.CaseId);
					 if(listaAux == null){
						  listaAux = new List<CaseShare>();
					 }
					 listaAux.add(registro);
					 mapa.put(registro.CaseId, listaAux);
				}
		  }
		  return mapa;
	 }
	 
	 
	 
	 /**
	  * Recalcula la compartición de profesionales para un set de casos y sus wo.
	  * 
	  * @param setIds: conjunto de ids de Casos
	  * 
	  */
	 public static void recalcularShares(Set<Id> casos){
		  Map<Id, List<CaseShare>> mapaSharesCaso = getMapaSharesCaso(casos);
		  Map<Id, List<WorkOrder>> woPorCaso = Util_Orden_Trabajo.getMapaOTsCasosFull(casos);
		  Map<Id,Id> woCaso = new Map<Id,Id>();
		  Set<Id> todasWo = new Set<Id>();
		  Set<Id> todosSR = new Set<Id>();
		  Map<Id,Set<Id>> srPorCaso = new Map<Id,Set<Id>>();
		  Map<Id,Set<Id>> srPorWOExtra = new Map<Id,Set<Id>>();
		  Map<Id,Id> casoOwner = new Map<Id,Id>();
		  for(List<Workorder> listaWO: woPorCaso.values()){
				for(Workorder wo: listaWO){
					 woCaso.put(wo.Id,wo.CaseId);
					 todasWo.add(wo.Id);
					 todosSr.add(wo.OTR_LKP_Recurso_Servicio__c);
					 casoOwner.put(wo.CaseId,wo.Case.OwnerID);
					 if(wo.OTR_LKP_Recurso_Servicio__c != null){
						  Set<Id> srTemp = srPorCaso.get(wo.CaseId);
						  if(srTemp == null)
								srTemp = new Set<Id>();
								
						  srTemp.add(wo.OTR_LKP_Recurso_Servicio__r.RelatedRecordId);
						  srPorCaso.put(wo.CaseId,srTemp);
					 }
				}
		  }
		  
		  Map<Id, List<WorkOrderShare>> mapaSharesWO = Util_Orden_Trabajo.getMapaSharesOT(todasWO);
		  
		  List<AssignedResource> recursosAsignadosWO = Util_Service_Resource.getMapAssignedResourcesByWO(todasWO).values();
		  
		  for(AssignedResource rec: recursosAsignadosWO){
				Set<Id> srTemp = srPorWOExtra.get(rec.ServiceAppointment.ParentRecordId);
				if(srTemp == null)
					 srTemp = new Set<Id>();
					 
				srTemp.add(rec.ServiceResource.RelatedRecordId);
				srPorWOExtra.put(rec.ServiceAppointment.ParentRecordId,srTemp);
				todosSr.add(rec.ServiceResource.RelatedRecordId);
				/*Set<Id> srTemp = srPorCaso.get(woCaso.get(rec.ServiceAppointment.ParentRecordId));
				if(srTemp == null)
					 srTemp = new Set<Id>();
					 
				srTemp.add(rec.ServiceResource.RelatedRecordId);
				srPorCaso.put(woCaso.get(rec.ServiceAppointment.ParentRecordId),srTemp);
				todosSr.add(rec.ServiceResource.RelatedRecordId);*/
		  }
		  
		  
		  Map<Id,User> activos = Util_Perfiles_Usuario.queryMapUsuariosActivos(todosSr);		
		  List<sObject> sharesBorrar = new List<sObject>();
		  
		  List<CaseShare> sharesCasoInsertar = new List<CaseShare>();
		  List<WorkOrderShare> sharesWOInsertar = new List<WorkOrderShare>();
		  
		  for(List<CaseShare> listaShare: mapaSharesCaso.values()){
				sharesBorrar.addAll(listaShare);
		  }
		  for(List<WorkOrderShare> listaShare: mapaSharesWO.values()){
				sharesBorrar.addAll(listaShare);
		  }
		  
		  system.debug('-----srPorCaso: '+srPorCaso);
		  system.debug('-----srPorWOExtra: '+srPorWOExtra);
		  
		  
		  for(Id casoId: casos){
				Set<Id> srTemp = srPorCaso.get(casoId);
				if(srTemp != null && !srTemp.isEmpty()){
					 for(Id recurso: srTemp){
						  if(activos.ContainsKey(recurso) && recurso != casoOwner.get(casoId)){
								sharesCasoInsertar.add(new CaseShare(CaseId=casoId,UserOrGroupId=recurso,RowCause='Manual',CaseAccessLevel='Edit'));
						  }
					 }
				}
				
				List<Workorder> woRelacionadas = woPorCaso.get(casoId);
				if(woRelacionadas != null){
					 for(Workorder wo: woRelacionadas){
						  if(srTemp != null && !srTemp.isEmpty()){
								for(Id recurso: srTemp){
									 if(activos.ContainsKey(recurso) && wo.ownerId != recurso)
										  sharesWOInsertar.add(new WorkOrderShare(ParentId=wo.Id,UserOrGroupId=recurso,RowCause='Manual',AccessLevel='Edit'));
								}
						  }
						  
						  Set<Id> srWOTemp = srPorWOExtra.get(wo.Id);
						  if(srWOTemp != null && !srWOTemp.isEmpty()){
								for(Id recurso: srWOTemp){
									 if(activos.ContainsKey(recurso) && wo.ownerId != recurso && (srTemp == null || !srTemp.contains(recurso))){
										  sharesWOInsertar.add(new WorkOrderShare(ParentId=wo.Id,UserOrGroupId=recurso,RowCause='Manual',AccessLevel='Edit'));
									 }
								}
						  }
						  
					 }
				}
		  }
		  
		  system.debug(sharesBorrar);
		  system.debug(sharesCasoInsertar);
		  system.debug(sharesWOInsertar);
		  
		  if(!sharesBorrar.isEmpty()){
				delete(sharesBorrar);
		  }
		  if(!sharesCasoInsertar.isEmpty()){
				insert(sharesCasoInsertar);
		  }
		  if(!sharesWOInsertar.isEmpty()){
				insert(sharesWOInsertar);
		  }
	 }
	 
	 public static List<Database.saveResult> insertShares(List<CaseShare> lista){
		  return Database.Insert(lista,false);
	 }
	 
	 public static List<Database.DeleteResult> deleteShares(List<CaseShare> lista){
		  return Database.Delete(lista,false);
	 }
	 
	 /*public static Map<Id, Case> queryCasesById(Set<Id> setIdsCasos) {
		  Map<Id, Case> mapCaseById = new Map<Id, Case>();
		  if(!setIdsCasos.isEmpty()) {
				mapCaseById=new Map<Id,Case>([SELECT ID,Account.Name,CAS_LKP_Compania__r.Name,CAS_LKP_PolizaContrato__r.Name,CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,CAS_FOR_Direccion_Riesgo__c,Status,CAS_TXT_Subestado_Caso__c,CAS_CAS_Siniestro_Grave__c,CAS_TXT_Num_Caso_HS__c,CAS_TXT_Num_Caso_CIA__c,CAS_FOR_Limite_Actuacion__c,CAS_DIV_Importe_Total__c,RecordType.Name FROM Case WHERE ID IN :setIdsCasos LIMIT 2000]);
		  }
		  return mapCaseById;
	 }*/
	 
	 /**
	  * Método que marca los checks facturado/liquidado de caso usando la lógica de eventos y abonos
	  *
	  * @param casoFacturar: set de ids de caso
	  * @param eventosDeWO: map de eventos por caso
	  * @param abonosDeWO: map de abonos por caso
	  * @param woPorCaso: map de wo por caso
	  * @param casoUpdate: mapa donde se almacenan los casos a actualizar
	  *
	  * @return casos a actualizar
	  */
/*  public static Map<Id, Case> facturarCasoEventosAbonos(Set<Id> casoFacturar, Map<Id,List<Propuesta_de_Evento__c>> eventosDeCaso, 
																				Map<Id,List<Propuesta_de_abono__c>> abonosDeCaso, Map<Id,List<Workorder>> woPorcaso, Map<Id,Case> casoUpdate){
																					 
		  for(Id casoId: casoFacturar){
				List<Propuesta_de_evento__c> eventosCaso = eventosDeCaso.get(casoId);
				List<Propuesta_de_abono__c> abonosCaso = abonosDeCaso.get(casoId);
				List<Workorder> woCaso = woPorCaso.get(casoId);
				Map<String,Integer> nEventosPorTipo = new Map<String,Integer>{'Pago'=>0,'Cobro'=>0};
				Boolean facturar = true;
				Boolean liquidar = true;
				
				if(eventosCaso != null && !eventosCaso.isEmpty()){
					 for(Propuesta_de_evento__c evt: eventosCaso){
						  if(nEventosPorTipo.containsKey(evt.EV_AB_SEL_Tipo_de_Evento__c))
								nEventosPorTipo.put(evt.EV_AB_SEL_Tipo_de_Evento__c,nEventosPorTipo.get(evt.EV_AB_SEL_Tipo_de_Evento__c)+1);
						  
						  if(!evt.EV_AB_CAS_Evento_Ab_Facturado__c && evt.EV_AB_SEL_Tipo_de_Evento__c == 'Cobro'){
								liquidar = false;
						  } else if(!evt.EV_AB_CAS_Evento_Ab_Liquidado__c && evt.EV_AB_SEL_Tipo_de_Evento__c == 'Pago'){
								liquidar = false;
						  }
					 }
				}
				
				if(abonosCaso != null && !abonosCaso.isEmpty()){
					 for(Propuesta_de_abono__c ab: abonosCaso){
						  if(!ab.AB_CAS_Abono_Facturado__c){
								facturar = false;
						  }
					 }
				}
				
				if(woCaso != null && !woCaso.isEmpty()){
					 for(Workorder wo: woCaso){
						  if(!wo.OTR_CAS_Orden_Trabajo_Facturada__c){
								facturar = false;
						  }
						  if(!wo.OTR_CAS_Orden_Trabajo_Liquidada__c){
								liquidar = false;
						  }
					 }
				} else {
					 
					 if(eventosCaso == null || eventosCaso.isEmpty() || nEventosPorTipo.get('Pago') == 0)
						  liquidar = false;
				
					 if((eventosCaso == null || eventosCaso.isEmpty() || nEventosPorTipo.get('Cobro') == 0)
					 && (abonosCaso == null || abonosCaso.isEmpty())){
						  facturar = false;
					 }
				}
				
				if(facturar || liquidar){
					 Case caso = casoUpdate.get(casoId);
					 if(caso == null){
						  caso = new Case();
					 }
					 caso.Id = casoId;
					 
					 if(facturar){
						  caso.CAS_CAS_Siniestro_Facturado__c = true;
					 }
					 if(liquidar){
						  caso.CAS_CAS_Liquidado__c = true;
					 }
					 
					 casoUpdate.put(caso.Id,caso);
				}
					 
		  }
		  return casoUpdate;
	 }
	 */
	 /*
	 * Método para recuperar el caso.
	 * @param setCompanias: Conjunto de Compañías
	 * @param setNumHs: Conjunto de número de HomeServe
	 */
	 public static Map<Id,Case> queryCaseByCompaniaYNumeroHs(Set<String> setCompanias, Set<String> setnumHs) {
		  Map<Id, Case> mapCaso=new Map<Id, Case>();
		  if(!setCompanias.isEmpty() && !setNumHs.isEmpty()) {
				for(List<Case> listaCasosAux:[SELECT Id,
													Account.CUE_EMA_Email__c,
													Account.CUE_FOR_DireccionEnvio__c,
													Account.CUE_FOR_IBAN__c,
													Account.CUE_FOR_RTDevName__c,
													Account.CUE_LKP_Cuenta_principal__c,
													Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													Account.CUE_SEL_Idioma__c,
													Account.CUE_SEL_Pais__c,
													Account.CUE_SEL_Provincia__c,
													Account.CUE_SEL_Tipo_Documento__c,
													Account.CUE_TXT_Cbanc_Codigo_Entidad__c,
													Account.CUE_TXT_Cbanc_Digito_Control__c,
													Account.CUE_TXT_Cbanc_Numero__c,
													Account.CUE_TXT_Cbanc_Pais__c,
													Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,
													Account.CUE_TXT_Condicion_Pago__c,
													Account.CUE_TXT_Establecimiento__c,
													Account.CUE_TXT_Identificador__c,
													Account.CUE_TXT_Metodo_Pago__c,
													Account.CUE_TXT_Nombre__c,
													Account.CUE_TXT_Numero_Documento__c,
													Account.CUE_TXT_Presentacion__c,
													Account.CUE_TXT_PrimerApellido__c,
													Account.CUE_TXT_SegundoApellido__c,
													Account.Name,
													Account.Phone,
													Account.RecordType.Name,
													Account.ShippingCity,
													Account.ShippingCountry,
													Account.ShippingPostalCode,
													Account.ShippingState,
													Account.ShippingStreet,
													Account.Type,
													AccountId,
													CAS_CAS_Apertura_Parcial__c,
													CAS_CAS_Confirmado__c,
													CAS_CAS_Danos_Perjudicado__c,
													CAS_CAS_Danos_Propios__c,
													CAS_CAS_Generar_Presupuesto__c,
													CAS_CAS_Liquidado__c,
													CAS_CAS_Reclamacion_Vinculada__c,
													CAS_CAS_Requiere_Perito__c,
													CAS_CAS_Siniestro_Consorciable__c,
													CAS_CAS_Siniestro_Encuestado__c,
													CAS_CAS_Siniestro_Facturado__c,
													CAS_CAS_Siniestro_Grave__c,
													CAS_CAS_Supera_Limite_Actuacion__c,
													CAS_CAS_Tercero_Causante__c,
													CAS_DAT_Fecha_Apertura__c,
													CAS_DAT_Fecha_de_Aplazamiento__c,
													CAS_DAT_Fecha_Informe_Pericial__c,
													CAS_DAT_Fecha_Modificacion_Estado__c,
													CAS_DAT_Fecha_Ocurrencia__c,
													CAS_DAT_Fecha_Pago_Minuta__c,
													CAS_DAT_Primera_Cita__c,
													CAS_DIV_Importe_Total__c,
													CAS_DIV_Pago_de_Minuta__c,
													CAS_DIV_Total_Facturar_CIA_AI__c,
													CAS_DIV_Total_Facturar_Cliente_AI__c,
													CAS_DIV_Total_Facturar_Profesional__c,
													CAS_EMA_Email__c,
													CAS_EMA_Solicitud_Email__c,
													CAS_FOR_Codigo_de_barras__c,
													CAS_FOR_Descripcion_Baremo__c,
													CAS_FOR_Direccion_Riesgo__c,
													CAS_FOR_EsB2C__c,
													CAS_FOR_Fecha_Cita_Reservada__c,
													CAS_FOR_Importe_Total__c,
													CAS_FOR_Limite_Actuacion__c,
													CAS_FOR_Nombre_Solicitud__c,
													CAS_FOR_OT_Principal_Urgente__c,
													CAS_FOR_Producto__c,
													CAS_FOR_Rango_Cita_Reservada__c,
													CAS_FOR_RTDevName__c,
													CAS_FOR_Tipo_Caso__c,
													CAS_LKP_Ayuda_Indemnizable__c,
													CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
													CAS_LKP_Baremo__c,
													CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
													CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
													CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
													CAS_LKP_Cliente_contable__c,
													CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
													CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
													CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
													CAS_LKP_Cliente_contable__r.Name,
													CAS_LKP_Cliente_contable__r.Phone,
													CAS_LKP_Cliente_contable__r.ShippingCity,
													CAS_LKP_Cliente_contable__r.ShippingCountry,
													CAS_LKP_Cliente_contable__r.ShippingPostalCode,
													CAS_LKP_Cliente_contable__r.ShippingState,
													CAS_LKP_Cliente_contable__r.ShippingStreet,
													CAS_LKP_Cliente_contable_cliente__c,
													CAS_LKP_Cliente_contable_cliente__r.Name,
													CAS_LKP_Compania__c,
													CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
													CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
													CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
													CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
													CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
													CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
													CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
													CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
													CAS_LKP_Compania__r.Name,
													CAS_LKP_Linea_de_Contrato__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
													CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
													CAS_LKP_Orden_Trabajo_Principal__c,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
													CAS_LKP_Perito__c,
													CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
													CAS_LKP_PolizaContrato__c,
													CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
													CAS_LKP_PolizaContrato__r.name,
													CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
													CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
													CAS_LKP_Procedencia__c,
													CAS_LKP_Procedencia__r.Name,
													CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
													CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
													CAS_LKP_Punto_de_venta__c,
													CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
													CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
													CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
													CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
													CAS_LKP_Responsable_Reclamacion__c,
													CAS_LKP_Tipo_Trabajo__c,
													CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
													CAS_NUM_Contador_Analisis__c,
													CAS_NUM_Contador_Clic_Hogar__c,
													CAS_NUM_Id_Actuacion_SondeoExt__c,
													CAS_SEL_Causa_Averia__c,
													CAS_SEL_Causante_Compania__c,
													CAS_SEL_Causante_Provincia__c,
													CAS_SEL_Causante_Responsable__c,
													CAS_SEL_Causante_Tipo_Documento__c,
													CAS_SEL_Comunicador_Recl__c,
													CAS_SEL_Conformidad_del_Cliente__c,
													CAS_SEL_Conformidad_del_Cliente_2__c,
													CAS_SEL_Conformidad_del_Cliente_3__c,
													CAS_SEL_Detalle_Averia__c,
													CAS_SEL_Direccion_Territorial__c,
													CAS_SEL_DirRiesgo_Estado_Provincia__c,
													CAS_SEL_Encuestador__c,
													CAS_SEL_Estado_Perito__c,
													CAS_SEL_Gremio_Principal__c,
													CAS_SEL_Grupo_Causa__c,
													CAS_SEL_Metodo_de_pago__c,
													CAS_SEL_Motivo_anulacion_reclamacion__c,
													CAS_SEL_Motivo_de_Cierre__c,
													CAS_SEL_Motivo_Indemnizable__c,
													CAS_SEL_Motivo_No_Apertura__c,
													CAS_SEL_Motivo_Peticion_Perito__c,
													CAS_SEL_Motivo_Reapertura__c,
													CAS_SEL_Motivo_Rechazo__c,
													CAS_SEL_Motivo_rechazo_presupuesto__c,
													CAS_SEL_Naturaleza__c,
													CAS_SEL_Otros_Danos__c,
													CAS_SEL_Padre_reclamacion__c,
													CAS_SEL_Perito_de_RGA__c,
													CAS_SEL_Rango_Cita__c,
													CAS_SEL_Reclamacion__c,
													CAS_SEL_Situacion_Danos_Propios__c,
													CAS_SEL_Sondeo_DocIndemSug__c,
													CAS_SEL_Sondeo_DocsIndemnizable__c,
													CAS_SEL_Sondeo_Fase__c,
													CAS_SEL_Sondeo_Gremios__c,
													CAS_SEL_Tipo_Averia__c,
													CAS_SEL_Tipo_Interlocutor__c,
													CAS_SEL_Tipo_Llamada__c,
													CAS_TFN_Solicitud_Telefono__c,
													CAS_TFN_Telefono_1__c,
													CAS_TFN_Telefono_2__c,
													CAS_TXT_Apellidos__c,
													CAS_TXT_Apellidos_2__c,
													CAS_TXT_Ayuda_Ind_Apertura__c,
													CAS_TXT_Causante_Direccion__c,
													CAS_TXT_Causante_N_Documento__c,
													CAS_TXT_Causante_N_exp_Stro__c,
													CAS_TXT_Causante_Poblacion__c,
													CAS_TXT_Causante_Poliza_R_C__c,
													CAS_TXT_Codigo_Apertura__c,
													CAS_TXT_Codigo_Campania_Origen__c,
													CAS_TXT_Codigo_Comercial__c,
													CAS_TXT_Codigo_Postal__c,
													CAS_TXT_Direccion__c,
													CAS_TXT_DirRiesgo_CP__c,
													CAS_TXT_DirRiesgo_Pais__c,
													CAS_TXT_DirRiesgo_Poblacion__c,
													CAS_TXT_Estado_Anterior__c,
													CAS_TXT_Identificador__c,
													CAS_TXT_Identificador_DLC__c,
													CAS_TXT_Motivo_Llamada__c,
													CAS_TXT_Motivo_Reapertura__c,
													CAS_TXT_Nombre__c,
													CAS_TXT_Num_Caso_CIA__c,
													CAS_TXT_Num_Caso_HS__c,
													CAS_TXT_Password_Clic_Hogar__c,
													CAS_TXT_Persona_que_llama__c,
													CAS_TXT_Sondeo_Causa__c,
													CAS_TXT_Sondeo_Grupo_Causa__c,
													CAS_TXT_Sondeo_Tipo_de_Carta__c,
													CAS_TXT_Subestado_Caso__c,
													CAS_TXT_Subestado_Codigo__c,
													CAS_TXT_Submotivo_Perito__c,
													CAS_TXT_texto_observaciones_RGA__c,
													CAS_TXT_Tipo_Encuesta__c,
													CAS_TXT_Usuario_Clic_Hogar__c,
													CAS_TXT_WF_Compania__c,
													CaseNumber,
													ClosedDate,
													Contact.CON_CAS_ContactoDummy__c,
													ContactEmail,
													ContactId,
													CreatedDate,
													LastModifiedDate,
													Origin,
													Owner.Name,
													Owner.Type,
													OwnerId,
													Parent.CAS_TXT_Num_Caso_CIA__c,
													Parent.CaseNumber,
													Parent.Type,
													ParentId,
													recordtype.DeveloperName,
													RecordType.Name,
													RecordTypeId,
													Status,
													Type
												FROM Case
												WHERE  CAS_TXT_Num_Caso_HS__c IN: setNumHS AND CAS_LKP_Compania__r.CUE_TXT_Identificador__c IN: setCompanias]) {
					 mapCaso.putAll(listaCasosAux);
				}
		  }
		  return mapCaso;
	 }

	 /**
	  * Obtiene a partir de una poliza, los casos ya existentes en la fase de confirmacion
	  *
	  *
	  * @param setIdPoliza
	  * @param setIdPadre
	  * @return mapa de casos ya existentes con esa póliza
	  */
	 public static Map<Id, Case> queryCasosYaExistentes(String grupoCausas, Date fLimite, Set<Id> setIdPoliza, Set<Id> setIdPadre) {
		  Map<Id, Case> mapaCasos=new Map<Id, Case>();
		  if(!setIdPoliza.isEmpty() && !setIdPadre.isEmpty()) {
				for(List<Case> listaCasosAux:[SELECT Id,
													Account.CUE_EMA_Email__c,
													Account.CUE_FOR_DireccionEnvio__c,
													Account.CUE_FOR_IBAN__c,
													Account.CUE_FOR_RTDevName__c,
													Account.CUE_LKP_Cuenta_principal__c,
													Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													Account.CUE_SEL_Idioma__c,
													Account.CUE_SEL_Pais__c,
													Account.CUE_SEL_Provincia__c,
													Account.CUE_SEL_Tipo_Documento__c,
													Account.CUE_TXT_Cbanc_Codigo_Entidad__c,
													Account.CUE_TXT_Cbanc_Digito_Control__c,
													Account.CUE_TXT_Cbanc_Numero__c,
													Account.CUE_TXT_Cbanc_Pais__c,
													Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,
													Account.CUE_TXT_Condicion_Pago__c,
													Account.CUE_TXT_Establecimiento__c,
													Account.CUE_TXT_Identificador__c,
													Account.CUE_TXT_Metodo_Pago__c,
													Account.CUE_TXT_Nombre__c,
													Account.CUE_TXT_Numero_Documento__c,
													Account.CUE_TXT_Presentacion__c,
													Account.CUE_TXT_PrimerApellido__c,
													Account.CUE_TXT_SegundoApellido__c,
													Account.Name,
													Account.Phone,
													Account.RecordType.Name,
													Account.ShippingCity,
													Account.ShippingCountry,
													Account.ShippingPostalCode,
													Account.ShippingState,
													Account.ShippingStreet,
													Account.Type,
													AccountId,
													CAS_CAS_Apertura_Parcial__c,
													CAS_CAS_Confirmado__c,
													CAS_CAS_Danos_Perjudicado__c,
													CAS_CAS_Danos_Propios__c,
													CAS_CAS_Generar_Presupuesto__c,
													CAS_CAS_Liquidado__c,
													CAS_CAS_Reclamacion_Vinculada__c,
													CAS_CAS_Requiere_Perito__c,
													CAS_CAS_Siniestro_Consorciable__c,
													CAS_CAS_Siniestro_Encuestado__c,
													CAS_CAS_Siniestro_Facturado__c,
													CAS_CAS_Siniestro_Grave__c,
													CAS_CAS_Supera_Limite_Actuacion__c,
													CAS_CAS_Tercero_Causante__c,
													CAS_DAT_Fecha_Apertura__c,
													CAS_DAT_Fecha_de_Aplazamiento__c,
													CAS_DAT_Fecha_Informe_Pericial__c,
													CAS_DAT_Fecha_Modificacion_Estado__c,
													CAS_DAT_Fecha_Ocurrencia__c,
													CAS_DAT_Fecha_Pago_Minuta__c,
													CAS_DAT_Primera_Cita__c,
													CAS_DIV_Importe_Total__c,
													CAS_DIV_Pago_de_Minuta__c,
													CAS_DIV_Total_Facturar_CIA_AI__c,
													CAS_DIV_Total_Facturar_Cliente_AI__c,
													CAS_DIV_Total_Facturar_Profesional__c,
													CAS_EMA_Email__c,
													CAS_EMA_Solicitud_Email__c,
													CAS_FOR_Codigo_de_barras__c,
													CAS_FOR_Descripcion_Baremo__c,
													CAS_FOR_Direccion_Riesgo__c,
													CAS_FOR_EsB2C__c,
													CAS_FOR_Fecha_Cita_Reservada__c,
													CAS_FOR_Importe_Total__c,
													CAS_FOR_Limite_Actuacion__c,
													CAS_FOR_Nombre_Solicitud__c,
													CAS_FOR_OT_Principal_Urgente__c,
													CAS_FOR_Producto__c,
													CAS_FOR_Rango_Cita_Reservada__c,
													CAS_FOR_RTDevName__c,
													CAS_FOR_Tipo_Caso__c,
													CAS_LKP_Ayuda_Indemnizable__c,
													CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
													CAS_LKP_Baremo__c,
													CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
													CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
													CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
													CAS_LKP_Cliente_contable__c,
													CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
													CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
													CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,
													CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
													CAS_LKP_Cliente_contable__r.Name,
													CAS_LKP_Cliente_contable__r.Phone,
													CAS_LKP_Cliente_contable__r.ShippingCity,
													CAS_LKP_Cliente_contable__r.ShippingCountry,
													CAS_LKP_Cliente_contable__r.ShippingPostalCode,
													CAS_LKP_Cliente_contable__r.ShippingState,
													CAS_LKP_Cliente_contable__r.ShippingStreet,
													CAS_LKP_Cliente_contable_cliente__c,
													CAS_LKP_Cliente_contable_cliente__r.Name,
													CAS_LKP_Compania__c,
													CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
													CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
													CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
													CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
													CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
													CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
													CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
													CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
													CAS_LKP_Compania__r.Name,
													CAS_LKP_Linea_de_Contrato__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
													CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
													CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
													CAS_LKP_Orden_Trabajo_Principal__c,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
													CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
													CAS_LKP_Perito__c,
													CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
													CAS_LKP_PolizaContrato__c,
													CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
													CAS_LKP_PolizaContrato__r.name,
													CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
													CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
													CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
													CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
													CAS_LKP_Procedencia__c,
													CAS_LKP_Procedencia__r.Name,
													CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
													CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
													CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
													CAS_LKP_Punto_de_venta__c,
													CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
													CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
													CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
													CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
													CAS_LKP_Responsable_Reclamacion__c,
													CAS_LKP_Tipo_Trabajo__c,
													CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
													CAS_NUM_Contador_Analisis__c,
													CAS_NUM_Contador_Clic_Hogar__c,
													CAS_NUM_Id_Actuacion_SondeoExt__c,
													CAS_SEL_Causa_Averia__c,
													CAS_SEL_Causante_Compania__c,
													CAS_SEL_Causante_Provincia__c,
													CAS_SEL_Causante_Responsable__c,
													CAS_SEL_Causante_Tipo_Documento__c,
													CAS_SEL_Comunicador_Recl__c,
													CAS_SEL_Conformidad_del_Cliente__c,
													CAS_SEL_Conformidad_del_Cliente_2__c,
													CAS_SEL_Conformidad_del_Cliente_3__c,
													CAS_SEL_Detalle_Averia__c,
													CAS_SEL_Direccion_Territorial__c,
													CAS_SEL_DirRiesgo_Estado_Provincia__c,
													CAS_SEL_Encuestador__c,
													CAS_SEL_Estado_Perito__c,
													CAS_SEL_Gremio_Principal__c,
													CAS_SEL_Grupo_Causa__c,
													CAS_SEL_Metodo_de_pago__c,
													CAS_SEL_Motivo_anulacion_reclamacion__c,
													CAS_SEL_Motivo_de_Cierre__c,
													CAS_SEL_Motivo_Indemnizable__c,
													CAS_SEL_Motivo_No_Apertura__c,
													CAS_SEL_Motivo_Peticion_Perito__c,
													CAS_SEL_Motivo_Reapertura__c,
													CAS_SEL_Motivo_Rechazo__c,
													CAS_SEL_Motivo_rechazo_presupuesto__c,
													CAS_SEL_Naturaleza__c,
													CAS_SEL_Otros_Danos__c,
													CAS_SEL_Padre_reclamacion__c,
													CAS_SEL_Perito_de_RGA__c,
													CAS_SEL_Rango_Cita__c,
													CAS_SEL_Reclamacion__c,
													CAS_SEL_Situacion_Danos_Propios__c,
													CAS_SEL_Sondeo_DocIndemSug__c,
													CAS_SEL_Sondeo_DocsIndemnizable__c,
													CAS_SEL_Sondeo_Fase__c,
													CAS_SEL_Sondeo_Gremios__c,
													CAS_SEL_Tipo_Averia__c,
													CAS_SEL_Tipo_Interlocutor__c,
													CAS_SEL_Tipo_Llamada__c,
													CAS_TFN_Solicitud_Telefono__c,
													CAS_TFN_Telefono_1__c,
													CAS_TFN_Telefono_2__c,
													CAS_TXT_Apellidos__c,
													CAS_TXT_Apellidos_2__c,
													CAS_TXT_Ayuda_Ind_Apertura__c,
													CAS_TXT_Causante_Direccion__c,
													CAS_TXT_Causante_N_Documento__c,
													CAS_TXT_Causante_N_exp_Stro__c,
													CAS_TXT_Causante_Poblacion__c,
													CAS_TXT_Causante_Poliza_R_C__c,
													CAS_TXT_Codigo_Apertura__c,
													CAS_TXT_Codigo_Campania_Origen__c,
													CAS_TXT_Codigo_Comercial__c,
													CAS_TXT_Codigo_Postal__c,
													CAS_TXT_Direccion__c,
													CAS_TXT_DirRiesgo_CP__c,
													CAS_TXT_DirRiesgo_Pais__c,
													CAS_TXT_DirRiesgo_Poblacion__c,
													CAS_TXT_Estado_Anterior__c,
													CAS_TXT_Identificador__c,
													CAS_TXT_Identificador_DLC__c,
													CAS_TXT_Motivo_Llamada__c,
													CAS_TXT_Motivo_Reapertura__c,
													CAS_TXT_Nombre__c,
													CAS_TXT_Num_Caso_CIA__c,
													CAS_TXT_Num_Caso_HS__c,
													CAS_TXT_Password_Clic_Hogar__c,
													CAS_TXT_Persona_que_llama__c,
													CAS_TXT_Sondeo_Causa__c,
													CAS_TXT_Sondeo_Grupo_Causa__c,
													CAS_TXT_Sondeo_Tipo_de_Carta__c,
													CAS_TXT_Subestado_Caso__c,
													CAS_TXT_Subestado_Codigo__c,
													CAS_TXT_Submotivo_Perito__c,
													CAS_TXT_texto_observaciones_RGA__c,
													CAS_TXT_Tipo_Encuesta__c,
													CAS_TXT_Usuario_Clic_Hogar__c,
													CAS_TXT_WF_Compania__c,
													CaseNumber,
													ClosedDate,
													Contact.CON_CAS_ContactoDummy__c,
													ContactEmail,
													ContactId,
													CreatedDate,
													LastModifiedDate,
													Origin,
													Owner.Name,
													Owner.Type,
													OwnerId,
													Parent.CAS_TXT_Num_Caso_CIA__c,
													Parent.CaseNumber,
													Parent.Type,
													ParentId,
													recordtype.DeveloperName,
													RecordType.Name,
													RecordTypeId,
													Status,
													Type
											  FROM Case 
											  WHERE CAS_SEL_Grupo_Causa__c = :grupocausas 
											  AND CAS_DAT_Fecha_Apertura__c >= :fLimite 
											  AND CAS_LKP_PolizaContrato__c IN :setIdPoliza
											  AND Id NOT IN :setIdPadre]) {
					 mapaCasos.putAll(listaCasosAux);
				}
		  }
		  return mapaCasos;
	 }
	 /**
	 * Devuelve los casos que existen y el owner.type
	 *
	 * @param setIds: Ids de casos
	 * @param setOwnType: set de tipo
	 *
	 * @return mapa que contiene los casos
	 */
	 public static Map<Id,Case> getCasoOwnerType (set<Id> setIds,set<String> setOwnType){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setIds != null && !setIds.isEmpty() && setOwnType != null && !setOwnType.isEmpty()){
				for(List<Case> lista:[SELECT Id, OwnerId, Owner.Type, Owner.Name
							FROM Case
							WHERE Id IN :setIds
							AND Owner.Type IN : setOwnType]){
					 mapa.putAll(lista);
				}					
		  }
		  return mapa;
	 }
	 
	 /**
	 *  Obtener el usuario activo con menos casos en curso asignados
	 *
	 * @param setIdsUsuAct: Ids de usuarios activos
	 *
	 * @return mapa que contiene los usuario que posee dichos casos
	 */
	 public static Map<Id,AggregateResult> getUsuMenCasoAsig (set<Id> setIdsUsuAct){
		  Map<Id,AggregateResult> mapa = new Map<Id,AggregateResult>();
		  if(setIdsUsuAct != null && !setIdsUsuAct.isEmpty()){
				for(List<AggregateResult> lista:[SELECT OwnerId, Count(Id)
											FROM Case
											WHERE Status != :Label.CAS_ESTADO_INACTIVO
											AND isClosed = false
											AND OwnerId IN :setIdsUsuAct
											GROUP BY OwnerId
											ORDER BY Count(Id) ASC]){
					 mapa.putAll(lista);
				}					
		  }
		  return mapa;
	 }
	 
	 /**
	  * recoge los casos inactivos por un conjunto de identificadores de direcciones linea contrato
	  * @param setIdDLC: Set de Strings que contiene identificadores de las direcciones B2B lineas
	  * @return devuelve un mapa con los casos encontrados
	  */
	 public static Map<Id,Case> queryCasosInactivosByDLC (Set<String> setIdDLC){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setIdDLC != null && !setIdDLC.isEmpty()){
				for(List<Case> lista:[SELECT Id, Status
											FROM Case
											WHERE CAS_TXT_Identificador_DLC__c IN :setIdDLC
											AND Status = :Label.CAS_ESTADO_INACTIVO]){
					 mapa.putAll(lista);
				}					
		  }
		  return mapa;
	 }
	 
	 
	 /**
	  * 
	  * @param setIdDLC: Set de Strings que contiene el numero del caso
	  * @param SetRecordTypeIdReclamacion : set de Id que recoge el RecordTypeId de la reclamacion
	  * @return devuelve un mapa con los casos encontrados
	  */
	 public static Map<Id,Case> queryCasosTRGEmailMessage(Set<String> setCaseNumber, Set<Id> SetRecordTypeIdReclamacion){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setCaseNumber != null && !setCaseNumber.isEmpty() && SetRecordTypeIdReclamacion != null && !SetRecordTypeIdReclamacion.isEmpty()){
				  for(List<Case> lista:[Select Id,
											  CaseNumber,
											  Parent.CaseNumber,
											  CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
											  CAS_TXT_Num_Caso_CIA__c,
											  OwnerId, 
											  recordTypeId,
											  Parent.CAS_TXT_Num_Caso_CIA__c, 
											  CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
											  AccountId
											  from Case 
											  where CAS_TXT_Num_Caso_CIA__c in :setCaseNumber 
											  or (RecordtypeId = :SetRecordTypeIdReclamacion
											  and (Parent.CAS_TXT_Num_Caso_CIA__c in :setCaseNumber
														 or CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c in :setCaseNumber)
											  and Status != :Label.CAS_ESTADO_CERRADO_FACTURADO
											  and Status != :Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR
											  and Status != :Label.CAS_ESTADO_CERRADO)
											  or CaseNumber in :setCaseNumber 
											  or (RecordtypeId = :SetRecordTypeIdReclamacion
											  and (Parent.CaseNumber in :setCaseNumber
														 or CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber in :setCaseNumber)
											  and Status != :Label.CAS_ESTADO_CERRADO_FACTURADO
											  and Status != :Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR
											  and Status != :Label.CAS_ESTADO_CERRADO)]){
					 mapa.putAll(lista);
				}					
		  }
		  return mapa;
	 }
	 
	 /**
	  * Devuelve los Casos filtrados por IDs y CUE_TXT_Identificador__c.
	  *
	  * @param setIdCaso: IDs de casos
	  * @param identificadorComp: valor de CUE_TXT_Identificador__c
	  *
	  * @return mapa que contienen los Casos devueltos
	  */
	 public static Map<Id,Case> getCasosByIdAndIdentificador(Set<Id> setIdCaso, Set<String> identificadorComp){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setIdCaso != null && !setIdCaso.isEmpty() && identificadorComp != null && !identificadorComp.isEmpty()){
				for(List<Case> lista:[SELECT Id,
											Account.CUE_EMA_Email__c,
											Account.CUE_FOR_DireccionEnvio__c,
											Account.CUE_FOR_IBAN__c,
											Account.CUE_FOR_RTDevName__c,
											Account.CUE_LKP_Cuenta_principal__c,
											Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
											Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
											Account.CUE_SEL_Idioma__c,
											Account.CUE_SEL_Pais__c,
											Account.CUE_SEL_Provincia__c,
											Account.CUE_SEL_Tipo_Documento__c,
											Account.CUE_TXT_Cbanc_Codigo_Entidad__c,
											Account.CUE_TXT_Cbanc_Digito_Control__c,
											Account.CUE_TXT_Cbanc_Numero__c,
											Account.CUE_TXT_Cbanc_Pais__c,
											Account.CUE_TXT_Cbanc_Sucursal_Oficina__c,
											Account.CUE_TXT_Condicion_Pago__c,
											Account.CUE_TXT_Establecimiento__c,
											Account.CUE_TXT_Identificador__c,
											Account.CUE_TXT_Metodo_Pago__c,
											Account.CUE_TXT_Nombre__c,
											Account.CUE_TXT_Numero_Documento__c,
											Account.CUE_TXT_Presentacion__c,
											Account.CUE_TXT_PrimerApellido__c,
											Account.CUE_TXT_SegundoApellido__c,
											Account.Name,
											Account.Phone,
											Account.RecordType.Name,
											Account.ShippingCity,
											Account.ShippingCountry,
											Account.ShippingPostalCode,
											Account.ShippingState,
											Account.ShippingStreet,
											Account.Type,
											AccountId,
											CAS_CAS_Apertura_Parcial__c,
											CAS_CAS_Confirmado__c,
											CAS_CAS_Danos_Perjudicado__c,
											CAS_CAS_Danos_Propios__c,
											CAS_CAS_Generar_Presupuesto__c,
											CAS_CAS_Liquidado__c,
											CAS_CAS_Reclamacion_Vinculada__c,
											CAS_CAS_Requiere_Perito__c,
											CAS_CAS_Siniestro_Consorciable__c,
											CAS_CAS_Siniestro_Encuestado__c,
											CAS_CAS_Siniestro_Facturado__c,
											CAS_CAS_Siniestro_Grave__c,
											CAS_CAS_Supera_Limite_Actuacion__c,
											CAS_CAS_Tercero_Causante__c,
											CAS_DAT_Fecha_Apertura__c,
											CAS_DAT_Fecha_de_Aplazamiento__c,
											CAS_DAT_Fecha_Informe_Pericial__c,
											CAS_DAT_Fecha_Modificacion_Estado__c,
											CAS_DAT_Fecha_Ocurrencia__c,
											CAS_DAT_Fecha_Pago_Minuta__c,
											CAS_DAT_Primera_Cita__c,
											CAS_DIV_Importe_Total__c,
											CAS_DIV_Pago_de_Minuta__c,
											CAS_DIV_Total_Facturar_CIA_AI__c,
											CAS_DIV_Total_Facturar_Cliente_AI__c,
											CAS_DIV_Total_Facturar_Profesional__c,
											CAS_EMA_Email__c,
											CAS_EMA_Solicitud_Email__c,
											CAS_FOR_Codigo_de_barras__c,
											CAS_FOR_Descripcion_Baremo__c,
											CAS_FOR_Direccion_Riesgo__c,
											CAS_FOR_EsB2C__c,
											CAS_FOR_Fecha_Cita_Reservada__c,
											CAS_FOR_Importe_Total__c,
											CAS_FOR_Limite_Actuacion__c,
											CAS_FOR_Nombre_Solicitud__c,
											CAS_FOR_OT_Principal_Urgente__c,
											CAS_FOR_Producto__c,
											CAS_FOR_Rango_Cita_Reservada__c,
											CAS_FOR_RTDevName__c,
											CAS_FOR_Tipo_Caso__c,
											CAS_LKP_Ayuda_Indemnizable__c,
											CAS_LKP_Ayuda_Indemnizable__r.AYU_TXT_Descripcion__c,
											CAS_LKP_Baremo__c,
											CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
											CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
											CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
											CAS_LKP_Cliente_contable__c,
											CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c,
											CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
											CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
											CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c,
											CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
											CAS_LKP_Cliente_contable__r.Name,
											CAS_LKP_Cliente_contable__r.Phone,
											CAS_LKP_Cliente_contable__r.ShippingCity,
											CAS_LKP_Cliente_contable__r.ShippingCountry,
											CAS_LKP_Cliente_contable__r.ShippingPostalCode,
											CAS_LKP_Cliente_contable__r.ShippingState,
											CAS_LKP_Cliente_contable__r.ShippingStreet,
											CAS_LKP_Cliente_contable_cliente__c,
											CAS_LKP_Cliente_contable_cliente__r.Name,
											CAS_LKP_Compania__c,
											CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
											CAS_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c,
											CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c,
											CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,
											CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,
											CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,
											CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
											CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,
											CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
											CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,
											CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
											CAS_LKP_Compania__r.Name,
											CAS_LKP_Linea_de_Contrato__c,
											CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
											CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,
											CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,
											CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
											CAS_LKP_Linea_de_Contrato__r.RecordTypeId,
											CAS_LKP_Orden_Trabajo_Principal__c,
											CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,
											CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowEndTime,
											CAS_LKP_Orden_Trabajo_Principal__r.OTR_LKP_Primera_Cita__r.ArrivalWindowStartTime,
											CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,
											CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
											CAS_LKP_Perito__c,
											CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
											CAS_LKP_PolizaContrato__c,
											CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c,
											CAS_LKP_PolizaContrato__r.name,
											CAS_LKP_PolizaContrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
											CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
											CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name,
											CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c,
											CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
											CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c,
											CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c,
											CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
											CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c,
											CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ,
											CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.Name,
											CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c,
											CAS_LKP_Procedencia__c,
											CAS_LKP_Procedencia__r.Name,
											CAS_LKP_Procedencia__r.PROC_SEL_Canal__c,
											CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,
											CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,
											CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,
											CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c,
											CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c,
											CAS_LKP_Punto_de_venta__c,
											CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,
											CAS_LKP_Recl_Orden_Trabajo__r.Case.CAS_TXT_Num_Caso_CIA__c,
											CAS_LKP_Recl_Orden_Trabajo__r.Case.CaseNumber,
											CAS_LKP_Recl_Orden_Trabajo__r.CaseId,
											CAS_LKP_Responsable_Reclamacion__c,
											CAS_LKP_Tipo_Trabajo__c,
											CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c,
											CAS_NUM_Contador_Analisis__c,
											CAS_NUM_Contador_Clic_Hogar__c,
											CAS_NUM_Id_Actuacion_SondeoExt__c,
											CAS_SEL_Causa_Averia__c,
											CAS_SEL_Causante_Compania__c,
											CAS_SEL_Causante_Provincia__c,
											CAS_SEL_Causante_Responsable__c,
											CAS_SEL_Causante_Tipo_Documento__c,
											CAS_SEL_Comunicador_Recl__c,
											CAS_SEL_Conformidad_del_Cliente__c,
											CAS_SEL_Conformidad_del_Cliente_2__c,
											CAS_SEL_Conformidad_del_Cliente_3__c,
											CAS_SEL_Detalle_Averia__c,
											CAS_SEL_Direccion_Territorial__c,
											CAS_SEL_DirRiesgo_Estado_Provincia__c,
											CAS_SEL_Encuestador__c,
											CAS_SEL_Estado_Perito__c,
											CAS_SEL_Gremio_Principal__c,
											CAS_SEL_Grupo_Causa__c,
											CAS_SEL_Metodo_de_pago__c,
											CAS_SEL_Motivo_anulacion_reclamacion__c,
											CAS_SEL_Motivo_de_Cierre__c,
											CAS_SEL_Motivo_Indemnizable__c,
											CAS_SEL_Motivo_No_Apertura__c,
											CAS_SEL_Motivo_Peticion_Perito__c,
											CAS_SEL_Motivo_Reapertura__c,
											CAS_SEL_Motivo_Rechazo__c,
											CAS_SEL_Motivo_rechazo_presupuesto__c,
											CAS_SEL_Naturaleza__c,
											CAS_SEL_Otros_Danos__c,
											CAS_SEL_Padre_reclamacion__c,
											CAS_SEL_Perito_de_RGA__c,
											CAS_SEL_Rango_Cita__c,
											CAS_SEL_Reclamacion__c,
											CAS_SEL_Situacion_Danos_Propios__c,
											CAS_SEL_Sondeo_DocIndemSug__c,
											CAS_SEL_Sondeo_DocsIndemnizable__c,
											CAS_SEL_Sondeo_Fase__c,
											CAS_SEL_Sondeo_Gremios__c,
											CAS_SEL_Tipo_Averia__c,
											CAS_SEL_Tipo_Interlocutor__c,
											CAS_SEL_Tipo_Llamada__c,
											CAS_TFN_Solicitud_Telefono__c,
											CAS_TFN_Telefono_1__c,
											CAS_TFN_Telefono_2__c,
											CAS_TXT_Apellidos__c,
											CAS_TXT_Apellidos_2__c,
											CAS_TXT_Ayuda_Ind_Apertura__c,
											CAS_TXT_Causante_Direccion__c,
											CAS_TXT_Causante_N_Documento__c,
											CAS_TXT_Causante_N_exp_Stro__c,
											CAS_TXT_Causante_Poblacion__c,
											CAS_TXT_Causante_Poliza_R_C__c,
											CAS_TXT_Codigo_Apertura__c,
											CAS_TXT_Codigo_Campania_Origen__c,
											CAS_TXT_Codigo_Comercial__c,
											CAS_TXT_Codigo_Postal__c,
											CAS_TXT_Direccion__c,
											CAS_TXT_DirRiesgo_CP__c,
											CAS_TXT_DirRiesgo_Pais__c,
											CAS_TXT_DirRiesgo_Poblacion__c,
											CAS_TXT_Estado_Anterior__c,
											CAS_TXT_Identificador__c,
											CAS_TXT_Identificador_DLC__c,
											CAS_TXT_Motivo_Llamada__c,
											CAS_TXT_Motivo_Reapertura__c,
											CAS_TXT_Nombre__c,
											CAS_TXT_Num_Caso_CIA__c,
											CAS_TXT_Num_Caso_HS__c,
											CAS_TXT_Password_Clic_Hogar__c,
											CAS_TXT_Persona_que_llama__c,
											CAS_TXT_Sondeo_Causa__c,
											CAS_TXT_Sondeo_Grupo_Causa__c,
											CAS_TXT_Sondeo_Tipo_de_Carta__c,
											CAS_TXT_Subestado_Caso__c,
											CAS_TXT_Subestado_Codigo__c,
											CAS_TXT_Submotivo_Perito__c,
											CAS_TXT_texto_observaciones_RGA__c,
											CAS_TXT_Tipo_Encuesta__c,
											CAS_TXT_Usuario_Clic_Hogar__c,
											CAS_TXT_WF_Compania__c,
											CaseNumber,
											ClosedDate,
											Contact.CON_CAS_ContactoDummy__c,
											ContactEmail,
											ContactId,
											CreatedDate,
											LastModifiedDate,
											Origin,
											Owner.Name,
											Owner.Type,
											OwnerId,
											Parent.CAS_TXT_Num_Caso_CIA__c,
											Parent.CaseNumber,
											Parent.Type,
											ParentId,
											recordtype.DeveloperName,
											RecordType.Name,
											RecordTypeId,
											Status,
											Type
										FROM Case
										WHERE Id IN :setIdCaso AND CAS_LKP_Compania__r.CUE_TXT_Identificador__c = :identificadorComp]){
					 mapa.putAll(lista);
				}			  
		  }
		  return mapa;
	 }
	 
	 /** 
	  * Devuelve los Casos filtrados por id de poliza.
	  *
	  * @param setIdCaso: IDs de Poliza
	  *
	  * @return mapa que contienen los Casos devueltos
	  */
	 public static Map<Id,Case> getCasosByPolizaId(Set<Id> setIdPoliza){
		  Map<Id,Case> mapa = new Map<Id,Case>();
		  if(setIdPoliza != null && !setIdPoliza.isEmpty() ){
				for(List<Case> lista:[Select Id,
											CaseNumber,			
											CAS_LKP_PolizaContrato__c,
											AccountId,
											CAS_TXT_Codigo_Postal__c,
											CAS_TFN_Solicitud_Telefono__c,
											CAS_LKP_Compania__c,
											Origin,
											CAS_TXT_Persona_que_llama__c,
											RecordTypeId,
											status,
											CAS_SEL_Motivo_No_Apertura__c,
											CAS_SEL_Tipo_Interlocutor__c,
											CAS_LKP_Procedencia__c,
											CAS_LKP_PolizaContrato__r.Name,
											CAS_LKP_Perito__c,
											CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
											CAS_CAS_Requiere_Perito__c,
											Type,
											CAS_SEL_DirRiesgo_Estado_Provincia__c,
											CAS_CAS_Siniestro_Grave__c,
											CAS_LKP_Cliente_contable__c
										FROM Case Where CAS_LKP_PolizaContrato__c IN :setIdPoliza]){
					 mapa.putAll(lista);
				}			  
		  }
		  return mapa;
	 }
	 
	 /** 
	  * Devuelve el número de Siniestros filtrados por id de poliza, tipo manitas y estado no anulado.
	  *
	  * @param idPoliza: Id de Poliza
	  * @param idCaso: Id del Siniestro que se está abriendo para excluirlo de la query
	  *
	  * @return integer con el número de siniestros recogidos
	  */	 
	public static Integer getNumeroCasosByPoliza(Case caso){
		Integer numCasos = 0;
		if(caso != null){
			List<AggregateResult> listaAgregados = [SELECT count(Id)numero 
													FROM Case 
													WHERE CAS_LKP_PolizaContrato__c = :caso.CAS_LKP_PolizaContrato__c
													AND Id != :caso.Id
													AND Status != :Label.CAS_ESTADO_ANULADO
													AND Type = :Label.CAS_TIPO_MANITAS];
			numCasos = Integer.valueOf(listaAgregados[0].get('numero'));
		}
		return numCasos;
	}


	/**
	 * Devuelve un mapa con cada uno de los comentarios de cada caso recibido.
	 * 
	 * @param setIdCaso: IDs de los casos
	 * @return mapa con cada uno de los comentarios de cada caso recibido
	 */
	public static Map<Id,List<Comentario_caso__c>> getMapComentariosCaso(Set<Id> setIdCaso){
		Map<Id,List<Comentario_caso__c>> mapa = new Map<Id,List<Comentario_caso__c>>();
		if(setIdCaso != null && !setIdCaso.isEmpty()){
			List<Comentario_caso__c> lista = new List<Comentario_caso__c>(
				[SELECT Id,
						CMC_TXT_Comentario__c,
						CMC_LKP_Caso__c,
						CMC_LKP_Caso__r.Type,
						CMC_SEL_Tipo__c,
						CreatedDate,
						CreatedById,
						CreatedBy.Name
				 FROM Comentario_caso__c
				 WHERE CMC_LKP_Caso__c IN :setIdCaso
				 ORDER BY CMC_LKP_Caso__c, CreatedDate ASC]);
			for(Comentario_caso__c registro : lista){
				List<Comentario_caso__c> listaAux = mapa.get(registro.CMC_LKP_Caso__c);
				if(listaAux == null){
					listaAux = new List<Comentario_caso__c>();
				}
				listaAux.add(registro);
				mapa.put(registro.CMC_LKP_Caso__c, listaAux);
			}
			for(Id idCaso : setIdCaso){
				if(mapa.get(idCaso) == null){
					mapa.put(idCaso, new List<Comentario_caso__c>());
				}
			}
		}
		return mapa;
	}

	/**
	 * Devuelve si un caso es un Servicio B2B B2B2C.
	 *
	 * @param caso: caso a evaluar su RecordType
	 *
	 * @return true si el Recordtype es Servicio B2B B2B2C, false en otro caso
	 */
	public static Boolean esServicioB2BB2B2C(Case caso){
		return (caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C));
	}
}