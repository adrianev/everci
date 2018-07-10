/**
  * Handler del Trigger TRG_Cuenta.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Cuenta {
	private static final Id recordTypeIdProfContrato = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_PROFESIONAL_CONTRATO);
	private static final Id recordTypeIdClienteB2Bsec = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2);
	private static final Id recordTypeIdCLientePart = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR);
	private static final Id recordTypeClienteAsegurado = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_ASEGURADO);
	private static final Id recordTypeIdClienteB2B_1 = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1);
	private static final Id recordTypeIdClienteB2C_1 = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2C_1);
	/**	
	 *	Esta funcion ejecuta los metodos necesarios para el tratamiento del before
	 *	@param Map<Id,Account> triggerNewMap		- Mapa con los datos del Trigger.newMap
	 *	@param List<Account> triggerNew			- Lista con las cuentas del trigger.new
	 *	@param Map<Id,Account> triggerOldMap		- Mapa con los datos del Trigger.oldMap
	 *	@param List<Account> triggerOld			- Lista con las cuentas del trigger.old
	 */
	public static void tratamientoBefore(Map<Id,Account> triggerNewMap, List<Account>triggerNew, 
			Map<Id,Account> triggerOldMap, List<Account>triggerOld){

		if(trigger.isInsert || trigger.isUpdate){
			// Cargar lista de cuentas con el mismo DNI
			Set<String> setDNIs = new Set<String>(); 
			for(Account cuenta: triggerNew){
				if(cuenta.CUE_TXT_Numero_Documento__c != null){
					setDNIs.add(cuenta.CUE_TXT_Numero_Documento__c);
				}
			}
			system.debug('-----------setDNIs: '+ setDNIs);
			List<Account> listaCuentasExistentes = new List<Account>();
			if(!setDNIs.isEmpty()){
				/*listaCuentasExistentes = new List<Account>(
					[SELECT Id,
							CUE_TXT_Numero_Documento__c,
							CUE_LKP_Cuenta_principal__c,
							RecordTypeId
					 FROM Account
					 WHERE CUE_TXT_Numero_Documento__c IN :setDNIs]);*/
					 listaCuentasExistentes = Util_Cuentas.getCuentasByNumDoc(setDNIs).values();
			}
		
			generarIdentificadorCuenta(triggerNew, triggerOldMap);
			for(Account cuenta: triggerNew){
				Account cuentaOld;
				if(triggerOldMap != null){
					cuentaOld = triggerOldMap.get(cuenta.Id);
				}

				// Almacenamos en el campo Name, la concatenacion de los campos Nombre (CUE_TXT_Nombre__c) y apellidos
				if(cuenta.RecordTypeId != recordTypeIdProfContrato){
					concatenarNombre(cuenta, triggerOldMap);
				}

				//Validación de número de documento duplicado
				if(cuenta.CUE_TXT_Numero_Documento__c != null && cuenta.RecordTypeId != recordTypeIdProfContrato && 
				  (cuentaOld == null || cuentaOld.CUE_TXT_Numero_Documento__c != cuenta.CUE_TXT_Numero_Documento__c)){					
					for (Account cuentaExistente : listaCuentasExistentes){
						if(cuentaExistente.RecordTypeId == cuenta.RecordTypeId){
							if (cuenta.RecordTypeId == recordTypeIdClienteB2Bsec || cuenta.RecordTypeId == recordTypeIdCLientePart || cuenta.RecordTypeId == recordTypeClienteAsegurado){
								if(cuenta.CUE_LKP_Cuenta_principal__c == cuentaExistente.CUE_LKP_Cuenta_principal__c){
									 cuenta.addError(Label.WARNING_CUENTAS_DNI);
								}
							}
							else {
								cuenta.addError(Label.WARNING_CUENTAS_DNI);
							}
						}
					}
				}
				// Para los profesionales Contrato, cuando se crean tienen por defecto el estado Preactivado por lo que el check de activo debe estar a false
				if(cuenta.RecordTypeId == recordTypeIdProfContrato) {
					if(cuentaOld != null && cuentaOld.CUE_SEL_Tipo_Contrato__c != cuenta.CUE_SEL_Tipo_Contrato__c){
						cuenta.CUE_DAT_Profesional_Franquicia__c = Date.today();
					}
					if(cuentaOld != null && cuentaOld.CUE_SEL_Estado__c != cuenta.CUE_SEL_Estado__c){
						cuenta.CUE_CAS_Activado__c = false;
						if(trigger.isUpdate) {
							//Si el estado es activado, marcamos el check de activo y registramos la fecha si el profesional no hubiera sido activado con anterioridad
							if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_ACTIVADO) {
								cuenta.CUE_CAS_Activado__c = true;
								if(cuenta.CUE_DAT_Fecha_de_Activacion__c == null){
									cuenta.CUE_DAT_Fecha_de_Activacion__c = datetime.now();
								}
								// Si las observaciones de veto estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_Veto__c != null){
									cuenta.CUE_TXT_Observaciones_Veto__c = null;
								}
								// Si la fecha de veto esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_Veto__c != null){
									cuenta.CUE_DAT_Fecha_Veto__c = null;
								}
								// Si las observaciones de baja temporal estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_BajaTemp__c != null){
									cuenta.CUE_TXT_Observaciones_BajaTemp__c = null;
								}
								// Si la fecha de baja temporal esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_BajaTemp_Venc__c != null){
									cuenta.CUE_DAT_Fecha_BajaTemp_Venc__c = null;
								}
								// Si el motivo de baja temporal esta relleno se blanquea
								if(cuenta.CUE_SEL_Motivo_Baja_Temp__c != null){
									cuenta.CUE_SEL_Motivo_Baja_Temp__c = null;
								}
								// Si las observaciones de baja definitiva estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_BajaDef__c != null){
									cuenta.CUE_TXT_Observaciones_BajaDef__c = null;
								}
								// Si la fecha de baja definitiva esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_Baja__c != null){
									cuenta.CUE_DAT_Fecha_Baja__c = null;
								}
								// Si el motivo de baja definitiva esta relleno se blanquea
								if(cuenta.CUE_SEL_Motivo_Baja_Def__c != null){
									cuenta.CUE_SEL_Motivo_Baja_Def__c = null;
								}
								// Si el check de Dado de baja esta relleno se blaquea
								if(cuenta.CUE_CAS_Dada_de_Baja__c == true){
									cuenta.CUE_CAS_Dada_de_Baja__c = false;
								}
							}
							//Si el estado es Baja Temporal, marcamos el check de baja, desmarcamos el check de activo y registramos la fecha
							else if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_BAJA_TEMPORAL) {
								cuenta.CUE_CAS_Activado__c = false;
								cuenta.CUE_CAS_Dada_de_Baja__c = true;
								cuenta.CUE_DAT_Fecha_BajaTemp_Venc__c = datetime.now();
								// Si las observaciones de veto estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_Veto__c != null){
									cuenta.CUE_TXT_Observaciones_Veto__c = null;
								}
								// Si la fecha de veto esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_Veto__c != null){
									cuenta.CUE_DAT_Fecha_Veto__c = null;
								}
								// Si las observaciones de baja definitiva estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_BajaDef__c != null){
									cuenta.CUE_TXT_Observaciones_BajaDef__c = null;
								}
								// Si la fecha de baja definitiva esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_Baja__c != null){
									cuenta.CUE_DAT_Fecha_Baja__c = null;
								}
								// Si el motivo de baja definitiva esta relleno se blanquea
								if(cuenta.CUE_SEL_Motivo_Baja_Def__c != null){
									cuenta.CUE_SEL_Motivo_Baja_Def__c = null;
								}
							}
							//Si el estado es Baja Definitiva, marcamos el check de baja, desmarcamos el check de activo y registramos la fecha
							else if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_BAJA_DEFINITIVA) {
								cuenta.CUE_CAS_Activado__c = false;
								cuenta.CUE_CAS_Dada_de_Baja__c = true;
								cuenta.CUE_DAT_Fecha_Baja__c = datetime.now();
								// Si las observaciones de veto estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_Veto__c != null){
									cuenta.CUE_TXT_Observaciones_Veto__c = null;
								}
								// Si la fecha de veto esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_Veto__c != null){
									cuenta.CUE_DAT_Fecha_Veto__c = null;
								}								
								// Si las observaciones de baja temporal estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_BajaTemp__c != null){
									cuenta.CUE_TXT_Observaciones_BajaTemp__c = null;
								}
								// Si la fecha de baja temporal esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_BajaTemp_Venc__c != null){
									cuenta.CUE_DAT_Fecha_BajaTemp_Venc__c = null;
								}
								// Si el motivo de baja temporal esta relleno se blanquea
								if(cuenta.CUE_SEL_Motivo_Baja_Temp__c != null){
									cuenta.CUE_SEL_Motivo_Baja_Temp__c = null;
								}
							}
							//Si el estado es Vetado, desmarcamos el check de activo y el check de baja, si alguno de ellos estuviera marcado, y registramos la fecha
							else if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_VETADO) {
								cuenta.CUE_CAS_Activado__c = false;
								cuenta.CUE_CAS_Dada_de_Baja__c = false;
								cuenta.CUE_DAT_Fecha_Veto__c = datetime.now();
								// Si las observaciones de baja temporal estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_BajaTemp__c != null){
									cuenta.CUE_TXT_Observaciones_BajaTemp__c = null;
								}
								// Si la fecha de baja temporal esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_BajaTemp_Venc__c != null){
									cuenta.CUE_DAT_Fecha_BajaTemp_Venc__c = null;
								}
								// Si el motivo de baja temporal esta relleno se blanquea
								if(cuenta.CUE_SEL_Motivo_Baja_Temp__c != null){
									cuenta.CUE_SEL_Motivo_Baja_Temp__c = null;
								}
								// Si las observaciones de baja definitiva estan rellenadas se blaquean
								if(cuenta.CUE_TXT_Observaciones_BajaDef__c != null){
									cuenta.CUE_TXT_Observaciones_BajaDef__c = null;
								}
								// Si la fecha de baja definitiva esta rellena se blaquea
								if(cuenta.CUE_DAT_Fecha_Baja__c != null){
									cuenta.CUE_DAT_Fecha_Baja__c = null;
								}
								// Si el motivo de baja definitiva esta relleno se blanquea
								if(cuenta.CUE_SEL_Motivo_Baja_Def__c != null){
									cuenta.CUE_SEL_Motivo_Baja_Def__c = null;
								}
							}
						}
					}
				}
				else {
					if(cuentaOld != null && cuentaOld.CUE_CAS_Dada_de_Baja__c != cuenta.CUE_CAS_Dada_de_Baja__c && cuenta.CUE_CAS_Dada_de_Baja__c == true){
						cuenta.CUE_DAT_Fecha_Baja__c = datetime.now();
					}
					else if(cuentaOld != null && cuentaOld.CUE_DAT_Fecha_Baja__c != cuenta.CUE_DAT_Fecha_Baja__c && cuentaOld.CUE_DAT_Fecha_Baja__c == null){
						cuenta.CUE_CAS_Dada_de_Baja__c = true;
					}
				}
			}
		}
		
		if(trigger.isDelete){
			//Creamos un set de Ids de cuentas para traernos los recursos de servicio
			Set<Id> setIdCuentas = new Set<Id>();
			for(Account cuenta: triggerOld){
				setIdCuentas.add(cuenta.Id);
			}
			//Nos traemos un Mapa con todos los recursos de servicio de todas las cuentas para la funcionalidad de que no se puedan borrar cuentas que tengan algún SR
			Map<Id, List<ServiceResource>> recursosServicioPorProf = Util_Service_Resource.getMapaRecursosServicio(setIdCuentas);
			for(Account cuenta: triggerOld){
				if(cuenta.RecordTypeId == recordTypeIdProfContrato) {
					if(recursosServicioPorProf.get(cuenta.Id) != null && !recursosServicioPorProf.get(cuenta.Id).isEmpty()){
						cuenta.addError(Label.ERROR_CUENTA_PROF_CON_SR);
					}
				}
			}
		}//FIN (Before delete): VALIDACIÓN PARA QUE NO SE PUEDA BORRAR UN PROFESIONAL SI TIENE RECURSOS DE SERVICIO
	}


	/**
	 *	Esta funcion genera un identificador de la cuenta en los casos pertinentes
	 *	@param List<Account> triggerNew						- Lista de las cuentas a insertar o modificar
	 *	@param Map<Id, Account> triggerOldMap				- mapa con las cuentas viejas
	 */
	private static void generarIdentificadorCuenta(List<Account> triggerNew, Map<Id, Account> triggerOldMap){ 
		Set<String> setCuentas=new Set<String>();
		Map<String, Account> mapCuentasPrincipales=new Map<String, Account>();
		for(Account cuentaAux: triggerNew) {
			if(!String.isEmpty(cuentaAux.CUE_LKP_Cuenta_principal__c)) {
				setCuentas.add(cuentaAux.CUE_LKP_Cuenta_principal__c);
			}
		}
		mapCuentasPrincipales=Util_Compania.queryAccountById(setCuentas);

		for(Account cuenta : triggerNew){
			Account cuentaOld;
			String rtDevName = 'Account:' + Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(cuenta.RecordTypeId);
			if(triggerOldMap != null){
				cuentaOld = triggerOldMap.get(cuenta.Id);
			}
			system.debug(cuenta + ' cuentaNew');
			// Actualiza el identificador si pertenece a uno de estos RT y se trata de una inserción o modificación del número de documento
			if((rtDevName == Label.RT_CUE_CLIENTE_ASEGURADO || rtDevName == Label.RT_CUE_CLIENTE_PARTICULAR || rtDevName == Label.RT_CUE_PROFESIONAL) 
				&& (cuentaOld == null || (cuentaOld != null && cuenta.CUE_TXT_Numero_Documento__c != cuentaOld.CUE_TXT_Numero_Documento__c))){
				if(rtDevName == Label.RT_CUE_CLIENTE_ASEGURADO){
                    
					//Identificado Cía + Nº Documento
					Account aux=mapCuentasPrincipales.get(cuenta.CUE_LKP_Cuenta_principal__c);
                    system.debug(aux + ' auxCuentaPRINCIPAL');
					cuenta.CUE_TXT_Identificador__c = aux.CUE_TXT_Identificador__c + '_' + cuenta.CUE_TXT_Numero_Documento__c;
				}
				else if(rtDevName == Label.RT_CUE_CLIENTE_PARTICULAR){
					cuenta.CUE_TXT_Identificador__c = cuenta.CUE_TXT_Numero_Documento__c + '_P';
				}
				else if(rtDevName == Label.RT_CUE_PROFESIONAL){
					cuenta.CUE_TXT_Identificador__c = cuenta.CUE_TXT_Numero_Documento__c + '_PR';
				}
			}
			
			// Crea el identificador si es del RT RT_CUE_PROFESIONAL_CONTRATO y lo modifica si también se ha modificado su Name
			else if(rtDevName == Label.RT_CUE_PROFESIONAL_CONTRATO && (cuentaOld == null || (cuentaOld != null && cuenta.Name != cuentaOld.Name))){
				cuenta.CUE_TXT_Identificador__c = cuenta.Name;
			}
			
			// Crea el identificador si se trata de una inserción y es del RT RT_CUE_CLIENTEB2B_2 
			else if(cuentaOld == null){
				if(rtDevName == Label.RT_CUE_CLIENTEB2B_2){
					if(cuenta.Type == Label.CUE_TIPO_CONTABLE){
						cuenta.CUE_TXT_Identificador__c = 'CC' + String.valueOf(System.now().getTime());
					}
					else {	
						cuenta.CUE_TXT_Identificador__c = 'RP' + String.valueOf(System.now().getTime());
					}
				}
			}
			actualizaIRDnis(triggerNew, triggerOldMap);
		}
	}

	/**
	 *	Esta función concatena el campo Nombre (CUE_TXT_Nombre__c) y apellidos (CUE_TXT_PrimerApellido__c, CUE_TXT_SegundoApellido__c) en caso de estar informados en el campo Name
	 */
	private static void concatenarNombre(Account cuenta, Map<Id, Account> triggerOldMap){
		Account cuentaOld;
		if(triggerOldMap != null){
			cuentaOld = triggerOldMap.get(cuenta.Id);
		}
		if(cuenta.Name == null	// Si el nombre es nulo
				|| (cuentaOld != null	// O si ha cambiado alguno de los componentes del nombre
				&& (cuenta.CUE_TXT_Nombre__c != cuentaOld.CUE_TXT_Nombre__c
				|| cuenta.CUE_TXT_PrimerApellido__c != cuentaOld.CUE_TXT_PrimerApellido__c
				|| cuenta.CUE_TXT_SegundoApellido__c != cuentaOld.CUE_TXT_SegundoApellido__c))){
			cuenta.Name = Util_Cuentas.nombreCompleto(cuenta.CUE_TXT_Nombre__c, cuenta.CUE_TXT_PrimerApellido__c, cuenta.CUE_TXT_SegundoApellido__c);
		}
	}

	/**	
	 *	Esta funcion ejecuta los metodos necesarios para el tratamiento del after
	 *	@param Map<Id,Account> triggerNewMap		- Mapa con los datos del Trigger.newMap
	 *	@param List<Account> triggerNew			- Lista con las cuentas del trigger.new
	 *	@param Map<Id,Account> triggerOldMap		- Mapa con los datos del Trigger.oldMap
	 *	@param List<Account> triggerOld			- Lista con las cuentas del trigger.old
	 */
	public static void tratamientoAfter(Map<Id,Account> triggerNewMap, List<Account> triggerNew, Map<Id,Account> triggerOldMap, List<Account> triggerOld){
		//Creamos un set de Ids de cuentas para traernos los recursos de servicio
		Set<Id> setIdCuentas = new Set<Id>();
		for(Account cuenta: triggerNew){
			setIdCuentas.add(cuenta.Id);
		}
		//Nos traemos un Mapa con todos los recursos de servicio de todas las cuentas
		Map <Id, ServiceResource> mapaRecursos = Util_Service_Resource.queryMapRecursosServicio(setIdCuentas);
		//Nos traemos otro Mapa con todos los recursos de servicio organizados por cuentas
		Map <Id, List<ServiceResource>> mapaRecursoPorProf = Util_Service_Resource.getMapaRecursosServicio(setIdCuentas);
		//Recorremos todos los recursos de servicio para rellenar un set con los ids de los usuarios asignados a cada uno de ellos
    	Set<Id> setUsuarios = new Set<Id>();
    	for(ServiceResource sr: mapaRecursos.values()){
    		if(sr.RelatedRecordId != null){
    			setUsuarios.add(sr.RelatedRecordId);
    		}
    	}
    	//Nos traemos un mapa con todos los usuarios cuyo Id se encuentr en el set anterior
    	Map<Id, User> usuarios = Util_Perfiles_Usuario.queryMapUsuario(setUsuarios);
    	//Map<Id, User> usuarios = Util_Service_Resource.queryMapUsuarios(setUsuarios);
    	//Creamos listas con los objetos a actualizar
		//List<ServiceResource> listaRecursosAActualizar = new List<ServiceResource>();
		Map<Id,ServiceResource> mapaRecursosAActualizar = new Map<Id,ServiceResource>();
		List<ServiceResource> recursoCuenta = new List<ServiceResource>();
		List<User> listaUsuariosAActualizar = new List<User>();
		Map<String, String> mapaMotivoBajaTempo = Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'CUE_SEL_Motivo_Baja_Temp__c');
		Map<String, String> mapaMotivoBajaDef = Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'CUE_SEL_Motivo_Baja_Def__c');
		Historico_Estados_Profesional__c historico;
		List<Historico_Estados_Profesional__c> historicoAActualizar = new List<Historico_Estados_Profesional__c>();
		if(trigger.isUpdate) {
			for (Account cuenta: triggerNew){
				Account cuentaOld;
				if(triggerOldMap != null){
						cuentaOld = triggerOldMap.get(cuenta.Id);
				}
				if(cuenta.RecordTypeId == recordTypeIdProfContrato){
					if(cuentaOld != null && cuentaOld.CUE_SEL_Estado__c != cuenta.CUE_SEL_Estado__c){
						//Si el estado es activado, marcamos el check de activo y registramos la fecha para los Recursos de Servicio vinculados
						if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_ACTIVADO) {
							recursoCuenta = (mapaRecursoPorProf.get(cuenta.Id)!=null)?mapaRecursoPorProf.get(cuenta.Id):new List<ServiceResource>();
							//Creamos un registro en el objeto historico de Estados Profesionales
							historico = new Historico_Estados_Profesional__c();
							historico.HEP_SEL_Estado__c = Label.HEP_ESTADO_ACTIVADO;
							historico.HEP_DAT_Fecha__c = datetime.now();
							historico.HEP_LKP_Cuenta__c	= cuenta.Id;
							historicoAActualizar.add(historico);
							for(ServiceResource recursoAActualizar: recursoCuenta){
								if(usuarios.get(recursoAActualizar.RelatedRecordId) != null){
									User usuario = usuarios.get(recursoAActualizar.RelatedRecordId);
									if(cuentaOld.CUE_SEL_Estado__c == Label.CUE_ESTADO_PREACTIVADO || 
									(cuentaOld.CUE_SEL_Estado__c == Label.CUE_ESTADO_VETADO && (usuario.USR_SEL_Motivo_de_desactivacion__c == Label.USR_MOTIVO_DESACT_VETO || usuario.isActive)) || 
									(cuentaOld.CUE_SEL_Estado__c == Label.CUE_ESTADO_BAJA_DEFINITIVA && (usuario.USR_SEL_Motivo_de_desactivacion__c == Label.USR_MOTIVO_DESACT_BAJA || usuario.isActive)) ||
									(cuentaOld.CUE_SEL_Estado__c == Label.CUE_ESTADO_BAJA_TEMPORAL && (usuario.USR_SEL_Motivo_de_desactivacion__c == Label.USR_MOTIVO_DESACT_DOCUMENTACION || usuario.USR_SEL_Motivo_de_desactivacion__c == Label.USR_MOTIVO_DESACT_BAJA || usuario.isActive))){
										if(!usuario.isActive){
											usuario.isActive = true;
											usuario.USR_SEL_Motivo_de_desactivacion__c = null;
											listaUsuariosAActualizar.add(usuario);
										}
										else{										
											if(recursoAActualizar.IsActive != true){
												recursoAActualizar.IsActive = true;
												mapaRecursosAActualizar.put(recursoAActualizar.Id,recursoAActualizar);
												//listaRecursosAActualizar.add(recursoAActualizar);
											}										
										}
									}
								}
							}
						}
						//Si el estado es Baja Temporal, marcamos el check de baja, desmarcamos el check de activo y registramos la fecha para los Recursos de Servicio vinculados
						else if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_BAJA_TEMPORAL) {
							recursoCuenta = (mapaRecursoPorProf.get(cuenta.Id)!=null)?mapaRecursoPorProf.get(cuenta.Id):new List<ServiceResource>();
							//Creamos un registro en el objeto historico de Estados Profesionales
							historico = new Historico_Estados_Profesional__c();
							historico.HEP_SEL_Estado__c = Label.HEP_ESTADO_BAJA_TEMPORAL;
							historico.HEP_DAT_Fecha__c = datetime.now();
							historico.HEP_TXT_Motivo_Baja__c = mapaMotivoBajaTempo.get(cuenta.CUE_SEL_Motivo_Baja_Temp__c);
							historico.HEP_TXT_Observaciones__c = cuenta.CUE_TXT_Observaciones_BajaTemp__c;
							historico.HEP_LKP_Cuenta__c	= cuenta.Id;
							historicoAActualizar.add(historico);
							for(ServiceResource recursoAActualizar: recursoCuenta){
								if(usuarios.get(recursoAActualizar.RelatedRecordId) != null){
									User usuario = usuarios.get(recursoAActualizar.RelatedRecordId);
									if(usuario.isActive != false){
										usuario.isActive = false;
										if(Util_Listas_Seleccion.getValorAPIDesdeLabel('Account', 'CUE_SEL_Motivo_Baja_Temp__c', mapaMotivoBajaTempo.get(cuenta.CUE_SEL_Motivo_Baja_Temp__c)) == Label.CUE_MOTIVO_BAJA_DOCUMENTACION){
											usuario.USR_SEL_Motivo_de_desactivacion__c = Label.USR_MOTIVO_DESACT_DOCUMENTACION;
										}else{
											usuario.USR_SEL_Motivo_de_desactivacion__c = Label.USR_MOTIVO_DESACT_BAJA;
										}
										if(recursoAActualizar.IsActive != false){
											recursoAActualizar.IsActive = false;
										}
										recursoAActualizar.RSE_DAT_Fecha_BajaTemp_Venc__c = datetime.now();
										//listaRecursosAActualizar.add(recursoAActualizar);
										mapaRecursosAActualizar.put(recursoAActualizar.Id,recursoAActualizar);
									}
									listaUsuariosAActualizar.add(usuario);
								}
							}
						}
						//Si el estado es Baja Definitiva, marcamos el check de baja, desmarcamos el check de activo y registramos la fecha para los Recursos de Servicio vinculados
						else if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_BAJA_DEFINITIVA) {
							recursoCuenta = (mapaRecursoPorProf.get(cuenta.Id)!=null)?mapaRecursoPorProf.get(cuenta.Id):new List<ServiceResource>();
							//Creamos un registro en el objeto historico de Estados Profesionales
							historico = new Historico_Estados_Profesional__c();
							historico.HEP_SEL_Estado__c = Label.HEP_ESTADO_BAJA_DEFINITIVA;
							historico.HEP_DAT_Fecha__c = datetime.now();
							historico.HEP_TXT_Motivo_Baja__c = mapaMotivoBajaDef.get(cuenta.CUE_SEL_Motivo_Baja_Def__c);
							historico.HEP_TXT_Observaciones__c = cuenta.CUE_TXT_Observaciones_BajaDef__c;
							historico.HEP_LKP_Cuenta__c	= cuenta.Id;
							historicoAActualizar.add(historico);
							for(ServiceResource recursoAActualizar: recursoCuenta){
								if(usuarios.get(recursoAActualizar.RelatedRecordId) != null){
									User usuario = usuarios.get(recursoAActualizar.RelatedRecordId);
									if(usuario.isActive != false){
										usuario.isActive = false;
										usuario.USR_SEL_Motivo_de_desactivacion__c = Label.USR_MOTIVO_DESACT_BAJA;
										if(recursoAActualizar.IsActive != false){
											recursoAActualizar.IsActive = false;
										}
										recursoAActualizar.RSE_DAT_Fecha_Baja__c = datetime.now();
										//listaRecursosAActualizar.add(recursoAActualizar);
										mapaRecursosAActualizar.put(recursoAActualizar.Id,recursoAActualizar);
									}
									listaUsuariosAActualizar.add(usuario);
								}
							}
						}

						//Si el estado es Vetado, desmarcamos el check de activo y registramos la fecha para los Recursos de Servicio vinculados
						else if(cuenta.CUE_SEL_Estado__c == Label.CUE_ESTADO_VETADO) {
							recursoCuenta = (mapaRecursoPorProf.get(cuenta.Id)!=null)?mapaRecursoPorProf.get(cuenta.Id):new List<ServiceResource>();
							//Creamos un registro en el objeto historico de Estados Profesionales
							historico = new Historico_Estados_Profesional__c();
							historico.HEP_SEL_Estado__c = Label.HEP_ESTADO_VETADO;
							historico.HEP_DAT_Fecha__c = datetime.now();
							historico.HEP_LKP_Cuenta__c	= cuenta.Id;
							for(ServiceResource recursoAActualizar: recursoCuenta){								
								if(usuarios.get(recursoAActualizar.RelatedRecordId) != null){
									User usuario = usuarios.get(recursoAActualizar.RelatedRecordId);
									if(usuario.isActive != false){
										usuario.isActive = false;
										usuario.USR_SEL_Motivo_de_desactivacion__c = Label.USR_MOTIVO_DESACT_VETO;
										if(recursoAActualizar.IsActive != false){
											recursoAActualizar.IsActive = false;
										}
										//listaRecursosAActualizar.add(recursoAActualizar);
										mapaRecursosAActualizar.put(recursoAActualizar.Id,recursoAActualizar);
									}
									listaUsuariosAActualizar.add(usuario);
								}
							}
						}

					}
					
					if(cuentaOld != null && cuentaOld.CUE_SEL_Tipo_de_red__c != cuenta.CUE_SEL_Tipo_de_red__c){
						recursoCuenta = (mapaRecursoPorProf.get(cuenta.Id)!=null)?mapaRecursoPorProf.get(cuenta.Id):new List<ServiceResource>();
						for(ServiceResource recurso: recursoCuenta){
							if(recurso.isActive && recurso.RSE_SEL_Tipo_de_red__c != cuenta.CUE_SEL_Tipo_de_red__c){
								ServiceResource recursoAActualizar = mapaRecursosAActualizar.get(recurso.Id);
								if(recursoAActualizar == null)
									recursoAActualizar = recurso;
								recursoAActualizar.RSE_SEL_Tipo_de_red__c = cuenta.CUE_SEL_Tipo_de_red__c;
								mapaRecursosAActualizar.put(recursoAActualizar.Id,recursoAActualizar);
							}
						}
						
					}
				}
			}
		}
		// Actualizar las cuentas actualizadas en el Before
		if (Util_Cuentas.cuentasActualizarTrigger != null && !Util_Cuentas.cuentasActualizarTrigger.isEmpty()){
			update Util_Cuentas.cuentasActualizarTrigger;
		}
		
		if(Trigger.isInsert){
			// Si la cuenta insertada es B2B Secundaria: Vincular Líneas de Contrato Correctivas
			insert direcciones_B2B_B2B2C_LineasContrato(triggerNew);
			// Si la cuenta insertada es B2B Principal: Generar Procedencias
			insert procedencias_B2B2C(triggerNew);
			// Si la cuenta insertada es B2B Principal: Generamos la habilidad de la CIA
			//update habilidadCIA_B2B2C(triggerNew);
		}
		// Se comprueba si se ha modificado DNI, nombre, o apellidos
		actualizaIRDnis(triggerNew, triggerOldMap);
		// Se actualiza la lista de recusos de servicio
		/*if (listaRecursosAActualizar != null && !listaRecursosAActualizar.isEmpty()){
			update listaRecursosAActualizar;
		}*/
		if (mapaRecursosAActualizar != null && !mapaRecursosAActualizar.isEmpty()){
			update mapaRecursosAActualizar.values();
		}
		// Se actualiza el historico de estados del profesional
		if (historicoAActualizar != null && !historicoAActualizar.isEmpty()){
			insert historicoAActualizar;
		}
		// Se actualiza la lista de usuarios
		if (listaUsuariosAActualizar != null && !listaUsuariosAActualizar.isEmpty()){
			Util_Usuarios usuario = new Util_Usuarios(listaUsuariosAActualizar);
			System.enqueueJob(usuario);
		}			
	}

	/**
	  * Método que encola el proceso de envío de la actualizacion del campo Robinson al sistema tercero
	  * 
	  * @param triggerNewMap: Mapa con los datos del trigger new
	  * @param triggerNew: Lista con las cuentas del trigger new
	  * @param triggerOldMap: Mapa con los datos del trigger old
	  * @param triggerOld: Lista con las cuentas del trigger old
	  * 
	  */
	public static void actualizarCheckRobinson (Map<Id,Account> triggerNewMap, List<Account> triggerNew, 
			Map<Id,Account> triggerOldMap, List<Account> triggerOld){
		//Encola un callback que envía información a Ensura acerca de la actualización del campo Robinson	
		String nombreIntegracion = 'SRV-PSI-057';
		String identificador ='1999';
		
		/*List<ServiceContract> listaCompaniaCuenta = new List<ServiceContract>([SELECT POL_LKP_Compania__r.CUE_TXT_Identificador__c FROM ServiceContract WHERE AccountId =: triggerNew[0].Id 
			AND POL_LKP_Compania__r.CUE_TXT_Identificador__c = '1999']);*/
			List<ServiceContract> listaCompaniaCuenta = new List<ServiceContract>();
			listaCompaniaCuenta = Util_Poliza_Contrato.queryPolizaByAccountIdAndCompania(new Set<Id>{triggerNew[0].Id},new Set<String>{'1999'}).values();
		ServiceContract companiaCuenta;
		if (!listaCompaniaCuenta.isEmpty())companiaCuenta = listaCompaniaCuenta.get(0);
		
		for(Account ac: triggerNew ){

			if(trigger.isUpdate && companiaCuenta != null){//UPDATE Robinson de true a false o viceversa; encolamos una llamada a Ensura
				if(companiaCuenta.POL_LKP_Compania__r.CUE_TXT_Identificador__c.equals(identificador)){
					if( triggerOldMap.get(ac.Id).CUE_CAS_Robinson__c != triggerNewMap.get(ac.Id).CUE_CAS_Robinson__c){


						// insertamos en la tabla de bitácoras como no enviado y luego realizamos el callback.
						//\--> Si se efetúa correctamente entonces eliminaremos la entrada de la tabla
						String idBitac = '';
                        
						idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,nombreIntegracion ,
								'', '','','',String.valueOf(ac.Id), '','', '',0,'', 0.0,Label.Callout_PUT);

						Map<Id, String> registroId = new Map<Id, String> ();
						registroId.put(ac.Id, 'Account');
						Util_Llamada_Externa batchRobinsonInsert = new Util_Llamada_Externa(registroId,'Ensura',nombreIntegracion,idBitac);
						
						//Encolamos el proceso batch
						System.enqueueJob(batchRobinsonInsert);
					}

				}
			}
			if(trigger.isInsert){ //INSERT con Robinson = falso, hacemos lo mismo.
				if(triggerNewMap.get(ac.Id).CUE_CAS_Robinson__c == false ){

					// insertamos en la tabla de bitácoras como no enviado y luego realizamos el callback.
					//\--> Si se efetúa correctamente entonces eliminaremos la entrada de la tabla
					String idBitac = '';
					idBitac = Util_Llamada_Externa.insertarBitacora('Ensura', '','03','02' ,nombreIntegracion ,
							'', '','','',String.valueOf(ac.Id), '','', '',0,'', 0.0,Label.Callout_PUT);

					Map<Id, String> registroId = new Map<Id, String> ();
					registroId.put(ac.Id, 'Account');
					Util_Llamada_Externa batchRobinsonInsert = new Util_Llamada_Externa(registroId,'Ensura',nombreIntegracion,idBitac);
					//Encolamos el proceso batch
					System.enqueueJob(batchRobinsonInsert);
				}
			}
			else{
				system.debug('Robinson Insert Robinson = true NO Callback');
				}
		}//End for
	}	

	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerOldMap: [PENDIENTE]
	  * 
	  */
	private static void actualizaIRDnis(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
		//system.debug('actualizaIRDnis');
		List<Account> datosUpdate = new List<Account>();
		for(Account cont : triggerNew){
			if(triggerOldMap == null || cont.CUE_TXT_Nombre__c != triggerOldMap.get(cont.Id).CUE_TXT_Nombre__c || 
					cont.CUE_TXT_Numero_Documento__c != triggerOldMap.get(cont.Id).CUE_TXT_Numero_Documento__c
					|| cont.CUE_TXT_PrimerApellido__c != triggerOldMap.get(cont.Id).CUE_TXT_PrimerApellido__c 
					|| cont.CUE_TXT_SegundoApellido__c != triggerOldMap.get(cont.Id).CUE_TXT_SegundoApellido__c){
				//system.debug('actualizaIRDnis go Handler');
				datosUpdate.add(cont);
			}		
		}	
		//system.debug('lista datosUpdate'+datosUpdate);
		TRG_Handler_MovimientoIR.actualizaCuentaIR(datosUpdate);	
	}	
	/**	
	 *	Esta funcion se encargar de crear direcciones B2B_B2B2C para lineas de contrato de cuentas
	 *	@param List<Account> triggerNew			- Lista con las cuentas del trigger.new
	 */
	private static List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> direcciones_B2B_B2B2C_LineasContrato(List<Account> triggerNew){
		List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaAgregarDirec = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if (trigger.isInsert){
			Id recordTypeIdClienteB2B_2 = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2);
			Id recordTypeIdCorrectivo = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_LIN_CON_CORRECTIVO);
			Map<Id, Account> mapaCuentas = new Map<Id, Account>();
			Map<Id, List<Linea_Contrato__c>> mapaLineaCuenta;
			List<Linea_Contrato__c> listLin;

			for (Account cuenta : triggerNew){
				if (cuenta.RecordTypeId == recordTypeIdClienteB2B_2 &&
				    cuenta.Type != Label.CUE_TIPO_CONTABLE &&
				    cuenta.Type != Label.CUE_TIPO_OK_PYMES &&
				    cuenta.CUE_LKP_Cuenta_principal__c!=null){
					mapaCuentas.put(cuenta.CUE_LKP_Cuenta_principal__c, cuenta);
				}
			}

			/*listLin = new List<Linea_Contrato__c>([
			                                       SELECT	Id,
			                                       LDC_LKP_Contrato__r.AccountId,
			                                       RecordTypeId,
			                                       LDC_NUM_Limite_de_servicios__c
			                                       FROM 	Linea_Contrato__c
			                                       WHERE 	LDC_LKP_Contrato__r.AccountId IN :mapaCuentas.keySet() 
			                                       AND LDC_LKP_Contrato__r.Status =: Label.CONTRATO_ESTADO_ACTIVO
			                                       AND RecordTypeId = :recordTypeIdCorrectivo
			                                       AND LDC_CAS_Activo__c = true]);*/
			                                       
			listLin = new List<Linea_Contrato__c>();
			listLin = Util_B2B.queryLineaContratoByCuentaStatusRecordTypeActivo(new Set<Id>(mapaCuentas.keySet()), new Set<String>{Label.CONTRATO_ESTADO_ACTIVO}
			, new Set<Id>{recordTypeIdCorrectivo}, true).values();                                     

			for (Linea_Contrato__c lin : listLin){
				listaAgregarDirec.add(Util_B2B.vincularB2BSecLineaCtr(mapaCuentas.get(lin.LDC_LKP_Contrato__r.AccountId), lin, null));
			}
		}
		return listaAgregarDirec;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	private static List<Procedencia__c> procedencias_B2B2C(List<Account> triggerNew){
		List<Procedencia__c> listaNuevasProc = new List<Procedencia__c>();
		for (Account cuenta : triggerNew){
			if (cuenta.RecordTypeId == recordTypeIdClienteB2B_1){
				listaNuevasProc.add(Util_Cuentas.crearProcedenciaB2B(cuenta, 1));
				listaNuevasProc.add(Util_Cuentas.crearProcedenciaB2B(cuenta, 2));
			} else if (cuenta.RecordTypeId == recordTypeIdClienteB2C_1){
				listaNuevasProc.add(Util_Cuentas.crearProcedenciaB2C(cuenta));
			}
		}
		return listaNuevasProc;
	}


	/**
	  * Este método se encarga de crear la habilidad de la CIA correspondiente al crear una cuenta principal
	  * 
	  * @param List<Account> triggerNew			- Lista con las cuentas del trigger.new
	  * 
	  * @return List<Skill>						- Lista con las habilidades a insertar
	  */
	private static List<Skill> habilidadCIA_B2B2C(List<Account> triggerNew){
		List<Skill> listaNuevasHabilidadesCIA = new List<Skill>();	
		for (Account cuenta : triggerNew){
			if (cuenta.RecordTypeId == recordTypeIdClienteB2B_1 || cuenta.RecordTypeId == recordTypeIdClienteB2C_1){
				listaNuevasHabilidadesCIA.add(Util_Cuentas.crearHabilidadCIA(cuenta));
			}
		}
		return listaNuevasHabilidadesCIA;
	}
}