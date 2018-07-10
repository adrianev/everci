/**
 * Clase de Test de la Clase Baipas.
 *
 * @author Everis
 */
@isTest
public without sharing class Test_Baipas extends TestSetup {
	/**
	 * Método que testea la activación/desactivación de triggers del Baipas.
	 */
	@isTest static void testTriggers(){
		// Testear desactivación de todos los triggers:
		Test.startTest();
		Baipas.establecerVariableControl();
		System.assertEquals(Baipas.ejecutarTrigger(),false);
		// Testear activación de todos los triggers:
		Baipas.deshabilitarVariableControl();
		System.assertEquals(Baipas.ejecutarTrigger(),true);
		// Testear bloqueo del trigger de Cuenta solamente:
		Baipas.bloquearTrigger(Account.SObjectType);
		System.assertEquals(Baipas.triggerBloqueado(Account.SObjectType),true);
		// Testear desbloqueo del trigger de Cuenta solamente:
		Baipas.desbloquearTrigger(Account.SObjectType);
		System.assertEquals(Baipas.triggerBloqueado(Account.SObjectType),false);
		Test.stopTest();
	}

	/**
	 * Método que testea el método isMigrationUser.
	 */
	@isTest static void testUsuario(){
		// Testear que el método isMigrationUser solo devuelve true si el usuario tiene perfil de migración:
		Test.startTest();
		String perfil = Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name;
		if(perfil == Label.PERFIL_MIGRACION){
			System.assertEquals(Baipas.isMigrationUser(),true);
		}
		else{
			System.assertEquals(Baipas.isMigrationUser(),false);
		}
		Test.stopTest();
	}
}