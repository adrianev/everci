/**
 * Clase de funciones auxiliares relativas a los Contactos.
 * 
 * @author EVERIS
 * @version 1.0
 *
 */
public without sharing class Util_Contacto {

	/**
	 * Devuelve los Contactos filtrados por el identificador externo de Cuenta y el Tipo de Programa y con Email distinto de nulo.
	 *
	 * @param setIdentificadorCuenta: conjunto de identificadores externos de Cuenta
	 * @param tipoPrograma: tipo de programa
	 *
	 * @return mapa que contiene Contactos encontrados
	 */
	public static Map<Id,Contact> getContactByIdExtCueAndTipoProg(Set<String> setIdentificadorCuenta, String tipoPrograma){
		Map<Id,Contact> mapa = new Map<Id,Contact>();
		if(setIdentificadorCuenta != null && !setIdentificadorCuenta.isEmpty() && tipoPrograma != null){
			for(List<Contact> lista:[SELECT Id,
											AccountId,
											LastModifiedBy.Username,
											CON_TXT_Codigo_Postal__c,
											CON_CAS_Contacto_principal__c,
											CON_EMA_Email_Adicional__c,
											CON_SEL_Departamento__c,
											CON_TXT_Identificador__c,
											CON_LKP_Procedencia__c,
											CON_SEL_Provincia__c,
											CON_TEL_Telefono_Adicional_Anterior__c,
											CON_TEL_Telefono_Anterior__c,
											CON_TEL_Telefono_Movil_Anterior__c,
											CON_SEL_Tipo_Programa__c,
											CON_CAS_ContactoDummy__c,
											FirstName,
											LastName,
											Email,
											MobilePhone,
											HomePhone,
											Phone
									 FROM Contact
									 WHERE Account.CUE_TXT_Identificador__c = :setIdentificadorCuenta
									 AND CON_SEL_Tipo_Programa__c INCLUDES (:tipoPrograma)
									 AND Email != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Contactos filtrados por el identificador externo de Cuenta y con Email distinto de nulo.
	 *
	 * @param setIdentificadorCuenta: conjunto de identificadores externos de Cuenta
	 *
	 * @return mapa que contiene Contactos encontrados
	 */
	public static Map<Id,Contact> getContactByIdExtCue(Set<String> setIdentificadorCuenta){
		Map<Id,Contact> mapa = new Map<Id,Contact>();
		if(setIdentificadorCuenta != null && !setIdentificadorCuenta.isEmpty()){
			for(List<Contact> lista:[SELECT Id,
											AccountId,
											CON_TXT_Codigo_Postal__c,
											CON_CAS_Contacto_principal__c,
											CON_EMA_Email_Adicional__c,
											CON_SEL_Departamento__c,
											CON_TXT_Identificador__c,
											CON_LKP_Procedencia__c,
											CON_SEL_Provincia__c,
											CON_TEL_Telefono_Adicional_Anterior__c,
											CON_TEL_Telefono_Anterior__c,
											CON_TEL_Telefono_Movil_Anterior__c,
											CON_SEL_Tipo_Programa__c,
											CON_CAS_ContactoDummy__c,
											FirstName,
											LastName,
											Email,
											MobilePhone,
											HomePhone,
											Phone
									 FROM Contact
									 WHERE Account.CUE_TXT_Identificador__c = :setIdentificadorCuenta
									 AND Email != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Contactos filtrados por los IDs de Cuenta y el Tipo de Programa y con Email distinto de nulo.
	 *
	 * @param setIdCuenta: conjunto de IDs de Cuenta
	 * @param tipoPrograma: tipo de programa
	 *
	 * @return mapa que contiene Contactos encontrados
	 */
	public static Map<Id,Contact> getContactByCuentaAndTipoProg(Set<Id> setIdCuenta, String tipoPrograma){
		Map<Id,Contact> mapa = new Map<Id,Contact>();
		if(setIdCuenta != null && !setIdCuenta.isEmpty() && tipoPrograma != null){
			for(List<Contact> lista:[SELECT Id,
											AccountId,
											CON_TXT_Codigo_Postal__c,
											CON_CAS_Contacto_principal__c,
											CON_EMA_Email_Adicional__c,
											CON_SEL_Departamento__c,
											CON_TXT_Identificador__c,
											CON_LKP_Procedencia__c,
											CON_SEL_Provincia__c,
											CON_TEL_Telefono_Adicional_Anterior__c,
											CON_TEL_Telefono_Anterior__c,
											CON_TEL_Telefono_Movil_Anterior__c,
											CON_SEL_Tipo_Programa__c,
											CON_CAS_ContactoDummy__c,
											FirstName,
											LastName,
											Email,
											MobilePhone,
											HomePhone,
											Phone
									 FROM Contact
									 WHERE AccountId = :setIdCuenta
									 AND CON_SEL_Tipo_Programa__c INCLUDES (:tipoPrograma)
									 AND Email != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Contactos filtrados por los IDs de Cuenta y el Tipo de Programa y con Email distinto de nulo.
	 *
	 * @param setIdCuenta: conjunto de IDs de Cuenta
	 *
	 * @return mapa que contiene Contactos encontrados
	 */
	public static Map<Id,Contact> getContactByCuenta(Set<Id> setIdCuenta){
		Map<Id,Contact> mapa = new Map<Id,Contact>();
		if(setIdCuenta != null && !setIdCuenta.isEmpty()){
			for(List<Contact> lista:[SELECT Id,
											AccountId,
											CON_TXT_Codigo_Postal__c,
											CON_CAS_Contacto_principal__c,
											CON_EMA_Email_Adicional__c,
											CON_SEL_Departamento__c,
											CON_TXT_Identificador__c,
											CON_LKP_Procedencia__c,
											CON_SEL_Provincia__c,
											CON_TEL_Telefono_Adicional_Anterior__c,
											CON_TEL_Telefono_Anterior__c,
											CON_TEL_Telefono_Movil_Anterior__c,
											CON_SEL_Tipo_Programa__c,
											CON_CAS_ContactoDummy__c,
											FirstName,
											LastName,
											Email,
											MailingAddress,
											MobilePhone,
											HomePhone,
											Name,
											Phone
									 FROM Contact
									 WHERE AccountId = :setIdCuenta
									 AND Email != null]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve los Contactos filtrados por los IDs de Cuenta y el Tipo de Programa.
	 *
	 * @param setIdCuenta: conjunto de IDs de Cuenta
	 *
	 * @return mapa que contiene Contactos encontrados
	 */
	public static Map<Id,Contact> getContactByAccountId(Set<Id> setIdCuenta){
		Map<Id,Contact> mapa = new Map<Id,Contact>();
		if(setIdCuenta != null && !setIdCuenta.isEmpty()){
			for(List<Contact> lista:[SELECT Id,
											AccountId,
											Account.CUE_TXT_Numero_Documento__c,
											Account.CUE_TXT_Nombre__c,
											Account.Phone,
											Account.CUE_TXT_SegundoApellido__c,
											Account.CUE_TXT_PrimerApellido__c,
											CON_TXT_Codigo_Postal__c,
											CON_CAS_Contacto_principal__c,
											CON_EMA_Email_Adicional__c,
											CON_SEL_Departamento__c,
											CON_TXT_Identificador__c,
											CON_LKP_Procedencia__c,
											CON_SEL_Provincia__c,
											CON_TEL_Telefono_Adicional_Anterior__c,
											CON_TEL_Telefono_Anterior__c,
											CON_TEL_Telefono_Movil_Anterior__c,
											CON_SEL_Tipo_Programa__c,
											CON_CAS_ContactoDummy__c,
											FirstName,
											LastName,
											Email,
											MailingAddress,
											MobilePhone,
											HomePhone,
											Name,
											Phone
									 FROM Contact
									 WHERE AccountId = :setIdCuenta]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

    /**
	* Método encargado de preparar los datos y construir el body del Callout que comunica a Ensura la actualización del teléfono de un Contacto asociado a una cuenta de Membership con Robinson =false
	* @param idContacto: identificador en Salesforce de un contacto asociado a una cuenta
	* @param Compania: nombre de la compañía a la que se realiza el callout ('Ensura''')
	* @param idBitacora: id de la bitácora
	* @param campoActualizado: mapa <String,String> que contiene una tupla (Nombre del campo teléfono modificado, 1 ó 2 -insert o update-);  se realiza un callout por teléfono cambiado o insertado; 
	*
	* @return void
	*/
	public static void actualizarTelefono(String idContacto, String Compania, String nombreIntegracion, String idBitacora, Map<String,String> campoActualizado) {
		Callout_ActualizaTelefono_RQ datos = new Callout_ActualizaTelefono_RQ();
		
		String telefonoAActualizar ;
		Integer insertOUpdate = 0;
		for (String campo : campoActualizado.keySet()){
			telefonoAActualizar = campo ; //Extraemos qué Teléfono es el que se ha actualizado
		}	
		for (String valorOperacion : campoActualizado.values()){
			insertOUpdate = integer.valueOf(valorOperacion); // --> Extraemos 1 o 2 dependiendo de si es insert o update	
		}
		Contact contacto = getContactById(new Set<Id>{idContacto}).values().get(0);
        system.debug(contacto + ' contacto ');
		/*Contact contacto = [SELECT Id,MobilePhone,Phone,HomePhone,CON_TEL_Telefono_Movil_Anterior__c, LastModifiedBy.Username, Account.CUE_TXT_Identificador__c,
	        CON_TEL_Telefono_Anterior__c,CON_TEL_Telefono_Adicional_Anterior__c, AccountId FROM Contact WHERE Id =: idContacto ][0];*/
		ServiceContract sC = Util_Poliza_Contrato.queryPolizaByAccountAndEnsuraNotNull(new Set<Id>{contacto.AccountId}).values().get(0);
		//ServiceContract sC = [SELECT Id,POL_TXT_Cliente_Ensura__c FROM ServiceContract WHERE AccountId =: contacto.AccountId AND POL_TXT_Cliente_Ensura__c != null][0];
        system.debug(sC + ' que devuelve la query');
		
			datos.identificadorCompania = sC.POL_TXT_Cliente_Ensura__c ;
			system.debug('---- SVV. Identificador compañia: ' + datos.identificadorCompania);

			if(telefonoAActualizar == 'MobilePhone'){//MobilePhone-->CON_TEL_Telefono_Movil_Anterior__c
				datos.nuevoValorTelefono = contacto.MobilePhone;
				datos.anteriorValorTelefono = contacto.CON_TEL_Telefono_Movil_Anterior__c;
			}
			if(telefonoAActualizar == 'Phone' ){//Phone-->CON_TEL_Telefono_Anterior__c
				datos.nuevoValorTelefono = contacto.Phone;
				datos.anteriorValorTelefono = contacto.CON_TEL_Telefono_Anterior__c;
			}
			if(telefonoAActualizar == 'HomePhone'){//HomePhone-->CON_TEL_Telefono_Adicional_Anterior__c
				datos.nuevoValorTelefono = contacto.HomePhone;
				datos.anteriorValorTelefono = contacto.CON_TEL_Telefono_Adicional_Anterior__c;
			}

			datos.usuario = contacto.LastModifiedBy.UserName ;
	     	datos.tipoCorreccion = insertOUpdate;
		        
        String body = Callout_ActualizaTelefono.construirBody(datos); 
		system.debug('------ body util'+body);
		//Se realiza la llamada al sistema tercero en sí misma:
		Callout_ActualizaTelefono.updateDatos(body,nombreIntegracion,idBitacora,idContacto,datos.identificadorCompania,datos.nuevoValorTelefono,datos.anteriorValorTelefono,datos.usuario,datos.tipoCorreccion);
	}
	
	/**
	 * Obtiene un contacto a partir del ID de contacto
	 * 
	 * @param idContacto ID de contacto a buscar
	 * @param idCuenta ID de cuenta a buscar
	 * @return lista de contactos que coinciden con el ID
	 */
	/*public static List<Contact> queryContacto(Id idContacto, Id idCuenta){
		List<Contact> listaContactos = new List<Contact>();
		if(idContacto != null || idCuenta != null){
			String sentenciaContacto = 'SELECT Id,';
			sentenciaContacto += ' AccountId,';
			sentenciaContacto += ' CON_TXT_Codigo_Postal__c,';
			sentenciaContacto += ' CON_CAS_Contacto_principal__c,';
			sentenciaContacto += ' CON_EMA_Email_Adicional__c,';
			sentenciaContacto += ' CON_SEL_Departamento__c,';
			sentenciaContacto += ' CON_TXT_Identificador__c,';
			sentenciaContacto += ' CON_LKP_Procedencia__c,';
			sentenciaContacto += ' CON_SEL_Provincia__c,';
			sentenciaContacto += ' CON_TEL_Telefono_Adicional_Anterior__c,';
			sentenciaContacto += ' CON_TEL_Telefono_Anterior__c,';
			sentenciaContacto += ' CON_TEL_Telefono_Movil_Anterior__c,';
			sentenciaContacto += ' CON_SEL_Tipo_Programa__c,';
			sentenciaContacto += ' FirstName,';
			sentenciaContacto += ' LastName,';
			sentenciaContacto += ' Email,';
			sentenciaContacto += ' MobilePhone,';
			sentenciaContacto += ' HomePhone,';
			sentenciaContacto += ' Phone';
			sentenciaContacto += ' FROM Contact';
			if(idContacto != null){
				sentenciaContacto += ' WHERE Id = \'' + idContacto + '\'';
			}
			else {
				sentenciaContacto += ' WHERE AccountId = \'' + idCuenta + '\'';
			}

			listaContactos = database.query(sentenciaContacto);
		}
		return listaContactos;
	}*/

	/**
	 * Obtiene un contacto a partir de un conjunto de IDs de contactos o cuentas
	 * 
	 * @param setIdContacto IDs de contactos a buscar
	 * @param setIdCuenta IDs de cuentas a buscar
	 * @return lista de contactos que coinciden con el ID
	 */
	/*public static List<Contact> queryContacto(Set<Id> setIdContacto, Set<Id> setIdCuenta){
		List<Contact> listaContactos = new List<Contact>();
		if((setIdContacto != null && !setIdContacto.isEmpty()) || (setIdCuenta != null && !setIdCuenta.isEmpty())){
			String sentenciaContacto = 'SELECT Id,';
			sentenciaContacto += ' AccountId,';
			sentenciaContacto += ' CON_TXT_Codigo_Postal__c,';
			sentenciaContacto += ' CON_CAS_Contacto_principal__c,';
			sentenciaContacto += ' CON_EMA_Email_Adicional__c,';
			sentenciaContacto += ' CON_SEL_Departamento__c,';
			sentenciaContacto += ' CON_TXT_Identificador__c,';
			sentenciaContacto += ' CON_LKP_Procedencia__c,';
			sentenciaContacto += ' CON_SEL_Provincia__c,';
			sentenciaContacto += ' CON_TEL_Telefono_Adicional_Anterior__c,';
			sentenciaContacto += ' CON_TEL_Telefono_Anterior__c,';
			sentenciaContacto += ' CON_TEL_Telefono_Movil_Anterior__c,';
			sentenciaContacto += ' CON_SEL_Tipo_Programa__c,';
			sentenciaContacto += ' FirstName,';
			sentenciaContacto += ' LastName,';
			sentenciaContacto += ' Email,';
			sentenciaContacto += ' MobilePhone,';
			sentenciaContacto += ' HomePhone,';
			sentenciaContacto += ' Phone';
			sentenciaContacto += ' FROM Contact';
			if(setIdContacto != null){
				sentenciaContacto += ' WHERE Id IN :setIdContacto';
			}
			else {
				sentenciaContacto += ' WHERE AccountId IN :setIdCuenta';
			}
 
			listaContactos = database.query(sentenciaContacto);
		}
		return listaContactos;
	}*/
	
	
/**
 * Devuelve un mapa de Contactos a partir de un conjunto de IDs.
 * 
 * @param setId IDs a buscar
 * @return mapa de contactos encontrados
 */
public static Map<Id, Contact> getContactById(Set<Id> setId){
	Map<Id, Contact> mapaContactos = new Map<Id, Contact>();
	if(setId != null && !setId.isEmpty()){
		for(List<Contact> listaContactos : [SELECT Id,
												   AccountId,
												   Account.CUE_TXT_Numero_Documento__c,
												   CON_TXT_Codigo_Postal__c,
												   CON_CAS_Contacto_principal__c,
												   CON_EMA_Email_Adicional__c,
												   CON_SEL_Departamento__c,
												   CON_TXT_Identificador__c,
												   CON_LKP_Procedencia__c,
												   CON_SEL_Provincia__c,
												   CON_TEL_Telefono_Adicional_Anterior__c,
												   CON_TEL_Telefono_Anterior__c,
												   CON_TEL_Telefono_Movil_Anterior__c,
												   CON_SEL_Tipo_Programa__c,
												   CON_CAS_ContactoDummy__c,
												   FirstName,
												   LastName,
												   Name,
												   Email,
												   MailingAddress,
												   MobilePhone,
												   HomePhone,
												   Account.RecordTypeId,
												   Account.CUE_TXT_Identificador__c,
												   Phone,
												   LastModifiedBy.Username
											FROM Contact
											WHERE Id IN :setId]){
			mapaContactos.putAll(listaContactos);
		}
	}
	return mapaContactos;
}
	
	/**
	* Método encargado de parsear y extraer los datos necesarios para realizar el callout de actualización de un valor de un campo Email a Ensura cuando el contacto modificado está asociado a una cuenta de Membership y además tiene el campo Robinson a false.
	* @param idContacto: identificador en Salesforce del contacto que ha sido actualizado/insertado y de cuyo email se quiere informar a Ensura.
	* @param Compania: nombre de la compañia ('Ensura')
	* @param nombreIntegracion: identificador de la integración 'SRV-PSI-71'
	* @param idBitacora: identificador de la bitácora sobre la que se modifica el estado del callout.
	* 
	* @return void: no se devuelve nada
	*/
	public static void actualizarEmail(String idContacto, String Compania, String nombreIntegracion, String idBitacora, Map <String,String> campoActualiza) {
		Callout_ActualizaEmail_RQ datos = new Callout_ActualizaEmail_RQ();
		
		system.debug('------ID CONTACTO---' + idContacto);
		
		
		List<Contact> listaContactos = getContactById(new Set<Id>{idContacto}).values();
		Contact contacto = new Contact();
		if(!listaContactos.isEmpty()) contacto = listaContactos.get(0);
		List<ServiceContract> listaPolizas = Util_Poliza_Contrato.queryPolizaByAccountAndEnsuraNotNull(new Set<Id>{contacto.AccountId}).values();
		ServiceContract poliza = new ServiceContract();
		if(!listaPolizas.isEmpty()) poliza = listaPolizas.get(0);	
		String campo_Actualiza;
		for (String campo : campoActualiza.keySet()){
			campo_Actualiza = campo ; 
		}	
		
		datos.identificadorCompania = poliza.POL_TXT_Cliente_Ensura__c;
		datos.usuario = contacto.LastModifiedBy.Username ;
		if(campo_Actualiza == 'Email'){
       		datos.emailCompania = contacto.Email ;
		}
		else{
			datos.emailCompania = contacto.CON_EMA_Email_Adicional__c ;
		}
        
        String body = Callout_ActualizaEmail.construirBody(datos); 
		system.debug('------ body util'+body);
		
		//Se realiza la llamada al sistema tercero en sí misma:
		Callout_ActualizaEmail.updateDatos(body,nombreIntegracion,idBitacora,String.valueOf(contacto.Id),datos.usuario,datos.emailCompania, datos.identificadorCompania);
	}
	
	/**
	  * Método que se utiliza para actualizar el contacto principal de una cuenta en el objeto cuenta
	  * 
	  * @param triggerNew: Nuevo información del contacto actualizado.
	  * @param triggerOldMap: Antigua información del contacto actualizado.
	  * 
	  */
	public static void actualizarContactoPpalCuenta(List<Contact> triggerNew,Map<Id, Contact> triggerOldMap){
		List<Contact> actualizadas = new List<Contact>();
		Contact conOld = new Contact();
		//Guardamos en la lista "Actualizadas" aquellos contactos que actulicen la casilla de "contacto principal"
		for(Contact con: triggerNew){
			if(triggerOldMap != null){
				conOld = triggerOldMap.get(con.Id);
			}
			if(con.CON_CAS_Contacto_principal__c != conOld.CON_CAS_Contacto_principal__c)
				actualizadas.add(con);
		}
		Set<Id> contactIds = new Set<Id>();
    	for(Contact aux: actualizadas){
    		contactIds.add(aux.AccountId);
    	}
		Map<id,Account> cuentas = Util_Cuentas.getMapCuentasById(contactIds);
		
		Map<id,Account> cuentasActualizar = new Map<id,Account>();
		//Actualizamos las cuentas de los contactos modificados
		for (Contact con: actualizadas){
			Account cuentaUpdate = cuentas.get(con.AccountId);
			if(con.CON_CAS_Contacto_principal__c == true)
				cuentaUpdate.CUE_LKP_contacto_principal__c = con.Id;
			else
				cuentaUpdate.CUE_LKP_contacto_principal__c = null;
			cuentasActualizar.put(con.AccountId,cuentaUpdate);
		}
		Baipas.establecerVariableControl();
		update cuentasActualizar.values();
		Baipas.deshabilitarVariableControl();
	}
	
	public static Map<Id, Contact> queryContactoByAccountIdAndProgramType(Set<Id> setAccountID, Set<String> setListProgramType) {
        Map<Id, Contact> mapaContactos=new Map<Id, Contact>();
			if(!setAccountID.isEmpty() && !setListProgramType.isEmpty()) {
			        for(List<Contact> listaContactoAux:[SELECT Id, Email,CON_SEL_Tipo_Programa__c
			        									FROM Contact
			        									WHERE AccountID IN :setAccountID
			        									AND CON_SEL_Tipo_Programa__c IN :setListProgramType LIMIT :setListProgramType.size()]) {
			            mapaContactos.putAll(listaContactoAux);
			        }
			}
        return mapaContactos;
    }
	
    
    public static Map<Id, Contact> queryContactByAccountIdAndProgramType(Id accountID, List<String> listProgramType) { 
        Map<Id, Contact> mapContacts=new Map<Id,Contact>();
        if(!String.isEmpty(accountID) && !listProgramType.isEmpty()) {
        	mapContacts=new Map<Id,Contact>([SELECT Id, Email,CON_SEL_Tipo_Programa__c
        										FROM Contact
        										WHERE AccountID= :accountID
        										AND CON_SEL_Tipo_Programa__c IN :listProgramType LIMIT :listProgramType.size()]);
        }	
    	return mapContacts;
    }
}