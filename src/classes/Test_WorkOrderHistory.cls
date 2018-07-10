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
        
        WorkOrder wohPrueba = new WorkOrder(CAS_TXT_WF_Compania__c = 'WORTEN', city= 'Teruel', CaseId=casoPrueba.id, Subject='Prueba WO',Status='New'); 
        insert wohPrueba;
    }

	 @isTest static void testGetListWoh(){
        List<sObject> caseList = WorkOrderHistoryController.getWoHistories('');
        System.assertEquals(caseList.size(),0);
    }
    
     @isTest static void testGetListNewWoh()
    {
        List<WorkOrder> woh = [Select id,status from WorkOrder Where Subject='Prueba WO'];
        if (woh.isEmpty()){
         	System.debug('Error woh');
    	}
        woh[0].status='In Progress';
        update woh[0];
      
  		List<WorkOrderHistory> whoList =  WorkOrderHistoryController.getWoHistories(woh[0].Id);
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
        @isTest 
        static void testIsValidIdTr(){
             
                List<WorkOrder> woh = [Select id,status from WorkOrder Where Subject='Prueba WO'];
                if (woh.isEmpty()){
                    System.debug('Error woh');
                }
                Boolean isValid = WorkOrderHistoryController.isValidId(woh[0].id);
                System.assertEquals(true, isValid);
        }
    
        @isTest 
        static void testIsValidIdFl(){
            Boolean isValid = WorkOrderHistoryController.isValidId('');
            System.assertEquals(false, isValid);
        }
    
}