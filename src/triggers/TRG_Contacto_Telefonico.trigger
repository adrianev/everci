trigger TRG_Contacto_Telefonico on Contacto_telefonico__c (before insert, after insert, before update, after update, before delete) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
	    if(Trigger.isBefore){
	        if(Trigger.isInsert){
	            TRG_Handler_CONTACTO_TELEFONICO.generarIdentificadorContactoTelefono(trigger.new,null, Trigger.isInsert);
	        }else if (Trigger.isUpdate){
	            TRG_Handler_CONTACTO_TELEFONICO.generarIdentificadorContactoTelefono(trigger.new, Trigger.oldmap, Trigger.isInsert);
	        } else if(Trigger.isDelete){
	            TRG_Handler_CONTACTO_TELEFONICO.tratamientoContactoTelefonicoBeforeDelete(trigger.old, trigger.oldMap);
	        }//FIN Trigger.isDelete
	    }//FIN Trigger.isBefore
	    if(Trigger.isAfter){
	        if(Trigger.isInsert){
	            TRG_Handler_CONTACTO_TELEFONICO.tratamientoContactoTelefonicoAfterInsert(trigger.new, trigger.newMap);
	        }//FIN Trigger.isInsert
	        if(Trigger.isUpdate){
	            TRG_Handler_CONTACTO_TELEFONICO.tratamientoContactoTelefonicoAfterUpdate(trigger.new,trigger.newMap,trigger.old,trigger.oldMap);
	        }//FIN Trigger.isUpdate
	    }//FIN Trigger.isAfter
	}
}//FIN TRG_CONTACTO_TELEFONICO