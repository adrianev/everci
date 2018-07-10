public without sharing class TRG_Handler_Arbol_Decision_Lineas {
	public static void tratamientoBefore(Map<Id, Arbol_Decision_Lineas__c> triggerNewMap, List<Arbol_Decision_Lineas__c> triggerNew, 
			Map<Id, Arbol_Decision_Lineas__c> triggerOldMap, List<Arbol_Decision_Lineas__c> triggerOld){
		// Se inicializa la lista de nuevos valores picklist (entradas que se insertan via metadatos)
		Util_Listas_Seleccion.nuevosValoresPickList = null;
		system.debug('>>>>> TRG_Handler - triggerNewMap: '+triggerNewMap);
		system.debug('>>>>> TRG_Handler - triggerNew: '+triggerNew);
		// 1. ACCIONES ANTES DE GUARDAR UN REGISTRO NUEVO O EXISTENTE
		if(Trigger.isInsert || Trigger.isUpdate){
			for(Arbol_Decision_Lineas__c adLinea : triggerNew){
				//system.debug('>>>>adLinea antes ' + adLinea);
				Util_Listas_Seleccion.corregirListasSeleccion(adLinea, new List<String>{
					'ADL_SEL_E_Causa_Averia__c', 
					'ADL_SEL_E_Detalle_Averia__c',
					'ADL_SEL_E_Grupo_Causa__c',
					'ADL_SEL_E_Otros_Danos_Perjudicados__c',
					'ADL_SEL_E_Otros_Danos_Propios__c', 
					'ADL_SEL_E_Situacion_Danos_Perjud__c',
					'ADL_SEL_E_Situacion_Danos_Propios__c',
					'ADL_SEL_E_Tipo_Averia__c', 
					//'ADL_SEL_E_Tipo_Riesgo__c',
					//'ADL_SEL_S_Causa__c',
					//'ADL_SEL_S_Email_Auto_AV__c',
					//'ADL_SEL_S_Gremio_Limite_Cobertura__c',
					'ADL_SEL_S_Gremios__c',
					//'ADL_SEL_S_Grupo_Causa__c',
					//'ADL_SEL_S_Motivo_Rechazo__c',
					'ADL_SEL_S_Motivo_Perito__c',
					//'ADL_SEL_S_Tipo_Carta__c',
					'ADL_SEL_S_Tipo_Actuacion_Mult__c'
				});
				Util_Listas_Seleccion.corregirListasDecision(adLinea, new List<String>{
					'ADL_SEL_E_Danos_Propios__c',
					'ADL_SEL_E_Danos_Perjudicados__c',
					'ADL_SEL_E_Danos_Perjud_Cubiertos__c',
					'ADL_SEL_Averia_Cubierta__c',
					'ADL_SEL_Danos_Propios_Cubiertos__c'
				});

				recogerCodigoGarantia(adLinea, new List<String>{
					'ADL_TXT_S_Garantia_RC__c',
					'ADL_TXT_S_Garantias_Piden_Perito__c',
					'ADL_TXT_S_Garantias__c',
					'ADL_TXT_S_Garantias_Enviar_CIA__c'
				});
				//system.debug('>>>>adLinea despues ' + adLinea);
			}

			// Crear valores en los campos listas de seleccion
			String tipoObjeto = 'Arbol_Decision_Lineas__c';
			//system.debug('[AMC]' + UserInfo.getOrganizationId()+':'+UserInfo.getSessionId().SubString(15));	
			//String sessionId = UserInfo.getOrganizationId()+':'+UserInfo.getSessionId().SubString(15);
			system.debug('>>>>> TRG_Handler - JSON.serialize(Util_Listas_Seleccion.nuevosValoresPickList): '+JSON.serialize(Util_Listas_Seleccion.nuevosValoresPickList));
			//Util_Listas_Seleccion.createPicklistField(tipoObjeto, JSON.serialize(Util_Listas_Seleccion.nuevosValoresPickList), UserInfo.getSessionId());
			Util_Listas_Seleccion.createPicklistFieldTooling(tipoObjeto, JSON.serialize(Util_Listas_Seleccion.nuevosValoresPickList), UserInfo.getSessionId());
		}
	}
	/**
	 *	Esta funcion se encarga de recoger la primera cadena de texto de un valor informado en un campo
	 */
	private static void recogerCodigoGarantia(Arbol_Decision_Lineas__c adLinea, List<String> campos){
		for(String campo : campos){
			String codigoGarantia;
			String valor = (String) adLinea.get(campo);
			if(valor != null){
				// El codigo de la garantia se corresponde con la primera cadena de texto
				codigoGarantia = valor.split(' ').get(0);
			}
			system.debug('>>>>adLinea.' + campo + ' antes: ' + valor);
			system.debug('>>>>adLinea.' + campo + ' despues: ' + codigoGarantia);
			adLinea.put(campo, codigoGarantia);
		}
	}
}