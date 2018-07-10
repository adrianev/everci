@isTest
public without sharing class Test_Callout_Previsora_OrdenDeTrabajo {

	@isTest
	public static void Testing(){
		test.startTest();
		List<Callout_Previsora_OrdenDeTrabajo_RQ> listaReparaciones = new List<Callout_Previsora_OrdenDeTrabajo_RQ>();
		Callout_Previsora_OrdenDeTrabajo_RQ rep1 = new Callout_Previsora_OrdenDeTrabajo_RQ();
		Callout_Previsora_OrdenDeTrabajo_RQ rep2 = new Callout_Previsora_OrdenDeTrabajo_RQ();

		rep1.CodigoAnulacionReparacion = 0010;
		rep1.CodigoModificacion = 8600;
		rep1.CodigoProfesion = 0071;
		rep1.EstadoReparacion = 4012;
		rep1.FechaHoraApertura = Datetime.now();
		rep1.FechaHoraMovimiento = Datetime.now() + 1;
		rep1.IdPoliza = 791283;
		rep1.IdReparacionReparalia = '2dsS0923j';
		rep1.NumReparacion = '09892d23j';
		rep1.NumSiniestroReparalia = '2d2dsS23j';
		rep1.ReparacionUrgente = true;
		rep1.TipoMovimiento = 'Reparación';
		rep1.IdSecuencia = '892dsS029';

		listaReparaciones.add(rep1);

		rep2.CodigoAnulacionReparacion = 0010;
		rep2.CodigoModificacion = 8600;
		rep2.CodigoProfesion = 0071;
		rep2.EstadoReparacion = 4012;
		rep2.FechaHoraApertura = Datetime.now();
		rep2.FechaHoraMovimiento = Datetime.now() + 1;
		rep2.IdPoliza = 791283;
		rep2.IdReparacionReparalia = '2dsS0923j';
		rep2.NumReparacion = '09892d23j';
		rep2.NumSiniestroReparalia = '2d2dsS23j';
		rep2.ReparacionUrgente = true;
		rep2.TipoMovimiento = 'Reparación';
		rep2.IdSecuencia = '892dsS029';

		listaReparaciones.add(rep2);
		
		String body = Callout_Previsora_OrdenDeTrabajo.construirBody(listaReparaciones);
		
		String nombreIntegracion = 'SRV-PSI-049 - Orden_de_trabajo Previsora';
		
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		
		Callout_Previsora_OrdenDeTrabajo.updateDatos(body,nombreIntegracion,''+bitacora.Id,'');
				
		test.stopTest();
	}
}