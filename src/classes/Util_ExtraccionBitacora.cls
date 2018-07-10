/**
 * Todo: Clase que se utilizará para la creación de un CSV para su posterior inserción masiva de objetos de tipo INT_Bitacora__c;
 * @author everis
 * @version 1.0
 */
 //PENDIENTE: Falta por completar: insertar WO en bitácora
public with sharing class Util_ExtraccionBitacora {


	@future
	public static void extraccionProfesionales(){
		List<INT_Bitacora__c> listaBitacora = new List<INT_Bitacora__c>();
		INT_Bitacora__c bitacora = new INT_Bitacora__c();

		//List<WorkOrder> listaSRWO = Util_Orden_Trabajo.getWorkOrderByInStatus(new Set<String>{:Label.OTR_ESTADO_CERRADO,:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO,:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN,:Label.OTR_ESTADO_REVISADO}).values();
		String otrRev = '' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
		List<WorkOrder> listaSRWO = new List<WorkOrder>([SELECT OTR_LKP_Recurso_Servicio__c FROM WorkOrder WHERE ((Status=:Label.OTR_ESTADO_CERRADO OR Status=:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO OR
															Status=:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN OR Status=:Label.OTR_ESTADO_REVISADO) AND (RecordTypeId != :otrRev))]);

		List<String> listaIds = new List<String>();

		for(WorkOrder listaSR : listaSRWO){
			if(listaSR.OTR_LKP_Recurso_Servicio__c != null){
				listaIds.add('' + listaSR.OTR_LKP_Recurso_Servicio__c);
				system.debug('>>>>>verListaIds: ' + listaIds);
			}
		}

		//List<ServiceResource> listaSR = Util_Service_Resource.queryMapSRByRsIds(new Set<Id>((List<Id>)listaIds)).values();
		List<ServiceResource> listaSR = new List<ServiceResource>([SELECT RSE_LKP_Cuenta__c FROM ServiceResource WHERE Id IN :listaIds]);
		List<String> listaIdcuentaProf = new List<String>();

		for(ServiceResource lista : listaSR){
			listaIdcuentaProf.add('' + lista.RSE_LKP_Cuenta__c);
		}
		/*List<Account> listaCuentaProf = Util_Cuentas.getMapCuentasById(new Set<Id>((List<Id>)listaId)).values();*/
		List<Account> listaCuentaProf = new List <Account>([SELECT Name, Id, CUE_TXT_Identificador__c, CUE_TXT_Tipologia_Rappel__c, CUE_SEL_Tipo_Documento__c, CUE_TXT_Numero_Documento__c, ShippingStreet,
																	ShippingPostalCode, ShippingState, CUE_SEL_Pais__c, CUE_DIV_Importe_fianza_Maxima__c, CUE_TXT_Condicion_Pago__c,
																	CUE_TXT_Codigo_Retencion_Fiscal__c, CUE_CAS_Profesional_Fianza__c, CUE_POR_Porcentaje_Fianza__c, CUE_DIV_Importe_Total_Fianza__c,
																	CUE_DIV_Importe_Fianza_Devuelta__c, CUE_DAT_Fecha_Baja__c, CUE_DIV_Importe_Franquicia__c, CUE_NUM_Vencimientos_Franquicia__c,
																	CUE_TXT_Metodo_Pago__c, CUE_TXT_Cbanc_Codigo_Entidad__c, CUE_TXT_Cbanc_Sucursal_Oficina__c, CUE_TXT_Cbanc_Digito_Control__c,
																	CUE_TXT_Cbanc_Numero__c, CUE_FOR_IBAN__c, CUE_TXT_Cbanc_Pais__c, CUE_CAS_Profesional_Rappel__c, CUE_CAS_Embargado__c, CUE_CAS_Vetado__c, Type,
																	CUE_LKP_CuentaPrincipalProf__r.Name, CUE_DAT_Profesional_Franquicia__c FROM Account WHERE Id IN :listaIdcuentaProf]);
		system.debug('>>>>>verListaCuentaProf: ' + listaCuentaProf);
		system.debug('>>>>>tamañoListaCuentaProf: ' + listaCuentaProf.size());
		List<String> ListaIdBitacora = new List<String>();

		for(Account profesional : listaCuentaProf){
			Callout_Fac_MaestroProfesionales_RQ datosProfesional = new Callout_Fac_MaestroProfesionales_RQ();
			if(profesional!=null){
				datosProfesional.tipoDocumento = profesional.CUE_SEL_Tipo_Documento__c;
				datosProfesional.tomadorNumeroDocumentoCliente = profesional.CUE_TXT_Numero_Documento__c;
				datosProfesional.direccionDelProfesional = profesional.ShippingStreet;
				datosProfesional.codigoPostalProfesional = profesional.ShippingPostalCode;
				datosProfesional.ciudadProfesional = profesional.ShippingState;
				datosProfesional.paisProfesional = profesional.CUE_SEL_Pais__c;
				datosProfesional.importeFianzaMaxima = profesional.CUE_DIV_Importe_fianza_Maxima__c;
				datosProfesional.condicionPago = profesional.CUE_TXT_Condicion_Pago__c;
				datosProfesional.codigoRetencionFiscal = profesional.CUE_TXT_Codigo_Retencion_Fiscal__c;
				datosProfesional.profesionaFianza = profesional.CUE_CAS_Profesional_Fianza__c;
				datosProfesional.porcentajeFianza = profesional.CUE_POR_Porcentaje_Fianza__c;
				datosProfesional.importeTotalFianza = profesional.CUE_DIV_Importe_Total_Fianza__c;
				datosProfesional.importeFianzadevuelta = profesional.CUE_DIV_Importe_Fianza_Devuelta__c;
				datosProfesional.fechaBajaDefinitiva = profesional.CUE_DAT_Fecha_Baja__c;
				datosProfesional.importeFranquicia = profesional.CUE_DIV_Importe_Franquicia__c;
				if(profesional.CUE_DIV_Importe_Franquicia__c != null && profesional.CUE_DIV_Importe_Franquicia__c != 0){
					datosProfesional.profesionalFranquicia = true;
				} else {
					datosProfesional.profesionalFranquicia = false;
				}
				datosProfesional.vencimientosFranquicia = profesional.CUE_NUM_Vencimientos_Franquicia__c;
				if(profesional.CUE_DAT_Profesional_Franquicia__c != null){
					datosProfesional.fechaFranquicia = ''+profesional.CUE_DAT_Profesional_Franquicia__c;
				}
				datosProfesional.tipoProfesional = profesional.Type;
				datosProfesional.metodoPago = profesional.CUE_TXT_Metodo_Pago__c;
				datosProfesional.codigoEntidadBanco = profesional.CUE_TXT_Cbanc_Codigo_Entidad__c;
				datosProfesional.codigoSucursal = profesional.CUE_TXT_Cbanc_Sucursal_Oficina__c;
				datosProfesional.profesionalRappel = profesional.CUE_CAS_Profesional_Rappel__c;
				datosProfesional.tipologiaRappel = profesional.CUE_TXT_Tipologia_Rappel__c;
				datosProfesional.digitosControl = profesional.CUE_TXT_Cbanc_Digito_Control__c;
				datosProfesional.numeroCuenta = profesional.CUE_TXT_Cbanc_Numero__c;
				datosProfesional.numeroIban = profesional.CUE_FOR_IBAN__c;
				datosProfesional.paisCuentaBancaria	= profesional.CUE_TXT_Cbanc_Pais__c;
				datosProfesional.embargado = profesional.CUE_CAS_Embargado__c;
				datosProfesional.vetado = profesional.CUE_CAS_Vetado__c;
				datosProfesional.numeroProfesional = profesional.CUE_TXT_Identificador__c ;
				datosProfesional.nombreProfesional = profesional.CUE_LKP_CuentaPrincipalProf__r.Name;
				
				if(''+profesional.Id !=null && ''+profesional.Id !=''){
					datosProfesional.identificadorUnicoProfesional = (''+profesional.Id).subString(0,15);
				}

			}
			datosProfesional.accionRealizada = 'Alta';		
			datosProfesional.profesionalPerito = False;

			String body = Callout_Fac_MaestroProfesionales.construirBody(datosProfesional);
			//WS_Info__mdt ws_CASV = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Profesional}).values().get(0);
			WS_Info__mdt ws_CASV = [SELECT EndPoint__c FROM WS_Info__mdt WHERE MasterLabel =: Label.FAC_Callout_Profesional][0];

			bitacora = crearBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_PROFESIONALES_NOMBRE ,body, ws_CASV.EndPoint__c,
					'','','','','','',0,'',0,Label.Callout_PUT);

			listaBitacora.add(bitacora);

		}

		if(listaBitacora != null && !listaBitacora.isEmpty())
			enviarCSV(listaBitacora, 'MaestroProfesionales');

	}


	/* 
	 *		Método creado para la extracción de los clientes;
	 * 		Se puede ejecutar desde forma anónima introduciendo: Util_ExtraccionBitacora.extraccionClientes();
	 */
	public static void extraccionClientes(){
		//Obtener todos los clientes:

		List<Account> listaCuenta = new List<Account>();
		List<Contact> listaContactos = new List<Contact>();
		List<Case> listaCasos = new List<Case>();
		Map<Id, String> mapaCuentas = new Map<Id, String>();
		Map<Id, Contact> mapaContactos = new Map<Id, Contact>();
		Map<Id, String> mapaCasos = new Map<Id, String>();
		Account cuenta;
		Contact contacto;
		Case caso;
		String jsonCaso;
		String jsonAcc;

		//List<WorkOrder> listaWO = Util_Orden_trabajo.getWorkOrderByInStatus(new Set<String>{:Label.OTR_ESTADO_CERRADO,:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO,:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN,:Label.OTR_ESTADO_REVISADO}).values();
		String otrRev = '' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
		List<WorkOrder> listaWO = new List<WorkOrder>([SELECT CaseId, RecordTypeId FROM WorkOrder WHERE ((Status=:Label.OTR_ESTADO_CERRADO OR Status=:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO OR
														Status=:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN OR Status=:Label.OTR_ESTADO_REVISADO) AND (RecordTypeId != :otrRev))]);
		Set<Id> IdCasos = new Set<Id>();
		system.debug('>>>>>sizeListaWO: '+listaWO.size());

		for(WorkOrder wo:listaWO){
			if(wo.CaseId!=null && !IdCasos.contains(wo.CaseId) && (wo.RecordTypeId != Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)))
				IdCasos.add(wo.CaseId);
		}
		system.debug('>>>>>PC1');
		listaCasos = [SELECT Account.Name, Account.ShippingCity,Account.CUE_FOR_RTDevName__c,Account.ShippingPostalCode,Account.ShippingState,Account.ShippingStreet,
				Account.CUE_SEL_Tipo_Documento__c, Account.CUE_TXT_Identificador__c,Account.Type , Account.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
				Account.Phone,Account.CUE_TXT_Condicion_Pago__c, Account.CUE_TXT_Metodo_Pago__c, Account.CUE_TXT_Cbanc_Codigo_Entidad__c,Account.CUE_TXT_Cbanc_Sucursal_Oficina__c, Account.CUE_TXT_Cbanc_Digito_Control__c, 
				Account.RecordType.Name,Account.CUE_TXT_Cbanc_Numero__c,Account.CUE_FOR_IBAN__c, Account.CUE_TXT_Cbanc_Pais__c,
				AccountId, Id, CAS_LKP_PolizaContrato__c,CAS_LKP_Cliente_contable__r.ShippingCity,CAS_LKP_Cliente_contable__r.ShippingPostalCode,
				CAS_LKP_Cliente_contable__r.ShippingState,CAS_LKP_Cliente_contable__r.ShippingStreet, CAS_LKP_Cliente_contable__c,RecordTypeId,RecordType.Name,CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c,
				CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c, CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
				CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c, CAS_LKP_Cliente_contable__r.Phone,CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c,CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c,
				CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c, CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c,CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c, CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c,
				CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c,CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c, CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c, CAS_LKP_Cliente_contable__r.Name,CAS_LKP_Cliente_contable__r.ShippingCountry,
				CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c, CAS_LKP_Cliente_contable_cliente__r.Name, CAS_LKP_Cliente_contable_cliente__r.CUE_FOR_RTDevName__c, CAS_LKP_Cliente_contable_cliente__r.Type, CAS_LKP_Cliente_contable_cliente__r.Id, 
				CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Tipo_Documento__c, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Numero_Documento__c, CAS_LKP_Cliente_contable_cliente__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
				CAS_LKP_Cliente_contable_cliente__r.Phone, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Condicion_Pago__c, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Metodo_Pago__c, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Codigo_Entidad__c,
				CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Sucursal_Oficina__c, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Digito_Control__c, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Numero__c,
				CAS_LKP_Cliente_contable_cliente__r.CUE_FOR_IBAN__c, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Pais__c, CAS_LKP_Cliente_contable_cliente__r.ShippingStreet, CAS_LKP_Cliente_contable_cliente__r.ShippingPostalCode,
				CAS_LKP_Cliente_contable_cliente__r.ShippingState, CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Pais__c, CAS_LKP_Cliente_contable_cliente__r.ShippingCity, CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c,
				CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c, CAS_LKP_Cliente_contable__r.Type FROM Case WHERE Id IN :IdCasos];

		system.debug('>>>>>tamañoListaCasos: ' + listaCasos.size());
		system.debug('>>>>>PC2');
		if(!listaCasos.isEmpty() && listaCasos != null){
			for(Case cs : listaCasos){
				jsonCaso = JSON.serialize(cs);
				mapaCasos.put(cs.Id, jsonCaso);//mapaCasos.put(cs.Id, cs);
			}
		}
		system.debug('>>>>>PC3');
		List<Id> AccsId = new List<Id>();
		for(Case casos:listaCasos){
			AccsId.add(casos.AccountId);
		}
		//listaCuenta = Util_Cuentas.getMapCuentasById(new Set<Id>((List<Id>)AccsId)).values();
		listaCuenta = [SELECT Id FROM Account WHERE Id IN :AccsId];

		//RELLENAMOS UN MAPA CON LAS CUENTAS DE LA LISTA
		if(!listaCuenta.isEmpty() && listaCuenta != null){
			for(Account cuentas : listaCuenta){
				jsonAcc = JSON.serialize(cuentas);
				mapaCuentas.put(cuentas.Id, jsonAcc);
			}
		}

		system.debug('>>>>>PC4');
		//listaContactos = Util_Contacto.getContactByAccountId((new Map<Id,Account>(listaCuenta)).keySet()).values();
		listaContactos = [SELECT Id, Email, MailingAddress, Name, Phone, AccountId FROM Contact WHERE AccountId IN :listaCuenta];

		//RELLENAMOS UN MAPA CON LOS CONTACTOS DE LA LISTA
		if(!listaContactos.isEmpty() && listaContactos != null){
			for(Contact ctc : listaContactos){
				mapaContactos.put(ctc.Id, ctc);
			}
		}
		system.debug('>>>>>PC5');

		List<String> listaJSON = new List<String>();
		WorkOrder wor = new WorkOrder();
		Integer i = 0;
		Integer j = 0;

		for(WorkOrder w:listaWO){
			i++;
			j++;
			String js = JSON.serialize(w);
			listaJson.add(js);

			if(j == 500){
				//j = 1;
				construirBodyClientes(listaJSON, mapaCasos, mapaCuentas);
				system.debug('>>>>>pasaPorAqui');
				listaJson.clear();
				//j = 500;// Para que sólo se ejecute una vez, para probar cómo responde el future
			}

			if(listaWO.size() >= i && j != 500){
				construirBodyClientes(listaJSON, mapaCasos, mapaCuentas);
			}
		}
	}

	@future
	public static void construirBodyClientes(List<String> listaJSON, Map<Id, String> mapaCasos, Map<Id, String> mapaCuentas){
		List<WorkOrder> listaWO = new List<WorkOrder>();
		Account cuenta = new Account();
		Contact contacto = new Contact();
		Case caso = new Case();
		WorkOrder wor = new WorkOrder();
		WS_Info__mdt ws_CASV = [SELECT EndPoint__c FROM WS_Info__mdt WHERE MasterLabel =: Label.FAC_Callout_Cliente][0];

		List<INT_Bitacora__c> listaBitacora = new List<INT_Bitacora__c>();
		INT_Bitacora__c bitacora = new INT_Bitacora__c();

		//Deserializamos para obtener la lista de WO;
		for(String js:listaJSON){
			//WorkOrder wor = new WorkOrder();
			wor = (WorkOrder)JSON.deserializeStrict(js, WorkOrder.class);
			listaWO.add(wor);
		}
		system.debug('>>>>>tamañoListaWO: ' + listaWO.size());
		Integer contador = 0;
		for(WorkOrder wo:listaWO){
			contador = contador + 1;
			system.debug('>>>>>verContador: ' + contador);
			caso = (Case)JSON.deserializeStrict(mapaCasos.get(wo.CaseId), Case.class);
			if(caso != null && wo.CaseId == caso.Id){
				Callout_Fac_MaestroClientes_RQ cliente = new Callout_Fac_MaestroClientes_RQ();
				cuenta = (Account)JSON.deserializeStrict(mapaCuentas.get(caso.AccountId), Account.class);
				if(cuenta != null && caso.AccountId == cuenta.Id){
					/*contacto = mapaContactos.get(contacto.AccountId);                                       //Null:REVISAR
					if(contacto != null && cuenta.Id == contacto.AccountId){
						cliente.nombreContacto = contacto.Name;
						cliente.mailContacto = contacto.Email;
					}//FIN Contacto*/
				}//FIN Cuenta
				system.debug('>>>>>caseId: ' + caso.Id);
				system.debug('>>>>>RTcaso: ' + caso.RecordType.Name);
				cliente.numeroPoliza ='_'+caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
				cliente.nombreDelClienteProcedencia = caso.CAS_LKP_Cliente_contable_cliente__r.Name;
				if(caso.CAS_LKP_Cliente_contable_cliente__r.Id != null)
					cliente.identificadorUnicoCliente = (''+caso.CAS_LKP_Cliente_contable_cliente__r.Id).subString(0,15);
				cliente.tipoDocumento = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Tipo_Documento__c;
				cliente.tomadorNumeroDocumentoCliente = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Numero_Documento__c;
				cliente.numeroClienteRelacionado = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c;
				cliente.telefonoCuenta = caso.CAS_LKP_Cliente_contable_cliente__r.Phone;
				cliente.condicionPago = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Condicion_Pago__c;
				cliente.metodoPago = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Metodo_Pago__c;
				cliente.codigoEntidadBanco = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Codigo_Entidad__c;
				cliente.codigoSucursal = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Sucursal_Oficina__c;
				cliente.digitosControl = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Digito_Control__c;
				cliente.numeroCuenta = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Numero__c;
				cliente.numeroIBAN = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_FOR_IBAN__c;
				cliente.paisCuentaBancaria = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Pais__c;
				cliente.direccionRiesgoDomicilio = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingStreet;
				cliente.direccionRiesgoCp = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingPostalCode;
				cliente.direccionRiesgoProvincia = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingState;
				cliente.paisCliente = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Pais__c;
				cliente.direccionRiesgoPoblacion = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingCity;
				cliente.recordType = caso.recordType.Name;
				//Cuando el cliente es de tipo contable, el tipoCliente será Compañia
				cliente.tipoCliente = Label.FAC_TipoCliente_CIA;//REVISAR
				cliente.identificadorCompania = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
				cliente.idDireccion = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;

				String body = Callout_Fac_MaestroClientes.construirJsonClientes(cliente);

				bitacora = crearBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE ,body, ws_CASV.EndPoint__c,
												'','','','',wo.Id,'',0,'',0,Label.Callout_PUT);

				listaBitacora.add(bitacora);
				if(listaBitacora.size() > 500){
					system.debug('>>>>>verContador: ' + contador);
					system.debug('>>>>>verListaBitacora: ' + listaBitacora);
					system.debug('>>>>>verListaBitacoraSize: ' + listaBitacora.size());
					system.debug('>>>dentroIfDelete');
					//enviarCSV(listaBitacora, 'MaestroClientes');
					//listaBitacora.clear();
					//list.removeAll(listaBitacora);
				}

				if(caso.RecordType.Name != 'Asistencia'){
					system.debug('>>>>>RTcaso: ' + caso.RecordType.Name);
					contador = contador + 1;
					cliente.nombreDelClienteProcedencia = caso.Account.Name;

					/////////////////////////   REVISAR   /////////////////////////
					if(caso.CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2B_1 || caso.CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2C_1){
						cliente.tipoCliente = Label.FAC_TipoCliente_CIA;
					} else if(caso.CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2B_2){
						if(caso.CAS_LKP_Cliente_contable__r.Type == Label.CUE_TIPO_DIRECCION || caso.Account.Type == Label.CUE_TIPO_CLIENTEFINAL){
							cliente.tipoCliente = Label.FAC_TipoCliente_CLIENTE;
						} else if(caso.CAS_LKP_Cliente_contable_cliente__r.Type == Label.CUE_TIPO_CONTABLE){
							cliente.tipoCliente = Label.FAC_TipoCliente_CIA;
						}
					}
					///////////////////////////////////////////////////////////////

					if(caso.CAS_LKP_Cliente_contable__c  != null)
						cliente.identificadorUnicoCliente = (''+caso.CAS_LKP_Cliente_contable__r.Id).subString(0,15);
					cliente.tipoDocumento = caso.CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c;
					cliente.tomadorNumeroDocumentoCliente = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c;
					cliente.numeroClienteRelacionado = caso.CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c;
					cliente.telefonoCuenta = caso.CAS_LKP_Cliente_contable__r.Phone;
					cliente.condicionPago = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c;
					cliente.metodoPago = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c;
					cliente.codigoEntidadBanco = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c;
					cliente.codigoSucursal = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c;
					cliente.digitosControl = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c;
					cliente.numeroCuenta = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c;
					cliente.numeroIBAN = caso.CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c;
					cliente.paisCuentaBancaria = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c;
					cliente.direccionRiesgoDomicilio = caso.CAS_LKP_Cliente_contable__r.ShippingStreet;
					cliente.direccionRiesgoCp = caso.CAS_LKP_Cliente_contable__r.ShippingPostalCode;
					cliente.direccionRiesgoProvincia = caso.CAS_LKP_Cliente_contable__r.ShippingCity;
					cliente.paisCliente = caso.CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c;
					cliente.direccionRiesgoPoblacion = caso.CAS_LKP_Cliente_contable__r.ShippingState;
					if(caso.CAS_LKP_Cliente_contable__r!=null){
						cliente.identificadorCompania = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
						cliente.idDireccion = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
					}
					String body2 = Callout_Fac_MaestroClientes.construirJsonClientes(cliente);

					bitacora = crearBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE ,body2, ws_CASV.EndPoint__c,
												'','','','',wo.Id,'',0,'',0,Label.Callout_PUT);
					listaBitacora.add(bitacora);
				}
			}//FIN Caso
		}//FIN for WorkOrder

		if(listaBitacora != null && !listaBitacora.isEmpty())
			enviarCSV(listaBitacora, 'MaestroClientes');
	}


	/* 
	 *		Método creado para la extracción de las prefacturas;
	 * 		Se puede ejecutar desde forma anónima introduciendo: Util_ExtraccionBitacora.extraccionPrefacturas();
	 */
	public static void extraccionPrefacturas(){
		List<WorkOrderLineItem> listaParWO = new List<WorkOrderLineItem>();
		List<INT_Bitacora__c> listaBitacora = new List<INT_Bitacora__c>();
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		Map<Id, String> mapaWO = new Map<Id, String>();
		Map<Id, String> mapaCaso = new Map<Id,String>();
		List<String> listaJSONwoli = new List<String>();
		String JSONWO;
		String JSONCase;
		String woli;

		String Siniestro = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
		String B2B2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
		String Asistencia = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C);
		
		

		String otrRev = '' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
		listaParWO = [SELECT WorkOrderId, WorkOrder.CaseId, PAR_FOR_Cargar_Cliente_DI__c, PAR_SEL_Codigo_Impuesto_Venta__c, PAR_TXT_Detalle_Venta__c, PAR_NUM_Unidades__c, PAR_DIV_Precio_Unitario_Venta__c, PAR_SEL_Unidades_Medida__c,
				PAR_DIV_ListPrice__c, PAR_TXT_Detalle_WOLI__c, PAR_DIV_Cargar_Cliente_AI__c, PAR_DIV_Facturacion_Total_AI__c, PAR_NUM_Iva__c, PAR_NUM_Ipsi__c, PAR_NUM_Igic__c, PAR_POR_Descuento__c, PAR_TXT_Baremo_Codigo__c, PAR_NUM_Ancho__c,
				PAR_NUM_Altura__c, PAR_POR_Impuesto_Prof__c, PAR_POR_Porcentaje_Imp_Cia_Cliente__c, PAR_SEL_Danios_Del__c, PAR_CAS_Danos_Esteticos__c, PAR_TXT_Baremo_Desc__c, PAR_POR_Materiales__c, PAR_TXT_S_Ref__c, PAR_DIV_Cargar_Comp_AI__c,
				PAR_FOR_Cargar_Comp_DI__c FROM WorkOrderLineItem WHERE WorkOrderId IN (SELECT Id FROM WorkOrder WHERE ((Status=:Label.OTR_ESTADO_CERRADO OR Status=:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO OR
				Status=:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN OR Status=:Label.OTR_ESTADO_REVISADO) AND (RecordTypeId != :otrRev)) AND (Case.RecordTypeId =: Siniestro OR Case.RecordTypeId =: B2B2C OR Case.RecordTypeId =: Asistencia))];

		system.debug('>>>>>listaParWO.size(): ' + listaParWO.size());
		/*List<WorkOrder> listaWO = new List<WorkOrder>([SELECT Id,Street, City, State, AccountId,CaseId,ContactId,OTR_SEL_Gremio__c,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,OTR_FOR_Identificador_CIA__c,
														OTR_CAS_Vetado_Orden_Trabajo__c,WorkOrderNumber,Status,LastModifiedDate,Account.CUE_TXT_Establecimiento__c FROM WorkOrder WHERE
														((Status=:Label.OTR_ESTADO_CERRADO OR Status=:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO OR Status=:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN OR
														Status=:Label.OTR_ESTADO_REVISADO) AND (RecordTypeId != :otrRev))]);

		for(WorkOrder wo:listaWO){
			jsonWO = JSON.serialize(wo);
			mapaWO.put(wo.Id,jsonWO);
		}*/

		Integer i = 0;
		Integer j = 0;
		//Rellenar los Mapas dentro del for, para intentar disminuir el heap size; ACT: Ahora, dentro de cada future, rellenaremos el mapa con los Casos y Órdenes de Trabajo que apliquen
		for(WorkOrderLineItem w:listaParWO){
			system.debug('>>>>>primerContadorJ: ' + j);
			i++;
			j++;
			String js = JSON.serialize(w);
			listaJSONwoli.add(js);

			if(j == 600){
				system.debug('>>>>>segundoContadorJ: ' + j);
				construirBodyPrefac(listaJSONwoli/*, mapaWO/*, mapaCaso*/);	
				system.debug('>>>>>pasaPorAqui');
				listaJSONwoli.clear();
				j = 500000000;
			}

			if(listaParWO.size() == i && j < 600){
				system.debug('>>>>>listaParWO.size(): ' + listaParWO.size());
				system.debug('>>>>>tercerContadorJ: ' + j);
				construirBodyPrefac(listaJSONwoli/*, mapaWO/*, mapaCaso*/);
			}
		}
	}


	@future
	public static void construirBodyPrefac(List<String> listaJSONwoli/*, Map<Id,String> mapaWO/*, Map<Id,String> mapaCaso*/){
		List<WorkOrderLineItem> listaParWO = new List<WorkOrderLineItem>();
		List<INT_Bitacora__c> listaBitacora = new List<INT_Bitacora__c>();
		List<String> idWO = new List<String>();
		List<String> idCS = new List<String>();
		Map<Id, Case> mapaCaso = new Map<Id, Case>();
		WorkOrderLineItem woli = new WorkOrderLineItem();
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		WorkOrder WO = new WorkOrder();
		Case caso = new Case();
		String JSONCase;

		WS_Info__mdt ws_CASV = [SELECT EndPoint__c FROM WS_Info__mdt WHERE MasterLabel =: Label.FAC_Callout_Prefactura][0];

		system.debug('>>>>>ws_CASV: ' + ws_CASV);

		for(String js:listaJSONwoli){
			woli = (WorkOrderLineItem)JSON.deserializeStrict(js, WorkOrderLineItem.class);
			listaParWO.add(woli);
			idWO.add(woli.WorkOrderId);
		}
		
		system.debug('>>>>>listaParWO: ' + listaParWO);

		String otrRev = '' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
		List<WorkOrder> listaWO = new List<WorkOrder>([SELECT Id,Street, City, State, AccountId,CaseId,ContactId,OTR_SEL_Gremio__c,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c,OTR_FOR_Identificador_CIA__c,
														OTR_CAS_Vetado_Orden_Trabajo__c,WorkOrderNumber,Status,LastModifiedDate,Account.CUE_TXT_Establecimiento__c FROM WorkOrder WHERE
														((Status=:Label.OTR_ESTADO_CERRADO OR Status=:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO OR Status=:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN OR
														Status=:Label.OTR_ESTADO_REVISADO) AND (RecordTypeId != :otrRev) AND (Id IN :idWO))]);

		system.debug('>>>>>listaWO: '+ listaWO);

		Map<Id,WorkOrder> mapaWO = new Map<Id,WorkOrder>();

		for(WorkOrder wor:listaWO){
			mapaWO.put(wor.Id,wor);
			idCS.add(wor.CaseId);
		}

		//String otrRev = '' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
		List<Case> listaCasos = new List<Case>();
		listaCasos = [SELECT Owner.Name, CAS_DIV_Pago_de_Minuta__c, Id, CAS_TXT_Num_Caso_HS__c, CAS_DAT_Fecha_Ocurrencia__c,CAS_FOR_Producto__c, CAS_CAS_Siniestro_Grave__c, recordtype.DeveloperName, CAS_SEL_Direccion_Territorial__c, Type, CaseNumber,
			CAS_LKP_Procedencia__r.PROC_SEL_Canal__c, CAS_LKP_Procedencia__c, CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c, CAS_LKP_Cliente_contable__c, CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c, Status, CAS_SEL_Grupo_Causa__c,
			CAS_FOR_RTDevName__c, Account.Id, Account.CUE_TXT_Establecimiento__c, Account.CUE_TXT_Nombre__c, Account.CUE_TXT_PrimerApellido__c, Account.CUE_TXT_SegundoApellido__c, Account.CUE_TXT_Identificador__c,
			CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.POLV_TXT_Codigo_Cliente_ING__c, CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c, CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c, CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c,
			CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c, LastModifiedDate FROM Case WHERE (recordtype.DeveloperName='CAS_Servicio_B2C' OR recordtype.DeveloperName='CAS_Servicio_B2B_B2B2C' OR recordtype.DeveloperName='CAS_Siniestro') AND Id 
			IN (SELECT CaseId FROM WorkOrder WHERE ((Status=:Label.OTR_ESTADO_CERRADO OR Status=:Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO OR Status=:Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN OR Status=:Label.OTR_ESTADO_REVISADO) AND
			(RecordTypeId != :otrRev) AND (CaseId IN :idCS)))];

		system.debug('>>>>>listaCasos: '+ listaCasos);

		for(Case cs:listaCasos){
			//JSONCase = JSON.serialize(cs);
			//mapaCaso.put(cs.Id, JSONCase);
			mapaCaso.put(cs.Id, cs);
		}

		for(WorkOrderLineItem datosPartida:listaParWO){
			Callout_Fac_PreFactura_RQ prefactura = new Callout_Fac_PreFactura_RQ();
			Callout_Fac_PreFactura_RQ prefactura2 = new Callout_Fac_PreFactura_RQ();
			prefactura.identificadorCompania = 'HSAS';
			if(datosPartida!=null){
				prefactura.lineaOrdenTrabajo = datosPartida.Id;
				if(datosPartida.PAR_FOR_Cargar_Cliente_DI__c != null || datosPartida.PAR_FOR_Cargar_Comp_DI__c != null){
				}
				prefactura.codigoImpuestoVenta = datosPartida.PAR_SEL_Codigo_Impuesto_Venta__c; 
				prefactura.unidadesDeMedida = datosPartida.PAR_SEL_Unidades_Medida__c;	 
				prefactura.cantidadGastos = datosPartida.PAR_NUM_Unidades__c;
				prefactura.importeTotal = datosPartida.PAR_DIV_Facturacion_Total_AI__c;
				prefactura.impuestoIva = datosPartida.PAR_NUM_Iva__c;
				prefactura.impuestoIpsi = datosPartida.PAR_NUM_Ipsi__c;
				prefactura.impuestoIgic = datosPartida.PAR_NUM_Igic__c;
				prefactura.descuento = datosPartida.PAR_POR_Descuento__c;
				prefactura.codigoBaremo = datosPartida.PAR_TXT_Baremo_Codigo__c;
				prefactura.ancho = datosPartida.PAR_NUM_Ancho__c;
				prefactura.alto = datosPartida.PAR_NUM_Altura__c;
				prefactura.porcentajeProf = datosPartida.PAR_POR_Impuesto_Prof__c; 
				prefactura.porcentajeCli = datosPartida.PAR_POR_Porcentaje_Imp_Cia_Cliente__c;
				prefactura.daniosDel = datosPartida.PAR_SEL_Danios_Del__c;
				prefactura.unidadMedidaGastos = datosPartida.PAR_SEL_Unidades_Medida__c;
				prefactura.daniosEsteticos = datosPartida.PAR_CAS_Danos_Esteticos__c;
				prefactura.descripcionBaremo = datosPartida.PAR_TXT_Baremo_Desc__c; 
				prefactura.baremo = datosPartida.PAR_TXT_Baremo_Codigo__c; 
				prefactura.detalleVenta = datosPartida.PAR_TXT_Detalle_Venta__c; 
				prefactura.cantidadVenta = datosPartida.PAR_NUM_Unidades__c;
				prefactura.precioUnitarioVenta = datosPartida.PAR_DIV_Precio_Unitario_Venta__c; 
				prefactura.unidadMedidadGastos = 'EUR';	 
				prefactura.detalleLineaOrdenDeTrabajo = datosPartida.PAR_TXT_Detalle_WOLI__c;	 
				prefactura.porcentajeMateriales = datosPartida.PAR_POR_Materiales__c;	
				prefactura.sREF = datosPartida.PAR_TXT_S_Ref__c;
				prefactura.codigoImpuestoGasto = ''+datosPartida.PAR_SEL_Codigo_Impuesto_Venta__c;

				WO = mapaWO.get(datosPartida.WorkOrderId);//(WorkOrder)JSON.deserializeStrict(mapaWO.get(datosPartida.WorkOrderId), WorkOrder.class);

				if(WO.Id == datosPartida.WorkOrderId){
					prefactura.direccionRealizacionTrabajo = WO.Street;
					prefactura.localidadRealizacionTrabajo = WO.City;
					prefactura.provinciaRealizacionTrabajo = WO.State;

					if(WO.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c != null){
						prefactura.identificadorUnicoProfesional = (''+WO.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c).subString(0,15);
					}

					prefactura.gremio = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Gremio__c').get(WO.OTR_SEL_Gremio__c);
					prefactura.vetadoOrdenDeTrabajo = WO.OTR_CAS_Vetado_Orden_Trabajo__c;
					prefactura.numOrdenTrabajo = WO.WorkOrderNumber;

					//El facturador no recibe "Cerrado pendiente de albarán" ni "Albarán recibido", entiende "Cierre Tecnico"
					if(WO.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN || WO.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO){
						prefactura.estadoCierreOrdenTrabajo = 'Cierre Tecnico';
					} else{
						prefactura.estadoCierreOrdenTrabajo = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(WO.Status);
					}
					prefactura.fechaCierreOrdenTrabajo = String.valueOf(date.newinstance(WO.LastModifiedDate.year(), WO.LastModifiedDate.month(), WO.LastModifiedDate.day()));

					caso = null;
					caso = mapaCaso.get(WO.CaseId);
						if(caso != null && (caso.Id == WO.CaseId)){
						prefactura.lineaDeNegocio = caso.CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c;

						if(caso.CAS_LKP_Cliente_contable__c!=null){
							prefactura.numeroPoliza ='_'+caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
							prefactura.segmento = '00';
						}

						if(caso != null){
							prefactura.numCaso = caso.CaseNumber;
							prefactura.identificadorUnicoCaso = (''+caso.Id).subString(0,15);

							if(caso.CAS_LKP_Procedencia__c != null){
								if(caso.CAS_LKP_Procedencia__c != null){
									prefactura.unidadNegocio = caso.CAS_LKP_Procedencia__r.PROC_SEL_Canal__c ;
								}else{
									prefactura.unidadNegocio = 'N/A' ;
								}
							}
							if(caso.Status != null && caso.Status == Label.CAS_ESTADO_CERRADO){//El facturador recibe los estados "Abierto" o "Cerrado", cuando el estado no sea "Cerrado", lo consideraremos "Abierto"
								prefactura.estado = 'Cerrado';
							}else if(caso.Status != null && caso.Status != Label.CAS_ESTADO_CERRADO){
								prefactura.estado = 'Abierto';
							}
							prefactura.tipoCaso = Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'Type').get(caso.Type); //cuenta.Type;
							prefactura.monedaVenta = 'EUR'; 
							prefactura.actividad = 'N/A';
							if(caso.Type != null && caso.Type.length() == 1){
								prefactura.tipoIntervencion = '0' + caso.Type;
							}else{
								prefactura.tipoIntervencion = caso.Type;
							}
							if(caso.CAS_SEL_Grupo_Causa__c == null || caso.CAS_SEL_Grupo_Causa__c == ''){
								prefactura.grupoCausa = '00';
							}else{
								prefactura.grupoCausa = caso.CAS_SEL_Grupo_Causa__c;
							}
							prefactura.servicio = caso.recordtype.DeveloperName;
							prefactura.siniestrosGraves = caso.CAS_CAS_Siniestro_Grave__c;
							prefactura.facturaAbonar = '';
							prefactura.numeroReferenciaCliente = caso.CAS_LKP_PolizaContrato__r.POL_LKP_Version_Actual__r.POLV_TXT_Codigo_Cliente_ING__c;
							prefactura.numeroReferenciaActivo = caso.CAS_TXT_Num_Caso_HS__c;	
							if(prefactura.estado == 'Abierto'){
								prefactura.fechaCierreCaso = '';
							} else {
								prefactura.fechaCierreCaso = String.valueOf(date.newinstance(caso.LastModifiedDate.year(), caso.LastModifiedDate.month(), caso.LastModifiedDate.day()));
							}
							prefactura.numeroExpediente = caso.CAS_TXT_Num_Caso_HS__c;
							prefactura.fechaOcurrencia = caso.CAS_DAT_Fecha_Ocurrencia__c;
							prefactura.referencia = caso.CAS_TXT_Num_Caso_HS__c;
							prefactura.itemProducto = caso.CAS_FOR_Producto__c;
							prefactura.delegacion = caso.CAS_SEL_Direccion_Territorial__c;
							prefactura.direccionTerritorial = caso.CAS_SEL_Direccion_Territorial__c;
							prefactura.codigoGestorNombre = caso.Owner.Name;
							prefactura.pagoDeMinuta = caso.CAS_DIV_Pago_de_Minuta__c;

							if(caso.CAS_FOR_RTDevName__c != Label.RT_CAS_B2C){
								prefactura2 = prefactura;
								prefactura = construirBodyPrefactura(WO,Caso,true,'_01', prefactura, datosPartida);
								prefactura2 = construirBodyPrefactura(WO,Caso,false,'_02', prefactura, datosPartida);
								String body2 = Callout_Fac_PreFactura.construirBody(prefactura2); //Creamos aquí el body de prefactura2, para asegurarnos que no está vacío el objeto
								bitacora = crearBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_PREFACTURA_NOMBRE ,body2, ws_CASV.EndPoint__c,
													'','','','',wo.Id,'',0,'',0,Label.Callout_PUT);
								listaBitacora.add(bitacora);
							}else{
								prefactura = construirBodyPrefactura(WO,Caso,true,'', prefactura, datosPartida);
							}
						}

						String body = Callout_Fac_PreFactura.construirBody(prefactura);
						bitacora = crearBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_PREFACTURA_NOMBRE ,body, ws_CASV.EndPoint__c,
													'','','','',wo.Id,'',0,'',0,Label.Callout_PUT);
						listaBitacora.add(bitacora);
					}
				}
			}
		}

		if(listaBitacora != null && !listaBitacora.isEmpty())
			enviarCSV(listaBitacora, 'Prefactura');
	}


	/* 
	 *		Método creado para la creación de un objeto bitácora;
	 *		@param campos del objeto bitácora para la creación del objeto bitácora
	 *		@return Callout_Fac_PreFactura_RQ: objeto Callout_Fac_PreFactura_RQ relleno.
	 */
	public static Callout_Fac_PreFactura_RQ construirBodyPrefactura(WorkOrder wo, Case caso, Boolean asegurado, String diferenciadorWO, Callout_Fac_PreFactura_RQ prefactura, WorkOrderLineItem datosPartida){
		if(wo.Id != null)
			prefactura.identificadorUnicoOrdenTrabajo = (''+wo.Id).subString(0,15) +diferenciadorWO;

		if(asegurado){
			if(caso.Account.Id != null){
				prefactura.identificadorUnicoCuenta = (''+caso.Account.Id).subString(0,15);
			}
			prefactura.codigoUsuario = caso.id;
			prefactura.numeroEstablecimiento = caso.Account.CUE_TXT_Establecimiento__c;
			prefactura.direccionEstablecimiento	= '';
			prefactura.nombre = caso.Account.CUE_TXT_Nombre__c;
			prefactura.apellido1 = caso.Account.CUE_TXT_PrimerApellido__c;
			prefactura.apellido2 = caso.Account.CUE_TXT_SegundoApellido__c;
		}else if(caso.CAS_LKP_Cliente_contable__c != null && (''+caso.CAS_LKP_Cliente_contable__c).length()>=15){
			if(caso.CAS_LKP_Cliente_contable__c != null){
				prefactura.identificadorUnicoCuenta = (''+caso.CAS_LKP_Cliente_contable__c).subString(0,15);
			}
			prefactura.codigoUsuario = caso.id;
			prefactura.numeroEstablecimiento = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c;
			prefactura.direccionEstablecimiento	= '';
			prefactura.nombre = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c;
			prefactura.apellido1 = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c;
			prefactura.apellido2 = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c;					
		}

		if(asegurado){
			prefactura.importeBaseImponible = datosPartida.PAR_DIV_Cargar_Cliente_AI__c;//Si es la prefactura del asegurado/secundario, enviamos los datos del cliente/secundario
		}else{
			prefactura.importeBaseImponible = datosPartida.PAR_DIV_Cargar_Comp_AI__c;//Si es la prefactura de la compañía/principal, enviamos los datos de la compañía/Principal
		}

		if(asegurado){
				prefactura.idDireccion = caso.Account.CUE_TXT_Identificador__c;
			}else{
				prefactura.idDireccion = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
			}

		if(datosPartida.PAR_FOR_Cargar_Cliente_DI__c != null || datosPartida.PAR_FOR_Cargar_Comp_DI__c != null){
			if(asegurado){
				prefactura.importeVentaLineaOrdenTrabajo = datosPartida.PAR_DIV_Cargar_Cliente_AI__c; //Si es la prefactura del asegurado/secundario, enviamos los datos del cliente/secundario
				if(datosPartida.PAR_FOR_Cargar_Cliente_DI__c == 0){
					prefactura.precioUnitarioGastos = 0;
				}else {
					prefactura.precioUnitarioGastos = datosPartida.PAR_DIV_ListPrice__c;
				}
			}else{
				prefactura.importeVentaLineaOrdenTrabajo = datosPartida.PAR_DIV_Cargar_Comp_AI__c;//Si es la prefactura de la compañía/principal, enviamos los datos de la compañía/Principal
				prefactura.precioUnitarioGastos = datosPartida.PAR_DIV_ListPrice__c;
				if(datosPartida.PAR_FOR_Cargar_Comp_DI__c == 0){
					prefactura.precioUnitarioGastos = 0;
				}else {
					prefactura.precioUnitarioGastos = datosPartida.PAR_DIV_ListPrice__c;
				}
			}
		}

		return prefactura;
	}


	/* 
	 *		Método creado para la creación de un objeto bitácora;
	 *		@param campos del objeto bitácora para la creación del objeto bitácora
	 *		@return INT_Bitacora__c: objeto bitácora relleno.
	 */
	public static INT_Bitacora__c crearBitacora(String BIT_TXT_Sistema_externo, String BIT_TXT_Error,String BIT_SEL_Estado, String BIT_SEL_Tipo_Integracion,String BIT_TXT_Nombre_Integracion,
			String BIT_TXT_Json, String BIT_TXT_EndPoint, String BIT_LKP_Id_Registro_caso, String BIT_LKP_Id_Registro_contacto, String BIT_LKP_Id_Registro_cuenta, String BIT_LKP_Id_Registro_factura,
			String BIT_LKP_Id_Registro_orden, String BIT_TXT_Id_Secuencia_Indemnizables, Integer BIT_NUM_Orden_RGA,String idBitacora, Decimal BIT_NUM_Reintentos, String BIT_TXT_Method){

		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_TXT_Sistema_externo__c = BIT_TXT_Sistema_externo;
		bitacora.BIT_TXT_Error__c =BIT_TXT_Error;
		bitacora.BIT_SEL_Estado__c = BIT_SEL_Estado;
		bitacora.BIT_TXT_Nombre_Integracion__c = BIT_TXT_Nombre_Integracion;
		bitacora.BIT_SEL_Tipo_Integracion__c = BIT_SEL_Tipo_Integracion;
		bitacora.BIT_TXT_Json__c = BIT_TXT_Json;
		bitacora.BIT_TXT_Method__c = BIT_TXT_Method;
		bitacora.BIT_TXT_EndPoint__c = BIT_TXT_EndPoint;
		if(BIT_LKP_Id_Registro_caso != '')
			bitacora.BIT_LKP_Id_Registro_caso__c = BIT_LKP_Id_Registro_caso;
		if(BIT_LKP_Id_Registro_contacto != '' )	
			bitacora.BIT_LKP_Id_Registro_contacto__c = BIT_LKP_Id_Registro_contacto;	
		if(BIT_LKP_Id_Registro_cuenta != '')
			bitacora.BIT_LKP_Id_Registro_cuenta__c = BIT_LKP_Id_Registro_cuenta;
		if(BIT_LKP_Id_Registro_factura != '' )	
			bitacora.BIT_LKP_Id_Registro_factura__c = BIT_LKP_Id_Registro_factura;
		if(BIT_LKP_Id_Registro_orden != '' )
			bitacora.BIT_LKP_Id_Registro_orden__c = BIT_LKP_Id_Registro_orden;	
		bitacora.BIT_TXT_Id_Secuencia_Indemnizables__c = BIT_TXT_Id_Secuencia_Indemnizables;
		bitacora.BIT_NUM_Orden_RGA__c = BIT_NUM_Orden_RGA;
		bitacora.BIT_NUM_Reintentos__c = BIT_NUM_Reintentos;
		Id idRecordTypeWS = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_WEBSERVICE);

		return 	bitacora;
	}


	/* 
	 *		Método creado para la extracción de las prefacturas;
	 * 		Método probado, envía correo con archivo adjunto (.csv)
	 *		@param lista de objetos Int_Bitacora__c para la creación del archivo con extension csv
	 *		nombre del servicio para el cual se está realizando la extracción
	 */

		private static void enviarCSV(List<Int_Bitacora__c> listaBitacora, String nombreServicio){
		system.debug('>>>>>dentroEnviarCSV');
		String mailUsuario = UserInfo.getUserEmail();
		system.debug('>>>>>mailUsuario: ' + mailUsuario);

		string header = 'BIT_TXT_Sistema_externo__c,"BIT_TXT_Error__c","BIT_SEL_Estado__c","BIT_TXT_Nombre_Integracion__c","BIT_SEL_Tipo_Integracion__c","BIT_TXT_Json__c","BIT_TXT_Method__c","BIT_TXT_EndPoint__c",'+
			'"BIT_LKP_Id_Registro_caso__c","BIT_LKP_Id_Registro_contacto__c","BIT_LKP_Id_Registro_cuenta__c","BIT_LKP_Id_Registro_factura__c","BIT_LKP_Id_Registro_orden__c","BIT_TXT_Id_Secuencia_Indemnizables__c",'+
			'"BIT_NUM_Orden_RGA__c","BIT_NUM_Reintentos__c","recordTypeId"\n';
			
		string finalstr = header ;
		
		Id idRecordTypeWS = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_WEBSERVICE);
				
		for(Int_Bitacora__c bit: listaBitacora){
			bit.BIT_TXT_Json__c = bit.BIT_TXT_Json__c.replaceAll('\"','\""');
						
			string recordString = '\"'+bit.BIT_TXT_Sistema_externo__c+'\","'+bit.BIT_TXT_Error__c+'","'+bit.BIT_SEL_Estado__c+'","'+bit.BIT_TXT_Nombre_Integracion__c + '","'+bit.BIT_SEL_Tipo_Integracion__c + 
				'","'+bit.BIT_TXT_Json__c + '","'+bit.BIT_TXT_Method__c + '","'+bit.BIT_TXT_EndPoint__c + '","'+bit.BIT_LKP_Id_Registro_caso__c + '","'+bit.BIT_LKP_Id_Registro_contacto__c + '","'
				+bit.BIT_LKP_Id_Registro_cuenta__c + '","'+bit.BIT_LKP_Id_Registro_factura__c + '","'+bit.BIT_LKP_Id_Registro_orden__c + '","'+bit.BIT_TXT_Id_Secuencia_Indemnizables__c + '","'+bit.BIT_NUM_Orden_RGA__c +
				'","'+bit.BIT_NUM_Reintentos__c + '","'+idRecordTypeWS +'"\n';
				
				if (recordString.contains('null')){
					recordString = recordString.replaceAll('null','');
				}
				
			finalstr = finalstr +recordString;
		}

		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		blob csvBlob = Blob.valueOf(finalstr);
		string csvname= 'extraccion_bitacora_'+nombreServicio+'.csv';
		csvAttc.setFileName(csvname);
		csvAttc.setBody(csvBlob);
		Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
		String[] toAddresses = new list<string> {mailUsuario};
		String subject ='CSV Bitacora ' + nombreServicio;
		email.setSubject(subject);
		email.setToAddresses( toAddresses );
		email.setPlainTextBody('Tiene adjunto un csv del objeto bitácora ' + '(' + nombreServicio + ')');
		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		if(!Test.isRunningTest()){
			Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		}
		system.debug('>>>>>MensajeEnviado');
	}
}