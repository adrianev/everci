trigger TRG_Propuesta_de_Evento on Propuesta_de_Evento__c (before Insert, after Insert, before Update, after Update) {system.debug('pasamos por el trigger propuesta de evento');
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
	    if(Trigger.isBefore){
	    	system.debug('>>>>>>>>tratamientoBefore');
	        TRG_Handler_Propuesta_de_Evento.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	        system.debug('>>>>>>>>End tratamientoBefore');
	    }//FIN Trigger.isBefore
	    else if (Trigger.isAfter){
	    	system.debug('>>>>>verTrigger: '+Trigger.new);
	        TRG_Handler_Propuesta_de_Evento.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    } //FIN Trigger.isAfter
	}
} // FIN TRIGGER