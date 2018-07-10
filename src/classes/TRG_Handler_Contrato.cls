/**
  * Handler del Trigger TRG_Contrato.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Contrato {

	/**
	  * Tratamiento antes de insertar registros.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Contract a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Contract
	  * @param triggerOldMap: mapa de registros antiguos del objeto Contract a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Contract
	  */
	public static void tratamientoAfterInsert(Map<Id,Contract> triggerNewMap, List<Contract> triggerNew, 
			Map<Id,Contract> triggerOldMap, List<Contract>triggerOld){
		Set<Id> setIdCont = new Set<Id>();
		Map<Id,Id> mapContratos = new Map <Id, Id>();
		Map<Id,Linea_Contrato__c> mapaLineasContrato;
		Map<Id,Tarea_Linea_Contrato__c> mapaTareasLineas;
		Map<Id,Id>mapLineaContratos = new Map <Id, Id>();
		Map<Id, List<Tarea_Linea_Contrato__c>> mapaLineaTarea;
		List<Tarea_Linea_Contrato__c> listaTareasContr;
		List<Tarea_Linea_Contrato__c>tareasClonadas=new List<Tarea_Linea_Contrato__c>();
		Map<Id, Linea_Contrato__c> listaLinContratos = new Map<Id, Linea_Contrato__c>();
		List<Contract> actualizarIdentificadores = new List<Contract>();
		//Localizamos los contratos que han sido clonados.
		for (Contract cont: triggerNew){
			system.debug('es clonado'+cont.CTR_LKP_Clonado_De__c);
			if (cont.CTR_LKP_Clonado_De__c!=null || cont.CTR_LKP_Clonado_De__c!=''){
				setIdCont.add(cont.CTR_LKP_Clonado_De__c);
				mapContratos.put(cont.CTR_LKP_Clonado_De__c, cont.Id);
			}
			// [INI] Corregir campo CTR_TXT_Identificador__c seteándole el valor del ContractNumber:
			if(cont.CTR_TXT_Identificador__c == null){
				Contract contratoAct = new Contract(Id=cont.Id);
				contratoAct.CTR_TXT_Identificador__c = cont.ContractNumber;
				actualizarIdentificadores.add(contratoAct);
			}
			// [FIN] Corregir campo CTR_TXT_Identificador__c seteándole el valor del ContractNumber.
		}
		// [INI] Actualizar con la corrección del campo CTR_TXT_Identificador__c:
		if(!actualizarIdentificadores.isEmpty()){
			Baipas.establecerVariableControl();
			update actualizarIdentificadores;
			Baipas.deshabilitarVariableControl();
		}
		// [FIN] Actualizar con la corrección del campo CTR_TXT_Identificador__c.
		//buscamos las lineas de contrato que tienen asociadas las lineas de contrato
		mapaLineasContrato = Util_B2B.queryLineaContratoByCont(setIdCont);
		/*mapaLineasContrato = new Map<Id, Linea_Contrato__c>(
				[ SELECT Id,
				  Name,
				  RecordTypeId,
				  LDC_NUM_Preaviso_dias__c,
				  LDC_SEL_Gremio__c,
				  LDC_LKP_Contrato__c,
				  LDC_NUM_Limite_de_servicios__c,
				  LDC_NUM_Periodicidad__c,
				  LDC_LKP_Tipo_Trabajo__c,
				  LDC_SEL_Unidad_de_periodicidad__c,
				  LDC_CAS_Urgente__c
				  FROM Linea_Contrato__c
				  WHERE LDC_LKP_Contrato__c IN :setIdCont]);*/
		/*listaTareasContr = new List<Tarea_Linea_Contrato__c>([SELECT Id,
		                                                      Name,
		                                                      TLC_LKP_LineaContrato__c,
		                                                      TLC_LKP_Tarea_Tipo_Trabajo__c
		                                                      FROM Tarea_Linea_Contrato__c
		                                                      WHERE TLC_LKP_LineaContrato__c IN :mapaLineasContrato.keySet()]);*/
		listaTareasContr = Util_B2B.queryMapTareaLineaContrato(mapaLineasContrato.keySet()).values();
		if(!listaTareasContr.isEmpty()){
			mapaLineaTarea = new Map<Id, List<Tarea_Linea_Contrato__c>>();
			for(Tarea_Linea_Contrato__c tar : listaTareasContr){
				Linea_Contrato__c lcAsociada = mapaLineasContrato.get(tar.TLC_LKP_LineaContrato__c);
				List<Tarea_Linea_Contrato__c> tareas;
				if(mapaLineaTarea.containsKey(lcAsociada.Id)){
					tareas = mapaLineaTarea.get(lcAsociada.Id);
				}else{
					tareas = new List<Tarea_Linea_contrato__c>();
				}
				tareas.add(tar);
				mapaLineaTarea.put(lcAsociada.Id, tareas);
			}
		}
		//clonamos las lineas de contrato que tienen un contrato clonado 
		for (Linea_Contrato__c lin : mapaLineasContrato.values()){
			Linea_contrato__c linClon = lin.clone();
			linClon.LDC_LKP_Contrato__c = mapContratos.get(lin.LDC_LKP_Contrato__c);
			system.debug('linea clonada contrato asociado'+linClon.LDC_LKP_Contrato__c);
			listaLinContratos.put(lin.Id, linClon);
		}
		try{
			insert listaLinContratos.values();
		}catch(Exception e){
			system.debug('***** EXCEPTION : ' + e);
		}
		for(Id idLcOriginal: listaLinContratos.keySet()){
			list<Tarea_Linea_Contrato__c> listaRecogida = mapaLineaTarea.get(idLcOriginal);
			if(listaRecogida!=null){
				Id idLcClonada = listaLinContratos.get(idLcOriginal).Id;
				system.debug('+++idClonada'+idLcClonada);
				for(Tarea_Linea_Contrato__c tar: listaRecogida){
					Tarea_Linea_Contrato__c tarClon = tar.clone();
					tarClon.TLC_LKP_LineaContrato__c = idLcClonada;
					tareasClonadas.add(tarClon);
				}
			}
		}
		try{
			insert tareasClonadas;
		}catch(Exception e){
			system.debug('***** EXCEPTION : ' + e);
		}
	}
    public static void tratamientoBeforeInsert(List<Contract> triggerNew, Map<Id,Contract> triggerNewMap){
        /*set<Id> idcuentas = new set<Id>();
        for(Contract con1: triggerNew){
            idcuentas.add(con1.AccountId);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, CUE_TXT_Identificador__c FROM Account WHERE Id IN :idcuentas]);
        String identificador;
        String fecha;
        for(Contract con: triggerNew){
            if(con.CTR_NUM_Version_Contrato__c.intValue() != null){
                fecha = String.valueOf(con.StartDate);
            	fecha = String.valueOf(system.now().getTime());//fecha.replace('-', '');
                identificador = accountMap.get(con.AccountId).CUE_TXT_Identificador__c + '_' + String.valueOf(con.CTR_NUM_Version_Contrato__c.intValue());
            	identificador += + '_' + fecha;
            	con.CTR_TXT_Identificador__c = identificador;
            }	
        }*/
    }
}