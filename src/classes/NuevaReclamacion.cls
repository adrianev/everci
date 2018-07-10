/**
 * Clase controladora de la Visualforce "NuevaReclamacion" encargada de gestionar la creación de reclamaciones
 * 
 * @author EVERIS
 */
public without sharing class NuevaReclamacion {

	public Case reclamacion;
	public ApexPages.standardController controlador;
	public Case casoPadre;
	public WorkOrder woPadre;
	public Boolean booleanUrgente {get; set;}
	public Boolean esGestorFront {get;set;}
	public Boolean esGestorRecl {get;set;}
	public Boolean esPerfilRecl {get;set;}
	public Boolean customNaturaleza {get;set;}
	public Boolean esSolicitud {get;set;}
	public Boolean woAbierta {get;set;}	
	public List<String> listaNaturalezasBorrar;
	public Map<String,String> naturalezaClaveValor;
	public Map<String,String> reemplazos;
	public List<String> nClaveValor;
	

	public String ultimoValorNaturaleza {get;set;}

	public String gremio {get;set;}

	public String cia{get;set;}
	
	public List<SelectOption> valoresTipo {get;set;}
	public List<SelectOption> valoresComunica {get;set;}
	public List<SelectOption> valoresGremio {get;set;}
	public List<SelectOption> valoresGremioPart {get;set;}
	public List<SelectOption> valoresGremioFull {get;set;}
    public String gremioConf {get; set;}

	/**
    * 
 	* Constructor de la clase
 	* 
 	*/  
	public NuevaReclamacion(ApexPages.standardController stdCtr){
		Set<String> customCIA = new Set<String>{'1023','1040','1018'};
		
		List<String> fields = new List<String> {'Id','Status'};
		if(!Test.isRunningTest()){
			stdCtr.addFields(fields);
		}
		booleanUrgente = false;
		reclamacion = (Case)stdCtr.getRecord();
		controlador = stdCtr;
		customNaturaleza = False;
		woAbierta = false;
		cia = '';
		gremio = null;
		esGestorFront = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_FRONT_TRAMITACION);
		esGestorRecl = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_RECLAMACIONES
						|| Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_ADMINISTRADOR);
		esPerfilRecl = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_RECLAMACIONES
						|| Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_SUPERVISOR_RECLAMACIONES
						|| Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_ADMINISTRADOR);
		
		PageReference paginaActual = ApexPages.currentPage();
		
		if (paginaActual.getParameters().containsKey('SOLICITUD') && paginaActual.getParameters().get('SOLICITUD') == 'Y'){
			esSolicitud = true;
			
			if (paginaActual.getParameters().containsKey('id') && !String.isBlank(paginaActual.getParameters().get('id'))){
				reclamacion.Id = paginaActual.getParameters().get('id');
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha encontrado Id'));
			}
			
		} else {
			
			if (paginaActual.getParameters().containsKey('id') && !String.isBlank(paginaActual.getParameters().get('id'))){
				reclamacion.Id = paginaActual.getParameters().get('id');
			}
			
			if (paginaActual.getParameters().containsKey('cuenta') && !String.isBlank(paginaActual.getParameters().get('cuenta'))){
				reclamacion.AccountId = paginaActual.getParameters().get('cuenta');
			}
			if (paginaActual.getParameters().containsKey('gremio')){
				//reclamacion.CAS_SEL_Gremio_Principal__c = paginaActual.getParameters().get('gremio');
				gremio = paginaActual.getParameters().get('gremio');
                system.debug(gremio + ' gremio');
			}
			if (paginaActual.getParameters().containsKey('caso') && !String.isBlank(paginaActual.getParameters().get('caso'))){
				reclamacion.ParentId = paginaActual.getParameters().get('caso');
				Set<Id> idCasos = new Set<Id>();
				idCasos.add(reclamacion.ParentId);
				casoPadre = Util_Caso.getCaseById(idCasos).get(reclamacion.ParentId);
				//casoPadre = Util_Caso.getMapaCasos(idCasos).get(reclamacion.ParentId);
				//List<Case> auxList = [Select id, RecordtypeId, Type, Recordtype.Name, CAS_LKP_Compania__r.CUE_TXT_Identificador__c, CAS_LKP_Compania__c,CAS_LKP_Procedencia__c from Case where id =: reclamacion.ParentId];
				if(casoPadre != null){
					//casoPadre = auxList[0];
					reclamacion.CAS_LKP_Procedencia__c = casoPadre.CAS_LKP_Procedencia__c;
					reclamacion.CAS_LKP_PolizaContrato__c = casoPadre.CAS_LKP_PolizaContrato__c;
					Id recordTypeIdSini = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
					Id recordTypeIdServB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C);
					Id recordTypeIdServB2B = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
	
					if(casoPadre.RecordtypeId == recordTypeIdSini)
						reclamacion.CAS_SEL_Padre_reclamacion__c = casoPadre.Type;
					else if(casoPadre.RecordtypeId == recordTypeIdServB2C || casoPadre.RecordtypeId == recordTypeIdServB2B)
						reclamacion.CAS_SEL_Padre_reclamacion__c = Label.CAS_TIPOLOGIA_ASISTENCIA;
	
					if(reclamacion.AccountId == null)
						reclamacion.AccountId = casoPadre.AccountId;
					
					cia = casoPadre.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
					
					system.debug('-----casoPadre.RecordtypeId: '+casoPadre.RecordtypeId);
					system.debug('-----casoPadre.RecordtypeId == recordTypeIdSini: '+(casoPadre.RecordtypeId == recordTypeIdSini));
					system.debug('-----casoPadre.RecordtypeId == recordTypeIdServB2C: '+(casoPadre.RecordtypeId == recordTypeIdServB2C));
					system.debug('-----casoPadre.RecordtypeId == recordTypeIdServB2C: '+(casoPadre.RecordtypeId == recordTypeIdServB2C));
					Map<Id,Workorder> wosCaso = Util_Orden_Trabajo.queryMapOTByCase(new Set<Id>{casoPadre.Id});
					if(!wosCaso.isEmpty()){
						for(Workorder wo: wosCaso.values()){
							if(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(wo.Status))
								woAbierta = true;
						}
					}
					
				}
	
			}
			if (paginaActual.getParameters().containsKey('workorder')){
				reclamacion.CAS_LKP_Recl_Orden_Trabajo__c = paginaActual.getParameters().get('workorder');
				List<WorkOrder> auxList = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{reclamacion.CAS_LKP_Recl_Orden_Trabajo__c}).values();
				//List<WorkOrder> auxList = Util_Orden_Trabajo.queryOT(reclamacion.CAS_LKP_Recl_Orden_Trabajo__c,null,null);
				//List<WorkOrder> auxList = [Select id, recordtype.Name,OTR_FOR_Identificador_CIA__c,Case.CAS_LKP_Compania__c,CaseId,Case.CAS_LKP_Procedencia__c from WorkOrder where id =: reclamacion.CAS_LKP_Recl_Orden_Trabajo__c];
				if(!auxList.isEmpty()){
					woPadre = auxList[0];
					reclamacion.CAS_LKP_Procedencia__c = woPadre.Case.CAS_LKP_Procedencia__c;
					reclamacion.CAS_LKP_PolizaContrato__c = woPadre.Case.CAS_LKP_PolizaContrato__c;
					reclamacion.CAS_SEL_Padre_reclamacion__c = Label.CAS_TIPOLOGIA_REPARACION;
					cia = woPadre.OTR_FOR_Identificador_CIA__c;
					
					if(reclamacion.AccountId == null)
						reclamacion.AccountId = woPadre.AccountId;
						
					if(gremio==null)
						gremio = woPadre.OTR_SEL_Gremio__c;
						
					if(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(woPadre.Status))
						woAbierta = true;
				}
	
			}
		

			reclamacion.RecordtypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
			reclamacion.Status = Label.CAS_ESTADO_PDTE_ANALISIS;
	
			if(reclamacion.CAS_LKP_Recl_Orden_Trabajo__c != null){
				if(woPadre != null)
					reclamacion.CAS_LKP_Compania__c = woPadre.Case.CAS_LKP_Compania__c;
			} else if(reclamacion.ParentId != null){
				if(casoPadre != null)
					reclamacion.CAS_LKP_Compania__c = casoPadre.CAS_LKP_Compania__c;
			}
	
	
			listaNaturalezasBorrar = new List<String>();
			Map<String,List<Naturaleza__mdt>> naturalezas = Util_Metadatos.mapaNaturalezaCIA;
			List<Naturaleza__mdt> temp = new List<Naturaleza__mdt>();
			for(List<Naturaleza__mdt> nats : naturalezas.values()){
				temp.addAll(nats);
			}
			for(Naturaleza__mdt nat: temp){
				listaNaturalezasBorrar.add(nat.MTD_NAT_TXT_Naturaleza_cia__c);
			}
	
			if(customCia.contains(cia)){
				customNaturaleza = true;
				rellenarReemplazosNaturaleza();
			}
			
			valoresTipo = rellenarTipoRecl();
			
			valoresComunica = opcionesQuienComunica();
			
			opcionesGremio();
			system.debug(' aqui entraaaaaa' +  valoresGremioFull);
			valoresGremio = valoresGremioFull;
            Configuracion_General__mdt confGeneral = Util_Metadatos.CONFIG_GENERAL.get('GremiosUrgentes');
            system.debug(confGeneral + ' gremiosUrgentes');
			if(confGeneral != null && confGeneral.CF_TXT_Valor__c != null){
			gremioConf = ';' + confGeneral.CF_TXT_Valor__c + ';';
            system.debug(gremioConf + ' gremiosUrgentes');
                
			}
		}

	}
	
	/**
    * 
 	* Método encargado de reemplazar las naturalezas de HS por las de la compañía en cuestión
 	* 
 	*/ 
	public void rellenarReemplazosNaturaleza(){

		if(!String.isBlank(cia)){

			List<Naturaleza__mdt> naturalezas = Util_Metadatos.mapaNaturalezaCIA.get(cia);
			Set<String> nuevosVal = new Set<String>();
			naturalezaClaveValor = new Map<String,String>();    
			nClaveValor = new List<String>();
			reemplazos = new Map<String,String>();

			if(naturalezas != null){

				for(Naturaleza__mdt nat: naturalezas){
					listaNaturalezasBorrar.add(nat.MTD_NAT_TXT_Naturaleza_HS__c);
					nuevosVal.add(nat.MTD_NAT_TXT_Naturaleza_cia__c);
					reemplazos.put(nat.MTD_NAT_TXT_Naturaleza_HS__c, nat.MTD_NAT_TXT_Naturaleza_cia__c);
				}
				Schema.DescribeFieldResult fieldResult = Case.CAS_SEL_Naturaleza__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

				for(Schema.PicklistEntry f : ple){
					if(nuevosVal.contains(f.getLabel())){
						naturalezaClaveValor.put(f.getLabel(), f.getValue());
						nClaveValor.add(f.getLabel()+';'+f.getValue());
					}
				}
			}
		}
	}

	public String getListaNaturalezasBorrar(){
		return String.escapeSingleQuotes(JSON.serialize(listaNaturalezasBorrar));
	}
    
  //linea Alberto  SFDCHC-552.COM_Bug.Reclamaciones (Worten). Error cita urgente
    public Boolean validarCheckUrgente(){
        
		Boolean varReturn = true;
		if(gremioConf == null){
            system.debug('entra aqui');
			gremioConf = '';
		}
		//Si se ha marcado el check de urgente de la visual
		system.debug(reclamacion.CAS_CAS_Solicitud_Urgente__c + ' reclamacion pendiente');
		if(reclamacion.CAS_CAS_Solicitud_Urgente__c){
            system.debug(valoresGremio + ' gremio1');
			//Compruebo si el gremio permite urgente
			system.debug(reclamacion.CAS_SEL_Gremio_Principal__c + ' gremio');
			if(reclamacion.CAS_SEL_Gremio_Principal__c != null && gremioConf.contains(';'  + reclamacion.CAS_SEL_Gremio_Principal__c + ';')){
                
                system.debug('entra aqui' + valoresGremio);
				varReturn = true;
			}
			else {
				//reclamacion.CAS_CAS_Solicitud_Urgente__c = false;
                system.debug('entra aqui');
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.INFO_GREMIO_NO_URGENTE));
                system.debug('entra aqui');
				varReturn = false;
			}
		}
		return varReturn;
	}
    

	public String getNClaveValor(){
		return String.escapeSingleQuotes(JSON.serialize(nClaveValor));
	}

	public String getNaturalezaClaveValor(){
		return String.escapeSingleQuotes(JSON.serialize(naturalezaClaveValor));
	}

	public String getReemplazos(){
		return String.escapeSingleQuotes(JSON.serialize(reemplazos));
	}

	/**
    * 
 	* Método encargado de guardar la reclamación
 	* 
	 * @return página a navegar tras guardar
 	*/
	public PageReference guardar(){
	 
       

		
	if(reclamacion.CAS_SEL_Estado_Expediente__c != LABEL.CAS_TIPO_RECL_QUEJA && reclamacion.CAS_SEL_Estado_Expediente__c
       != LABEL.CAS_TIPO_RECL_TERMINADA && reclamacion.CAS_SEL_Requiere_profesional__c == '01'){
			if (String.isBlank(reclamacion.CAS_SEL_Requiere_el_mismo_profesional__c)){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Si la reclamación requiere profesional, se debe señalar si desea el mismo'));
				return null;
			} else if(String.isBlank(reclamacion.CAS_SEL_Gremio_Principal__c)){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Si la reclamación requiere profesional, se debe señalar el gremio del mismo'));
				return null;
			} /*else if (!String.isBlank(gremio) && reclamacion.CAS_SEL_Gremio_Principal__c == gremio && String.isBlank(reclamacion.CAS_SEL_Requiere_el_mismo_profesional__c)){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Si se selecciona el mismo gremio que el trabajo anterior, se debe señalar si desea el mismo profesional'));
				return null;
			}*/
		}
        
		
		if(reclamacion.CAS_DAT_Fecha_Vencimiento__c != null){
			if(reclamacion.CAS_DAT_Fecha_Vencimiento__c > System.Today().addMonths(2)){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'La fecha de vencimiento no puede ser posterior a dos meses con respecto a la actual'));
				return null;
			}
		}
		
		if(reclamacion.CAS_SEL_Estado_Expediente__c != LABEL.CAS_TIPO_RECL_QUEJA &&
		 	reclamacion.CAS_SEL_Estado_Expediente__c != LABEL.CAS_TIPO_RECL_TERMINADA &&
		 	(reclamacion.CAS_SEL_Naturaleza__c == '017' ||
		 	reclamacion.CAS_SEL_Naturaleza__c == '018' ||
		 	reclamacion.CAS_SEL_Naturaleza__c == '019' ||
		 	reclamacion.CAS_SEL_Naturaleza__c == '008') &&
		 	!woAbierta &&
		 	!esPerfilRecl){
		 		
			reclamacion.CAS_SEL_Requiere_profesional__c = '02';
		}
        
       //Linea Alberto SFDCHC-552.COM_Bug.Reclamaciones (Worten). Error cita urgente 
       if(reclamacion.CAS_CAS_Solicitud_Urgente__c){
            system.debug(validarCheckUrgente() + ' queeeeeeeee');
            if(!validarCheckUrgente()){
                return null;
            } 
        }
		

		reclamacion.CAS_DAT_Fecha_Apertura__c = System.now();

		ultimoValorNaturaleza = reclamacion.CAS_SEL_Naturaleza__c;

		system.debug('--------gremio: '+reclamacion.CAS_SEL_Gremio_Principal__c);

		PageReference paginaRedireccion = controlador.save();

		Id recID = controlador.getId();
		
		if(recID != null){
			reclamacion.Id = recId;
			//TODO: Pasarlo al trigger?
			if(reclamacion.CAS_SEL_Estado_Expediente__c == LABEL.CAS_TIPO_RECL_QUEJA
					|| reclamacion.CAS_SEL_Estado_Expediente__c == LABEL.CAS_TIPO_RECL_TERMINADA){
						
				Case updateRec = new Case(Id=recId);		
				updateRec.Status = LABEL.CAS_ESTADO_CERRADO;
				if(reclamacion.CAS_SEL_Estado_Expediente__c == LABEL.CAS_TIPO_RECL_QUEJA){
					updateRec.CAS_SEL_Motivo_de_Cierre__c = Label.CAS_MOTIVO_DE_CIERRE_RECLAMACION2;
				}else if(reclamacion.CAS_SEL_Estado_Expediente__c == LABEL.CAS_TIPO_RECL_TERMINADA){
					updateRec.CAS_SEL_Motivo_de_Cierre__c = Label.CAS_MOTIVO_DE_CIERRE_RECLAMACION;
				}
                                
       			
				
				//Esto es para saltarnos la regla de validación de que no se puede editar
				//caso en estado cerrado. Como se crea en cerrado y hay un update para el identificador
				//salta la regla. Así que cerramos después de que se genere el identificador, saltando los triggers
				Baipas.establecerVariableControl();
				update updateRec;
				Baipas.deshabilitarVariableControl();
				
			}
			
			try{
			 // notificarProfesional();
			} catch(Exception e){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
				return null;
			}
			

			if(paginaRedireccion != null && reclamacion.CAS_SEL_Requiere_profesional__c == '01' && reclamacion.Status != Label.CAS_ESTADO_RECLAMACION_DORMIDA){

				List<WorkOrder> wos = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordType(new Set<Id>{recID},new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)}).values();
				//List<WorkOrder> wos = Util_Orden_Trabajo.queryOT(null,recID,'RecordTypeId = \''+Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)+'\'');//[SELECT Id from WorkOrder where CaseId = :recID AND RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)];
	
				if(!wos.isEmpty()){
					if(reclamacion.ParentId == null)
						asignarPreferencias(reclamacion.CAS_LKP_Recl_Orden_Trabajo__c,wos[0].id,reclamacion.CAS_SEL_Requiere_el_mismo_profesional__c);
					else{
						List<WorkOrder> wosPadre = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordTypeAndGremio(new Set<Id>{reclamacion.ParentID},new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)},new Set<String>{reclamacion.CAS_SEL_Gremio_Principal__c}).values();
						//List<WorkOrder> wosPadre = Util_Orden_Trabajo.queryOT(null,reclamacion.ParentID,'RecordTypeId != \''+Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)+'\' AND OTR_SEL_Gremio__c = \'' + reclamacion.CAS_SEL_Gremio_Principal__c +'\'');
						
						if(!wosPadre.isEmpty()){
							asignarPreferencias(wosPadre[0].Id,wos[0].id,reclamacion.CAS_SEL_Requiere_el_mismo_profesional__c);
						}
					}
	
	
					paginaRedireccion = new PageReference('/apex/'+Label.VF_B2B_REPARABLE);
					//paginaRedireccion = new PageReference('/apex/' + Label.VF_RESERVARCITA);
					paginaRedireccion.getParameters().put('id', recID);
					//paginaRedireccion.getParameters().put('idOrdenTrabajo', wos[0].Id);
					//paginaRedireccion.getParameters().put('retorno', '/' + recID);
					paginaRedireccion.getParameters().put('inline', '1');
					paginaRedireccion.setRedirect(true);
				}
            
			}
        }
        
 

         

		return paginaRedireccion;
        
	}

	/**
    * 
 	* Método encargado de asignar las preferencias a las órdenes de trabajo
 	* @param woId: Id de la WorkOrder original
	 * @param woNewId: Id de la WorkOrder nueva con los recursos asignados
	 * @param mismoProfesional: Indica si el cliente prefiere el mismo profesional o no
 	* 
	 * @return true si ha habido algún error en el proceso, si no false
 	*/
	public static Boolean asignarPreferencias(Id woId, Id woNewId, String mismoProfesional){

		Workorder wo = null;
		List<WorkOrder> listaOTs = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).values();
		//List<WorkOrder> listaOTs = Util_Orden_Trabajo.queryOT(woId,null,null);
		if(!listaOTs.isEmpty()){
			wo = listaOTs.get(0);//[Select id,OTR_LKP_Recurso_Servicio__c,OTR_SEL_Gremio__c from Workorder where Id = :woId];
		}
		else{
			return true;  // Si wo es null dará error
		}
		
		ServiceResource recProfesional = null;
		//Set<Id> setIdRS = null;
		if(wo.OTR_LKP_Recurso_Servicio__c == null){
			List<ServiceResource> recList = Util_Service_Resource.queryMapSRByWoIds(new Set<Id>{woId}).values();
			//List<ServiceResource> recList = Util_Service_Resource.queryMapSR('Id IN (SELECT ServiceResourceId FROM AssignedResource WHERE ServiceAppointment.ParentRecordId = \''+woId+'\')').values();
			//List<ServiceResource> recList = Util_Documentacion.querySR('Id IN (SELECT ServiceResourceId FROM AssignedResource WHERE ServiceAppointment.ParentRecordId = \''+woId+'\')');//[select id, RelatedRecordId from ServiceResource where Id in (Select ServiceResourceId from AssignedResource where ServiceAppointment.ParentRecordId = :woId)];
			if(!recList.isEmpty())
				recProfesional = recList[0];

		} else {
			//setIdRS = new Set<Id>();
			//setIdRS.add(wo.OTR_LKP_Recurso_Servicio__c);
			List<ServiceResource> recList = Util_Service_Resource.queryMapSRByRsIds(new Set<Id>{wo.OTR_LKP_Recurso_Servicio__c}).values();
			//List<ServiceResource> recList = Util_Service_Resource.queryMapSR('Id = \''+wo.OTR_LKP_Recurso_Servicio__c+'\'').values();
			//List<ServiceResource> recList = Util_Documentacion.querySR('Id = \''+wo.OTR_LKP_Recurso_Servicio__c+'\'');//[Select id, RelatedRecordId from ServiceResource where id = :wo.OTR_LKP_Recurso_Servicio__c];
			if(!recList.isEmpty())
				recProfesional = recList[0];
		}

		Boolean error = false;
		if(recProfesional != null){
			ResourcePreference rp = new ResourcePreference();

			rp.ServiceResourceId = recProfesional.Id;
			if(mismoProfesional == 'SI')
				rp.PreferenceType = 'Required';
			else
				rp.PreferenceType = 'Excluded';

			rp.RelatedRecordId = woNewId;

			try{
				insert rp;
			} catch(Exception e){
				error = true;
				System.debug('Error: '+e.getMessage());

			}
		}

		return error;

	}
	
	private List<SelectOption> rellenarTipoRecl(){
		List<SelectOption> options = new List<SelectOption>();
		
		Map<String,List<Tipo_de_Reclamacion__mdt>> mapaTipos = Util_Metadatos.mapaTipoReclamacionCIA;
	    
	    List<Tipo_de_Reclamacion__mdt> listaCIA = mapaTipos.get(cia);
	    
	    Set<String> tiposReclCIA = new Set<String>();
	    
	    if(listaCIA != null){
	    	for(Tipo_de_Reclamacion__mdt tRec: listaCIA){
	    		tiposReclCIA.add(tRec.MTD_TIPORECL_TXT_Tipo_de_la_Reclamacion__c);
	    	}
	    }
	    
	    if(!tiposReclCIA.isEmpty()){
			Schema.DescribeFieldResult fieldResult = Case.CAS_SEL_Tipo_de_reclamacion_del__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	
			for(Schema.PicklistEntry f : ple){
				
				system.debug('------------f: '+f);
				
				if(tiposReclCIA.contains(f.getValue())){
					options.add(new SelectOption(f.getValue(),f.getLabel()));
				}
			}
			
			system.debug('---------options: ' + options);
	    }
	    
	    if(options.isEmpty()){
	    	options.add(new SelectOption('','--Ninguno--'));
	    }
	    
		return options;
	}
	
	private List<SelectOption> opcionesQuienComunica(){
		List<SelectOption> options = new List<SelectOption>();
		
		Schema.DescribeFieldResult fieldResult = Case.CAS_SEL_Comunicador_Recl__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		options.add(new SelectOption('','--Ninguno--'));
		
		for(Schema.PicklistEntry f : ple){
			
			system.debug('------------f: '+f);
			
			if(esGestorRecl || f.getValue() != '007'){
				options.add(new SelectOption(f.getValue(),f.getLabel()));
			}
		}
		
		system.debug('---------options: ' + options);
		
		return options;
	}
	
	public void opcionesGremio(){
		List<SelectOption> options = new List<SelectOption>();
		List<SelectOption> optionsFull = new List<SelectOption>();

		List<WorkOrder> wos = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordType(new Set<Id>{reclamacion.ParentID},new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)}).values();
		//List<WorkOrder> wos = Util_Orden_Trabajo.queryOT(null,reclamacion.ParentID,'RecordTypeId != \''+Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)+'\'');
		
		Set<String> gremios = new Set<String>();
	
		if(!wos.isEmpty()){
            for(Workorder wo: wos){
                system.debug(wo.OTR_SEL_Gremio__c + ' añadimos gremios');
				gremios.add(wo.OTR_SEL_Gremio__c);
            }
		}
	
		Schema.DescribeFieldResult fieldResult = Case.CAS_SEL_Gremio_Principal__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		options.add(new SelectOption('','--Ninguno--'));
		optionsFull.add(new SelectOption('','--Ninguno--'));
		
		for(Schema.PicklistEntry f : ple){
			
			system.debug('------------f: '+f);
			
			if(reclamacion.ParentId == null || gremios.contains(f.getValue())){
				options.add(new SelectOption(f.getValue(),f.getLabel()));
			}
			optionsFull.add(new SelectOption(f.getValue(),f.getLabel()));
		}
		
		system.debug('---------options: ' + options);
		
		valoresGremioPart = options;
		valoresGremioFull = optionsFull;		

		//return null;
	}
	
	public pageReference cambiarGremio(){
		if(reclamacion.CAS_SEL_Requiere_el_mismo_profesional__c == 'SI'){
            system.debug(valoresGremioPart + ' 1');
            
			valoresGremio = valoresGremioPart;
		} else {
            system.debug(valoresGremioFull + ' 2');
			valoresGremio = valoresGremioFull;
		}
		
		return null;
	}
	
	public pageReference cambiarGremioPart(){
		valoresGremio = valoresGremioPart;
		return null;
	}
	
	public pageReference cambiarGremioFull(){
		valoresGremio = valoresGremioFull;
		return null;
	}
	
	public pageReference continuarSolicitud(){
		
		if(reclamacion.ParentId == null && reclamacion.CAS_LKP_Recl_Orden_Trabajo__c == null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Debe seleccionar el servicio o la intervención origen de la reclamación'));
			return null;
		}
		
		if(reclamacion.ParentId != null && reclamacion.CAS_LKP_Recl_Orden_Trabajo__c != null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sólo se puede seleccionar servicio o intervención, no los dos'));
			return null;
		}
		
		if(reclamacion.ParentId != null){
			Case padre = Util_Caso.getCaseById(new Set<Id>{reclamacion.ParentId}).get(reclamacion.ParentId);
			if(padre != null){
				
				if(padre.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se puede crear una reclamación de otra reclamación'));
					return null;
				}
				
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha encontrado caso asociado'));
				return null;
			}
			
		} else {
			Workorder woPadre = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{reclamacion.CAS_LKP_Recl_Orden_Trabajo__c}).get(reclamacion.CAS_LKP_Recl_Orden_Trabajo__c);
			
			if(woPadre != null){
				
				if(woPadre.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se puede crear una reclamación de otra reclamación'));
					return null;
				}
				
				if(woPadre.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se puede crear una reclamación de un servicio en revisión'));
					return null;
				}
				
				
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha encontrado servicio asociado'));
				return null;
			}
		}
		
		PageReference page = new PageReference('/apex/'+Label.VF_NUEVA_RECLAMACION);
		page.getParameters().put('id', reclamacion.Id);
		if(reclamacion.ParentId != null)
			page.getParameters().put('caso', reclamacion.ParentId);
		else if(reclamacion.CAS_LKP_Recl_Orden_Trabajo__c != null)
			page.getParameters().put('workorder', reclamacion.CAS_LKP_Recl_Orden_Trabajo__c);
		page.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
		page.getParameters().put('inline', '1');
				
		page.setRedirect(true);
		return page;
	}
	 /*  
	public Boolean notificarProfesional(){
		
		if(reclamacion.ParentId == null){
			
			Workorder wo;
			List<WorkOrder> listaOTs = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{reclamacion.CAS_LKP_Recl_Orden_Trabajo__c}).values();
            system.debug(reclamacion.ParentId + ' pruebaaaa1');
			//List<WorkOrder> listaOTs = Util_Orden_Trabajo.queryOT(woId,null,null);
			if(!listaOTs.isEmpty()){
				wo = listaOTs.get(0);//[Select id,OTR_LKP_Recurso_Servicio__c,OTR_SEL_Gremio__c from Workorder where Id = :woId];
			}
			else{
				return true;  // Si wo es null dará error
			}
			
			Id profesional = wo.OTR_LKP_Recurso_Servicio__r.RelatedRecordId;
            system.debug(profesional + ' profesional');
			
			User destinatario = Util_Perfiles_Usuario.queryMapUsuario(new Set<Id>{profesional}).get(profesional);
            system.debug(destinatario + ' destinatario');
			
			Baipas.establecerVariableControl(); //Ahorrar queries para un contacto que se va a eliminar al final del método
			Contact contactoDestinatario = Util_Correo_Electronico.generarDummyContact(destinatario.FirstName,destinatario.LastName,destinatario.Email,null,null);		
			Baipas.deshabilitarVariableControl();
			
			String asunto = 'Se ha abierto una reclamación al servicio '+wo.WorkorderNumber;
			String body = 'TEST';
			String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
			if(!Test.isRunningTest()) Util_Correo_Electronico.enviarSingleEmailSinPlantilla(reclamacion.Id,asunto,body,'HTML',contactoDestinatario.Id,null,null,correoRemitente,null);
				
			return false;
			
		} else{
			List<WorkOrder> wosPadre = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordTypeAndGremio(new Set<Id>{reclamacion.ParentID},new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)},new Set<String>{reclamacion.CAS_SEL_Gremio_Principal__c}).values();
			//List<WorkOrder> wosPadre = Util_Orden_Trabajo.queryOT(null,reclamacion.ParentID,'RecordTypeId != \''+Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)+'\' AND OTR_SEL_Gremio__c = \'' + reclamacion.CAS_SEL_Gremio_Principal__c +'\'');

			if(!wosPadre.isEmpty()){
				Set<Id> profesionales = new Set<Id>();
				for(Workorder wo: wosPadre){
					profesionales.add(wo.OTR_LKP_Recurso_Servicio__r.RelatedRecordId);
				}
				
				if(!profesionales.isEmpty()){
					String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
					
					String asunto = 'Se ha abierto una reclamación a la intervención '+wosPadre[0].Case.CaseNumber;
					String body = 'TEST';
					for(Id prof: profesionales){
						User destinatario = Util_Perfiles_Usuario.queryMapUsuario(new Set<Id>{prof}).get(prof);
			
						Baipas.establecerVariableControl(); //Ahorrar queries para un contacto que se va a eliminar al final del método
						Contact contactoDestinatario = Util_Correo_Electronico.generarDummyContact(destinatario.FirstName,destinatario.LastName,destinatario.Email,null,null);		
						Baipas.deshabilitarVariableControl();
						

						if(!Test.isRunningTest()) Util_Correo_Electronico.enviarSingleEmailSinPlantilla(reclamacion.Id,asunto,body,'HTML',contactoDestinatario.Id,null,null,correoRemitente,null);
						
					}
				}
			}
			
			return false;
		}

		
	}
	
*/
}