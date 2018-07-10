public class WCCMailToCommunityController {

	@AuraEnabled
	public static String getCommunityManageEmail() {
		List<User> users = [SELECT Contact.Account.CUE_EMA_Gestor_Comunidad__c from User where Id =: UserInfo.getUserId()];

		String sEmail = null;
		if (users!=null && users.get(0)!=null && users.get(0).Contact!=null){
			sEmail = users.get(0).Contact.Account.CUE_EMA_Gestor_Comunidad__c;
		}

		return sEmail;
	}
}