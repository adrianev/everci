@isTest
public without sharing class Test_Callout_Previsora_Siniestro {

	@isTest static void pruebaCallout(){
		Test.startTest();
		List<Callout_Previsora_Siniestro_RQ> listaDatos = new List<Callout_Previsora_Siniestro_RQ>();
		Callout_Previsora_Siniestro_RQ datos = new Callout_Previsora_Siniestro_RQ();

		datos.descripcion = '';
		datos.IdSecuencia = '892202';
		datos.Apellido1Perjudicado = 'Gómez';
		datos.Apellido1 = 'Martínez';
		datos.Apellido2Perjudicado = 'Navarro';
		datos.Apellido2 = 'Ortega';
		datos.Calificacion = 10;
		datos.CodigoCausa = 7;
		datos.CodigoGrupo = 12199;
		datos.CodigoModificacion = 31;
		datos.CodigoPerjudicado = 8292;
		datos.CodigoReapertura = 8946;
		datos.CodigoRechazo = 7152;
		datos.CodigoResponsable = 192123;
		datos.ComentarioStrosIndemnizable = ' ';
		datos.ComentarioStrosReparable = ' ';
		datos.CompaniaTercero = 'AXA';
		datos.DNIPerjudicado = '28319272J';
		datos.DNITercero = '91282720S';
		datos.DireccionPerjudicado = 'C/Del Olivo, 98';
		datos.FechaHoraMovimiento = system.today() - 7;
		datos.FechaOcurrencia = system.today();
		datos.IdPoliza = 391283;
		datos.IdSiniestroReparalia = '129h9138fh';
		datos.ImporteReserva = 349.22;
		datos.NombrePerjudicado = 'Noelia';
		datos.NombreTercero = 'Pedro';
		datos.NumSiniestroReparalia = '9283829';
		datos.Perjudicado = 298239;
		datos.PolizaTercero = 'Ocaso';
		datos.ResponsableDelSiniestro = 223856;
		datos.Telefono1Asegurado = '691302720';
		datos.Telefono1AseguradoHoraDesde = '08:00';
		datos.Telefono1AseguradoHoraHasta = '17:00';
		datos.Telefono1AseguradoTipoTelefono = 1;
		datos.TelefonoPerjudicado = '619272029';
		datos.TelefonoTercero = '614402382';
		datos.TipoMovimiento = 17;
		datos.CodGarantia = 971;
		List<Callout_Previsora_Siniestro_RQ.Garantias> listaGar = new List<Callout_Previsora_Siniestro_RQ.Garantias>();
		Callout_Previsora_Siniestro_RQ.Garantias gar1 = new Callout_Previsora_Siniestro_RQ.Garantias();
		gar1.Codigo = 2;
		gar1.ImporteBaseServicio = 9.7;
		gar1.PorcentajeIvaAplicadoServicio= 2;
		listaGar.add(gar1);
		datos.listaGarantias = listaGar;
		listaDatos.add(datos);
		
		String body = Callout_Previsora_Siniestro.construirBody(listaDatos);
		
		String nombreIntegracion = 'SRV-PSI-048 - Siniestro Previsora';
		
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		
		Callout_Previsora_Siniestro.updateDatos(body,nombreIntegracion,''+bitacora.Id,'');
				
		test.stopTest();
	}




	/*@isTest
	public static void Testing(){
		test.startTest();
		List<Callout_Previsora_Siniestro_RQ> listaDatos = new List<Callout_Previsora_Siniestro_RQ>();
		Callout_Previsora_Siniestro_RQ datos = new Callout_Previsora_Siniestro_RQ();

		datos.IdSecuencia = '892202';
		datos.Apellido1Perjudicado = 'Gómez';
		datos.Apellido1 = 'Martínez';
		datos.Apellido2Perjudicado = 'Navarro';
		datos.Apellido2 = 'Ortega';
		datos.Calificacion = 10;
		datos.CodigoCausa = 7;
		datos.CodigoGrupo = 12199;
		datos.CodigoModificacion = 31;
		datos.CodigoPerjudicado = 8292;
		datos.CodigoReapertura = 8946;
		datos.CodigoRechazo = 7152;
		datos.CodigoResponsable = 192123;
		datos.ComentarioStrosIndemnizable = ' ';
		datos.ComentarioStrosReparable = ' ';
		datos.CompaniaTercero = 'AXA';
		datos.DNIPerjudicado = '28319272J';
		datos.DNITercero = '91282720S';
		datos.DireccionPerjudicado = 'C/Del Olivo, 98';
		datos.FechaHoraMovimiento = system.today() - 7;
		datos.FechaOcurrencia = system.today();
		datos.IdPoliza = 391283;
		datos.IdSiniestroReparalia = '129h9138fh';
		datos.ImporteReserva = 349.22;
		datos.NombrePerjudicado = 'Noelia';
		datos.NombreTercero = 'Pedro';
		datos.NumSiniestroReparalia = '9283829';
		datos.Perjudicado = 298239;
		datos.PolizaTercero = 'Ocaso';
		datos.ResponsableDelSiniestro = 223856;
		datos.Telefono1Asegurado = '691302720';
		datos.Telefono1AseguradoHoraDesde = '08:00';
		datos.Telefono1AseguradoHoraHasta = '17:00';
		datos.Telefono1AseguradoTipoTelefono = 1;
		datos.TelefonoPerjudicado = '619272029';
		datos.TelefonoTercero = '614402382';
		datos.TipoMovimiento = 17;
		datos.CodGarantia = 971;
		List<Callout_Previsora_Siniestro_RQ.Garantias> listaGar = new List<Callout_Previsora_Siniestro_RQ.Garantias>();
		Callout_Previsora_Siniestro_RQ.Garantias gar1 = new Callout_Previsora_Siniestro_RQ.Garantias();
		gar1.Codigo = 2;
		gar1.ImporteBaseServicio = 9.7;
		gar1.PorcentajeIvaAplicadoServicio= 2;
		listaGar.add(gar1);
		datos.listaGarantias = listaGar;
		listaDatos.add(datos);
		Callout_Previsora_Siniestro.updateDatos(listaDatos); 
		test.stopTest();
	}*/

}