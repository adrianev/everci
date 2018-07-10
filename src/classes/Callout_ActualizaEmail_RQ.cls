/*
 * Clase que encapsula los datos a introducir en la request a Ensura para informarle acerca de la 
 * actualización de emails para usuarios Robinson 
 * @author EVERIS
 * @version 1.0
 */
public without sharing class Callout_ActualizaEmail_RQ {
	public String identificadorCompania{get;set;}
	public String usuario{get;set;}
	public String emailCompania{get;set;}
}