@isTest
private class Test_OrdenTrabajoCustomList {

	private static Account compania;
	private static Account cuentaPrincipal;
	private static Account cuenta;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCIA;
	private static ServiceContract poliza;
	private static Case caso;
	//private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo;

	private static void inicializar() {
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1114567X');
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		//tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2.00);
		//insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2.00).id,caso.Id);
		ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		ordenTrabajo.AccountId = cuenta.Id;
		insert ordenTrabajo;
		Baipas.deshabilitarVariableControl();
	}

	@isTest static void test(){
		inicializar();
		List<WorkOrder> woList = new List<WorkOrder>();
		woList.add(ordenTrabajo);
		Test.setCurrentPage(Page.OrdenTrabajoCustomList);
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(woList);
		stdSetController.setSelected(woList);
		OrdenTrabajoCustomList ot = new OrdenTrabajoCustomList(stdSetController);
		ot.gremioSeleccionado = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.companiaSeleccionada = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.direccionTerritorialSeleccionada = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.provinciaSeleccionada = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.tipologiaDeServicioSeleccionada = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.tipoIntervencionSeleccionada = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.productoSeleccionado = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.picklistGremios = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.picklistCompanias = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.picklistNombreTipoProducto = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.picklistDireccionesTerritoriales = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.picklistProvincias = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.picklistTiposServicio = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.picklistTipoIntervencion = new List<SelectOption>{new SelectOption('','-- Ninguno --')};
		ot.recargaFiltroNuevo();
		ot.nombreVistaNueva = 'Vista Nueva';
		ot.recargaFiltroGuardar();
		ot.recargaFiltroExistente();
		ot.sigPag();
		ot.antPag();
		ot.cambioPropietario();
		ot.revisarAutomaticamente();
		ot.borrarVista();
		ot.seleccionarTodos();
	}
}