@isTest
public without sharing class Test_Util_Facturador {
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account cuenta {get; set;}
	private static Account cuentaContable {get; set;}
    private static Account cuentaProfesional {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static Poblacion__c poblacion {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static Contract contrato {get; set;}
	private static Linea_Contrato__c lineaContrato {get; set;}
	private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
    private static WorkOrderLineItem lineaOrdenTrabajo {get; set;}
    private static ServiceResource profesional {get; set;}
    private static User usuari {get; set;}
    private static OperatingHours horasFuncionamiento {get; set;}
    private static ServiceTerritory territorio {get; set;}
    private static List<ContentDocumentLink> listaDoc {get;set;}
    private static Account cuentaPoliza {get;set;}
    //Comentado para la subida a PRO
    private static Account propAbonoAcc{get;set;}
	private static Account cuentaTipoProducto{get;set;}
	private static Case casoClienteContable{get;set;}
	private static Case casoAbono{get;set;}
	private static WorkOrder ordenTrabajoEvento{get;set;}
	private static Propuesta_de_Abono__c propAbono {get;set;}
	private static ServiceResource recursoServ {get;set;}
	private static ServiceResource recursoServ2 {get;set;}	
	private static User usuario {get;set;}
	private static User usuario2 {get;set;}
    
    private static void inicializarVariables(){
    	Baipas.establecerVariableControl();
    	List<Account> listaCuentas = new List<Account>();
		compania = Util_Tests.crearCuentaCompania('Endesa',Label.IDE_ENDESA,'X1234567X');
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
		insert cuentaPrincipal;
        //cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('CuentaProf','1020' /*,'X1114567X'*/);
        Account cuentaProfesional = new Account();
		cuentaProfesional.Name = 'PR123456';
		cuentaProfesional.CUE_TXT_Identificador__c = 'PR123456';
		cuentaProfesional.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_PROFESIONAL_CONTRATO);
		cuentaProfesional.CUE_SEL_Tipo_Documento__c = 'C';
        cuentaProfesional.CUE_TXT_Numero_Documento__c = 'X1114567X';
        cuentaProfesional.CUE_SEL_Estado__c = '01';
        cuentaProfesional.CUE_CAS_Activado__c = false;
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        //cuentaProfesional.CUE_LKP_Cuenta_principal__c = cuentaPrincipal.Id;
		insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		update cuentaProfesional;
		
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuari;
        profesional = Util_Tests.crearRecursoServicio(cuentaProfesional.CUE_TXT_Identificador__c + '_01_1','Estanislao',cuentaProfesional.Id,usuari);
        insert profesional;
        profesional.IsActive =  true;
        update profesional;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1021',cuentaPrincipal.Id,'X1111567X');
		listaCuentas.add(compania);
		listaCuentas.add(cuenta);
		insert listaCuentas;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		/*poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;*/
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta.Id,'101801','CAS_Siniestro');
		insert procedencia;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		caso.CAS_TXT_DirRiesgo_CP__c = '28001';
		insert caso;
		update compania;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		//tipoTrabajo = Util_Tests.crearTipoTrabajo('Arregla mesa','21', 2);
		insert tipoTrabajo;
		contrato = Util_Tests.crearContrato(cuenta.Id,'b2b_p_1');
		insert contrato;
		lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,5,'21',Label.RT_LIN_CON_CORRECTIVO);
		insert lineaContrato;
		direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id,lineaContrato.Id,3);
		direccionBB_lineas.DLC_TXT_Identificador__c = cuenta.Id + '_' + lineaContrato.Id;
		insert direccionBB_lineas;
		List<FSL__Scheduling_Policy__c> listaPoliticas = new List<FSL__Scheduling_Policy__c>();
		FSL__Scheduling_Policy__c primerPoliticas = new FSL__Scheduling_Policy__c();
		primerPoliticas.Name = 'Política de Asignación – Geolocalización - Primario';
		listaPoliticas.add(primerPoliticas);
		FSL__Scheduling_Policy__c segundoPoliticas = new FSL__Scheduling_Policy__c();
		segundoPoliticas.Name = 'Política de Asignación – Geolocalización';
		listaPoliticas.add(segundoPoliticas);
		insert listaPoliticas;
		horasFuncionamiento = Util_Tests.crearHoraFuncionamiento('horaF', 'Europe/Paris');
		insert horasFuncionamiento;
		territorio = Util_Tests.crearTerritorioServicio('28001', horasFuncionamiento.Id, '28001');
		territorio.IsActive = true;
		insert territorio;
		
    }	
	@isTest static void Test(){
		inicializarVariables();
		Baipas.establecerVariableControl();
        Case casoContable = new Case();
		casoContable.AccountId = cuenta.Id;
		casoContable.CAS_LKP_Compania__c = compania.Id;
		casoContable.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(label.RT_CAS_RECLAMACION);
		casoContable.CAS_TXT_DirRiesgo_CP__c = '28001';
		insert casoContable;
        
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,casoContable.Id,profesional.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		ordentrabajo.CaseId = casoContable.Id; 
		ordentrabajo.PostalCode = '28001';
        
		//new
		ordentrabajo.OTR_LKP_Recurso_Servicio__c = profesional.Id ;
		upsert ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo;
        ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
		system.debug('ordenTrabajo '+ordenTrabajo);
        Account cuentaContable1 = Util_Tests.crearCuentaB2BSec('Asegurado','1018',cuentaPrincipal.Id,'X1111512X');
		cuentaContable1.Type = '02';
		insert cuentaContable1;
		casoContable.CAS_LKP_Cliente_contable__c = cuentaContable1.Id;	
		upsert casoContable;
		Util_Facturador.facturarCliente(ordenTrabajo.Id,label.FAC_Maestro_Clientes);
		Util_Facturador.facturarCliente(cuenta.id,label.FAC_Maestro_Clientes);
		Util_Facturador.facturarPreFactura(ordenTrabajo.id,label.FAC_PreFactura);
		Util_Facturador.facturarProfesional(ordenTrabajo.id,label.FAC_Maestro_Profesionales);
		Baipas.deshabilitarVariableControl();
	}
	@isTest static void Test1(){
		inicializarVariables();
		Baipas.establecerVariableControl();
		Case casoContable = new Case();
		casoContable.AccountId = cuenta.Id;
		casoContable.CAS_LKP_Compania__c = compania.Id;
		casoContable.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(label.RT_CAS_RECLAMACION);
		casoContable.CAS_TXT_DirRiesgo_CP__c = '28001';
		insert casoContable;
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,casoContable.Id,profesional.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		ordentrabajo.CaseId = casoContable.Id; 
		ordentrabajo.PostalCode = '28001';
		//new
		ordentrabajo.OTR_LKP_Recurso_Servicio__c = profesional.Id ;
		upsert ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo;
        ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
		cuentaContable = Util_Tests.crearCuentaB2BSec('Asegurado','1018',cuentaPrincipal.Id,'X1111512X');
		cuentaContable.Type = '02';
		insert cuentaContable;
		casoContable.CAS_LKP_Cliente_contable__c = cuentaContable.Id;	
		upsert casoContable;
		Util_Facturador.facturarCliente(ordenTrabajo.Id,label.FAC_Maestro_Clientes);
		cuenta.CUE_LKP_Cliente_contable__c = compania.Id;
		Util_Facturador.facturarCliente(cuenta.id,label.FAC_Maestro_Clientes);
		Util_Facturador.facturarPreFactura(ordenTrabajo.id,label.FAC_PreFactura);
		Util_Facturador.facturarProfesional(ordenTrabajo.id,label.FAC_Maestro_Profesionales);
		Baipas.deshabilitarVariableControl();
		Util_facturador.facturarprofesional(compania.Id, Label.FAC_PreFactura);
	}
	
	@isTest static void FacturarEvento(){
		inicializarVariables();
        Account compania1 = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania1;
        
		Account cuenta1 = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		cuenta1.Type = Label.CUE_TIPO_CONTABLE;
        cuenta1.CUE_LKP_Cuenta_principal__c = compania1.Id;
		insert cuenta1;
        
        Account propEventoAcc = Util_Tests.crearCuentaAsegurado('Alejandro','04626393N','coredamnwork@gmail.com',
		'04626393N','Alejandro', 'Rey', 'Lopez');
       	propEventoAcc.Type = '01';
        propEventoAcc.CUE_LKP_Cliente_contable__c = cuenta1.Id;
        propEventoAcc.CUE_LKP_Cuenta_principal__c = cuenta1.Id;
        insert propEventoAcc ;
		
		Account cuentaTipoProducto = new Account();
		cuentaTipoProducto = Util_Tests.crearCuentaCompania('cuentaTipoProducto','26032018','X1114568X');
		insert cuentaTipoProducto;
		
		Tipo_Producto_CIA__c tipoProductoCIA = new Tipo_Producto_CIA__c();
		Util_Tests.crearTipoProductoCIA('productoTipo', '01', propEventoAcc.Id);
		tipoProductoCIA.TPR_LKP_Compania__c = cuentaTipoProducto.Id;
		tipoProductoCIA.TPR_TXT_Identificador__c = '4209323';
		insert tipoProductoCIA;
		
		Producto_CIA__c productoCIA = new Producto_CIA__c();
		productoCIA = Util_Tests.crearProductoCIA('productoCIA', '23032018', tipoProductoCIA.Id);
		insert productoCIA;
		
		ServiceContract poliza = new ServiceContract();
		poliza = Util_Tests.crearPolizaContrato('poliza', cuenta1.Id , propEventoAcc.Id, productoCIA.Id);
		insert poliza;
		
		Case casoClienteContable = new Case();

            casoClienteContable = Util_Tests.crearCasoConClienteContable(poliza.Id, cuenta1.Id, compania1.Id, cuenta1.Id);//crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
            casoClienteContable.CAS_SEL_Encuestador__c = 'Servitelco';
            casoClienteContable.CAS_LKP_Compania__c = compania1.Id;
            casoClienteContable.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            casoClienteContable.CreatedDate = system.now();
            casoClienteContable.Status = '993';
            casoClienteContable.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
            insert casoClienteContable;
        
		
		Case caso = new Case();
		caso = Util_Tests.crearCasoSini(poliza.Id, cuentaTipoProducto.Id, cuentaTipoProducto.Id);
		insert caso;
		
		Baipas.establecerVariableControl();
		WorkOrder ordenTrabajo = new WorkOrder();
		ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = '26032018';
		ordenTrabajo.OTR_SEL_Gremio__c = '75';
		ordenTrabajo.CaseId = casoClienteContable.Id;
		insert ordenTrabajo;

		Propuesta_de_Abono__c propAbono = new Propuesta_de_Abono__c(AB_SEL_Estado__c = '02', AB_SEL_Descripcion_evento__c = 'E12');
		//propAbono.AB_LKP_Imputar_a__c = usuari.Id;
		propAbono.AB_LKP_Caso__c = casoClienteContable.Id;
        propAbono.AB_LKP_Ingresar_a__c = casoClienteContable.AccountId;
		propAbono.AB_LKP_Imputar_a__c = system.UserInfo.getUserId(); 
        propAbono.AB_DIV_Importe_a_Imputar__c = 50;
		insert propAbono;

		Baipas.deshabilitarVariableControl();
		
		Test.startTest();
		
		WorkOrder ordenTrabajoEvento = new WorkOrder();				
		
		Propuesta_de_Evento__c propEvento = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = casoClienteContable.Id);
		propEvento.EV_AB_TXT_Identificador__c = '13042018';
		insert propEvento;
		propEvento.EV_AB_SEL_Estado__c = '02';
		propEvento.EV_AB_CAS_Evento_Ab_Facturado__c = true;
		propEvento.EV_AB_LKP_Orden_de_Trabajo__c = ordenTrabajoEvento.Id;
		propEvento.EV_AB_LKP_Abono__c = propAbono.Id;
		update propEvento;
		
		
		List<Propuesta_de_Evento__c> ListaEventos = new List<Propuesta_de_Evento__c>();
		ListaEventos.add(propEvento);

		Map<Id,Propuesta_de_Evento__c> mEvento = new Map<Id,Propuesta_de_Evento__c>();
		mEvento.put(propEvento.Id, propEvento);
		
		Util_Facturador.CalloutFacturadorEvento(mEvento, 'SRV-PSI-097a');
		
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		Util_Facturador.facturadorEventos(propEvento.Id, 'SRV-PSI-097a');
		
		
		Map<Id,Propuesta_de_Abono__c> mAbono = new Map<Id,Propuesta_de_Abono__c>();
		mAbono.put(propAbono.Id, propAbono);
		
		Util_Facturador.CalloutFacturadorAbono(mAbono, 'SRV-PSI-097b');
		Util_Facturador.facturadorEventos(propEvento.Id, 'SRV-PSI-097b');
		Test.stopTest();		
	}
	
	@isTest static void ClienteAbono(){
		inicializarvariables();
		
		WorkOrder wo = new WorkOrder();
		wo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
		insert wo;
		List<WorkOrder> listWO = new List<WorkOrder>();

		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;

		Account propAbonoAcc = new Account();
		propAbonoAcc.Name = 'propAbonoAcc';
		propAbonoAcc.CUE_TXT_Identificador__c = '23032018';
		propAbonoAcc.CUE_SEL_Tipo_Documento__c = 'C';
        propAbonoAcc.CUE_TXT_Numero_Documento__c = 'X1114567X';
		propAbonoAcc.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1);
		insert propAbonoAcc;

		Account cuentappal = new Account();
		cuentappal.Name = 'cuentappal';
		cuentappal.CUE_TXT_Identificador__c = '101101';
		cuentappal.CUE_SEL_Tipo_Documento__c = 'C';
        cuentappal.CUE_TXT_Numero_Documento__c = 'X1123456X';
		cuentappal.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1);
		insert cuentappal;
		
		Util_facturador.construirBodyClientes(listWO, propAbonoAcc.Id, Label.FAC_Maestro_Clientes);
		
		//Ahora, a la cuenta del abono, tendrá un cliente contable;
		Account clienteContable = new Account();
		clienteContable.Name = 'clienteContable';
		clienteContable.CUE_TXT_Identificador__c = '19042018';
		clienteContable.CUE_SEL_Tipo_Documento__c = 'C';
        clienteContable.CUE_TXT_Numero_Documento__c = 'X1111111X';
        clienteContable.Type = '02';
		clienteContable.CUE_LKP_Cuenta_principal__c = cuentappal.Id;
		insert clienteContable;
		
		propAbonoAcc.CUE_LKP_Cliente_contable__c = clienteContable.Id;
		update propAbonoAcc;
		Util_facturador.construirBodyClientes(listWO, propAbonoAcc.Id, Label.FAC_Maestro_Clientes);
		
	}
}