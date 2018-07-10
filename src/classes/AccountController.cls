public class AccountController {
	@AuraEnabled
    public static Integer doCount(Account account){
        return [Select id from Account].size();        
    }
}