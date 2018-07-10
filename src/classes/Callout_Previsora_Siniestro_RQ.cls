/*
* Clase que encapsula los datos a introducir en la request para la clase "Callout_Previsora_Siniestro"
*
* @author EVERIS
*/
public without sharing class Callout_Previsora_Siniestro_RQ {
	
	public without sharing class Garantias{
		public Integer Codigo {get;set;}
		public Double ImporteBaseServicio {get;set;}
		public Integer PorcentajeIvaAplicadoServicio {get;set;}
	}	
	public List<Garantias> listaGarantias {get;set;}
	public String Descripcion {get;set;}
	public String IdSecuencia {get;set;}
	public String Apellido1Perjudicado {get;set;}
	public String Apellido1 {get;set;}
	public String Apellido2Perjudicado {get;set;}
	public String Apellido2 {get;set;}
	public Integer Calificacion {get;set;}
	public Integer CodigoCausa {get;set;}
	public Integer CodigoGrupo {get;set;}
	public Integer CodigoModificacion {get;set;}
	public Integer CodigoPerjudicado {get;set;}
	public Integer CodigoReapertura {get;set;}
	public Integer CodigoRechazo {get;set;}
	public Integer CodigoResponsable {get;set;}
	public String ComentarioStrosIndemnizable {get;set;}
	public String ComentarioStrosReparable {get;set;}
	public String CompaniaTercero {get;set;}
	public String DNIPerjudicado {get;set;}
	public String DNITercero {get;set;}
	public String DireccionPerjudicado {get;set;}
	public DateTime FechaHoraMovimiento {get;set;}
	public Date FechaOcurrencia {get;set;}
	public Integer IdPoliza {get;set;}
	public String IdSiniestroReparalia {get;set;}
	public Double ImporteReserva {get;set;}
	public String NombrePerjudicado {get;set;}
	public String NombreTercero {get;set;}
	public String NumSiniestroReparalia {get;set;}
	public Integer Perjudicado {get;set;}
	public String PolizaTercero {get;set;}
	public Integer ResponsableDelSiniestro {get;set;}
	public String Telefono1Asegurado {get;set;}
	public String Telefono1AseguradoHoraDesde {get;set;}
	public String Telefono1AseguradoHoraHasta {get;set;}
	public Integer Telefono1AseguradoTipoTelefono {get;set;}
	public String TelefonoPerjudicado {get;set;}
	public String TelefonoTercero {get;set;}
	public Integer TipoMovimiento {get;set;}
	public Integer CodGarantia {get;set;}
}