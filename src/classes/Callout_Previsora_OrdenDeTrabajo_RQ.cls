/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_Previsora_OrdenDeTrabajo"
 *
 * @author EVERIS
 */
public without sharing class Callout_Previsora_OrdenDeTrabajo_RQ {
	public Integer CodigoAnulacionReparacion {get;set;}
	public Integer CodigoModificacion {get;set;}
	public Integer CodigoProfesion {get;set;}
	public String Comentarios {get;set;}
	public Integer EstadoReparacion {get;set;}
	public DateTime FechaHoraApertura {get;set;}
	public DateTime FechaHoraMovimiento {get;set;}
	public Integer IdPoliza {get;set;}
	public String IdReparacionReparalia {get;set;}
	public String NumReparacion {get;set;}
	public String NumSiniestroReparalia {get;set;}
	public Boolean ReparacionUrgente {get;set;}
	public String TipoMovimiento {get;set;}
	public String IdSecuencia {get;set;}

}