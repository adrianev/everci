/*
 * Clase de test del Callout_ActualizaSiniestroVesta
 */
@isTest
public without sharing class Test_Callout_ActualizaSiniestroVesta {
	@isTest
	public static void testUtil(){
		Callout_ActualizaSiniestroVesta_RQ datos = new Callout_ActualizaSiniestroVesta_RQ(12345678,1,'','Fecha de Ocurrencia','1','2','05','1','2017445566','9876543');
		String datosSerializados = JSON.serialize(datos);
		test.startTest();
		Callout_ActualizaSiniestroVesta.updateDatosAsync(datosSerializados);
		test.stopTest();
	}
}