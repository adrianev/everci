@isTest
public without sharing class Test_TRG_Handler_EmailMessage extends TestSetup{

	private static Account cuentaCompania {get; set;}
	private static Account cuentaCompania2 {get; set;}
	private static Account cuentaAsegurado {get; set;}
	private static Account cuentaAsegurado2 {get; set;}
	private static Account cuentaB2BSec {get; set;}
	private static Account cuentaB2BSec2 {get; set;}
	private static Account cuentaB2BPrincipal {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA2 {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static Producto_CIA__c productoCIA2 {get; set;}
	private static ServiceContract poliza {get; set;}
	private static ServiceContract poliza2 {get; set;}
	private static ServiceContract polizaB2B {get; set;}
	private static ServiceContract polizaB2B2 {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Buzon_CIA__c buzon {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static Contract contrato {get; set;}
	private static Linea_Contrato__c lineaContrato {get; set;}
	private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static WorkOrderLineItem partidaOT {get; set;}
	private static Contact contacto1 {get; set;}
	private static Contact contacto2 {get; set;}
	private static String userType {get; set;}
	private static Case casoB2B {get; set;}
	private static Case casoSini {get; set;}

	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		userType = Schema.SObjectType.User.getKeyPrefix();
		List<Case> listaCasos = new List<Case>();
		List<Account> listaCuentas = new List<Account>();
		List<Tipo_Producto_CIA__c> listaTipoPCIA = new List<Tipo_Producto_CIA__c>();
		List<Producto_CIA__c> listaProductoCIA = new List<Producto_CIA__c>();
		List<ServiceContract> listaPolizas = new List<ServiceContract>();
		List<Contact> listaContactos = new List<Contact>();
		cuentaB2BPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1018','X1234567X');
		insert cuentaB2BPrincipal;
		cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1019','X1134567X');
		cuentaCompania2 = Util_Tests.crearCuentaCompania('SegurCaixa3','1020','X1114567X');
		cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1023','email@gmail.es','38231074Z','nombre','apellido1','apellido2');
		cuentaAsegurado.CUE_SEL_Tipo_Documento__c = 'N';
        cuentaAsegurado2 = Util_Tests.crearCuentaAsegurado('Asegurado2','1024','email2@gmail.es','89074907R','nombre','apellido1','apellido2');
		cuentaAsegurado2.CUE_SEL_Tipo_Documento__c = 'N';
        cuentaB2BSec = Util_Tests.crearCuentaB2BSec('SegurCaixa2','1021',cuentaB2BPrincipal.Id,'X1111567X');
		cuentaB2BSec2 = Util_Tests.crearCuentaB2BSec('SegurCaixa4','1022',cuentaB2BPrincipal.Id,'X1111167X');
		listaCuentas.add(cuentaCompania);
		listaCuentas.add(cuentaCompania2);
		listaCuentas.add(cuentaAsegurado);
		listaCuentas.add(cuentaAsegurado2);
		listaCuentas.add(cuentaB2BSec);
		listaCuentas.add(cuentaB2BSec2);
		insert listaCuentas;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.id);
		tipoProductoCIA2 = Util_Tests.crearTipoProductoCIA('SegurCaixa2 - HOGAR','01',cuentaCompania2.id);
		listaTipoPCIA.add(tipoProductoCIA);
		listaTipoPCIA.add(tipoProductoCIA2);
		insert listaTipoPCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		productoCIA2 = Util_Tests.crearProductoCIA('KIT 108','12345679',tipoProductoCIA2.Id);
		listaProductoCIA.add(productoCIA);
		listaProductoCIA.add(productoCIA2);
		insert listaProductoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',cuentaCompania.Id,cuentaAsegurado.Id,productoCIA.Id);
		poliza2 = Util_Tests.crearPolizaContrato('2277394',cuentaCompania2.Id,cuentaAsegurado2.Id,productoCIA2.Id);
		polizaB2B = Util_Tests.crearPolizaContrato('2277384',cuentaCompania.Id,cuentaB2BSec.Id,productoCIA.Id);
		polizaB2B2 = Util_Tests.crearPolizaContrato('2277385',cuentaCompania2.Id,cuentaB2BSec2.Id,productoCIA2.Id);
		listaPolizas.add(poliza);
		listaPolizas.add(poliza2);
		listaPolizas.add(polizaB2B);
		listaPolizas.add(polizaB2B2);
		insert listaPolizas;
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuentaB2BSec.Id,'101801','CAS_Siniestro');
		procedencia.Name = Label.IDE_PROCEDENCIA_HOMESERVE;
		insert procedencia;
		casoB2B = Util_Tests.crearCasoB2B(polizaB2B.Id,cuentaB2BSec.Id,cuentaCompania.Id);
		casoSini = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,cuentaCompania.Id);
		listaCasos.add(casoB2B);
		listaCasos.add(casoSini);
		insert listaCasos;
		buzon = Util_Tests.crearBuzon('Buzon',cuentaB2BSec.Id,'correo@email.com');
		insert buzon;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		contrato = Util_Tests.crearContrato(cuentaB2BSec.Id,'b2b_p_1');
		insert contrato;
		lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
		lineaContrato.LDC_LKP_Tipo_Trabajo__c = tipoTrabajo.Id;
		insert lineaContrato;
		direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuentaB2BSec.Id,lineaContrato.Id,3);
		direccionBB_lineas.DLC_LKP_Linea_de_Contrato__c = lineaContrato.Id;
		insert direccionBB_lineas;
		contacto1 = Util_Tests.crearContacto('Manuel', 'Rosas Castillo', cuentaAsegurado.Id, '53568187A');
		contacto2 = Util_Tests.crearContacto('Manuelito', 'Castellano Manzano', cuentaB2BSec.Id, '63568187A');
		listaContactos.add(contacto1);
		listaContactos.add(contacto2);
		insert listaContactos;
		Baipas.deshabilitarVariableControl();
	}

	@isTest static void testEM1(){
		Test.startTest();
		inicializarVariables();
		EmailMessage em = new EmailMessage();
		em.ParentId = casoB2B.Id;
		em.FromName = 'Remitente';
		em.FromAddress = 'remitente@mail.com';
		em.ToAddress = 'destinatario@mail.com';
		em.Subject = 'Reclamación:Prueba';
		em.TextBody = 'Texto del Correo';
		em.Incoming = true;

		casoB2B.CAS_TXT_Num_Caso_CIA__c = 'Prueba';

		Baipas.establecerVariableControl();
		update casoB2B;
		Baipas.deshabilitarVariableControl();

		insert em;
		em.TextBody = 'Texto del Correo Modificado';
		update em;
		delete em;
		Test.stopTest();
	}
}