/**
 * Clase de funciones auxiliares relativas a los Territorios de Servicio.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_TerritorioServicio {

	/**
	 * Devuelve los Miembros de Servicio de Territorio filtrando por: ((ServiceResourceId IN :setTodosProfesionalesNUEVAS OR ServiceResourceId IN :setTodosProfesionalesVIEJAS) AND TerritoryType IN setInTerritoryType) OR ((ServiceTerritoryId IN :setTerritorioProfesionalNUEVAS OR ServiceTerritoryId IN :setTerritorioProfesionalVIEJAS) AND (ServiceResourceId IN :setTodosProfesionalesNUEVAS OR ServiceResourceId IN :setTodosProfesionalesVIEJAS) AND TerritoryType NOT IN :setNotInTerritoryType).
	 *
	 * @param setTodosProfesionalesNUEVAS: conjunto de IDs de todos los Recursos de Servicio Profesionales nuevos
	 * @param setTodosProfesionalesVIEJAS: conjunto de IDs de todos los Recursos de Servicio Profesionales viejos
	 * @param setTerritorioProfesionalNUEVAS: conjunto de IDs los Recursos de Servicio Profesionales del territorio nuevos
	 * @param setTerritorioProfesionalVIEJAS: conjunto de IDs los Recursos de Servicio Profesionales del territorio viejos
	 * @param setInTerritoryType: conjunto de tipos de territorio en el IN del where
	 * @param setNotInTerritoryType: conjunto de tipos de territorio en el NOT IN del where
	 *
	 * @return mapa que contiene los çMiembros de Servicio de Territorio encontrados
	 */
	public static Map<Id,ServiceTerritoryMember> getSTMemberBySRAndServiceTerritory(Set<Id> setTodosProfesionalesNUEVAS, Set<Id> setTodosProfesionalesVIEJAS, Set<Id> setTerritorioProfesionalNUEVAS, Set<Id> setTerritorioProfesionalVIEJAS, Set<String> setInTerritoryType, Set<String> setNotInTerritoryType){
		Map<Id,ServiceTerritoryMember> mapa = new Map<Id,ServiceTerritoryMember>();
		if(setTodosProfesionalesNUEVAS != null && !setTodosProfesionalesNUEVAS.isEmpty() && setTodosProfesionalesVIEJAS != null && !setTodosProfesionalesVIEJAS.isEmpty() && setTerritorioProfesionalNUEVAS != null && !setTerritorioProfesionalNUEVAS.isEmpty() && setTerritorioProfesionalVIEJAS != null && !setTerritorioProfesionalVIEJAS.isEmpty() && setInTerritoryType != null && !setInTerritoryType.isEmpty() && setNotInTerritoryType != null && !setNotInTerritoryType.isEmpty()){
			for(List<ServiceTerritoryMember> lista:[SELECT ServiceResourceId,ServiceTerritoryId,TerritoryType,OperatingHoursId,MTS_CAS_Creado_para_guardia__c FROM ServiceTerritoryMember WHERE ((ServiceResourceId IN :setTodosProfesionalesNUEVAS OR ServiceResourceId IN :setTodosProfesionalesVIEJAS) AND TerritoryType IN :setInTerritoryType) OR ((ServiceTerritoryId IN :setTerritorioProfesionalNUEVAS OR ServiceTerritoryId IN :setTerritorioProfesionalVIEJAS) AND (ServiceResourceId IN :setTodosProfesionalesNUEVAS OR ServiceResourceId IN :setTodosProfesionalesVIEJAS) AND TerritoryType NOT IN :setNotInTerritoryType)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 *  A partir de un Código Postal, devuelve una lista seleccionable de poblaciones asociadas al mismo.
	 *  Para cada población devuelve:
	 *  Valor: CódigoProvincia#NombrePoblación
	 *  Etiqueta: NombrePoblación
	 *  
	 *  @param codigoPostal Código Postal sobre el que buscar
	 *  @return listaPoblaciones Lista de poblaciones seleccionables
	 **/
	public static List<SelectOption> cargarListaPoblacionPorCP(String codigoPostal){
		List<SelectOption> listaPoblaciones = new List<SelectOption>();
		listaPoblaciones.add(new SelectOption('', '-- Ninguno --'));
		if(codigoPostal != null){
			List<Poblacion_CP__c> listaPobCP = Util_Poblacion.queryPoblacion_CPByPCP_LKP_TerritorioServicio_r_TDS_TXT_Identificador(new Set<String>{codigoPostal}).values();
			/*List<Poblacion_CP__c> listaPobCP = new List<Poblacion_CP__c>(
				[SELECT PCP_LKP_Poblacion__r.POB_SEL_Provincia__c,
						PCP_LKP_Poblacion__r.Name
				 FROM Poblacion_CP__c 
				 WHERE PCP_LKP_TerritorioServicio__r.TDS_TXT_Identificador__c = :codigoPostal]);*/
			for(Poblacion_CP__c objPobCP : listaPobCP){
				String provincia = objPobCP.PCP_LKP_Poblacion__r.POB_SEL_Provincia__c;
				String poblacion = objPobCP.PCP_LKP_Poblacion__r.Name;
				if(poblacion != null){
					//Valor: CódigoProvincia#NombrePoblación
					//Etiqueta: NombrePoblación
					listaPoblaciones.add(new SelectOption(provincia + '#' + poblacion, poblacion));
				}
			}
			// Si solo se ha cargado un valor adicional al valor 'Ninguno': se elimina el valor 'Ninguno'
			if(listaPoblaciones.size() == 2){
				listaPoblaciones.remove(0);
			}
		}
		return listaPoblaciones;
	}

	/**
	 *  A partir de un Código Postal, devuelve una lista seleccionable de poblaciones asociadas al mismo.
	 *  Para cada población devuelve:
	 *  Valor: CódigoProvincia#NombrePoblación
	 *  Etiqueta: NombrePoblación
	 *  
	 *  @param setCodigoPostal Código Postal sobre el que buscar
	 *  @return listaPoblaciones Lista de poblaciones seleccionables
	 **/
	public static List<SelectOption> cargarListaSeleccionPoblacionPorCP(Set<String> setCodigoPostal){
		List<SelectOption> listaPoblaciones = new List<SelectOption>();
		listaPoblaciones.add(new SelectOption('', '-- Ninguno --'));
		if(setCodigoPostal != null && !setCodigoPostal.isEmpty()){
			List<Poblacion_CP__c> listaPobCP = Util_Poblacion.queryPoblacion_CPByPCP_LKP_TerritorioServicio_r_TDS_TXT_Identificador(setCodigoPostal).values();
			/*List<Poblacion_CP__c> listaPobCP = new List<Poblacion_CP__c>(
				[SELECT PCP_LKP_Poblacion__r.POB_SEL_Provincia__c,
						PCP_LKP_Poblacion__r.Name
				 FROM Poblacion_CP__c 
				 WHERE PCP_LKP_TerritorioServicio__r.TDS_TXT_Identificador__c IN :setCodigoPostal]);*/
			for(Poblacion_CP__c objPobCP : listaPobCP){
				String provincia = objPobCP.PCP_LKP_Poblacion__r.POB_SEL_Provincia__c;
				String poblacion = objPobCP.PCP_LKP_Poblacion__r.Name;
				if(poblacion != null){
					//Valor: CódigoProvincia#NombrePoblación
					//Etiqueta: NombrePoblación
					listaPoblaciones.add(new SelectOption(provincia + '#' + poblacion, poblacion));
				}
			}
			// Si solo se ha cargado un valor adicional al valor 'Ninguno': se elimina el valor 'Ninguno'
			if(listaPoblaciones.size() == 2){
				listaPoblaciones.remove(0);
			}
		}
		return listaPoblaciones;
	}
	
	/**
	 *  A partir de la selección hecha, se obtiene la población
	 *  
	 *  @param poblacionSelecOpt Selección realizada
	 *  @return población seleccionada
	 **/
	public static String obtenerPoblacionSel(String poblacionSelecOpt){
		String ret = null;
		if(poblacionSelecOpt != null && poblacionSelecOpt.indexOf('#') > 0){
			ret = poblacionSelecOpt.substring(poblacionSelecOpt.indexOf('#')+1);
		}
		return ret;
	}

	/**
	 *  A partir de la selección hecha, se obtiene la provincia.
	 *  
	 *  @param poblacionSelecOpt Selección realizada
	 *  @return provincia seleccionada
	 **/
	public static String obtenerProvinciaSel(String poblacionSelecOpt){
		String ret = null;
		if(poblacionSelecOpt != null && poblacionSelecOpt.indexOf('#') > 0){
			ret = poblacionSelecOpt.substring(0, poblacionSelecOpt.indexOf('#'));
		}
		return ret;
	}

	/**
	 *  Obtiene un mapa de territorios cuya clave es la combinación:
	 *  CódigoProvincia#CódigoPostal#NombrePoblación
	 *  @param codigosProvincias provincias para filtrar
	 *  @param codigosPostales cp para filtrar
	 *  @param codigosPostales poblaciones para filtrar
	 *  @return mapa de territorios
	 **/
	public static Map<String, ServiceTerritory> getMapaTerrActPorCP(Set<String> codigosPostales){
		Map<String, ServiceTerritory> mapa = new Map<String, ServiceTerritory>();
		if(!codigosPostales.isEmpty()){
			List<ServiceTerritory> lista = new List<ServiceTerritory>(
					[SELECT Id,
							IsActive,
							Name,
							PostalCode,
					 		ParentTerritoryId,
					 		TDS_TXT_Identificador__c
					 FROM ServiceTerritory
					 WHERE IsActive = true
					 AND TDS_TXT_Identificador__c IN :codigosPostales]);
			for(ServiceTerritory registro : lista){
				mapa.put(registro.TDS_TXT_Identificador__c, registro);
			}
		}
		return mapa;
	}

	/**
	 *  A partir de un código postal, se obtiene si es provincia.
	 *  
	 *  @param codigoPostal: código postal
	 *  @return true si es capital de provincia y false si no lo es
	 **/
	public static boolean esCapitalDeProvincia(String codigoPostal){
        system.debug(codigoPostal + ' CP');
		String val = codigoPostal.substring(2,3);
		String cp = codigoPostal.substring(0,3);
		if(val == '0' || cp == Label.CP_VIGO || cp == Label.CP_GIJON ||
			cp == Label.CP_VIGO_2){
			return true;
		}else{
			return false;
		}
	}


	/**
	* Devuelve los Miembros de Territorio principales activos cuya provincia/CP se encuentre entre los Festivos a procesar
	*
	* @param setCPostales: códigos postales
	* @param setProvincia: provincias
	*
	* @return mapa que contiene los miembros de territorio
	*/
	public static Map<Id,ServiceTerritoryMember> getMiembrosFestivos(set<String> setCPostales,set<String> setProvincia){
	    Map<Id,ServiceTerritoryMember> mapa = new Map<Id,ServiceTerritoryMember>();
	    if(setCPostales != null && !setCPostales.isEmpty() && setProvincia != null && !setProvincia.isEmpty()){
	        for(List<ServiceTerritoryMember> lista:[SELECT ServiceResourceId, MTS_FOR_Provincia__c, ServiceResource.RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c,PostalCode FROM ServiceTerritoryMember 
										WHERE (PostalCode IN: setCPostales OR MTS_FOR_Provincia__c IN: setProvincia)  AND TerritoryType = 'P'
										AND ServiceResource.IsActive = true]){
	            mapa.putAll(lista);
	        }               
	    }
	    return mapa;
	}

	/**
	* Devuelve un objeto ServiceTerritory desde su Id
	*
	* @param idSetTServ: id del territorio de servicio
	*
	* @return mapa que contiene los objetos ServiceTerritory
	*/
	public static Map<Id, ServiceTerritory> getTerritorioServicioById(set<Id> idSetTServ){
		Map<Id, ServiceTerritory> mapa = new Map<Id, ServiceTerritory>();
		if(idSetTServ != null && !idSetTServ.isEmpty()){
	        for(List<ServiceTerritory> lista:[SELECT TDS_TXT_Identificador__c
                         FROM ServiceTerritory
                         WHERE Id IN :idSetTServ]){
	            mapa.putAll(lista);
	        }               
	    } 
	    return mapa;
	}
}