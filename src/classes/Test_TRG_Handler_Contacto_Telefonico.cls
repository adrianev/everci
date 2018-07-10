@isTest class Test_TRG_Handler_Contacto_Telefonico {
	@isTest static void main(){
        

      
        
        Contact co=new Contact();
        co.LastName='Perez';
        insert co;
        
        Contact co2=new Contact();
        co2.LastName='Perico';
        insert co2;
        

        /*TODO Util_Test.CrearPoliza
        ServiceContract poliza=new ServiceContract();
        poliza.Name='Paco';
        poliza.POL_TXT_Id_Version_Poliza__c='81629344';
        insert poliza;
        
        ServiceContract poliza2=new ServiceContract();
        poliza2.Name='Paquito';
        poliza2.POL_TXT_Id_Version_Poliza__c='816293444';
        insert poliza2;

        Case parent=new Case();
        parent.Subject =' Joder Hermano';
       	
        insert parent;
        
        Case ca=new  Case();
        ca.ParentId=parent.Id;
        insert ca;
        list <Contacto_telefonico__c> ListaTelefono = new list<Contacto_telefonico__c>();
      

        
        Contacto_telefonico__c t=new Contacto_telefonico__c();
        t.CTF_LKP_Contacto__c=co2.Id;
        t.CTF_LKP_Poliza_Contrato__c=poliza2.Id;
        t.RecordTypeId = '0129E0000005B3FQAU';
        //t.CTF_LKP_Caso__c=ca.Id; 
        ListaTelefono.add(t);
        
        
        
        
       
        insert ListaTelefono;
     

        
        delete t;
        
        t.Id=null;
        insert t;
               Contacto_telefonico__c h = new Contacto_telefonico__c();
        			h.CTF_LKP_Contacto__c=co2.Id;
        			h.CTF_LKP_Caso__c = parent.Id;
        		
        insert h;
        
        t.CTF_TXT_Observaciones__c='Es un payo';
        t.CTF_TXT_Identificador__c=null;
        update t;
        update t;
        
             
        	
        
*/        
        
        
    }
    
    @isTest static void main2(){
        
        Contact co2=new Contact();
        co2.LastName='Perico';
        insert co2;
                
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1111111X');
        
		insert compania;
        
        /*TODO Util_Test.CrearPoliza
        ServiceContract poliza=new ServiceContract();
        poliza.Name='Paco';
        poliza.POL_TXT_Id_Version_Poliza__c='81629344';
        poliza.POL_LKP_Compania__r = compania;
        poliza.POL_LKP_Compania__c = compania.Id;
        insert poliza;
        
        ServiceContract poliza2=new ServiceContract();
        poliza2.Name='Paquito';
        poliza2.POL_TXT_Id_Version_Poliza__c='816293444';
        poliza2.POL_LKP_Compania__r = compania;
        poliza2.POL_LKP_Compania__c = compania.Id;
        insert poliza2;
    
    
    
        list <Contacto_telefonico__c> ListaTelefono = new list<Contacto_telefonico__c>();
        

        
        Contacto_telefonico__c t=new Contacto_telefonico__c();
        t.CTF_LKP_Contacto__c=co2.Id;
        t.CTF_LKP_Poliza_Contrato__c=poliza2.Id;
        t.RecordTypeId = '0129E0000005B3KQAU';
        //t.CTF_LKP_Caso__c=ca.Id; 
        ListaTelefono.add(t);
        
        
       
        insert ListaTelefono;
        Case Caso = new case();
        insert Caso;
        
        Map<Id, Contacto_telefonico__c> listaConTelVieja = new  Map<Id, Contacto_telefonico__c>();
        listaConTelvieja.put(t.Id, t);
 

        Map<Id, Contact> mapaContactos = new Map<Id, Contact>();
         mapaContactos.put(co2.Id, co2);

        
        Map<Id, ServiceContract> mapaPolizas = new Map<Id, ServiceContract>();
           mapaPolizas.put(poliza2.Id, poliza2);

        Map<Id, Case> mapaCasos = new Map<Id,Case>();
        mapaCasos.put(Caso.Id,Caso);

    
    
		TRG_Handler_Contacto_Telefonico.hayModificaciones(t,listaConTelVieja,mapaContactos,mapaPolizas,mapaCasos);   
    
*/
    
    }
    
    
    
    
    
    
}