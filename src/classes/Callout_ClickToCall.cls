/**
 * Todo: Clase que se utilizará para ClickToCall.
		La configuración de la conectividad de la clase se encuentra en el metadato "".
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_ClickToCall {
	private static HttpResponse resultMock;	
	private static String body;	
	/**
	 * Clase de respuesta.
	 *
	 */
	public class Resultado{
		public String code = '';
		public String message = '';
	}	
	
	/**
	 * método que ejecuta el Callout contra el servicio externo
	 *
	 */
	public static Resultado sendDatos(Callout_ClickToCall_RQ datos){
		System.debug(datos);
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		//try{
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_ClickToCall'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			request.setHeader('content-type',ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
    
	    //	DESACTIVADO EN DEV
		//	String returnToken = new GetTokenPSI().getToken();
        //  if(returnToken != ''){
        //  	request.setHeader('Authorization',returnToken);
        //	}
			
			request.setBody(JSON.Serialize(datos));
			system.debug('Request: '+request.getBody());
			HttpResponse response;
			response = http.send(request);
			system.debug('Response' + response);
			res = (Resultado)JSON.Deserialize(response.getBody(),Resultado.class);
			return res;

		/*}catch(Exception e){
			system.debug(e.getStackTraceString());
			return null;
		}*/
	}
}