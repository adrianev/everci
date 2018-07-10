global with sharing class Callaut_contactar {
    
    public class Resultado{
		public String code = '';
		public String message = '';
	}

	public class completadas{
		public String idRef = '';
		public String idServicio = '';
		public String idCarga = '';
	}

	public Class ResultadoFinal{
		public List<completadas> completadas;
		public Resultado resultado;
	}

	public static ResultadoFinal sendDatos(Callout_ClickToCall_RQ datos){

		ResultadoFinal res = new ResultadoFinal();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		try{
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Contactar'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			request.setHeader('content-type',ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
            String returnToken = new GetTokenPSI().getToken();
            if(returnToken != ''){
            	request.setHeader('Authorization',returnToken);
            }
			request.setBody(JSON.Serialize(datos));
			system.debug('Request: '+request.getBody());
			HttpResponse response;
			response = http.send(request);
			res = (ResultadoFinal)JSON.Deserialize(response.getBody(),ResultadoFinal.class);

			return res;

		}catch(Exception e){
			system.debug(e.getStackTraceString());
			return null;
		}
	}
}