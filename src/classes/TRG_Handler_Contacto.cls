/**
  * Handler del Trigger TRG_Contacto.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Contacto {

	/**
	  * Tratamiento antes de insertar registros.
	  * 
	  * @param triggerNew: lista de contactos nuevos
	  */
	public static void tratamientoBeforeInsert(List<Contact> triggerNew){
		system.debug('>>>>> triggerNew : ' + triggerNew);
		generarIdentificadorContacto(triggerNew);

		// Si es el primer contacto de una cuenta: se marca el check de principal
		Set<Id> setIdsCuentas = new Set<Id>();
		for (Contact con : triggerNew) {
			if(con.AccountId != null){
				setIdsCuentas.add(con.AccountId);				
			}
		}
		system.debug('>>>>> setIdsCuentas : ' + setIdsCuentas);
		if(!setIdsCuentas.isEmpty()){
			Map<Id, Account> cuentas = Util_Cuentas.getMapCuentasById(setIdsCuentas);
			
			for (Contact con : triggerNew) {
				List<Contact> lstCont = cuentas.get(con.AccountId).contacts;
				if (!con.CON_CAS_Contacto_principal__c && lstCont.isEmpty()) {
					con.CON_CAS_Contacto_principal__c = true;
				}
			}
		}
		system.debug('>>>>> triggerNew : ' + triggerNew);
	}

	/**
	  * Tratamiento antes de actualizar registros.
	  * 
	  * @param triggerNew: lista de contactos a insertar
	  * @param triggerOldMap: lista de contactos antiguos
	  */
	public static void tratamientoBeforeUpdate(List<Contact> triggerNew, List<Contact> triggerOldMap){
		guardarAntiguoTelefono(triggerNew, triggerOldMap);
	}

	/**
	  * Tratamiento después de insertar registros.
	  * 
	  * @param triggerNew: lista de contactos a insertar
	  * @param triggerOldMap: mapa de registros antiguos de Contacto a partir del Id
	  * @param isUpdate: true si es una actualización, false en caso contrario
	  */
	public static void tratamientoAfterInsert(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap, Boolean isUpdate){
		checkContactoPrincipal(triggerNew, null, isUpdate, false);
		actualizarEmailContactosCuenta(triggerNew, triggerOldMap);
		system.debug('>>>>> triggerNew : ' + triggerNew);
		Util_Contacto.actualizarContactoPpalCuenta(triggerNew, triggerOldMap);
	}

	/**
	  * Tratamiento después de actualizar registros.
	  * 
	  * @param triggerNew: lista de contactos a insertar
	  * @param triggerOldMap: mapa de registros antiguos de Contacto a partir del Id
	  * @param isUpdate: true si es una actualización, false en caso contrario
	  */
	public static void tratamientoAfterUpdate(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap, Boolean isUpdate){
		checkContactoPrincipal(triggerNew, triggerOldMap, isUpdate, false);
		actualizarEmailContactosCuenta(triggerNew, triggerOldMap);
		actualizarTelefonosIR(triggerNew, triggerOldMap);
		Util_Contacto.actualizarContactoPpalCuenta(triggerNew, triggerOldMap);
	}

	/**
	  * Tratamiento después de borrar registrosr.
	  * 
	  * @param triggerOldMap: mapa de registros antiguos del objeto Contacto a partir del Id
	  */
	public static void tratamientoAfterDelete(Map<Id, Contact> triggerOldMap){
		checkContactoPrincipal(null, triggerOldMap, false, true);
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param listaConNuevos: [PENDIENTE]
	  * @param mapaConViejos: [PENDIENTE]
	  * @param isUpdate: true si es una actualización, false en caso contrario
	  * @param isDelete: true si es una eliminación, false en caso contrario
	  * 
	  */
	private static void checkContactoPrincipal(List<Contact> listaConNuevos, Map<Id, Contact> mapaConViejos, Boolean isUpdate, Boolean isDelete) {

		Set<Id> setIdsCuentas = new Set<Id>();

		if (isDelete) {
			for (Contact con : mapaConViejos.values()) {
				setIdsCuentas.add(con.AccountId);
			}
		}
		else {
			for (Contact con : listaConNuevos) {
				setIdsCuentas.add(con.AccountId);
			}
		}

		//PREV
		/*Map<Id, Account> cuentas = new Map<Id,Account>([
		                                                SELECT	Id, RecordTypeId, (SELECT Id, CON_CAS_Contacto_principal__c, AccountId FROM Contacts) FROM Account WHERE Id IN :setIdsCuentas]);
		*/
		//NEW
		Map<Id, Account> cuentas = Util_Cuentas.getMapCuentasById(setIdsCuentas);
		
		Map <Id, Account> cuentasActualizar = new Map <Id, Account>();
		Map <Id, Contact> contactosActualizar = new Map <Id, Contact>(); 
		
		if (isDelete) {
			//Si borramos un contacto principal de una cuenta, se marca como contacto principal el primer contacto existente de los pertenecientes a la cuenta
			//Se actualiza tanto el campo casilla del contacto como el campo lkp a contacto del objeto cuenta
			for (Contact con : mapaConViejos.values()) {
				if (cuentas.get(con.AccountId) != null && con.CON_CAS_Contacto_principal__c) {
					List<Contact> lstCont = cuentas.get(con.AccountId).contacts;
					Account cuentaUpdate = cuentas.get(con.AccountId);
					if (!lstCont.isEmpty()) {
						lstCont.get(0).CON_CAS_Contacto_principal__c = true;
						contactosActualizar.put(lstCont.get(0).Id, lstCont.get(0));
						cuentaUpdate.CUE_LKP_Contacto_principal__c = lstCont.get(0).Id;
						cuentasActualizar.put(con.AccountId, cuentaUpdate);
					}
				}				
			}
		}
		else {
			//Si cambiamos un contacto principal de una cuenta marcando la casilla del nuevo contacto principal, se desmarca la casilla del contacto principal anterior
			//Se actualiza tanto el campo casilla del contacto como el campo lkp a contacto del objeto cuenta
			for (Contact con : listaConNuevos) {
				if (cuentas.get(con.AccountId) != null) {
					List<Contact> lstCont = cuentas.get(con.AccountId).contacts;
					if ((!isUpdate && con.CON_CAS_Contacto_principal__c) || (isUpdate && con.CON_CAS_Contacto_principal__c != mapaConViejos.get(con.Id).CON_CAS_Contacto_principal__c && con.CON_CAS_Contacto_principal__c)){
						for (Contact conCuenta : lstCont){
							Account cuentaUpdate = cuentas.get(conCuenta.AccountId);
							if (conCuenta.Id!= con.Id){
								conCuenta.CON_CAS_Contacto_principal__c = false;
								Util_variablesGlobales.contactoPrincipal = false;
							}
							else {
								conCuenta.CON_CAS_Contacto_principal__c = con.CON_CAS_Contacto_principal__c;
								Util_variablesGlobales.contactoPrincipal = true;
								cuentaUpdate.CUE_LKP_Contacto_principal__c = conCuenta.Id;
								cuentasActualizar.put(con.AccountId, cuentaUpdate);
							}							
							if (conCuenta != null) {
								contactosActualizar.put(conCuenta.Id, conCuenta); 
							}
						}
					}	
					//Regla de validación para no dejar desmarcar un contactoPrincipal
					else if (isUpdate && con.CON_CAS_Contacto_principal__c != mapaConViejos.get(con.Id).CON_CAS_Contacto_principal__c && !con.CON_CAS_Contacto_principal__c){
						if (Util_variablesGlobales.contactoPrincipal){
							con.CON_CAS_Contacto_principal__c.addError('No se permite desmarcar un contacto principal. Para ello, seleccione otro contacto como principal.'); 
						}
					}
				}
			}
		}

		Baipas.establecerVariableControl();
		update cuentasActualizar.values();
		update contactosActualizar.values();
		Baipas.deshabilitarVariableControl();
	}


	/*
	 *  Esta funcion genera un identificador del contacto si el campo CON_TXT_Identificador__c está vacío
	 *  @param List<Contact> listaConNuevos -   Lista de contactos del trigger.new 
	 *  
	 **/
	private static void generarIdentificadorContacto(List<Contact> listaConNuevos){
		//Recorro la lista
		for(Contact con : listaConNuevos){
			if(con.CON_TXT_Identificador__c == null){
				//Si no tiene identificador, le paso de identificador el tiempo en milisegundos del momento actual
				con.CON_TXT_Identificador__c = 'RP'+String.valueOf(System.now().getTime());
			}
		}
	}

	/*
	 *	Esta funcion guarda los numeros de telefono del contacto si se actualiza 
	 *	@param List<Contact> listaNuevos	-	Lista de contactos del trigger.new 
	 * 	@param List<Contact> listaViejos	-	Lista de contactos del trigger.old
	 *	
	 **/
	private static void guardarAntiguoTelefono(List<Contact> listaNuevos, List<Contact> listaViejos){

		Map<Id,String> mapaMobileViejos = new Map<Id,String>();
		Map<Id,String> mapaPhoneViejos = new Map<Id,String>();
		Map<Id,String> mapaHomeViejos = new Map<Id,String>();
		for(Contact con : listaViejos){
			mapaMobileViejos.put(con.Id,con.MobilePhone);
			mapaPhoneViejos.put(con.Id,con.Phone);
			mapaHomeViejos.put(con.Id,con.HomePhone); 				
		}
		for(Contact contactoNuevo: listaNuevos){ 			
			if(contactoNuevo.MobilePhone !=null 
					&& contactoNuevo.MobilePhone != mapaMobileViejos.get(contactoNuevo.Id)){ 				 
				contactoNuevo.CON_TEL_Telefono_Movil_Anterior__c=mapaMobileViejos.get(contactoNuevo.Id);

			}
			if(contactoNuevo.Phone !=null 
					&& contactoNuevo.Phone != mapaPhoneViejos.get(contactoNuevo.Id)){ 				 
				contactoNuevo.CON_TEL_Telefono_Anterior__c=mapaPhoneViejos.get(contactoNuevo.Id);
			}
			if(contactoNuevo.HomePhone !=null 
					&& contactoNuevo.HomePhone != mapaHomeViejos.get(contactoNuevo.Id)){ 				 
				contactoNuevo.CON_TEL_Telefono_Adicional_Anterior__c=mapaHomeViejos.get(contactoNuevo.Id);
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  */
	public without sharing class actPhone{
		public String id = '';
		public String phone = '';
		public String dni = '';
	}	

	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerOldMap: [PENDIENTE]
	  * 
	  */
	private static void actualizarTelefonosIR(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap){
		List<actPhone> phoneList = new List<actPhone>();
		actPhone datos = new actPhone();
		for(Contact cont : triggerNew){
			if(triggerOldMap == null || cont.MobilePhone != triggerOldMap.get(cont.Id).MobilePhone){
				datos = new actPhone();
				datos.id = cont.Id;
				datos.phone = cont.MobilePhone;
				phoneList.add(datos);
			}
			if(cont.Phone != triggerOldMap.get(cont.Id).Phone){
				datos = new actPhone();
				datos.id = cont.Id;
				datos.Phone = cont.Phone;
				phoneList.add(datos);
			}
			if(cont.HomePhone != triggerOldMap.get(cont.Id).HomePhone){
				datos = new actPhone();
				datos.id = cont.Id;
				datos.Phone = cont.HomePhone;
				phoneList.add(datos);
			}			
		}
		TRG_Handler_MovimientoIR.actualizaTelefono(phoneList);	
	}


	/*
	 * 
	 * Método que encola un proceso batch encargado de enviar a un sistema tercero los teléfonos
	 *  de contacto actualizados para clientes que no son Robinson
	 *
	 *  @ triggerNewMap: Mapa de valores para cada Contacto insertado (valores nuevos)
	 *  @ triggerNew: lista de Contactos con valores nuevos
	 *  @ triggerOldMap: antiguo Mapa de valores para contactos (id,Contact)
	 *  @ triggerOld: lista de Contactos antiguos
	 */
	public static void actualizarTelefono (Map<Id,Contact> triggerNewMap, List<Contact> triggerNew, 
			Map<Id,Contact> triggerOldMap, List<Contact> triggerOld){

		String nombreIntegracion = 'SRV-PSI-058';
		String identificador ='1999';
		
		//PREV: List<Account> cuenta = [SELECT Id, CUE_CAS_Robinson__c FROM Account WHERE Id =: triggerNew[0].AccountId AND CUE_CAS_Robinson__c = false];
		//NEW:
		List<Account> cuenta = Util_Cuentas.queryMapCuentaByIdAndCheckRobinson(new Set<Id>{triggerNew[0].AccountId}, false).values();
		
		if (cuenta == null || cuenta.size() == 0) {
			return;
		}
		List<ServiceContract> listaCompaniaCuenta = Util_Poliza_Contrato.queryPolizaByAccountIdAndCompania(new Set<Id>{triggerNew[0].AccountId},new Set<String>{'1999'}).values();
		/*List<ServiceContract> listaCompaniaCuenta = [SELECT Id, POL_LKP_Compania__r.CUE_TXT_Identificador__c FROM ServiceContract WHERE AccountId =: triggerNew[0].AccountId 
			AND POL_LKP_Compania__r.CUE_TXT_Identificador__c = '1999'];*/
		
		for(Contact contacto: triggerNew ){
			if(trigger.isInsert){ //AFTER INSERT de Contacto
				
				Map<Id,String> mapaDatos = new Map<Id,String>();
				mapaDatos.put(contacto.Id,'Contact');

				Map <String,String> campoActualizado = new Map <String,String>();
				String idBitac = '';

				if (contacto.MobilePhone != null){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,'Ensura - '+nombreIntegracion + ' Actualizar Telefono' ,
							'', '','',String.valueOf(contacto.Id), '','',
							'', '',0,'', 0.0,Label.Callout_PUT);
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('MobilePhone','1');

					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarTfno = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado );
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarTfno);
				}
				if(contacto.Phone != null){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,'Ensura - '+nombreIntegracion + ' Actualizar Telefono',
							'', '','',String.valueOf(contacto.Id), '','',
							'', '',0,'', 0.0, Label.Callout_PUT);
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('Phone','1');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarTfno = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado );
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarTfno);
				}
				if(contacto.HomePhone != null){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,'Ensura - '+nombreIntegracion + ' Actualizar Telefono' ,
							'', '','',String.valueOf(contacto.Id), '','',
							'', '',0,'', 0.0, Label.Callout_PUT);
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('HomePhone','1');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarTfno = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado );
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarTfno);
				}
				
			}
			if(trigger.isUpdate){ //AFTER UDPATE

				Map<Id,String> mapaDatos = new Map<Id,String>();
				mapaDatos.put(contacto.Id,'Contact');

				Map <String,String> campoActualizado = new Map <String,String>();
				String idBitac = '';

				if (triggerNewMap.get(contacto.Id).MobilePhone!=null && triggerNewMap.get(contacto.Id).MobilePhone!='' && !(contacto.MobilePhone.equals(triggerOldMap.get(contacto.Id).MobilePhone)) ){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,'Ensura - '+nombreIntegracion + ' Actualizar Telefono' ,
							'', '','',String.valueOf(contacto.Id), '','',
							'', '',0,'', 0.0, '');
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('MobilePhone','2');
					
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarTfno = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado );
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarTfno);
				}
				if(triggerNewMap.get(contacto.Id).Phone!=null && triggerNewMap.get(contacto.Id).Phone!='' && !(contacto.Phone.equals(triggerOldMap.get(contacto.Id).Phone))) {
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,'Ensura - '+nombreIntegracion + ' Actualizar Telefono' ,
							'', '','',String.valueOf(contacto.Id), '','',
							'', '',0,'', 0.0,'');
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('Phone','2');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarTfno = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado );
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarTfno);
				}
				if(triggerNewMap.get(contacto.Id).HomePhone!=null && triggerNewMap.get(contacto.Id).HomePhone!='' && !(contacto.HomePhone.equals(triggerOldMap.get(contacto.Id).HomePhone))){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,'Ensura - '+nombreIntegracion + ' Actualizar Telefono' ,
							'', '','',String.valueOf(contacto.Id), '','',
							'', '',0,'', 0.0,'');
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('HomePhone','2');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarTfno = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado );
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarTfno);
				}
				
			}
		}//End for
	}	


	/*
	 *  Método que encola un proceso batch encargado de enviar a un sistema tercero información de email que 
	 *  cambian o se crean para clientes no Robinson  
	 *
	 *  @ triggerNewMap: Mapa de valores para cada Contacto insertado (valores nuevos)
	 *  @ triggerNew: lista de Contactos con valores nuevos
	 *  @ triggerOldMap: antiguo Mapa de valores para contactos (id,Contact)
	 *  @ triggerOld: lista de Contactos antiguos
	 */
	public static void actualizarEmailTomadorEnsura (Map<Id,Contact> triggerNewMap, List<Contact> triggerNew, 
			Map<Id,Contact> triggerOldMap, List<Contact> triggerOld){

		String nombreIntegracion = 'SRV-PSI-071';
		String identificador ='1999';
		
		//PREV: List<Account> cuenta = [SELECT Id, CUE_CAS_Robinson__c FROM Account WHERE Id =: triggerNew[0].AccountId AND CUE_CAS_Robinson__c = false];
		//NEW:
		List<Account> cuenta = Util_Cuentas.queryMapCuentaByIdAndCheckRobinson( new Set <Id>{triggerNew[0].AccountId},false).values();
		//END_NEW
		if (cuenta == null || cuenta.size() == 0) {
			return;
		}
		
		//PREV: List<ServiceContract> listaCompaniaCuenta = [SELECT Id, POL_LKP_Compania__r.CUE_TXT_Identificador__c FROM ServiceContract WHERE AccountId =: triggerNew[0].AccountId 
		//	AND POL_LKP_Compania__r.CUE_TXT_Identificador__c = '1999'];
		//NEW:
		List<ServiceContract> listaCompaniaCuenta = Util_Poliza_Contrato.queryPolizaByAccountIdAndCompania(new Set<Id>{triggerNew[0].AccountId}, new Set <String> {'1999'} ).values();
		//END_NEW
		
		for(Contact contacto: triggerNew ){
			if(trigger.isInsert){ //AFTER INSERT de Contacto
				
				Map<Id,String> mapaDatos = new Map<Id,String>();
				mapaDatos.put(contacto.Id,'Contact');

				String idBitac = '';
				Map <String,String> campoActualizado = new Map <String,String>();

				if (contacto.Email != null){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,nombreIntegracion ,
							'', '','',String.valueOf(contacto.Id), '','','', '',0,'', 0.0,'');
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('Email','1');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarEmail = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado);
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarEmail);
					system.debug('Callout ENQUEUED: <isINSERT : Email> EmailRobinson');
				}
				if(contacto.CON_EMA_Email_Adicional__c != null){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,nombreIntegracion ,
							'', '','',String.valueOf(contacto.Id), '','','', '',0,'', 0.0,'');
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('CON_EMA_Email_Adicional__c','1');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarEmail = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado);
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarEmail);
					system.debug('Callout ENQUEUED: <isINSERT : CON_EMA_Email_Adicional__c> EmailRobinson');
				}
				system.debug('Email Ensura INSERT ');
			}
			if(trigger.isUpdate){ //TRAS UPDATE
				Map<Id,String> mapaDatos = new Map<Id,String>();
				mapaDatos.put(contacto.Id,'Contact');	

				String idBitac = '';
				Map <String,String> campoActualizado = new Map <String,String>();

				if (triggerNewMap.get(contacto.Id).Email!=null && triggerNewMap.get(contacto.Id).Email!=''  &&! (triggerNewMap.get(contacto.Id).Email.equals(triggerOldMap.get(contacto.Id).Email)) ){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,nombreIntegracion ,
							'', '','',String.valueOf(contacto.Id), '','','', '',0,'', 0.0,'');
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('Email','2');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarEmail = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado);
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarEmail);
					system.debug('Callout ENQUEUED: <isUPDATE : Email> EmailRobinson');
				}
				if (triggerNewMap.get(contacto.Id).CON_EMA_Email_Adicional__c!=null && triggerNewMap.get(contacto.Id).CON_EMA_Email_Adicional__c!=''   && ! (triggerNewMap.get(contacto.Id).CON_EMA_Email_Adicional__c.equals(triggerOldMap.get(contacto.Id).CON_EMA_Email_Adicional__c)) ){
					//Insertamos la bitácora con los datos que conocemos antes de intentar el callout
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,nombreIntegracion ,
							'', '','',String.valueOf(contacto.Id), '','','', '',0,'', 0.0,'');
					//Definimos nombre del campo que ha sido actualizado
					campoActualizado.put('CON_EMA_Email_Adicional__c','2');
					//Creamos el objeto que implementa Queueable
					Util_Llamada_Externa batchActualizarEmail = new Util_Llamada_Externa(mapaDatos,'Ensura',nombreIntegracion,idBitac,campoActualizado);
					//Encolamos el proceso batch
					System.enqueueJob(batchActualizarEmail);
					system.debug('Callout ENQUEUED: <isUPDATE : CON_EMA_Email_Adicional__c> EmailRobinson');
				}

			}
			
		}//End for2

	}




	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerOldMap: [PENDIENTE]
	  * 
	  */
	private static void actualizarEmailContactosCuenta(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap){
		Set<Id> idsCuenta = new Set<Id>();
		for(Contact cont : triggerNew){
			Boolean contPropagar = false;
			Boolean hayCambios = false;
			if(cont.CON_SEL_Tipo_Programa__c != null
					&& cont.CON_SEL_Tipo_Programa__c.contains('INFORMES')){
				contPropagar = true;
			}

			if(triggerOldMap == null
					|| cont.Email != triggerOldMap.get(cont.Id).Email){
				hayCambios = true;
			}

			if(contPropagar
					&& hayCambios
					&& cont.AccountId != null
					&& !idsCuenta.contains(cont.AccountId)){
				idsCuenta.add(cont.AccountId);
			}
		}

		Map<Id, Account> mapaCuentasPropagar;

		if(!idsCuenta.isEmpty()){
			/*PREV:  mapaCuentasPropagar = new Map<Id, Account>([
			                                            SELECT	CUE_EMA_Correo_Contacto_Informes__c
			                                            FROM	Account
			                                            WHERE	Id IN :idsCuenta]);
			                                      */
			//NEW 
			mapaCuentasPropagar = Util_Cuentas.getMapCuentasById(idsCuenta);
		}

		if(mapaCuentasPropagar != null){

			List<Account> listaCuentasAct = new List<Account>();

			for(Contact cont : triggerNew){
				Account cuentaPropagar = mapaCuentasPropagar.get(cont.AccountId);
				if(cuentaPropagar != null){
					if(cont.CON_SEL_Tipo_Programa__c != null
							&& cont.CON_SEL_Tipo_Programa__c.contains('INFORMES')
							&& cuentaPropagar.CUE_EMA_Correo_Contacto_Informes__c != cont.Email){
						cuentaPropagar.CUE_EMA_Correo_Contacto_Informes__c = cont.Email;
						listaCuentasAct.add(cuentaPropagar);
					}
				}
			}

			update listaCuentasAct;
		}
	}
}