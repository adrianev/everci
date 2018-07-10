/**
 * Clase de Test de la Clase controladora Sini_Sondeo
 * 
*/
@isTest
public without sharing class Test_Sini_Indemn_Partidas/* extends TestSetup*/{ 
	private static ServiceContract NuevaPoliza{get; set;}
	private static Case Nuevocaso {get; set;}
	public static SiniIndemnDocumentosController siniDocumentos  {get; set;}
	private static Account compania {get; set;}
	private static Account cuenta {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Tipo_Producto_CIA__c  tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static WorkOrder OrdenTrabajo {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static Indemnizable_Documento__c documentoIndem {get; set;}
	
	
	/**
	* Este metodo se encarga de realizar la carga de datos de static resources
	* 
	*/
	
	/*
	@testSetup
	public static void test(){
		TestSetup loadData = new Test_Sini_Indemn_Partidas();
		loadData.setTestData();
	}
	*/

	public static void InicializarVariables(){
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
		compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		NuevaPoliza = Util_Tests.crearPolizaContrato('4523814',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
		insert NuevaPoliza;
		Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
		insert Nuevocaso;
		Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',cuenta.Id);
		//cuentaProfesional.CUE_SEL_Estado__c = '02';
		cuentaProfesional.CUE_LKP_Cuenta_principal__c = Null;
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
		insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		update cuentaProfesional;
		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuario;
		Account cuentaProfUp = [SELECT Id, Name, CUE_TXT_Identificador__c FROM Account WHERE Id=: cuentaProfesional.Id];
		Profesional_Gremio__c profGrem = new Profesional_Gremio__c();
		profGrem.PRG_LKP_Cuenta_Profesional__c = cuentaProfUp.Id;
		profGrem.PRG_TXT_Identificador__c='j40dg49alnf194j';
		profGrem.PRG_NUM_Lim_OT_en_Curso__c=2;
		profGrem.PRG_SEL_Gremio__c = '01';
		profGrem.Name = cuentaProfUp.CUE_TXT_Identificador__c+'_'+profGrem.PRG_SEL_Gremio__c;
		insert profGrem;
		ServiceResource sr = Util_Tests.crearRecursoServicio('David','Estanislao',cuentaProfUp.Id,usuario);
		sr.RSE_SEL_Gremio__c = '01';
		sr.Name = cuentaProfUp.CUE_TXT_Identificador__c + '_01_1';
		sr.RSE_LKP_Profesional_Gremio__c = profGrem.Id;
		insert sr;
								//Crear Worktype
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		 						//Crear WorkOrder//
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,Nuevocaso.Id);
		ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		ordenTrabajo.OTR_DAT_Fecha_cambio_estado__c = system.now();
		ordenTrabajo.OTR_NUM_Horas_verde__c = 0;
		ordenTrabajo.OTR_NUM_Horas_amarillo__c = 0;
		ordenTrabajo.AccountId = cuenta.Id;
		//ordenTrabajo.Status = '999';
		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = sr.Id;
		insert ordenTrabajo;
		
		documentoIndem = new Indemnizable_Documento__c();
		documentoIndem.IND_SEL_Estado__c = 	'001';
		documentoIndem.IND_LKP_Caso__c = Nuevocaso.Id;
		documentoIndem.IND_SEL_Tipo_Documento__c = '02';
		documentoIndem.IND_TXT_Descripcion__c = ' Indemnizacion de IronHackers ';
		insert documentoIndem;
		Baipas.deshabilitarVariableControl();
	}
	
	
	@isTest static void testSini_Indemn_Partidas(){
		InicializarVariables();
		PageReference pageRef = Page.Sini_TipoInterlocutor;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('retorno','1018');
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('fase','1018');
		ServiceContract poliza = getServiceContractByName(NuevaPoliza.Name);
		Case caso = getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('id',caso.id);
		ApexPages.currentPage().getParameters().put('idPoliza',poliza.Id);
		WorkOrder workOrder = getWorkOrderByPolidaId(caso.Id); 
		ApexPages.currentPage().getParameters().put('idOrdenTrabajo',workOrder.Id);
		ApexPages.currentPage().getParameters().put('idDocIndemnizable',documentoIndem.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		Test.startTest();
		SiniIndemnPartidasController siniIndemnPartidas = new SiniIndemnPartidasController(stdc);
		siniIndemnPartidas.indiceListaItems = 0;
		// siniIndemnPartidas.nuevoItem = new Indemnizable_Partida__c();
		
		/*
		Indemnizable_Partida__c indemen= new Indemnizable_Partida__c();
		indemen.INDP_SEL_Estado__c = '01';
		indemen.INDP_DIV_Importe__c = 100;
		indemen.INDP_LKP_Documento_Indemnizable__c = documentoIndem.Id;
		indemen.INDP_TXT_Descripcion__c = ' Indemnizacion de IronHackers ';  
		insert indemen;
		*/
		//siniIndemnPartidas.listaItems.add(indemen);

		siniIndemnPartidas.crearItem();
		siniIndemnPartidas.nuevoItem.INDP_TXT_Descripcion__c = 'IronHackers';
		siniIndemnPartidas.guardarItem();
		siniIndemnPartidas.cancelarCreacionItem();
		siniIndemnPartidas.volver();
		siniIndemnPartidas.indiceListaItems=0;
		siniIndemnPartidas.seleccionarItem();
		siniIndemnPartidas.actualizarItem();
		//siniIndemnPartidas.indiceListaItems=1;  
		//siniIndemnPartidas.eliminarItem();
	Test.stopTest();
	}

	private static WorkOrder getWorkOrderByPolidaId(Id idPoliza){
		 WorkOrder workOrder;
		
		List<WorkOrder> listaWorkOrder = new List<WorkOrder>([Select Id,
								OTR_TXT_Num_OrdenTrabajo_HS__c,
								CaseId
								FROM WorkOrder Where CaseId = :idPoliza LIMIT 1]);
								
		if(!listaWorkOrder.isEmpty()){
			workOrder = listaWorkOrder.get(0);
		}else{
			throw new TestException('No existen WorkOrders con la id de poliza especificado');
		}

		return workOrder;
	}

	private static ServiceContract getServiceContractByName(String name){
		ServiceContract poliza;
		
		List<ServiceContract> listaPolizas = new List<ServiceContract>([Select Id,
								POL_LKP_Compania__r.Name,
								POL_LKP_Compania__r.CUE_EMA_Email__c,
								AccountId,
								Account.Name,
								POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Autorizados__c
								FROM ServiceContract Where Name = :name LIMIT 1]);
								
		if(!listaPolizas.isEmpty()){
			poliza = listaPolizas.get(0);
		}else{
			throw new TestException('No existen polizas/contratos con el nombre especificado');
		}

		return poliza;
	}

  private static Case getCaseById(Id id){
		Case caso;
		
		List<Case> listaCasos = new List<Case>([Select Id,			
								CAS_LKP_PolizaContrato__c,
								AccountId,
								CAS_LKP_Compania__c,
								Origin,
								CAS_TXT_Persona_que_llama__c,
								RecordTypeId,
								status,
								CAS_SEL_Motivo_No_Apertura__c,
								CAS_SEL_Tipo_Interlocutor__c
								FROM Case Where CAS_LKP_PolizaContrato__c = :id LIMIT 1]);
								
		if(!listaCasos.isEmpty()){
			caso = listaCasos.get(0);
		}else{
			throw new TestException('No existen casos con el nombre especificado');
		}

		return caso;
	}
}