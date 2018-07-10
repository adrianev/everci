/**
* Clase de respuesta para cuando se quiere devolver el listado de reclamaciones
* Utilizado en la clase: 'Rest_ConsultaReclamacionMembership'
*
* @author EVERIS
* 
*/

global without sharing class Rest_CaseReclamacion_RP {
	public String caseNumber{get;set;}
	public String Parent{get;set;}
	public String RecordType{get;set;}
	public DateTime CreatedDate{get;set;}
	public String Status{get;set;}
	public String estadoLiteral{get;set;}
	public String CAS_SEL_Naturaleza{get;set;}
	public String naturalezaLiteral{get;set;}
	public DateTime ClosedDate{get;set;}
	public String CAS_SEL_Comunicador_Recl{get;set;}
	public String CAS_TXT_Sondeo_Tipo_de_Carta{get;set;}
}