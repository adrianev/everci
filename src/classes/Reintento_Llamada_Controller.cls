global without sharing class Reintento_Llamada_Controller {
	public Reintento_Llamada_Controller(){
		
	}
	WebService static String solicitarReintento(String body, String endPoint, String identificador ){
		Controller_Reintento_Llamada_RQ request = new Controller_Reintento_Llamada_RQ();
		request.body = body;
		request.endPoint = endPoint;
		request.identificador = identificador;
		if (!test.isRunningTest())
			Callout_Reintento_Llamada.sendDatos(request);
		return 'Ok';
	}
}