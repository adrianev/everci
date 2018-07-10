public class InsertFutureUser {
    @future
    public static void insertUser(String sContactId) {
        User futureUser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'HomeServe Customer Community Plus Login'].Id,
                          LastName = 'last',
                          Email = 'puser000@amamama.com',
                          Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                          CompanyName = 'CompanyTest',
                          Title = 'title',
                          Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US',
                          //UserRoleId = [SELECT Id FROM UserRole where PortalType = 'CustomerPortal' and PortalRole = 'Manager' LIMIT 1].Id,
                          //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'HomeServe Cliente Usuario' LIMIT 1].Id,
                          ContactId = sContactId);
        if(!Test.isRunningTest()){
            insert(futureUser);
        }
    }
}