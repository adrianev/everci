@isTest
public without sharing class Test_Callout_Previsora_Abono {

	@isTest
	public static void Testing(){
		test.startTest();
		List<Callout_Previsora_Abono_RQ> listAbonos = new List<Callout_Previsora_Abono_RQ>();
		Callout_Previsora_Abono_RQ abono1 = new Callout_Previsora_Abono_RQ();
		Callout_Previsora_Abono_RQ abono2 = new Callout_Previsora_Abono_RQ();

		// AÑADIMOS ABONO 1

		abono1.ConceptoPago = 'Error a su favor';
		abono1.FechaAbono = DateTime.now();
		abono1.FechaHoraMovimiento = DateTime.now();
		abono1.IdAbonoReparalia = 'asdasd';
		abono1.IdPoliza = 123123;
		abono1.TotalServiciosSinIva = '82.2';
		abono1.TotalServiciosConIva = '93.4';

		List<Callout_Previsora_Abono_RQ.Garantias> lista1Garantias = new List<Callout_Previsora_Abono_RQ.Garantias>();
		Callout_Previsora_Abono_RQ.Garantias garantia1_1 = new Callout_Previsora_Abono_RQ.Garantias();
		Callout_Previsora_Abono_RQ.Garantias garantia1_2 = new Callout_Previsora_Abono_RQ.Garantias();

		garantia1_1.Codigo = 23;
		garantia1_1.ImporteBaseServicio = 0;
		garantia1_1.PorcentajeIvaAplicadoServicio = 2;
		lista1Garantias.add(garantia1_1);

		garantia1_2.Codigo = 24;
		garantia1_2.ImporteBaseServicio = 3;
		garantia1_2.PorcentajeIvaAplicadoServicio = 0;
		lista1Garantias.add(garantia1_2);

		abono1.listaGarantias = lista1Garantias;

		abono1.NumFactura = 'asdfasdf';
		abono1.NumReparacion = 'asdfasdf';
		abono1.NumSiniestroReparalia = 'asdfasdff';
		abono1.IdSecuencia = '2341234';

		listAbonos.add(abono1);

		// AÑADIMOS ABONO 2

		abono2.ConceptoPago = 'Error a su favor';
		abono2.FechaAbono = DateTime.now();
		abono2.FechaHoraMovimiento = DateTime.now();
		abono2.IdAbonoReparalia = 'asdasd';
		abono2.IdPoliza = 123123;

		List<Callout_Previsora_Abono_RQ.Garantias> lista2Garantias = new List<Callout_Previsora_Abono_RQ.Garantias>();
		Callout_Previsora_Abono_RQ.Garantias garantia2_1 = new Callout_Previsora_Abono_RQ.Garantias();
		Callout_Previsora_Abono_RQ.Garantias garantia2_2 = new Callout_Previsora_Abono_RQ.Garantias();

		garantia2_1.Codigo = 23;
		garantia2_1.ImporteBaseServicio = 0;
		garantia2_1.PorcentajeIvaAplicadoServicio = 2;
		lista2Garantias.add(garantia2_1);

		garantia2_2.Codigo = 24;
		garantia2_2.ImporteBaseServicio = 3;
		garantia2_2.PorcentajeIvaAplicadoServicio = 0;
		lista2Garantias.add(garantia2_2);

		abono2.listaGarantias = lista2Garantias;

		abono2.NumFactura = 'asdfasdf';
		abono2.NumReparacion = 'asdfasdf';
		abono2.NumSiniestroReparalia = 'asdfasdff';
		abono2.IdSecuencia = '2341234';

		listAbonos.add(abono2);
		
		String body = Callout_Previsora_Abono.construirBody(listAbonos);

		String nombreIntegracion = 'SRV-PSI-085 - Abono Previsora';

		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;

		Callout_Previsora_Abono.updateDatos(body,nombreIntegracion,''+bitacora.Id,'');
		
		test.stopTest();
	}
}