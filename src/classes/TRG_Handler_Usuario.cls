/**
  * Handler del Trigger TRG_Usuario.
  * 
  * @author EVERIS
  * 
  */
public with sharing class TRG_Handler_Usuario {
	
	public static Map<String,Id> fslMobile;
    /**
      * Tratamiento después de insertar registros.
      * 
      * @param triggerNew: lista de usuarios nuevos
      */
    public static void tratamientoAfterInsert(List<User> triggerNew){
    	fslMobile = Util_Perfiles_Usuario.getMapNamePerfilesUsuario();
		Map<String,Id> mapaPermisos = Util_Perfiles_Usuario.getMapPermissionSet();
        List<PermissionSetAssignment> listaPSA = new List<PermissionSetAssignment>();
        for (User usr : triggerNew) {
        	if(usr.profileId==fslMobile.get(Label.PERFIL_PROFESIONAL)){
        		if (usr.IsActive){
        			// Creamos los permisionSetAssignment
        			listaPSA.addAll(Util_Perfiles_Usuario.getPermissionSetAssigmentProfesional(usr.Id,mapaPermisos));
        		}
        		Util_Profesionales profesionales = new Util_Profesionales(usr);
        		System.enqueueJob(profesionales);
        	}
        	else if(Util_Perfiles_Usuario.isGestorOrSupervisorActive(usr,fslMobile)){
        		listaPSA.addAll(Util_Perfiles_Usuario.getPermissionSetAssigmentGestoresSupervisores(usr.Id,mapaPermisos));
        	}
        	else if(usr.profileId==fslMobile.get(Label.PERFIL_ADMINISTRADOR) && usr.IsActive){
        		listaPSA.addAll(Util_Perfiles_Usuario.getPermissionSetAssigmentAdministrador(usr.Id,mapaPermisos));
        	}
        }
        if(!Test.isRunningTest()){
        	insert listaPSA;
        }
    }
    
    /**
      * Tratamiento después de actualizar registros.
      * 
      * @param triggerNewMap: mapa de usuarios actualizados
      * @param triggerNew: lista de usuarios actualizados
      * @param triggerOldMap: mapa de usuarios con su valor antes de la actualización
      * @param triggerOld: lista de usuarios con su valor antes de la actualización
      */
    public static void tratamientoAfterUpdate(Map<Id,User> triggerNewMap, List<User> triggerNew, Map<Id,User> triggerOldMap, List<User> triggerOld){
    	if (fslMobile == null) {
    		fslMobile = Util_Perfiles_Usuario.getMapNamePerfilesUsuario();
    	}
    	//Creo un set con los usuarios que han actualizado el IsActive
    	Set<Id> relatedRecordId = new Set<Id>();
    	for(User usuario: triggerNew){
    		User userOld;
    		if(triggerOldMap != null){
				userOld = triggerOldMap.get(usuario.Id);
			}
			if((usuario.isActive && userOld != null && !userOld.IsActive) || (!usuario.isActive && userOld != null && userOld.IsActive)){
    			relatedRecordId.add(usuario.Id);
			}
			if(usuario.profileId==fslMobile.get(Label.PERFIL_PROFESIONAL)){
        		Util_Profesionales profesionales = new Util_Profesionales(usuario);
        		System.enqueueJob(profesionales);
        	}
    	}
    	
    	//Creamos una lista con los recursos de servicio relacionados
    	List<ServiceResource> listServiceResource = new List<ServiceResource>([Select Id, RSE_LKP_Profesional_Gremio__c from ServiceResource where RelatedRecordId in :relatedRecordId]);
    	//Si se ha modificado el IsActive, se actualiza el número de recursos activos para un determinado profesional_gremio
		if(!listServiceResource.isEmpty()){
			//Serializar listServiceResource
			String listServiceResourceSerializado = JSON.serialize(listServiceResource);
			//Llamar al método Util_Service_Resource.actualizarRecursosActivosFuture de forma asíncrona
			Util_Service_Resource.actualizarRecursosActivosFuture(listServiceResourceSerializado);
		}
    }
}