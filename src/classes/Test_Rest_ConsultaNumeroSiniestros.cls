@isTest
public without sharing class Test_Rest_ConsultaNumeroSiniestros {
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account asegurada {get; set;}
	private static Account cuenta {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get;set;}

	@isTest static void Testing() {
		Baipas.establecerVariableControl();
				
		compania = Util_Tests.crearCuentaCompania('SegurCaixa',Label.IDE_PREVISORA_BILBAINA,'X1234567X');
    	insert compania;
    	cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
    	insert cuentaPrincipal;
    	asegurada = Util_Tests.crearCuentaB2BSec('Asegurado','1020',cuentaPrincipal.Id,'X1114567X');
    	cuenta = Util_Tests.crearCuentaB2BSec('SegurCaixa1','1021',cuentaPrincipal.Id,'X1111567X');
    	tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
        insert tipoProductoCIA;
        productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;
        poliza = Util_Tests.crearPolizaContrato('2277384',compania.Id,asegurada.Id,productoCIA.Id);
        insert poliza;
        caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        caso.Type = '2';
        caso.Status = '003';
        insert caso;
        tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '51', 5.30);
        insert tipoTrabajo;
        ordenTrabajo = Util_Tests.crearOrdenTrabajo('0000000739','01',tipoTrabajo.Id,caso.Id);
        ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
        insert ordenTrabajo;
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/polizasActivasCompania';
		req.addParameter('identificadorCompania', Label.IDE_PREVISORA_BILBAINA);
		req.addParameter('fechaInicio', '12/12/2009');
		req.addParameter('fechaFin', '12/12/2020');
		req.addParameter('codigoConsulta', '1');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_ConsultaNumeroSiniestros.consultaNumSiniestros();
        
        req.addParameter('codigoConsulta', '2');
        Rest_ConsultaNumeroSiniestros.consultaNumSiniestros();
        
        compania.CUE_TXT_Identificador__c = Label.IDE_SEGURCAIXA;
        update compania;
        req.addParameter('identificadorCompania', Label.IDE_SEGURCAIXA);
        Rest_ConsultaNumeroSiniestros.consultaNumSiniestros();
	}
	
}