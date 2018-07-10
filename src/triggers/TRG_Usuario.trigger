trigger TRG_Usuario on User (after Insert, after Update) {
    if(!Baipas.isMigrationUser()){
        if(Trigger.isAfter && Trigger.isInsert){
            TRG_Handler_Usuario.tratamientoAfterInsert(Trigger.new);
        }//FIN Trigger.isAfter && Trigger.isInsert
        if(Trigger.isAfter && Trigger.isUpdate){
            TRG_Handler_Usuario.tratamientoAfterUpdate(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
        }//FIN Trigger.isAfter && Trigger.isInsert
    }
}