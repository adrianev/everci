/**
* Clase que es la respuesta del servicio "Rest_ConsultaCaso"
*
* @author EVERIS
* 
*/
global without sharing class Rest_ConsultaCaso_RP {
    public String code{get;set;}
    public String message{get;set;}
    public String Name{get;set;}
    public String CUE_TXT_PrimerApellido{get;set;}
    public String CUE_TXT_SegundoApellido{get;set;}
    public String CUE_TXT_Numero_Documento{get;set;}
    public List<Rest_Case_RP> listadoCaso{get;set;}
}