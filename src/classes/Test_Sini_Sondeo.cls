/**
 * Clase de Test de la Clase controladora Sini_Sondeo
 *
*/
@isTest
public without sharing class Test_Sini_Sondeo extends TestSetup{

	private static Account compania1 {get; set;}
	private static Account compania2 {get; set;}
	private static Tipo_Producto_CIA__c tipoProdCIA1 {get; set;}
	private static Producto_CIA__c prodCIA1 {get; set;}
	private static ServiceContract poliza1 {get; set;}
	private static Version_ContratoServicio__c versionPoliza1 {get; set;}
	private static Case casoSini1 {get; set;}
	private static Perjudicado_Siniestro__c perjudicado {get; set;}
	private static Arbol_Decision__c arbol {get; set;}
	private static Arbol_Decision_Lineas__c arbolLinea {get; set;}
	private static Confirmacion__c confirmacion {get; set;}
	private static Garantia__c garantia1 {get; set;}
	private static Garantia_Poliza__c garPoliza1 {get; set;}


	/**
	 * Inicialización de objetos.
	 */
	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		compania1 = Util_Tests.crearCuentaCompania('compania','1018','X1234567X');
		insert compania1;
		compania2 = Util_Tests.crearCuentaCompania('SegurCaixa', '1019','X1111111X');
		insert compania2;
		tipoProdCIA1 = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania2.Id);
		insert tipoProdCIA1;
		prodCIA1 = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProdCIA1.Id);
		insert prodCIA1;
		poliza1 = Util_Tests.crearPolizaContrato('2277393',compania1.id,compania2.id,prodCIA1.id);
		insert poliza1;
		versionPoliza1 = new Version_ContratoServicio__c();
		versionPoliza1.POLV_SEL_Tipo_Riesgo__c = 'COMERCIO';
		versionPoliza1.polv_lkp_polizacontrato__c = poliza1.Id;
		versionPoliza1.polv_dat_fechainicio__c = Date.newInstance(2018, 5, 6).addDays(2);
		insert versionPoliza1;
		casoSini1 = Util_Tests.crearCasoSini(poliza1.Id,compania1.Id,compania2.Id);
		casoSini1.CAS_LKP_VersionPolizaContrato__c = versionPoliza1.Id;
		casoSini1.CAS_SEL_Grupo_Causa__c = '01';
		casoSini1.CAS_CAS_Danos_Perjudicado__c = true;
		casoSini1.CAS_CAS_Danos_Propios__c = true;
		insert casoSini1;
		confirmacion = new Confirmacion__c();
		confirmacion.cnf_lkp_parentid__c = casoSini1.Id;
		confirmacion.CNF_SEL_Grupo_Causa__c = '01';
		confirmacion.CNF_SEL_Detalle_Averia__c = '001;128';
		confirmacion.CNF_SEL_Tipo_Averia__c = '001;050';
		confirmacion.CNF_SEL_Tipo__c = Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL;
		confirmacion.CNF_NUM_Id_Actuacion_SondeoExt__c = 1;
		insert confirmacion;
		arbol = new Arbol_Decision__c();
		arbol.ADC_SEL_Estado__c = 'Activo';
		arbol.ADC_LKP_Producto_CIA__c = prodCIA1.Id;
		arbol.adc_num_version__c = 1;
		insert arbol;
		arbolLinea = new Arbol_Decision_Lineas__c();
		arbolLinea.ADL_SEL_E_Tipo_Riesgo__c = versionPoliza1.POLV_SEL_Tipo_Riesgo__c;
		arbolLinea.adl_lkp_arbol_decision__c = arbol.Id;
		arbolLinea.ADL_SEL_S_Tipo_Actuacion__c = Label.CAS_TIPO_REPARABLE;
		arbolLinea.ADL_SEL_E_Tipo_Averia__c = confirmacion.CNF_SEL_Tipo_Averia__c;
		arbolLinea.ADL_SEL_E_Detalle_Averia__c = confirmacion.CNF_SEL_Detalle_Averia__c;
		arbolLinea.ADL_SEL_E_Danos_Perjudicados__c = 'SI';
		arbolLinea.ADL_SEL_E_Situacion_Danos_Perjud__c = 'ACUARIOS';
		arbolLinea.ADL_SEL_E_Causa_Averia__c = null;
		arbolLinea.ADL_SEL_E_Otros_Danos_Perjudicados__c = 'OTROS DAÑOS PERJUDICADO';
		arbolLinea.ADL_SEL_S_Tipo_Actuacion_Mult__c = null;
		arbolLinea.ADL_TXT_S_Garantia_RC__c = null;
		arbolLinea.ADL_TXT_S_Garantias_Piden_Perito__c = null;
		arbolLinea.ADL_SEL_E_Danos_Propios__c = 'NO';
		arbolLinea.ADL_TXT_S_Garantias__c = '1234';
		arbolLinea.ADL_TXT_S_Com_Auto_Lim_Cobertura__c = '1';
		arbolLinea.ADL_DIV_S_Franquicia_Fija__c = 5;
		arbolLinea.ADL_POR_S_Franquicia__c = 2;
		insert arbolLinea;
		perjudicado = new Perjudicado_Siniestro__c();
		perjudicado.PRJ_LKP_Siniestro__c = confirmacion.CNF_LKP_ParentId__c;
		insert perjudicado;
		garantia1 = new Garantia__c();
		garantia1.GAR_TXT_Codigo_Garantia__c = '1234';
		insert garantia1;
		garPoliza1 = new Garantia_Poliza__c();
		garPoliza1.GPOL_LKP_VersionPolizaContrato__c = versionPoliza1.Id;
		garPoliza1.GPOL_LKP_Garantia__c = garantia1.Id;
		insert garPoliza1;
		Baipas.deshabilitarVariableControl();
	}

	@isTest static void testSondeoConDaniosPropios(){
		inicializarVariables();
		Test.startTest();
		ServiceContract poliza = getServiceContractByName('2277393');
		system.debug('<<<<entrando enlazar');
		enlazarProducto(poliza);
		ApexPages.StandardController stdc = new ApexPages.StandardController(confirmacion);
		SiniSondeoController prueba = new SiniSondeoController(stdc);
		prueba.lineaSalida = arbolLinea;
		prueba.obtenerSalida();
		prueba.crearPerjudicado();
		prueba.nuevoPerjudicado.PRJ_TXT_Codigo_Postal__c = '28802';
		prueba.cargarListaPoblacionPorCPPerjudicado();
		prueba.continuar_paso2();
		Test.stopTest();
	}
	@isTest static void testSondeoPerjudicados(){
		inicializarVariables();
		ServiceContract poliza = getServiceContractByName('2277393');
		enlazarProducto(poliza);
		enlazarPerjudicado(casoSini1);
		ApexPages.StandardController stdc = new ApexPages.StandardController(confirmacion);
		Test.startTest();
		SiniSondeoController prueba = new SiniSondeoController(stdc);
		Test.stopTest();
		prueba.crearPerjudicado();
		prueba.nuevoPerjudicado.PRJ_SEL_Tipo_Perjudicado__c = '02';
		prueba.nuevoPerjudicado.PRJ_TXT_Nombre__c = 'Ruben';
		prueba.nuevoPerjudicado.PRJ_TXT_Direccion__c = 'Vallecas';
		prueba.nuevoPerjudicado.PRJ_TXT_Codigo_Postal__c = '28802';
		prueba.nuevoPerjudicado.PRJ_TXT_Poblacion__c = 'Val';
		prueba.nuevoPerjudicado.PRJ_SEL_Provincia__c = 'Madrid';
		prueba.nuevoPerjudicado.PRJ_TXT_Perjudicado_N_Documento__c = '53543456T';
		prueba.nuevoPerjudicado.PRJ_TFN_Telefono_1__c = '914568456';
		prueba.nuevoPerjudicado.PRJ_SEL_Situacion_Danos__c = 'TECHO';
		prueba.nuevoPerjudicado.PRJ_TFN_Movil__c = '685456776';
		prueba.guardarPerjudicado();
		prueba.indiceListaPerjudicados = 0;
		prueba.editarPerjudicado();
		prueba.guardarPerjudicado();
		prueba.eliminarPerjudicado();
		prueba.cancelarCreacionPerjudicado();
	}

	@isTest static void testIfGCausasSelectOptions(){
		inicializarVariables();
		Test.startTest();
		ServiceContract poliza = getServiceContractByName('2277393');
		enlazarProducto(poliza);
		ApexPages.StandardController stdc = new ApexPages.StandardController(confirmacion);
		SiniSondeoController prueba = new SiniSondeoController(stdc);
		prueba.grupoCausas = confirmacion.CNF_SEL_Grupo_Causa__c;
		prueba.cambioGrCausas();
		prueba.tipoAveria = confirmacion.CNF_SEL_Tipo_Averia__c;
		prueba.cambioTipoAveria();
		prueba.detalleAveria = confirmacion.CNF_SEL_Detalle_Averia__c;
		prueba.cambioDetalleAveria();
		prueba.cargarListaPoblacionPorCPCausante();
		prueba.esProfValido();
		prueba.recogerValoresDisponibles('CNF_SEL_Situacion_Danos_Propios__c', confirmacion.CNF_SEL_Tipo_Averia__c, new List<SelectOption>{new SelectOption('', 'ACCESO Y/O DAÑOS PROVOCADOS POR OCUPAS'),new SelectOption('', 'ATASCO')});
		Test.stopTest();
	}

	// ELIMINAR TODOS LOS MÉTODOS PRIVADOS DE A CONTINUACIÓN Y USAR EN SU LUGAR LAS LLAMADAS DE UTIL_TESTS:
	// =============================================================================================================
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
	//Id,CAS_LKP_PolizaContrato__c,AccountId,CAS_LKP_Compania__c,Origin,CAS_TXT_Persona_que_llama__c
	//,RecordTypeId,status,CAS_SEL_Motivo_No_Apertura__c,CAS_SEL_Tipo_Interlocutor__c
	private static void enlazarPerjudicado(Case caso){
		List<Perjudicado_Siniestro__c>	siniestros = new List <Perjudicado_Siniestro__c>([select Id,PRJ_LKP_Siniestro__c from Perjudicado_Siniestro__c limit 1]);
		if(!siniestros.isEmpty()){
			Perjudicado_Siniestro__c siniestro = siniestros.get(0);
			siniestro.PRJ_LKP_Siniestro__c = caso.Id;
			update siniestro;
		}

	}

	private static void enlazarProducto (ServiceContract poliza){
		system.debug('<<<<dentro enlazar');
		List<Producto_CIA__c> productos = new List<Producto_CIA__c>([select Id from Producto_CIA__c where Name = 'KIT 107']);
		system.debug('<<<<productos'+productos);
		if (!productos.isEmpty()){
			Producto_CIA__c obj = productos.get(0);
			system.debug('<<<<productocreado '+obj);
			List<Arbol_Decision__c> arboles = new List<Arbol_Decision__c>([select Id, ADC_LKP_Producto_CIA__c from Arbol_Decision__c where ADC_SEL_Estado__c = 'Activo']);
			Arbol_Decision__c arb = arboles.get(0);
			poliza.POL_LKP_Producto_Cia__c = obj.Id;
			arb.ADC_LKP_Producto_CIA__c = obj.Id;
			//caso.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c = obj.Id;
			system.debug('<<<<arbol actualizad '+arb);
			update arb;
			update poliza;
			//update caso;
		}
	}

	private static Case getCaseById(Id id){
		Case caso;
		List<Case> listaCasos = new List<Case>([Select Id,
								CAS_LKP_PolizaContrato__c,
								CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c,
								AccountId,
								CAS_LKP_Compania__c,
								Origin,
								CAS_SEL_Situacion_Danos_Propios__c,
								CAS_SEL_Causa_Averia__c,
								CAS_TXT_Sondeo_Causa__c,
								CAS_SEL_Grupo_Causa__c,
								CAS_SEL_Detalle_Averia__c,
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