trigger TRG_Miembro_Territorio_De_Servicio on ServiceTerritoryMember (before insert, before update) {
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            TRG_Handler_Miembro_Territorio_Servicio.tratamientoBefore(trigger.new, Trigger.oldmap, Trigger.isInsert);
        }
    }
}