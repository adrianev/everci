trigger TRG_Festivo on Festivos__c (before insert) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		TRG_Handler_Festivo.tratamientoBefore(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
	}
}