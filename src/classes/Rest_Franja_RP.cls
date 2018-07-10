/**
* Clase que es la respuesta para cuando se quiere devolver el listado de franjas disponibles
* Utilizado en las clases: 'Rest_B2BB2B2C_CreacionServicio', 'Rest_ObtenerFranjaHoraria', 'Rest_validarCodigoAsistencia' y 'Util_Booking'
* @author everis
* @version 1.0
*/

public without sharing class Rest_Franja_RP {
	public String fecha{get;set;}
	public String[] rango{get;set;}
}