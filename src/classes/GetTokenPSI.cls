/**
 * Esta clase se encarga de traer el token necesario para las comunicaciones por HTTPS contra PSI.
 * @author everis
 * @version 1.0
 */
public without sharing class GetTokenPSI {

	private static HttpResponse resultMock;	

	public string getToken() {
		HttpRequest req = new HttpRequest();   
		String resultado ='';
		TokenPSI__mdt datosPSI = [select Client_id__c, Client_secret__c, Content_Type__c, Grant_type__c,Method__c,EndPoint__c  from TokenPSI__mdt where MasterLabel = 'PSI'][0];
		req.setEndpoint(datosPSI.EndPoint__c);
		req.setMethod(datosPSI.Method__c);
		req.setHeader('Content-Type', datosPSI.Content_Type__c);
		String body ='client_id='+datosPSI.Client_id__c;
		body += '&client_secret='+datosPSI.Client_secret__c; 
		body += '&grant_type='+datosPSI.Grant_type__c;
		req.setBody(body);

		System.debug('Request Body: ' + req.getBody());
		System.debug('Endpoint: ' + req.getEndpoint());

		Http http = new Http();
		HTTPResponse res;
		if (!test.isRunningTest()) {
			res = http.send(req);
			System.debug('---- Request Send ----');
		}
		else {
			System.debug('---- Es Test ----');
			setResponseMock();
			res = resultMock;
		}

		System.debug('Endpoint: ' +res.getStatus() + ' Status Code ' + res.getStatusCode());
		System.debug('Response: '+res.getBody());
		if(res.getStatusCode()==200 || test.isRunningTest()){
			JSONParser parser = JSON.createParser(res.getBody());	
			resultado = analizarRespuesta(parser);
			system.debug('Token= '+resultado);
		}
		return resultado;
	}

	private static String analizarRespuesta(JSONParser response){
		String token = '';
		String tokenType = '';
		while(response.nextToken() != null){

			String gett = response.getText();
			if(gett == 'access_token'){
				response.nextToken();
				token = response.getText();
			}
			if(gett == 'token_type'){
				response.nextToken();
				tokenType += ' '+response.getText();
			}
		}
		String tokenReturn = tokenType+' '+token;
		return tokenReturn;
	}   

	private static void setResponseMock(){
		String body = '{'+
				'"access_token" : "83e7d60e-309a-4419-9bc7-d87a187734df",'+
				'"token_type" : "Bearer",' +
				'"expires_in" : 3600,' +
				'"scope": "oob"}';
		System.debug('Body: ' + body);

		resultMock = new HttpResponse();
		resultMock.setBody(body);
	}
}