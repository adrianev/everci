trigger TRG_Ausencia on ResourceAbsence (before insert, before update) {
    if(!Baipas.triggerBloqueado(ResourceAbsence.SObjectType) && Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		TRG_Handler_Ausencia.comprobarGuardia(Trigger.new);
    }
}