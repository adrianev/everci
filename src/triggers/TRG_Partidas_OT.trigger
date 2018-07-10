trigger TRG_Partidas_OT on WorkOrderLineItem (before insert, before update, after insert, after update, before delete, after delete) {system.debug('pasamos por el trigger partidas_ot');
    system.debug('<<<<<<<<<sera TRG_Partidas_OT>>>>>>>>');
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
        system.debug('<<<<<<<<<sera TRG_Partidas_OT Baipas>>>>>>>>');
        if(Trigger.isBefore){
            system.debug('<<<<<<<<<sera isBefore>>>>>>>>');
            TRG_Handler_Partidas_OT.tratamientoBefore(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
        }//FIN (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert))
        if(Trigger.isAfter){
            system.debug('<<<<<<<<<sera after>>>>>>>>');
            TRG_Handler_Partidas_OT.tratamientoAfter(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
        }
    }
}//FIN TRG_Partidas_OT