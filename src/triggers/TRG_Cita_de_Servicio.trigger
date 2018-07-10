trigger TRG_Cita_de_Servicio on ServiceAppointment (after insert, after update, before update, before insert, before delete) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		if(trigger.isBefore){
			TRG_Handler_Cita_de_Servicio.tratamientoBefore(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}
		else {
			TRG_Handler_Cita_de_Servicio.tratamientoAfter(trigger.newMap, trigger.new, trigger.oldMap, trigger.old);
		}
	}
}