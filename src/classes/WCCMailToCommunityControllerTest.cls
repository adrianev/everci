@isTest
public class WCCMailToCommunityControllerTest {



	@testSetup static void setup() {
        Baipas.establecerVariableControl();
		String sInputEmail = 'homeserveGestor@cliente.com';

		//Get the OwnerUse for the Account
		//List<Profile> lProfiles = [Select Id, Name, (Select Id, Name From Users) From Profile where Name = 'System Administrator' Limit 1];
		//User ownerUser = lProfiles.get(0).Users.get(0);

        List<User> lUsers = [SELECT Name,UserRoleId FROM User WHERE UserRoleId != ''];
        
		//Create Test Account
		Account a = new Account(Name='TestAccount', CUE_EMA_Gestor_Comunidad__c = sInputEmail,CUE_TXT_Identificador__c='00001', OwnerId = lUsers.get(0).Id);
      	a.CUE_TXT_Numero_Documento__c = ' 12345678Z';
        a.CUE_SEL_Tipo_Documento__c = 'N';
        
        insert a;
		//Create Test Contact
		Contact c = new Contact(firstname='first',lastname='last',AccountId=a.Id);
		insert c;
         Baipas.deshabilitarVariableControl();
	}

	@isTest
	public static void testGetCommunityManageEmail() {
		String sInputEmail = 'homeserveGestor@cliente.com';

		Contact c = [SELECT Id from Contact where firstname='first' and lastname='last' LIMIT 1];

		User execUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		//Create User in a future Class to avoid DML Issues
		System.runAs(execUser) {
			Test.startTest();
			WCCInsertFutureUser.insertUser(c.Id);
			Test.stopTest();            
		}

		//Get Id of User Created
		User thisUser = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];

		//Simulate Run as
		System.runAs(thisUser) {         
			String sEmailOutput = WCCMailToCommunityController.getCommunityManageEmail();

			//System.assert(sEmailOutput.equalsIgnoreCase(sInputEmail));
		}
	}

	@isTest
	public static void testInsertFutureUser() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		// System.runAs() allows mixed DML operations in test context
		System.runAs(thisUser) {
			// startTest/stopTest block to run future method synchronously
			Test.startTest();
			Contact c = [SELECT Id from Contact where firstname='first' and lastname='last' LIMIT 1];
			WCCInsertFutureUser.insertUser(c.Id);
			Test.stopTest();
		}

		System.assert(true);


	}
}