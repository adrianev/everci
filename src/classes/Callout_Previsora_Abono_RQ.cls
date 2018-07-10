/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_Previsora_Abono"
 *
 * @author EVERIS
 */
public without sharing class Callout_Previsora_Abono_RQ {

	public without sharing class Garantias{
		public Integer Codigo {get;set;}
		public Double ImporteBaseServicio {get;set;}
		public Integer PorcentajeIvaAplicadoServicio {get;set;}
	}

	public String ConceptoPago {get;set;}
	public Datetime FechaAbono {get;set;}
	public Datetime FechaHoraMovimiento {get;set;}
	public String IdAbonoReparalia {get;set;}
	public Integer IdPoliza {get;set;}
	public List<Garantias> listaGarantias {get;set;}
	public String NumFactura {get;set;}
	public String NumReparacion {get;set;}
	public String NumSiniestroReparalia {get;set;}
	public String IdSecuencia {get;set;}
	public String TotalServiciosSinIva{get;set;}
	public String TotalServiciosConIva{get;set;}
}