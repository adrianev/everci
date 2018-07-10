/*
 * Clase que encapsula los datos a introducir en la request a Ensura para informarle acerca de la 
 * actualización del check Robinson
 * @author EVERIS
 * @version 1.0
 */
public without sharing class Callout_Actualizar_Check_Robin_RQ {
	public String tomadorNumeroDocumentoCliente {get;set;}
	public boolean checkRobinson {get;set;}
	public String usuario {get;set;}
}