/**
 * Todo: Clase que se utilizará para crear o actualizar profesionales en CPQ. 
 *	
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_CPQ_Profesionales {
	
	private static HttpResponse resultMock;
	private static String body;
	private static Integer contParametros;
	
	/* Clase de respuesta */
	public without sharing class Resultado {
		public String code = '';
		public String message = '';
	}
	
	@future(callout=true)
	public static void updateDatos(String bodySend, String nombreIntegracion, String idBitacora, String identificadorUnicoProfesional){
		
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		INT_Bitacora__c error = new INT_Bitacora__c();
		
		try {
			System.debug('-------- Req Callout_CPQ_Profesionales --------');
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_CPQ_Profesionales'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			request.setHeader('content-type', ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
			request.setBody(bodySend);
			system.debug('-------- Request: '+ request.getBody());
			HttpResponse response;
			if (!test.isRunningTest()) {
				String returnToken = new GetTokenPSI().getToken();
                if(returnToken != ''){
                	request.setHeader('Authorization',returnToken);
                }
				response = http.send(request);
			}else{
				setResponseMock();
				response = resultMock;	
			}
			system.debug('-------- Response: ' + response);
			res = (Resultado)JSON.Deserialize(response.getBody(),Resultado.class);
			system.debug('-------- Resultado: '+ res);
			
			if (res.code != 'CPQ-001' && res.message != 'Operación ejecutada correctamente') {
				INT_Bitacora__c bitacora = [SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id =: idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c + 1;
				}
				else {
					bitacora.BIT_NUM_Reintentos__c = 1;
				}
				Util_Llamada_Externa.insertarBitacora(Label.CPQ_Profesional,res.code +' '+ res.message,'03','02',Label.CPQ_Profesional_Nombre,bodySend,ws_CASV.EndPoint__c,
							'','','','','','',identificadorUnicoProfesional,0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_POST);
			}
			else {
				system.debug('-------- Entra en el else -> No ha habido error --------');
				system.debug('-------- Id Profesional: ' + identificadorUnicoProfesional);
				Util_Llamada_Externa.insertarBitacora(Label.CPQ_Profesional,'','06','02',Label.CPQ_Profesional_Nombre,bodySend,ws_CASV.EndPoint__c,
							'','','','','','',identificadorUnicoProfesional,0,idBitacora,0,Label.Callout_POST);
			}
		}
		catch (Exception e) {
			system.debug('-------- Id Bitacora: ' + idBitacora);
			INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(bitacora.BIT_NUM_Reintentos__c != null){
				bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
			}else{
				bitacora.BIT_NUM_Reintentos__c = 1;
			}
			WS_Info__mdt ws_CASV = [select EndPoint__c from WS_Info__mdt where MasterLabel = 'Callout_CPQ_Profesionales'][0];
			Util_Llamada_Externa.insertarBitacora(Label.CPQ_Profesional,res.code +' '+ res.message,'03','02',Label.CPQ_Profesional_Nombre,bodySend,ws_CASV.EndPoint__c,
							'','','','','','',identificadorUnicoProfesional,0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_POST);
		}
	}
	
	/*
	 * Método encargado de simular el mensaje de respuesta en los test; se simula 
	 * el mensaje a recibir mediente la inicialización de un valor que se provee al constructor
	 *
	 */
	private static void setResponseMock(){

		String body = '{' +
				'"code": "CPQ-001",' +
				'"message": "Operación ejecutada correctamente"}';

		resultMock = new HttpResponse();
		resultMock.setBody(body);

	}
	
}