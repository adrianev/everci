/**
* Clase que es la respuesta para la clase 'Rest_ConsultaReclamacionMembership'
* @author everis
* @version 1.0
*/

global without sharing class Rest_ConsultaReclamacionMembership_RP {
	public String code{get;set;}
	public String message{get;set;}
	public List<Rest_CaseReclamacion_RP> listadoCaso{get;set;}
}