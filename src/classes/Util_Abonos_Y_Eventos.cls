global without sharing class Util_Abonos_Y_Eventos {

    webService static String cambiarEstadoAbono(String idAbono){
		List<Propuesta_de_Abono__c> abonoList = new List<Propuesta_de_Abono__c>(getPropuestaAbonoById(new Set<Id>{idAbono}).values());
		/*List<Propuesta_de_Abono__c> abonoList = new List<Propuesta_de_Abono__c>([SELECT AB_SEL_Estado__c FROM Propuesta_de_Abono__c
										WHERE Id = :idAbono]);*/
        Profile perfil = Util_Perfiles_Usuario.queryProfileById(new Set<Id>{system.UserInfo.getProfileId()}).get(system.UserInfo.getProfileId());
        //Profile perfil = [SELECT id, Name FROM Profile WHERE id = : system.UserInfo.getProfileId()];
        if(perfil.Name != Label.PERFIL_ADMINISTRADOR && perfil.Name != Label.PERFIL_SUPERVISOR_RECLAMACIONES
          && perfil.Name != Label.PERFIL_MIGRACION && perfil.Name != Label.PERFIL_DIRECTOR_IT && perfil.Name != Label.PERFIL_SUBDIRECTOR_IT && perfil.Name != Label.PERFIL_GESTOR_RECLAMACIONES){
            return 'error';
        }
        
        String cambioEstado = 'false';
        if(!abonoList.isEmpty()){
            for(Propuesta_de_Abono__c abono: abonoList){
                if(abono.AB_SEL_Estado__c == '04'){
                    abono.AB_SEL_Estado__c = '01';
            		Baipas.establecerVariableControl();
                    update abono;
                    Baipas.deshabilitarVariableControl();
					cambioEstado = 'true';
                }
               
            }
        }else{
			cambioEstado = 'false';
		}
        return cambioEstado;
       
	}
    
    webService static String cambiarEstadoEvento(String eventoId){
    	List<Propuesta_de_Evento__c> eventoList = new List<Propuesta_de_Evento__c>(getPropuestaEventoById(new Set<Id>{eventoId}).values());
		/*List<Propuesta_de_Evento__c> eventoList = new List<Propuesta_de_Evento__c>([SELECT EV_AB_SEL_Estado__c  FROM Propuesta_de_Evento__c
										WHERE Id = :eventoId]);*/
        String cambioEstado = 'false';
        Profile perfil = Util_Perfiles_Usuario.queryProfileById(new Set<Id>{system.UserInfo.getProfileId()}).get(system.UserInfo.getProfileId());
        //Profile perfil = [SELECT id, Name FROM Profile WHERE id = : system.UserInfo.getProfileId()];
        if(perfil.Name != Label.PERFIL_ADMINISTRADOR && perfil.Name != Label.PERFIL_SUPERVISOR_RECLAMACIONES
          && perfil.Name != Label.PERFIL_MIGRACION && perfil.Name != Label.PERFIL_DIRECTOR_IT && perfil.Name != Label.PERFIL_SUBDIRECTOR_IT && perfil.Name != Label.PERFIL_GESTOR_RECLAMACIONES){
            return 'error';
        }
        if(!eventoList.isEmpty()){
            for(Propuesta_de_Evento__c evento: eventoList){
                if(evento.EV_AB_SEL_Estado__c == '04'){
                    evento.EV_AB_SEL_Estado__c = '01';
                    Baipas.establecerVariableControl();
            		update evento;
                    Baipas.deshabilitarVariableControl();   
					cambioEstado = 'true';
                }
            }
        }else{
			cambioEstado = 'false';
		}
        return cambioEstado;
	}

	/**
	 * Devuelve las propuestas de evento filtradas por OT y Descripción.
	 *
	 * @param setIdWorkOrder: conjunto de IDs de OT
	 * @param setStringDescripcion: conjunto de Descripciones
	 *
	 * @return mapa que contiene las propuestas de evento encontradas
	 */
	public static Map<Id,Propuesta_de_Evento__c> getPropuestaEventoByWorkOrderAndDescripcion(Set<Id> setIdWorkOrder, Set<String> setStringDescripcion){
		Map<Id,Propuesta_de_Evento__c> mapa = new Map<Id,Propuesta_de_Evento__c>();
		if(setIdWorkOrder != null && !setIdWorkOrder.isEmpty() && setStringDescripcion != null && !setStringDescripcion.isEmpty()){
			for(List<Propuesta_de_Evento__c> lista:[SELECT Id,EV_AB_DIV_Importe_profesional__c,EV_AB_SEL_Estado__c FROM Propuesta_de_Evento__c WHERE EV_AB_LKP_Orden_de_Trabajo__c IN :setIdWorkOrder AND EV_AB_SEL_Descripcion__c IN :setStringDescripcion]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las propuestas de evento filtradas por OT.
	 *
	 * @param setIdWorkOrder: conjunto de IDs de OT
	 *
	 * @return mapa que contiene las propuestas de evento encontradas
	 */
	public static Map<Id,Propuesta_de_Evento__c> getPropuestaEventoByWorkOrder(Set<Id> setIdWorkOrder){
		Map<Id,Propuesta_de_Evento__c> mapa = new Map<Id,Propuesta_de_Evento__c>();
		if(setIdWorkOrder != null && !setIdWorkOrder.isEmpty()){
			for(List<Propuesta_de_Evento__c> lista:[SELECT Id,EV_AB_DIV_Importe_profesional__c,EV_AB_SEL_Estado__c FROM Propuesta_de_Evento__c WHERE EV_AB_LKP_Orden_de_Trabajo__c IN :setIdWorkOrder]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las propuestas de evento filtradas por los ID's.
	 *
	 * @param setIds: conjunto de IDs de propuestas de evento
	 *
	 * @return mapa que contiene las propuestas de evento encontradas
	 */
	public static Map<Id,Propuesta_de_Evento__c> getPropuestaEventoById(Set<Id> setIds){
		Map<Id,Propuesta_de_Evento__c> mapa = new Map<Id,Propuesta_de_Evento__c>();
		if(setIds != null && !setIds.isEmpty()){
			for(List<Propuesta_de_Evento__c> lista:[SELECT Id,EV_AB_DIV_Importe_profesional__c,EV_AB_SEL_Estado__c FROM Propuesta_de_Evento__c WHERE Id IN :setIds]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las propuestas de abono filtradas por los ID's.
	 *
	 * @param setIds: conjunto de IDs de propuestas de abono
	 *
	 * @return mapa que contiene las propuestas de abono encontradas
	 */
	public static Map<Id,Propuesta_de_Abono__c> getPropuestaAbonoById(Set<Id> setIds){
		Map<Id,Propuesta_de_Abono__c> mapa = new Map<Id,Propuesta_de_Abono__c>();
		if(setIds != null && !setIds.isEmpty()){
			for(List<Propuesta_de_Abono__c> lista:[SELECT Id,Name,AB_SEL_Estado__c FROM Propuesta_de_Abono__c WHERE Id IN :setIds]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}