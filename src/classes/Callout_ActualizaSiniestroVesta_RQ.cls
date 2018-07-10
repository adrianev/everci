/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_ActualizaSiniestroVesta"
 *
 * @author EVERIS
 */
public without sharing class Callout_ActualizaSiniestroVesta_RQ {
	public Integer actuacion{get;set;}
	public Integer casoActualizacion{get;set;}
	public String fechaCambio{get;set;}
	public String descripcionNoAbierto{get;set;}
	public String tipoSiniestro{get;set;}
	public String gremio{get;set;}
	public String numeroSiniestroHS{get;set;}
	public String numeroSiniestroCia{get;set;}
	public String tipoSituacion{get;set;}
	public String tipoSituacionReparacion{get;set;}

	public Callout_ActualizaSiniestroVesta_RQ(Integer actuacion, Integer casoActualizacion, String fechaCambio, String descripcionNoAbierto,
			String tipoSiniestro, String gremio, String numeroSiniestroHS, String numeroSiniestroCia, String tipoSituacion, String tipoSituacionReparacion){
		this.actuacion = actuacion;
		this.casoActualizacion = casoActualizacion;
		this.fechaCambio = fechaCambio;
		this.descripcionNoAbierto = descripcionNoAbierto;
		this.tipoSiniestro = tipoSiniestro;
		this.gremio = gremio;
		this.numeroSiniestroHS = numeroSiniestroHS;
		this.numeroSiniestroCia = numeroSiniestroCia;
		this.tipoSituacion = tipoSituacion;
		this.tipoSituacionReparacion = tipoSituacionReparacion;
	}
}