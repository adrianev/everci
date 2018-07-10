trigger TRG_Contrato on Contract (after insert, before insert) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
        if(Trigger.isBefore){
            TRG_Handler_Contrato.tratamientoBeforeInsert(trigger.new, trigger.newMap);
        }else if(Trigger.isAfter){
	        TRG_Handler_Contrato.tratamientoAfterInsert(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
        }
	}
}