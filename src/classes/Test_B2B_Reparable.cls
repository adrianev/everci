@isTest
public without sharing class Test_B2B_Reparable{
	private static B2B_Reparable b2bReparable  {get; set;}
	private static PageReference pageRef {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Account compania {get; set;}
	private static Account b2b_1 {get; set;}
	private static Account b2b_2 {get; set;}
    private static Account b2b_3 {get; set;}
    private static WorkOrder ordenTrabajo {get; set;}
    private static Case caso {get; set;}

	
	
	private static void test(){
		/*TestSetup loadData = new Test_B2B_Reparable();
		loadData.setTestData();*/
		Baipas.establecerVariableControl();
		system.debug('PERFIL COMUNIDAD'+Label.PERFIL_COMUNIDAD);
		compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
		b2b_1 = Util_Tests.crearCuentaB2BPpal('Manolo', '2018','X1134567X');
		insert b2b_1;
		b2b_2 = Util_Tests.crearCuentaB2BSec('Paco', '3018',b2b_1.Id,'X1114567X');
		insert b2b_2;
		Date startDate = Date.newInstance(2016, 12, 31);
		poliza = Util_Tests.crearPolizaContrato('9729187', compania.Id, b2b_2.Id, null);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,compania.Id,'101801','CAS_Servicio_B2B_B2B2C');
		insert procedencia;
		caso = Util_Tests.crearCasoB2B(poliza.Id, b2b_2.Id, compania.Id);
		insert caso;
		Contract contrato = Util_Tests.crearContrato(b2b_2.Id,'contrato');
		insert contrato;
		Linea_Contrato__c lineaCon = Util_Tests.crearLineaContrato(contrato.Id,3,'21', Label.RT_LIN_CON_CORRECTIVO);
		insert lineaCon;
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccion = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(b2b_2.Id, lineaCon.Id, 3);
		insert direccion;
		Presupuesto__c presupuesto = Util_Tests.crearPresupuesto('100', caso.Id,1);
		insert presupuesto;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '21', 20.0);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19410.0', '21', tipoTrabajo.Id, caso.Id);
		ordenTrabajo.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;
		Date primeraCita = Date.newInstance(2018, 12, 31);
		ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c = primeraCita;
		ordenTrabajo.OTR_CAS_Urgente__c = false;
		ordenTrabajo.AccountId = b2b_2.Id;
		insert ordenTrabajo;
        
      
		datetime fechaInicio = datetime.newInstance(2018, 12, 31);
		datetime fechaVencimiento = datetime.newInstance(2019, 12, 31);
		ServiceAppointment citaServicio = Util_Tests.crearCitaServicio('Madrid', 'Espana', '28000', 'Espana', 'Virgen de la Cabeza', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Asignada';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
        
  
		caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
		caso.CAS_CAS_Supera_Limite_Actuacion__c = true;
		caso.Type = Label.B2B_TIPO_CORRECTIVO;
		update caso;
		Comentario_caso__c comentarioCaso = Util_Tests.crearComentarioCaso('comentario de caso para test', caso.Id);
		insert comentarioCaso;
		Comentario_Orden_de_Trabajo__c comentarioOT= Util_Tests.crearComentarioOT('comentario de Orden Trabajo para test', ordenTrabajo.Id);
		insert comentarioOT;
		FSL__Scheduling_Policy__c politicaGeo = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		insert politicaGeo;
     
		Contact contacto = Util_Tests.crearContacto('Miguel', 'Sagrado');
		contacto.CON_TXT_Identificador__c = '00000';
		contacto.CON_SEL_Tipo_Programa__c = Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO;
		contacto.AccountId = compania.Id;
		contacto.Email = 'miguel@gmail.es';
		insert contacto;
		Buzon_CIA__c buzon = new Buzon_CIA__c();
		buzon.BUZ_LKP_Cuenta__c = compania.Id;
		buzon.BUZ_EMA_Direccion__c = 'miguel@gmail.es';
		buzon.BUZ_SEL_Tipo_Programa__c = Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO;
		insert buzon;

		Baipas.deshabilitarVariableControl();
	}

	// El usuario pulsa el botón de eliminar el segundo item, inserta un comentario en la OT principal y finaliza el proceso
	@isTest static void testEliminarOrdenFinalizar(){
        Test();
		eliminarOrdenFinalizar(false);
	}

	@isTest static void testEliminarOrdenCorreo(){
        Test();
		eliminarOrdenFinalizar(true);
	}


	// El usuario inserta un nuevo comentario en el caso
	@isTest static void testNuevoComentarioCaso(){
        Test();
		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		ServiceContract poliza = Util_Tests.getServiceContractByName('9729187');
		Case caso = Util_Tests.getCaseById(poliza.Id);
		parametizarPagina(caso.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		Test.startTest();
		b2bReparable = new B2B_Reparable(stdc);
		b2bReparable.nuevoComentCaso.comentarioCaso.CMC_TXT_Comentario__c = 'Comentario de prueba para caso';
		b2bReparable.insertarComentarioCaso();
		Test.stopTest();
	}

	// El usuario accede a la pantalla de actualizar partidas
	@isTest static void testActualizarPartidas(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.actualizarPartidas();
		Test.stopTest();
	}

	// El usuario simula CPQ acceso a la pantalla de actualizar partidas
	@isTest static void testActualizarPartidasCPQ(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.actualizarPartidas_CPQSimulado();
		Test.stopTest();
	}

	// El usuario accede a la pantalla de habilidades requeridas
	@isTest static void testHabilidadesRequeridas(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.HabilidadesRequeridas();
		Test.stopTest();
	}

	// El usuario accede a la pantalla de reservar cita
	@isTest static void testReservarCita(){
        Test();
		crearPagina();
		b2bReparable.indiceListaItems = 1;
		b2bReparable.reservarCita();
		b2breparable.cambiarCita();

		b2bReparable.caso.CAS_CAS_Supera_Limite_Actuacion__c=false;

		b2bReparable.superaLimiteActuacion=false;

		b2breparable.caso.CAS_CAS_Generar_Presupuesto__c=false;
		update b2breparable.caso;

		b2bReparable.generarPresupuesto=false;

		b2bReparable.reservarCita();

		b2bReparable.listaItems=new List<WorkOrder>();

		b2bReparable.esB2C=true;

		WorkOrder wo = new WorkOrder();
		wo.City = 'Madrid';
		wo.StartDate = system.now();
		wo.Duration = 2.0;
		wo.DurationType = 'Hours';
		wo.Latitude = 40.48023673004623;
		wo.Longitude = -3.6690412312805356;
		wo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815917';
		wo.CreatedDate = system.now();
		wo.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo.OTR_SEL_Rango_Primera_Cita__c = '07';
        wo.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';
		insert wo;
	
		b2breparable.listaItems.add(wo);
		b2breparable.reservarCita();		
	}
    
	@isTest static void testSolicitarPresupuesto(){
        Test();
		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		crearPoliza();
		b2bReparable.nuevoPresupuesto();
		Test.stopTest();
	}
	
	// El usuario ve el ultimo presupuesto
	@isTest static void testVerUltimoPresupuesto(){
        Test();
		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		crearPoliza();
		b2bReparable.verUltimoPresupuesto();
		Test.stopTest();
	}

	// El usuario desea vincular un cliente
	@isTest static void testvincularCliente(){
        Test();
		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		crearPoliza();
		b2bReparable.vincularCliente();
		Test.stopTest();
	}

	// El usuario sale del proceso
	@isTest static void testSalir(){
        Test();
		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ServiceContract poliza = Util_Tests.getServiceContractByName('9729187');
		Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('solicitudExistente','Y');
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('guardadoOK','OK');
		ApexPages.currentPage().getParameters().put('presuAceptado','Y');
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		b2bReparable = new B2B_Reparable(stdc);
		b2bReparable.salir();
		Test.stopTest();
	}

	// El usuario desea vincular la línea de contrato a una OT
	@isTest static void testvincularLCaOT(){
        Test();
		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		crearPoliza();
		b2bReparable.indiceListaItems = 1;
		WorkOrder ordenTrabajo = getWorkOrderByTXT('19410.0');
		b2bReparable.idOrdenTrabajo = ordenTrabajo.Id;
		b2bReparable.vincularLCaOT();
		Test.stopTest();
	}

	// El usuario desea anular una OT
	@isTest static void testAnularOT(){
        Test();
		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		crearPoliza();
		b2bReparable.indiceListaItems = 2;
		WorkOrder ordenTrabajo = getWorkOrderByTXT('19410.0');
		b2bReparable.idOrdenTrabajo = ordenTrabajo.Id;
		b2bReparable.anularOrdenDeTrabajo();
		Test.stopTest();
	}

	// El usuario desea cerrar una OT
	@isTest static void testCerrarOT(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.indiceListaItems = 2;
		b2bReparable.cerrarOrdenDeTrabajo();
		Test.stopTest();
	}
	
	// El usuario desea cambiar el estado de una OT
	@isTest static void testCambiarEstadoOrdenDeTrabajo(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.cambiarEstadoOrdenDeTrabajo();
		Test.stopTest();
	}
	
	// El usuario desea dormir una OT
	@isTest static void testDormirOrdenDeTrabajo(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.dormirOrdenDeTrabajo();
		Test.stopTest();
	}
	
	// El usuario desea hacer una OT la principal del caso
	@isTest static void testHacerOrdenTrabajoPrincipal(){
        Test();
		Test.startTest();
		crearPagina();
        
     
		b2bReparable.indiceListaItems = 1;
		b2bReparable.hacerOrdenTrabajoPrincipal();
		Test.stopTest();
	}
    

	// El usuario desea solicitar autorizacion a CIA
	@isTest static void testSolicitarAutorizacionCIA(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.solicitarAutorizacionCIA();
		Test.stopTest();
	}
	
	// El usuario desea solicitar autorizacion a CIA
	/*@isTest static void testSolicitarAutorizacionGestor(){
		
		crearPagina();
		b2bReparable.solicitarAutorizacionGestor();
		Test.stopTest();
	}*/
	
	// El usuario desea generar  un PDF con el presupuesto actual
	/*@isTest static void testGenerarPDFPresupuestoActual(){
        Test();
		Test.startTest();
		crearPagina();
        b2bReparable.solicitarAutorizacionCIA();
		b2bReparable.generarPDFPresupuestoActual();
        //b2bReparable.generarPDFyEnviar();
		Test.stopTest();
	}*/
	
	// El usuario desea guardar los cambios
	@isTest static void testGuardarCambios(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.guardarCambios();
		Test.stopTest();
	}
	
	// El usuario desea crear un nuevo gremio
	@isTest static void testNuevoGremio(){
        Test();
		Test.startTest();
		crearPagina();
		b2bReparable.nuevoGremio();
		Test.stopTest();
	}
    
 	@isTest static void testEliminarCaso(){
        Test();
		Test.startTest();
        crearPoliza();
        b2bReparable.salir();
		Test.stopTest();
	}
    
     	@isTest static void EsProfesional(){
      	test();
            

		b2b_3 = Util_Tests.crearCuentaB2BPpal('Carlos', '2017','X1234567X');
		insert b2b_3;
		crearPagina();
       
		b2bReparable.indiceListaItems = 1;
       
		//b2bReparable.reservarCita();
		
		//b2bReparable.caso.CAS_CAS_Supera_Limite_Actuacion__c=false;

		//b2bReparable.superaLimiteActuacion=false;

		//b2breparable.caso.CAS_CAS_Generar_Presupuesto__c=false;
        b2breparable.caso.AccountId = b2b_3.Id;
        //b2breparable.caso.CAS_LKP_Compania__c = compania.Id;
        Baipas.establecerVariableControl();
		update b2breparable.caso;
		Baipas.deshabilitarVariableControl();

		//b2bReparable.generarPresupuesto=false;

		//b2bReparable.reservarCita();

		//b2bReparable.listaItems=new List<WorkOrder>();

		//b2bReparable.esB2C=true;
		ordenTrabajo.Case = b2bReparable.caso;
        ordenTrabajo.OTR_CAS_Urgente__c = True;
        ordenTrabajo.PostalCode = '28000';
            
        Baipas.establecerVariableControl();
        upsert ordenTrabajo;
		Baipas.deshabilitarVariableControl();

		//update ordenTrabajo;
		system.debug(caso + 'casoooooo');
		system.debug(ordenTrabajo +  ' ordenTrabajo' );
        system.debug(caso.AccountId +  ' casoCuenta' );
            
      

		//b2breparable.listaItems.add(ordenTrabajo);
		b2breparable.cambiarCita();
		b2breparable.reservarCita();		
		system.debug(ordenTrabajo +  ' ordenTrabajo1' );
		
	}
  



	private static WorkOrder getWorkOrderByTXT(String txt){
		WorkOrder orden;

		List<WorkOrder> listaOrdenes = new List<WorkOrder>([Select Id,
		                                                    OTR_TXT_Num_OrdenTrabajo_HS__c,
		                                                    CaseId
		                                                    FROM WorkOrder Where OTR_TXT_Num_OrdenTrabajo_HS__c = :txt LIMIT 1]);

		if(!listaOrdenes.isEmpty()){
			orden = listaOrdenes.get(0);
		}else{
			throw new TestException('No existen órdenes de trabajo con el nombre especificado');
		}

		return orden;
	}

	private static void crearPagina(){
		pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);
		crearPoliza();
		WorkOrder ordenTrabajo = getWorkOrderByTXT('19410.0');
		b2bReparable.idOrdenTrabajo = ordenTrabajo.Id;
        ordenTrabajo.OTR_CAS_Urgente__c = true;
	}

	private static void parametizarPagina(ID casoId){
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('solicitudExistente','N');
		ApexPages.currentPage().getParameters().put('id',casoId);
		ApexPages.currentPage().getParameters().put('guardadoOK','OK');
		ApexPages.currentPage().getParameters().put('presuAceptado','Y');
	}

	private static void crearPoliza(){
		poliza = Util_Tests.getServiceContractByName('9729187');
		Case caso = Util_Tests.getCaseById(poliza.Id);
		parametizarPagina(caso.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		b2bReparable = new B2B_Reparable(stdc);
	}

	private static void eliminarOrdenFinalizar(boolean enviarCorreo){
	
		Test.startTest();

		PageReference pageRef = Page.B2B_Reparable;
		Test.setCurrentPage(pageRef);

		ServiceContract poliza = Util_Tests.getServiceContractByName('9729187');
		Case caso = Util_Tests.getCaseById(poliza.Id);

		if(enviarCorreo){
			/*compania = Util_Tests.crearCuentaCompania('SegurCaixa', Label.IDE_WORTEN,'X1234588X');
			insert compania;
			system.debug('compania CUE TXT Identificador  c: ' + compania.CUE_TXT_Identificador__c);
			system.debug('ASOCIADOS '+[SELECT ID, CUE_TXT_Identificador__c FROM Account Where ID = :caso.CAS_LKP_Compania__r.Id]);*/


			Account cuentaPrincipal= Util_Tests.crearCuentaB2BPpal('Perico', Label.IDE_WORTEN,'X1434862X');
			insert cuentaPrincipal;


			caso.CAS_LKP_Compania__c=cuentaPrincipal.Id;
			caso.CAS_LKP_Compania__r=cuentaPrincipal;
			Baremo__c baremo=new Baremo__c();
			baremo.BAR_LKP_Compania__c=cuentaPrincipal.Id;
			insert baremo;
			caso.CAS_LKP_Baremo__c=baremo.Id;
			caso.CAS_LKP_Baremo__r=baremo;

			List<RecordType> recordTypes=[SELECT ID, Name FROM RecordType WHERE Name = 'Cliente B2B/B2B2C secundario'];


			
			/*Account cuentaSecundaria= Util_Tests.crearCuentaB2BSec('Hola', '2099',cuentaPrincipal.Id,'X1119567X');
			insert cuentaSecundaria;*/

			Account puntoDeVenta=new Account();
			puntoDeVenta.Name='Manolico';
			puntoDeVenta.CUE_TXT_Numero_Documento__c='11223344B';
			puntoDeVenta.CUE_SEL_Tipo_Documento__c= 'P';
			puntoDeVenta.Type= '01';

			puntoDeVenta.RecordType=recordTypes.get(0);
			puntoDeVenta.RecordTypeId=recordTypes.get(0).Id;
			puntoDeVenta.CUE_LKP_Cuenta_principal__r = cuentaPrincipal;
			puntoDeVenta.CUE_LKP_Cuenta_principal__c = cuentaPrincipal.Id;

			insert puntoDeVenta;

			caso.CAS_LKP_Punto_de_venta__c=puntoDeVenta.Id;
			caso.CAS_LKP_Punto_de_venta__r=puntoDeVenta;

			update caso;
            

			system.debug('caso CAS LKP Compania r CUE TXT Identificador c' + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c);

			system.debug('ASOCIADOS '+[SELECT ID, CUE_TXT_Identificador__c FROM Account Where ID = :caso.CAS_LKP_Compania__r.Id]);

			system.debug('CUENTA 1 '+Label.IDE_WORTEN);
			system.debug('CUENTA 2 '+compania);
			system.debug('CUENTA 3 '+caso.CAS_LKP_Compania__r); //Estos 2 son distintos?
			system.debug('CUENTA 3 '+[SELECT ID, CUE_TXT_Identificador__c FROM Account Where ID = :caso.CAS_LKP_Compania__r.Id]);
			system.debug('COMPANIA 1'+caso);
		}
        
            


		parametizarPagina(caso.Id);

		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		b2bReparable = new B2B_Reparable(stdc);
		//b2bReparable.indiceListaItems = 2;
		//b2bReparable.eliminarItem();

		WorkOrder ordenTrabajo = getWorkOrderByTXT('19410.0');

		b2bReparable.idOrdenTrabajo = ordenTrabajo.Id;
		b2bReparable.mapaNuevoComentsOT.get(b2bReparable.idOrdenTrabajo).comentarioOT.COT_TXT_Comentario__c = 'Comentario de prueba para orden de trabajo';
		b2bReparable.insertarComentarioOT();
		caso.CAS_LKP_Orden_Trabajo_Principal__c = b2bReparable.idOrdenTrabajo;

		
		update caso;

		b2bReparable.caso.CAS_LKP_Orden_Trabajo_Principal__c = b2bReparable.idOrdenTrabajo;

		system.debug('ESTA A TRUE');
		system.debug(enviarCorreo);
		system.debug(b2bReparable.ciaWorten);

		b2bReparable.finalizarApertura();
        //b2bReparable.generarPDFyEnviar();
      
		Test.stopTest();
	}
}