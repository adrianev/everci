/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_Previsora_Facturas"
 *
 * @author EVERIS
 */
public without sharing class Callout_Previsora_Facturas_RQ {

	public without sharing class Garantia{
		public Integer codGarantia {get;set;}
		public Integer importeBaseServicio {get;set;}
		public Integer porcenIvaAplicadoServicio {get;set;}
	}

	public List<Garantia> listaGarantias {get;set;}

	public Integer estadoSiniestro {get;set;}
	public Date fechaFacturaServicio {get;set;}
	public Integer idFacturaReparalia {get;set;}
	public Integer idPoliza {get;set;}
	public String numFacturaServicio {get;set;}
	public Integer numReparacion {get;set;}
	public Integer numSiniestroReparalia {get;set;}
	public String idSecuencia {get;set;}
	public Integer TotalServiciosSinIva {get;set;}
	public Integer TotalServiciosConIva {get;set;}
	public DateTime FechaHoraMovimiento {get;set;}

	/*
	public String Codigo {get;set;}
	public String Descripcion {get;set;}
	public String Secuencia {get;set;}
	public String IdSecuencia {get;set;}
	public Integer IdFacturaReparalia {get;set;}
	public Integer idPoliza {get;set;}
	public Integer NumFacturaServicio {get;set;}
	public String NumReparacion {get;set;}
	public Integer NumSiniestroReparalia {get;set;}
	public Integer CodGarantia {get;set;}
	public Integer ImporteBaseServicio {get;set;}
	public Integer PorcenIvaAplicadoServicio {get;set;}
	 */
}