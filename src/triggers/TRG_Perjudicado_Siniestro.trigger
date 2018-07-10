trigger TRG_Perjudicado_Siniestro on Perjudicado_Siniestro__c (before insert, after insert, before update, after update, before delete, after delete) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
	    if(Trigger.isBefore){
	        TRG_Handler_Perjudicado_Siniestro.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    }
	    if(Trigger.isAfter){
	        TRG_Handler_Perjudicado_Siniestro.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    }
	}
}