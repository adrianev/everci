trigger TRG_Confirmacion on Confirmacion__c (before Insert, before Delete, after Insert, before Update, after Update){
 system.debug('<<<<<<<<<<<<<<sera Baipas.ejecutarTrigger()' + Baipas.ejecutarTrigger());
  // Sustituir temporalmente Baipas.ejecutarTrigger() por: (Baipas.triggerActivado(Case.SObjectType) || Baipas.ejecutarTrigger())
  if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
      if(Trigger.isBefore){
        if(!Trigger.isDelete){
          TRG_Handler_Confirmacion.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
        }
      }//FIN Trigger.isBefore
      else if(Trigger.isAfter){ 
        if(!Trigger.isDelete){
          TRG_Handler_Confirmacion.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
        }
      } //FIN Trigger.isAfter
  }
} // FIN TRIGGER