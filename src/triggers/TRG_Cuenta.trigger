trigger TRG_Cuenta on Account (before insert, before update, before delete, after insert, after update) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		if(Trigger.isBefore){
			TRG_Handler_Cuenta.tratamientoBefore(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}//FIN TRIGGER BEFORE
		if (trigger.isAfter){
			TRG_Handler_Cuenta.tratamientoAfter(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
			TRG_Handler_Cuenta.actualizarCheckRobinson(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}
	}
}//FIN TRIGGER CUENTA