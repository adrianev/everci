public without sharing class Util_Llamada_Externa implements Queueable {

	private Map<Id, String> registroId;     
	private String compania, llamada, idBitacora;
	private Map <String,String>campoActualizado;
	private Set<Id> cuentasPadre;
	private Map<Id,Linea_Contrato__c> mapaLineas;
	private List<WorkOrder> listaWO;
	
	/**
	 * Constructor para ClickToCall
	 */
	public Util_Llamada_Externa(List<WorkOrder> listaWO,String llamada){
		this.listaWO =listaWO;
		this.llamada = llamada;
	}

	public Util_Llamada_Externa(Set<Id> cuentasPadre,Map<Id,Linea_Contrato__c> mapaLineas,String llamada){
		this.cuentasPadre =cuentasPadre;
		this.llamada = llamada;
		this.mapaLineas=mapaLineas;
	}

	public Util_Llamada_Externa(Map<Id, String> registroId,String compania,String llamada, String idBitacora){
		this.registroId =registroId;
		this.compania = compania;
		this.llamada = llamada;
		this.idBitacora = idBitacora;
        system.debug('datos del constructor util:');
        system.debug(registroId);
        system.debug(compania);
        system.debug(llamada);
        system.debug(idBitacora);
        
	}

	/*
	 * Constructor que permite al proceso batch conocer el campo que ha sido actualizado y acerca del que se debe informar al sistema tercero
	 * @param registroId: Mapa que contiene tuplas con valor <Id,'tipoDeRegistroAsociado al id'>
	 * @param compania: compañía a cuyo sistema se hace el callout correspondiente
	 * @param llamada: nombre o identificador inequívoco del callout a realizar i.e. 'SRV-PSI-058'
	 * @param idBitacora: identificador de la bitácora asociada a la llamada, que se actualiza con el estado de esta (error, se borra si se envía...)
	 * @param campoActualizado: mapa de tupla <nombre del campo afectado, insertOupdate>
	 *
	 */
	public Util_Llamada_Externa(Map<Id, String> registroId,String compania,String llamada, String idBitacora, Map<String,String> campoActualizado){
		this.registroId = registroId;
		this.compania = compania;
		this.llamada = llamada;
		this.idBitacora = idBitacora;
		this.campoActualizado = campoActualizado;
		system.debug('datos del constructor util:');
        system.debug(registroId);
        system.debug(compania);
        system.debug(llamada);
        system.debug(idBitacora);
	}


	public void execute(QueueableContext context) {
		system.debug('ejecuta');
		generarLlamada();       
	}

	public static String insertarBitacora(String BIT_TXT_Sistema_externo, String BIT_TXT_Error,String BIT_SEL_Estado, String BIT_SEL_Tipo_Integracion,String BIT_TXT_Nombre_Integracion,
			String BIT_TXT_Json, String BIT_TXT_EndPoint, String BIT_LKP_Id_Registro_caso, String BIT_LKP_Id_Registro_contacto, String BIT_LKP_Id_Registro_cuenta, String BIT_LKP_Id_Registro_factura,
			String BIT_LKP_Id_Registro_orden, String BIT_TXT_Id_Secuencia_Indemnizables, Integer BIT_NUM_Orden_RGA,String idBitacora, Decimal BIT_NUM_Reintentos, String BIT_TXT_Method){
		INT_Bitacora__c toInsert = new INT_Bitacora__c();
		system.debug('prueba bitacora: '+idBitacora);
		system.debug('>>>>>BIT_TXT_EndPoint: ' + BIT_TXT_EndPoint);
		toInsert.BIT_TXT_Sistema_externo__c = BIT_TXT_Sistema_externo;
		toInsert.BIT_TXT_Error__c =BIT_TXT_Error;
		toInsert.BIT_SEL_Estado__c = BIT_SEL_Estado;
		toInsert.BIT_TXT_Nombre_Integracion__c = BIT_TXT_Nombre_Integracion;
		toInsert.BIT_SEL_Tipo_Integracion__c = BIT_SEL_Tipo_Integracion;
		toInsert.BIT_TXT_Json__c = BIT_TXT_Json;
		toInsert.BIT_TXT_Method__c = BIT_TXT_Method;
		toInsert.BIT_TXT_EndPoint__c = BIT_TXT_EndPoint;
		if(BIT_LKP_Id_Registro_caso != '')
			toInsert.BIT_LKP_Id_Registro_caso__c = BIT_LKP_Id_Registro_caso;
		if(BIT_LKP_Id_Registro_contacto != '' )	
			toInsert.BIT_LKP_Id_Registro_contacto__c = BIT_LKP_Id_Registro_contacto;	
		if(BIT_LKP_Id_Registro_cuenta != '')
			toInsert.BIT_LKP_Id_Registro_cuenta__c = BIT_LKP_Id_Registro_cuenta;
		if(BIT_LKP_Id_Registro_factura != '' )	
			toInsert.BIT_LKP_Id_Registro_factura__c = BIT_LKP_Id_Registro_factura;
		if(BIT_LKP_Id_Registro_orden != '' )
			toInsert.BIT_LKP_Id_Registro_orden__c = BIT_LKP_Id_Registro_orden;	
		toInsert.BIT_TXT_Id_Secuencia_Indemnizables__c = BIT_TXT_Id_Secuencia_Indemnizables;
		toInsert.BIT_NUM_Orden_RGA__c = BIT_NUM_Orden_RGA;
		toInsert.BIT_NUM_Reintentos__c = BIT_NUM_Reintentos;
		Id idRecordTypeWS = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('INT_Bitacora__c:Servicio_Web');
		toInsert.recordTypeId = idRecordTypeWS;
		
		if (idBitacora != '')
			toInsert.Id = idBitacora;
		system.debug('prueba bitacora toInsert: '+toInsert);
		upsert toInsert;
		system.debug('prueba bitacora post upsert: '+toInsert);
		system.debug('>>>>>verBitacora: ' + toInsert);	
		return 	toInsert.Id;
	}
	
	/*Función a eliminar cuando se haya probado que funciona, tiene un campo mas, BIT_LKP_Id_Usuario__c*/
	public static String insertarBitacora(String BIT_TXT_Sistema_externo, String BIT_TXT_Error,String BIT_SEL_Estado, String BIT_SEL_Tipo_Integracion,String BIT_TXT_Nombre_Integracion,
			String BIT_TXT_Json, String BIT_TXT_EndPoint, String BIT_LKP_Id_Registro_caso, String BIT_LKP_Id_Registro_contacto, String BIT_LKP_Id_Registro_cuenta, String BIT_LKP_Id_Registro_factura,
			String BIT_LKP_Id_Registro_orden, String BIT_TXT_Id_Secuencia_Indemnizables, String BIT_LKP_Id_Usuario, Integer BIT_NUM_Orden_RGA,String idBitacora, Decimal BIT_NUM_Reintentos, String BIT_TXT_Method){
		INT_Bitacora__c toInsert = new INT_Bitacora__c();
		system.debug('prueba bitacora: '+idBitacora);
		system.debug('>>>>>BIT_TXT_EndPoint: ' + BIT_TXT_EndPoint);
		toInsert.BIT_TXT_Sistema_externo__c = BIT_TXT_Sistema_externo;
		toInsert.BIT_TXT_Error__c =BIT_TXT_Error;
		toInsert.BIT_SEL_Estado__c = BIT_SEL_Estado;
		toInsert.BIT_TXT_Nombre_Integracion__c = BIT_TXT_Nombre_Integracion;
		toInsert.BIT_SEL_Tipo_Integracion__c = BIT_SEL_Tipo_Integracion;
		toInsert.BIT_TXT_Json__c = BIT_TXT_Json;
		toInsert.BIT_TXT_Method__c = BIT_TXT_Method;
		toInsert.BIT_TXT_EndPoint__c = BIT_TXT_EndPoint;
		if(BIT_LKP_Id_Registro_caso != '')
			toInsert.BIT_LKP_Id_Registro_caso__c = BIT_LKP_Id_Registro_caso;
		if(BIT_LKP_Id_Registro_contacto != '' )	
			toInsert.BIT_LKP_Id_Registro_contacto__c = BIT_LKP_Id_Registro_contacto;	
		if(BIT_LKP_Id_Registro_cuenta != '')
			toInsert.BIT_LKP_Id_Registro_cuenta__c = BIT_LKP_Id_Registro_cuenta;
		if(BIT_LKP_Id_Registro_factura != '' )	
			toInsert.BIT_LKP_Id_Registro_factura__c = BIT_LKP_Id_Registro_factura;
		if(BIT_LKP_Id_Registro_orden != '' )
			toInsert.BIT_LKP_Id_Registro_orden__c = BIT_LKP_Id_Registro_orden;	
		if (BIT_LKP_Id_Usuario != '')
			toInsert.BIT_LKP_Id_Usuario__c = BIT_LKP_Id_Usuario;
		toInsert.BIT_TXT_Id_Secuencia_Indemnizables__c = BIT_TXT_Id_Secuencia_Indemnizables;
		toInsert.BIT_NUM_Orden_RGA__c = BIT_NUM_Orden_RGA;
		toInsert.BIT_NUM_Reintentos__c = BIT_NUM_Reintentos;
		Id idRecordTypeWS = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('INT_Bitacora__c:Servicio_Web');
		toInsert.recordTypeId = idRecordTypeWS;
		
		if (idBitacora != '')
			toInsert.Id = idBitacora;
		system.debug('prueba bitacora toInsert: '+toInsert);
		upsert toInsert;
		system.debug('prueba bitacora post upsert: '+toInsert);
		system.debug('>>>>>verBitacora: ' + toInsert);	
		return 	toInsert.Id;
	}
	/*Fin de función a eliminar*/

	public void generarLlamada(){
		Id id;
		system.debug('GENERAR LLAMADA');
		if(llamada == 'PRUEBA'){
			system.debug('prueba');
		}
		else if(llamada == 'SRV-PSI-057') {
			system.debug('Llamada a Callout Actualizar_Check_Robin');
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
			Util_Cuentas.actualizarRobinson(String.valueOf(id),compania,llamada,idBitacora);
		}
		else if(llamada == 'SRV-PSI-071') {
			system.debug('Llamada a Callout Callout_ActualizaEmail');
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
				Util_Contacto.actualizarEmail(String.valueOf(id),compania,llamada,idBitacora,campoActualizado);
		}
		else if(llamada == 'SRV-PSI-058') {
			system.debug('Llamada a Callout Callout_ActualizaTelefono');
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
			Util_Contacto.actualizarTelefono(String.valueOf(id),compania,llamada,idBitacora,campoActualizado);
			
		}

		else if(llamada == label.FAC_Maestro_Clientes){
			//MAESTRO CLIENTES
			system.debug('+++++++Callout '+label.FAC_Maestro_Clientes);
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
            system.debug('los nulos estan aqui');
            system.debug(id);
            system.debug(label.FAC_Maestro_Clientes);
            system.debug('>>>>>verId: ' + id);
			Util_Facturador.facturarCliente(id,label.FAC_Maestro_Clientes);
		}else if(llamada == label.FAC_Maestro_Profesionales){
			//MAESTRO PROFESIONAL
			system.debug('+++++++Callout'+label.FAC_Maestro_Profesionales);
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
			system.debug('>>>>>verId: ' + id);
			Util_Facturador.facturarProfesional(id,label.FAC_Maestro_Profesionales);
		}else if(llamada == label.FAC_PreFactura){
			//PREFACTURA
			system.debug('+++++++Callout'+label.FAC_PreFactura);
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
			Util_Facturador.facturarPreFactura(id,label.FAC_PreFactura);
		}else if(llamada == Label.FAC_Eventos_a){
			//EVENTOS
			system.debug('+++++++Callout'+Label.FAC_Eventos_a);
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
			Util_Facturador.facturadorEventos(id,'SRV-PSI-097a');
		}else if(llamada == Label.FAC_Eventos_b){
			//ABONOS
			system.debug('+++++++Callout'+Label.FAC_Eventos_b);
			for (String fieldName : registroId.keySet()){
				id = fieldName;
				System.debug('field name is ' + fieldName);
			}
			Util_Facturador.facturadorAbonos(id,Label.FAC_Eventos_b);
		}else if(llamada == 'AgregarDirecciones'){
			Integer contador = 0;
			List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaAgregarDirec = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
			//if (!listCuentas.isEmpty()) {
				List<Account> listCuenta = Util_Cuentas.queryMapCuentaByCuentaPpalAndNotInType(cuentasPadre,new Set<String>{Label.CUE_TIPO_CONTABLE,Label.CUE_TIPO_OK_PYMES}).values();
				//for (List<Account> listCuenta : [SELECT Id, CUE_LKP_Cuenta_principal__c FROM Account WHERE CUE_LKP_Cuenta_principal__c IN :cuentasPadre AND Type != :Label.CUE_TIPO_CONTABLE AND Type != :Label.CUE_TIPO_OK_PYMES]) {
					for (Account a: listCuenta){
						contador++;
						Id padre = a.CUE_LKP_Cuenta_principal__c;
						Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC = new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c();
						dirLC.DLC_LKP_Linea_de_Contrato__c = mapaLineas.get(padre).Id;
						dirLC.DLC_LKP_Direccion_B2B_B2B2C__c = a.Id;
						dirLC.DLC_NUM_Servicios_restantes__c = mapaLineas.get(padre).LDC_NUM_Limite_de_servicios__c;
						listaAgregarDirec.add(dirLC);
					}
				//}
				try {
					insert listaAgregarDirec;
				}
				catch(Exception e){
					system.debug('***** EXCEPTION : ' + e);
				}	
			//}
		}else if(llamada == 'c2c'){
			List<Configuracion_VDN__mdt> conf = Util_Metadatos.getConfVDNMetadataByDevName(new Set<String>{'Rechazo_en_Confirmacion'}).values();
			//List<Configuracion_VDN__mdt> conf = [SELECT Distancia_prioridad__c, LoadId__c, ServiceId__c FROM Configuracion_VDN__mdt WHERE DeveloperName = 'Rechazo_en_Confirmacion'];
			if(!conf.isEmpty()){
				for(WorkOrder wo : listaWO){
					Callout_ClickToCall_RQ c2c = new Callout_ClickToCall_RQ();
					c2c.telefono = wo.OTR_TEL_Telefono_C2C__c;
					c2c.idCarga = Integer.valueOf(conf[0].LoadId__c);
					c2c.idServicio = Integer.valueOf(conf[0].ServiceId__c);
					c2c.fechaProgramada = wo.OTR_DAT_Fecha_Primera_Cita__c;
					c2c.dato1 = String.valueOf(wo.WorkOrderNumber);
					Callout_ClickToCall.Resultado res = new Callout_ClickToCall.Resultado();
					res =  Callout_ClickToCall.sendDatos(c2c);
				}
			}else{
				System.debug('@@@@Falta metadato para Click2Call en Util_Llamada_Externa');
			}
		}
	}
}