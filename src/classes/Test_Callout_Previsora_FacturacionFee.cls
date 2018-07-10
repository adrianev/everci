@isTest
public without sharing class Test_Callout_Previsora_FacturacionFee {

	@isTest
	public static void Testing(){
		test.startTest();
		List<Callout_Previsora_FacturacionFee_RQ> listaFacturas = new List<Callout_Previsora_FacturacionFee_RQ>();
		Callout_Previsora_FacturacionFee_RQ fac1 = new Callout_Previsora_FacturacionFee_RQ();
		Callout_Previsora_FacturacionFee_RQ fac2 = new Callout_Previsora_FacturacionFee_RQ();
		Callout_Previsora_FacturacionFee_RQ datos = new Callout_Previsora_FacturacionFee_RQ();

		fac1.FechaFacturaGestion = '2017-12-04T14:20:03.932+01:00';
		fac1.IdFacturaFeeReparalia = '28050';
		fac1.IdPoliza = 123123;
		fac1.Importe = 120.3;
		fac1.EstadoSiniestro = 1;
		fac1.NumFacturaGestion = 'sdffsdfs';
		fac1.NumSiniestroReparalia = 'asdasdasd';
		fac1.PorcentajeIVA = 10.0;
		fac1.IdSecuencia = '113036';

		listaFacturas.add(fac1);

		fac2.FechaFacturaGestion = '2017-12-04T14:20:03.932+01:00';
		fac2.IdFacturaFeeReparalia = '28050';
		fac2.IdPoliza = 123123;
		fac2.Importe = 120.3;
		fac2.EstadoSiniestro = 1;
		fac2.NumFacturaGestion = 'sdffsdfs';
		fac2.NumSiniestroReparalia = 'asdasdasd';
		fac2.PorcentajeIVA = 10.0;
		fac2.IdSecuencia = '113036';

		listaFacturas.add(fac2);

		datos.TotalServiciosSinIva = 288.22;
		datos.TotalServiciosConIva = 317.04;
		datos.FechaHoraMovimiento = DateTime.now();

		String body = Callout_Previsora_FacturacionFee.construirBody(listaFacturas, datos);
		system.debug('>>>>>verBody: ' + body);
		
		String nombreIntegracion = 'SRV-PSI-084 - FacturacionFee Previsora';
		
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		
		system.debug('>>>>>>PasaPorAqui');
		
		Callout_Previsora_FacturacionFee.updateDatos(body,nombreIntegracion,''+bitacora.Id,'');
		
		test.stopTest();
	}

}