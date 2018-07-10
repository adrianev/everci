/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_Fac_MaestroProfesionales"
 *
 * @author EVERIS
 */
public without sharing class Callout_Fac_MaestroProfesionales_RQ {

	public String origenDatos {get;set;}
	public String accionRealizada {get;set;}
	public String nombreProfesional {get;set;}
	public String identificadorUnicoProfesional {get;set;}
	public String numeroProfesional {get;set;}
	public String tipoDocumento {get;set;}
	public String tomadorNumeroDocumentoCliente {get;set;}
	public String nombreContacto {get;set;}
	public String mailContacto {get;set;}
	public Address direccionContacto {get;set;}
	public String telefonoContacto {get;set;}
	public String direccionDelProfesional {get;set;}
	public String codigoPostalProfesional {get;set;}
	public String ciudadProfesional {get;set;}
	public String paisProfesional {get;set;}
	public Double importeFianzaMaxima {get;set;}
	public String condicionPago {get;set;}
	public String codigoRetencionFiscal {get;set;}
	public Boolean profesionaFianza {get;set;}
	public Double porcentajeFianza {get;set;}
	public Double importeTotalFianza {get;set;}
	public Decimal importeFianzadevuelta {get;set;}
	public DateTime fechaBajaDefinitiva {get;set;}
	public Boolean profesionalFranquicia {get;set;}
	public Double importeFranquicia {get;set;}
	public String fechaFranquicia {get;set;}
	public Double vencimientosFranquicia {get;set;}
	public String tipoProfesional {get;set;}
	public String metodoPago {get; set;}
	public String codigoEntidadBanco {get; set;}
	public String codigoSucursal {get; set;}
	public Boolean profesionalRappel {get; set;}
	public String tipologiaRappel {get; set;}
	public String digitosControl {get;set;}
	public String numeroCuenta {get;set;}
	public String numeroIban {get;set;}
	public String paisCuentaBancaria {get;set;}
	public Boolean embargado {get;set;}
	public Boolean vetado {get;set;}
	public Boolean profesionalPerito{get;set;}

}