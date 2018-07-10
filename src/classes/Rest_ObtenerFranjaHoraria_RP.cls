/**
* Clase de respuesta del servicio "Rest_ObtenerFranjaHoraria"
* 
* @author everis
* @version 1.0
*/
global without sharing class Rest_ObtenerFranjaHoraria_RP {
    public String code{get;set;}
    public String message{get;set;}
    public List<Rest_Franja_RP> listadoFranjas{get;set;}
}