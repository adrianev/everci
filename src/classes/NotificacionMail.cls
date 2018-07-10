/*
 * NotificacionMail
 * Notificación en mail de apertura de servicio B2B
 * 10/01/2018
 * @author everis
 *
 */
global without sharing class NotificacionMail{

	public static void filtroNotificaciones(List<sObject> objetoCoc, String IdCaso, String IdCia, ContentVersion cv){
		//Se comprueba que el objeto sea un caso o una lista de contactos
		String objetoTipo = objetoCoc.getSObjectType().getDescribe().getName()+'';
		
		if (objetoTipo == 'Case') {
			List<Case> caso = new List<Case>();
			caso = (List<Case>)objetoCoc;
			
			system.debug('----SVV. Es de tipo Caso----');
			if(!String.isEmpty(caso.get(0).CAS_EMA_Solicitud_Email__c)){
				String apellidos = caso.get(0).CAS_TXT_Apellidos__c;
				if (caso.get(0).CAS_TXT_Apellidos_2__c != null){
					apellidos+= ' ' + caso.get(0).CAS_TXT_Apellidos_2__c;
				}
				Contact con = Util_Correo_Electronico.generarDummyContact(caso.get(0).CAS_TXT_Nombre__c, apellidos, caso.get(0).CAS_EMA_Solicitud_Email__c, caso.get(0).CAS_TFN_Solicitud_Telefono__c, caso.get(0).CAS_TFN_Telefono_1__c);
				String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
				String casoSerializado = JSON.serialize(caso.get(0));
				Util_Correo_Electronico.enviarSingleEmailMessage(casoSerializado, Label.CON_TIPO_PROGRAMA_COMPROBANTE_SERVICIO, null, con, correoRemitente, cv, null, null);
			}
		}
		else if (objetoTipo == 'Contact'){
			List<Contact> listaContactos = (List<Contact>)objetoCoc;
			String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
			system.debug('---- Lista contactos: ' + listaContactos);
			Util_Correo_Electronico.envioMasivoTemplate(IdCaso, IdCia, Label.CON_TIPO_PROGRAMA_COMPROBANTE_SERVICIO, null, listaContactos, correoRemitente, cv, null, null);
		}
		else {
			system.debug('---- Error ----');
		}
	}
}