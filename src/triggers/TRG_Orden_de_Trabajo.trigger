trigger TRG_Orden_de_Trabajo on WorkOrder (after delete, after insert, after update, before delete, before insert, before update) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		if(Trigger.isBefore){
            System.debug(Trigger.old + 'Trigger.old');
            System.debug(Trigger.new + 'Trigger.new');
            System.debug(Trigger.oldMap + 'Trigger.oldMap');
			TRG_Handler_Orden_de_Trabajo.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
		}//FIN Trigger.isBefore

		else if(Trigger.isAfter){
            System.debug(Trigger.old + 'Trigger.old');
            System.debug(Trigger.new + 'Trigger.new');
            System.debug(Trigger.oldMap + 'Trigger.oldMap');
			TRG_Handler_Orden_de_Trabajo.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
		}//FIN Trigger.isAfter
	}
}//FIN TRG_Orden_de_Trabajo