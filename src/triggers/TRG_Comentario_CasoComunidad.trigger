trigger TRG_Comentario_CasoComunidad on CaseComment (before insert, after insert){
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()){
		if(trigger.isBefore){
			TRG_Handler_Comentario_CasoComunidad.tratamientoBefore(trigger.new);
		}
		else {
			TRG_Handler_Comentario_CasoComunidad.tratamientoAfter(trigger.new);			
		}
	}
}