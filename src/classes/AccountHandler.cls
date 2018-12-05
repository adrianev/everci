public class AccountHandler{

    public static Account insertNewAccount(String name ){
        try{
            Account acct = new Account(Name = name);
            insert acct;
            Account[] queriedAccounts = [SELECT Name FROM Account WHERE Name='aaa'];
            System.debug(queriedAccounts);
            return acct;
        }catch(Dmlexception e){
            System.debug('An error has occurred '+ e.getMessage());
            return null;
        }
    }

}