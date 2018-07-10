trigger TRG_Documentos_Profesionales_Contrato on Documentos_Profesionales_Contrato__c (before insert, before update, after insert, after update, after delete) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		if (trigger.isBefore){
			TRG_Handler_Documentos_Profesionales.tratamientoBefore(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}//FIN TRIGGER BEFORE
		if (trigger.isAfter){
			TRG_Handler_Documentos_Profesionales.tratamientoAfter(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}		
	}
}