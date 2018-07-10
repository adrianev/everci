/**
 * Todo: Clase que se utilizará para el Trigger Reclamacion_IR. 
 * @author everis
 * @version 1.0
 */
public without sharing class TRG_Handler_MovimientoIR implements Queueable{
	private List<Case> listReclamacion = new List<Case>();
	private List<Case> listDelete = new List<Case>();
	Map<Id, Case> mapaCases= new Map<Id,Case>();
	private List<WorkOrder> listWorkOrder = new List<WorkOrder>();
	Boolean eliminar = false;
	private String workOrderNumber = '';
	private String operacion;
    @testVisible
	private DateTime fechaCierreServicio;
	public TRG_Handler_MovimientoIR(List<Case> listReclamacion, String operacion){
		this.listReclamacion = listReclamacion;
		this.operacion = operacion;
	}
	public TRG_Handler_MovimientoIR(List<WorkOrder> listWorkOrder, String operacion){
		this.listWorkOrder = listWorkOrder;
		this.operacion = operacion;
	}
	public TRG_Handler_MovimientoIR(Map<Id,Case> mapDelete, String operacion){
		this.mapaCases = mapDelete;
		this.operacion = operacion;
		this.eliminar = true;
	}
	/**
	 *	Este metodo actualiza la tabla teléfonos de IR
	 *	@param TRG_Handler_Contacto.actPhone datos						-  datos del Trigger.newMap
	 */	
	public static void actualizaTelefono(List<TRG_Handler_Contacto.actPhone> datos){
		List<String> ids = new List<String>();
		List<String> dnis = new List<String>();
		List<Movimiento_IR__c> insertIR = new List<Movimiento_IR__c>();
		Movimiento_IR__c telefono;
		for(TRG_Handler_Contacto.actPhone aux:datos){
			ids.add(aux.id);
			dnis.add(aux.dni);
		}
		List<Contact> infoContact = new List<Contact>();
		if(!ids.isEmpty() && !dnis.isEmpty()){
			infoContact = Util_Contacto.getContactById(new Set<Id>((List<Id>)ids)).values();
			/*infoContact = new List<Contact>(
					[SELECT Account.CUE_TXT_Numero_Documento__c
					 FROM   Contact 
					 WHERE  Id IN: ids]);*/
		}
		if(infoContact != null && !infoContact.isEmpty()){
			for(Contact aux:infoContact){
				for(TRG_Handler_Contacto.actPhone dat:datos){
					if(dat.Id == aux.Id){
						telefono = new Movimiento_IR__c();
						telefono.MIR_TXT_OPERACION__c = Label.MIR_Procedimiento;
						telefono.MIR_TXT_CLIENTE_VALOR__c = '\'0\'';
						telefono.MIR_TXT_DNI__c = '\''+aux.Account.CUE_TXT_Numero_Documento__c+'\'';
						if(telefono.MIR_TXT_DNI__c != null && telefono.MIR_TXT_DNI__c.contains('.'))
							telefono.MIR_TXT_DNI__c = telefono.MIR_TXT_DNI__c.replace('.','');
						telefono.MIR_TXT_TELEFONO__c = dat.phone;
						if(aux.Account.CUE_TXT_Numero_Documento__c != null){
							insertIR.add(telefono);
						}
					}
				}
			}
		}else{
			for(TRG_Handler_Contacto.actPhone dat:datos){
				telefono = new Movimiento_IR__c();
				telefono.MIR_TXT_OPERACION__c = Label.MIR_Procedimiento;
				telefono.MIR_TXT_CLIENTE_VALOR__c = '\'0\'';
				telefono.MIR_TXT_DNI__c = '\''+dat.dni+'\'';
				if(telefono.MIR_TXT_DNI__c != null && telefono.MIR_TXT_DNI__c.contains('.'))
							telefono.MIR_TXT_DNI__c = telefono.MIR_TXT_DNI__c.replace('.','');
				telefono.MIR_TXT_TELEFONO__c = dat.phone;
				if(dat.dni != null){
					insertIR.add(telefono);
				}	
			}
		}
		system.debug('insertIR '+insertIR);
		upsert insertIR;
	}   
	/**
	 *	Este metodo actualiza la tabla DNIs de IR
	 *	@param TRG_Handler_Contacto.actPhone datos						-  datos del Trigger.newMap
	 */		
	public static void actualizaCuentaIR(List<Account> datosUpdate){
		List<Movimiento_IR__c> insertIR = new List<Movimiento_IR__c>();
		Movimiento_IR__c insertoDatos;
		for(Account cuenta:datosUpdate){
			insertoDatos = new Movimiento_IR__c();
			insertoDatos.MIR_TXT_OPERACION__c = Label.MIR_Procedimiento;
			insertoDatos.MIR_TXT_CLIENTE_VALOR__c = '\'0\'';
			
			if(cuenta.CUE_TXT_PrimerApellido__c != null && cuenta.CUE_TXT_PrimerApellido__c != 'null'){
				insertoDatos.MIR_TXT_APELLIDOS__c = '\''+cuenta.CUE_TXT_PrimerApellido__c;
			} else {
				insertoDatos.MIR_TXT_APELLIDOS__c = '\'';
			}
			
			if(cuenta.CUE_TXT_SegundoApellido__c != null){
				insertoDatos.MIR_TXT_APELLIDOS__c += ' '+cuenta.CUE_TXT_SegundoApellido__c+'\'';
			} else {
				insertoDatos.MIR_TXT_APELLIDOS__c += '\'';
			}
			
			if(insertoDatos.MIR_TXT_APELLIDOS__c.contains(' null')){
				insertoDatos.MIR_TXT_APELLIDOS__c = insertoDatos.MIR_TXT_APELLIDOS__c.replaceAll(' null','');
			}
			
			if(insertoDatos.MIR_TXT_APELLIDOS__c.contains('null')){
				insertoDatos.MIR_TXT_APELLIDOS__c = insertoDatos.MIR_TXT_APELLIDOS__c.replaceAll('null','');
			}
			//insertoDatos.MIR_TXT_APELLIDOS__c = '\''+cuenta.CUE_TXT_PrimerApellido__c+' '+cuenta.CUE_TXT_SegundoApellido__c+'\'';
			insertoDatos.MIR_TXT_DNI__c = '\''+cuenta.CUE_TXT_Numero_Documento__c+'\'';
			insertoDatos.MIR_TXT_NOMBRE__c = '\''+cuenta.CUE_TXT_Nombre__c+'\'';
			if(cuenta.CUE_TXT_Numero_Documento__c != null){
				insertIR.add(insertoDatos);
			}
		}
		upsert insertIR;
	}     
	/**
	 *	Este metodo actualiza la tabla Claims de IR
	 *	@param WorkOrder datos						-  datos del Trigger.newMap
	 */	
	public static void actualizarOrdenTrabajo(List<WorkOrder> datos){
		List<String> listaCasos = new List<String>();
		Movimiento_IR__c movimientoIR = new Movimiento_IR__c();
		List<Movimiento_IR__c> insertIR = new List<Movimiento_IR__c>();
		for(WorkOrder aux:datos){
			listaCasos.add(aux.CaseId);
		}
		List<Case> casoId;
		if(!listaCasos.isEmpty()){
			casoId = Util_Caso.getCaseById(new Set<Id>((List<Id>)listaCasos)).values();
			//casoId = [SELECT Id, CaseNumber FROM Case WHERE Id IN :listaCasos];
		}
		if(casoId != null){
			for(Case aux:casoId){
				for(WorkOrder aux2:datos){
					if(aux2.CaseId == aux.Id){
						movimientoIR.MIR_TXT_OPERACION__c = Label.MIR_Procedimiento;
						movimientoIR.MIR_TXT_CLIENTE_VALOR__c = '\'0\'';
						movimientoIR.MIR_TXT_NUM_SINIESTRO__c = aux.CaseNumber;
						movimientoIR.MIR_TXT_NUM_SERVICIO__c = aux2.WorkOrderNumber;  
						insertIR.add(movimientoIR);					 
					}
				}
			}
		}
		insert insertIR;
	}
	
	/**
	 *	Este metodo actualiza la tabla Claims de IR
	 *	@param WorkOrder datos						-  datos del Trigger.newMap
	 */		
	private static Map<Id, User> getMapaUsers(Set<Id> setIds) {
		Map<Id, User> mapa = new Map<Id, User>();
		if (setIds != null && (!setIds.isEmpty())) {
			List<User> lista = Util_Perfiles_Usuario.queryMapUsuario(setIds).values();
			/*List<User> lista = new List<User>(
					[SELECT Id
							,USR_TXT_Presence_Login__c
					 FROM User WHERE Id IN :setIds]);*/
			for (User registro : lista) {
				mapa.put(registro.Id, registro);
			}
		}
		return mapa;
	}
	
	/**
	 *	Este metodo actualiza la tabla CLAIMS de IR
	 *	@param TRG_Handler_Contacto.actPhone datos						-  datos del Trigger.newMap
	 *  @param String operacion											-  nombre de la función que se ejecutará del procedimiento almacenado en IR
	 */	
	public void insertaCasoIR(){
		Movimiento_IR__c movimientoIR = new Movimiento_IR__c(); 
		List<Movimiento_IR__c> listaMovimientosIR = new List<Movimiento_IR__c>();
		Set<Id> listaIds = new Set<Id>();
		Set<Id> listaIdsCuenta = new Set<Id>();
		for(Case caso:listReclamacion){
			listaIds.add(caso.Id);
		}
		if(mapaCases.size() == 0){
			mapaCases = Util_Caso.getCaseById(listaIds);
			//mapaCases = Util_Caso.getMapaCasos(listaIds);
		}
		system.debug('mapaCases'+ mapaCases);
		Set<Id> owners = new Set<Id>();
		for(Case c:mapaCases.values()){
			owners.add(c.OwnerId);
			listaIdsCuenta.add(c.AccountId);
		}
		List<Movimiento_IR__c> listaMovimientosNoEnviados = new List<Movimiento_IR__c>();
		listaMovimientosNoEnviados = Util_Movimientos.getMovIRByEnviado(false,4999).values();
		//listaMovimientosNoEnviados = [SELECT MIR_TXT_NUM_SINIESTRO__c,MIR_TXT_TELEFONO__c FROM Movimiento_IR__c WHERE MIR_CAS_ENVIADO__c = False LIMIT 4999];
		Map<Id,User> mapaUsuariosPresenceLogin = getMapaUsers(owners);
		if(listReclamacion != null){
			List<Contact> listaCuenta;
			//listaCuenta = [SELECT CUE_TXT_Numero_Documento__c,CUE_TXT_PrimerApellido__c,CUE_TXT_SegundoApellido__c,CUE_TXT_Nombre__c, Phone, Id FROM Account WHERE Id IN: listaIdsCuenta]; 
			//List<Contact> listaContactos;
			listaCuenta = Util_Contacto.getContactByAccountId(listaIdsCuenta).values();
			/*listaCuenta = [SELECT Account.CUE_TXT_Numero_Documento__c, MobilePhone,HomePhone, Phone, Id, Account.CUE_TXT_PrimerApellido__c, Account.CUE_TXT_SegundoApellido__c,
								Account.CUE_TXT_Nombre__c, Account.Phone, Account.Id FROM Contact WHERE AccountId IN: listaIdsCuenta];*/
			List<TRG_Handler_Contacto.actPhone> listTelefonos = new List<TRG_Handler_Contacto.actPhone>();
			TRG_Handler_Contacto.actPhone telefonosIds;
			Boolean existeTel = false;
			for(Contact aux:listaCuenta){
				existeTel = false;
				for(Movimiento_IR__c MovNoEnviado:listaMovimientosNoEnviados){
						if(MovNoEnviado.MIR_TXT_TELEFONO__c!=null && (MovNoEnviado.MIR_TXT_TELEFONO__c == aux.MobilePhone || MovNoEnviado.MIR_TXT_TELEFONO__c == aux.HomePhone ||MovNoEnviado.MIR_TXT_TELEFONO__c == aux.Phone)){
							existeTel = true;
						}
				}
				if(aux.MobilePhone != null && aux.MobilePhone != '' && !existeTel){
					telefonosIds = new TRG_Handler_Contacto.actPhone();
					telefonosIds.Id = aux.Id;
					telefonosIds.phone = aux.MobilePhone;
					telefonosIds.dni = aux.Account.CUE_TXT_Numero_Documento__c;
					if(aux.Account.CUE_TXT_Numero_Documento__c != null){
						listTelefonos.add(telefonosIds);
					}
				}
				if(aux.HomePhone != null && aux.HomePhone != '' && !existeTel){
					telefonosIds = new TRG_Handler_Contacto.actPhone();
					telefonosIds.Id = aux.Id;
					telefonosIds.phone = aux.HomePhone;
					telefonosIds.dni = aux.Account.CUE_TXT_Numero_Documento__c;
					if(aux.HomePhone != null){
						listTelefonos.add(telefonosIds);
					}
				}
				if(aux.Phone != null && aux.Phone != '' && !existeTel){
					telefonosIds = new TRG_Handler_Contacto.actPhone();
					telefonosIds.Id = aux.Id;
					telefonosIds.phone = aux.Phone;
					telefonosIds.dni = aux.Account.CUE_TXT_Numero_Documento__c;
					if(aux.Phone != null){
						listTelefonos.add(telefonosIds);
					}
				}
			}
			if(listTelefonos != null && !listTelefonos.isEmpty()){
				actualizaTelefono(listTelefonos);
			}
			Map <Id, WorkOrder> MapWoNumber = Util_Orden_Trabajo.queryMapOTByCase(listaIds);
			//Map <Id, WorkOrder> MapWoNumber = Util_Orden_Trabajo.queryOTBySet(new Set<Id>(), listaIds, 'RecordTypeId != \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) + '\'');
			List<WorkOrder> WoNumber = new List <WorkOrder>();
			WoNumber = MapWoNumber.values();
			for(Case casoIn:mapaCases.values()){
				String tipoRegistro ='';
				Boolean existe = false;
				//Se rellenan todos los campos relacionados con la cuenta:
				for(Contact cuenta:listaCuenta){
					if(cuenta.Account.Id != CasoIn.AccountId){
						continue;
					}
					movimientoIR = new Movimiento_IR__c();
	
					//Se rellenan los campos relacionados con caso.
					if(casoIn.status != null){
						tipoRegistro = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.MIR_Reclamacion).getRecordTypeId();
						if(casoIn.RecordTypeId == tipoRegistro){
							if(casoIn.status != Label.MIR_CodiReclamacion1 && casoIn.status != Label.MIR_CodiReclamacion2){
								movimientoIR.MIR_TXT_RECLA_NO_CERRADA__c = '\'1\'';
							}
							else{
								movimientoIR.MIR_TXT_RECLA_NO_CERRADA__c = '\'0\'';
							}
						}else{
							if(casoIn.status != Label.MIR_CodiReclamacion1 && casoIn.status != Label.MIR_CodiReclamacion2)
								movimientoIR.MIR_TXT_SINI_NO_CERRADO__c = '\'1\'';
							else
								movimientoIR.MIR_TXT_SINI_NO_CERRADO__c = '\'0\'';
						}
					}
					if(casoIn.ClosedDate != null /*&& movimientoIR.MIR_DAT_fechaCierre__c != null*/){//Se ha quitado la condición "movimientoIR.MIR_DAT_fechaCierre__c != null" ya que nunca se dará, porque no se inicializa.
						movimientoIR.MIR_DAT_fechaCierre__c = casoIn.ClosedDate;
					}else if(eliminar){
						movimientoIR.MIR_DAT_fechaCierre__c = system.now();
					}
					if(fechaCierreServicio != null){
						movimientoIR.MIR_DAT_fechaCierre__c = fechaCierreServicio;
					}
					if(casoIn.CaseNumber != null){
						movimientoIR.MIR_TXT_ID_CASO__c = casoIn.CaseNumber ;
					}                    
					if(casoIn.CAS_CAS_Confirmado__c == null || casoIn.CAS_CAS_Confirmado__c == false){
						movimientoIR.MIR_TXT_CONF_PENDIENTE__c = '\'0\'';
					}else{
						movimientoIR.MIR_TXT_CONF_PENDIENTE__c = '\'1\'';
					}
	
					if(casoIn.CAS_SEL_Motivo_Indemnizable__c != null){
						movimientoIR.MIR_TXT_SERV_INDEMNI__c = casoIn.CAS_SEL_Motivo_Indemnizable__c;
					}
					if(casoIn.CAS_LKP_Procedencia__r.Name != null){
						movimientoIR.MIR_TXT_ID_PROCEDENCIA__c= '\''+casoIn.CAS_LKP_Procedencia__r.Name+'\'';
					}
					if(casoIn.CaseNumber != null){
						movimientoIR.MIR_TXT_NUM_SINIESTRO__c = '\''+casoIn.CaseNumber+'\'';
					}
					movimientoIR.MIR_TXT_ID_CASO__c = casoIn.Id;
	
					if(cuenta.Account.CUE_TXT_PrimerApellido__c != null){
						movimientoIR.MIR_TXT_APELLIDOS__c = '\''+cuenta.Account.CUE_TXT_PrimerApellido__c;
					}else{
						movimientoIR.MIR_TXT_APELLIDOS__c = '\'';
					}
					if(cuenta.Account.CUE_TXT_SegundoApellido__c != null){
						movimientoIR.MIR_TXT_APELLIDOS__c += ' '+cuenta.Account.CUE_TXT_SegundoApellido__c+'\'';
					}else{
						movimientoIR.MIR_TXT_APELLIDOS__c += '\'';
					}
					if(cuenta.Account.CUE_TXT_Nombre__c != null){
						movimientoIR.MIR_TXT_NOMBRE__c = '\''+cuenta.Account.CUE_TXT_Nombre__c+'\'';
					}
					if(cuenta.Account.CUE_TXT_Numero_Documento__c != null){
						movimientoIR.MIR_TXT_DNI__c = '\''+cuenta.Account.CUE_TXT_Numero_Documento__c+'\'';
					}
					/*if(cuenta.Account.CUE_FOR_Segmentacion__c != null){
						if(cuenta.Account.CUE_FOR_Segmentacion__c == '\'1\''){  
							movimientoIR.MIR_TXT_CLIENTE_VALOR__c = cuenta.Account.CUE_FOR_Segmentacion__c;
						}else{
							movimientoIR.MIR_TXT_CLIENTE_VALOR__c = '\'0\'';
						}
					}else{
						movimientoIR.MIR_TXT_CLIENTE_VALOR__c = '\'0\'';
					}	  
					*/
					//Si tiene algún motivo de servicio indemnizable, enviamos un 1, en caso contrario enviamos un 0
					if(movimientoIR.MIR_TXT_SERV_INDEMNI__c == null){
						movimientoIR.MIR_TXT_SERV_INDEMNI__c = '\'0\'';
					}
					else{
						movimientoIR.MIR_TXT_SERV_INDEMNI__c = '\'1\'';
					}
					
					//Se añade el login de Presence
					User presence = mapaUsuariosPresenceLogin.get(casoIn.OwnerId);
					if(presence != null){
						if(presence.USR_TXT_Presence_Login__c != null && casoIn.RecordTypeId != tipoRegistro){
							movimientoIR.MIR_TXT_GESTOR_SINIESTRO__c = '\''+presence.USR_TXT_Presence_Login__c+'\'';
						}else if(presence.USR_TXT_Presence_Login__c != null && casoIn.RecordTypeId == tipoRegistro){
							movimientoIR.MIR_TXT_GESTOR_SINIESTRO__c = '\''+0+'\'';
							movimientoIR.MIR_TXT_GESTOR_RECLAMA__c = '\''+presence.USR_TXT_Presence_Login__c+'\'';
						}else{
							movimientoIR.MIR_TXT_GESTOR_SINIESTRO__c = '\''+0+'\'';
						}
					}else{
						movimientoIR.MIR_TXT_GESTOR_SINIESTRO__c = '\''+0+'\'';
					}
					//Nos quedamos con la primera WO del caso	
					movimientoIR.MIR_TXT_NUM_SERVICIO__c = '\''+0+'\''; 	
					for(WorkOrder WoNum:WoNumber){
						if(workOrderNumber != ''){
							movimientoIR.MIR_TXT_NUM_SERVICIO__c = '\''+workOrderNumber+'\'';
							break;
						}else if(!WoNumber.isEmpty() && WoNumber.get(0).WorkOrderNumber != null){
							if(WoNum.CaseId == casoIn.Id){
								movimientoIR.MIR_TXT_NUM_SERVICIO__c = '\''+WoNumber.get(0).WorkOrderNumber+'\''; 
								break;
							}
						}
					}
					movimientoIR.MIR_TXT_OPERACION__c = Label.MIR_Procedimiento;
					if(movimientoIR.MIR_TXT_DNI__c == '' || movimientoIR.MIR_TXT_DNI__c == '\'null\'' || cuenta.Account.CUE_TXT_Numero_Documento__c == null){
							existe = true;
					}
					for(Movimiento_IR__c aux1:listaMovimientosIR){
						if(aux1.MIR_TXT_NUM_SINIESTRO__c == movimientoIR.MIR_TXT_NUM_SINIESTRO__c)
							existe = true;						
					}
					
					if(!existe){
						listaMovimientosIR.add(movimientoIR);
					}	
				}	
			}
			upsert listaMovimientosIR;
		}
	}
	/**
	 *	Este metodo actualiza la tabla Claims de IR con WorkOrders
	 *	@param WorkOrder datos						-  datos del Trigger.newMap
	 */	
	public void insertaWOIR(){
		//List<WorkOrder> listWO = [SELECT CaseId,WorkOrderNumber FROM WorkOrder WHERE Id =:listWorkOrder];
		List<String> listIdCasos = new List<String>();
		for(WorkOrder a:listWorkOrder){
			listIdCasos.add(a.CaseId);
		}
		if(listWorkOrder != null & !listWorkOrder.isEmpty()){
			workOrderNumber = listWorkOrder[0].WorkOrderNumber;
			if(listWorkOrder[0].Status == Label.OTR_ESTADO_CERRADO){
				fechaCierreServicio = listWorkOrder[0].LastModifiedDate;
			}
		}
		listReclamacion = Util_caso.getCaseById(new Set<Id>((List<Id>)listIdCasos)).values();
		//listReclamacion = [SELECT id FROM Case Where Id IN: listIdCasos];
		
		insertaCasoIR();
	}
	/**
	 *	Esta metodo hace asíncrono el servicio. Evitamos problemas con las querys, y no es necesaria la sincronia.
	 */	
	public void execute(QueueableContext context){
		selector();
	}
	public void selector(){
		if(mapaCases != null && mapaCases.size()>0){
			insertaCasoIR();
		}else if(listReclamacion != null && !listReclamacion.isEmpty()){
			String tipoRegistro = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.MIR_Reclamacion).getRecordTypeId();
			for(Case CaseRecord:listReclamacion){
				if(CaseRecord.RecordTypeId == tipoRegistro){
					insertaCasoIR();
				}
			}
		}else{
			insertaWOIR();
		}
	}
}