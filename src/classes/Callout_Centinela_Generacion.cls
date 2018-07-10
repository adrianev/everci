public without sharing class Callout_Centinela_Generacion {
	public static String token;
	public Boolean updateDatos(String fichero) {

		Callout_Centinela_Generacion_RP rp = new Callout_Centinela_Generacion_RP();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		//1. Obtenemos los parámetros de configuración del header desde un metadato que hemos creado
		WS_Info__mdt ws_AE = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Centinela_Generacion'][0];

		try{
			System.debug('---------- Req Callout Centinela');
			request.setHeader('content-type',ws_AE.Content_Type__c);
			request.setEndPoint(ws_AE.EndPoint__c+fichero); 
			System.debug('---------- Endpoint: ' + ws_AE.EndPoint__c+fichero);
			request.setMethod(ws_AE.Method__c);
			System.debug('---------- método: ' + ws_AE.Method__c);
			request.setTimeout(Integer.valueOf(ws_AE.TimeOut__c));
			System.debug('---------- método: ' + ws_AE.Method__c);
			//1.Obtenemos el token para conectarnos a PSI
			/*if(String.isBlank(token)){
				system.debug('pido token');
				token = new GetTokenPSI().getToken();
				system.debug('----token');
			}
			request.setHeader('Authorization',token);*/
			HttpResponse response = http.send(request);
			rp = (Callout_Centinela_Generacion_RP) JSON.deserialize(response.getBody(),Callout_Centinela_Generacion_RP.class);
            system.debug(response.getBody() + ' body');
			system.debug('Response: '+rp);
			if(rp.code=='INT-001'){ 
				system.debug('INT-001');
				return true;
			} else if(rp.code=='INT-009'){
				system.debug('INT-009. Error desconocido');
				//callout caido, ver si se avisa o qué
          	}
		}catch (Exception e){
			system.debug('---- Excepcion: ' + e);
		}
		return false;
	}
}