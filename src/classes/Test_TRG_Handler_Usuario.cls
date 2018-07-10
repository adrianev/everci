@isTest
public without sharing class Test_TRG_Handler_Usuario extends TestSetup{
    
	static testMethod void test_Handler_Usuario(){
		Id FSL_Mobile = [SELECT Id FROM Profile where Name = :Label.PERFIL_PROFESIONAL].Id;
		User usr = new User(LastName='Apellido',Alias='user',Email='fake@user.com',Username='fake@user.com.usr',CommunityNickname='user',ProfileId=FSL_Mobile,TimeZoneSidKey='Europe/Paris',LocaleSidKey='es_ES',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='es');
		insert usr;
	}

	static testMethod void test_Handler_Usuario2(){
		Id FSL_Mobile = [SELECT Id FROM Profile where Name = :Label.PERFIL_GESTOR_RECLAMACIONES].Id;
		User usr = new User(LastName='Apellido',Alias='user',Email='fake@user.com',Username='fake@user.com.usr',CommunityNickname='user',ProfileId=FSL_Mobile,TimeZoneSidKey='Europe/Paris',LocaleSidKey='es_ES',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='es');
		insert usr;
	}

	static testMethod void test_Handler_Usuario3(){
		Id FSL_Mobile = [SELECT Id FROM Profile where Name = :Label.PERFIL_ADMINISTRADOR].Id;
		User usr = new User(LastName='Apellido',Alias='user',Email='fake@user.com',Username='fake@user.com.usr',CommunityNickname='user',ProfileId=FSL_Mobile,TimeZoneSidKey='Europe/Paris',LocaleSidKey='es_ES',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='es');
		insert usr;
	}
}