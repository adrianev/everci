/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_Previsora_Indemnizables"
 *
 * @author EVERIS
 */
public without sharing class Callout_Previsora_Indemnizables_RQ {

	public without sharing class Garantia{
		public Integer codGarantia {get;set;}
		public Integer importeBaseServicio {get;set;}
		public Integer porcenIvaAplicadoServicio {get;set;}
	}

	public List<Garantia> listaGarantias {get;set;}

	public String beneficiario {get;set;}
	public String codigoPostalBenef {get;set;}
	public String conceptoPago {get;set;}
	public String domicilioBenef {get;set;}
	public Integer estadoSiniestro {get;set;}
	public Integer fechaCierre {get;set;}
	public DateTime fechaHoraMovimiento {get;set;}
	public Date fechaRecepcionRepFacturaPerito {get;set;}
	public Integer idPagoIndemnizableReparalia {get;set;}
	public String idPoliza {get;set;}
	public Integer importeBaseGastosPerito  {get;set;}
	public Integer importeBaseHonorariosPerito  {get;set;}
	public String localidadBenef {get;set;}
	public String nifBenef {get;set;}
	public String nifPerito {get;set;}
	public String nombreApellidosBenef {get;set;}
	public String numFacturaPerito {get;set;}
	public String numPago {get;set;}
	public String numSiniestroPrevisora {get;set;}
	public String numSiniestroReparalia {get;set;}
	public Integer personaFisicaJuridicaBenef {get;set;}
	public Integer porcentajeIvaIgiPerito  {get;set;}
	public String telefonoFaxBenef {get;set;}
	public Integer tipoDocumentoBenef {get;set;}
	public Integer tipoImpuestoPerito {get;set;}
	public String tipoRegistro {get;set;}
	public String idSecuencia {get;set;}
}