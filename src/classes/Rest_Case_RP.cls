/**
* Clase que es la respuesta para cuando se quiere devolver el listado de un caso
* Utilizado en la clase: 'Rest_ConsultaConsultaCaso'
*
* @author EVERIS
* 
*/

global without sharing class Rest_Case_RP {
	public String caseNumber{get;set;}
	public String IdCaso{get;set;}
	public String CAS_TXT_Num_Caso_CIA{get;set;}
	public String CAS_TXT_Num_Caso_HS{get;set;}
	public String RecordType{get;set;}
	public String CAS_TXT_Direccion{get;set;}
	public String CAS_TXT_DirRiesgo_CP{get;set;}
	public String Name{get;set;}
	public String CAS_SEL_DirRiesgo_Estado_Provincia{get;set;}
	public String provinciaLiteral{get;set;}
	public String Type{get;set;}
	public String tipoLiteral{get;set;}
	public DateTime CreatedDate{get;set;}
	public String Status{get;set;}
	public String estadoLiteral{get;set;}
	public DateTime ClosedDate{get;set;}
	public String POL_TXT_Id_Version_Poliza{get;set;}
	public Double CAS_DIV_Importe_Total{get;set;}
	public String Parent{get;set;}
	public List<Rest_WorkOrder_RP> listadoOrdenesTrabajo{get;set;}
	public List<Rest_Presupuesto_RP> listadoPresupuesto{get;set;}
}