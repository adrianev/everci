/*
 * Clase que encapsula los datos que se tendrán de respuesta en la clase "Callout_ConsultaPolizaVesta"
 *
 * @author EVERIS
 */
public without sharing class Callout_ConsultaPolizaVesta_RP {
	public String identificadorCompania {get;set;}
	public String nombreCompania {get; set;}
	public Id idSFCompania {get; set;}
	public String numeroPoliza {get;set;}
	public String listaTelefono {get;set;}

	public String errorCode{get;set;}
	public String errorMessage{get;set;}

	public String identificadorVersion {get;set;}
	public DateTime fechaInicioCobertura {get;set;}
	public DateTime fechaFinCobertura {get;set;}
	public String numeroDocumento {get;set;}
	public String nombre {get;set;}
	public String apellido1 {get;set;}
	public String apellido2 {get;set;}
	public String email {get;set;}
	public String idioma {get;set;}
	public String producto {get;set;}
	public String nombreProducto {get; set;}
	public Id idSFProducto {get; set;}
	public String descProdAux{get;set;}

	public String direccionRiesgoDomicilio {get;set;}
	public String direccionRiesgoPoblacion {get;set;}
	public String direccionRiesgoProvincia {get;set;}
	public String direccionRiesgoCodProvincia {get;set;}
	public String direccionRiesgoCp {get;set;}
	public Double capitalContenido {get;set;}
	public Double capitalContinente {get;set;}
	public Double capitalObjetos {get;set;}
	public String certificado {get;set;}
	public String codigoDelegacion {get;set;}
	public String codigoSucursal {get;set;}
	public Integer controlDigitoSegurcaixa {get;set;}
	public String datosVivienda {get;set;}
	public DateTime fechaAltaCompania {get;set;}
	public Boolean isGold {get;set;}
	public Boolean isVip {get;set;}	
	public String VIPCompany {get;set;}	
	public Integer superficieGaraje {get;set;}	
	public Integer superficieTrastero {get;set;}	
	public Integer superficieVivienda {get;set;}	
	public String suplemento {get;set;}	
	public String tipoDivisa {get;set;}	
	public String tipoRegimenVivienda {get;set;}	
	public Integer tipoTransferencia {get;set;}	
	public String polizaComplementaria {get;set;}	
	public String codigoGestor {get;set;}	
	public String codigocliente {get;set;}
	public String telefono1 {get;set;}	
	public String telefono2 {get;set;}															
	public String telefono3 {get;set;}
	public String telefono4 {get;set;}
	public String numeroPolizasActivas{get;set;}

	public Boolean perteneceHS {get;set;}
	public String perteneceHSMsg {get;set;}
	public String estado {get;set;}

	public String nombreCompleto {get;set;}	
	public String direccionCompleta {get;set;}

	public String codigoMunicipio {get;set;}	
	public String rolAsegurado {get;set;}
	public String idClienteEnsura {get;set;}

}