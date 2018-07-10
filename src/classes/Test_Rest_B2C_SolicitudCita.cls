/**
 * Clase de Test de la Clase Rest_B2C_SolicitudCita
 *
 * @author EVERIS
 *
 */
@isTest
public without sharing class Test_Rest_B2C_SolicitudCita{
	
	private static Account cuentaPrincipal {get; set;}
	private static Account cuentaPrincipal1 {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	private static Contact contacto {get; set;}
	private static Contact contacto1 {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'Q3714152J');
		insert cuentaPrincipal;
		cuentaPrincipal1 = Util_Tests.crearCuentaB2BPpal('B2BPrincipal1', '1546013898675', 'G0569374B');
		insert cuentaPrincipal1;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuentaPrincipal.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
		datetime fechaInicio = datetime.newInstance(2018, 02, 21);
		datetime fechaVencimiento = datetime.newInstance(2018, 02, 24);
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		contacto = Util_Tests.crearContacto('María', 'García Maza');
		contacto.AccountId = cuentaPrincipal.Id;
		insert contacto;
		contacto1 = Util_Tests.crearContacto('Pedro', 'García Martín');
		contacto1.AccountId = cuentaPrincipal1.Id;
		insert contacto1;
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		
		Rest_B2C_SolicitudCita_RP resultado = new Rest_B2C_SolicitudCita_RP();
		List<ServiceAppointment> numCita = [SELECT AppointmentNumber FROM ServiceAppointment WHERE Id =: citaServicio.Id];
		//Caso OK
		resultado = Rest_B2C_SolicitudCita.setAppointment('2018-01-20', '05', '04', caso.Id, '','', 'María', 'Vega', 'López', 'mariav@prueba.com', '945786690', '654231245', numCita[0].AppointmentNumber);
		resultado = Rest_B2C_SolicitudCita.setAppointment('2018-01-24', '05', '04', caso.Id, contacto.Id,cuentaPrincipal.Id, '', '', '', '', '', '', numCita[0].AppointmentNumber);
		//Caso KO. No existe el caso
		resultado = Rest_B2C_SolicitudCita.setAppointment('2018-01-20', '05', '04', '9909E000007HElb', '','', 'María', 'Vega', 'López', 'mariav@prueba.com', '945786690', '654231245', numCita[0].AppointmentNumber);
		//Caso KO. No existe el contacto
		resultado = Rest_B2C_SolicitudCita.setAppointment('2018-01-24', '05', '04', caso.Id, '0040E00000Pb8WB',cuentaPrincipal.Id, '', '','', '', '', '', numCita[0].AppointmentNumber);
		resultado = Rest_B2C_SolicitudCita.setAppointment('2018-01-24', '05', '04', caso.Id, contacto1.Id,cuentaPrincipal.Id, '', '', '','', '', '', numCita[0].AppointmentNumber);
		
		
		test.stopTest();
	}
    @isTest static void setAppointment(){

		Rest_B2C_SolicitudCita.setAppointment('','','','','','','','','','','','','');
		Rest_B2C_SolicitudCita.setAppointment('a','a','a','a','a','a','a','a','a','a','a','a','a');
		inicializarVariables();

		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,'','','','','','','','','a');
		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,'','','','','','a@a','','a','a');
		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,contacto.Id,'','a','a','a','a','a','a','a');
		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,'',cuentaPrincipal.Id,'a','a','a','a','a','a','a');

		compania.RecordTypeId= Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1);
		update compania;

		cuentaPrincipal.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2);
		cuentaPrincipal.Type = Label.CUE_TIPO_CLIENTEFINAL;
		cuentaPrincipal.CUE_LKP_Cuenta_principal__c = caso.CAS_LKP_Compania__c;
		update cuentaPrincipal;

		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,'',cuentaPrincipal.Id,'a','a','a','a','a','a','a');

		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,contacto.Id,cuentaPrincipal.Id,'a','a','a','a','a','a','a');
		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,'','','','a','a','a','a','a','a');

		contacto.AccountId=cuentaPrincipal.Id;

		update contacto;

		Rest_B2C_SolicitudCita.setAppointment('a','a','a',caso.Id,contacto.Id,cuentaPrincipal.Id,'a','a','a','a','a','a','a');
	}

}