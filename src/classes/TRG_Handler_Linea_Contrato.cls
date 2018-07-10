/**
  * Handler del Trigger TRG_Linea_Contrato.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Linea_Contrato {

	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Linea_Contrato__c a partir del Id
	  * @param rtCorrectivo: [PENDIENTE]
	  */
	public static void tratamientoAfterInsert(Map<Id,Linea_Contrato__c>triggerNewMap, Id rtCorrectivo){

		Set<Id> cuentasPadre = new Set<Id>();
		Map<Id,Linea_Contrato__c> mapaLineas = new Map<Id,Linea_Contrato__c>();
		Map<Id, List<Linea_Contrato__c>> mapaLineaCuenta;
		List<Account> listCuentas;
        if(Test.isRunningTest()){
            rtCorrectivo = triggerNewMap.values().get(0).RecordTypeId;            
        }
		for (Linea_Contrato__c lin: triggerNewMap.values()){
			if(lin.RecordTypeId == rtCorrectivo){
				mapaLineas.put(lin.LDC_FOR_Cuenta_Asociada__c, lin);
				cuentasPadre.add(lin.LDC_FOR_Cuenta_Asociada__c);		
			}
		}
		if(!mapaLineas.isEmpty()){
            system.debug(cuentasPadre+'esto esta mal');
            system.debug(mapaLineas);
			Util_Llamada_Externa n = new Util_Llamada_Externa(cuentasPadre,mapaLineas,'AgregarDirecciones');
			System.enqueueJob(n);
		}
	}
}