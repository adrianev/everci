/**
 * Clase de respuesta de la clase 'Rest_B2BB2B2C_CreacionServicio'
 *
 * @author EVERIS
 *
 */

global without sharing class Rest_B2BB2B2C_CreacionServicio_RP {
	public String code{get;set;}
	public String message{get;set;}
	public String Id{get;set;}
	public String identificadorUnicoOrden{get;set;}
	public String codigoCita{get;set;}
	public List<Rest_Franja_RP> listadoFranjas{get;set;}
}