/*
   Esta clase implementa un proceso batch que se realiza diariamente y notifica a usuarios de Clic Hogar que no hayan cambiado su contraseña al cabo de 3 días
    @author everis
 	@version 1.0
 */
global without sharing class Batch_Comprobar_Cambio_Contrasenya_CH implements Schedulable {
    
    
      global Integer dias; //Número de días tras la creación del caso tras los que se ha de enviar un mail
      global date fechaLimite ; //Auxiliar

    
       global Batch_Comprobar_Cambio_Contrasenya_CH() {
		  this.dias = 3; 
          date hoy = date.today();
          this.fechaLimite = hoy.addDays(-dias);
      }


	global void execute(SchedulableContext ctx) {

		//Conversión requerida para pasarle a la query una string con el formato yyy-MM-dd
		 DateTime dt = Datetime.newInstance(this.fechaLimite.year(),this.fechaLimite.month(),this.fechaLimite.day() );
		
		//Obtenemos todos los usuarios con cuenta de Clic Hogar cuya Fecha de creación es hace 3 días.
		List<Case> casos_a_comprobarContrasenya = Util_Caso.getCaseByCreatedDateUsrPassNotNull(this.fechaLimite).values();
		/*List<Case> casos_a_comprobarContrasenya = [SELECT Id, ContactId, CAS_LKP_Compania__c,CAS_LKP_Procedencia__c,CreatedDate,CAS_TXT_Usuario_Clic_Hogar__c,CAS_NUM_Contador_Clic_Hogar__c,CAS_TXT_Password_Clic_Hogar__c,CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c FROM Case WHERE DAY_ONLY(CreatedDate) = :this.fechaLimite
		AND CAS_TXT_Usuario_Clic_Hogar__c != null AND CAS_TXT_Password_Clic_Hogar__c != null  ];*/
        
        system.debug(casos_a_comprobarContrasenya + ' Query probatura');
		
		OrgWideEmailAddress sourceEmail = Util_Correo_Electronico.getOWEmailAddressByAddress(new Set<String>{'homeservecrm@gmail.com'}).values().get(0);
		//OrgWideEmailAddress sourceEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'homeservecrm@gmail.com' LIMIT 1];
		
		List<Account> compania;
		List<Procedencia__c> proc;
		String nombre_emailTemplateRecordatorio;
	
	List<Messaging.SingleEmailMessage> lista_mensajes = new List<Messaging.SingleEmailMessage>(); //Lista de mensajes a enviar, ya montados
	
      for (Case c : casos_a_comprobarContrasenya) { //Para cada caso
      	
      	 compania = new List<Account>{Util_Cuentas.getMapCuentasById(new Set<Id>{c.CAS_LKP_Compania__c}).get(c.CAS_LKP_Compania__c)};
      	 //compania = [ SELECT CUE_TXT_Identificador__c,Id FROM Account WHERE Id=:c.CAS_LKP_Compania__c LIMIT 1];
      	 
      	 if(compania.size()==0) continue;

      	 proc = Util_Procedencia.queryProcedencia(new Set<Id>{c.CAS_LKP_Procedencia__c}).values();
		 //proc = [SELECT Name,Id FROM Procedencia__c WHERE Id=:c.CAS_LKP_Procedencia__c ];
		 if(compania.size()==0) continue;
      	
      	//Extraemos el template a utilizar
		if(compania[0].CUE_TXT_Identificador__c == Label.IDE_SEGURCAIXA){
			nombre_emailTemplateRecordatorio = 'Recordatorio_Contrasenya_Segurcaixa_ClicHogar';
		}
		else if(compania[0].CUE_TXT_Identificador__c == Label.IDE_NATIONALE_NETHERLANDEN){
			nombre_emailTemplateRecordatorio = 'Recordatorio_Contrasenya_Nationale_Netherlanden_ClicHogar';
		}
		else if(compania[0].CUE_TXT_Identificador__c == Label.IDE_PREVISORA_BILBAINA){
			nombre_emailTemplateRecordatorio = 'Recordatorio_Previsora_Clic_Hogar';
		}
		else if(compania[0].CUE_TXT_Identificador__c == Label.IDE_ALMUDENA){
			nombre_emailTemplateRecordatorio = 'Recordatorio_Almudena_Clic_Hogar' ;
		}
		
      	EmailTemplate et = Util_Correo_Electronico.getEmailTemplateByDevName(new Set<String>{nombre_emailTemplateRecordatorio}).values().get(0);
      	//EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:nombre_emailTemplateRecordatorio];
      
      		if( c.CAS_TXT_Password_Clic_Hogar__c == c.Id ){ //Si la contraseña es el Id del caso es que no ha cambiado la contraseña --> Notificamos
      			
      			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); //
      			
      			String correoI = c.CAS_LKP_PolizaContrato__r.Account.CUE_EMA_Email__c;


				mail.setOrgWideEmailAddressId(sourceEmail.Id);
				mail.setTemplateId(et.Id);//Id de la Template asociada
				mail.setSaveAsActivity(false);
                system.debug(c + ' Id del contacto ');
				
				mail.setTargetObjectId(c.ContactId);//Id del contacto o usuario destinatario
				mail.setWhatId(c.Id);  //Id del sObject del que se extraen los campos dinámicos
				
				mail.setToAddresses(new list<String>{correoI});
      			
			    mail.setSaveAsActivity(false);
			    mail.setUseSignature(false);
				
				lista_mensajes.add(mail);		
						
      		}
			
	
		}
		
		try { //Enviamos los mensajes
				    Messaging.sendEmail(lista_mensajes,false);
				    return;
		} catch (Exception e) {
				    System.debug(e.getMessage());
		}
	      			
		
		

    }
    
    
	}