/**
* Clase que es la respuesta cuando se quieren devolver un listado de presupuestos
* Utilizado en la clase: "Rest_ConsultaCaso"
* @author EVERIS
* 
*/
global without sharing class Rest_Presupuesto_RP {
	public String IdPresupuesto{get;set;}
	public String Name{get;set;}
	public String PRE_SEL_Estado{get;set;}
}