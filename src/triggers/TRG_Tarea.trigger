trigger TRG_Tarea on Task (before insert, after insert, before update, after update) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		if(Trigger.isBefore){
			TRG_Handler_Tarea.tratamientoBefore(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}
		else{
			TRG_Handler_Tarea.tratamientoAfter(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}
	}
}