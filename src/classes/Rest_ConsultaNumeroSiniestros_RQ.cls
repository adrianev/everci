/**
* Clase que es la request del servicio "Rest_ConsultaNumeroSiniestros"
*
* @author EVERIS
* 
*/
global without sharing class Rest_ConsultaNumeroSiniestros_RQ {
	
	public String identificadorCompania{get;set;}
	public Date fechaInicio{get;set;}
	public Date fechaFin{get;set;}
	public String codigoConsulta{get;set;}
	
}