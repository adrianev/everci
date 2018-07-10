/**
  * Clase handler del trigger del Trigger TRG_Festivo.
  * 
  * @author EVERIS
  */
public without sharing class TRG_Handler_Festivo {
    
	public static void tratamientoBefore(Map<Id, Festivos__c> triggerNewMap, List<Festivos__c> triggerNew, 
			Map<Id, Festivos__c> triggerOldMap, List<Festivos__c> triggerOld){
				if(trigger.isInsert){
					
					for(Festivos__c festivo : triggerNew){
						if(festivo.FES_TXT_Identificador__c == null){
							Long timestamp = datetime.now().getTime();
							festivo.FES_TXT_Identificador__c = String.valueOf(timestamp);
						}
					}
				}
			}
	
}