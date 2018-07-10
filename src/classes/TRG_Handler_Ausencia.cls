/**
  * Handler del Trigger TRG_Ausencia.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Ausencia {

	/**
	  * [PENDIENTE]
	  * 
	  * @param ausenciaList: [PENDIENTE]
	  */
	public static void comprobarGuardia(List<ResourceAbsence> ausenciaList){

		Boolean esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());

		if(esProfesional){
			Map<Id, Set<ResourceAbsence>> profesionalAusenciaMap = new Map<Id, Set<ResourceAbsence>>();
			for(ResourceAbsence ra: ausenciaList){
				if(profesionalAusenciaMap.containsKey(ra.ResourceId)){
					profesionalAusenciaMap.get(ra.ResourceId).add(ra);
				}
				else {
					Set<ResourceAbsence> raSet = new Set<ResourceAbsence>();
					raSet.add(ra);
					profesionalAusenciaMap.put(ra.ResourceId, raSet);
				}
			}

			List<Guardia__c> guardiaList = Util_Service_Resource.getGuardiaByProfesionalAndFechaFin(profesionalAusenciaMap.keySet(),Date.today()).values();
			//List<Guardia__c> guardiaList = Util_Service_Resource.queryMapGuardias(profesionalAusenciaMap.keySet(),Date.today()).values();
			/*List<Guardia__c> guardiaList = [SELECT GUA_LKP_Territorio__c, GUA_LKP_Profesional__c, GUA_DAT_Fecha_Inicio__c, GUA_DAT_Fecha_Fin__c FROM Guardia__c
											WHERE GUA_DAT_Fecha_Fin__c >=: Date.today() AND GUA_LKP_Profesional__c IN: profesionalAusenciaMap.keySet()];*/

			for(Guardia__c gua: guardiaList){
				for(ResourceAbsence ra: profesionalAusenciaMap.get(gua.GUA_LKP_Profesional__c)){
					if(gua.GUA_DAT_Fecha_Inicio__c <= ra.Start.date() && gua.GUA_DAT_Fecha_Fin__c >= ra.Start.date() 
						|| gua.GUA_DAT_Fecha_Inicio__c <= ra.End.date() && gua.GUA_DAT_Fecha_Fin__c >= ra.End.date()){
						ra.addError('El periodo seleccionado corresponde con una guardia, por favor contacte con su responsable para gestionar esta ausencia');
					}
				}
			}
		}
	}
}