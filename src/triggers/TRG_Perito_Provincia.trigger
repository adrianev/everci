trigger TRG_Perito_Provincia on Perito_Provincia__c (before insert, after insert, before update, after update) {
	if (trigger.isAfter){
			TRG_Handler_Perito_Provincia.tratamientoAfter(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}
}