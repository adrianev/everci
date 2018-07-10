/**
 * Clase de Test de la Clase Callout_ActualizaTelefono
 *
 */
@isTest 
public without sharing class Test_Callout_ActualizaTelefono {
	private static Account cuentaDeMembership {get;set;}
	private static Account membership {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract polizaMembership {get; set;}
	private static Contact newContacto {get;set;}
	
	@isTest public static void testOK(){
		test.startTest();
			
			Baipas.establecerVariableControl();
			//CREAMOS MEMBERSHIP
			membership = Util_Tests.crearCuentaCompania('Membership','1999','X1234567X');
			membership.BillingCity = 'Pozuelo de Alarcón';
			membership.BillingCountry = 'España';
			membership.BillingPostalCode = '28224';
			membership.BillingState = 'Madrid' ;
			membership.BillingStreet = 'Camino del Cerro de los Gamos 1';
			membership.CUE_TXT_Identificador__c = '1999';
			membership.Name = 'Membership' ;
			membership.RecordTypeId = '0129E0000004pciQAA';
			insert membership ;
			
			system.debug('1.COMPANIA MEMBERSHIP INSERTADA: '+membership);
			
			cuentaDeMembership =  Util_Tests.crearCuentaAsegurado('ClienteMembership', '132456', 'prueba@prueba.es', '12345678Z','María', 'García', 'Montes');
			cuentaDeMembership.CUE_CAS_Robinson__c = false;
			cuentaDeMembership.CUE_LKP_Cuenta_principal__c=membership.Id;
			insert cuentaDeMembership;
			
			system.debug('2.CUENTA DE MEMBERSHIP INSERTADA: '+cuentaDeMembership);
			
			tipoProductoCIA = Util_Tests.crearTipoProductoCIA('MEMBERSHIP - Hogar','01',membership.ID);
			insert tipoProductoCIA;
			
			system.debug('3.tipoProductoCIA INSERTADO: '+tipoProductoCIA);
			
			productoCIA = Util_Tests.crearProductoCIA('MEMBERSHIP - MEMBERSHIP SINIESTROS','01',tipoProductoCIA.Id);
			insert productoCIA;
			system.debug('3.productoCIA INSERTADO: '+tipoProductoCIA);
			
			polizaMembership = Util_tests.crearPolizaContrato('10', membership.id, cuentaDeMembership.id, productoCIA.id);
			polizaMembership.POL_TXT_Cliente_Ensura__c = '26983233';
			upsert polizaMembership;
			
			system.debug('3.POLIZA MEMBERSHIP INSERTADA: '+polizaMembership);
			
			//AÑADIMOS UN CONTACTO ASOCIADO A LA CUENTA DE MEMBERSHIP CREADA ANTERIORMENTE
			Baipas.deshabilitarVariableControl();
			newContacto = Util_Tests.crearContacto('Prueba','PruebaActualizaEmail_Contact');
			newContacto.AccountId  = cuentaDeMembership.Id ; //Una cuenta existente (la que acabamos de crear)
			newContacto.LastName = 'Prueba';
			newContacto.MobilePhone = '619675187';
			newContacto.Phone = '969320106';
			newContacto.HomePhone = '969320109';
			//newContacto.OwnerId = '0059E0000037kx1QAA'; //Será el id de un user que queramos
			insert newContacto ;
			
			system.debug('4.CONTACTO ASOCIADO  CREADO: '+newContacto);
			
			//ACTUALIZAMOS EL MISMO CONTACTO
			newContacto.MobilePhone = '619675188';
			newContacto.Phone = '969320107';
			newContacto.HomePhone = '969320108';
			update newContacto ;
			
			system.debug('5.ACTUALIZAR 1:  '+newContacto);
			newContacto.MobilePhone = '619675166';
			newContacto.Phone = '969320111';
			newContacto.HomePhone = '969320133';
			update newContacto ;
			
			newContacto.MobilePhone = '619675266';
			newContacto.Phone = '969320311';
			newContacto.HomePhone = '969340133';
			update newContacto ;
			
			newContacto.MobilePhone = '619075266';
			newContacto.Phone = '969120311';
			newContacto.HomePhone = '919340133';
			update newContacto ;
			
		
			test.stopTest();
	}
}