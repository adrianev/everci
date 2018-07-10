/**
 * Todo: Clase que se utilizará para exponer un servicio a SF para la inserción de Facturas.
 * @author everis
 * @version 1.0
 */
@RestResource(urlMapping='/facturador/factura/')
global without sharing class Rest_Fac_infoFacturas {
	private static Integer contParametros;
	public static String response ='';
	global class listaCasos{
		public String identificadorUnicoCaso;
		public listaCasos(String identificadorUnicoCaso){
			this.identificadorUnicoCaso = identificadorUnicoCaso;
			system.debug('>>>>>identificadorUnicoCaso: ' + identificadorUnicoCaso);
		}   
	}

	global class listaWO{
		public String identificadorUnicoOrdenTrabajo;
		public listaWO(String identificadorUnicoOrdenTrabajo){
			this.identificadorUnicoOrdenTrabajo = identificadorUnicoOrdenTrabajo;
			system.debug('>>>>>identificadorUnicoOrdenTrabajo: ' + identificadorUnicoOrdenTrabajo);
		}
	}
	@HttpPost
	global static void doPost(
			List<listaCasos> listaCasos,
			List<listaWO> listaWO,
			String identificadorUnicoCuentaProf,
			String identificadorUnicoCuentaClie,
			String identificadorUnicoEvento,
			String identificadorUnicoAbono,
			Integer anioFactura,
			Double importePago,
			Integer mesPago,
			Double retencionPago,
			String numeroFactura,
			Date fechaFactura,
			String codigoCapital,
			Double importeFranquicia,
			Double importeFinal, 
			Double importeIva,
			Integer porcentajeIva,
			Boolean indicadorFranquicia,
			String tipoRegistro,
			Integer indicadorQuincena,
			Double totalImporte,
			Boolean facturaGestion
			) {

		system.debug('>>>>>listaCasos: ' + listaCasos);
		system.debug('>>>>>listaWO: ' + listaWO);
		system.debug('>>>>>identificadorUnicoCuentaProf: ' + identificadorUnicoCuentaProf);
		system.debug('>>>>>identificadorUnicoCuentaClie: ' + identificadorUnicoCuentaClie);
		system.debug('>>>>>identificadorUnicoEvento: ' + identificadorUnicoEvento);
		system.debug('>>>>>identificadorUnicoAbono: ' + identificadorUnicoAbono);
		system.debug('>>>>>anioFactura: ' + anioFactura);
		system.debug('>>>>>importePago: ' + importePago);
		system.debug('>>>>>mesPago: ' + mesPago);
		system.debug('>>>>>retencionPago: ' + retencionPago);
		system.debug('>>>>>numeroFactura: ' + numeroFactura);
		system.debug('>>>>>fechaFactura: ' + fechaFactura);
		system.debug('>>>>>codigoCapital: ' + codigoCapital);
		system.debug('>>>>>importeFranquicia: ' + importeFranquicia);
		system.debug('>>>>>importeFinal: ' + importeFinal);
		system.debug('>>>>>importeIva: ' + importeIva);
		system.debug('>>>>>porcentajeIva: ' + porcentajeIva);
		system.debug('>>>>>indicadorFranquicia: ' + indicadorFranquicia);
		system.debug('>>>>>tipoRegistro: ' + tipoRegistro);
		system.debug('>>>>>indicadorQuincena: ' + indicadorQuincena);
		system.debug('>>>>>totalImporte: ' + totalImporte);
		system.debug('>>>>>facturaGestion: ' + facturaGestion);

		Rest_Fac_infoFacturas_RP respuesta = new Rest_Fac_infoFacturas_RP();
		Factura__c fac = new Factura__c();
		List<Factura__c> listFac = new List<Factura__c>();
		List<String> casosIds = new List<String>();
		List<String> wOIds = new List<String>();
		List<Case> casosToUpdate = new List<Case>();
		//List<WorkOrder> woToUpdate = new List<WorkOrder>();
		List<Propuesta_de_Abono__c> listaAbonos = new List<Propuesta_de_Abono__c>();
		List<Propuesta_de_Evento__c> listaEventos = new List<Propuesta_de_Evento__c>();
		Map<Id,WorkOrder> woToUpdate = new Map<Id,WorkOrder>();
		Set<Id> setIds = new Set<Id>();
		for(listaCasos casoId : listaCasos){
			if(casoId.identificadorUnicoCaso!= null && casoId.identificadorUnicoCaso != '')
				setIds.add((Id) casoId.identificadorUnicoCaso);
		}
		for(listaWO woId:listaWO){setIds.add((Id) woId.identificadorUnicoOrdenTrabajo);}
		Map<Id,Case> mapaCasos = Util_Caso.getCaseById(setIds);
		Map<Id,WorkOrder> mapaOTs = new Map<Id,WorkOrder>([SELECT Id,OTR_CAS_Orden_Trabajo_Facturada__c,CaseId,Case.RecordTypeId,Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, RecordTypeId FROM WorkOrder WHERE Id IN : setIds AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)]);
		WorkOrder woAbono = new WorkOrder();
		WorkOrder woEvento = new WorkOrder();
		system.debug('>>>>>setIds: ' + setIds);
		system.debug('>>>>>verMapaOTs: ' + mapaOTs);
		Account cuentaClient = new Account();
		if(identificadorUnicoCuentaClie != null && identificadorUnicoCuentaClie!= ''){
			cuentaClient = ([SELECT RecordTypeId FROM Account WHERE Id =: identificadorUnicoCuentaClie]);
		}
		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
		Propuesta_de_Abono__c abono = new Propuesta_de_Abono__c();
		if(identificadorUnicoAbono != null && identificadorUnicoAbono != ''){
			abono = [SELECT Id, AB_LKP_Orden_de_Trabajo__r.Case.RecordTypeId FROM Propuesta_de_Abono__c WHERE id =: identificadorUnicoAbono];
		}


		//try{
			system.debug('>>>>>identificadorUnicoEventoTry: ' + identificadorUnicoEvento);
			system.debug('>>>>>EV_AB_SEL_Tipo_de_Evento__c: ' + evento.EV_AB_SEL_Tipo_de_Evento__c);
			if(identificadorUnicoEvento != null && identificadorUnicoEvento != '' && !facturaGestion){
				evento = ([SELECT EV_AB_SEL_Tipo_de_Evento__c
									,EV_AB_CAS_Evento_Ab_Facturado__c
									,EV_AB_CAS_Evento_Ab_Liquidado__c
									,EV_AB_DAT_Fecha_Facturacion__c
									,EV_AB_DAT_Fecha_Liquidacion__c
									,EV_AB_LKP_Orden_de_Trabajo__c FROM Propuesta_de_Evento__c WHERE Id =: identificadorUnicoEvento]);

				system.debug('>>>>>TipoDeEvento: ' + evento.EV_AB_SEL_Tipo_de_Evento__c);
				if(evento.EV_AB_SEL_Tipo_de_Evento__c == Label.TIPO_EVENTO_COBRO){
					evento.EV_AB_CAS_Evento_Ab_Facturado__c = true;
					evento.EV_AB_DAT_Fecha_Facturacion__c = system.now();
					update evento;
					woEvento = facturarServicioEvento(evento);
					woToUpdate.put(woEvento.Id,woEvento);
				} else if (evento.EV_AB_SEL_Tipo_de_Evento__c == Label.TIPO_EVENTO_PAGO){
					evento.EV_AB_CAS_Evento_Ab_Liquidado__c = true;
					evento.EV_AB_DAT_Fecha_Liquidacion__c = system.now();
					update evento;
					woEvento = liquidarServicioEvento(evento);
					woToUpdate.put(woEvento.Id,woEvento);
				}
				/*update evento;

				if(evento.EV_AB_SEL_Tipo_de_Evento__c == Label.TIPO_EVENTO_COBRO){
					woEvento = facturarServicioEvento(evento);
					woToUpdate.put(woEvento.Id,woEvento);
				} else if (evento.EV_AB_SEL_Tipo_de_Evento__c == Label.TIPO_EVENTO_PAGO){
					woEvento = liquidarServicioEvento(evento);
					woToUpdate.put(woEvento.Id,woEvento);
				}*/
			}

			system.debug('>>>>>identificadorUnicoAbono: ' + identificadorUnicoAbono);
			if(identificadorUnicoAbono != null && identificadorUnicoAbono != '' && !facturaGestion){
				abono.Id = identificadorUnicoAbono;
				abono.AB_CAS_Abono_Liquidado__c = true;
				abono.AB_DAT_Fecha_Liquidacion__c = system.today();
				update abono;
				if(abono.AB_LKP_Orden_de_Trabajo__c != null)
					woAbono = liquidarServicioAbono(abono);
					woToUpdate.put(woAbono.Id, woAbono);
					system.debug('>>>>>verMapaWoToUpdate: ' + woToUpdate);
			}

			List<WorkOrder> listaCaseId = new List<WorkOrder>();
			List<WorkOrder> listaOTByCaseId = new List<WorkOrder>();

			if(setIds != null && (!setIds.isEmpty())){
				listaCaseId = ([SELECT CaseId FROM WorkOrder WHERE Id IN :setIds]);
				List<Id> listaID = new List<Id>();
				for(WorkOrder cs:listaCaseId){
					listaID.add(cs.CaseId);
				}
				listaOTByCaseId = ([SELECT Id, OTR_CAS_Orden_Trabajo_Facturada__c, OTR_CAS_Orden_Trabajo_Liquidada__c, CaseId, Case.RecordTypeId
							FROM WorkOrder WHERE CaseId IN :listaID AND RecordTypeId = :Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C)]);	
			}

			List<WorkOrder> lista = new List<WorkOrder>();
			Map<Id, List<WorkOrder>> mapaOT = new Map<Id, List<WorkOrder>>();
	        if(setIds != null && (!setIds.isEmpty())){
	            lista = ([SELECT Id,
	                        CaseId,
	                        OTR_CAS_Orden_Trabajo_Facturada__c,
	                        OTR_CAS_Orden_Trabajo_Liquidada__c,
	                        Case.CAS_CAS_Liquidado__c,
	                        Case.CAS_CAS_Siniestro_Facturado__c
	                 FROM WorkOrder WHERE CaseId IN :setIds
	                 AND RecordTypeId = :Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C)]);
	            for(WorkOrder registro : lista){
	                List<WorkOrder> listaAux = mapaOT.get(registro.CaseId);
	                if(listaAux == null){
	                    listaAux = new List<WorkOrder>();
	                }
	                listaAux.add(registro);
	                mapaOT.put(registro.CaseId, listaAux);
	            }
	        }

			List<Id> idCaso = new List<Id>();
			for(WorkOrder ls:lista){
				idCaso.add(ls.CaseId);
				system.debug('>>>>>ls.CaseId: ' + ls.CaseId);
			}

			List<Case> siniestros = new List<Case>([SELECT Id, CAS_CAS_Siniestro_Facturado__c, CAS_CAS_Liquidado__c FROM Case WHERE Id IN :idCaso]);

			for(Case caso:siniestros){
				if(mapaOT != null && !mapaOT.isEmpty()){
					List<WorkOrder> ListWO = mapaOT.get(caso.Id);
					caso.CAS_CAS_Siniestro_Facturado__c = true;
					caso.CAS_CAS_Liquidado__c = true;
					for(WorkOrder wo:ListWO){
						system.debug('>>>>>verWoId: ' + wo.Id);
						if(wo.OTR_CAS_Orden_Trabajo_Facturada__c == false){
							caso.CAS_CAS_Siniestro_Facturado__c = false;
						}
						if(wo.OTR_CAS_Orden_Trabajo_Liquidada__c == false){
							caso.CAS_CAS_Liquidado__c = false;
						}
					}
					casosToUpdate.add(caso);
				}
			}

			for(listaCasos casoId:listaCasos){
				fac = new Factura__c();
				//marco check facturado //Pendiente ver si borrar el if de aquí y marcar check de facturado en otro sitio
				if(mapaCasos.get(casoId.identificadorUnicoCaso)!=null && (identificadorUnicoCuentaClie != null && identificadorUnicoCuentaClie != '') && !facturaGestion){
					system.debug('>>>>>DentroFacturarSiniestro');
					mapaCasos.get(casoId.identificadorUnicoCaso).CAS_CAS_Siniestro_Facturado__c = true;
					if(!casosToUpdate.contains(mapaCasos.get(casoId.identificadorUnicoCaso))){
						casosToUpdate.add(mapaCasos.get(casoId.identificadorUnicoCaso));
					}
				}
				fac.FAC_LKP_Caso__c = casoId.identificadorUnicoCaso;
				if(identificadorUnicoCuentaClie != '')
					fac.FAC_LKP_Cuenta__c = identificadorUnicoCuentaClie;
				if(identificadorUnicoCuentaProf != '')
					fac.FAC_LKP_Cuenta__c = identificadorUnicoCuentaProf; 
				fac.FAC_NUM_Ano_Pago__c = anioFactura; 
				fac.FAC_DIV_ImporteFactura__c = importePago;
				fac.FAC_NUM_MesPago__c = mesPago;
				fac.FAC_DIV_RetencionPago__c = retencionPago;
				fac.FAC_TXT_Numero_Factura__c = numeroFactura;
				fac.FAC_DAT_FechaFactura__c = fechaFactura;
				fac.FAC_TXT_Codigo_Capital__c = codigoCapital;
				fac.FAC_DIV_ImporteFranquicia__c = importeFranquicia;
				fac.FAC_NUM_ImporteFinal__c = importeFinal;
				fac.FAC_NUM_ImporteIVA__c = importeIva;
				fac.FAC_POR_PorcentajeIVA__c = porcentajeIva;
				fac.FAC_CAS_IndicadorPagoFranquicia__c = indicadorFranquicia;
				fac.FAC_TXT_Tipo_Registro__c = tipoRegistro;
				fac.FAC_NUM_IndicadorQuincena__c = indicadorQuincena;
				fac.FAC_NUM_TotalImportes__c = totalImporte;
				fac.FAC_CAS_Factura_de_Gestion__c = facturaGestion;
				listFac.add(fac);
			}

			List<Id> casosFacturados = new List<Id>();
			for(listaCasos csId:listaCasos){
				if((csId.identificadorUnicoCaso != null) && (identificadorUnicoCuentaClie != null) && (
				cuentaClient.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2) ||
				cuentaClient.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_ASEGURADO) ||
				cuentaClient.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR)) && !facturaGestion){
					system.debug('>>>>>DentroFacturarCaso');
					mapaCasos.get(csId.identificadorUnicoCaso).CAS_CAS_Siniestro_Facturado__c = true;
					if(!casosToUpdate.contains(mapaCasos.get(csId.identificadorUnicoCaso)))
						casosToUpdate.add(mapaCasos.get(csId.identificadorUnicoCaso));
				}

				if((csId.identificadorUnicoCaso != null) && (identificadorUnicoCuentaProf != null && identificadorUnicoCuentaProf != '') && !facturaGestion){
					mapaCasos.get(csId.identificadorUnicoCaso).CAS_CAS_Liquidado__c= true;
					if(!casosToUpdate.contains(mapaCasos.get(csId.identificadorUnicoCaso)))
						casosToUpdate.add(mapaCasos.get(csId.identificadorUnicoCaso));
				}
			}

			if(!facturaGestion){
				update woToUpdate.values();
				system.debug('>>>>>woToUpdate: ' + woToUpdate);
				update casosToUpdate;
				system.debug('>>>>>casosToUpdate: ' + casosToUpdate);
			}


			List<WorkOrder> WOcasoFacLiq = new List<WorkOrder>([SELECT Id, OTR_CAS_Orden_Trabajo_Facturada__c, Case.CAS_CAS_Siniestro_Facturado__c , OTR_CAS_Orden_Trabajo_Liquidada__c, Case.CAS_CAS_Liquidado__c, Case.RecordTypeId
																	FROM WorkOrder 
																	WHERE (Case.CAS_CAS_Siniestro_Facturado__c = true AND OTR_CAS_Orden_Trabajo_Facturada__c = false)
																	OR (Case.CAS_CAS_Liquidado__c = true AND OTR_CAS_Orden_Trabajo_Liquidada__c = false)]);

			system.debug('>>>>>WOcasoFacLiq: ' + WOcasoFacLiq);
			for(WorkOrder wo:WOcasoFacLiq){
				system.debug('>>>>>wo.Id: ' + wo.Id);
				if(wo.Case.CAS_CAS_Siniestro_Facturado__c){
					wo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
				}
				if(wo.Case.CAS_CAS_Liquidado__c){
					wo.OTR_CAS_Orden_Trabajo_Liquidada__c = true;
				}
				woToUpdate.put(wo.Id,wo);
			}

			for(listaWO woId:listaWO){

				fac = new Factura__c();
				fac.FAC_LKP_WorkOrkder__c = woId.identificadorUnicoOrdenTrabajo;
				if(identificadorUnicoCuentaClie != '')
					fac.FAC_LKP_Cuenta__c = identificadorUnicoCuentaClie;
				if(identificadorUnicoCuentaProf != '')
					fac.FAC_LKP_Cuenta__c = identificadorUnicoCuentaProf;   
				if(identificadorUnicoEvento != '')
				fac.FAC_NUM_Ano_Pago__c = anioFactura; 
				fac.FAC_DIV_ImporteFactura__c = importePago;
				fac.FAC_NUM_MesPago__c = mesPago;
				fac.FAC_DIV_RetencionPago__c = retencionPago;
				fac.FAC_TXT_Numero_Factura__c = numeroFactura;
				fac.FAC_DAT_FechaFactura__c = fechaFactura;
				fac.FAC_TXT_Codigo_Capital__c = codigoCapital;
				fac.FAC_DIV_ImporteFranquicia__c = importeFranquicia;
				fac.FAC_NUM_ImporteFinal__c = importeFinal;
				fac.FAC_NUM_ImporteIVA__c = importeIva;
				fac.FAC_POR_PorcentajeIVA__c = porcentajeIva;
				fac.FAC_CAS_IndicadorPagoFranquicia__c = indicadorFranquicia;
				fac.FAC_TXT_Tipo_Registro__c = tipoRegistro;
				fac.FAC_NUM_IndicadorQuincena__c = indicadorQuincena;
				fac.FAC_NUM_TotalImportes__c = totalImporte;
				fac.FAC_CAS_Factura_de_Gestion__c = facturaGestion;
				listFac.add(fac);

				WorkOrder woFACT = mapaOTs.get(fac.FAC_LKP_WorkOrkder__c);
				system.debug('>>>>>woFACT: ' + woFACT);
				system.debug('>>>>>cuentaClient.RecordTypeId: ' + cuentaClient.RecordTypeId);
				system.debug('>>>>>cuentaClient: ' + cuentaClient.Id);


				/*Cuando se recibe una factura de una Orden de Trabajo dirigida a una cuenta con RecordType Cliente B2B Secundario, Cliente Asegurado o Cliente
				Particular, con el campo Factura de Gestión sin marcar (FAC_CAS_Factura_de_Gestion__c = false), se registra el Servicio como Facturado*/
				if((cuentaClient.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2) ||
				cuentaClient.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_ASEGURADO) ||
				cuentaClient.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR)) && !facturaGestion){
					woFACT.OTR_CAS_Orden_Trabajo_Facturada__c = true;
					woToUpdate.put(woFACT.Id,woFACT);
				}

				/*Cuando se recibe una factura de una Orden de Trabajo dirigida a un profesional, se registra el Servicio como Liquidado */
				if(identificadorUnicoCuentaProf != null && identificadorUnicoCuentaProf != ''){
					woFACT.OTR_CAS_Orden_Trabajo_Liquidada__c = true;
					woToUpdate.put(woFACT.Id,woFACT);
				}
			}           

			system.debug('>>>>>facturaInsertada preUpsert: '+listFac);
			upsert listFac;
			system.debug('>>>>>facturaInsertada postUpsert: '+listFac);
			List<String> idFact = new List<String>();
			for(Factura__c aux:listFac){
				idFact.add(aux.id);
			}

			respuesta.listaFacturas = idFact;

			//Actualizo casos y WO
			update casosToUpdate;
			system.debug('>>>>>casosToUpdate: ' + casosToUpdate);
			//update woToUpdate;
			system.debug('>>>>>woToUpdate: ' + woToUpdate);
			system.debug('>>>>>woToUpdate.size(): ' + woToUpdate.size());

			system.debug('@@@Contiene nulos: ' + woToUpdate.containsKey(null));
			for (Id key : woToUpdate.keySet()) {
				system.debug('>>>>>verWO: ' + woToUpdate.get(key).Id);
			}

			if(!facturaGestion)
				update woToUpdate.values();
				system.debug('>>>>>woToUpdate: ' + woToUpdate);

			//Genero movimientos
			system.debug('response: '+response);
			for(Case c : casosToUpdate){
				if(Util_Siniestro.esSiniestro(c)){
					Util_Movimientos.compruebaEnviable(c.Id,c.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'99');
					Util_Movimientos.compruebaEnviable(c.Id,c.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'98');
				}
			}

			system.debug('>>>>>verMapaWoToUpdate: ' + woToUpdate);

			for(Id key : woToUpdate.keySet()){
				WorkOrder woUtilMov = woToUpdate.get(key);
				system.debug('>>>>>woUtilMovId: ' + woUtilMov);
				system.debug('>>>>>woUtilMov.CaseId: ' + woUtilMov.CaseId);
				system.debug('>>>>>woUtilMov.Case.RecordTypeId: ' + woUtilMov.Case.RecordTypeId);
				Case caso = new Case(RecordTypeId = woUtilMov.Case.RecordTypeId);
				if(Util_Siniestro.esSiniestro(caso)){
					Util_Movimientos.compruebaEnviable(woUtilMov.CaseId,woUtilMov.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'99',woUtilMov.Id);
					Util_Movimientos.compruebaEnviable(woUtilMov.CaseId,woUtilMov.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'98',woUtilMov.Id);
				}
			}

			//respuesta.listaFacturas = idFact;
			respuesta.success = 'true';
			respuesta.errors = '';
			respuesta.listaFacturas = idFact;   
			response += '{"code":"FAC-001", "message":"Operación ejecutada correctamente","listaFacturas":[';
			contParametros = 0;
			for(String aux:idFact){
				if(contParametros != 0){response += '}';}
				concatenarParametroJSON('id',aux);
			}
			response += '}]}';
			system.debug(respuesta);
			system.debug('Factura Insertada: '+idFact); 
			system.debug('response: '+response);

		if (!test.isRunningTest()) {
			RestContext.response.addHeader('Content-Type', 'application/json');
			RestContext.response.responseBody = Blob.valueOf(response);
		}
	}

	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {response += ',';}
			response += '{"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}else{
			if (contParametros > 0) {response += ',';}
			response += '{"' + nombreParametro + '" : ""';
			contParametros++;        	
		}
	}


	/*Cuando se recibe una factura de una Abono dirigida a una cuenta con RecordType Cliente B2B Secundario, Cliente Asegurado o Cliente Particular, 
	se registra el Abono como Liquidado (AB_CAS_Abono_Liquidado__c= true).*/
	public static WorkOrder liquidarServicioAbono(Propuesta_de_Abono__c abono){
		List<Propuesta_de_Abono__c> listaAbonos = new List<Propuesta_de_Abono__c>();
		listaAbonos = ([SELECT Id, AB_CAS_Abono_Liquidado__c FROM Propuesta_de_Abono__c WHERE AB_LKP_Orden_de_Trabajo__c =: abono.AB_LKP_Orden_de_Trabajo__c]);
		system.debug('>>>>>verListaAbonos: ' + listaAbonos);
		WorkOrder woAbono = new WorkOrder();
		woAbono = ([SELECT Id, CaseId, Case.RecordTypeId FROM WorkOrder WHERE Id =: abono.AB_LKP_Orden_de_Trabajo__c]);
		system.debug('>>>>>verWoAbono: ' + woAbono);
		if(woAbono.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
			woAbono.OTR_CAS_Orden_Trabajo_Liquidada__c = true;
			for(Propuesta_de_Abono__c ab:listaAbonos){
				if(!ab.AB_CAS_Abono_Liquidado__c){
					woAbono.OTR_CAS_Orden_Trabajo_Liquidada__c = false;
				}
			}
		}
		system.debug('>>>>>verWoAbonoBeforeUpdate: ' + woAbono);
		//Devolvemos la WO para añadirla al mapa para su posterior actualización;
		return woAbono;
	}


	/*Cuando un Servicio que pertenece a una reclamación, tenga todos sus Eventos facturados a excepción del E111, se registrará el Servicio como
	facturado (OTR_CAS_Orden_Trabajo_Facturada__c = true)*/
	public static WorkOrder facturarServicioEvento(Propuesta_de_Evento__c evento){
		WorkOrder woEvento = new WorkOrder();

		List<Propuesta_de_Evento__c> listaEventos = new List<Propuesta_de_Evento__c>();
		listaEventos = ([SELECT Id,
								EV_AB_CAS_Evento_Ab_Facturado__c,
								EV_AB_DAT_Fecha_Facturacion__c,
								EV_AB_LKP_Orden_de_Trabajo__c,
								EV_AB_SEL_Descripcion__c,
								EV_AB_SEL_Tipo_de_Evento__c
								FROM Propuesta_de_Evento__c WHERE EV_AB_LKP_Orden_de_Trabajo__c =: evento.EV_AB_LKP_Orden_de_Trabajo__c]);

		system.debug('>>>>>verListaEventos: ' + listaEventos);
		woEvento = ([SELECT Id, CaseId, Case.RecordTypeId FROM WorkOrder WHERE Id =: evento.EV_AB_LKP_Orden_de_Trabajo__c]);
		system.debug('>>>>>verWoEventoFacturar: ' + woEvento);
		if(woEvento.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
			woEvento.OTR_CAS_Orden_Trabajo_Facturada__c = true;
			for(Propuesta_de_Evento__c ev:listaEventos){
				system.debug('>>>>>DentroFor');
				system.debug('>>>>>verEvento: ' + ev);
				if(!ev.EV_AB_CAS_Evento_Ab_Facturado__c && ev.EV_AB_SEL_Descripcion__c  != Label.AB_DESCRIPCION_IMP_GESTOR && ev.EV_AB_SEL_Tipo_de_Evento__c == Label.TIPO_EVENTO_COBRO){
					system.debug('>>>>>DentroIF');
					woEvento.OTR_CAS_Orden_Trabajo_Facturada__c = false;
				}
			}
		}

		system.debug('>>>>>verWOEvento: ' + woEvento);
		return woEvento;
	}


	/*Cuando un Servicio que pertenece a una reclamación, tenga todos sus Eventos liquidados a excepción del E111, se registrará el Servicio como
	liquidado (OTR_CAS_Orden_Trabajo_Liquidada__c= true)*/
	public static WorkOrder liquidarServicioEvento(Propuesta_de_Evento__c evento){
		WorkOrder woEvento = new WorkOrder();
		
		List<Propuesta_de_Evento__c> listaEventos = new List<Propuesta_de_Evento__c>();
		listaEventos = ([SELECT Id,
								EV_AB_CAS_Evento_Ab_Liquidado__c,
								EV_AB_DAT_Fecha_Liquidacion__c,
								EV_AB_LKP_Orden_de_Trabajo__c,
								EV_AB_SEL_Descripcion__c,
								EV_AB_SEL_Tipo_de_Evento__c
								FROM Propuesta_de_Evento__c WHERE EV_AB_LKP_Orden_de_Trabajo__c =: evento.EV_AB_LKP_Orden_de_Trabajo__c]);

		system.debug('>>>>>verListaEventos: ' + listaEventos);
		woEvento = ([SELECT Id, CaseId, Case.RecordTypeId FROM WorkOrder WHERE Id =: evento.EV_AB_LKP_Orden_de_Trabajo__c]);
		system.debug('>>>>>verWoEventoLiquidar: ' + woEvento);
		if(woEvento.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
			system.debug('>>>>>EsReclamacion');
			woEvento.OTR_CAS_Orden_Trabajo_Liquidada__c = true;
			for(Propuesta_de_Evento__c ev:listaEventos){
				system.debug('>>>>>evento: ' + ev);
				if(!ev.EV_AB_CAS_Evento_Ab_Liquidado__c && ev.EV_AB_SEL_Descripcion__c != Label.AB_DESCRIPCION_IMP_GESTOR && ev.EV_AB_SEL_Tipo_de_Evento__c == Label.TIPO_EVENTO_PAGO){
					system.debug('>>>>>DentroIf');
					woEvento.OTR_CAS_Orden_Trabajo_Liquidada__c = false;
				}
			}
		}
		system.debug('>>>>>Label.AB_DESCRIPCION_IMP_GESTOR: ' + Label.AB_DESCRIPCION_IMP_GESTOR);
		system.debug('>>>>>woEvento: ' + woEvento);
		system.debug('>>>>>listaEventos: ' + listaEventos);
		return woEvento;
	}

}