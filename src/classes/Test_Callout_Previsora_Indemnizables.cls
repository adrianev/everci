@isTest
public without sharing class Test_Callout_Previsora_Indemnizables {

	@isTest
	public static void Testing(){
		test.startTest();
		List<Callout_Previsora_Indemnizables_RQ> listDatos = new List<Callout_Previsora_Indemnizables_RQ>();
		Callout_Previsora_Indemnizables_RQ indemnizables1 = new Callout_Previsora_Indemnizables_RQ();
		Callout_Previsora_Indemnizables_RQ indemnizables2 = new Callout_Previsora_Indemnizables_RQ();

		indemnizables1.beneficiario = '2';
		indemnizables1.codigoPostalBenef = '28050';
		indemnizables1.conceptoPago = 'FACTURA CERRAJERO';
		indemnizables1.domicilioBenef = 'Avd.Principal';
		indemnizables1.estadoSiniestro = 1;
		indemnizables1.fechaCierre =15012018;
		indemnizables1.fechaHoraMovimiento = system.today();
		indemnizables1.fechaRecepcionRepFacturaPerito = system.today();
		indemnizables1.idPagoIndemnizableReparalia = 01;
		indemnizables1.idPoliza = 'j01893je';
		indemnizables1.importeBaseGastosPerito = 1;
		indemnizables1.importeBaseHonorariosPerito = 20;
		indemnizables1.localidadBenef = 'Badajoz';
		indemnizables1.nifBenef = '3915922X';
		indemnizables1.nifPerito = '90237129Y';
		indemnizables1.nombreApellidosBenef = 'FranciscoZamoraPolo';
		indemnizables1.numFacturaPerito = '18292103';
		indemnizables1.numPago = '2821';
		indemnizables1.numSiniestroPrevisora = '0';
		indemnizables1.numSiniestroReparalia = '221898298';
		indemnizables1.personaFisicaJuridicaBenef = 1;
		indemnizables1.porcentajeIvaIgiPerito = 20;
		indemnizables1.telefonoFaxBenef = '919102918';
		indemnizables1.tipoDocumentoBenef = 2;
		indemnizables1.tipoImpuestoPerito = 3;
		indemnizables1.tipoRegistro = '1';
		indemnizables1.idSecuencia = '0129abl';

		listDatos.add(indemnizables1);

		List<Callout_Previsora_Indemnizables_RQ.Garantia> lista1Garantias = new List<Callout_Previsora_Indemnizables_RQ.Garantia>();
		Callout_Previsora_Indemnizables_RQ.Garantia garantia1_1 = new Callout_Previsora_Indemnizables_RQ.Garantia();
		Callout_Previsora_Indemnizables_RQ.Garantia garantia1_2 = new Callout_Previsora_Indemnizables_RQ.Garantia();

		garantia1_1.codGarantia = 17;
		garantia1_1.importeBaseServicio = 0;
		garantia1_1.porcenIvaAplicadoServicio = 2;
		lista1Garantias.add(garantia1_1);


		garantia1_2.codGarantia = 23;
		garantia1_2.importeBaseServicio = 46;
		garantia1_2.porcenIvaAplicadoServicio = 8;
		lista1Garantias.add(garantia1_2);

		indemnizables1.listaGarantias=lista1Garantias;

		indemnizables2.beneficiario = '1';
		indemnizables2.codigoPostalBenef = '28002';
		indemnizables2.conceptoPago = 'FACTURA FONTANERO';
		indemnizables2.domicilioBenef = 'Avd.Grande';
		indemnizables2.estadoSiniestro = 2;
		indemnizables2.fechaCierre = 24122017;
		indemnizables2.fechaHoraMovimiento = system.today();
		indemnizables2.fechaRecepcionRepFacturaPerito = system.today();
		indemnizables2.idPagoIndemnizableReparalia = 01;
		indemnizables2.idPoliza = 'prueba';
		indemnizables2.importeBaseGastosPerito = 2;
		indemnizables2.importeBaseHonorariosPerito = 23;
		indemnizables2.localidadBenef = 'Murcia';
		indemnizables2.nifBenef = '31830175B';
		indemnizables2.nifPerito = '72639401E';
		indemnizables2.nombreApellidosBenef = 'ManuelReyesRodriguez';
		indemnizables2.numFacturaPerito = '283928';
		indemnizables2.numPago = '1702';
		indemnizables2.numSiniestroPrevisora = '2';
		indemnizables2.numSiniestroReparalia = '18932';
		indemnizables2.personaFisicaJuridicaBenef = 2;
		indemnizables2.porcentajeIvaIgiPerito = 17;
		indemnizables2.telefonoFaxBenef = '91823403';
		indemnizables2.tipoDocumentoBenef = 1;
		indemnizables2.tipoImpuestoPerito = 4;
		indemnizables2.tipoRegistro = '7';
		indemnizables2.idSecuencia = '21ba1';

		List<Callout_Previsora_Indemnizables_RQ.Garantia> lista2Garantias = new List<Callout_Previsora_Indemnizables_RQ.Garantia>();
		Callout_Previsora_Indemnizables_RQ.Garantia garantia2_1 = new Callout_Previsora_Indemnizables_RQ.Garantia();
		Callout_Previsora_Indemnizables_RQ.Garantia garantia2_2 = new Callout_Previsora_Indemnizables_RQ.Garantia();

		garantia2_1.codGarantia = 19;
		garantia2_1.importeBaseServicio = 19;
		garantia2_1.porcenIvaAplicadoServicio = 4;
		lista2Garantias.add(garantia2_1);

		garantia2_2.codGarantia = 80;
		garantia2_2.importeBaseServicio = 19;
		garantia2_2.porcenIvaAplicadoServicio = 4;
		lista2Garantias.add(garantia2_2);

		indemnizables2.listaGarantias = lista2Garantias;
		indemnizables2.listaGarantias=lista2Garantias;

		listDatos.add(indemnizables2);
		
		String body = Callout_Previsora_Indemnizables.construirBody(listDatos);
		system.debug('>>>>>verBody: ' + body);
		
		String nombreIntegracion = 'SRV-PSI-073-Indemni_Previsora';
		
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		
		system.debug('>>>>>>PasaPorAqui');
		
		Callout_Previsora_Indemnizables.updateDatos(body,nombreIntegracion,''+bitacora.Id,'');
				
		test.stopTest();
	}
}