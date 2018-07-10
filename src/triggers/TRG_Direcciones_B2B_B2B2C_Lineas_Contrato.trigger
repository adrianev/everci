trigger TRG_Direcciones_B2B_B2B2C_Lineas_Contrato on Direcciones_B2B_B2B2C_Lineas_de_Contrato__c (before insert, after insert, after delete) {
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
	    if (Trigger.isBefore && Trigger.isInsert) {
	        TRG_Handler_Direcciones_B2B_Lineas.tratamientoBeforeInsert(trigger.new);
	    }
	    else if (Trigger.isAfter && Trigger.isInsert) {
	        TRG_Handler_Direcciones_B2B_Lineas.tratamientoAfterInsert(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
	    }
	    else if (Trigger.isAfter && Trigger.isDelete) {
	    	TRG_Handler_Direcciones_B2B_Lineas.tratamientoAfterDelete(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
	    }
    }
}