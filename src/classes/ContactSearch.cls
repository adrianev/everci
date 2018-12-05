public class ContactSearch{
    public static Contact[] searchForContacts(String lastname, String mailingcode){
         System.debug('Test  AXAc vcvvvda:');
        Contact[] matched =[SELECT Id,Name FROM Contact WHERE LastName= :lastname AND MailingPostalCode = :mailingcode ];
        return matched;
    }
}