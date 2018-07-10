@isTest
public without sharing class Test_PDF_RechazoAlbaran {

    private static Case casoB2B;
	private static Case casoSini;
	private static WorkOrder ordTbj;
    
    private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
		Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('SEGURCAIXA - Hogar', '01', compania.Id);
		insert tipoProducto;
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('Segurcaixa - HOGAR', '01', tipoProducto.Id);
		insert producto;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('02277393', compania.Id, null,producto.Id);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.00, 0, 1, 0, 0, compania.Id, '1620334609050', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_Anulacion__c = '02;03';
		procedencia.PROC_CAS_No_Requiere_Albaran__c = true;
		insert procedencia;
		casoB2B = Util_Tests.crearCasoB2B(poliza.Id, compania.Id, compania.Id);
		casoB2B.CAS_LKP_Procedencia__c = procedencia.Id;
		casoSini = Util_Tests.crearCasoSini(poliza.Id,compania.Id,compania.Id);
		casoSini.CAS_LKP_Procedencia__c = procedencia.Id;
		insert casoB2B;
		insert casoSini;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Aplicación de estetica', '02', 120.00);
		insert tipoTrabajo;
		ordTbj = Util_Tests.crearOrdenTrabajo('0010100244', '02', tipoTrabajo.Id, casoB2B.Id);
		ordTbj.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbj.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
		insert ordTbj;
		
	}
    
    static testMethod void PDF_RechazoAlbaran(){
        inicializarVariables();
        ApexPages.currentPage().getParameters().put('id',ordTbj.Id);
        PDF_RechazoAlbaran pdf = new PDF_RechazoAlbaran();
       
    }
    
}