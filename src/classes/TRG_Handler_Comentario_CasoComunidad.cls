/**
 * Handler del Trigger TRG_Comentario_CasoComunidad.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Comentario_CasoComunidad {

	/**
	  *  Esta funcion ejecuta los metodos necesarios para el tratamiento del before.
	  *  @param triggerNew  Lista con los objetos actualizados del trigger.new
	  */
	public static void tratamientoBefore(List<CaseComment> triggerNew){
		for(CaseComment com : triggerNew){
			com.IsPublished = true;
		}
	}

	/**
	  *  Esta funcion ejecuta los metodos necesarios para el tratamiento del after.
	  *  @param triggerNew  Lista con los objetos actualizados del trigger.new
	  */
	public static void tratamientoAfter(List<CaseComment> triggerNew){
		  
		List<Task> listaTareasInsert = new List<Task>();

		// Cargar casos-padre de los comentarios insertados
		Set<Id> setIdsCasos = new Set<Id>();
		for(CaseComment com : triggerNew){
			setIdsCasos.add(com.ParentId);
		}
		Map<Id, Case> mapaCasos = new Map<Id, Case>();
		if(!setIdsCasos.isEmpty()){
			mapaCasos = Util_Caso.getCaseById(setIdsCasos);
			//mapaCasos = new Map<Id, Case>([SELECT Id, OwnerId, CAS_LKP_Compania__c FROM Case WHERE Id IN :setIdsCasos]);
		}

		for(CaseComment com : triggerNew){
			Case caso = mapaCasos.get(com.ParentId);

			// Si el usuario actual es un usuario de la comunidad
			if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_COMUNIDAD){
				// Generar tarea al gestor actual del Caso
				Task tarea = Util_Tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_COMENT_COMUNIDAD,
													Label.TAR_ESTADO_EN_CURSO, null, caso.OwnerId,
													caso.Id, caso.CAS_LKP_Compania__c);
				listaTareasInsert.add(tarea);
			}
		}
		if(!listaTareasInsert.isEmpty()){
			insert listaTareasInsert;
		}
	}
}