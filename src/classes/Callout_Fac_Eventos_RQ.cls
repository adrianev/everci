/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_Fac_Eventos"
 *
 * @author EVERIS
 */
public without sharing class Callout_Fac_Eventos_RQ {
	public class listadoProf {
		public String identificadorUnicoProfesional {get;set;}
		public String importeEvento {get;set;}
	}   

	public String origenDatos {get;set;}
	public String identificadorUnicoEvento {get;set;}
	public String identificadorUnicoAbono {get;set;}
	public String unidadNegocio {get;set;}
	public String lineaDeNegocio  {get;set;}
	public String identificadorUnicoCaso {get;set;}
	public String identificadorUnicoOrdenTrabajo  {get;set;}
	public String numOrdenTrabajo {get;set;}
	public String lineaOrdenTrabajo {get;set;}
	public String descripcion {get;set;}
	public String moneda {get;set;}
	public String direccionTerritorial {get;set;}
	public String tipoIntervencion {get;set;}
	public String grupoCausa {get;set;}
	public String tipoRegistroCaso {get;set;}
	public String facturaAbonar {get;set;}
	public String impuesto {get;set;}
	public String retencion {get;set;}
	public String id_DireccionCliente {get;set;}
	public String identificadorUnicoProfesional {get;set;}
	public String importe {get;set;}
	public String identificadorUnicoCuenta {get;set;}
	public String tipoEvento {get;set;}
}