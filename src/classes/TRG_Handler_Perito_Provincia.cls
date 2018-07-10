/**
  * Handler del Trigger TRG_Perito_Provincia.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Perito_Provincia {
	
	public static void tratamientoAfter(Map<Id, Perito_Provincia__c> triggerNewMap, List<Perito_Provincia__c> triggerNew, 
			Map<Id, Perito_Provincia__c> triggerOldMap, List<Perito_Provincia__c> triggerOld){
		Set<Id> idCompanias = new Set<Id>();
		List<Perito_Provincia__c> peritosAct = new List<Perito_Provincia__c>();
		Set<String> idProvincias = new Set<String>();
		
		if(Trigger.isInsert) {
			for(Perito_Provincia__c per :triggerNew) {
				idCompanias.add(per.PERP_FOR_Compania__c);
				idProvincias.add(per.PERP_SEL_Provincia__c);
			}
			List<Perito_Provincia__c> listPeritos = Util_Perito.peritoByIdCompaniaAndProvincia(idCompanias, idProvincias).values();
			for(Perito_Provincia__c perAct :listPeritos) {
				perAct.PERP_NUM_Siniestros_Asignados__c = 0;
				peritosAct.add(perAct);
			}
			if(!peritosAct.isEmpty()) {
				update peritosAct;
			}
		}
		
	}
}