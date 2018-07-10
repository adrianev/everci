/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_Previsora_FacturacionFee"
 *
 * @author EVERIS
 */
public without sharing class Callout_Previsora_FacturacionFee_RQ {
	public String FechaFacturaGestion {get;set;}
	public String IdFacturaFeeReparalia {get;set;}
	public Integer IdPoliza {get;set;}
	public Double Importe {get;set;}
	public Integer EstadoSiniestro {get;set;}
	public String NumFacturaGestion {get;set;}
	public String NumSiniestroReparalia {get;set;}
	public Double PorcentajeIVA {get;set;}
	public String IdSecuencia {get;set;}
	public Double TotalServiciosSinIva {get;set;}
	public Double TotalServiciosConIva {get;set;}
	public Datetime FechaHoraMovimiento {get;set;}
}