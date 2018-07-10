/**
  * Handler del Trigger TRG_Direcciones_B2B_Lineas.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Direcciones_B2B_Lineas {

	/**
	  * Tratamiento para el caso before del trigger.
	  * 
	  * @param triggerNew: lista de registros nuevos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
	  */
	public static void tratamientoBeforeInsert(List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> triggerNew) {
 		for (Direcciones_B2B_B2B2C_Lineas_de_Contrato__c registro : triggerNew) {
			registro.DLC_TXT_Identificador__c = registro.DLC_LKP_Direccion_B2B_B2B2C__c + '_' + registro.DLC_LKP_Linea_de_Contrato__c;
			system.debug('>>>> Identificador: ' + registro.DLC_TXT_Identificador__c);
		}
	}

   	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
	  */
	public static void tratamientoAfterInsert(Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> triggerNewMap, List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> triggerNew, Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> triggerOldMap, List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>triggerOld){
		Map<Id,Linea_Contrato__c> mapaLineaContrato;
		List<WorkOrderLineItem> listaWOLIInsertar = new List<WorkOrderLineItem>();//Lista de WOLI a insertar
		Set<Id> setIdLinCon = new Set<Id>();
		for (Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dir : triggerNew) {
			if (dir.DLC_LKP_Linea_de_Contrato__c != null){
				setIdLinCon.add(dir.DLC_LKP_Linea_de_Contrato__c);
			}
		}
		Set<Id> setIdCuentas = new Set<Id>();
		for (Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC : triggerNew) {
			if (dirLC.DLC_LKP_Direccion_B2B_B2B2C__c != null) {
				setIdCuentas.add(dirLC.DLC_LKP_Direccion_B2B_B2B2C__c);
			}
		}
		
		//Se recoge el id del recordtype de la  Linea de Trabajo Preventiva para recoger las lineas de contrato que son preventivo
		List<String> nombreRT = Label.RT_LIN_CON_PREVENTIVO.split(':');
		system.debug('***** nombreRT.get(1) : ' + nombreRT.get(1));
		system.debug('***** Util_mapasTiposDeRegistro.RTIDBYDEVNAME : ' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME);
		Id rtIdPreventivo = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_LIN_CON_PREVENTIVO);
		system.debug('***** rtIdPreventivo : ' + rtIdPreventivo);
		system.debug('***** nombreRT : ' + nombreRT);
		mapaLineaContrato = Util_B2B.queryLineaContratoPreventivoById(setIdLinCon, rtIdPreventivo);
		/*mapaLineaContrato = new Map<Id, Linea_Contrato__c>(
							[	SELECT 	Id,
										Name,
										RecordTypeId,
										LDC_FOR_Gremio__c,
										LDC_SEL_Gremio__c,
										LDC_LKP_Tipo_Trabajo__c,
										LDC_LKP_Tipo_Trabajo__r.Name,
										LDC_NUM_Preaviso_dias__c,
										LDC_LKP_Contrato__r.AccountId
								FROM Linea_Contrato__c
								WHERE Id IN :setIdLinCon AND RecordTypeId = :rtIdPreventivo]);*/
		
		if (!mapaLineaContrato.isEmpty()) {
			Id idRtCasoB2BB2B2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
			system.debug('***** idRtCasoB2BB2B2C : ' + idRtCasoB2BB2B2C);
			system.debug('***** mapaLineaContrato : ' + mapaLineaContrato);
			
			//Mapa de las cuentas que tengo en las direcciones
			Map<Id, Account> mapaCuentas = Util_Cuentas.getMapCuentasById(setIdCuentas);
			/*Map<Id, Account> mapaCuentas = new Map<Id, Account>(
										[	SELECT	CUE_LKP_Cuenta_principal__c,
													CUE_SEL_Provincia__c,
													ShippingCity,
													ShippingStreet,
													ShippingPostalCode,
													ShippingState,
													ShippingCountry
											FROM Account
											WHERE Id IN :setIdCuentas]);*/
										
			system.debug('***** mapaCuentas : ' + mapaCuentas);
			
			//Mapa que contendrá el Id de la linea de contrato y el caso para crear la OT una vez se han insertado los casos
			Map<Id, Case> mapaDirLCCaso = new Map<Id, Case>();
			//Recorro la lista de las Direcciones de líneas de contrato, y para cada linea de contrato creo un Caso 
			for (Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC : triggerNew) {
				system.debug('***** direccion : ' + dirLC);
				system.debug('***** cuenta : ' + mapaCuentas.get(dirLC.DLC_LKP_Direccion_B2B_B2B2C__c));
				system.debug('***** lineacontrato : ' + mapaLineaContrato.get(dirLC.DLC_LKP_Linea_de_Contrato__c));
				system.debug('***** idcaso : ' + idRtCasoB2BB2B2C);
				Case caso = Util_B2B.crearCasoPreventivo(dirLC, mapaCuentas.get(dirLC.DLC_LKP_Direccion_B2B_B2B2C__c),
												mapaLineaContrato.get(dirLC.DLC_LKP_Linea_de_Contrato__c), idRtCasoB2BB2B2C);

				if (caso != null) {
					mapaDirLCCaso.put(dirLC.Id, caso);
				}
			}
						
			if(!mapaDirLCCaso.isEmpty()){
				//Inserto la lista de los casos que se ha creado
				try{
					system.debug('***** mapaDirLCCaso : ' + mapaDirLCCaso);
					insert mapaDirLCCaso.values();
				}catch(Exception e){
					system.debug('***** EXCEPTION : ' + e);
				}
			}
						
			Map<Id, WorkOrder> mapaDirLCWO = new Map<Id, WorkOrder>();
			//Recorro la lista de Casos creados y para cada caso creo una OT
			for (Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC : triggerNew) {
				if (mapaLineaContrato.get(dirLC.DLC_LKP_Linea_de_Contrato__c)!=null) {
					WorkOrder wo = Util_Orden_Trabajo.crearOrdenDeTrabajo(mapaDirLCCaso.get(dirLC.Id), Label.OTR_ESTADO_INACTIVO,
					 mapaLineaContrato.get(dirLC.DLC_LKP_Linea_de_Contrato__c).LDC_SEL_Gremio__c,
					 mapaLineaContrato.get(dirLC.DLC_LKP_Linea_de_Contrato__c).LDC_LKP_Tipo_Trabajo__c, null, false);
				 	mapaDirLCWO.put(dirLC.Id, wo); 
				}
			}
			if (!mapaDirLCWO.isEmpty()){
				//Inserto la lista de las WO
				try {
					insert mapaDirLCWO.values();
				}
				catch(Exception e){
					system.debug('***** EXCEPTION : ' + e);
				}
			}
			
			
			//Almaceno todas las tareas que tiene la línea de contrato
			List<Tarea_Linea_Contrato__c> listaTareasLC = Util_B2B.queryMapTareaLineaContrato(mapaLineaContrato.keySet()).values();
			/*List<Tarea_Linea_Contrato__c> listaTareasLC = new List<Tarea_Linea_Contrato__c>(
								[	SELECT 	Id,
											Name,
											TLC_LKP_LineaContrato__c,
											TLC_LKP_Tarea_Tipo_Trabajo__r.Name,
											TLC_LKP_Tarea_Tipo_Trabajo__r.TTT_LKP_Tipo_Trabajo__c,
											TLC_LKP_Tarea_Tipo_Trabajo__r.TTT_LKP_Tipo_Trabajo__r.Name
									FROM Tarea_Linea_Contrato__c
									WHERE TLC_LKP_LineaContrato__c IN : mapaLineaContrato.keySet()
									ORDER BY TLC_LKP_LineaContrato__c]);*/
			system.debug('>>>> TGR_Handler_Direcciones_B2B_Lineas: listaTareasLC: ' + listaTareasLC);
			//Recorro las direcciones del trigger, y creo todas las WOLI necesarias según las tareas
			for (Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC : triggerNew) {
				if (mapaLineaContrato.get(dirLC.DLC_LKP_Linea_de_Contrato__c)!=null) {
					//Recorro para cada una de las direcciones, la tarea que le corresponde a su LC
					for (Tarea_Linea_Contrato__c tarLC : listaTareasLC) {
						WorkOrder wo = mapaDirLCWO.get(dirLC.Id);
						if(wo != null){
							WorkOrderLineItem woli = new WorkOrderLineItem();
							woli.WorkOrderId = wo.Id;
							//En WorkType guardo el WT que tiene asociado el tipo de tarea
							woli.WorkTypeId = tarLC.TLC_LKP_Tarea_Tipo_Trabajo__r.TTT_LKP_Tipo_Trabajo__c;
							woli.Description = tarLC.TLC_LKP_Tarea_Tipo_Trabajo__r.Name;
							listaWOLIInsertar.add(woli);
						}
					}
				}
			}
			system.debug('>>>> TGR_Handler_Direcciones_B2B_Lineas: listaWOLIInsertar: ' + listaWOLIInsertar);
			if (!listaWOLIInsertar.isEmpty()) {
				//Inserto la lista de las WOLI
				try {
					system.debug('***** listaWOLIInsertar : ' + listaWOLIInsertar);
					insert listaWOLIInsertar;
				}
				catch(Exception e) {
					system.debug('***** EXCEPTION : ' + e);
				}
			}
			system.debug('---------Thisistheend');
			//system.debug('>>>> TGR_Handler_Direcciones_B2B_Lineas: Después de if (!listaWOLIInsertar.isEmpty())');
		}
	}//FIN tratamientoAfterInsert

	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
	  */
	public static void tratamientoAfterDelete(Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> triggerNewMap, List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> triggerNew, 
		Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> triggerOldMap, List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>triggerOld) {
		//Localizar los casos que estan vinculados a direcciones de lineas de contrato que han sido borradas y los casos estan inactivos
		Set<String> setIdDLC = new Set<String>();
		Map<Id, Case> mapaCasos;
		for (Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC : triggerOld) {
			setIdDLC.add(dirLC.DLC_TXT_Identificador__c);
		}
		mapaCasos = Util_Caso.queryCasosInactivosByDLC(setIdDLC);
		/*mapaCasos = new Map<Id, Case>(
			  [ SELECT Id, Status
				FROM Case
				WHERE CAS_TXT_Identificador_DLC__c IN :setIdDLC
				AND Status = :Label.CAS_ESTADO_INACTIVO]);*/

		// ponerlos como anulado.
		for (Case cas: mapaCasos.values()){
			cas.Status = Label.CAS_ESTADO_ANULADO;
		}
		try {
			update mapaCasos.values();
		}
		catch(Exception e) {
			system.debug('***** EXCEPTION : ' + e);
		}
	}
}