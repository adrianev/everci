public class AccountDetailController {
	@AuraEnabled
    public static Integer doCount(){
        return [Select id from Account].size();        
    }
    
    @AuraEnabled
    public static List<Account> doGetListAccount(){
        return [Select id, Name from Account];        
    }
    
    @AuraEnabled
    public static String doSave(Account acc){
        String result='KO';
        try{
            upsert acc;
            result='OK';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
             
        return result;
    }
}