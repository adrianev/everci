public class WCCTableFilterController {

	@AuraEnabled
	public static String getCases() {
		List<User> accountIdByUser = [SELECT Contact.AccountId from User where Id =: UserInfo.getUserId()];
		List<Case> cases = 
				[SELECT Id, CaseNumber FROM Case where AccountId =:accountIdByUser.get(0).Contact.AccountId];
		return JSON.serialize(cases);
	}
}