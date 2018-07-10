/**
 * Clase de funciones auxiliares relativas a los Servicios B2B/B2B2C.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_B2B {

	/**
	  * Método que realizar una consulta sobre el objeto Case filtrando por su Id.
	  * 
	  * @param idCaso: Id del caso por el cual filtramos en la query
	  * 
	  * @return lista de casos devuelta por la query
	  */
	/*public static List<Case> queryCaso(Id idCaso){
		List<Case> listaCasos = new List<Case>();
		if(idCaso != null){
			String sentenciaCaso = 'SELECT Id,';
			sentenciaCaso += ' AccountId,';
			sentenciaCaso += ' Account.Name,';
			sentenciaCaso += ' Account.CUE_LKP_Cuenta_principal__c,';
			sentenciaCaso += ' Account.CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,';
			sentenciaCaso += ' Account.RecordType.Name,';
			sentenciaCaso += ' CAS_CAS_Generar_Presupuesto__c,';
			sentenciaCaso += ' CAS_CAS_Supera_Limite_Actuacion__c,';
			sentenciaCaso += ' CAS_DAT_Fecha_Apertura__c,';
			sentenciaCaso += ' CAS_DAT_Fecha_Ocurrencia__c,';
			sentenciaCaso += ' CAS_DAT_Primera_Cita__c,';
			sentenciaCaso += ' CAS_DIV_Total_Facturar_CIA_AI__c,';
			sentenciaCaso += ' CAS_DIV_Total_Facturar_Cliente_AI__c,';
			sentenciaCaso += ' CAS_DIV_Total_Facturar_Profesional__c,';
			sentenciaCaso += ' CAS_EMA_Email__c,';
			sentenciaCaso += ' CAS_EMA_Solicitud_Email__c,';
			sentenciaCaso += ' CAS_FOR_Codigo_de_barras__c,';
			sentenciaCaso += ' CAS_FOR_Descripcion_Baremo__c,';
			sentenciaCaso += ' CAS_FOR_Direccion_Riesgo__c,';
			sentenciaCaso += ' CAS_FOR_EsB2C__c,';
			sentenciaCaso += ' CAS_FOR_Importe_Total__c,';
			sentenciaCaso += ' CAS_FOR_Limite_Actuacion__c,';
			sentenciaCaso += ' CAS_FOR_Nombre_Solicitud__c,';
			sentenciaCaso += ' CAS_FOR_RTDevName__c,';
			sentenciaCaso += ' CAS_FOR_Tipo_Caso__c,';
			sentenciaCaso += ' CAS_LKP_Baremo__c,';
			sentenciaCaso += ' CAS_LKP_Cliente_contable__c,';
			sentenciaCaso += ' CAS_LKP_Cliente_contable__r.Name,';
			sentenciaCaso += ' CAS_LKP_Cliente_contable_cliente__c,';
			sentenciaCaso += ' CAS_LKP_Cliente_contable_cliente__r.Name,';
			sentenciaCaso += ' CAS_LKP_Compania__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_FOR_RTDevName__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_LKP_buzon_principal__r.BUZ_EMA_Direccion__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_LKP_VDN_Principal__r.VDN_TLF_Telefono__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_TXT_Identificador__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_TXT_Numero_Documento__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,';
			sentenciaCaso += ' CAS_LKP_Compania__r.Name,';
			sentenciaCaso += ' CAS_LKP_Linea_de_Contrato__c,';
			sentenciaCaso += ' CAS_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,';
			sentenciaCaso += ' CAS_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,';
			sentenciaCaso += ' CAS_LKP_Linea_de_Contrato__r.LDC_FOR_RTDevName__c,';
			sentenciaCaso += ' CAS_LKP_Linea_de_Contrato__r.LDC_FOR_Tipo__c,';
			sentenciaCaso += ' CAS_LKP_Linea_de_Contrato__r.RecordTypeId,';
			sentenciaCaso += ' CAS_LKP_Orden_Trabajo_Principal__c,';
			sentenciaCaso += ' CAS_LKP_Orden_Trabajo_Principal__r.OTR_DAT_Fecha_Primera_Cita__c,';
			sentenciaCaso += ' CAS_LKP_PolizaContrato__r.Name,';
			sentenciaCaso += ' CAS_LKP_Procedencia__c,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.Name,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c,';
			sentenciaCaso += ' CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c,';
			sentenciaCaso += ' CAS_LKP_Tipo_Trabajo__c,';
			sentenciaCaso += ' CAS_LKP_Punto_de_venta__c,';
			sentenciaCaso += ' CAS_LKP_Punto_de_venta__r.CUE_LKP_Cliente_contable__c,';
			sentenciaCaso += ' CAS_SEL_DirRiesgo_Estado_Provincia__c,';
			sentenciaCaso += ' CAS_SEL_Gremio_Principal__c,';
			sentenciaCaso += ' CAS_SEL_Metodo_de_pago__c,';
			sentenciaCaso += ' CAS_SEL_Otros_Danos__c,';
			sentenciaCaso += ' CAS_SEL_Tipo_Averia__c,';
			sentenciaCaso += ' CAS_TFN_Solicitud_Telefono__c,';
			sentenciaCaso += ' CAS_TFN_Telefono_1__c,';
			sentenciaCaso += ' CAS_TFN_Telefono_2__c,';
			sentenciaCaso += ' CAS_TXT_Apellidos__c,';
			sentenciaCaso += ' CAS_TXT_Apellidos_2__c,';
			sentenciaCaso += ' CAS_TXT_Codigo_Campania_Origen__c,';
			sentenciaCaso += ' CAS_TXT_Codigo_Comercial__c,';
			sentenciaCaso += ' CAS_TXT_Codigo_Postal__c,';
			sentenciaCaso += ' CAS_TXT_Direccion__c,';
			sentenciaCaso += ' CAS_TXT_DirRiesgo_CP__c,';
			sentenciaCaso += ' CAS_TXT_DirRiesgo_Pais__c,';
			sentenciaCaso += ' CAS_TXT_DirRiesgo_Poblacion__c,';
			sentenciaCaso += ' CAS_TXT_Identificador_DLC__c,';
			sentenciaCaso += ' CAS_TXT_Nombre__c,';
			sentenciaCaso += ' CAS_TXT_Num_Caso_CIA__c,';
			sentenciaCaso += ' CAS_TXT_Num_Caso_HS__c,';
			sentenciaCaso += ' CAS_TXT_Subestado_Caso__c,';
			sentenciaCaso += ' CAS_TXT_Subestado_Codigo__c,';
			sentenciaCaso += ' CaseNumber,';
			sentenciaCaso += ' ContactId,';
			sentenciaCaso += ' Contact.CON_CAS_ContactoDummy__c,';
			sentenciaCaso += ' ContactEmail,';
			sentenciaCaso += ' CreatedDate,';
			sentenciaCaso += ' Origin,';
			sentenciaCaso += ' OwnerId,';
			sentenciaCaso += ' Owner.Name,';
			sentenciaCaso += ' Parent.Type,';
			sentenciaCaso += ' ParentId,';
			sentenciaCaso += ' RecordTypeId,';
			sentenciaCaso += ' RecordType.Name,';
			sentenciaCaso += ' Status,';
			sentenciaCaso += ' Type';
			sentenciaCaso += ' FROM Case';
			sentenciaCaso += ' WHERE Id = \'' + idCaso + '\'';
			system.debug('PruebaUtilB2B-->'+sentenciaCaso);
			listaCasos = database.query(sentenciaCaso);
		}
		return listaCasos;
	}*/

	/*
	 *  Funcion que recoge la periodicidad y calcula el numero de días que tienen que pasar 
	 *  para que se vuelva a activar un caso preventivo
	 *
	 *  @param Integer periodicidad 	-   Numero que tiene la periodicidad que tiene que pasar
	 *  @param String tipoPeriodicidad  -   Tipo de periodicidad (Dias, semanas, meses, años)
	 *
	 *  @return dias					-   Días calculados a partir de la periodicidad y del tipo de periodicidad
	 **/
	public static Integer devolverDiasPreventivo(Integer periodicidad, String tipoPeriodicidad){
		Integer dias = 0;
		if(tipoPeriodicidad == 'Dias'){
			dias = periodicidad;
		}else if(tipoPeriodicidad == 'Semanas'){
			dias = periodicidad * 7;
		}else if(tipoPeriodicidad == 'Meses'){
			dias = periodicidad * 30;
		}else if(tipoPeriodicidad == 'Anyos'){
			dias = periodicidad * 365;
		}
		return dias;
	}

	/*
	 *  FUNCION QUE COMPRUEBA SI EL CASO ES UN SERVICIO B2B/B2B2C
	 *  @param Case caso	-   Caso que se quiere comprobar
	 *
	 *  @return true/false  -   Devuelve true si es un Servicio B2B/B2B2C 
	 *						-   Devuelve false si no es un Servicio B2B/B2B2C 
	 **/
	public static Boolean esServB2BB2B2C(Case caso){
		return (caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C));
	}

	/*
	 *  FUNCION QUE COMPRUEBA SI EL CASO ES UN SERVICIO B2C
	 *  @param Case caso	-   Caso que se quiere comprobar
	 *
	 *  @return true/false  -   Devuelve true si es un Servicio B2C 
	 *						-   Devuelve false si no es un Servicio B2C 
	 **/
	public static Boolean esServB2C(Case caso){
		return (caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C));
	}

	/*
	 *  Vincula una cuenta B2B secundaria a una Línea de Contrato.
	 *  @param cuenta   - Objeto Account de la cuenta B2B secundaria
	 *  @param linea	- Objeto Linea_Contrato__c de la Línea de Contrato
	 *  @param fechaActivacion  - Fecha Activación para Líneas de Contrato Preventivas
	 *  @return objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c generado
	 **/
	public static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c vincularB2BSecLineaCtr(Account cuenta, Linea_Contrato__c linea, Date fechaActivacion){
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC = new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c();
		dirLC.DLC_LKP_Linea_de_Contrato__c = linea.Id;
		dirLC.DLC_LKP_Direccion_B2B_B2B2C__c = cuenta.Id;
		dirLC.DLC_NUM_Servicios_restantes__c = linea.LDC_NUM_Limite_de_servicios__c;
		dirLC.DLC_DAT_Activacion_primer_servicio__c = fechaActivacion;
		return dirLC;
	}

	/**
	  * Método que setean los campos de una cuenta dada sobre un caso dado.
	  * 
	  * @param caso: caso al que se le setean los datos de cuenta
	  * @param cuenta: cuenta que contiene los datos a setear sobre el caso
	  * 
	  */
	public static void setDatosCuenta(Case caso, Account cuenta){
		Id recordTypeIdCuentaB2BSec = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2);
		if(cuenta != null){
			caso.CAS_LKP_Compania__c = cuenta.CUE_LKP_Cuenta_principal__c;
			if(cuenta.RecordTypeId == recordTypeIdCuentaB2BSec){
				caso.CAS_TXT_Direccion__c = cuenta.ShippingStreet;
				caso.CAS_TXT_DirRiesgo_Poblacion__c = cuenta.ShippingCity;
				caso.CAS_TXT_DirRiesgo_CP__c = cuenta.ShippingPostalCode;
				caso.CAS_TXT_DirRiesgo_Pais__c = cuenta.ShippingCountry;
				caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = cuenta.CUE_SEL_Provincia__c;
			}
			if (esServB2BB2B2C(caso)) {
				caso.CAS_LKP_Cliente_contable__c = cuenta.CUE_LKP_Cliente_contable__c;
			}
			// Quitar que se setee el campo CAS_LKP_Cliente_contable__c con el AccountId para Casos de Tipo "Asistencia" (para ello, comentamos el siguiente else if):
			/*else if (esServB2C(caso)) {
				caso.CAS_LKP_Cliente_contable__c = caso.AccountId;
			}*/
		}
	}

	/**
	  * Método que setea los campos de un contacto dado sobre un caso dado.
	  * 
	  * @param caso: caso sobre el cual se setean los datos del contacto
	  * @param contacto: contacto que contiene los datos a setear al caso
	  * 
	  */
	public static void setDatosContacto(Case caso, Contact contacto){
		if(contacto != null){
			caso.CAS_TXT_Nombre__c = contacto.FirstName;
			caso.CAS_TXT_Apellidos__c = contacto.LastName;
			caso.CAS_TFN_Solicitud_Telefono__c = contacto.Phone;
			caso.CAS_TFN_Telefono_1__c = contacto.MobilePhone;
			caso.CAS_EMA_Solicitud_Email__c = contacto.Email;
		}
	}

	/*
	 *  Funcion que crea el caso preventivo nuevo con la fecha de activacion correspondiente calculada si se ha activado un caso
	 *  
	 *  @param Map<Id, Case> triggerNewMap  -   trigger.newMap
	 *  @param Map<Id, Case> triggerOldMap  -   trigger.oldMap
	 *  
	 **/
	public static void activacionPreventivo(List<Case> triggerNew, Map<Id, Case> triggerOldMap, Map<Id, List<WorkOrder>> mapaOTsPorCaso,
			Map<Id, WorkOrderLineItem> mapaPartidasOTs){

		Map<Id,List<WorkOrder>> wosCasoClon = new Map<Id,List<WorkOrder>>();
		Map<Id,WorkOrderLineItem> wolisCasoClon = new Map<Id,WorkOrderLineItem>(mapaPartidasOTs);
		List<Case> listaCasosPreventivos = new List<Case>();
		Set<Id> idsLineaContrato = new Set<Id>();
		for(Case caso : triggerNew){
			if(caso.CAS_LKP_Linea_de_Contrato__c != null){
				idsLineaContrato.add(caso.CAS_LKP_Linea_de_Contrato__c);
			}
		}
		if(!idsLineaContrato.isEmpty()){
			Map<Id,Linea_Contrato__c> mapaLineasContrato = getLCById(idsLineaContrato);
			/*Map<Id, Linea_Contrato__c> mapaLineasContrato = new Map<Id, Linea_Contrato__c>([
				SELECT	LDC_SEL_Unidad_de_periodicidad__c,
						LDC_NUM_Periodicidad__c,
						LDC_NUM_Preaviso_dias__c,
						LDC_LKP_Contrato__r.EndDate
				FROM 	Linea_Contrato__c
				WHERE 	Id IN :idsLineaContrato]);*/
	
			List<Case> listaCasosClonados = new List<Case>();
			for(Case caso : triggerNew){
				Case casoOld = null;
				if(triggerOldMap != null){
					casoOld = triggerOldMap.get(caso.Id);
				}
				//Si el caso ahora está activo y antes estaba inactivo, es preventivo y es un Servicio B2B/B2B2C
				if(Util_B2B.esServB2BB2B2C(caso)
						&& caso.Type == Label.B2B_TIPO_PREVENTIVO 
						&& caso.CAS_LKP_Linea_de_Contrato__c != null
						&& casoOld != null && caso.Status != casoOld.Status && casoOld.Status == Label.CAS_ESTADO_INACTIVO){
					//Clono el caso, le pongo la fecha de activacion que tiene que tener y
					Linea_Contrato__c lineaContrato = mapaLineasContrato.get(caso.CAS_LKP_Linea_de_Contrato__c);
					Case casClon = caso.clone(false, true);
					casClon.Status = Label.CAS_ESTADO_INACTIVO;
					casClon.CAS_LKP_Clon_De__c = caso.Id;
					//Calculo la fecha a partir de la linea de contrato que tiene asociada el caso
					casClon.CAS_DAT_Fecha_activacion__c = caso.CAS_DAT_Fecha_activacion__c.addDays(Util_B2B.devolverDiasPreventivo((Integer) lineaContrato.LDC_NUM_Periodicidad__c, lineaContrato.LDC_SEL_Unidad_de_periodicidad__c));
					system.debug('>>>>lineaContrato.LDC_LKP_Contrato__r.EndDate: ' + lineaContrato.LDC_LKP_Contrato__r.EndDate);
					system.debug('>>>>casClon.CAS_DAT_Fecha_activacion__c: ' + casClon.CAS_DAT_Fecha_activacion__c);
					if(lineaContrato.LDC_LKP_Contrato__r.EndDate >= casClon.CAS_DAT_Fecha_activacion__c){
						casClon.CAS_DAT_Fecha_confirmacion_cita__c = casClon.CAS_DAT_Fecha_activacion__c.addDays(-(Integer) lineaContrato.LDC_NUM_Preaviso_dias__c);
						listaCasosPreventivos.add(casClon);
						listaCasosClonados.add(caso);
						wosCasoClon.put(caso.Id,mapaOTsPorCaso.get(caso.Id));
					}
				}//FIN IF
			}//FIN FOR
			//Inserto los casos preventivos que se tienen que crear con estado inactivo si la lista no está vacia
			if(!listaCasosPreventivos.isEmpty()){
				insert listaCasosPreventivos;
	
				//EN ESTE MAPA ALMACENO LA ID DEL CASO ORIGINAL Y LA ID DEL CASO CLON
				Map<Id, Id> mapaIdCasoClon = new Map<Id, Id>();
				for(Case cas : listaCasosPreventivos){
					mapaIdCasoClon.put(cas.CAS_LKP_Clon_De__c, cas.Id);
				}
				//Clono las WO y las inserto
				Map<Id, WorkOrder> mapaWOClonadas = new Map<Id, WorkOrder>();
				Map<Id, WorkOrder> mapaCasoWOPrincipal = new Map<Id, WorkOrder>();//Este mapa tiene como KEY el ID DEL CASO y como VALUE la WO, para poner en el caso la WO Principal 
				for(Case caso : listaCasosClonados){
					for(WorkOrder ordTbjo : wosCasoClon.get(caso.Id)){
						WorkOrder ordTbjoClon = ordTbjo.clone(false, true);
						ordTbjoClon.OTR_TXT_Num_OrdenTrabajo_HS__c = null;
						ordTbjoClon.CaseId = mapaIdCasoClon.get(ordTbjo.CaseId);
						mapaWOClonadas.put(ordTbjo.Id, ordTbjoClon);
						if(caso.CAS_LKP_Orden_Trabajo_Principal__c == ordTbjo.Id){
							mapaCasoWOPrincipal.put(ordTbjoClon.CaseId, ordTbjoClon);
						}
					}
				}
				if(!mapaWOClonadas.isEmpty()){
					insert mapaWOClonadas.values();
	
					//Clono las WOLI y las inserto
					List<WorkOrderLineItem> listaWoliClon = new List<WorkOrderLineItem>();
					for(WorkOrderLineItem woli : wolisCasoClon.values()){
						if(mapaWOClonadas.containsKey(woli.WorkOrderId)){
							WorkOrderLineItem woliClon = woli.clone();
							woliClon.WorkOrderId = mapaWOClonadas.get(woli.WorkOrderId).Id;
							listaWoliClon.add(woliClon);
						}
					}
					insert listaWoliClon;
	
					//RECORRO LOS CASOS Y VINCULO LA OT PRINCIPAL AL CASO
	
					List<Case> preventivosUpdate = new List<Case>();
					for(Case caso : listaCasosPreventivos){
						WorkOrder woClon = mapaCasoWOPrincipal.get(caso.Id);
						if(woClon != null){
							//Recorro la lista de casosPreventivos que se van a insertar, y le asigno la WO que se ha clonado como OT Principal
							Case temp = new Case(Id=caso.Id);
							temp.CAS_LKP_Orden_Trabajo_Principal__c = woClon.Id;
							preventivosUpdate.add(temp);
							//caso.CAS_LKP_Orden_Trabajo_Principal__c = woClon.Id;
						}
					}
					//update listaCasosPreventivos;
					update preventivosUpdate;
				}
			}//FIN IF !listaCasosPreventivos.isEmpty
		}
	}//FIN activacionPreventivo


	/**
	 * Devuelve un mapa de objetos Direccion-LíneaContrato identificados por el external ID.
	 * 
	 * @param setIds: Conjunto de external Ids de objetos Direccion-LíneaContrato
	 * @return mapa de objetos Direccion-LíneaContrato identificados por el external ID
	 */
	public static Map<String, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getMapaDLC(Set<String> setExtIds){
		Map<String, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapa = new Map<String, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(!setExtIds.isEmpty()){
			List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>(Util_Direcciones_B2B_B2B2C_Lineas.getDLCByIdentificadorExt(setExtIds).values());
			/*List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>(
				[SELECT Id,
				 		DLC_FOR_Linea_Contrato_Activa__c,
				 		DLC_FOR_Linea_Contrato_LimServ__c,
				 		DLC_NUM_Servicios_restantes__c,
				 		DLC_TXT_Identificador__c
				 FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
				 WHERE DLC_TXT_Identificador__c IN :setExtIds]);*/
			if(!lista.isEmpty()){
				for(Direcciones_B2B_B2B2C_Lineas_de_Contrato__c registro : lista){
					mapa.put(registro.DLC_TXT_Identificador__c, registro);
				}
			}
		}
		return mapa;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param dirLC: [PENDIENTE]
	  * @param cuenta: [PENDIENTE]
	  * @param lineaCtr: [PENDIENTE]
	  * @param idRtCasoB2BB2B2C: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	public static Case crearCasoPreventivo(Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC,
			Account cuenta, Linea_Contrato__c lineaCtr,
			Id idRtCasoB2BB2B2C){
		Case caso = null;
		if(dirLC != null && cuenta != null && lineaCtr != null){
			caso = new Case();
			caso.AccountId = dirLC.DLC_LKP_Direccion_B2B_B2B2C__c;
			caso.CAS_LKP_Linea_de_Contrato__c = dirLC.DLC_LKP_Linea_de_Contrato__c;
			caso.CAS_TXT_Identificador_DLC__c = dirLC.DLC_TXT_Identificador__c;
			caso.Status = Label.CAS_ESTADO_INACTIVO;
			caso.Type = Label.B2B_TIPO_PREVENTIVO;
			caso.RecordTypeId = idRtCasoB2BB2B2C;
			caso.CAS_DAT_Fecha_activacion__c = dirLC.DLC_DAT_Activacion_primer_servicio__c;
			caso.CAS_DAT_Fecha_confirmacion_cita__c = dirLC.DLC_DAT_Activacion_primer_servicio__c.addDays(-(Integer)lineaCtr.LDC_NUM_Preaviso_dias__c);
			caso.CAS_SEL_Gremio_Principal__c = lineaCtr.LDC_FOR_Gremio__c;
			caso.CAS_LKP_Compania__c = cuenta.CUE_LKP_Cuenta_principal__c;
			caso.CAS_TXT_DirRiesgo_Poblacion__c = cuenta.ShippingCity;
			caso.CAS_TXT_Direccion__c = cuenta.ShippingStreet;
			caso.CAS_TXT_DirRiesgo_CP__c = cuenta.ShippingPostalCode;
			caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = cuenta.CUE_SEL_Provincia__c;
			caso.CAS_TXT_DirRiesgo_Pais__c = cuenta.ShippingCountry;
		}
		return caso;
	}

	/*public static List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getLCsCorrectDisponibles(WorkOrder ordenDeTrabajo, Id idCuenta,
																							 Boolean filtroPorSeleccionAuto,
																							 Boolean filtroPorUrgente,
																							 Boolean filtroPorSaldo){
		List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(ordenDeTrabajo.OTR_SEL_Gremio__c != null && idCuenta != null){
			String soql = 'SELECT Id,';
			soql += ' DLC_NUM_Servicios_restantes__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__r.LDC_TXT_Observaciones__c,';
			soql += ' DLC_LKP_Linea_de_Contrato__r.Name';
			soql += ' FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c';
			soql += ' WHERE DLC_LKP_Direccion_B2B_B2B2C__c = \'' + idCuenta + '\'';
			soql += ' AND DLC_FOR_Linea_Contrato_Activa__c = true';
			soql += ' AND DLC_FOR_LC_RTDevName__c = \'' + Label.RT_LIN_CON_CORRECTIVO + '\'';
			soql += ' AND (DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = NULL';
			soql += ' OR DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = \'' + ordenDeTrabajo.OTR_SEL_Gremio__c + '\')';
			if(filtroPorSeleccionAuto){
				soql += ' AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Seleccion_Auto__c = true';
			}
			if(filtroPorUrgente){
				soql += ' AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c = ' + ordenDeTrabajo.OTR_CAS_Urgente__c;
			}
			if(filtroPorSaldo){
				soql += ' AND (DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c = NULL OR DLC_NUM_Servicios_restantes__c > 0)';
			}
			system.debug('>>>>>>>>>>>>>getLCsCorrectDisponibles.soql: ' + soql);
			lista = database.query(soql);
		}
		return lista;
	}*/


	/**
	 * Devuelve las tareas de línea de contrato filtradas por un conjunto de ids de línea de contrato.
	 *
	 * @param setIdLineaContrato: conjunto de ids de línea de contrato
	 * @return mapa de tareas de líneas de contratos encontradas
	 */
	public static Map<Id,Tarea_Linea_Contrato__c> queryMapTareaLineaContrato(Set<Id> setIdLineaContrato){
		Map<Id,Tarea_Linea_Contrato__c> mapa = new Map<Id,Tarea_Linea_Contrato__c>();
		if(setIdLineaContrato != null && !setIdLineaContrato.isEmpty()){
			for(List<Tarea_Linea_Contrato__c> lista : [SELECT Id,
															Name,
															TLC_LKP_LineaContrato__c,
															TLC_LKP_Tarea_Tipo_Trabajo__c,
															TLC_LKP_Tarea_Tipo_Trabajo__r.Name,
															TLC_LKP_Tarea_Tipo_Trabajo__r.TTT_LKP_Tipo_Trabajo__c,
															TLC_LKP_Tarea_Tipo_Trabajo__r.TTT_LKP_Tipo_Trabajo__r.Name
														FROM Tarea_Linea_Contrato__c
														WHERE TLC_LKP_LineaContrato__c IN :setIdLineaContrato
														ORDER BY TLC_LKP_LineaContrato__c]){
				mapa.putAll(lista);			
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve las tareas de línea de contrato filtradas por un conjunto de ids de línea de contrato.
	 *
	 * @param setIdLineaContrato: conjunto de ids de línea de contrato
	 * @return lista de tareas de líneas de contratos encontradas
	 */
	/*public static List<Tarea_Linea_Contrato__c> queryTareaLineaContrato(Set<Id> setIdLineaContrato){
		List<Tarea_Linea_Contrato__c> lista = new List<Tarea_Linea_Contrato__c>();
		if(setIdLineaContrato != null && !setIdLineaContrato.isEmpty()){
			lista = [SELECT Id,
							Name,
							TLC_LKP_LineaContrato__c,
							TLC_LKP_Tarea_Tipo_Trabajo__c,
							TLC_LKP_Tarea_Tipo_Trabajo__r.Name,
							TLC_LKP_Tarea_Tipo_Trabajo__r.TTT_LKP_Tipo_Trabajo__c,
							TLC_LKP_Tarea_Tipo_Trabajo__r.TTT_LKP_Tipo_Trabajo__r.Name
					 FROM Tarea_Linea_Contrato__c
					 WHERE TLC_LKP_LineaContrato__c IN :setIdLineaContrato
					 ORDER BY TLC_LKP_LineaContrato__c];
		}
		return lista;
	}*/

	/**
	 * Devuelve los objetos BigMachines__Quote__c filtrados por los IDs de las Órdenes de Trabajo.
	 *
	 * @param setIdOT: IDs de las Órdenes de Trabajo
	 * @return mapa de objetos BigMachines__Quote__c encontrados
	 */
	public static Map<Id,BigMachines__Quote__c> queryMapBigMachinesQuote(set<Id> setIdOT){
		Map<Id,BigMachines__Quote__c> mapa = new Map<Id,BigMachines__Quote__c>();
		if(setIdOT !=  null && !setIdOT.isEmpty()){
			for(List<BigMachines__Quote__c> lista : [SELECT BigMachines__Transaction_Id__c,
								OQU_LKP_Work_Order__c,
								BigMachines__Is_Primary__c
						 FROM BigMachines__Quote__c
						 WHERE OQU_LKP_Work_Order__c IN :setIdOT]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los objetos BigMachines__Quote__c filtrados por el ID de Orden de Trabajo.
	 *
	 * @param idOT: ID de Orden de Trabajo
	 * @return lista de objetos BigMachines__Quote__c encontrados
	 */
	/*public static List<BigMachines__Quote__c> queryBigMachinesQuote(Id idOT){
		List<BigMachines__Quote__c> lista = new List<BigMachines__Quote__c>();
		if(idOT !=  null){
			lista = [SELECT BigMachines__Transaction_Id__c,
							OQU_LKP_Work_Order__c,
							BigMachines__Is_Primary__c
					 FROM BigMachines__Quote__c
					 WHERE OQU_LKP_Work_Order__c = :idOT];
		}
		return lista;
	}*/
	
	/**
	 * Devuelve un mapa de lineas de contrato
	 * @param setIdCont: set de contratos
	 * @return mapa de linea de contrato encontradas
	 */
	public static Map<Id,Linea_Contrato__c> queryLineaContratoByCont(set<Id> setIdCont){
		Map<Id,Linea_Contrato__c> mapa = new Map<Id,Linea_Contrato__c>();
		if(setIdCont !=  null && !setIdCont.isEmpty()){
			for(List<Linea_Contrato__c> lista : [SELECT Id,
				                   				  Name,
				                				  RecordTypeId,
				                				  LDC_NUM_Preaviso_dias__c,
				                				  LDC_SEL_Gremio__c,
				                				  LDC_LKP_Contrato__c,
				                				  LDC_NUM_Limite_de_servicios__c,
				                				  LDC_NUM_Periodicidad__c,
				                				  LDC_LKP_Tipo_Trabajo__c,
				                				  LDC_SEL_Unidad_de_periodicidad__c,
				                				  LDC_LKP_Contrato__r.AccountId,
				                				  LDC_FOR_RTDevName__c,
				                				  LDC_LKP_Contrato__r.Status,
				                				  LDC_CAS_Urgente__c
				                				  FROM Linea_Contrato__c
				                				  WHERE LDC_LKP_Contrato__c IN :setIdCont]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	public static Map<Id,Linea_Contrato__c> queryLineaContratoByCuentaStatusRecordTypeActivo(set<Id> setIdCuenta, set<String> setStatus, set<Id> setRecordType, boolean activo){
		Map<Id,Linea_Contrato__c> mapa = new Map<Id,Linea_Contrato__c>();
		if(setIdCuenta !=  null && !setIdCuenta.isEmpty() && setStatus !=  null && !setStatus.isEmpty() 
			&& setRecordType !=  null && !setRecordType.isEmpty() && activo !=  null){
			for(List<Linea_Contrato__c> lista : [SELECT	Id,
			                                       LDC_LKP_Contrato__r.AccountId,
			                                       RecordTypeId,
			                                       LDC_NUM_Limite_de_servicios__c
			                                       FROM 	Linea_Contrato__c
			                                       WHERE 	LDC_LKP_Contrato__r.AccountId IN :setIdCuenta
			                                       AND LDC_LKP_Contrato__r.Status IN : setStatus
			                                       AND RecordTypeId IN :setRecordType
			                                       AND LDC_CAS_Activo__c =: activo]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Query para traer las lineas de contrato por Id y por RecordType
	 * @param idLinCont id de las lineas con las que buscar
	 * @return devuelve un mapa con los resultados encontrados
	 */
	public static Map<Id,Linea_Contrato__c> queryLineaContratoPreventivoById(set<Id> setIdLinCon, Id rtRecord){
		Map<Id,Linea_Contrato__c> mapa = new Map<Id,Linea_Contrato__c>();
		if(setIdLinCon !=  null && !setIdLinCon.isEmpty()){
			for(List<Linea_Contrato__c> lista : [SELECT Id,
													Name,
													RecordTypeId,
													LDC_FOR_Gremio__c,
													LDC_SEL_Gremio__c,
													LDC_LKP_Tipo_Trabajo__c,
													LDC_LKP_Tipo_Trabajo__r.Name,
													LDC_NUM_Preaviso_dias__c,
													LDC_LKP_Contrato__r.AccountId
				                				  FROM Linea_Contrato__c
				                				  WHERE Id IN :setIdLinCon AND RecordTypeId = :rtRecord]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Query para traer las lineas de contrato Nombre
	 * @param setNames: conjunto de nombres de linea ade contrato.
	 * @return devuelve un mapa con los resultados encontrados
	 */
	public static Map<Id,Linea_Contrato__c> queryLineaContratoByName(set<String> setNames){
		Map<Id,Linea_Contrato__c> mapa = new Map<Id,Linea_Contrato__c>();
		if(setNames !=  null && !setNames.isEmpty()){
			for(List<Linea_Contrato__c> lista : [Select Id,			
                                        Name,
                                        LDC_LKP_Contrato__c,
                                        LDC_NUM_Limite_de_servicios__c,
                                        LDC_SEL_Gremio__c,
                                        RecordTypeId,
                                        LDC_CAS_Activo__c
                                        FROM Linea_Contrato__c Where Name IN :setNames]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las Líneas de Contrato filtradas por los IDs.
	 *
	 * @param setId: conjunto de IDs de Líneas de Contrato
	 *
	 * @return mapa que contiene las Líneas de Contrato encontradas
	 */
	public static Map<Id,Linea_Contrato__c> getLCById(Set<Id> setId){
		Map<Id,Linea_Contrato__c> mapa = new Map<Id,Linea_Contrato__c>();
		if(setId != null && !setId.isEmpty()){
			for(List<Linea_Contrato__c> lista:[SELECT LDC_SEL_Unidad_de_periodicidad__c,LDC_NUM_Periodicidad__c,LDC_NUM_Preaviso_dias__c,LDC_LKP_Contrato__r.EndDate
                                                FROM Linea_Contrato__c
                                                WHERE Id IN :setId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}