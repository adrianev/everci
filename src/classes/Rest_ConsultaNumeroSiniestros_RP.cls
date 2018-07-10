/**
* Clase que es la respuesta del servicio "Rest_ConsultaNumeroSiniestros"
*
* @author EVERIS
* 
*/
global without sharing class Rest_ConsultaNumeroSiniestros_RP {
	
	public String code{get;set;}
	public String siniestrosDeclarados{get;set;}
	public String siniestrosHogar{get;set;}
	public String siniestrosMantenimiento{get;set;}
	public String siniestrosPremium{get;set;}
	public String siniestrosSegmentado{get;set;}
	public String message{get;set;}
	
}