/*
 * Clase que encapsula los datos a introducir en la request a Ensura para informarle acerca de la 
 * actualización de teléfonos de usuarios no Robinson = false (Aquel que quiere recibir ofertas, información ...)
 * @author EVERIS 
 * @version 1.0
 */
public without sharing class Callout_ActualizaTelefono_RQ {
	public String identificadorCompania{get;set;}
	public String nuevoValorTelefono{get;set;}
	public String anteriorValorTelefono{get;set;}
	public String usuario{get;set;}
	public Integer tipoCorreccion{get;set;}
}