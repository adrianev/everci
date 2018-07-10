trigger TRG_Recurso_Servicio on ServiceResource (before Insert, after Insert, before Update, after Update) {
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()){
        if(Trigger.isBefore){ 
            //TRG_Handler_Recurso_Servicio.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
            TRG_Handler_Recurso_Servicio.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
        }//FIN Trigger.isBefore
        else if (Trigger.isAfter){
            //TRG_Handler_Recurso_Servicio.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
            TRG_Handler_Recurso_Servicio.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
        } //FIN Trigger.isAfter
    }
} // FIN TRIGGER