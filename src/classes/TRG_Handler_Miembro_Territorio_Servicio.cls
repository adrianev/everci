/**
 * Handler del Trigger TRG_Miembro_Territorio_De_Servicio.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Miembro_Territorio_Servicio {

    private static List<ResourceAbsence> listaRA = new List<ResourceAbsence>();
    
    /*
     *  Esta funcion genera el número de identificador en caso de que no se informe
     *  @param listaMTSNuevas       -   Lista del Objeto de Miembro de Territorio de Servicio
     *  @param listaMTSVieja        -   Mapa con el objeto de Miembro de Territorio de Servicio antes de hacer una modificación
     *  @param insercion            -   Booleano que nos indica si estamos realizando una inserción
     *  
    **/
    public static void tratamientoBefore(List<ServiceTerritoryMember> listaMTSNuevas, Map<Id, ServiceTerritoryMember> listaMTSVieja, Boolean insercion){
        Set<Id> idSetTServ = new Set<Id>();
        Set<Id> idSetRServ = new Set<Id>();
        Set<Id> idSetRAbse = new Set<Id>();
        
        for(ServiceTerritoryMember mts : listaMTSNuevas){
            if(!idSetTServ.contains(mts.ServiceTerritoryId)){
                idSetTServ.add(mts.ServiceTerritoryId);
            }
            if(!idSetRServ.contains(mts.ServiceResourceId)){
                idSetRServ.add(mts.ServiceResourceId);
            }
        }
        
        /*Map<Id, ServiceResource> mapaSR = new Map<Id, ServiceResource>(
                        [SELECT RSE_TXT_Codigo_Recurso__c
                         FROM ServiceResource
                         WHERE Id IN :idSetRServ]);*/
                         
                   Map<Id, ServiceResource> mapaSR = new Map<Id, ServiceResource>();
                   mapaSR = Util_Service_resource.queryMapSRByRsIds(idSetRServ);
                         
        /*Map<Id, ServiceTerritory> mapaST = new Map<Id, ServiceTerritory>(
                        [SELECT TDS_TXT_Identificador__c
                         FROM ServiceTerritory
                         WHERE Id IN :idSetTServ]);*/
                         
        Map<Id, ServiceTerritory> mapaST = new Map<Id, ServiceTerritory>();
        mapaST = Util_TerritorioServicio.getTerritorioServicioById(idSetTServ);
                        
        /*Map<Id, ResourceAbsence> mapaRALocalProvincial = new Map<Id, ResourceAbsence>(
        				[SELECT ResourceId
        				 FROM ResourceAbsence
        				 WHERE ResourceId in :idSetRServ
        				 AND Type =: Label.ABS_Tipo_Festivo_LocalProvincial]);*/
        				 
        Map<Id, ResourceAbsence> mapaRALocalProvincial = new Map<Id, ResourceAbsence>();				 
        mapaRALocalProvincial = Util_Service_Resource.getResourceAbsenceByIdAndType(idSetRServ);
        
        for(ServiceTerritoryMember mts : listaMTSNuevas){
        	// Parte que se encarga de generar/modificar el identificador externo
            if ((insercion && mts.MTS_TXT_Identificador__c == null) || (!insercion && !identificadorCorrecto(mts, mapaSR, mapaST))){
            	// Concatena el Id del Recurso de Servicio (RSE_TXT_Codigo_Recurso__c) y el Id Territorio de Servicio (TDS_TXT_Identificador)
                mts.MTS_TXT_Identificador__c =  mapaSR.get(mts.ServiceResourceId).RSE_TXT_Codigo_Recurso__c + '_' + mapaST.get(mts.ServiceTerritoryId).TDS_TXT_Identificador__c;
            }
            // Parte que se encarga de eliminar los absentismos locales y provinciales si se ha modificado la HomeBase del STM
            if(listaMTSVieja!=null && !listaMTSVieja.isEmpty()){
	            ServiceTerritoryMember STMViejo = listaMTSVieja.get(mts.Id);
	            if(mts.TerritoryType == 'P' && mts.PostalCode != STMViejo.PostalCode){
	            	resetFestivosLocalesProvinciales(mts, mapaRALocalProvincial);
	            }
            }
        }
        if(!listaRA.isEmpty()){
			// Le borramos todos los recursos de absentismo locales y provinciales de los MTS que se les ha modificado la HomeBase
			try {
				delete listaRA;
			}catch (ListException e) {
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
			}
			// Restablecemos la lista para los update
			listaRA = new List<ResourceAbsence>();
		}
    }
    
    /**
      * Método que devuelve si el identificador es correcto
      * 
      * @param mts: Miembro de Territorio de Servicio
      * @param mapaSR: Mapa con los Recursos de Servicio pertenecientes a los MTS
      * @param mapaST: Mapa con los Territorios de Servicio pertenecientes a los MTS
      * 
      * @return true si el identificador es correcto
      */
    private static Boolean identificadorCorrecto(ServiceTerritoryMember mts,  Map<Id, ServiceResource> mapaSR, Map<Id, ServiceTerritory> mapaST){
        if (mts.MTS_TXT_Identificador__c != mapaSR.get(mts.ServiceResourceId).RSE_TXT_Codigo_Recurso__c + '_' + mapaST.get(mts.ServiceTerritoryId).TDS_TXT_Identificador__c){
        	return false;
        }
        return true;
    }
        
    /**
      * Método que elimina los absentismos Locales y Provinciales de un Recurso de Servicio y marca su check de Procesado Festivo a false
      * 
      * @param mts: Miembro de Territorio de Servicio
      * @param mapaABS: Mapa con los Absentismos pertenecientes a los RS
      * 
      */
    private static void resetFestivosLocalesProvinciales(ServiceTerritoryMember mts, Map<Id, ResourceAbsence> mapaABS){
    	for(Id absId : mapaABS.keySet()){
    		if (mapaABS.get(absId).ResourceId == mts.ServiceResourceId){
    			listaRA.add(mapaABS.get(absId));
    		}
    	}
    	mts.MTS_CAS_Procesado_Festivo__c = false;
    }
}