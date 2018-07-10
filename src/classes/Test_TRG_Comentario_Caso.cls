/**
 * Clase de Test de la Clase TRG_Comentario_Caso Comunidad
 * 
 */

@isTest
public without sharing class Test_TRG_Comentario_Caso {
	public enum PortalType { CustomerPortal, CSPLiteUser, PowerPartner, PowerCustomerSuccess, CustomerSuccess }

	@isTest 
	static void anadirComentarioCaso(){
		//Creamos el usuario con rol necesario para crear la compañia y la cuenta
		User userWithRole;

		if(userWithRole == null) {  
			if(UserInfo.getUserRoleId() == null) {
				UserRole r = new UserRole(name = 'TEST ROLE');
				Database.insert(r);
				userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
									emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
									localesidkey='en_US', profileid = UserInfo.getProfileId(),
									timezonesidkey='America/Los_Angeles',Username='userwithrole@roletest2.com', 
									CommunityNickname='userwithrole.test@roletest2' );
			} else {
				userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
			}
			System.assert(userWithRole.userRoleId != null,
						  'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
		}

		//Creamos el set de datos inicial 
		Account cuentaPrincipal;
		Contact contactoPrincipal;
		Case casoTest;

		System.runAs(userWithRole) {
			Account compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
			compania.Type='01';
			insert compania;

			cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1019', 'X1134567X');
			cuentaPrincipal.CUE_LKP_Cuenta_Principal__c = compania.id;
			cuentaPrincipal.Type='01';
			cuentaPrincipal.CUE_LKP_Cliente_contable__c=cuentaPrincipal.Id;
			insert cuentaPrincipal;
			
			contactoPrincipal = new Contact(AccountId = cuentaPrincipal.id, lastname = 'lastname');
			insert contactoPrincipal;

			Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
			insert tipoProductoCIA;
			Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
			insert productoCIA;
			ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuentaPrincipal.Id,productoCIA.Id);
			insert poliza;
			casoTest = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
			casoTest.Status = '993';
			insert casoTest;

			Test.startTest();
			CaseComment comentarioCaso =  new CaseComment();
			comentarioCaso.CommentBody = 'Comentario del caso' ;   
			comentarioCaso.ParentId = casoTest.Id;
			insert comentarioCaso;
			Test.stopTest();
			
			//Se ha creado una tarea al gestor
			//System.assertEquals([select id from Task where WhatId=:comentarioCaso.Id].size(), 1);
		}

	}   
}