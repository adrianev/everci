trigger TRG_Linea_Contrato on Linea_Contrato__c (after insert) {
	if(Baipas.ejecutarTrigger() && !Baipas.isMigrationUser()) {
		Id recordTypeCorrectivo = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_LIN_CON_CORRECTIVO);
		TRG_Handler_Linea_Contrato.tratamientoAfterInsert(trigger.newMap, recordTypeCorrectivo);
	}
}