/**
 * Clase de funciones auxiliares relativas a los Contactos Telefónicos.
 * 
 * @author EVERIS
 * @version 1.0
 *
 */
public without sharing class Util_Contacto_Telefonico {
	
	/**
	 * Método que busca un contacto telefónico por ID.
	 *
	 * @param setCTIds: IDs del contacto o contactos a retornar
	 *
	 * @return mapa de contactos telefónicos asociados a los ids del conjunto especificado
	 */
	public static Map<Id,Contacto_telefonico__c> queryMapCT(Set <Id> setCTIds){
		Map<Id, Contacto_telefonico__c> mapaContactosTelefonicos = new Map<Id, Contacto_telefonico__c>();
			if(!setCTIds.isEmpty()){
				for(List<Contacto_telefonico__c> listaContactosTelefonicosAux:
					[SELECT Id,
							CTF_LKP_Caso__c,
							CTF_LKP_Caso__r.Type,
							CTF_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
							CTF_LKP_Caso__r.ParentId,
							CTF_LKP_Caso__r.RecordTypeId,
							CTF_LKP_Contacto__c,
							CTF_LKP_Contacto__r.Phone,
							CTF_LKP_Contacto__r.MobilePhone,
							CTF_LKP_Contacto__r.CON_TXT_Identificador__c,
							CTF_LKP_Contacto_Telefonico__c,
							CTF_CAS_Contacto_Poliza__c,
							CTF_FOR_Email__c,
							CTF_FOR_Apellidos__c,
							CTF_SEL_Hora_desde__c,
							CTF_SEL_Hora_hasta__c,
							CTF_FOR_Nombre__c,
							CTF_TXT_Observaciones__c,
							CTF_TXT_Identificador__c,
							CTF_FOR_Poliza_Contrato__c,
							CTF_LKP_Poliza_Contrato__c,
							CTF_LKP_Poliza_Contrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
							CTF_LKP_Poliza_Contrato__r.Name,
							CTF_CAS_SMS__c,
							CTF_FOR_Telefono__c,
							CTF_FOR_TelefonoAdicional__c,
							CTF_FOR_TelefonoMovil__c,
							CTF_SEL_Tipo_Relacion__c,
							RecordTypeId,
							RecordType.DeveloperName
					 FROM Contacto_telefonico__c
					 WHERE Id IN :setCTIds]){
						 mapaContactosTelefonicos.putAll(listaContactosTelefonicosAux);	 	
				}
			}
    	return mapaContactosTelefonicos;
	}

	/**
	 * Devuelve los contactos telefónicos filtrado por los Casos y los tipos de relación.
	 *
	 * @param setCase: conjunto de IDs de Caso
	 * @param setTipoRelacion: conjunto de tipos de relación
	 *
	 * @return mapa con los contactos telefónicos encontrados
	 */
	public static Map<Id,Contacto_telefonico__c> queryMapCTByCaseAndTipoRelacion(Set<Id> setCase, Set<String> setTipoRelacion){
		Map<Id, Contacto_telefonico__c> mapaContactosTelefonicos = new Map<Id, Contacto_telefonico__c>();
			if(setCase != null && !setCase.isEmpty() && setTipoRelacion != null && !setTipoRelacion.isEmpty()) {
			        for(List<Contacto_telefonico__c> listaContactosTelefonicosAux:
			        [SELECT Id,
				        	CTF_LKP_Caso__c, 
		                    CTF_LKP_Contacto__c, 
		                    CTF_CAS_Contacto_Poliza__c, 
		                    CTF_FOR_Email__c, 
		                    CTF_FOR_Apellidos__c, 
		                    CTF_SEL_Hora_desde__c, 
		                    CTF_SEL_Hora_hasta__c, 
		                    CTF_FOR_Nombre__c, 
		                    CTF_TXT_Observaciones__c, 
		                    CTF_FOR_Poliza_Contrato__c,
		                    CTF_LKP_Poliza_Contrato__c, 
		                    CTF_CAS_SMS__c, 
		                    CTF_FOR_Telefono__c,
		                    CTF_FOR_TelefonoAdicional__c,
		                    CTF_FOR_TelefonoMovil__c,
		                    CTF_SEL_Tipo_Relacion__c,
		                    RecordTypeId
	                    FROM Contacto_telefonico__c
	                    WHERE CTF_LKP_Caso__c IN :setCase AND CTF_SEL_Tipo_Relacion__c IN :setTipoRelacion]){
						 mapaContactosTelefonicos.putAll(listaContactosTelefonicosAux);	 	
						}	
		  }
    	return mapaContactosTelefonicos;
	}

	/**
	 * queryContactoTelefonicoByPolizaId: Método que busca contactos telefónicos asociados a un set de PÓLIZAS
	 *
	 * @param setPolizaId : conjunto de Ids de póliza sobre los que se quiere buscar.
	
	 * @return mapa con los contactos telefónicos resultantes de la query
	 */
	public static Map<Id,Contacto_telefonico__c> queryContactoTelefonicoByPolizaId(Set<Id> setPolizaId){
		
		  Map<Id, Contacto_telefonico__c> mapaContactosTelefonicos = new Map<Id, Contacto_telefonico__c>();
				if(!setPolizaId.isEmpty()) {
					for(List<Contacto_telefonico__c> listaContactosTelefonicosAux:[SELECT Id,
																				        	CTF_LKP_Caso__c, 
																		                    CTF_LKP_Contacto__c, 
																		                    CTF_CAS_Contacto_Poliza__c, 
																		                    CTF_FOR_Email__c, 
																		                    CTF_FOR_Apellidos__c, 
																		                    CTF_SEL_Hora_desde__c, 
																		                    CTF_SEL_Hora_hasta__c, 
																		                    CTF_FOR_Nombre__c, 
																		                    CTF_TXT_Observaciones__c, 
																		                    CTF_FOR_Poliza_Contrato__c,
																		                    CTF_LKP_Poliza_Contrato__c, 
																		                    CTF_CAS_SMS__c, 
																		                    CTF_FOR_Telefono__c,
																		                    CTF_FOR_TelefonoAdicional__c,
																		                    CTF_FOR_TelefonoMovil__c,
																		                    CTF_SEL_Tipo_Relacion__c,
																		                    RecordTypeId
																					 FROM Contacto_telefonico__c 
																					 WHERE CTF_LKP_Poliza_Contrato__c IN :setPolizaId]){
							 mapaContactosTelefonicos.putAll(listaContactosTelefonicosAux);	 	
							}	
			  }
	    return mapaContactosTelefonicos;
	}

	/**
	 * queryMapCTByCaseId: Búsqueda de Contactos telefónicos por Id del caso/Intervención
	 *
	 * @param setCaseIds: IDs de los casos sobre los que se quiere buscar
	 *
	 * @return mapa de Contactos telefónicos obtenidos
	 */
	public static Map<Id,Contacto_telefonico__c> queryMapCTByCaseId(Set <Id> setCaseIds){
		
		Map<Id, Contacto_telefonico__c> mapaContactosTelefonicos = new Map<Id, Contacto_telefonico__c>();
		if(!setCaseIds.isEmpty()){
		
		 for(List<Contacto_telefonico__c> listaContactosTelefonicosAux:
					[SELECT Id,
				        	CTF_LKP_Caso__c, 
		                    CTF_LKP_Contacto__c, 
		                    CTF_CAS_Contacto_Poliza__c, 
		                    CTF_FOR_Email__c, 
		                    CTF_FOR_Apellidos__c, 
		                    CTF_SEL_Hora_desde__c, 
		                    CTF_SEL_Hora_hasta__c, 
		                    CTF_FOR_Nombre__c, 
		                    CTF_TXT_Observaciones__c, 
		                    CTF_FOR_Poliza_Contrato__c,
		                    CTF_LKP_Poliza_Contrato__c, 
		                    CTF_CAS_SMS__c, 
		                    CTF_FOR_Telefono__c,
		                    CTF_FOR_TelefonoAdicional__c,
		                    CTF_FOR_TelefonoMovil__c,
		                    CTF_SEL_Tipo_Relacion__c,
		                    RecordTypeId
								 FROM Contacto_telefonico__c 
								 WHERE CTF_LKP_Caso__c IN :setCaseIds]){
								 	mapaContactosTelefonicos.putAll(listaContactosTelefonicosAux);	
								 }
		}
		return mapaContactosTelefonicos;
	}

	/**
	 * queryMapCTByCaseIdAndContact: Búsqueda de Contactos telefónicos por Id del caso/Intervención e ID de Contacto
	 *
	 * @param setCaseIds: IDs de los casos sobre los que se quiere buscar
	 * @param setContactoIds: IDs de los contactos sobre los que se quiere buscar
	 *
	 * @return mapa de Contactos telefónicos obtenidos
	 */
	public static Map<Id,Contacto_telefonico__c> queryMapCTByCaseIdAndContact(Set <Id> setCaseIds, Set<Id> setContactoIds){
		
		Map<Id, Contacto_telefonico__c> mapaContactosTelefonicos = new Map<Id, Contacto_telefonico__c>();
		if(setCaseIds!=null && !setCaseIds.isEmpty() && setContactoIds!=null && !setContactoIds.isEmpty()){
		
		 for(List<Contacto_telefonico__c> listaContactosTelefonicosAux:
					[SELECT Id,
				        	CTF_LKP_Caso__c, 
		                    CTF_LKP_Contacto__c, 
		                    CTF_CAS_Contacto_Poliza__c, 
		                    CTF_FOR_Email__c, 
		                    CTF_FOR_Apellidos__c, 
		                    CTF_SEL_Hora_desde__c, 
		                    CTF_SEL_Hora_hasta__c, 
		                    CTF_FOR_Nombre__c, 
		                    CTF_TXT_Observaciones__c, 
		                    CTF_FOR_Poliza_Contrato__c,
		                    CTF_LKP_Poliza_Contrato__c, 
		                    CTF_CAS_SMS__c, 
		                    CTF_FOR_Telefono__c,
		                    CTF_FOR_TelefonoAdicional__c,
		                    CTF_FOR_TelefonoMovil__c,
		                    CTF_SEL_Tipo_Relacion__c,
		                    RecordTypeId
								 FROM Contacto_telefonico__c 
								 WHERE CTF_LKP_Caso__c IN :setCaseIds AND CTF_LKP_Contacto__c IN :setContactoIds]){
								 	mapaContactosTelefonicos.putAll(listaContactosTelefonicosAux);	
								 }
		}
		return mapaContactosTelefonicos;
	}

	/**
	 * Método que busca contactos telefónicos por query.
	 *
	 * @param setIdCT: IDs de los contactos telefónicos a buscar
	 * @param setPolizaCT: IDs de las polizas de contrato relacionadas con los contactos telefónicos a buscar
	 * @param setCasoCT: IDs de los casos relacionados con los contactos telefónicos a buscar
	 * @param setContactoCT: IDs de los contactos relacionados con los contactos telefónicos a buscar
	 *
	 * @return lista con los contactos telefónicos resultantes de la query
	 */
	/*public static List<Contacto_telefonico__c> queryContactoTelefonico(Set<Id> setIdCT, Set<Id> setPolizaCT, Set<Id> setCasoCT, Set<Id> setContactoCT){
		Boolean arg1 = setIdCT != null && !setIdCT.isEmpty();
		Boolean arg2 = setPolizaCT != null && !setPolizaCT.isEmpty();
		Boolean arg3 = setCasoCT != null && !setCasoCT.isEmpty();
		Boolean arg4 = setContactoCT != null && !setContactoCT.isEmpty();
		List<Contacto_telefonico__c> registros = new List<Contacto_telefonico__c>();
		if(arg1 || arg2 || arg3 || arg4){
			String sentenciaOT = 'SELECT Id,';
			sentenciaOT += ' Name,';
			sentenciaOT += ' RecordTypeId,';
			sentenciaOT += ' CTF_LKP_Caso__c,';
			sentenciaOT += ' CTF_LKP_Caso__r.Type,';
			sentenciaOT += ' CTF_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,';
			sentenciaOT += ' CTF_LKP_Caso__r.RecordTypeId,';
			sentenciaOT += ' CTF_LKP_Caso__r.ParentId,';
			sentenciaOT += ' CTF_LKP_Contacto__c,';
			sentenciaOT += ' CTF_LKP_Contacto__r.Phone,';
			sentenciaOT += ' CTF_LKP_Contacto__r.MobilePhone,';
			sentenciaOT += ' CTF_LKP_Poliza_Contrato__c,';
			sentenciaOT += ' CTF_LKP_Contacto_Telefonico__c,';
			sentenciaOT += ' CTF_CAS_Contacto_Poliza__c,';
			sentenciaOT += ' CTF_FOR_Nombre__c,';
			sentenciaOT += ' CTF_FOR_Apellidos__c,';
			sentenciaOT += ' CTF_FOR_Telefono__c,';
			sentenciaOT += ' CTF_FOR_TelefonoAdicional__c,';
			sentenciaOT += ' CTF_FOR_TelefonoMovil__c,';
			sentenciaOT += ' CTF_FOR_Email__c,';
			sentenciaOT += ' CTF_FOR_Poliza_Contrato__c,';
			sentenciaOT += ' CTF_TXT_Observaciones__c,';
			sentenciaOT += ' CTF_SEL_Tipo_Relacion__c,';
			sentenciaOT += ' CTF_SEL_Hora_desde__c,';
			sentenciaOT += ' CTF_SEL_Hora_hasta__c,';
			sentenciaOT += ' CTF_CAS_SMS__c';
			sentenciaOT += ' FROM Contacto_telefonico__c';
			String sentenciaOT_where = ' WHERE ';
			if(arg1){
				sentenciaOT_where += 'Id IN :setIdCT';
			}
			else{
				if(arg2){
					sentenciaOT_where += 'CTF_LKP_Poliza_Contrato__c IN :setPolizaCT';
				}
				if(arg3){
					if(sentenciaOT_where != ' WHERE '){
						sentenciaOT_where += ' AND ';
					}
					sentenciaOT_where += 'CTF_LKP_Caso__c IN :setCasoCT';
				}
				if(arg4){
					if(sentenciaOT_where != ' WHERE '){
						sentenciaOT_where += ' AND ';
					}
					sentenciaOT_where += 'CTF_LKP_Contacto__c IN :setContactoCT';
				}
			}
			sentenciaOT += sentenciaOT_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Contacto_Telefonico.queryContactoTelefonico.sentenciaOT: ' + sentenciaOT);
			registros = database.query(sentenciaOT);
		}
		return registros;
	}*/

	/**
	 * Método que busca contactos telefónicos por query.
	 *
	 * @param idCT: ID del contacto telefónico a buscar
	 * @param polizaCT: ID de la poliza de contrato relacionada con los contactos telefónicos a buscar
	 * @param casoCT: ID del caso relacionado con los contactos telefónicos a buscar
	 * @param contactoCT: ID del contacto relacionado con los contactos telefónicos a buscar
	 *
	 * @return lista con los contactos telefónicos resultantes de la query
	 */
	/*public static List<Contacto_telefonico__c> queryContactoTelefonico(Id idCT, Id polizaCT, Id casoCT, Id contactoCT){
		Set<Id> setIdCT = (idCT != null) ? (new Set<Id>{idCT}) : null;
		Set<Id> setPolizaCT = (polizaCT != null) ? (new Set<Id>{polizaCT}) : null;
		Set<Id> setCasoCT = (casoCT != null) ? (new Set<Id>{casoCT}) : null;
		Set<Id> setContactoCT = (contactoCT != null) ? (new Set<Id>{contactoCT}) : null;
		return queryContactoTelefonico(setIdCT,setPolizaCT,setCasoCT,setContactoCT);
	}*/

	/**
	 * Método que busca un contacto telefónico por ID.
	 *
	 * @param idCT: ID del contacto telefónico a buscar
	 *
	 * @return contacto telefónico con el ID especificado
	 */
	/*public static Contacto_telefonico__c queryContactoTelefonico(Id idCT){
		if(idCT != null){
			List<Contacto_telefonico__c> registros = queryContactoTelefonico(idCT,null,null,null);
			if(!registros.isEmpty()){
				return registros.get(0);
			}
		}
		return null;
	}*/
	
	/**
	* Devuelve los Contactos Telefónicos según el LKP a contacto y la poliza
	*
	* @param setContacto: Contacto asociados  
	* @param setpoliza: Poliza asociada
	*
	* @return mapa que contiene los Contactos Telefónicos
	*/
	public static Map<Id,Contacto_telefonico__c> getContTelByContactoyPoliza (set<Id> setContacto,set<Id> setPoliza){
	    Map<Id,Contacto_telefonico__c> mapa = new Map<Id,Contacto_telefonico__c>();
	    if(setContacto != null && !setContacto.isEmpty() && setPoliza != null && !setPoliza.isEmpty()){
	        for(List<Contacto_telefonico__c> lista:[SELECT Id 
													  FROM Contacto_telefonico__c
													  WHERE CTF_LKP_Contacto__c IN :setContacto
													  AND CTF_LKP_Poliza_Contrato__c IN :setPoliza]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}
	
		/**
	* Devuelve los Contactos Telefónicos basándonos en el valor del campo CTF_TXT_Observaciones__c
	*
	* @param setObservaciones: set Observaciones asociados  
	*
	* @return mapa que contiene los Contactos Telefónicos
	*/
	public static Map<Id,Contacto_telefonico__c> getContTelByObservaciones(set<String> setObservaciones){
	    Map<Id,Contacto_telefonico__c> mapa = new Map<Id,Contacto_telefonico__c>();
	    if(setObservaciones != null && !setObservaciones.isEmpty()){
	        for(List<Contacto_telefonico__c> lista:[
                  Select Id,
		                  CTF_LKP_Poliza_Contrato__c,
		                  CTF_SEL_Tipo_Relacion__c,
		                  CTF_LKP_Contacto__c
                  FROM	Contacto_telefonico__c 
                  Where	CTF_TXT_Observaciones__c IN :setObservaciones]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}
	
	/**
	* Devuelve los contactos telefonicos duplicados relacionados
	*
	* @param setIdContactoTel: Contactos Telefonico asociados  
	* @param setOtrosIdContactoTel: Antiguos Contactos Telefonico asociados 
	*
	* @return mapa que contiene los Contactos Telefónicos
	*/
	public static Map<Id,Contacto_telefonico__c> getContTelAntyNueAsociados (set<Id> setIdContactoTel,set<Id> setOtrosIdContactoTel){
	    Map<Id,Contacto_telefonico__c> mapa = new Map<Id,Contacto_telefonico__c>();
	    if(setIdContactoTel != null && !setIdContactoTel.isEmpty() && setOtrosIdContactoTel != null && !setOtrosIdContactoTel.isEmpty()){
	        for(List<Contacto_telefonico__c> lista:[SELECT Id
													 FROM Contacto_telefonico__c
													 WHERE Id IN: setIdContactoTel
													 OR CTF_LKP_Contacto_Telefonico__c IN :setOtrosIdContactoTel]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}
}