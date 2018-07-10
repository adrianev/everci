/*
* Clase que encapsula los datos a introducir en la request para la clase "Callout_RGAPratusAsistenciaApertura"
*
* @author EVERIS
*/
public without sharing class Callout_RGAPratusAsistenciaApertura_RQ {
	
	/*public without sharing class Garantias{
		public Integer Codigo {get;set;}
		public Double ImporteBaseServicio {get;set;}
		public Integer PorcentajeIvaAplicadoServicio {get;set;}
	}	*/
	//public List<Garantias> listaGarantias {get;set;}
	public Integer refSiniestroAsis {get;set;}
	public String fechaRegistroAsis {get;set;}
	public String horaRegistroAsis {get;set;}
	public Integer tipoAccion {get;set;}
	public String fechaAccion {get;set;}
	public String nombreReparador {get;set;}
	public String textoObservaciones {get;set;}
	public Integer origenObservacion {get;set;}
	public Integer codigoSeguimientoAsis {get;set;}
	public Integer identificadorPerito {get;set;}
	public Integer codigoMotivoRechazo {get;set;}
	public String indicadorGestora {get;set;}
	public Integer causanteAveria {get;set;}
	public String codigoOperadoraAsis {get;set;}
	public Integer codigoCausaAsis {get;set;}
	public String descrCausaAsis {get;set;}
	public String indicadorPerjudicado {get;set;}
	public String nombrePerjudicado {get;set;}
	public String telefonoPerjudicado {get;set;}
	public String telefonoAsegurado {get;set;}
}