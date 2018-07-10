trigger TRG_Contacto on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                TRG_Handler_Contacto.tratamientoBeforeInsert(trigger.new);
            }
            if (Trigger.isUpdate){
                TRG_Handler_Contacto.tratamientoBeforeUpdate(trigger.new, trigger.old);
            }
        }//FIN TRIGGER BEFORE 
        if (Trigger.isAfter){
            if(Trigger.isInsert){
                TRG_Handler_Contacto.tratamientoAfterInsert(trigger.new, null, trigger.isUpdate);
            }
            if (Trigger.isUpdate){
                TRG_Handler_Contacto.tratamientoAfterUpdate(trigger.new, Trigger.oldmap, trigger.isUpdate);
            }   
            if (Trigger.isDelete){
                TRG_Handler_Contacto.tratamientoAfterDelete(Trigger.oldmap);
            }
            if(Trigger.isInsert ||Trigger.isUpdate ){
            	TRG_Handler_Contacto.actualizarTelefono(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
            	TRG_Handler_Contacto.actualizarEmailTomadorEnsura(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
            }
        } 
    } else{
    	System.debug('Baipas.isMigrationUser() vale: '+Baipas.isMigrationUser());
    }  
}//FIN TRIGGER CONTACTO