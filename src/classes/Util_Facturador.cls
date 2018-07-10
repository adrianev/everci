public without sharing class Util_Facturador { 
	 

	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada al callout
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void construirBodyClientes(List<WorkOrder> listWO, String inId, String nombreIntegracion){
		system.debug('inIdClientes: ' + inId);
		List<Case> listaCaso = new List<Case>();
		List<ServiceContract> listaPolizas = new List<ServiceContract>();
		ServiceContract poliza;
		List<Account> listaCuentaPoliza = new List<Account>();
		Account cuentaPoliza;
		Account cuenta;
		List<Contact> listaContactos = new List<Contact>();
		Contact contacto;
		Case caso;
		List<Account> listaCuenta = new List<Account>();
		Account cuentaAbono = new Account();
		Callout_Fac_MaestroClientes_RQ datosCliente = new Callout_Fac_MaestroClientes_RQ();
		String idBitacora;
		
		if(!listWO.isEmpty()){
			if(listWO[0].CaseId != null){
			listaCaso = Util_Caso.getCaseFactById(new Set<Id>{listWO[0].CaseId}).values();
				if(!listaCaso.isEmpty()){
					caso = listaCaso.get(0);
				}	
			}
			listaContactos = Util_Contacto.getContactByCuenta(new Set<Id>{caso.CAS_LKP_Cliente_contable__c}).values();
			if(!listaContactos.isEmpty()){
				contacto = listaContactos.get(0);	
			}
			//QUERY PARA OBTENER EL CUE_TXT_IDENTIFICADOR DE LA CUENTA DE LA POLIZA DEL CLIENTE Y EL NUMERO DE POLIZA
			if(listaCaso != null){
				if(listaCaso.size()>0){
					listaPolizas = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{listaCaso[0].CAS_LKP_PolizaContrato__c}).values();
					if(!listaPolizas.isEmpty()){
						poliza = listaPolizas.get(0);
						listaCuentaPoliza = Util_Cuentas.getMapCuentasById(new Set<Id>{poliza.POL_LKP_compania__c}).values();
						cuentaPoliza = listaCuentaPoliza.get(0);
					}
				}
			}
			
			datosCliente.procedencia = caso.CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c;
			
			if(poliza != null && poliza.Name != ''){
				datosCliente.numeroPoliza= poliza.Name;
			}else{
				if(caso.CAS_LKP_Cliente_contable__c!=null && cuentaPoliza!=null){
					datosCliente.numeroPoliza = cuentaPoliza.CUE_TXT_Identificador__c+'_'+caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
				}else if(caso.CAS_LKP_Cliente_contable__c!=null){
					datosCliente.numeroPoliza ='_'+caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
				}		
			}
	
			if(contacto != null){
				datosCliente.nombreContacto = contacto.Name;
				datosCliente.mailContacto = contacto.Email;
			}
			if(caso.CAS_LKP_Cliente_contable__c!=null){
				datosCliente.nombreDelClienteProcedencia = caso.CAS_LKP_Cliente_contable_cliente__r.Name;
				if(caso.CAS_LKP_Cliente_contable_cliente__r.Id != null)
					datosCliente.identificadorUnicoCliente = (''+caso.CAS_LKP_Cliente_contable_cliente__r.Id).subString(0,15);
				datosCliente.tipoDocumento = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Tipo_Documento__c;
				datosCliente.tomadorNumeroDocumentoCliente = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Numero_Documento__c;
				datosCliente.numeroClienteRelacionado = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c;
				datosCliente.telefonoCuenta = caso.CAS_LKP_Cliente_contable_cliente__r.Phone;
				datosCliente.condicionPago = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Condicion_Pago__c;
				datosCliente.metodoPago = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Metodo_Pago__c;
				datosCliente.codigoEntidadBanco = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Codigo_Entidad__c;
				datosCliente.codigoSucursal = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Sucursal_Oficina__c;
				datosCliente.digitosControl = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Digito_Control__c;
				datosCliente.numeroCuenta = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Numero__c;
				datosCliente.numeroIBAN = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_FOR_IBAN__c;
				datosCliente.paisCuentaBancaria = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Cbanc_Pais__c;
				datosCliente.direccionRiesgoDomicilio = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingStreet;
				datosCliente.direccionRiesgoCp = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingPostalCode;
				datosCliente.direccionRiesgoProvincia = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingState;//caso.CAS_LKP_Cliente_contable__r.ShippingCity;
				datosCliente.paisCliente = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_SEL_Pais__c;
				datosCliente.direccionRiesgoPoblacion = caso.CAS_LKP_Cliente_contable_cliente__r.ShippingCity;//caso.CAS_LKP_Cliente_contable__r.ShippingState;
				datosCliente.recordType = caso.recordType.Name;
				//Cuando el cliente es de tipo contable, el tipoCliente será Compañia
				datosCliente.tipoCliente = Label.FAC_TipoCliente_CIA;
				if(cuentaPoliza!=null){system.debug(datosCliente+' una de las dos esta a nulo '+cuentaPoliza+' '+cuenta);
					datosCliente.identificadorCompania = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CUE_TXT_Identificador__c;
					datosCliente.idDireccion = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CUE_TXT_Identificador__c;
				}else{
					/*datosCliente.identificadorCompania = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
					datosCliente.idDireccion = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;*/
					//Realizamos el if de abajo para separar la concatenación entre número de cliente y procedencia.
					if(caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c != null && 
					caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c != '' && 
					caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c.contains('_')){
						List<String> conCat = new List<String>(caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c.split('\\_'));
						datosCliente.identificadorCompania = conCat.get(0);
						datosCliente.idDireccion = conCat.get(0);
					} else {
						datosCliente.identificadorCompania = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
						datosCliente.idDireccion = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
					}
					
					
				}
			}
			/*Se ejecuta una llamada para construir el JSON, y hacer la llamada del cliente contable asociado al caso. Si no es B2C se enviará también la informacion de la cuenta asociada al caso 
				ya que puede que la factura se pague a medias*/
			String body = Callout_Fac_MaestroClientes.construirJsonClientes(datosCliente);
			WS_Info__mdt ws_CASV = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Cliente}).values().get(0);
			idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE ,body, ws_CASV.EndPoint__c,
						'','','','',listWO[0].Id,'',0,'',0,Label.Callout_PUT);					
			Callout_Fac_MaestroClientes.updateDatos(body,nombreIntegracion,idBitacora,datosCliente.identificadorUnicoCliente,listWO[0].Id);	
			
			if(caso.RecordType.Name != 'Asistencia'){
				/*idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',nombreIntegracion,'','',
							'','','','',listWO[0].Id,'',0,'',0,Label.Callout_PUT);*/
				listaContactos = Util_Contacto.getContactByCuenta(new Set<Id>{caso.AccountId}).values();
				if(!listaContactos.isEmpty()){
					contacto = listaContactos.get(0);	
				}
				if(contacto != null){
					datosCliente.nombreContacto = contacto.Name;
					datosCliente.mailContacto = contacto.Email;
				}						
				datosCliente.nombreDelClienteProcedencia = caso.CAS_LKP_Cliente_contable__r.Name;

				if(caso.CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2B_1 || caso.CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2C_1){
					datosCliente.tipoCliente = Label.FAC_TipoCliente_CIA;
				} else if(caso.CAS_LKP_Cliente_contable__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2B_2){
					if(caso.CAS_LKP_Cliente_contable__r.Type == Label.CUE_TIPO_DIRECCION || caso.CAS_LKP_Cliente_contable__r.Type == Label.CUE_TIPO_CLIENTEFINAL){
						datosCliente.tipoCliente = Label.FAC_TipoCliente_CLIENTE;
					} else if(caso.CAS_LKP_Cliente_contable__r.Type == Label.CUE_TIPO_CONTABLE){
						datosCliente.tipoCliente = Label.FAC_TipoCliente_CIA;
					}
				}
                system.debug(caso.CAS_LKP_Cliente_contable__r.Id + ' probaaaaar');
                system.debug(caso + ' probaaaaar1');
				datosCliente.identificadorUnicoCliente = (''+caso.CAS_LKP_Cliente_contable__r.Id).subString(0,15);
				datosCliente.tipoDocumento = caso.CAS_LKP_Cliente_contable__r.CUE_SEL_Tipo_Documento__c;
				datosCliente.tomadorNumeroDocumentoCliente = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Numero_Documento__c;
				datosCliente.numeroClienteRelacionado = caso.CAS_LKP_Cliente_contable__r.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c;
				datosCliente.telefonoCuenta = caso.CAS_LKP_Cliente_contable__r.Phone;
				datosCliente.condicionPago = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Condicion_Pago__c;
				datosCliente.metodoPago = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Metodo_Pago__c;
				datosCliente.codigoEntidadBanco = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Codigo_Entidad__c;
				datosCliente.codigoSucursal = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Sucursal_Oficina__c;
				datosCliente.digitosControl = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Digito_Control__c;
				datosCliente.numeroCuenta = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Numero__c;
				datosCliente.numeroIBAN = caso.CAS_LKP_Cliente_contable__r.CUE_FOR_IBAN__c;
				datosCliente.paisCuentaBancaria = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Cbanc_Pais__c;
				datosCliente.direccionRiesgoDomicilio = caso.CAS_LKP_Cliente_contable__r.ShippingStreet;
				datosCliente.direccionRiesgoCp = caso.CAS_LKP_Cliente_contable__r.ShippingPostalCode;
				datosCliente.direccionRiesgoProvincia = caso.CAS_LKP_Cliente_contable__r.ShippingState;//caso.Account.ShippingCity;
				datosCliente.paisCliente = caso.CAS_LKP_Cliente_contable__r.CUE_SEL_Pais__c;
				datosCliente.direccionRiesgoPoblacion = caso.CAS_LKP_Cliente_contable__r.ShippingCity;//caso.Account.ShippingState;
				if(caso.CAS_LKP_Cliente_contable__c!=null && cuentaPoliza!=null){
					datosCliente.identificadorCompania = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CUE_TXT_Identificador__c;
					datosCliente.idDireccion = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CUE_TXT_Identificador__c;
				}else if(caso.CAS_LKP_Cliente_contable__c!=null){
					/*datosCliente.identificadorCompania = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
					datosCliente.idDireccion = caso.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;*/
					//Realizamos el if de abajo para separar la concatenación entre número de cliente y procedencia.
					if(caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c != null && 
					caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c != '' && 
					caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c.contains('_')){
						List<String> conCat = new List<String>(caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c.split('\\_'));
						datosCliente.identificadorCompania = conCat.get(0);
						datosCliente.idDireccion = conCat.get(0);
					} else {
						datosCliente.identificadorCompania = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
						datosCliente.idDireccion = caso.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
					}
				}
				String body2 = Callout_Fac_MaestroClientes.construirJsonClientes(datosCliente);
				WS_Info__mdt ws_CASV2 = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Cliente}).values().get(0);
				idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE ,body2, ws_CASV2.EndPoint__c,
							'','','','',inId,'',0,'',0,Label.Callout_PUT);
				Callout_Fac_MaestroClientes.updateDatos(body2,nombreIntegracion,idBitacora,datosCliente.identificadorUnicoCliente,inId);


			}
		}else{ //En este else, construiremos el bodyClientes que se lance cuando lancemos Abonos a Facturador
				
				listaCuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{inId}).values();
					if(!listaCuenta.isEmpty()){
						cuentaAbono = listaCuenta.get(0);
					}
					system.debug('>>>>>verCuentaAbono: ' + cuentaAbono);
				if(cuentaAbono.CUE_LKP_Cliente_contable__c!= null){
					listaContactos = Util_Contacto.getContactByCuenta(new Set<Id>{cuentaAbono.CUE_LKP_Cliente_contable__c}).values();
				}

			if(!listaContactos.isEmpty()){
				contacto = listaContactos.get(0);	
			}
			//QUERY PARA OBTENER EL CUE_TXT_IDENTIFICADOR DE LA CUENTA DE LA POLIZA DEL CLIENTE Y EL NUMERO DE POLIZA
			if(listaCaso != null){
				if(listaCaso.size()>0){
					listaPolizas = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{listaCaso[0].CAS_LKP_PolizaContrato__c}).values();
					if(!listaPolizas.isEmpty()){
						poliza = listaPolizas.get(0);
						listaCuentaPoliza = Util_Cuentas.getMapCuentasById(new Set<Id>{poliza.POL_LKP_compania__c}).values();
						cuentaPoliza = listaCuentaPoliza.get(0);
					}
				}
			}
			if(poliza != null && poliza.Name != ''){
				datosCliente.numeroPoliza= poliza.Name;
			}else{
				if(cuentaAbono.CUE_LKP_Cliente_contable__c!=null && cuentaPoliza!=null){
					datosCliente.numeroPoliza = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CUE_TXT_Identificador__c;
				}else if(cuentaAbono.CUE_LKP_Cliente_contable__c!=null){
					datosCliente.numeroPoliza ='_'+cuentaAbono.CUE_TXT_Identificador__c;
				}		
			}

			if(contacto != null){
				datosCliente.nombreContacto = contacto.Name;
				datosCliente.mailContacto = contacto.Email;
				//datosCliente.direccion = contacto.MailingAddress;
			}
			if(cuentaAbono.CUE_LKP_Cliente_contable__c!=null){
				datosCliente.nombreDelClienteProcedencia = cuentaAbono.Name;
				datosCliente.identificadorUnicoCliente = (''+cuentaAbono.Id).subString(0,15);
				datosCliente.tipoDocumento = cuentaAbono.CUE_SEL_Tipo_Documento__c;
				datosCliente.tomadorNumeroDocumentoCliente = cuentaAbono.CUE_TXT_Numero_Documento__c;
				datosCliente.numeroClienteRelacionado = cuentaAbono.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c;//cuentaAbono.CUE_TXT_Identificador__c;
				datosCliente.telefonoCuenta = cuentaAbono.Phone;
				datosCliente.condicionPago = cuentaAbono.CUE_TXT_Condicion_Pago__c;
				datosCliente.metodoPago = cuentaAbono.CUE_TXT_Metodo_Pago__c;
				datosCliente.codigoEntidadBanco = cuentaAbono.CUE_TXT_Cbanc_Codigo_Entidad__c;
				datosCliente.codigoSucursal = cuentaAbono.CUE_TXT_Cbanc_Sucursal_Oficina__c;
				datosCliente.digitosControl = cuentaAbono.CUE_TXT_Cbanc_Digito_Control__c;
				datosCliente.numeroCuenta = cuentaAbono.CUE_TXT_Cbanc_Numero__c;
				datosCliente.numeroIBAN = cuentaAbono.CUE_FOR_IBAN__c;
				datosCliente.paisCuentaBancaria = cuentaAbono.CUE_TXT_Cbanc_Pais__c;
				datosCliente.direccionRiesgoDomicilio = cuentaAbono.ShippingStreet;
				datosCliente.direccionRiesgoCp = cuentaAbono.ShippingPostalCode;
				datosCliente.direccionRiesgoProvincia = cuentaAbono.ShippingState;//cuentaAbono.ShippingCity;
				datosCliente.paisCliente = cuentaAbono.CUE_SEL_Pais__c;
				datosCliente.direccionRiesgoPoblacion = cuentaAbono.ShippingCity;//cuentaAbono.ShippingState;
				datosCliente.recordType = 'Cliente abonar';//cuentaAbono.recordType.Name;
				//Cuando el cliente es de tipo contable, el tipoCliente será Compañia
				datosCliente.tipoCliente = Label.FAC_TipoCliente_CIA;
				if(cuentaPoliza!=null){
					datosCliente.identificadorCompania = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CUE_TXT_Identificador__c;
					datosCliente.idDireccion = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CUE_TXT_Identificador__c;
				}else{
					/*datosCliente.identificadorCompania = cuentaAbono.CUE_TXT_Identificador__c;
					datosCliente.idDireccion = cuentaAbono.CUE_TXT_Identificador__c;*/
					//Realizamos el if de abajo para separar la concatenación entre número de cliente y procedencia.
					if(cuentaAbono.CUE_TXT_Identificador__c != null && 
					cuentaAbono.CUE_TXT_Identificador__c != '' && 
					cuentaAbono.CUE_TXT_Identificador__c.contains('_')){
						List<String> conCat = new List<String>(cuentaAbono.CUE_TXT_Identificador__c.split('\\_'));
						datosCliente.identificadorCompania = conCat.get(0);
						datosCliente.idDireccion = conCat.get(0);
					} else {
						datosCliente.identificadorCompania = cuentaAbono.CUE_TXT_Identificador__c;
						datosCliente.idDireccion = cuentaAbono.CUE_TXT_Identificador__c;
					}
				}
			}
			/*Se ejecuta una llamada para construir el JSON, y hacer la llamada del cliente contable asociado al caso. Si no es B2C se enviará también la informacion de la cuenta asociada al caso 
			  ya que puede que la factura se pague a medias*/

			if(cuentaAbono.CUE_LKP_Cliente_contable__c != null){//Si no ponemos esta condición, se generaría el body aunque no existiera cliente contable, y obtendríamos un error en el callout,
																//así nos aseguramos de insertar un objeto bitácora con los campos del JSON rellenos.
				String body = Callout_Fac_MaestroClientes.construirJsonClientes(datosCliente);
				WS_Info__mdt ws_CASV = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Cliente}).values().get(0);
				idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE ,body, ws_CASV.EndPoint__c,
							'','',cuentaAbono.Id,'','','',0,'',0,Label.Callout_PUT);
				system.debug('>>>>>idBitacora3: ' + idBitacora);
				Callout_Fac_MaestroClientes.updateDatos(body,nombreIntegracion,idBitacora,inId,'');
			}
			
			//system.debug('>>>>>idBitacora3: ' + idBitacora);
			
			//Callout_Fac_MaestroClientes.updateDatos(body,nombreIntegracion,idBitacora,inId,'');		
		}
		/*PARA CLIENTES ASEGURADOS
		if(poliza != null && cuenta.CUE_LKP_Cliente_contable_B2B2C__c == null){
			system.debug('++++++ 3333333333333333333333 ');
			datosCliente.direccionRiesgoDomicilio = poliza.POL_TXT_Calle__c;
			datosCliente.direccionRiesgoCp = poliza.POL_TXT_Codigo_Postal__c;
			datosCliente.direccionRiesgoProvincia = poliza.POL_SEL_Estado_Provincia__c;
			datosCliente.paisCliente = poliza.POL_SEL_Pais__c;
			datosCliente.direccionRiesgoPoblacion = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Poblacion__c;
			datosCliente.idDireccion = (''+poliza.Id).subString(0,15);	
		} */	
	}
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada al callout
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void facturarCliente(Id inId, String nombreIntegracion){
		system.debug('>>>>>DatosEngancheCliente');
		system.debug('>>>>>inId: ' + inId);
		system.debug('>>>>>nombreIntegracion: ' + nombreIntegracion);
		
		List<Account> listaIdCuenta = new List<Account>();
		String objetoTipo = inId.getSObjectType().getDescribe().getName()+'';
		List<WorkOrder> listWO = new List<WorkOrder>();
		//Comprobamos si la WO tiene compañía aseguradora:
		if(objetoTipo =='WorkOrder'){
			listWO = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{inId}).values();		
			if(!listWO.isEmpty() && listWO[0].AccountId != null){
                system.debug('todo esto es nulo');
                system.debug('@Laura ----->'+listWO);
				construirBodyClientes(listWO,inId,nombreIntegracion);
			}
		}else if(objetoTipo =='Account'){
			construirBodyClientes(listWO,inId,nombreIntegracion);			
		}
	}

	public static void construirBodyPrefactura(List<WorkOrder> listWO, List<Case> listaCuenta, Boolean asegurado, String nombreIntegracion, String idOrdenTrabajo, String diferenciadorWO){
		List<Procedencia__c> listaProcedencias = new List<Procedencia__c>();
		List<ServiceResource> listaProfesional = new List<ServiceResource>();
		Procedencia__c procedencia; 
		List<Case> idPoliza = new List<Case>();
		List<ServiceContract> listaPolizas =	new List<ServiceContract>();
		ServiceContract poliza;
		List<Account> listaCuentaPoliza = new List<Account>();
		Account cuentaPoliza;
		Case cuenta;
		List<Case> listaCasos = new List<Case>();
		Case caso;	 
		List<WorkOrderLineItem> listaParWO=new List<WorkOrderLineItem>();
		WorkOrderLineItem parWO;
		String idBitacora; 
		if(listaCuenta != null && !listaCuenta.isEmpty()){

			cuenta = listaCuenta.get(0);
			system.debug('>>>>>verCuenta: ' + cuenta.Id);

			if(asegurado){
				listaProcedencias = Util_Procedencia.getProcedenciaByAccount(new Set<Id>{cuenta.CAS_LKP_Cliente_contable_cliente__c}).values();
			}else{
				listaProcedencias = Util_Procedencia.getProcedenciaByAccount(new Set<Id>{cuenta.CAS_LKP_Cliente_contable__c}).values();
			}
			if(!listaProcedencias.isEmpty()){
				procedencia = listaProcedencias.get(0);
			}
		}
		if(!listWO.isEmpty() && listWO[0].CaseId != null){
			idPoliza = Util_Caso.getCaseFactById(new Set<Id>{listWO[0].CaseId}).values();
		} 
		if(idPoliza != null){
			if(idPoliza.size()>0){
				listaPolizas = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{idPoliza[0].CAS_LKP_PolizaContrato__c}).values();
				if(!listaPolizas.isEmpty()){
					poliza = listaPolizas.get(0);
					listaCuentaPoliza = Util_Cuentas.getMapCuentasById(new Set<Id>{poliza.POL_LKP_compania__c}).values();
					cuentaPoliza = listaCuentaPoliza.get(0);
				}
			}
		}
		if(!listWO.isEmpty() && listWO[0].Id != null){
			listaParWO = Util_Partida.queryMapPartidasOTByWorkOrder(new Set<Id>{listWO[0].Id}).values();
			if(!listaParWO.isEmpty()){	
				parWO = listaParWO.get(0);
			}
		}
		Callout_Fac_PreFactura_RQ datos;
		for(WorkOrderLineItem datosPartida:listaParWO){
			/*idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_PREFACTURA_NOMBRE,'','',
						'','','','',listWO[0].Id,'',0,'',0,Label.Callout_PUT);*/
			datos = new Callout_Fac_PreFactura_RQ(); 
			datos.identificadorCompania = 'HSAS';
			datos.lineaDeNegocio = cuenta.CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c;
			if(procedencia != null){
				datos.unidadNegocio = procedencia.PROC_SEL_Canal__c ;
			}else{
				datos.unidadNegocio = 'N/A' ;
			}
			/*if(poliza != null){
				datos.segmento = poliza.POL_LKP_Version_Actual__r.POLV_SEL_Segmentacion__c;	
				datos.numeroPoliza = poliza.Name;
			}else{
				datos.segmento = '00';
			}*/ 

			if(poliza != null && poliza.Name != ''){
			datos.numeroPoliza= poliza.Name;
			datos.segmento = poliza.POL_LKP_Version_Actual__r.POLV_FOR_Cod_Segmentacion__c;//poliza.POL_LKP_Version_Actual__r.POLV_SEL_Segmentacion__c;
			} else {
				if(cuenta.CAS_LKP_Cliente_contable__c!=null && cuentaPoliza!=null){
					datos.numeroPoliza = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuentaPoliza.CUE_TXT_Identificador__c;
					datos.segmento = '00';
				}else if(cuenta.CAS_LKP_Cliente_contable_cliente__r!=null){
					datos.numeroPoliza ='_'+cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
					datos.segmento = '00';
				}		
			}

			system.debug('>>>>>CAS_LKP_Cliente_contable_cliente__c: '+cuenta.CAS_LKP_Cliente_contable_cliente__c);
			if(cuenta!=null){
				if(asegurado){
					if(cuenta.CAS_LKP_Cliente_contable_cliente__c != null)
						datos.identificadorUnicoCuenta = (''+cuenta.CAS_LKP_Cliente_contable_cliente__c).subString(0,15);
					datos.codigoUsuario = cuenta.id;
					datos.numeroEstablecimiento = cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Establecimiento__c;
					datos.direccionEstablecimiento	= '';
					datos.nombre = cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Nombre__c;
					datos.apellido1 = cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_PrimerApellido__c;
					datos.apellido2 = cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_SegundoApellido__c;
				}else if(cuenta.CAS_LKP_Cliente_contable__c != null && (''+cuenta.CAS_LKP_Cliente_contable__c).length()>=15){
					datos.identificadorUnicoCuenta = (''+cuenta.CAS_LKP_Cliente_contable__c).subString(0,15);
					datos.codigoUsuario = cuenta.id;
					datos.numeroEstablecimiento = cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Establecimiento__c;
					datos.direccionEstablecimiento	= '';
					datos.nombre = cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Nombre__c;
					datos.apellido1 = cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_PrimerApellido__c;
					datos.apellido2 = cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_SegundoApellido__c;					
				}

			}	
			if(listWO[0].OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c != null){
				datos.identificadorUnicoProfesional = (''+listWO[0].OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c).subString(0,15);
			}
			datos.gremio = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Gremio__c').get(listWO[0].OTR_SEL_Gremio__c);
			datos.vetadoOrdenDeTrabajo = listWO[0].OTR_CAS_Vetado_Orden_Trabajo__c;	 
			datos.identificadorUnicoOrdenTrabajo = (''+listWO[0].Id).subString(0,15) +diferenciadorWO;
			datos.numOrdenTrabajo = listWO[0].WorkOrderNumber;
			//El facturador no recibe "Cerrado pendiente de albarán" ni "Albarán recibido", entiende "Cierre Tecnico"
			if(listWO[0].Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN || listWO[0].Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO){
				datos.estadoCierreOrdenTrabajo = 'Cierre Tecnico';
			} else if (listWO[0].Status == Label.OTR_ESTADO_REVISADO){
				datos.estadoCierreOrdenTrabajo = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(listWO[0].Status);
			} else if(listWO[0].Status == Label.OTR_ESTADO_ANULADO){
				datos.estadoCierreOrdenTrabajo = 'Cancelado';
			}
			datos.fechaCierreOrdenTrabajo = String.valueOf(date.newinstance(listWO[0].LastModifiedDate.year(), listWO[0].LastModifiedDate.month(), listWO[0].LastModifiedDate.day()));
			if(cuenta!=null && cuentaPoliza!=null && asegurado){
				datos.idDireccion = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
			}else if(cuenta!=null && cuentaPoliza!=null && !asegurado){
				datos.idDireccion = cuentaPoliza.CUE_TXT_Identificador__c+'_'+cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
			}else if(asegurado){
				/*datos.idDireccion = cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;*/
				//Realizamos el if de abajo para separar la concatenación entre número de cliente y procedencia.
					if(cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c != null && 
					cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c != '' && 
					cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c.contains('_')){
						List<String> conCat = new List<String>(cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c.split('\\_'));
						datos.idDireccion = conCat.get(0);
					} else {
						datos.idDireccion = cuenta.CAS_LKP_Cliente_contable_cliente__r.CUE_TXT_Identificador__c;
					}
				
			}else{
				/*datos.idDireccion = cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;*/
				
				//Realizamos el if de abajo para separar la concatenación entre número de cliente y procedencia.
				if(cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c != null && 
					cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c != '' && 
					cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c.contains('_')){
						List<String> conCat = new List<String>(cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c.split('\\_'));
						datos.idDireccion = conCat.get(0);
					} else {
						datos.idDireccion = cuenta.CAS_LKP_Cliente_contable__r.CUE_TXT_Identificador__c;
					}
				
				
				
				
			}
			datos.direccionRealizacionTrabajo = listWO[0].Street;
			datos.localidadRealizacionTrabajo = listWO[0].City;
			datos.provinciaRealizacionTrabajo = listWO[0].State;
			if(datosPartida!=null){
				datos.lineaOrdenTrabajo = datosPartida.Id;
				if(datosPartida.PAR_FOR_Cargar_Cliente_DI__c != null || datosPartida.PAR_FOR_Cargar_Comp_DI__c != null){
					if(asegurado){
						datos.importeVentaLineaOrdenTrabajo = datosPartida.PAR_DIV_Cargar_Cliente_AI__c; //Si es la prefactura del asegurado/secundario, enviamos los datos del cliente/secundario
						if(datosPartida.PAR_FOR_Cargar_Cliente_DI__c == 0){
							datos.precioUnitarioGastos = 0;
						}else {
							datos.precioUnitarioGastos = datosPartida.PAR_DIV_ListPrice__c;
						}
					}else{
						datos.importeVentaLineaOrdenTrabajo = datosPartida.PAR_DIV_Cargar_Comp_AI__c;//Si es la prefactura de la compañía/principal, enviamos los datos de la compañía/Principal
						datos.precioUnitarioGastos = datosPartida.PAR_DIV_ListPrice__c;
						if(datosPartida.PAR_FOR_Cargar_Comp_DI__c == 0){
							datos.precioUnitarioGastos = 0;
						}else {
							datos.precioUnitarioGastos = datosPartida.PAR_DIV_ListPrice__c;
						}
					}
				}
				datos.codigoImpuestoVenta = datosPartida.PAR_SEL_Codigo_Impuesto_Venta__c; 
				datos.unidadesDeMedida = datosPartida.PAR_SEL_Unidades_Medida__c;	 
				datos.cantidadGastos = datosPartida.PAR_NUM_Unidades__c;
				//datos.precioUnitarioGastos = datosPartida.PAR_DIV_ListPrice__c;
				if(asegurado){
					datos.importeBaseImponible = datosPartida.PAR_DIV_Cargar_Cliente_AI__c;//Si es la prefactura del asegurado/secundario, enviamos los datos del cliente/secundario
				}else{
					datos.importeBaseImponible = datosPartida.PAR_DIV_Cargar_Comp_AI__c;//Si es la prefactura de la compañía/principal, enviamos los datos de la compañía/Principal
				}
				datos.importeTotal = datosPartida.PAR_DIV_Facturacion_Total_AI__c;
				datos.impuestoIva = datosPartida.PAR_NUM_Iva__c;
				datos.impuestoIpsi = datosPartida.PAR_NUM_Ipsi__c;
				datos.impuestoIgic = datosPartida.PAR_NUM_Igic__c;
				datos.descuento = datosPartida.PAR_POR_Descuento__c;
				datos.codigoBaremo = datosPartida.PAR_TXT_Baremo_Codigo__c;
				datos.ancho = datosPartida.PAR_NUM_Ancho__c;
				datos.alto = datosPartida.PAR_NUM_Altura__c;
				datos.porcentajeProf = datosPartida.PAR_POR_Impuesto_Prof__c; 
				datos.porcentajeCli = datosPartida.PAR_POR_Porcentaje_Imp_Cia_Cliente__c;
				datos.daniosDel = datosPartida.PAR_SEL_Danios_Del__c;
				datos.unidadMedidaGastos = datosPartida.PAR_SEL_Unidades_Medida__c;
				datos.daniosEsteticos = datosPartida.PAR_CAS_Danos_Esteticos__c;
				datos.descripcionBaremo = datosPartida.PAR_TXT_Baremo_Desc__c; 
				datos.baremo = datosPartida.PAR_TXT_Baremo_Codigo__c; 
				datos.detalleVenta = datosPartida.PAR_TXT_Detalle_Venta__c; 
				datos.cantidadVenta = datosPartida.PAR_NUM_Unidades__c;
				datos.precioUnitarioVenta = datosPartida.PAR_DIV_Precio_Unitario_Venta__c; 
				datos.unidadMedidadGastos = 'EUR';	 
				datos.detalleLineaOrdenDeTrabajo = datosPartida.PAR_TXT_Detalle_WOLI__c;	 
				datos.porcentajeMateriales = datosPartida.PAR_POR_Materiales__c;	
				datos.sREF = datosPartida.PAR_TXT_S_Ref__c;
				datos.codigoImpuestoGasto = '';//''+datosPartida.PAR_SEL_Codigo_Impuesto_Venta__c;	
			}
			if(cuenta != null){
				datos.numCaso = cuenta.CaseNumber;
				datos.identificadorUnicoCaso = (''+cuenta.Id).subString(0,15);
				if(cuenta.Status != null && cuenta.Status == Label.CAS_ESTADO_CERRADO){//El facturador recibe los estados "Abierto" o "Cerrado", cuando el estado no sea "Cerrado", lo consideraremos "Abierto"
					datos.estado = 'Cerrado';
				}else if(cuenta.Status != null && cuenta.Status != Label.CAS_ESTADO_CERRADO){
					datos.estado = 'Abierto';
				}
				if(cuenta.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C)){
					datos.tipoCaso = 'Servicio B2C';
				} else {
					datos.tipoCaso = cuenta.RecordType.Name;//Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'Type').get(cuenta.Type); //cuenta.Type;
				}
				
				system.debug('>>>>>nombreRT: ' + cuenta.RecordType.Name);
				system.debug('>>>>>nombreEtiqueta: ' + Label.CAS_TIPOLOGIA_ASISTENCIA);
				
				datos.monedaVenta = 'EUR'; 
				datos.actividad = 'N/A';
				if(cuenta.Type != null && cuenta.Type.length() == 1){
					datos.tipoIntervencion = '0' + cuenta.Type;
				}else if(cuenta.Type != null && cuenta.Type.length() == 2){
					datos.tipoIntervencion = cuenta.Type;
				}else{
					datos.tipoIntervencion = '00';
				}				

				if(cuenta.CAS_SEL_Grupo_Causa__c == null || cuenta.CAS_SEL_Grupo_Causa__c == '')
					datos.grupoCausa = '00';
				else
					datos.grupoCausa = cuenta.CAS_SEL_Grupo_Causa__c;
				datos.servicio = cuenta.recordtype.DeveloperName;
				datos.siniestrosGraves = cuenta.CAS_CAS_Siniestro_Grave__c;
				datos.facturaAbonar = '';
				datos.numeroReferenciaCliente = cuenta.CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c;
				datos.numeroReferenciaActivo = cuenta.CAS_TXT_Num_Caso_HS__c;	
				if(datos.estado == 'Abierto'){
					datos.fechaCierreCaso = '';
				} else {
					datos.fechaCierreCaso = String.valueOf(date.newinstance(cuenta.LastModifiedDate.year(), cuenta.LastModifiedDate.month(), cuenta.LastModifiedDate.day()));
				}
				datos.numeroExpediente = cuenta.CAS_TXT_Num_Caso_HS__c;
				datos.fechaOcurrencia = cuenta.CAS_DAT_Fecha_Ocurrencia__c;
				datos.referencia = cuenta.CAS_TXT_Num_Caso_HS__c;
				datos.itemProducto = cuenta.CAS_FOR_Producto__c;
				datos.delegacion = cuenta.CAS_SEL_Direccion_Territorial__c;
				datos.direccionTerritorial = cuenta.CAS_SEL_Direccion_Territorial__c;
				datos.codigoGestorNombre = cuenta.Owner.Name;
				datos.pagoDeMinuta = cuenta.CAS_DIV_Pago_de_Minuta__c;
			}
			
			
			String body = Callout_Fac_PreFactura.construirBody(datos);
			WS_Info__mdt ws_CASV = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Prefactura}).values().get(0);
			
			idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_PREFACTURA_NOMBRE ,body, ws_CASV.EndPoint__c,
							'','','','',idOrdenTrabajo,'',0,'',0,Label.Callout_PUT);
							
			/*idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_PREFACTURA_NOMBRE,'','',
						'','','','',listWO[0].Id,'',0,'',0,Label.Callout_PUT);*/
						
			Callout_Fac_PreFactura.updateDatos(body,nombreIntegracion,idBitacora,idOrdenTrabajo);			
		}
	}

	public static void facturarPreFactura(Id inId, String nombreIntegracion){
		List<WorkOrder> listWO = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{inId}).values();
		List<Account> listaCuenta = new List<Account>();
		List<Account> listaIdCuenta = new List<Account>();
		List<Case> listaCaso = new List<Case>();
		Case caso = new Case();
		if(!listWO.isEmpty()){
			if(listWO[0].CaseId != null){
			listaCaso = Util_Caso.getCaseFactById(new Set<Id>{listWO[0].CaseId}).values();
				if(!listaCaso.isEmpty()){
					caso = listaCaso.get(0);
                    system.debug(caso + ' casoooo');
				}
			}
		}

		if(caso.CAS_FOR_RTDevName__c != Label.RT_CAS_B2C){
			construirBodyPrefactura(listWO,listaCaso,true, nombreIntegracion,inId,'_01');
			construirBodyPrefactura(listWO,listaCaso,false, nombreIntegracion,inId,'_02');
		}else{
			construirBodyPrefactura(listWO,listaCaso,false, nombreIntegracion,inId,'');
		} 
	}

	public static void facturarProfesional(Id inId, String nombreIntegracion){
		system.debug('>>>>DatosEngancheProf: ');
		system.debug('>>>>inId: ' + inId);
		system.debug('>>>>nombreIntegracion: ' + nombreIntegracion);
		List<ServiceResource> listaProfesional = new List<ServiceResource>();
		ServiceResource profesional;
		List<Case> idPoliza = new List<Case>();
		List<ServiceContract> listaPolizas =	new List<ServiceContract>();
		ServiceContract poliza;
		List<Account> listaCuentaPoliza = new List<Account>();
		Account cuentaPoliza;
		List<Account> listaCuenta = new List<Account>();
		Account cuenta; 
		List<Contact> listaContacts;
		Contact contacto;
		Set<Id> listIdCuenta = new Set<Id>();
		String idBitacora;
				system.debug('<<<<<<<<<<sera facturador>>>>>>>>>' + inId.getSObjectType().getDescribe().getName());
		String objetoTipo = inId.getSObjectType().getDescribe().getName()+'';
		if (objetoTipo == 'WorkOrder') {
			List<WorkOrder> listWO = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{inId}).values();
			for(WorkOrder idCuenta:listWO){
				listIdCuenta.add(idCuenta.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c);
			}
			if(listWO != null && !listWO.isEmpty()){
				if(listWO[0].OTR_LKP_Recurso_Servicio__c != null){
					if(listWO[0].OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c != null){
					listaCuenta = Util_Cuentas.getMapCuentasById(listIdCuenta).values();		
					}
				}
				if(listWO[0].AccountId != null){
					listaProfesional = Util_Service_Resource.queryMapSRByRsIds(new Set<Id>{listWO[0].OTR_LKP_Recurso_Servicio__c}).values();
				}
				if(listWO[0].ContactId != null){
					listaContacts = Util_Contacto.getContactById(new Set<Id>{listWO[0].ContactId}).values();
					if(!listaContacts.isEmpty()) contacto = listaContacts.get(0);
				}
				
		}
		}else if(objetoTipo == 'Account'){
			listaProfesional = Util_Service_Resource.queryMapSRByRsIds(new Set<Id>{inId}).values();
			for(ServiceResource idCuenta:listaProfesional){
				listIdCuenta.add(idCuenta.RSE_LKP_Cuenta__c);
			}
			if(inId != null){
				listaCuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{inId}).values();
			}
		}
		if(!listaCuenta.isEmpty()){
				cuenta = listaCuenta.get(0);
			}


		Callout_Fac_MaestroProfesionales_RQ datosProfesional = new Callout_Fac_MaestroProfesionales_RQ();
		if(cuenta!=null){
			datosProfesional.tipoDocumento = cuenta.CUE_SEL_Tipo_Documento__c;
			datosProfesional.tomadorNumeroDocumentoCliente = cuenta.CUE_TXT_Numero_Documento__c;
			datosProfesional.direccionDelProfesional = cuenta.ShippingStreet;
			datosProfesional.codigoPostalProfesional = cuenta.ShippingPostalCode;
			datosProfesional.ciudadProfesional = cuenta.ShippingState;
			datosProfesional.paisProfesional = cuenta.CUE_SEL_Pais__c;
			datosProfesional.importeFianzaMaxima = cuenta.CUE_DIV_Importe_fianza_Maxima__c;
			datosProfesional.condicionPago = cuenta.CUE_TXT_Condicion_Pago__c;
			datosProfesional.codigoRetencionFiscal = cuenta.CUE_TXT_Codigo_Retencion_Fiscal__c;
			datosProfesional.profesionaFianza = cuenta.CUE_CAS_Profesional_Fianza__c;
			datosProfesional.porcentajeFianza = cuenta.CUE_POR_Porcentaje_Fianza__c;
			datosProfesional.importeTotalFianza = cuenta.CUE_DIV_Importe_Total_Fianza__c;
			datosProfesional.importeFianzadevuelta = cuenta.CUE_DIV_Importe_Fianza_Devuelta__c;
			datosProfesional.fechaBajaDefinitiva = cuenta.CUE_DAT_Fecha_Baja__c;
			datosProfesional.importeFranquicia = cuenta.CUE_DIV_Importe_Franquicia__c;
			if(cuenta.CUE_DIV_Importe_Franquicia__c != null && cuenta.CUE_DIV_Importe_Franquicia__c != 0){
				datosProfesional.profesionalFranquicia = true;
			} else {
				datosProfesional.profesionalFranquicia = false;
			}
			datosProfesional.vencimientosFranquicia = cuenta.CUE_NUM_Vencimientos_Franquicia__c;
			if(cuenta.CUE_DAT_Profesional_Franquicia__c != null)
				datosProfesional.fechaFranquicia = ''+cuenta.CUE_DAT_Profesional_Franquicia__c;
			datosProfesional.tipoProfesional = cuenta.Type;
			datosProfesional.metodoPago = cuenta.CUE_TXT_Metodo_Pago__c;
			datosProfesional.codigoEntidadBanco = cuenta.CUE_TXT_Cbanc_Codigo_Entidad__c;
			datosProfesional.codigoSucursal = cuenta.CUE_TXT_Cbanc_Sucursal_Oficina__c;
			datosProfesional.profesionalRappel = cuenta.CUE_CAS_Profesional_Rappel__c;
			datosProfesional.tipologiaRappel = cuenta.CUE_TXT_Tipologia_Rappel__c;
			datosProfesional.digitosControl = cuenta.CUE_TXT_Cbanc_Digito_Control__c;
			datosProfesional.numeroCuenta = cuenta.CUE_TXT_Cbanc_Numero__c;
			datosProfesional.numeroIban = cuenta.CUE_FOR_IBAN__c;
			datosProfesional.paisCuentaBancaria	= cuenta.CUE_TXT_Cbanc_Pais__c;
			datosProfesional.embargado = cuenta.CUE_CAS_Embargado__c;
			datosProfesional.vetado = cuenta.CUE_CAS_Vetado__c;
			datosProfesional.numeroProfesional = cuenta.CUE_TXT_Identificador__c ;
			datosProfesional.nombreProfesional = cuenta.CUE_LKP_CuentaPrincipalProf__r.Name;//cuenta.Name;
			datosProfesional.identificadorUnicoProfesional = (''+cuenta.Id).subString(0,15);
		}
		
		if(contacto != null){
			datosProfesional.nombreContacto = contacto.Name;
			datosProfesional.mailContacto = contacto.Email;
			datosProfesional.telefonoContacto = contacto.MobilePhone;
		}
		
		datosProfesional.accionRealizada = 'Alta';		
		datosProfesional.profesionalPerito = False;
		
		String body = Callout_Fac_MaestroProfesionales.construirBody(datosProfesional);
		WS_Info__mdt ws_CASV = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Profesional}).values().get(0);
		
							
		//system.debug('body util:'+body);
		system.debug('>>>>>AntesDeError');
		if(objetoTipo == 'WorkOrder') {
			system.debug('>>>>>verinID: ' + inId);
			if(listaCuenta.isEmpty() != null || !listaCuenta.isEmpty()){
				idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_PROFESIONALES_NOMBRE ,body, ws_CASV.EndPoint__c,
						'','','','',inId,'',0,'',0,Label.Callout_PUT);
			}
			Callout_Fac_MaestroProfesionales.updateDatos(body,nombreIntegracion,idBitacora,datosProfesional.identificadorUnicoProfesional,inId);
		}else if(objetoTipo == 'Account'){
			if(listaCuenta.isEmpty() != null || !listaCuenta.isEmpty()){
				idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_MAESTRO_PROFESIONALES_NOMBRE ,body, ws_CASV.EndPoint__c,
							'','',inId,'','','',0,'',0,Label.Callout_PUT);
			}
			Callout_Fac_MaestroProfesionales.updateDatos(body,nombreIntegracion,idBitacora,datosProfesional.identificadorUnicoProfesional,''); 
		}

	}
	
	//Comentado para la subida a producción, ya que, las clases que aplican para Eventos y Abonos, no están subidas a producción, y dará error al desplegar el paquete. (NO ELIMINAR)
	public static void facturadorAbonos(Id inId, String nombreIntegracion){
	String idBitacora;
		List<Propuesta_de_Evento__c> idsEventos = Util_Propuesta_de_evento.getPropuestaEventoByAbono(new Set<Id>{inId}).values();
		for(Propuesta_de_Evento__c ids:idsEventos){
			String idBitac = '';
			//idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,Label.FAC_Eventos_a ,
								//'', '','','','', '','', '',0,'', 0.0,Label.Callout_PUT);
			facturadorEventos(ids.Id,Label.FAC_Eventos_a);
		}
		List<Propuesta_de_Abono__c> propAbonos = Util_Propuesta_de_abono.getPropuestaAbonoById(new Set<Id>{inId}).values();
		
		Propuesta_de_Abono__c abono = new Propuesta_de_Abono__c();
		Callout_Fac_EventosAbonos_RQ datosAbono = new Callout_Fac_EventosAbonos_RQ();

		if (propAbonos != null){
			abono = propAbonos.get(0);
			system.debug('@Laura: abono: '+ abono);
			system.debug('@Laura: abono.AB_LKP_Caso__r' + abono.AB_LKP_Caso__r);
			List<String> rTypeIds = new List<String>();
			String rTypeId = ''+abono.AB_LKP_Caso__r.RecordTypeId;
			system.debug('@Laura: rTypeId: '+ rTypeId);
			rTypeIds.add(rTypeId);
			List<RecordType> rTypeName = new List<RecordType>([SELECT Name FROM RecordType WHERE Id =: rTypeId]);
			system.debug('@Laura: rTypeName: ' + rTypeName.get(0));
			datosAbono.identificadorUnicoEvento = '';
			datosAbono.identificadorUnicoAbono = (''+abono.Id).subString(0,15);
			datosAbono.unidadNegocio = Label.FAC_Unidad_Negocio;
			datosAbono.lineaDeNegocio = abono.AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c;//datosAbono.lineaDeNegocio = abono.AB_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
			datosAbono.identificadorUnicoCaso = abono.AB_LKP_Caso__r.CaseNumber;
			if(abono.AB_LKP_Orden_de_Trabajo__c != null){
				datosAbono.identificadorUnicoOrdenTrabajo = (''+abono.AB_LKP_Orden_de_Trabajo__c).subString(0,15);
			}
			datosAbono.numOrdenTrabajo = abono.AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber;
			datosAbono.lineaOrdenTrabajo = abono.AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber;
			if(abono.AB_TXT_Observaciones__c != null && abono.AB_TXT_Observaciones__c != ''){
				system.debug('>>>>>DentroIfAbono: ' + abono.AB_TXT_Observaciones__c);
				datosAbono.descripcion = abono.AB_TXT_Observaciones__c;
			} else {
				system.debug('>>>>>DentroElseAbono');
				datosAbono.descripcion = 'Abono';
			}
			//datosAbono.descripcion = abono.AB_TXT_Observaciones__c;//abono.AB_TXT_Descripcion__c;
			datosAbono.moneda = 'EUR';
			datosAbono.direccionTerritorial = abono.AB_FOR_Direccion_Territorial__c;
			if(abono.AB_LKP_Caso__r.Type != null && abono.AB_LKP_Caso__r.Type.length() == 1){
					datosAbono.tipoIntervencion = '0' + abono.AB_LKP_Caso__r.Type;
				} else if(abono.AB_LKP_Caso__r.Type != null && abono.AB_LKP_Caso__r.Type.length() == 2){
					datosAbono.tipoIntervencion = abono.AB_LKP_Caso__r.Type;
				} else {
					datosAbono.tipoIntervencion = '00';
				}
			datosAbono.grupoCausa = abono.AB_LKP_Caso__r.CAS_SEL_Grupo_Causa__c;
			if(rTypeName[0].Name == Label.CAS_TIPOLOGIA_ASISTENCIA	){
				datosAbono.tipoRegistroCaso = '01';
			} else if(rTypeName[0].Name == Label.CAS_TIPOLOGIA_SINIESTRO){
				datosAbono.tipoRegistroCaso = '02';
			} else if(rTypeName[0].Name == Label.CAS_TIPOLOGIA_GRAN_SINIESTRO){
				datosAbono.tipoRegistroCaso = '03';
			} else {
				datosAbono.tipoRegistroCaso = '00';
			}
			datosAbono.facturaAbonar = abono.AB_LKP_Factura__r.FAC_TXT_Numero_factura__c;
			datosAbono.impuesto = '';
			datosAbono.retencion = '';
			
			datosAbono.id_DireccionCliente = /*'_' +*/ abono.AB_LKP_Ingresar_a__r.CUE_TXT_Identificador__c;//abono.AB_LKP_Cuenta__r.CUE_TXT_Identificador__c;
			datosAbono.identificadorUnicoProfesional = '';
			datosAbono.importe = ''+abono.AB_DIV_Importe_a_ingresar__c;
			if(abono.AB_LKP_Ingresar_a__c != null){//if(abono.AB_LKP_Cuenta__c != null){
				datosAbono.identificadorUnicoCuenta = (''+abono.AB_LKP_Ingresar_a__c).subString(0,15);//datosAbono.identificadorUnicoCuenta = (''+abono.AB_LKP_Cuenta__c).subString(0,15);
			}
			datosAbono.tipoEvento = Label.FAC_TipoEvento_Abono;
		}
		//String body = Callout_Fac_Eventos.construirBodyAbonos(datosAbono);
		//Callout_Fac_Eventos.updateDatos(body,nombreIntegracion,idBitacora,inId);
		
		if(propAbonos != null){//Aseguramos que el body se va a rellenar, y no se generará un objeto de bitácora vacío
			String body = Callout_Fac_Eventos.construirBodyAbonos(datosAbono);
			WS_Info__mdt ws_CASV = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Ev_Ab}).values().get(0);
			system.debug('>>>>ver ws_CASV: ' + ws_CASV);
			system.debug('>>>>ver ws_CASV EndPoint__c: ' + ws_CASV.EndPoint__c);

			idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_Eventos_b ,body, ws_CASV.EndPoint__c,
					'','','','','','',0,'',0,Label.Callout_PUT);

			Callout_Fac_Eventos.updateDatos(body,nombreIntegracion,idBitacora,inId);
		}
	}
	public static void facturadorEventos(Id inId, String nombreIntegracion){
		String idBitacora;
		Callout_Fac_Eventos_RQ datosEvento = new Callout_Fac_Eventos_RQ();
		List<Propuesta_de_Evento__c> propEventos = Util_Propuesta_de_evento.getPropuestaEventoByIdOrEconomico(new Set<Id>{inId}, new Set<Id>{inId}).values();

		List<String> rTypeIds = new List<String>();
		String rTypeId;
		for(Propuesta_de_Evento__c evento:propEventos){
			 rTypeId = ''+evento.EV_AB_LKP_Caso__r.RecordTypeId;
			 rTypeIds.add(rTypeId);
		}
		List<RecordType> rTypeName = new List<RecordType>([SELECT Name FROM RecordType WHERE Id IN :rTypeIds]);

		for(Propuesta_de_Evento__c evento:propEventos){
			Integer i = 0;
			datosEvento.identificadorUnicoEvento = (''+evento.Id).subString(0,15);
			datosEvento.identificadorUnicoAbono = '';//evento.EV_AB_LKP_Abono__c;
			datosEvento.unidadNegocio = Label.FAC_Unidad_Negocio;
			datosEvento.lineaDeNegocio = evento.EV_AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c;//datosEvento.lineaDeNegocio = evento.EV_AB_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
			datosEvento.identificadorUnicoCaso = evento.EV_AB_LKP_Caso__r.CaseNumber;
			if(evento.EV_AB_LKP_Orden_de_Trabajo__c != null){
				datosEvento.identificadorUnicoOrdenTrabajo = (''+evento.EV_AB_LKP_Orden_de_Trabajo__c).subString(0,15);
			}
			datosEvento.numOrdenTrabajo = evento.EV_AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber;
			datosEvento.descripcion = Util_Listas_Seleccion.getLabelDesdeAPI('Propuesta_de_Evento__c', 'EV_AB_SEL_Descripcion__c').get(evento.EV_AB_SEL_Descripcion__c);
			datosEvento.moneda = 'EUR';
			datosEvento.direccionTerritorial = evento.EV_AB_FOR_Direccion_Territorial__c;
			if(evento.EV_AB_LKP_Caso__r.Type != null && evento.EV_AB_LKP_Caso__r.Type.length() == 1){
				datosEvento.tipoIntervencion = '0' + evento.EV_AB_LKP_Caso__r.Type;
			} else if(evento.EV_AB_LKP_Caso__r.Type != null && evento.EV_AB_LKP_Caso__r.Type.length() == 2){
				datosEvento.tipoIntervencion = evento.EV_AB_LKP_Caso__r.Type;
			} else {
				datosEvento.tipoIntervencion = '00';
			}
				
			datosEvento.grupoCausa = evento.EV_AB_LKP_Caso__r.CAS_SEL_Grupo_Causa__c ;
			
			if(!rTypeName.isEmpty()){
				if(rTypeName[i].Name == Label.CAS_TIPOLOGIA_ASISTENCIA){
					datosEvento.tipoRegistroCaso = '01';
				} else if(rTypeName[i].Name == Label.CAS_TIPOLOGIA_SINIESTRO){
					datosEvento.tipoRegistroCaso = '02';
				} else if(rTypeName[i].Name == Label.CAS_TIPOLOGIA_GRAN_SINIESTRO){
					datosEvento.tipoRegistroCaso = '03';
				} else {
					datosEvento.tipoRegistroCaso = '00';
				}
			}

			datosEvento.facturaAbonar = '';
			datosEvento.impuesto = '';
			datosEvento.retencion = '';
						//Se prueba en el test de Callout_Fac_Eventos
			datosEvento.id_DireccionCliente = '';
			//if(evento.EV_AB_LKP_Orden_de_Trabajo__r.OTR_LKP_Recurso_Servicio__c != null)
			//	datosEvento.identificadorUnicoProfesional = (''+evento.EV_AB_LKP_Orden_de_Trabajo__r.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c).subString(0,15);*///evento.EV_AB_LKP_Orden_de_Trabajo__r.OTR_LKP_Recurso_Servicio__c;
			//if(evento.EV_AB_DIV_Importe_gestor__c != null)
			//	datosEvento.importe = ''+evento.EV_AB_DIV_Importe_gestor__c;*/
				
			if(evento.EV_AB_LKP_Imputar_a_profesional__c != null && evento.EV_AB_DIV_Importe_profesional__c != null){
				datosEvento.identificadorUnicoProfesional = ('' + evento.EV_AB_LKP_Imputar_a_profesional__c).subString(0,15);
				datosEvento.importe = '' + evento.EV_AB_DIV_Importe_profesional__c;
			} else if (evento.EV_AB_LKP_Liquidar_a_prof__c !=null && evento.EV_AB_DIV_Importe_a_liquidar_prof__c != null){
				datosEvento.identificadorUnicoProfesional = ('' + evento.EV_AB_LKP_Liquidar_a_prof__c).subString(0,15);
				datosEvento.importe = '' + evento.EV_AB_DIV_Importe_a_liquidar_prof__c;
			}
			datosEvento.identificadorUnicoCuenta = '';
			datosEvento.tipoEvento = evento.EV_AB_SEL_Descripcion__c;
			
			if(datosEvento != null){
				String body = Callout_Fac_Eventos.construirBodyEventos(datosEvento);
				WS_Info__mdt ws_CASV = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{Label.FAC_Callout_Ev_Ab}).values().get(0);
				idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',Label.FAC_Eventos_a ,body, ws_CASV.EndPoint__c,
					'','','','','','',0,'',0,Label.Callout_PUT);
				Callout_Fac_Eventos.updateDatos(body,nombreIntegracion,idBitacora,datosEvento.identificadorUnicoOrdenTrabajo);
			}
			//String body = Callout_Fac_Eventos.construirBodyEventos(datosEvento);			
			//Callout_Fac_Eventos.updateDatos(body,nombreIntegracion,idBitacora,datosEvento.identificadorUnicoOrdenTrabajo);
			i++;	
		}
	}

	public static void calloutFacturador (Map<Id,WorkOrder> mapaOTs, String service) {
		List<String> partidasId = new List<String>();
		Map<Id, String> mapaOTR = new Map<Id, String>();
		Util_Llamada_Externa n;
		for(WorkOrder wo:mapaOTs.values()){
			if(wo.Status == Label.OTR_ESTADO_REVISADO || wo.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN || wo.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO ){
				mapaOTR = new Map<Id, String>();
				mapaOTR.put(wo.Id, 'WorkOrder');
				//String idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','03','02',service,'','',
						//'','','','',wo.Id,'',0,'',0,Label.Callout_PUT);
				n = new Util_Llamada_Externa(mapaOTR,'Facturador',service,'');		
				System.enqueueJob(n);
			}	
		}	
	}
	
	public static void calloutFacturadorEvento (Map<Id,Propuesta_de_Evento__c> triggerNewMap, String service) {
		List<String> eventosId = new List<String>();
		Map<Id, String> mapaEventos = new Map<Id, String>();
		Util_Llamada_Externa n;
		for(Propuesta_de_Evento__c ev:triggerNewMap.values()){
			if(ev.EV_AB_SEL_Estado__c == Label.EV_AB_ESTADO_APROBADO){
				Map<Id, String> mapaEV = new Map<Id, String>();
				mapaEV.put(ev.Id, 'Propuesta_de_Evento__c');
				//String idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','03','02',service,'','',
						//'','','','','','',0,'',0,Label.Callout_PUT);
				n = new Util_Llamada_Externa(mapaEV,'Facturador',service,'');		
				System.enqueueJob(n);
			}
		}
	}

	public static void calloutFacturadorAbono (Map<Id,Propuesta_de_Abono__c> triggerNewMap, String service) {
		List<String> abonosId = new List<String>();
		Map<Id, String> mapaAbonos = new Map<Id, String>();
		Util_Llamada_Externa n;
		for(Propuesta_de_Abono__c ab:triggerNewMap.values()){
			if(ab.AB_SEL_Estado__c == Label.AB_ESTADO_APROBADO){
				Map<Id, String> mapaAB = new Map<Id, String>();
				mapaAB.put(ab.Id, 'Propuesta_de_Abono__c');
				//Línea inferior comentada: No queremos que se cree un objeto bitácora si los campos inferiores no van a estar completos;
				//String idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','03','02',service,'','',
						//'','','','','','',0,'',0,Label.Callout_PUT);
				n = new Util_Llamada_Externa(mapaAB,'Facturador',service,'');
				System.enqueueJob(n);
			}
		}
	}
}