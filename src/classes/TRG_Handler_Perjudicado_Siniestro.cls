/**
 * Handler del Trigger TRG_Perjudicado_Siniestro.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Perjudicado_Siniestro {
	public static List<Case> listaCasos;

	/**
	  * Tratamiento para el caso before del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Perjudicado_Siniestro__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Perjudicado_Siniestro__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Perjudicado_Siniestro__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Perjudicado_Siniestro__c
	  */
	public static void tratamientoBefore(Map<Id, Perjudicado_Siniestro__c> triggerNewMap, List<Perjudicado_Siniestro__c> triggerNew, 
			Map<Id, Perjudicado_Siniestro__c> triggerOldMap, List<Perjudicado_Siniestro__c> triggerOld){
		system.debug('>>>>triggerNewMap ' + triggerNewMap);
		system.debug('>>>>triggerNew ' + triggerNew);
		system.debug('>>>>triggerOldMap ' + triggerOldMap);
		system.debug('>>>>triggerOld ' + triggerOld);
		// 1. ACCIONES ANTES DE GUARDAR UN REGISTRO NUEVO O EXISTENTE
		if(Trigger.isInsert || Trigger.isUpdate){
			for (Perjudicado_Siniestro__c perj : triggerNew){
				system.debug('************* ACCIONES ANTES DE GUARDAR UN REGISTRO NUEVO: ' + perj);
				/* 
				 * 1.1.1. Existen listas en las que no se restringen los valores que se pueden insertar
				 * En estos casos se busca si el valor introducido coincide con uno de los nombres API de los valores de la lista 
				 * de seleccion y, si no existe, se busca si coincide con las etiquetas
				 * Si coincide con alguna de las etiquetas, se actualiza el campo del objeto poniendo el valor correcto, el API
				 */
				Util_Listas_Seleccion.corregirListasSeleccion(perj, new List<String> { 
					'PRJ_SEL_Otros_Danos__c', 
					'PRJ_SEL_Situacion_Danos__c'
				});

			}
		}
		if(Trigger.isDelete){
			if(listaCasos == null){
				inicializarVariables(triggerNew, triggerOld);
				generaMovimientos();
			}
		}
	}

	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Perjudicado_Siniestro__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Perjudicado_Siniestro__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Perjudicado_Siniestro__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Perjudicado_Siniestro__c
	  */
	public static void tratamientoAfter(Map<Id, Perjudicado_Siniestro__c> triggerNewMap, List<Perjudicado_Siniestro__c> triggerNew, 
			Map<Id, Perjudicado_Siniestro__c> triggerOldMap, List<Perjudicado_Siniestro__c> triggerOld){
		if(listaCasos == null){
			inicializarVariables(triggerNew, triggerOld);
			generaMovimientos();
		}	
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param perjudicadosNew: [PENDIENTE]
	  * @param perjudicadosOld: [PENDIENTE]
	  * 
	  */
	public static void inicializarVariables(List<Perjudicado_Siniestro__c> perjudicadosNew, List<Perjudicado_Siniestro__c> perjudicadosOld){
		if(listaCasos == null){
			Set<Id> setIdsCasos = new Set<Id>();
			if(perjudicadosNew != null){
				for(Perjudicado_Siniestro__c perjudicado : perjudicadosNew){
					setIdsCasos.add(perjudicado.PRJ_LKP_Siniestro__c);
				}
			}
			if(perjudicadosOld != null){
				for(Perjudicado_Siniestro__c perjudicado : perjudicadosOld){
					setIdsCasos.add(perjudicado.PRJ_LKP_Siniestro__c);
				}
			}
			inicializarListaCasos(setIdsCasos);
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param setIdsCasos: [PENDIENTE]
	  * 
	  */
	public static void inicializarListaCasos(Set<Id> setIdsCasos){
		if(!setIdsCasos.isEmpty()){
			/* PREV: listaCasos = new List<Case>([SELECT Id,Type,Status,RecordTypeId,CAS_LKP_Compania__r.CUE_TXT_Identificador__c 
			                             FROM Case 
			                             WHERE Id 
			                             IN :setIdsCasos]);*/
			 //NEW:
			listaCasos = Util_Caso.getCaseById(setIdsCasos).values();
		}
	}

	/**
	 * Inicia la generación de movimientos en caso de que cumplan las condiciones establecidas
	 * 
	 */
	private static void generaMovimientos(){
		for(case caso : listaCasos){
			if(Util_Siniestro.esSiniestro(caso)){
				if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && caso.Status != Label.CAS_ESTADO_CERRADO){
						//&& caso.Status != Label.SINI_ESTADO_CUBIERTO && caso.Status != Label.CAS_ESTADO_CERRADO){
					Util_Movimientos.compruebaEnviable(caso.Id,caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'10');
				}
				if(Trigger.isBefore && Trigger.isDelete){
					Util_Movimientos.compruebaEnviable(caso.Id,caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'12');
				}  	
			}
		}
	}
}