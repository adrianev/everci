/**
 * Clase que se utiliza para evitar que salte en trigger cuando se ejecuta la clase Test.
 *
 * @author Everis
 */
public without sharing class Baipas {
	// Variable de control para bloquear/desbloquear todos los triggers:
	private static Boolean variableControl = false;
	// Tipos de objeto asociados a los triggers bloqueados:
	private static Set<SObjectType> objetosTriggerBloqueados = new Set<SObjectType>();

	/**
	 * Activa el bloqueo a la ejecución de los triggers.
	 *
	 * @return true si bloqueamos la ejecución de los triggers, false en caso contrario
	 */
	public static Boolean establecerVariableControl(){
		variableControl = true;
		return variableControl;
	}

	/**
	 * Informa si se pueden ejecutar los triggers.
	 *
	 * @return true si está activada la ejecución de los triggers, false en otro caso
	 */
	public static Boolean ejecutarTrigger(){
		return !variableControl;
	}

	/**
	 * Desactiva el bloqueo a la ejecución de los triggers.
	 *
	 * @return true si bloqueamos la ejecución de los triggers, false en caso contrario
	 */
	public static Boolean deshabilitarVariableControl(){
		variableControl = false;
		return variableControl;
	}

	/**
	 * Informa si el usuario se salta el trigger
	 *
	 * @return true si el usuario tiene a true el campo Saltar_Trigger__c de la configuración personalizada Baipas__c
	 */
	public static Boolean isMigrationUser(){
		//Si el usuario tiene en la configuración personalizada Baipas__c el check de Saltar_Trigger__c se salta el trigger
		Baipas__c baipas = Baipas__c.getInstance();		
		return baipas.Saltar_Trigger__c;
	}

	/**
	 * Bloquea el trigger del SObject especificado por parámetro.
	 */
	public static void bloquearTrigger(SObjectType objeto){
		objetosTriggerBloqueados.add(objeto);
	}

	/**
	 * Desbloquea el trigger del SObject especificado por parámetro.
	 */
	public static void desbloquearTrigger(SObjectType objeto){
		objetosTriggerBloqueados.remove(objeto);
	}

	/**
	 * Informa si el trigger del SObject especificado por parámetro está bloqueado o no.
	 *
	 * @return true si el trigger está bloqueado, false en caso contrario
	 */
	public static Boolean triggerBloqueado(SObjectType objeto){
		return objetosTriggerBloqueados.contains(objeto);
	}
}