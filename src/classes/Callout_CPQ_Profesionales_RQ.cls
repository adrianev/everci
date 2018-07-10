/*
 * Clase que encapsula los datos a introducir en la request para la clase "Callout_CPQ_Profesionales"
 *
 * @author EVERIS
 */

public without sharing class Callout_CPQ_Profesionales_RQ {
	public String login {get;set;}
	public String nombreProfesional {get;set;}
	public String apellidosProfesional {get;set;}
	public String emailProfesional {get;set;}
	public String zonaHoraria {get;set;}
	public String partnerLogin {get;set;}
	public String estado {get;set;}
}