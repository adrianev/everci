/*
	Esta clase de utilidad encapsula los mensajes de error asociados a un código, de forma que el programador no tenga que preocuparse de codificar el mensaje y el código en cada servicio expuesto.
	Se promueve con esto la reusabilidad y flexibilidad del código, puesto que cambiar un mensaje de error asociado a un código solo implica cambiarlo en el MetadataType

	@author everis
	@version 1.0
 */
public without sharing class Util_WS_Error {

	public static String devolverMensajeRespuesta(String codigoRespuesta){

		//Obtenemos el mensaje asociado al código de error que se le pasa a este método.
		Excepciones_Servicios__mdt Excepcion = Util_Metadatos.getExpServiciosByCodError(new Set<String>{codigoRespuesta}).values().get(0);
		//Construimos la string en formato JSON			 
		String respuesta = Excepcion.TXT_Descripcion_Error__c;
		return respuesta;
	}

	public static String devolverMensaje(String codigoMensaje){
		//Obtenemos el mensaje asociado al código de mensaje que se le pasa a este método.
		Excepciones_Servicios__mdt Excepcion = Util_Metadatos.getExpServiciosByCodError(new Set<String>{codigoMensaje}).values().get(0);
		//Construimos la string en formato JSON
		String respuesta = '"code":"'+Excepcion.TXT_Codigo_Error__c+'","message":"'+Excepcion.TXT_Descripcion_Error__c+'"'; 
		return respuesta;
	}
}