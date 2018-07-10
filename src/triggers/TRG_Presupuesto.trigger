trigger TRG_Presupuesto on Presupuesto__c (before update, after insert, after update) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()){
		if (trigger.isBefore){
	        TRG_Handler_Presupuesto.tratamientoBefore(trigger.new,Trigger.OldMap);
	    } 
		else if(trigger.isAfter){
	        TRG_Handler_Presupuesto.tratamientoAfter(trigger.new,Trigger.OldMap);
	    } 
	}
}