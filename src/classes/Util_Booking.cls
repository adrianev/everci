/**
 * Clase que se utilizará para los servicios que realizan un booking
 * @author everis
 * @version 1.0
 */
public without sharing class Util_Booking {

	/*Método que devuelve el número de cita de una orden de trabajo*/
	public static String NumeroCita(String ordenTrabajo) {
		List<ServiceAppointment> citaServicio = Util_Cita_Servicio.getMapCitasByOTs(new Set<Id>{ordenTrabajo}).values();
		String ServiceAppointment = citaServicio[0].AppointmentNumber;
		return ServiceAppointment;
	}

	/*Método que devuelve el listado de franjas disponibles para un profesional*/
	public static List<Rest_Franja_RP> franjas(String AppointmentNumber, String CAS_SEL_origen_web) {
		List<Rest_Franja_RP> auxFranjasList = new List<Rest_Franja_RP>();
		String fechaProv, fecha;
        String[] arrRango = new String[]{};

		List<ServiceAppointment> listaSA = new List<ServiceAppointment>{Util_Cita_Servicio.getMapCitasByNum(new Set<String>{AppointmentNumber}).values().get(0)};
		if (CAS_SEL_origen_web == Label.CAS_ORIGEN_CLIENTE_WEB) {
			if(listaSA == null || listaSA.size() == 0){
				return auxFranjasList;
			}
		}

		ServiceAppointment sa = listaSA.get(0);
		
		//Añadido para WORTEN
		List<WorkOrder> infoCuenta = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{sa.ParentRecordId}).values();
		
		Date dia = date.valueof(infoCuenta[0].Case.CAS_DAT_Recepcion_Producto_b2b2c__c);
		String nombreDia = Datetime.newInstance(dia,Time.newInstance(12, 0, 0, 0)).format('EEEE');
		if (nombreDia == 'Wednesday' || nombreDia == 'Thursday' || nombreDia == 'Friday') {
			sa.EarliestStartTime = infoCuenta[0].Case.CAS_DAT_Recepcion_Producto_b2b2c__c.addDays(2);
		}
		else {
			sa.EarliestStartTime = infoCuenta[0].Case.CAS_DAT_Recepcion_Producto_b2b2c__c;
		}
		
		if (infoCuenta[0].Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_WORTEN) {
			
			/*Cambios para citas de worten, dependiendo si es o no urgente, y si es o no ola de calor*/
			if (sa.CSE_SEL_Gremio__c == Label.GREMIO_AIREACONDICIONADO) {
				//Si es urgente
				if (infoCuenta[0].Case.CAS_CAS_Urgente__c) {
					sa.EarliestStartTime = infoCuenta[0].Case.CAS_DAT_Recepcion_Producto_b2b2c__c.addDays(Integer.valueOf(Label.SLA_Worten_UrgenteCapital));
					if (Util_TerritorioServicio.esCapitalDeProvincia(sa.Account.ShippingPostalCode)) {
						sa.DueDate = sa.EarliestStartTime;
					}
					else {
						sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten_Urgente));
					}
				}
				//Si no es urgente pero está en ola de calor
				else if (sa.Account.CUE_CAS_Ola_calor__c) {
					sa.EarliestStartTime = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten));
					sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten_olaCalor));
				}
				//Cuando no es urgente
				else {
					sa.EarliestStartTime = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten));
					sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten_noUrgente));
				}
			}
			else {
				sa.EarliestStartTime = infoCuenta[0].Case.CAS_DAT_Recepcion_Producto_b2b2c__c.addDays(2);
				sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten1));
			}
			/*Fin de cambios para worten*/
		}
		else {
			sa.EarliestStartTime = sa.EarliestStartTime.addDays(2);
		}
		
		Baipas.establecerVariableControl();
		update sa;
		Baipas.deshabilitarVariableControl();
		
		if(infoCuenta[0].Case.CAS_LKP_Compania__r.CUE_CAS_BOManual__c){
			auxFranjasList = calendarioFake(auxFranjasList, sa.EarliestStartTime, sa.DueDate, infoCuenta[0], fechaProv, arrRango);
		}
		else {
			OperatingHours abOperatingHours = Util_Service_Resource.getOperatingHoursByName(new Set<String>{Label.OPH_NOMBRE_HORARIO_DEFECTO}).values()[0];
			Id schedulingPolicyId = Util_FSL.getFSLSchedPol(new Set<String>{Label.FSL_POLITICA_POR_DEFECTO}).values()[0].Id;
			Timezone tz = UserInfo.getTimeZone();
			List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(sa.Id, schedulingPolicyId, abOperatingHours, tz,'SORT_BY_DATE', false);
			
	        for(integer i=0; i<slots.size(); i++){
				Rest_Franja_RP franjasAux = new Rest_Franja_RP();
	
				String intervaloInicial = string.valueOfGmt(slots[i].Interval.Start);
				String intervaloFinal = string.valueOfGmt(slots[i].Interval.Finish);
				String[] arrFechaInicial = intervaloInicial.split(' ');
				String[] arrFechaFinal = intervaloFinal.split(' ');
	
				String rangoInicio = arrFechaInicial[1].substring(0,5);
				String rangoFin = arrFechaFinal[1].substring(0,5);
				String intervalo = rangoInicio + ' - ' + rangoFin;
	
				String rango =  Util_Listas_Seleccion.getValorAPIDesdeLabel('WorkOrder','OTR_SEL_Rango_Ultima_Cita__c', intervalo);
				
				if (fechaProv == arrFechaInicial[0]) {
					arrRango.add(rango);
				}
				else {
					if (i > 0) {
						franjasAux.fecha = fechaProv;
						String allFranjas = string.join(arrRango, ',');
						franjasAux.rango = new String[]{};
						franjasAux.rango.add(allFranjas);
						auxFranjasList.add(franjasAux);
						arrRango.clear();
					}
					fechaProv = arrFechaInicial[0];
					arrRango.add(rango);
				}
				if (i == slots.size() - 1) {
					franjasAux.fecha = fechaProv;
					String allFranjas = string.join(arrRango, ',');
					franjasAux.rango = new String[]{};
					franjasAux.rango.add(allFranjas);
					auxFranjasList.add(franjasAux);
					arrRango.clear();
				}
	        }
		}
		system.debug('>>>>>>>>>>franjas.auxFranjasList: ' + auxFranjasList);
		return auxFranjasList;
	}

	/*Método que crea una WorkOrder nueva con una cita de servicio y devuelve las franjas disponibles*/
	public static List<Rest_Franja_RP> BookingFranjas(String AccountId, String CaseId, String WorkTypeId, String CAS_SEL_origen_web) {
		List<Rest_Franja_RP> listaAuxFranjas = new List<Rest_Franja_RP>();
		List<Case> caso = Util_Caso.getCaseById(new Set<Id>{CaseId}).values();
		
		//Crear un wo con una cita de servicio
		WorkOrder ordenTrabajo = new WorkOrder();
		ordenTrabajo.AccountId = AccountId;
		ordenTrabajo.CaseId = CaseId;
		ordenTrabajo.OTR_SEL_Gremio__c = caso[0].CAS_SEL_Gremio_Principal__c;
		if(!String.isEmpty(WorkTypeId)){
			ordenTrabajo.WorkTypeId = WorkTypeId;
		}
		// Vincular automáticamente la Línea de Contrato Correctiva correspondiente
		// si el caso es un Servicio B2B/B2B2C Correctivo
		if(!caso[0].CAS_FOR_EsB2C__c && caso[0].Type == Label.B2B_TIPO_CORRECTIVO){
			List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaDirLCauto = Util_Direcciones_B2B_B2B2C_Lineas.getLCsCorrectDisponiblesPorSeleccionAutoAndPorSaldo(new Set<Id>{AccountId},true,new Set<String>{Label.RT_LIN_CON_CORRECTIVO},new Set<String>{ordenTrabajo.OTR_SEL_Gremio__c},true,0).values();
			if(!listaDirLCauto.isEmpty()){
				ordenTrabajo.OTR_LKP_Linea_Contrato__c = listaDirLCauto.get(0).DLC_LKP_Linea_de_Contrato__c;
			}
		}
		insert ordenTrabajo;

		caso[0].CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
		caso[0].CAS_LKP_Tipo_Trabajo__c = ordenTrabajo.WorkTypeId;
		Baipas.establecerVariableControl();
		update caso[0];
		Baipas.deshabilitarVariableControl();
		
		//Llamar funcion franjas
		listaAuxFranjas = franjas(NumeroCita(ordenTrabajo.Id), CAS_SEL_origen_web);
		System.debug('>>>>>>>>>BookingFranjas.listaAuxFranjas: ' + listaAuxFranjas);
		return listaAuxFranjas;
	}

	/*Método que realiza un cambio de Cita*/
	public static Rest_B2C_SolicitudCita_RP setAppointment(String OTR_DAT_Fecha_Ultima_Cita, String OTR_SEL_Rango_Ultima_Cita, String AppointmentNumber, String CAS_SEL_origen_web) {
		Rest_B2C_SolicitudCita_RP respuesta = new Rest_B2C_SolicitudCita_RP();
		FSL.ScheduleResult scheduleResult =  new FSL.ScheduleResult();
		Id schedulingPolicyId;
		try{
			List<ServiceAppointment> sa = new List<ServiceAppointment>{Util_Cita_Servicio.getMapCitasByNum(new Set<String>{AppointmentNumber}).values()[0]};

			if (sa == null || sa.size() == 0) {
				if (CAS_SEL_origen_web == Label.CAS_ORIGEN_CLIENTE_WEB) {
					respuesta.code='MEM-011';
					respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
					return respuesta;
				}
				else if (CAS_SEL_origen_web == Label.CAS_ORIGEN_LANDING_B2B2C) {
					respuesta.code='API-004';
					respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
					return respuesta;
				}
				return respuesta;
			}

			List<WorkOrder> ordenTrabajo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{sa[0].ParentRecordId}).values();
			
			if(!ordenTrabajo[0].Case.CAS_LKP_Compania__r.CUE_CAS_BOManual__c){
				schedulingPolicyId = Util_FSL.getFSLSchedPol(new Set<String>{Label.FSL_POLITICA_POR_DEFECTO}).values()[0].Id;
				if(schedulingPolicyId == null || ''.equals(schedulingPolicyId)){
					if (CAS_SEL_origen_web == Label.CAS_ORIGEN_CLIENTE_WEB) {
						respuesta.code='MEM-011';
						respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
						return respuesta;
					}
					else if (CAS_SEL_origen_web == Label.CAS_ORIGEN_LANDING_B2B2C) {
						respuesta.code='API-004';
						respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
						return respuesta;
					}
					return respuesta;
				}
			}

			String rangoLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Rango_Ultima_Cita__c').get(OTR_SEL_Rango_Ultima_Cita);
			String[] arrRango = rangoLiteral.split('-');

			String[] hora1 = arrRango[0].split(':');
			hora1[1] = hora1[1].trim();
			if (hora1[0] == '00') {
				hora1[0] = String.valueOf(0);
			}
			if (hora1[1] == '00') {
				hora1[1] = String.valueOf(0);
			}

			String[] hora2 = arrRango[1].split(':');
			hora2[0] = hora2[0].trim();
			if (hora2[0] == '00') {
				hora2[0] = String.valueOf(0);
			}
			if (hora2[1] == '00') {
				hora2[1] = String.valueOf(0);
			}

			Date fecha = date.valueOf(OTR_DAT_Fecha_Ultima_Cita);
			Time intervalo1 = Time.newInstance(integer.valueOf(hora1[0]), integer.valueOf(hora1[1]), 0, 0);
			Time intervalo2 = Time.newInstance(integer.valueOf(hora2[0]), integer.valueOf(hora2[1]), 0, 0);

			DateTime intervaloInicial = DateTime.newInstance(fecha, intervalo1);
			DateTime intervaloFinal = DateTime.newInstance(fecha, intervalo2);
			
			sa[0].ArrivalWindowStartTime = intervaloInicial;
			sa[0].ArrivalWindowEndTime = intervaloFinal;
			
			
			if (ordenTrabajo[0].Case.CAS_LKP_Compania__r.CUE_CAS_BOManual__c) {
				update sa[0];
			}
			else {
				
				Baipas.establecerVariableControl();
				update sa[0];
				Baipas.deshabilitarVariableControl();
				
				scheduleResult = FSL.ScheduleService.Schedule(schedulingPolicyId, sa[0].Id);
				if (scheduleResult != null)
				{
					if (CAS_SEL_origen_web == Label.CAS_ORIGEN_CLIENTE_WEB) {
						respuesta.code='MEM-001';
						respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
						return respuesta;
					}
					else if (CAS_SEL_origen_web == Label.CAS_ORIGEN_LANDING_B2B2C) {
						respuesta.code='API-001';
						respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
						return respuesta;
					}
					return respuesta;
				}
				else
				{
					if (CAS_SEL_origen_web == Label.CAS_ORIGEN_CLIENTE_WEB) {
						respuesta.code='MEM-011';
						respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
						return respuesta;
					}
					else if (CAS_SEL_origen_web == Label.CAS_ORIGEN_LANDING_B2B2C) {
						respuesta.code='API-004';
						respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
						return respuesta;
					}
				}
			}

		}catch(Exception e)
		{
			respuesta.code='MEM-013';
			respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
		}
		return respuesta;
	}
	
	//Método que te devuelve true si el día analizado es festivo en un área determinada
	public static Boolean isFestivo(Date dia, String strCP) {
		List<Festivos__c> listaFestivos = Util_Festivos.getFestivoByFecha(new Set<Date>{dia}).values();
		
		Boolean esFestivo = false;
		
		if (!listaFestivos.isEmpty()){
			for(Festivos__c festivo:listaFestivos){
				if(festivo.FES_SEL_Tipo_de_Festivo__c == Label.FES_TIPO_NACIONAL){
					esFestivo = true;
				}else{
					if(festivo.FES_SEL_Provincia__c != null){
						List <String> listaProvincias = festivo.FES_SEL_Provincia__c.split(';');
						String provincia = strCp.subString(0,2);
						if(listaProvincias.contains(provincia)){
							esFestivo = true;
						}
					}else{
						if(festivo.FES_LKP_Territorio__r.Name != null){
							if(festivo.FES_LKP_Territorio__r.Name == strCP){
								esFestivo = true;
							}
						}
					}
				}
			}			
		}
		return esFestivo;
	}
	
	//Método que te devuelve la lista de franjas horarias del calendario fake
	public static List<Rest_Franja_RP> calendarioFake (List<Rest_Franja_RP> auxFranjasList, Datetime earliestStartTime, Datetime dueDate, WorkOrder wo, String fechaProv, String[] arrRango){
			Integer nDays = date.valueof(earliestStartTime).daysBetween(date.valueof(dueDate));
			Integer i = 0;
			Date dia = date.valueof(earliestStartTime);			
			while(i<=nDays){
			    String nombreDia = Datetime.newInstance(dia,Time.newInstance(12, 0, 0, 0)).format('EEEE');
			    if (nombreDia == 'Saturday'){
			        dia = dia.addDays(2);
			    } else if (nombreDia == 'Sunday'){
			        dia = dia.addDays(1);
			    } else if (isFestivo(dia, wo.Case.CAS_TXT_DirRiesgo_CP__c)){
			    	dia = dia.addDays(1);
			    } else {
			        Rest_Franja_RP franjasAux = new Rest_Franja_RP();
			        String [] diaDate = string.valueOf(Datetime.newInstance(dia,Time.newInstance(12, 0, 0, 0))).split(' ');
			        for(Integer j=8; j<20; j=j+2){
			        	
			            Datetime startTime = Datetime.newInstance(dia,Time.newInstance(j, 0, 0, 0));
			            Datetime endTime = Datetime.newInstance(dia,Time.newInstance(j+2, 0, 0, 0));
			            String[] arrFechaInicial = string.valueOf(startTime).split(' ');
						String[] arrFechaFinal = string.valueOf(endTime).split(' ');
						String rangoInicio = arrFechaInicial[1].substring(0,5);
						String rangoFin = arrFechaFinal[1].substring(0,5);
						String intervalo = rangoInicio + ' - ' + rangoFin;
			            
			            String rango =  Util_Listas_Seleccion.getValorAPIDesdeLabel('WorkOrder','OTR_SEL_Rango_Ultima_Cita__c', intervalo);
			            
			            if (fechaProv != arrFechaInicial[0]) {
							arrRango.add(rango);
							fechaProv = arrFechaInicial[0];
						}
						else {
							franjasAux.fecha = fechaProv;
							String allFranjas = string.join(arrRango, ',');
							franjasAux.rango = new String[]{};
							franjasAux.rango.add(allFranjas);
							arrRango.add(rango);
						}
						if (j == 18) {
							franjasAux.fecha = fechaProv;
							String allFranjas = string.join(arrRango, ',');
							franjasAux.rango = new String[]{};
							franjasAux.rango.add(allFranjas);
							arrRango.clear();
						}
			        }	

			        dia = dia.addDays(1);
			        i++;
			        auxFranjasList.add(franjasAux);
			    }
			}
			return auxFranjasList;
	}
}