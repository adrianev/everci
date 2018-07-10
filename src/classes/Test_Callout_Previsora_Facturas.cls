@isTest
public without sharing class Test_Callout_Previsora_Facturas {

	@isTest
	public static void Testing(){
		test.startTest();
		List<Callout_Previsora_Facturas_RQ> listDatos = new List<Callout_Previsora_Facturas_RQ>();
		Callout_Previsora_Facturas_RQ fac1 = new Callout_Previsora_Facturas_RQ();
		Callout_Previsora_Facturas_RQ fac2 = new Callout_Previsora_Facturas_RQ();
		Callout_Previsora_Facturas_RQ datos = new Callout_Previsora_Facturas_RQ();

		fac1.estadoSiniestro = 002;
		fac1.fechaFacturaServicio = system.today();
		fac1.idFacturaReparalia = 198237;
		fac1.idPoliza = 389163;
		fac1.numFacturaServicio = '105';
		fac1.numReparacion = 382947;
		fac1.numSiniestroReparalia = 0;
		fac1.idSecuencia = '102ab301c';

		List<Callout_Previsora_Facturas_RQ.Garantia> lista1Garantias = new List<Callout_Previsora_Facturas_RQ.Garantia>();
		Callout_Previsora_Facturas_RQ.Garantia garantia1_1 = new Callout_Previsora_Facturas_RQ.Garantia();
		Callout_Previsora_Facturas_RQ.Garantia garantia1_2 = new Callout_Previsora_Facturas_RQ.Garantia();

		garantia1_1.codGarantia = 25;
		garantia1_1.importeBaseServicio = 46;
		garantia1_1.porcenIvaAplicadoServicio = 21;
		lista1Garantias.add(garantia1_1);

		garantia1_2.codGarantia = 23;
		garantia1_2.importeBaseServicio = 37;
		garantia1_2.porcenIvaAplicadoServicio = 18;
		lista1Garantias.add(garantia1_2);


		fac1.listaGarantias=lista1Garantias;
		listDatos.add(fac1);

		fac2.estadoSiniestro = 001;
		fac2.fechaFacturaServicio = system.today()-7;
		fac2.idFacturaReparalia = 198262;
		fac2.idPoliza = 389277;
		fac2.numFacturaServicio = '100';
		fac2.numReparacion = 392847;
		fac2.numSiniestroReparalia = 3;
		fac2.idSecuencia = '123ab302d';

		List<Callout_Previsora_Facturas_RQ.Garantia> lista2Garantias = new List<Callout_Previsora_Facturas_RQ.Garantia>();
		Callout_Previsora_Facturas_RQ.Garantia garantia2_1 = new Callout_Previsora_Facturas_RQ.Garantia();
		Callout_Previsora_Facturas_RQ.Garantia garantia2_2 = new Callout_Previsora_Facturas_RQ.Garantia();

		garantia2_1.codGarantia = 27;
		garantia2_1.importeBaseServicio = 40;
		garantia2_1.porcenIvaAplicadoServicio = 22;
		lista1Garantias.add(garantia2_1);

		garantia2_2.codGarantia = 23;
		garantia2_2.importeBaseServicio = 38;
		garantia2_2.porcenIvaAplicadoServicio = 22;
		lista2Garantias.add(garantia2_2);

		fac2.listaGarantias = lista2Garantias;

		listDatos.add(fac2);

		datos.TotalServiciosSinIva = 0;
		datos.TotalServiciosConIva = 4;
		datos.FechaHoraMovimiento = system.today();

		//Callout_Previsora_Facturas.updateDatos(listDatos, datos);

		String body = Callout_Previsora_Facturas.construirBody(listDatos, datos);

		String nombreIntegracion = 'SRV-PSI-072 - Facturas_Previsora';

		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;

		Callout_Previsora_Facturas.updateDatos(body,nombreIntegracion,''+bitacora.Id,'');
		
		
		

		test.stopTest();
	}

}