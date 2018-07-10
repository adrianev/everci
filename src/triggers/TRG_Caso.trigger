trigger TRG_Caso on Case (before Insert, before Delete, after Insert, before Update, after Update){
	system.debug('<<<<<<<<<<<<<<sera Baipas.ejecutarTrigger()' + Baipas.ejecutarTrigger());
	// Sustituir temporalmente Baipas.ejecutarTrigger() por: (Baipas.triggerActivado(Case.SObjectType) || Baipas.ejecutarTrigger())
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
	    if(Trigger.isBefore){
	    	if(Trigger.isDelete){
		    	TRG_Handler_Caso_Refact.tratamientoBeforeDelete(Trigger.old);    		
	    	}
	    	else {
                system.debug(Trigger.oldMap +' Trigger.oldMap');
		    	TRG_Handler_Caso_Refact.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    	}
	    	
	    }//FIN Trigger.isBefore
	    else if(Trigger.isAfter){

	    	if(!Trigger.isDelete){
    			TRG_Handler_Caso_Refact.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    	}   
    			 
	    } //FIN Trigger.isAfter
		
	}
	SYstem.debug('Fin trigger Caso: '+Trigger.new);
} // FIN TRIGGER