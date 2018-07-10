/**
* Clase de respuesta del servicio "Rest_validarCodigoAsistencia"
* 
* @author everis
* @version 1.0
*/
global without sharing class Rest_validarCodigoAsistencia_RP {
	public String code{get;set;}
	public String message{get;set;}
	public String codigoCita{get;set;}
	public String PAR_TXT_Baremo_Desc{get;set;}
	public String identificadorUnicoOrden{get;set;}
	public String identificadorCuentaPadre{get;set;}
	public List<Rest_Franja_RP> listadoFranjas{get;set;}
}