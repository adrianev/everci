/**
 * Clase de funciones auxiliares relativas a las procedencias.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Procedencia {

	public static Id getProcedencia(Id	recordTypeCaseId, Id companiaCaseId, Map<Id, Procedencia__c> mapaProcedencias){
		Id idProcedencia = null;
		//Boolean esB2C = (recordTypeCaseId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C) ||
		//				   recordTypeCaseId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C));

		for(Procedencia__c proc : mapaProcedencias.values()) {
			String tiposDeCaso = '';
			if(proc.PROC_SEL_Tipos_Caso__c != null){
				tiposDeCaso = ';' + proc.PROC_SEL_Tipos_Caso__c + ';';
			}

			//system.debug('>>>>>>>>>>>> getProcedencia: recordTypeCaseId (caso.RecordTypeId): ' + recordTypeCaseId);
			//system.debug('>>>>>>>>>>>> getProcedencia: companiaCaseId (caso.CAS_LKP_Compania__c): ' + companiaCaseId);
			//system.debug('>>>>>>>>>>>> getProcedencia: proc: ' + proc);
			//system.debug('>>>>>>>>>>>> getProcedencia: esB2C: ' + esB2C);
			//system.debug('>>>>>>>>>>>> getProcedencia: companiaCaseId: ' + companiaCaseId);
			//system.debug('>>>>>>>>>>>> getProcedencia: proc.PROC_LKP_Cuenta__c: ' + proc.PROC_LKP_Cuenta__c);
			//system.debug('>>>>>>>>>>>> getProcedencia: tiposDeCaso: ' + tiposDeCaso);

			/*
			// Si es B2C y no hay Poliza: la procedencia es Canal Digital, código 0000
			if (esB2C && companiaCaseId == null) {
				if (proc.PROC_LKP_Cuenta__r.CUE_TXT_Identificador__c == Label.IDE_HOMESERVE &&
					tiposDeCaso.contains(';' + Label.PROCEDENCIA_SERVICIO_B2C + ';')){
					idProcedencia = proc.Id;
					break;
				}
			}
			// Si es Siniestro o Servicio B2C de Asegurado: la procedencia es la correspondiente de las de la CIA
			else {
			 */
			if(proc.PROC_LKP_Cuenta__c == companiaCaseId &&
					tiposDeCaso.contains(';' + Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(recordTypeCaseId) + ';')){
				idProcedencia = proc.Id;
				break;
			}
			//}
		}

		return idProcedencia;
	}

	public static List<Procedencia__c> queryProcedencia(Id idProcedencia){
		return queryProcedencia(idProcedencia, false);
	}

	/**
	 * Devuelve las procedencias filtrando por los IDs.
	 *
	 * @param setIdProcedencia: conjunto de IDs de procedencia
	 *
	 * @return mapa que contiene las procedencias encontradas
	 */
	public static Map<Id,Procedencia__c> queryProcedencia(Set<Id> setIdProcedencia){
		Map<Id,Procedencia__c> mapa = new Map<Id,Procedencia__c>();
		if(setIdProcedencia != null && !setIdProcedencia.isEmpty()){
			for(List<Procedencia__c> lista:[SELECT Id,Name,PROC_CAS_No_Requiere_Albaran__c,PROC_CAS_Requiere_Declaracion_Resp__c,PROC_NUM_Contador__c,PROC_NUM_Contador_Rechazos__c,PROC_NUM_Tiempo_Atencion_Urgencias__c,PROC_SEL_Motivos_rechazo_presupuesto__c,PROC_SEL_Motivos_Anulacion__c,PROC_SEL_Canal__c,PROC_SEL_Gremios_Disp__c,PROC_SEL_Subcanal__c FROM Procedencia__c WHERE Id IN :setIdProcedencia]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene una procedencia a partir del ID de procedencia
	 * 
	 * @param idProcedencia ID de Procedencia a buscar
	 * @return lista de Procedencias que coinciden con el ID
	 */
	public static List<Procedencia__c> queryProcedencia(Id idProcedencia, Boolean forUpdate){
		List<Procedencia__c> listaProcedencias = new List<Procedencia__c>();
		if(idProcedencia != null){
			/*listaProcedencias.add([SELECT Name
										,PROC_CAS_No_Requiere_Albaran__c
										,PROC_CAS_Requiere_Declaracion_Resp__c
										,PROC_NUM_Contador__c
										,PROC_NUM_Contador_Rechazos__c
										,PROC_NUM_Tiempo_Atencion_Urgencias__c
										,PROC_SEL_Canal__c
										,PROC_SEL_Gremios_Disp__c
										,PROC_SEL_Subcanal__c
									FROM Procedencia__c 
									WHERE ID = :idProcedencia FOR UPDATE]);*/
			
			String sentenciaProcedencia = 'SELECT Id,';
			sentenciaProcedencia += ' Name,';
			sentenciaProcedencia += ' PROC_CAS_No_Requiere_Albaran__c,';
			sentenciaProcedencia += ' PROC_CAS_Requiere_Declaracion_Resp__c,';
			sentenciaProcedencia += ' PROC_NUM_Contador__c,';
			sentenciaProcedencia += ' PROC_NUM_Contador_Rechazos__c,';
			sentenciaProcedencia += ' PROC_NUM_Tiempo_Atencion_Urgencias__c,';
			sentenciaProcedencia += ' PROC_SEL_Motivos_rechazo_presupuesto__c,';
			sentenciaProcedencia += ' PROC_SEL_Motivos_Anulacion__c,';
			sentenciaProcedencia += ' PROC_SEL_Canal__c,';
			sentenciaProcedencia += ' PROC_SEL_Gremios_Disp__c,';
			sentenciaProcedencia += ' PROC_SEL_Subcanal__c';	
			sentenciaProcedencia += ' FROM Procedencia__c';
			sentenciaProcedencia += ' WHERE Id = \'' + idProcedencia + '\'';
			if(forUpdate)
				sentenciaProcedencia += ' FOR UPDATE';
			listaProcedencias = database.query(sentenciaProcedencia);
		}
		return listaProcedencias;
	}

	/**
	 * Devuelve las procedencias filtradas por IDs de Cuentas y por un valor de PROC_SEL_Tipos_Caso__c.
	 *
	 * @param setIdAccount: conjunto de IDs de Cuentas
	 * @param selValTiposCaso: valor contenido en PROC_SEL_Tipos_Caso__c
	 *
	 * @return mapa que contiene las Cuentas encontradas
	 */
	public static Map<Id,Procedencia__c> getProcedenciaByAccountTiposCaso(Set<Id> setIdAccount, String selValTiposCaso){
		Map<Id,Procedencia__c> mapa = new Map<Id,Procedencia__c>();
		if(setIdAccount != null && !setIdAccount.isEmpty() && selValTiposCaso != null){
			for(List<Procedencia__c> lista:[SELECT Id,PROC_SEL_Gremios_Disp__c, PROC_SEL_Canal__c FROM Procedencia__c WHERE PROC_SEL_Tipos_Caso__c includes (:selValTiposCaso) AND PROC_LKP_Cuenta__c IN :setIdAccount]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve las procedencias filtradas por IDs de Cuentas
	 *
	 * @param setIdAccount: conjunto de IDs de Cuentas
	 *
	 * @return mapa que contiene las Cuentas encontradas
	 */
	public static Map<Id,Procedencia__c> getProcedenciaByAccount(Set<Id> setIdAccount){
		Map<Id,Procedencia__c> mapa = new Map<Id,Procedencia__c>();
		if(setIdAccount != null && !setIdAccount.isEmpty()){
			for(List<Procedencia__c> lista:[SELECT Id,PROC_SEL_Gremios_Disp__c, PROC_SEL_Canal__c FROM Procedencia__c WHERE PROC_LKP_Cuenta__c IN :setIdAccount]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene una procedencia a partir del ID de su cuenta.
	 *
	 * @param idCuenta ID de cuenta de la procedencia a buscar
	 * @return lista de Procedencias que coinciden con el ID de su cuenta
	 */
	public static List<Procedencia__c> queryProcedenciaPorCuenta(Id idCuenta){
		if(idCuenta != null){
			return [SELECT Id,
							Name,
							PROC_CAS_No_Requiere_Albaran__c,
							PROC_CAS_Requiere_Declaracion_Resp__c,
							PROC_NUM_Contador__c,
							PROC_NUM_Contador_Rechazos__c,
							PROC_NUM_Tiempo_Atencion_Urgencias__c,
							PROC_SEL_Canal__c,
							PROC_SEL_Gremios_Disp__c,
							PROC_SEL_Subcanal__c
					FROM Procedencia__c
					WHERE PROC_LKP_Cuenta__c = :idCuenta];
		}
		return new List<Procedencia__c>();
	}

	/**
	 * Obtiene una procedencia a partir del ID de su cuenta y de su tipo de registro.
	 *
	 * @param idCuenta ID de cuenta de la procedencia a buscar
	 * @return lista de Procedencias con el tipo de registro especificado que coinciden con el ID de su cuenta
	 */
	public static List<Procedencia__c> queryProcedenciaPorCuenta(Id idCuenta, String tipoReg){
		if(idCuenta != null){
			return [SELECT Id,
							Name,
							PROC_CAS_No_Requiere_Albaran__c,
							PROC_CAS_Requiere_Declaracion_Resp__c,
							PROC_NUM_Contador__c,
							PROC_NUM_Contador_Rechazos__c,
							PROC_NUM_Tiempo_Atencion_Urgencias__c,
							PROC_SEL_Canal__c,
							PROC_SEL_Gremios_Disp__c,
							PROC_SEL_Subcanal__c
					FROM Procedencia__c
					WHERE PROC_LKP_Cuenta__c = :idCuenta
					AND PROC_SEL_Tipos_Caso__c includes (:tipoReg)];
		}
		return new List<Procedencia__c>();
	}
	
/**
 * Query sobre procedencias con bloqueo
 *
 * @return mapa de Procedencias 
 */
	public static Map<Id,Procedencia__c> queryProcedenciasForUpdate(){
		Map<Id,Procedencia__c> mapa = new Map<Id,Procedencia__c> ();
		for(List<Procedencia__c> lista:[SELECT Name,
								PROC_SEL_Tipos_Caso__c,
								PROC_LKP_Cuenta__c,
								PROC_LKP_Cuenta__r.CUE_TXT_Identificador__c,
								PROC_TXT_Identificador__c
						 FROM Procedencia__c
						 FOR UPDATE] ){
						 	mapa.putAll(lista);
						 }
		return mapa;
	}
	
/**
 * Query sobre procedencias sin condición
 *
 * @return mapa de Procedencias 
 */
	public static Map<Id,Procedencia__c> queryProcedenciasNoWhere(){
		Map<Id,Procedencia__c> mapa = new Map<Id,Procedencia__c> ();
		for(List<Procedencia__c> lista:[SELECT Name,
						PROC_SEL_Tipos_Caso__c,
						PROC_LKP_Cuenta__c,
						PROC_LKP_Cuenta__r.CUE_TXT_Identificador__c,
						PROC_TXT_Identificador__c
						 FROM Procedencia__c
						 ] ){
						 	mapa.putAll(lista);
						 }
		return mapa;
	}





	
	
}