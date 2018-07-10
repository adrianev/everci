/**
 * Clase de Test de la Clase Callout_Reintento_Llamada
 *  @author everis 
 **/
@isTest
public without sharing class Test_Callout_Reintento_Llamada {
	@isTest
	public static void testOK(){	
		Controller_Reintento_Llamada_RQ datos = new Controller_Reintento_Llamada_RQ();
		datos.identificador = 'aa';
		datos.endPoint = 'prueba';
		datos.body = 'body';
		test.startTest();
		Reintento_Llamada_Controller.solicitarReintento('test','test','test');
		Callout_Reintento_Llamada.Resultado res = Callout_Reintento_Llamada.sendDatos(datos);
		test.stopTest();
	}
}