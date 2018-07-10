trigger TRG_Indemnizable_Documento on Indemnizable_Documento__c(before insert, before update){
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) { 
		TRG_Handler_Indemnizable_Documento.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
    }
}