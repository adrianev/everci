@isTest
public without sharing class Test_AltaModificacionCliente{

	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account cuentaPrincipal2 {get; set;}
	private static Account cuentaPrincipalCons {get; set;}
	private static Account cuenta1 {get; set;}
	private static Account aseguradoHijo {get; set;}
	private static Account cuenta3 {get; set;}
	private static Account asegurado {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static Direccion_Cuenta__c direccionCuenta1 {get; set;}
	private static Direccion_Cuenta__c direccionCuenta2 {get; set;}
	private static Poblacion__c poblacion {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static OperatingHours horaFuncionamiento {get; set;}
	private static ServiceTerritory territorioServicio {get; set;}
	private static Poblacion_CP__c poblacionCP {get; set;}
	private static Case caso {get; set;}
	private static Contact contacto1 {get; set;}
	private static Contact contacto2 {get; set;}

	private static void inicializarVariables(){
		List<Account> listaCuentas = new List<Account>();
		List<Account> listaCias = new  List<Account>();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018', 'P5990145D');
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019', 'W5057244E');
		cuentaPrincipal2 = Util_Tests.crearCuentaB2BPpal('B2BPrincipal2','1020', 'P2606889J');
		cuentaPrincipal2.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2C_1);
		cuentaPrincipalCons = Util_Tests.crearCuentaB2BPpal('CuentaCons','1021', 'U4615885C');
		cuentaPrincipalCons.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA);
		
		listaCias.add(cuentaPrincipal);
		listaCias.add(cuentaPrincipal2);
		listaCias.add(cuentaPrincipalCons);
		insert listaCias;
		poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;
		horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
		insert horaFuncionamiento;
		territorioServicio = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
		territorioServicio.TDS_TXT_Identificador__c = '28001';
		insert territorioServicio;
		List<Poblacion_CP__c> poblacionCPList = new List<Poblacion_CP__c>();
		poblacionCPList.add(Util_Tests.crearPoblacionCP('Madrid',poblacion.Id,territorioServicio.Id,'28001'));
		poblacionCPList.add(Util_Tests.crearPoblacionCP('Madrid2',poblacion.Id,territorioServicio.Id,'28001'));
		insert poblacionCPList;
		//system.debug('>>>>SMM_TEST: [TEST DESPUES insert poblacionCP] poblacionCP: '+poblacionCP);
		cuenta1 = Util_Tests.crearCuentaB2BSec('SegurCaixa1','1022',cuentaPrincipal.Id, 'X1111167X');
		aseguradoHijo = Util_Tests.crearCuentaB2BSec('AseguradoHijo','1023',cuentaPrincipal.Id,'X1111111X');
		cuenta3 = Util_Tests.crearCuentaB2BSec('SegurCaixa2','1024',cuentaPrincipal.Id, 'X1111117X');
		asegurado = Util_Tests.crearCuentaB2BSec('Asegurado','1025',cuentaPrincipal.Id,'X1111176X');
		//asegurada.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR);
		asegurado.CUE_TXT_Numero_Documento__c = '65595805N';
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		asegurado.ShippingPostalCode = '28001';
		asegurado.ShippingStreet = 'Calle';
		List<SelectOption> listaPoblaciones = Util_TerritorioServicio.cargarListaPoblacionPorCP('28001');
		system.debug('>>>>SMM_TEST: [TEST DESPUES Util_TerritorioServicio.cargarListaPoblacionPorCP] listaPoblaciones: '+listaPoblaciones);
		String poblacionSelecOpt = listaPoblaciones.get(0).getValue();
		asegurado.ShippingCity = Util_TerritorioServicio.obtenerPoblacionSel(poblacionSelecOpt.substring(poblacionSelecOpt.indexOf('#')+1));//'Avenida de Europa 34';
		//asegurado.ShippingCity ='Avenida de Europa 34';
		//asegurado.CUE_SEL_Pais__c = Label.PAIS_ESPANA;
		asegurado.CUE_TXT_PrimerApellido__c = 'Lopez';
		listaCuentas.add(compania);
		listaCuentas.add(cuenta1);
		listaCuentas.add(aseguradoHijo);
		listaCuentas.add(cuenta3);
		listaCuentas.add(asegurado);
		insert listaCuentas;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		List<Direccion_Cuenta__c> listaDireccionesCuenta = new List<Direccion_Cuenta__c>();
		direccionCuenta1 = Util_Tests.crearDireccionCuenta('28050',asegurado.Id);
		direccionCuenta2 = Util_Tests.crearDireccionCuenta('28002',asegurado.Id);
		direccionCuenta1.DCU_TXT_Poblacion__c = 'MADRID';
		direccionCuenta1.DCU_SEL_Provincia__c = '28';
		direccionCuenta2.DCU_TXT_Poblacion__c = 'MADRID';
		direccionCuenta2.DCU_SEL_Provincia__c = '28';
		listaDireccionesCuenta.add(direccionCuenta1);
		listaDireccionesCuenta.add(direccionCuenta2);
		insert listaDireccionesCuenta;
		poliza = Util_Tests.crearPolizaContrato('2277384',compania.Id,asegurado.Id,productoCIA.Id);
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta1.Id,'101801','CAS_Siniestro');
		insert procedencia;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta1.Id, compania.Id);
		insert caso;
		List<Contact> listaContactos = new List<Contact>();
		contacto1 = Util_Tests.crearContacto('Manuel','Rosas',asegurado.Id,'53568187A');
		contacto2 = Util_Tests.crearContacto('Manuelito','Rosasrio',asegurado.Id,'63568187A');
		contacto1.Phone = '657753457';
		contacto2.Phone = '667753457';
		listaContactos.add(contacto1);
		listaContactos.add(contacto2);
		insert listaContactos;
	}

	@isTest static void testIdRecordType(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('fase','Y');
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.currentPage().getParameters().put('retURL','Y');
		ApexPages.currentPage().getParameters().put('creadoOK','modificado');
		ApexPages.currentPage().getParameters().put('idRecordType',asegurado.RecordTypeId);
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);
		System.assertEquals(altaModificacionCliente.clienteB2C,false);
		System.assertEquals(altaModificacionCliente.caso.Id,caso.Id);
		System.assertEquals(altaModificacionCliente.cuenta.RecordTypeId,asegurado.RecordTypeId);
		System.assertEquals(altaModificacionCliente.cabecera,'Crear Dirección/Cliente Final/Cliente Contable');
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}

	@isTest static void testRecordTypeId(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('fase','Y');
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.currentPage().getParameters().put('recordTypeName','Cliente Asegurado');  
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);	   
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);
		System.assertEquals(altaModificacionCliente.clienteB2C,false);
		System.assertEquals(altaModificacionCliente.cabecera,'Crear Dirección/Cliente Final/Cliente Contable');
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}

	@isTest static void testIdCuentaB2BPpal(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('fase','Y');
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		//Account asegurado = Util_Tests.getAccountByName('SegurCaixa2');
		ApexPages.currentPage().getParameters().put('retURL','Y');
		ApexPages.currentPage().getParameters().put('creadoOK','creado');
		ApexPages.currentPage().getParameters().put('idCuentaB2BPpal',cuenta3.Id);   
		ApexPages.StandardController sc = new ApexPages.StandardController(cuenta3);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);
		System.assertEquals(altaModificacionCliente.clienteB2C,false);
		System.assertEquals(altaModificacionCliente.cabecera,'Crear Dirección/Cliente Final/Cliente Contable');
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}

	@isTest static void testIdB2B(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('fase','Y');
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.currentPage().getParameters().put('retURL','Y');
		//Account aseguradoHijo = Util_Tests.getAccountByName('AseguradoHijo');
		ApexPages.currentPage().getParameters().put('Id',asegurado.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(aseguradoHijo);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);
		System.assertEquals(altaModificacionCliente.clienteB2C,false);
		System.assertEquals(altaModificacionCliente.cabecera,'Modificar Dirección/Cliente Final/Cliente Contable');
		System.assertEquals(altaModificacionCliente.cuenta.Id,aseguradoHijo.Id);
		//System.assertEquals(altaModificacionCliente.cuenta.ShippingCity,'MADRID');
		//System.assertEquals(altaModificacionCliente.cuenta.CUE_SEL_Provincia__c,'28');
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}


	@isTest static void testId(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		forRubenByalex(caso);
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.currentPage().getParameters().put('retURL','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('Id',asegurado.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);
		System.assertEquals(altaModificacionCliente.clienteB2C,false);
		System.assertEquals(altaModificacionCliente.cabecera,'Modificar Dirección/Cliente Final/Cliente Contable');
		System.assertEquals(altaModificacionCliente.cuenta.Id,asegurado.Id);

		altaModificacionCliente.crearDireccion();
		System.assertEquals(altaModificacionCliente.creacionDireccion,true);
		System.assertEquals(altaModificacionCliente.actualizacionDireccion,false);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de nueva dirección');
		System.assertNotEquals(altaModificacionCliente.listaPoblacionesNueva,null);
		altaModificacionCliente.guardarDireccion();				 
		altaModificacionCliente.indiceListaDirecciones=0;
		altaModificacionCliente.seleccionarDireccion(); 
		System.assertEquals(altaModificacionCliente.creacionDireccion,false);
		System.assertEquals(altaModificacionCliente.actualizacionDireccion,true);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de actualización de Dirección');

		altaModificacionCliente.crearContacto();
		System.assertEquals(altaModificacionCliente.creacionContacto,true);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,false);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de nuevo contacto');
		altaModificacionCliente.indiceListaContactos = 0;
		altaModificacionCliente.guardar();
		altaModificacionCliente.seleccionarContacto();
		System.assertEquals(altaModificacionCliente.creacionContacto,false);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,true);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de actualización de contacto');
		altaModificacionCliente.nuevoContacto = new Contact();
		altaModificacionCliente.guardarContacto();
		System.assertEquals(altaModificacionCliente.creacionContacto,false);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,true);
		System.assertNotEquals(altaModificacionCliente.listaContactosCuenta,null);
		asegurado.ShippingCity ='Avenida de Europa 34';
		update asegurado;
		altaModificacionCliente.guardar();
		altaModificacionCliente.detalleCliente();
		altaModificacionCliente.indiceListaContactos = 1;
		altaModificacionCliente.eliminarContacto();
		altaModificacionCliente.indiceListaDirecciones= 1;
		altaModificacionCliente.eliminarDireccion();
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}

	@isTest static void testId2(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.currentPage().getParameters().put('retURL','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('Id',asegurado.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);

		altaModificacionCliente.crearDireccion();
		System.assertEquals(altaModificacionCliente.creacionDireccion,true);
		System.assertEquals(altaModificacionCliente.actualizacionDireccion,false);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de nueva dirección');
		System.assertNotEquals(altaModificacionCliente.listaPoblacionesNueva,null);
		altaModificacionCliente.guardarDireccion();				 
		altaModificacionCliente.indiceListaDirecciones=0;
		altaModificacionCliente.seleccionarDireccion(); 
		System.assertEquals(altaModificacionCliente.creacionDireccion,false);
		System.assertEquals(altaModificacionCliente.actualizacionDireccion,true);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de actualización de Dirección');

		altaModificacionCliente.crearContacto();
		System.assertEquals(altaModificacionCliente.creacionContacto,true);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,false);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de nuevo contacto');
		altaModificacionCliente.indiceListaContactos = 0;
		altaModificacionCliente.seleccionarContacto();
		System.assertEquals(altaModificacionCliente.creacionContacto,false);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,true);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de actualización de contacto');
		altaModificacionCliente.nuevoContacto = new Contact();
		altaModificacionCliente.guardarContacto();
		//System.assertEquals(altaModificacionCliente.nuevoContacto,null);
		System.assertEquals(altaModificacionCliente.creacionContacto,false);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,true);
		System.assertNotEquals(altaModificacionCliente.listaContactosCuenta,null);
		system.debug('>>>>SMM_TEST: [TEST ANTES segundo guardar()] asegurado.Name: '+asegurado.Name+', asegurado.ShippingCity: '+asegurado.ShippingCity);
		altaModificacionCliente.guardar();
		altaModificacionCliente.detalleCliente();
		altaModificacionCliente.indiceListaContactos = 1;
		altaModificacionCliente.indiceListaDirecciones= 1;
		altaModificacionCliente.listaResultados.get(0).seleccionado = true;
		altaModificacionCliente.nuevoServicioB2C();
		altaModificacionCliente.eliminarContacto();
        
		altaModificacionCliente.eliminarDireccion();
		altaModificacionCliente.poblacionNueva = 'Madrid';
		altaModificacionCliente.cargarProvinciaPoblacionNueva();
		Baipas.deshabilitarVariableControl();
		Test.stopTest(); 
	}
    
    
    @isTest static void testId3(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.currentPage().getParameters().put('retURL','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('Id',asegurado.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);

		altaModificacionCliente.crearDireccion();
		System.assertEquals(altaModificacionCliente.creacionDireccion,true);
		System.assertEquals(altaModificacionCliente.actualizacionDireccion,false);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de nueva dirección');
		System.assertNotEquals(altaModificacionCliente.listaPoblacionesNueva,null);
		altaModificacionCliente.guardarDireccion();				 
		altaModificacionCliente.indiceListaDirecciones=0;
		altaModificacionCliente.seleccionarDireccion(); 
		System.assertEquals(altaModificacionCliente.creacionDireccion,false);
		System.assertEquals(altaModificacionCliente.actualizacionDireccion,true);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de actualización de Dirección');

		altaModificacionCliente.crearContacto();
		System.assertEquals(altaModificacionCliente.creacionContacto,true);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,false);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de nuevo contacto');
		altaModificacionCliente.indiceListaContactos = 0;
		altaModificacionCliente.seleccionarContacto();
		System.assertEquals(altaModificacionCliente.creacionContacto,false);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,true);
		System.assertEquals(altaModificacionCliente.tituloFormularioEdicion,'Datos de actualización de contacto');
		altaModificacionCliente.nuevoContacto = new Contact();
		altaModificacionCliente.guardarContacto();
		//System.assertEquals(altaModificacionCliente.nuevoContacto,null);
		System.assertEquals(altaModificacionCliente.creacionContacto,false);
		System.assertEquals(altaModificacionCliente.actualizacionContacto,true);
		System.assertNotEquals(altaModificacionCliente.listaContactosCuenta,null);
		system.debug('>>>>SMM_TEST: [TEST ANTES segundo guardar()] asegurado.Name: '+asegurado.Name+', asegurado.ShippingCity: '+asegurado.ShippingCity);
		altaModificacionCliente.guardar();
		altaModificacionCliente.detalleCliente();
		altaModificacionCliente.indiceListaContactos = 1;
		altaModificacionCliente.indiceListaDirecciones= 1;
		altaModificacionCliente.listaResultados.get(0).seleccionado = true;
		altaModificacionCliente.nuevoServicioB2C();
		altaModificacionCliente.eliminarContacto();
        system.debug(AltaModificacionCliente.nuevaDireccion + 'pruebaaaaaaaa');
        
		altaModificacionCliente.eliminarDireccion();
		altaModificacionCliente.poblacionNueva = 'Madrid';
		altaModificacionCliente.cargarProvinciaPoblacionNueva();
		Baipas.deshabilitarVariableControl();
		Test.stopTest(); 
	}

    
    
    
    
    
    
    
    
    
    
    
    
    
	@isTest static void testIdEmpresa(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		//Account asegurado = Util_Tests.getAccountByName('SegurCaixa1');
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('fase','Y');
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		ApexPages.currentPage().getParameters().put('idRecordType',cuenta1.RecordTypeId);
		ApexPages.currentPage().getParameters().put('idCuentaPpal',cuentaPrincipal.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);
		System.assertEquals(altaModificacionCliente.caso.Id,caso.Id);
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}
    
    	@isTest static void testIdEmpresa1(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		//Account asegurado = Util_Tests.getAccountByName('SegurCaixa1');
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('fase','Y');
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		ApexPages.currentPage().getParameters().put('idRecordType',cuentaPrincipal2.RecordTypeId);
		ApexPages.currentPage().getParameters().put('idCuentaPpal',cuentaPrincipal2.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		AltaModificacionCliente altaModificacionCliente = new AltaModificacionCliente(sc);
		System.assertEquals(altaModificacionCliente.caso.Id,caso.Id);
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}
    
	
	@isTest static void testContinuarCaso(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		//Account asegurado = Util_Tests.getAccountByName('SegurCaixa1');
		ApexPages.StandardController sc = new ApexPages.StandardController(cuenta1);
		AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		altaMC.clienteB2C = true;
		altaMC.continuarCaso();
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}
	
	 @isTest static void testVolver(){
	 	Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		PageReference pageRef = Page.AltaModificacionCliente;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		//ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		//Case caso = Util_Tests.getCaseById(poliza.Id);
		forRubenByalex(caso);
		ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		//Account asegurado = Util_Tests.getAccountByName('Asegurado');
		ApexPages.currentPage().getParameters().put('retURL','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('Id',asegurado.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		 altaMC.cuenta = Util_Tests.getAccountByName(cuenta1.Name);
		altaMC.volver();
		Baipas.deshabilitarVariableControl();
		Test.stopTest();
	}
   
	 @isTest static void testNuevoCliente(){
		 Test.startTest();
		 Baipas.establecerVariableControl();
		 inicializarVariables();
		 PageReference pageRef = Page.AltaModificacionCliente;
		 Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('Id',asegurado.Id);
		 ApexPages.currentPage().getParameters().put('solicitudExistente','Y');
		 ApexPages.currentPage().getParameters().put('vincularCliB2BRep','Y');
		 ApexPages.currentPage().getParameters().put('retorno','');
		 ApexPages.currentPage().getParameters().put('creadoOK','creado');
		 ApexPages.currentPage().getParameters().put('idRecordType',asegurado.RecordTypeId);
		 ApexPages.currentPage().getParameters().put('idCuentaPpal',cuentaPrincipal.Id);
		 ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		 ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		 //ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		 //Case caso = Util_Tests.getCaseById(poliza.Id);
		 forRubenByalex(caso);
		 ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		 ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		 //Account asegurado = Util_Tests.getAccountByName('Asegurado');
		 ApexPages.currentPage().getParameters().put('retURL','/'+caso.Id);
		 ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		 AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		 altaMC.cuenta = Util_Tests.getAccountByName(cuenta1.Name);
		 altaMC.cuenta.ShippingCity='Madrid';
		 altaMC.cuenta.ShippingPostalCode= '28001';
         altaMC.nuevaDireccion = direccionCuenta1;
         System.debug(altaMC.nuevaDireccion + ' altaMC.nuevaDireccion');
         altaMC.cargarProvinciaPoblacionNueva(); 
		 altaMC.cargarListaPoblacionPorCP();
		 altaMC.continuarCaso();
		 altaMC.guardar();
		 altaMC.volver();
		 Baipas.deshabilitarVariableControl();
		 Test.stopTest();
	 }
    
    @isTest static void testNuevoCliente2(){
		 Test.startTest();
		 Baipas.establecerVariableControl();
		 inicializarVariables();
		 PageReference pageRef = Page.AltaModificacionCliente;
		 Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('Id',asegurado.Id);
		 ApexPages.currentPage().getParameters().put('solicitudExistente','Y');
		 ApexPages.currentPage().getParameters().put('vincularCliB2BRep','Y');
		 ApexPages.currentPage().getParameters().put('retorno','');
		 ApexPages.currentPage().getParameters().put('creadoOK','creado');
         ApexPages.currentPage().getParameters().put('idRecordType',cuentaPrincipal2.RecordTypeId);
		 ApexPages.currentPage().getParameters().put('idCuentaPpal',cuentaPrincipal2.Id);
		 ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		 ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		 //ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		 //Case caso = Util_Tests.getCaseById(poliza.Id);
		 forRubenByalex(caso);
		 ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		 ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		 //Account asegurado = Util_Tests.getAccountByName('Asegurado');
		 ApexPages.currentPage().getParameters().put('retURL','/'+caso.Id);
		 ApexPages.StandardController sc = new ApexPages.StandardController(asegurado);
		 AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		 altaMC.cuenta = Util_Tests.getAccountByName(cuentaPrincipal2.Name);
		 altaMC.cuenta.ShippingCity='Madrid';
		 altaMC.cuenta.ShippingPostalCode= '28001';
		 altaMC.cargarListaPoblacionPorCP();
		 altaMC.continuarCaso();
		 altaMC.guardar();
		 altaMC.volver();
		 Baipas.deshabilitarVariableControl();
		 Test.stopTest();
	 }
    
    
    
    
	 @isTest static void testGuardarB2C(){
		 Test.startTest();
		 Baipas.establecerVariableControl();
		 inicializarVariables();
		 PageReference pageRef = Page.AltaModificacionCliente;
		 Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('Id',cuentaPrincipal2.Id);
		 ApexPages.currentPage().getParameters().put('solicitudExistente','Y');
		 ApexPages.currentPage().getParameters().put('vincularCliB2BRep','Y');
		 ApexPages.currentPage().getParameters().put('retorno','');
		 ApexPages.currentPage().getParameters().put('creadoOK','creado');
		 ApexPages.currentPage().getParameters().put('idRecordType',cuentaPrincipal2.RecordTypeId);
		 ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		 ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		 //ServiceContract poliza = Util_Tests.getServiceContractByName('2277384');
		 //Case caso = Util_Tests.getCaseById(poliza.Id);
		 forRubenByalex(caso);
		 ApexPages.currentPage().getParameters().put('idCaso',caso.Id);
		 ApexPages.currentPage().getParameters().put('vincularCliente','Y');
		 //Account asegurado = Util_Tests.getAccountByName('Asegurado');
		 ApexPages.currentPage().getParameters().put('retURL','/'+caso.Id);
		 ApexPages.StandardController sc = new ApexPages.StandardController(aseguradoHijo);
		 AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		 altaMC.cuenta = Util_Tests.getAccountByName(cuenta1.Name);
		 altaMC.cuenta.ShippingCity='Madrid';
		 system.debug('@@@@@@@@@@ShippingCity: '+altaMC.cuenta.ShippingCity);
		 altaMC.cargarListaPoblacionPorCP();
		 altaMC.crearDireccion();
		 altaMC.nuevaDireccion.DCU_TXT_Direccion__c='Calle';
		 altaMC.nuevaDireccion.DCU_TXT_Codigo_Postal__c='28000';
		 altaMC.nuevaDireccion.DCU_TXT_Poblacion__c = 'Madrid';
		 altaMC.nuevaDireccion.DCU_SEL_Provincia__c = '01';
		 altaMC.nuevaDireccion.DCU_SEL_Pais__c = 'ESP';
		 altaMC.guardarDireccion();
		 //altaMC.continuarCaso();
		 altaMC.guardar();
		 altaMC.volver();
		 Baipas.deshabilitarVariableControl();
		 Test.stopTest();
	 }
	 @isTest static void testNuevoClienteParticular(){
		 Test.startTest();
		 Baipas.establecerVariableControl();
		 inicializarVariables();
		 PageReference pageRef = Page.AltaModificacionCliente;
		 Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('idRecordType', Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR));
		 ApexPages.currentPage().getParameters().put('idCuentaPpal',cuentaPrincipal.Id);
		 ApexPages.currentPage().getParameters().put('sfdc.tabName','01r9E0000000');
		 ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipalCons);
		 AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		 altaMc.cuenta.CUE_TXT_Numero_Documento__c='12345678P';
		 altaMc.cuenta.CUE_TXT_Nombre__c='Nemesio';
         altaMc.cuenta.CUE_TXT_SegundoApellido__c = 'Juanillo';
		 altaMc.cuenta.ShippingPostalCode='36100';
		 altaMc.cuenta.ShippingStreet='Benito Corbal';
		 altaMc.cuenta.ShippingCity='Pontevedra';
		 altaMc.cuenta.CUE_SEL_Pais__c=Label.PAIS_ESPANA;
		 altaMc.cuenta.CUE_TXT_PrimerApellido__c='Carballo';
		 altaMc.mostrarConfirm = true;
		 altaMc.guardar();
		 altaMc.crearDireccion();
		 altaMC.continuarCaso();
		 altaMC.guardar();
		 Baipas.deshabilitarVariableControl();
		 Test.stopTest();
	 }
    	 @isTest static void testNuevoClienteParticular1(){
		 Test.startTest();
		 Baipas.establecerVariableControl();
		 inicializarVariables();
		 PageReference pageRef = Page.AltaModificacionCliente;
		 Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('idRecordType', Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR));
		 ApexPages.currentPage().getParameters().put('idCuentaPpal',cuentaPrincipal.Id);
		 ApexPages.currentPage().getParameters().put('sfdc.tabName','01r9E0000000');
		 ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipalCons);
		 AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		 altaMc.cuenta.CUE_TXT_Numero_Documento__c='12345678P';
		 altaMc.cuenta.CUE_TXT_Nombre__c='Nemesio';
         altaMc.cuenta.CUE_TXT_SegundoApellido__c = 'Juanillo';
		 altaMc.cuenta.ShippingPostalCode='36100';
		 altaMc.cuenta.ShippingStreet='Benito Corbal';
		 altaMc.cuenta.ShippingCity='Pontevedra';
		 altaMc.cuenta.CUE_SEL_Pais__c=Label.PAIS_ESPANA;
		 altaMc.cuenta.CUE_TXT_PrimerApellido__c='Carballo';
         altaMc.cuenta.type = Label.CUE_TIPO_DIRECCION;
		 altaMc.mostrarConfirm = true;
		 altaMc.guardar();
		 altaMc.crearDireccion();
		 altaMC.continuarCaso();
		 altaMC.guardar();
		 Baipas.deshabilitarVariableControl();
		 Test.stopTest();
	 }
    
       	 @isTest static void testNuevoClienteParticular2(){
		 Test.startTest();
		 Baipas.establecerVariableControl();
		 inicializarVariables();
		 PageReference pageRef = Page.AltaModificacionCliente;
		 Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('idRecordType', Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR));
		 ApexPages.currentPage().getParameters().put('idCuentaPpal',cuentaPrincipal.Id);
		 ApexPages.currentPage().getParameters().put('sfdc.tabName','01r9E0000000');
		 ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipalCons);
		 AltaModificacionCliente altaMC = new AltaModificacionCliente(sc);
		 altaMc.cuenta.CUE_TXT_Numero_Documento__c=Null;
		 altaMc.cuenta.CUE_TXT_Nombre__c='Nemesio';
         altaMc.cuenta.CUE_TXT_SegundoApellido__c = 'Juanillo';
		 altaMc.cuenta.ShippingPostalCode='36100';
		 altaMc.cuenta.ShippingStreet='Benito Corbal';
		 altaMc.cuenta.ShippingCity='Pontevedra';
		 altaMc.cuenta.CUE_SEL_Pais__c=Label.PAIS_ESPANA;
		 altaMc.cuenta.CUE_TXT_PrimerApellido__c= Null;
         altaMc.cuenta.type = Label.CUE_TIPO_OK_PYMES;
		 altaMc.mostrarConfirm = true;
		 altaMc.guardar();
		 altaMc.crearDireccion();
		 altaMC.continuarCaso();
		 altaMC.guardar();
		 Baipas.deshabilitarVariableControl();
		 Test.stopTest();
	 }
    
    
    
    
    
    
	 private static void forRubenByalex(Case caso){
		Id recordTypeSolicitud = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
		caso.RecordTypeId = recordTypeSolicitud;
		update caso;
	} 
}