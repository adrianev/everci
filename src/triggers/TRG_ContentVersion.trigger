trigger TRG_ContentVersion on ContentVersion (after insert){
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()){
		TRG_Handler_ContentVersion.obtenerFactura(trigger.new);
		TRG_Handler_ContentVersion.tratamientoAfter(trigger.new);
	}
}