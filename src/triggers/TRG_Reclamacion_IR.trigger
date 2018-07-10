trigger TRG_Reclamacion_IR on Case (after insert, before delete) {
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
        if(Trigger.isAfter){
            if(checkRecursive.runOnceIR()){
                TRG_Handler_MovimientoIR trg = new TRG_Handler_MovimientoIR(trigger.new, Label.MIR_Procedimiento);
                System.enqueueJob(trg);
            }
        }
        if(Trigger.isBefore){
            system.debug('trigger Delete');
            if(checkRecursive.runOnceIR()){
                TRG_Handler_MovimientoIR trg = new TRG_Handler_MovimientoIR(Trigger.oldMap, Label.MIR_Procedimiento);
                System.enqueueJob(trg);
            }
        }       
    } 
}