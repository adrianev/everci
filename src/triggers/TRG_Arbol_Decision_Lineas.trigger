trigger TRG_Arbol_Decision_Lineas on Arbol_Decision_Lineas__c (before insert, before update) {
	if(!Baipas.triggerBloqueado(Arbol_Decision_Lineas__c.SObjectTYpe) && Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
        TRG_Handler_Arbol_Decision_Lineas.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
	}
}