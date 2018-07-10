trigger TRG_Recurso_Asignado on AssignedResource (before insert, before update, after insert) {
	if(Trigger.isBefore){ 
        TRG_Handler_Recurso_Asignado.tratamientoBefore(Trigger.newMap, Trigger.new);
    }
    if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		TRG_Handler_Recurso_Asignado.actualizarCitaServicioAsignacionDirecta(Trigger.new);
    }
}