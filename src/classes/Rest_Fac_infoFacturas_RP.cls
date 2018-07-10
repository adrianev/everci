/**
* Clase que es la respuesta del servicio "Rest_Fac_infoFacturas"
*
* @author EVERIS
* 
*/
global without sharing class Rest_Fac_infoFacturas_RP {
    public List<String> listaFacturas {get;set;}
    public String success {get;set;}
    public String errors {get;set;}
}