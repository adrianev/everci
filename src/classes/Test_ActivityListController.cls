@isTest
public class Test_ActivityListController {  
   
    @TestSetup
    static void setUp(){
      	ID UserId = UserInfo.getUserId();
		Id adminProfId = [Select id from Profile WHERE Name=:Label.PERFIL_ADMINISTRADOR].Id;
        User adminUser = new User();
        adminUser.FirstName = 'Admin';
        adminUser.LastName = 'testUser';
        adminUser.Email = 'AdmintestUserak@test.com';
        adminUser.Username = 'AdmintestUserak@test.com';
        adminUser.ProfileId = adminProfId;
        adminUser.IsActive = true;
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.Alias = adminUser.FirstName.substring(0,1) + adminUser.LastName.substring(0,4);
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.TimeZoneSidKey = 'GMT';        
        insert adminUser;
		
        
    	BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1]; 
       
        Account cuenta;
      	cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        cuenta.Type = Label.CUE_TIPO_CONTABLE;
        insert cuenta;
        
    	Case casoPrueba = new Case(BusinessHours=bh,CAS_LKP_Compania__c=cuenta.Id,CreatedById=UserId,OwnerId=adminUser.Id,CAS_TXT_Persona_que_llama__c='Guadavili');
        insert casoPrueba;
        System.debug(casoPrueba);
        
        
        Task taskPrueba = new Task(CreatedById=UserId, WhatId=casoPrueba.Id,TaskSubType='Call',Status='Completed',Priority='Normal',OwnerId=adminUser.Id);
        insert taskPrueba;
    }

	 @isTest static void testGetListActivities()
    {
        List<sObject> caseList = ActivityListController.getListActivities('','');
        System.assertEquals(caseList.size(),0);
    }
    
     @isTest static void testGetListNewTask()
    {
     
  		Case caso = [Select id from Case Where CAS_TXT_Persona_que_llama__c = 'Guadavili'];
  		System.debug(caso.Id);
  		List<Task> taskList = ActivityListController.getListTasks(caso.Id,'Call');
        
        System.assertEquals(taskList.size(),1); 
    }
     @isTest static void testGetException()
    {
        try{
            ActivityListController.getListTasks('31','13');
        }
        catch(Exception e)
        {
         	Boolean expectedExceptionThrown =  (e.getMessage().contains('My Error Message')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
     
    }
    
}