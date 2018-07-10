/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:			 everis
Company:		everis España
Description:	<Trigger para objeto movimientos>

History:  <DESCRIPCIÓN DEL CAMBIO, REQUISITO, INCIDENCIA, CORRECTIVO O MEJORA QUE HIZO ACTUALIZAR/CREAR LA CLASE>

<18/12/2017>		  everis		  <Inicio de clase>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public without sharing class TRG_Handler_Movimientos {
	private static Map<Id,Case> mapCasosActualizar;//Mapa para los casos que hay que actualizar con el número de CIA de retorno(Actualmente sólo NN)
	private static Map<Id,INT_Movimiento_CIA__c> mapMovError;//Lista de movimientos en estado Error
	private static Map<Id,INT_Movimiento_CIA__c> mapMovTratados;//Lista de movimientos que pasan de Error a Resuelto(OK)(Id Caso.Id)
	private static Map<Id,Case> mapaCasos;//Mapa de casos
	public static void tratamientoBefore(Map<Id, INT_Movimiento_CIA__c> triggerNewMap, List<INT_Movimiento_CIA__c> triggerNew, 
			Map<Id, INT_Movimiento_CIA__c> triggerOldMap, List<INT_Movimiento_CIA__c> triggerOld){
		Set<Id> setIdError;//Set con ids de los casos que tienen algún movimiento en error
		if(Trigger.isInsert){
			if(mapaCasos==null){
				System.debug('@Laura: El mapa de caso es null: '+mapaCasos);
				inicializaMapaCaso(triggerNew);
			}
			setIdError = setIdCasosMovError();
			//Si es un movimiento de siniestro o reparable sin número de CIA los pone en estado de espera
			for(INT_Movimiento_CIA__c mov : triggerNew){//Ojo con los reparables, revisar si aplica la lógica
				if((mov.MOV_SEL_Estado_Movimiento__c != Label.BIT_ESTADO_RECIBIDO && mov.MOV_SEL_Estado_Movimiento__c != Label.BIT_ESTADO_ERROR) 
						&& (String.isBlank(mov.MOV_TXT_Num_Caso_CIA__c) && mapaCasos.get(mov.MOV_LKP_Caso__c).CAS_LKP_Compania__r.CUE_TXT_Identificador__c==Label.IDE_NATIONALE_NETHERLANDEN)
						&& (mov.MOV_TXT_Tipo_Movimiento__c != '1' || mov.MOV_TXT_Codigo_Modificacion__c != '00')
						&& mov.MOV_TXT_Tipo_Movimiento__c != '0'){
					mov.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_EN_ESPERA;
				}else if(setIdError.contains(mov.MOV_LKP_Caso__c)){//Comprueba si tiene un movimiento hermano en error
					if(mov.MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_NO_ENVIADO){
						mov.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_EN_ESPERA;
					}
				}
			}		
		}
	}

	public static void tratamientoAfter(Map<Id, INT_Movimiento_CIA__c> triggerNewMap, List<INT_Movimiento_CIA__c> triggerNew, 
			Map<Id, INT_Movimiento_CIA__c> triggerOldMap, List<INT_Movimiento_CIA__c> triggerOld){
		if((mapCasosActualizar == null || mapCasosActualizar.values().isEmpty())
				&& (mapMovError == null || mapMovError.values().isEmpty())
				&& (mapMovTratados == null || mapMovTratados.values().isEmpty())){
			inicializaVariables(triggerNew,triggerOldMap);
		}
		if(Trigger.isInsert){
			for(INT_Movimiento_CIA__c mov : triggerNew){
				if(mapCasosActualizar.containsKey(mov.MOV_LKP_Caso__c)){
					mapCasosActualizar.get(mov.MOV_LKP_Caso__c).CAS_TXT_Num_Caso_CIA__c = mov.MOV_TXT_Num_Caso_CIA__c;
				}
			}
		}
		if(mapMovError!=null || mapMovTratados!=null){
			if(mapMovTratados!=null){
				replicaMovimiento();
			}
			actualizaMovimientos();
		}
		if(mapCasosActualizar != null){
			try{
				update mapCasosActualizar.values();
			} catch(Exception e){
				System.debug('>>>>>>>>>>Error al actualizar en trigger movimientos ' + e);
			}   
		}
	}
	private static void inicializaMapaCaso(List<INT_Movimiento_CIA__c> triggerNew){
		Set<Id> setIdCaso = new Set<Id>();
		for(INT_Movimiento_CIA__c m:triggerNew){
			System.debug('@Laura: m.MOV_LKP_Caso__c: '+m.MOV_LKP_Caso__c);
			setIdCaso.add(m.MOV_LKP_Caso__c);
		}
		//PREV: mapaCasos = new Map<Id,Case>([SELECT Id, CAS_LKP_Compania__r.CUE_TXT_Identificador__c FROM Case WHERE Id IN : setIdCaso]);
		//NEW:
		mapaCasos = Util_Caso.getCaseById(setIdCaso);
		System.debug('@Laura: mapaCasos: '+mapaCasos);
	}
	private static void inicializaVariables(List<INT_Movimiento_CIA__c> triggerNew, Map<Id,INT_Movimiento_CIA__c> triggerOldMap){
		Set<Id> setIdCasosActualizar = new Set<Id>();
		mapMovError = new Map<Id,INT_Movimiento_CIA__c>();
		mapMovTratados = new Map<Id,INT_Movimiento_CIA__c>();
		for(INT_Movimiento_CIA__c mov : triggerNew){
			if(Trigger.isInsert){
				if(mov.MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_ERROR){
					mapMovError.put(mov.MOV_LKP_Caso__c,mov);	
				}else if (isRetornoApertura(mov)){//Tiene Nº de caso de CIA & es el retorno de una apertura
					setIdCasosActualizar.add(mov.MOV_LKP_Caso__c);
				}

			}
			if(Trigger.isUpdate){
				System.debug(mov.MOV_SEL_Estado_Movimiento__c + ' ' + triggerOldMap.get(mov.id).MOV_SEL_Estado_Movimiento__c);
				if(mov.MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_RESUELTO && triggerOldMap.get(mov.id).MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_ERROR){
					mapMovTratados.put(mov.MOV_LKP_Caso__c,mov);
				}
			}
		}
		//List<Case> listaCasos = [SELECT Id,CAS_TXT_Num_Caso_CIA__c FROM Case WHERE CAS_LKP_Compania__r.CUE_TXT_Identificador__c =: Label.IDE_NATIONALE_NETHERLANDEN AND Id IN : setIdCasosActualizar];
		List<Case> listaCasos = Util_Caso.getCasosByIdAndIdentificador(setIdCasosActualizar,new Set<String>{Label.IDE_NATIONALE_NETHERLANDEN}).values();
		//mapCasosActualizar = new Map<Id,Case>([SELECT Id,CAS_TXT_Num_Caso_CIA__c FROM Case WHERE CAS_LKP_Compania__r.CUE_TXT_Identificador__c =: Label.IDE_NATIONALE_NETHERLANDEN AND Id IN : setIdCasosActualizar]);
		mapCasosActualizar = new Map<Id,Case>(Util_Caso.getCasosByIdAndIdentificador(setIdCasosActualizar,new Set<String>{Label.IDE_NATIONALE_NETHERLANDEN}));
	}
	/**
	 * Si es una recepción de un registro de apertura, pasa los movimientos hermanos de 'En espera' a 'No enviados'
	 * Si es una recepción de un registro de error, pasa los movimientos hermanos de 'No enviados' a 'En espera'
	 * Si se ha tratado un error y se pasa manualmente de de 'Error' a 'R', pasa los movimientos hermanos de 'En espera' a 'No enviado'
	 * 
	 */
	private static void actualizaMovimientos(){
		Boolean actualiza = true;
		List<INT_Movimiento_CIA__c> listMovimientosActualizar = new List<INT_Movimiento_CIA__c>();
		List<INT_Movimiento_CIA__c> listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id, Name, MOV_TXT_Num_Caso_CIA__c, MOV_LKP_Caso__c, MOV_SEL_Estado_Movimiento__c 
																						FROM INT_Movimiento_CIA__c 
																						WHERE (MOV_LKP_Caso__c IN : mapCasosActualizar.keySet() AND MOV_TXT_Num_Caso_CIA__c = null)
																						OR (MOV_LKP_Caso__c IN : mapMovError.keySet() AND MOV_SEL_Estado_Movimiento__c = : Label.BIT_ESTADO_NO_ENVIADO)
																						OR (MOV_LKP_Caso__c IN : mapMovTratados.keySet() AND (MOV_SEL_Estado_Movimiento__c = : Label.BIT_ESTADO_ERROR OR MOV_SEL_Estado_Movimiento__c = : Label.BIT_ESTADO_EN_ESPERA))]);
		for(Integer i = 0; i<listMovimientos.size(); i++){
			if(mapCasosActualizar.containsKey(listMovimientos.get(i).MOV_LKP_Caso__c)){//Son Aperturas recibidas
				if(listMovimientos.get(i).MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_EN_ESPERA){
					listMovimientos.get(i).MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;
					listMovimientos.get(i).MOV_TXT_Num_Caso_CIA__c = mapCasosActualizar.get(listMovimientos.get(i).MOV_LKP_Caso__c).CAS_TXT_Num_Caso_CIA__c;
					listMovimientosActualizar.add(listMovimientos.get(i));
				}
			}else if(mapMovError.containsKey(listMovimientos.get(i).MOV_LKP_Caso__c)){//Son registros erróneos recibidos
				if(listMovimientos.get(i).MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_NO_ENVIADO){
					listMovimientos.get(i).MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_EN_ESPERA;
					listMovimientosActualizar.add(listMovimientos.get(i));
				}
			}else if(mapMovTratados.containsKey(listMovimientos.get(i).MOV_LKP_Caso__c)){//Es un error tratado
				if(listMovimientos.get(i).MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_ERROR){//Y no hay otro error en un movimiento hermano
					actualiza=false;
				}
				if(listMovimientos.get(i).MOV_SEL_Estado_Movimiento__c == Label.BIT_ESTADO_EN_ESPERA
						&& String.isNotBlank(listMovimientos.get(i).MOV_TXT_Num_Caso_CIA__c)){//No tiene número de CIA
					listMovimientos.get(i).MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;
					listMovimientosActualizar.add(listMovimientos.get(i));
				}
			}
		}

		if(actualiza && !listMovimientosActualizar.isEmpty()){
			try{
				update listMovimientos;
			}catch(Exception e){
				System.debug('>>>>>>>>>>>Excepción en TRG_Movimientos' + e);
			}
		}
	}

	/**
	 * Comprueba si es un movimiento de apertura para la CIA NN
	 */
	private static Boolean isRetornoApertura(INT_Movimiento_CIA__c mov){
		return(mov.MOV_TXT_Tipo_Movimiento__c == '1' && mov.MOV_TXT_Codigo_Modificacion__c == '00'
				&& String.isNotBlank(mov.MOV_TXT_Num_Caso_CIA__c));
	}

	/**
	 * Devuelve set con id de casos con movimientos en error
	 */
	private static Set<Id> setIdCasosMovError(){
		//List<INT_Movimiento_CIA__c> listMovError = new List<INT_Movimiento_CIA__c>([SELECT Id,MOV_LKP_Caso__c FROM INT_Movimiento_CIA__c WHERE MOV_SEL_Estado_Movimiento__c = :Label.BIT_ESTADO_ERROR AND MOV_LKP_Caso__c != null]);
		
		List<INT_Movimiento_CIA__c> listMovError = Util_Movimientos.queryMovimientosByCasoAndEstadoMov(null,new Set<String>{ Label.BIT_ESTADO_ERROR}).values();
		Set<Id> setIdCasoErrorMov = new Set<Id>();
		for(INT_Movimiento_CIA__c mov : listMovError){
			setIdCasoErrorMov.add(mov.MOV_LKP_Caso__c);
		}
		System.debug('@Laura: setIdCasoErrorMov: '+setIdCasoErrorMov);
		return setIdCasoErrorMov;
	}
	/**
	 * Replica el movimiento tratado en caso de que haya que haya que reenviarlo y no se genere(Apertura y reapertura)
	 */
	private static void replicaMovimiento(){
		if(Trigger.isUpdate){
			//PREV: Set<INT_Movimiento_CIA__c> setTratados = new Set<INT_Movimiento_CIA__c>([SELECT Id, MOV_LKP_Caso__c, MOV_LKP_Compania__r.CUE_TXT_Identificador__c, MOV_TXT_Codigo_Modificacion__c, MOV_TXT_Tipo_Movimiento__c 
			 //                                                                            FROM INT_Movimiento_CIA__c WHERE Id IN : mapMovTratados.values()]);
			//NEW
			Set<INT_Movimiento_CIA__c> setTratados = new Set<INT_Movimiento_CIA__c>(Util_Movimientos.queryMovimientosById( new Set<Id> (mapMovTratados.keySet())).values());
			System.debug('@@@@@@@En replicaMovimiento: ' + setTratados);
			for(INT_Movimiento_CIA__c mov : setTratados){
				if(mov.MOV_TXT_Codigo_Modificacion__c == '00'){
					if(mov.MOV_TXT_Tipo_Movimiento__c == '1'){//Apertura 
						Util_Movimientos.compruebaEnviable(mov.MOV_LKP_Caso__c,mov.MOV_LKP_Compania__r.CUE_TXT_Identificador__c,'1');
					}else if(mov.MOV_TXT_Tipo_Movimiento__c == '4'){
						Util_Movimientos.compruebaEnviable(mov.MOV_LKP_Caso__c,mov.MOV_LKP_Compania__r.CUE_TXT_Identificador__c,'3');
					}
				}
			}
		}
	}
}