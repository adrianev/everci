@isTest
public class EVRCI_APEXClassTest {
@testSetup static void setup(){
List<Contact> lContacts = new List<Contact>();
        
for (Integer i = 0; i < 20; i++ ){
            lContacts.add(new Contact(FirstName='First'+i, LastName='Last'+i, Title='Sr', Email='contact'+i+'@test.com'));
}
        
        insert lContacts;
    }
    
    @isTest static void listContact(){
        EVRCI_APEXClass eClass = new EVRCI_APEXClass();
        eClass.sortByLastName();
        System.assertEquals(10, eClass.getContacts().size()); 
        eClass.sortByFirstName();
        System.assertEquals(10, eClass.getContacts().size());
    }
}