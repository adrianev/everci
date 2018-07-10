trigger TRG_Propuesta_de_Abono on Propuesta_de_Abono__c (after Insert, after Update) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		if (Trigger.isAfter){
	        TRG_Handler_Propuesta_de_Abono.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    } //FIN Trigger.isAfter
	}
} // FIN TRIGGER