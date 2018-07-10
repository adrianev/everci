trigger TRG_Comentario_Caso on Comentario_caso__c (after insert) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		TRG_Handler_Comentario_del_caso.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	}
}