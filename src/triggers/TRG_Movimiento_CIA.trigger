trigger TRG_Movimiento_CIA on INT_Movimiento_CIA__c (before Insert, after Insert, before Update, after Update, before Delete) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
	    if(Trigger.isBefore){
	        TRG_Handler_Movimientos.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    }//FIN Trigger.isBefore
	    else if (Trigger.isAfter){
	        TRG_Handler_Movimientos.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	    } //FIN Trigger.isAfter
	}
} // FIN TRIGGER