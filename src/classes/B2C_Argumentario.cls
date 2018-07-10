/**
 * Clase controladora de la Visualforce "B2C_Argumentario" lanza un flow:interview
 * @author EVERIS
 */

public without sharing class B2C_Argumentario {
	private String codigoVDN;
	public Case caso {get; set;}
	public Account cuenta {get; set;}
	public Account compania {get; set;}
	public Id idCia {get; set;}
	public ServiceContract poliza {get; set;}
	public String via {get; set;}
	public String cp {get; set;}
	public String poblacion {get; set;}
	public String provincia {get; set;}
	public List<SelectOption> listaTelefonos {get; set;}
	public String idTelefonoCIA {get; set;}
	public Direccion_Cuenta__c direcCuenta;
	public Flow.Interview.Flujo_argumentario_B2C flujoArgumentario {get; set;}
	public Id rtB2C {get; set;}
	public Id idPoliza {get; set;}
	public Boolean esMembership {get; set;}
	private String retURLRetorno;
	
	public B2C_Argumentario(ApexPages.standardController stdCtr){
		PageReference paginaActual = ApexPages.currentPage();
		system.debug('B2C_Argumentario : Constructor : paginaActual.getUrl() : '+paginaActual.getUrl());
		if(paginaActual.getParameters().containsKey('VDN')){
			codigoVDN = paginaActual.getParameters().get('VDN');
		}
		rtB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
		listaTelefonos = new List<SelectOption>();
		if(paginaActual.getParameters().containsKey('retURL')){
			retURLRetorno = paginaActual.getParameters().get('retURL');
		}
		system.debug('B2C_Argumentario : Constructor : retURLRetorno : '+retURLRetorno);
		//Si recibo por parametro el caso, busco el caso y la cuenta 
		if (paginaActual.getParameters().containsKey('id')){
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_Siniestro.queryCaso(stdCtr.getRecord().Id, null, 1);
			if (!listaCasos.isEmpty()){
				caso = listaCasos.get(0);
				via = caso.CAS_TXT_Direccion__c;
				cp = caso.CAS_TXT_DirRiesgo_CP__c;
				idCia = caso.CAS_LKP_Compania__c;
				provincia = caso.CAS_SEL_DirRiesgo_Estado_Provincia__c;
				poblacion = caso.CAS_TXT_DirRiesgo_Poblacion__c;
				idPoliza = caso.CAS_LKP_PolizaContrato__c;
				esMembership = (caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP);
				System.debug('B2C_Argumentario: constructor: esMembership: '+esMembership);
				compania = new Account(Id=caso.CAS_LKP_Compania__c,Name=caso.CAS_LKP_Compania__r.Name);
				System.debug('B2C_Argumentario: constructor: compania: '+compania);
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
			}
		}

		//Si se me pasa el id de la cuenta, busco la cuenta
		if (paginaActual.getParameters().containsKey('idCuenta')){
			cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{paginaActual.getParameters().get('idCuenta')}).get(paginaActual.getParameters().get('idCuenta'));
			if (cuenta != null){
				compania = new Account(Id=cuenta.CUE_LKP_Cuenta_principal__c,Name=cuenta.CUE_LKP_Cuenta_principal__r.Name);
				esMembership = (cuenta.CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP);
			}
		}
		
		//Si recibo el id de la compañía, busco la compañía
		if (paginaActual.getParameters().containsKey('idCIA')){
			idCia = paginaActual.getParameters().get('idCIA');
			
			//PREV
			/*
			List<Account> listaCuentas = new List<Account>(
						[   SELECT  Id,
									Name,
									CUE_TXT_Identificador__c
							FROM Account
							WHERE Id = :idCia]);
			compania = listaCuentas.get(0);
			esMembership = (compania.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP);
			*/
			compania = Util_Cuentas.getMapCuentasById(new Set<Id>{Id.valueOf(idCia)}).get(Id.valueOf(idCia));
			if(compania != null){
				esMembership = (compania.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP);
			}
		}
		
		//Si recibo el id de la póliza, la busco
		if (paginaActual.getParameters().containsKey('idPoliza')){
			List<ServiceContract> listaPolizas = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{paginaActual.getParameters().get('idPoliza')}).values();
			//List<ServiceContract> listaPolizas = Util_Poliza_Contrato.queryMapPoliza('Id = \''+paginaActual.getParameters().get('idPoliza')+'\'').values();
			//List<ServiceContract> listaPolizas = Util_Poliza_Contrato.queryPoliza(paginaActual.getParameters().get('idPoliza'));
			if (!listaPolizas.isEmpty()){
				poliza = listaPolizas.get(0);
				idPoliza = poliza.Id;
				idCia = poliza.POL_LKP_Compania__c;
				via = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Calle__c;
				cp = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Codigo_Postal__c;
				provincia = poliza.POL_LKP_Version_Actual__r.POLV_SEL_Estado_Provincia__c;
				poblacion = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Poblacion__c;
				esMembership = (poliza.POL_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP);
			}
		}
		
		//Si recibo el id de la direccion, la busco
		if (paginaActual.getParameters().containsKey('idDireccion')){
			List<Direccion_Cuenta__c> listaDireccionesCuenta = Util_Cuentas.queryByDireccionId(new Set<Id>{paginaActual.getParameters().get('idDireccion')}).values();
			//List<Direccion_Cuenta__c> listaDireccionesCuenta = Util_Cuentas.queryDireccion(paginaActual.getParameters().get('idDireccion'), null);
			if (!listaDireccionesCuenta.isEmpty()){
				direcCuenta = listaDireccionesCuenta.get(0);
				via = direcCuenta.DCU_TXT_Direccion__c;
				cp = direcCuenta.DCU_TXT_Codigo_Postal__c;
				provincia = direcCuenta.DCU_SEL_Provincia__c;
				poblacion = direcCuenta.DCU_TXT_Poblacion__c;
				
			}
		}
		
		/*List<Account> listaCuentaHS = new List<Account>(
						[   SELECT  Id,
									CUE_TXT_Identificador__c
							FROM Account
							WHERE CUE_TXT_Identificador__c = :Label.IDE_HOMESERVE]);*/
		List<Account> listaCuentaHS = Util_Cuentas.queryCuentasByIdExt(new Set<String>{Label.IDE_HOMESERVE}).values();				
		Account homeserve = listaCuentaHS.get(0);
		listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(homeserve.Id);
		idTelefonoCIA = null;
		
	}//FIN B2C_Argumentario
	
	/**
       * [PENDIENTE]
       * 
        * @param idGrupo: [PENDIENTE]
       * 
        * @return [PENDIENTE]
       */  
	
	public PageReference getPaginaRedireccionar(){
		
		PageReference paginaRedireccion;
		
		if(caso != null){
			paginaRedireccion = new PageReference('/' + caso.Id);
		}
		
		/*
		 * 
		 *  - DETALLE SINIESTRO: Si No es reparable: actualizamos el siniestro con el motivo de no apertura indicado en el argumentario. 
		 *  - DETALLE SINIESTRO: Si es reparable y NO ofrecemos solución: actualizamos el siniestro con el motivo de rechazo indicado en el argumentario.
		 *  - DETALLE SOLICITUD B2C: Si es reparable y SI ofrecemos solución, si urgente, si tranferido: creamos SOLICITUD B2C en estado transferido.
		 *  - DETALLE SOLICITUD B2C: Si es reparable y SI ofrecemos solución, no urgente: creamos SOLICITUD B2C en estado transferido.
		 *  - APERTURA B2C (VF B2C GREMIOS): Si es reparable, Si es urgente, NO es tranferido.
		 *
		**/
		if(flujoArgumentario != null){
			Case casoDevuelto = new Case();
			Id idCasoDevuelto;
			//system.debug('***** flujoArgumentario : ' + flujoArgumentario);
			
			if(flujoArgumentario.IdCasoNoReparableConPoliza != null){
				idCasoDevuelto = (Id) flujoArgumentario.IdCasoNoReparableConPoliza;
			}else if(flujoArgumentario.IdCasoNoReparableSinPoliza  != null){
				idCasoDevuelto = (Id) flujoArgumentario.IdCasoNoReparableSinPoliza ;
			}else if(flujoArgumentario.idcasourgentetransferimosconpoliza != null){
				idCasoDevuelto = (Id) flujoArgumentario.idcasourgentetransferimosconpoliza;
			}else if(flujoArgumentario.idcasourgentetransferimossini != null){
				idCasoDevuelto = (Id) flujoArgumentario.idcasourgentetransferimossini;
			}else if(flujoArgumentario.idcasourgentetransferimossinpoliza != null){
				idCasoDevuelto = (Id) flujoArgumentario.idcasourgentetransferimossinpoliza;
			}
		
			//PREV
			/*List<Case> listaCasos = new List<Case>(
							[   SELECT  Id,
										Type,
										AccountId
								FROM Case
								WHERE Id = :idCasoDevuelto]);
			*/
			//NEW
			Set <Id> setIdCaso = new Set<Id>();
			setIdCaso.add( idCasoDevuelto);
			List<Case> listaCasos = Util_Caso.getCaseById(setIdCaso).values();
			//END_NEW
								
			if(!listaCasos.isEmpty()){
				casoDevuelto = listaCasos.get(0);
				paginaRedireccion = new PageReference('/' + casoDevuelto.Id);
			}
			
			if(casoDevuelto != null && flujoArgumentario.preguntareparable != null){
				if(!flujoArgumentario.preguntareparable){//Si no es reparable
					if(flujoArgumentario.getVariableValue('MotivoNo_Reparable') != null){//Si tiene motivo no reparable
						//Se redirige al detalle del Siniestro -- casoDevueltoNoReparable
						paginaRedireccion = new PageReference('/' + flujoArgumentario.getVariableValue('CasoNoReparable')); 
					}
					//String asunto, String estado, String prioridad, Id owner, Id vincularA, String compania
					/*
					*	   ----- ESTÁ HARDCODEADO PARA QUE LAS TAREAS SE ASIGNEN AL USUARIO ED JULIA.
					*	   ----- BUSCAR FORMA DE QUE LAS TAREAS SE ASIGNEN A UNA COLA
					*
					*/
					Id userJulia = (Id) '0059E000002Lexi';
					//Task tarea = Util_Siniestro.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_SOLIC_B2C, Label.TAR_ESTADO_SIN_INICIAR, 
					// Label.TAR_PRIORIDAD_NORMAL, userJulia, casoDevuelto.Id, null);
					Task tarea = Util_Tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_SOLIC_B2C, Label.TAR_ESTADO_EN_CURSO, 
						null, userJulia, casoDevuelto.Id, casoDevuelto.CAS_LKP_Compania__c);
					
					if(tarea != null){
						try{
							//insert tarea;
						}
						catch(DmlException e){
            				if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                				system.debug('***** EXCEPTION : ' + e);
             				}
     					}
						catch(Exception e){
							system.debug('***** EXCEPTION : ' + e);
						}
					}
				}else if(flujoArgumentario.preguntareparable){//Si es reparable
					
					//SE OFRECE SOLUCION -->OfrecerSolucion
					system.debug('---OfrecerSolucion: ' + flujoArgumentario.getVariableValue('OfrecerSolucion'));
					system.debug('---var_OfrecerAsistencia: ' + flujoArgumentario.getVariableValue('var_OfrecerAsistencia'));
					system.debug('---Ofrecer_Solucion istrue: ' + (flujoArgumentario.getVariableValue('Ofrecer_Solucion') == 'true'));
					system.debug('---Urgencia: ' + flujoArgumentario.getVariableValue('Urgencia'));
					system.debug('---EsUrgente: ' + flujoArgumentario.getVariableValue('EsUrgente'));
					system.debug('---EsUrgente istrue: ' + (flujoArgumentario.getVariableValue('EsUrgente') == true));
					system.debug('---QueHacemoSiUrgente: ' + flujoArgumentario.getVariableValue('QueHacemoSiUrgente'));
					
					system.debug('>>>>>> caso : ' + caso);
					if(flujoArgumentario.getVariableValue('var_OfrecerAsistencia') == false || (cuenta == null) || flujoArgumentario.getVariableValue('IdSiniestroflujo') == null){
						system.debug('--- Entrada ofrecer solución');
						paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_GREMIOS); 
						paginaRedireccion.getParameters().put('fase', Label.SINI_FASE_APERTURA);
						paginaRedireccion.getParameters().put('id', idCasoDevuelto);
						paginaRedireccion.getParameters().put('solicitudExistente', 'Y');
					}else{//Si NO ofrecemos solución
						//Se redirige al Detalle del Siniestro -- caso.Id
						if(casoDevuelto == null && caso != null){
							if(caso.Id != null){
								paginaRedireccion = new PageReference('/' + caso.Id);
							}
						}else if(casoDevuelto != null){
							if(casoDevuelto.Id != null){
								paginaRedireccion = new PageReference('/' + casoDevuelto.Id);
							}
						}
					}
				}
			}
			
		}
		system.debug('***** flujoArgumentario : ' + flujoArgumentario);
		system.debug('***** paginaRedireccion : ' + paginaRedireccion);
		return paginaRedireccion;
	}
	
	 /**
       * [PENDIENTE]
       * 
        * @param idGrupo: [PENDIENTE]
       * 
        * @return [PENDIENTE]
       */  
	
	public PageReference cancelar() {	   
		PageReference paginaRedireccion = null;
		Boolean salir = true;
		if(flujoArgumentario != null){
			Id idCasoDevuelto;			
			if(flujoArgumentario.IdCasoNoReparableConPoliza != null){
				idCasoDevuelto = (Id) flujoArgumentario.IdCasoNoReparableConPoliza;
			}else if(flujoArgumentario.IdCasoNoReparableSinPoliza  != null){
				idCasoDevuelto = (Id) flujoArgumentario.IdCasoNoReparableSinPoliza ;
			}else if(flujoArgumentario.idcasourgentetransferimosconpoliza != null){
				idCasoDevuelto = (Id) flujoArgumentario.idcasourgentetransferimosconpoliza;
			}else if(flujoArgumentario.idcasourgentetransferimossini != null){
				idCasoDevuelto = (Id) flujoArgumentario.idcasourgentetransferimossini;
			}else if(flujoArgumentario.idcasourgentetransferimossinpoliza != null){
				idCasoDevuelto = (Id) flujoArgumentario.idcasourgentetransferimossinpoliza;
			}
			
			if(idCasoDevuelto !=null){ //Tenemos que conocer si hay algun caso para poder eliminador
				system.debug('***** idCasoDevuelto : ' + idCasoDevuelto);
				//PREV
				/*List<Case> listaCasos = new List<Case>(
								[   SELECT  Id,
											Type
									FROM Case
									WHERE Id = :idCasoDevuelto]);*/
				//NEW
				Set <Id> setIdsCaso = new Set <Id>();
				setIdsCaso.add(idCasoDevuelto);
				List<Case> listaCasos = new List<Case>(Util_Caso.getCaseById(setIdsCaso).values());
				//List<Case> listaCasos = new List<Case>(Util_Caso.getMapaCasos(setIdsCaso).values() );
				
				//END_NEW
				if(!listaCasos.isEmpty()){
					system.Savepoint puntoGuardado = Database.setSavepoint();
					try {
							delete listaCasos.get(0);
					}
					catch(DmlException e){
						salir = false;
						Database.rollback(puntoGuardado);
						system.debug(e.getStackTraceString());
            			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_ELIMINAR_REGISTRO));
             			}
     				}
					catch(Exception e){
						salir = false;
						Database.rollback(puntoGuardado);
						system.debug(e.getStackTraceString());
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_ELIMINAR_REGISTRO));
					}
				}
			} 
		}

		if(salir){
			if(retURLRetorno != null){
				paginaRedireccion = new PageReference(retURLRetorno);
				if(codigoVDN != null){
					paginaRedireccion.getParameters().put('VDN', codigoVDN);
				}
			}
		}
		return paginaRedireccion;
	}//FIN cancelar()
	
	/**
       * [PENDIENTE]
       * 
        * @param idGrupo: [PENDIENTE]
       * 
        * @return [PENDIENTE]
       */  
	
	public void mostrarAyudaTelefonoCIA(){
		system.debug('***** idTelefonoCIA : ' + idTelefonoCIA);
		if (idTelefonoCIA != null){
			//PREV
			/*List<Telefonos_Transfer_CIA__c> listaTelefonosTransferCIA = new List<Telefonos_Transfer_CIA__c>(
				[SELECT TTC_TXT_Ayuda__c FROM Telefonos_Transfer_CIA__c WHERE Id = :idTelefonoCIA]);*/
			//NEW
			Set <Id> setTelefonos = new Set<Id>();
			setTelefonos.add(idTelefonoCIA);
			List<Telefonos_Transfer_CIA__c> listaTelefonosTransferCIA = new List<Telefonos_Transfer_CIA__c>( Util_Telef_TransferCIA.queryMapTelefonoTransferCIA(setTelefonos).values() );
			//END_NEW
			system.debug('***** ');
			if (!listaTelefonosTransferCIA.isEmpty()){
				String ayuda = listaTelefonosTransferCIA.get(0).TTC_TXT_Ayuda__c;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ayuda));		
			}
		}
	}
}//FIN B2C_Argumentario