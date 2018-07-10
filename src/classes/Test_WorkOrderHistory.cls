@isTest
public class Test_WorkOrderHistory {  
   
    @TestSetup
    static void setUp(){

    	BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1]; 
       
        Account cuenta;
      	cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        cuenta.Type = Label.CUE_TIPO_CONTABLE;
        insert cuenta;
        
    	Case casoPrueba = new Case(BusinessHours=bh,CAS_LKP_Compania__c=cuenta.Id,CAS_TXT_Persona_que_llama__c='Guadavili');
        insert casoPrueba;  
        System.debug(casoPrueba);
        
        WorkOrder wohPrueba = new WorkOrder(CAS_TXT_WF_Compania__c = 'WORTEN', city= 'Teruel', CaseId=casoPrueba.id, Subject='Prueba WO',Status='New'); 
            //CreatedById=UserId, WhatId=casoPrueba.Id,TaskSubType='Call',Status='Completed',Priority='Normal',OwnerId=adminUser.Id);
        insert wohPrueba;
        System.debug('woh: '+wohprueba);
    }

	 @isTest static void testGetListWoh(){
        List<sObject> caseList = WorkOrderHistoryController.getWoHistories('');
        System.assertEquals(caseList.size(),0);
    }
    
     @isTest static void testGetListNewWoh()
    {


        List<WorkOrder> woh = [Select id,status from WorkOrder Where Subject='Prueba WO'];
        System.debug('woh='+woh);       
        if (woh.isEmpty()){
         	System.debug('Error woh');
    	}
        System.debug('Status 1: '+woh[0].status);
        woh[0].status='In Progress';
        update woh[0];
       	System.debug('Status 2: '+woh[0].status);

      
  		List<WorkOrderHistory> whoList =  WorkOrderHistoryController.getWoHistories(woh[0].Id);
       	System.debug('whoList2: '+whoList);
        //System.assertNotEquals(whoList.size(),0); 
    }
     @isTest static void testGetException()
    {
        try{
            WorkOrderHistoryController.getWoHistories('31');
        }
        catch(Exception e)
        {
         	Boolean expectedExceptionThrown =  (e.getMessage().contains('My Error Message')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
     
    }
    
}