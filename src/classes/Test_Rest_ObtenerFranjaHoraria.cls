/**
 * Clase de Test de la Clase Rest_ObtenerFranjaHoraria
 *
 */

@isTest
public without sharing class Test_Rest_ObtenerFranjaHoraria extends TestSetup {
	
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get;set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	private static FSL__Scheduling_Policy__c politicaGeo {get; set;}
	private static OperatingHours horaFuncionamiento {get; set;}
	private static TimeSlot timeSlot1 {get; set;}
	private static TimeSlot timeSlot2 {get; set;}
	private static TimeSlot timeSlot3 {get; set;}
	
	@isTest static void inicializarVariablesMembership(){
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('Membership','1999','X1234567X');
		insert compania;
		cuenta = Util_Tests.crearCuentaAsegurado('ClienteMembership', '132456', 'prueba@prueba.es', '12345678Z',
			'María', 'García', 'Montes');
		cuenta.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('MEMBERSHIP - Hogar','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('MEMBERSHIP - MEMBERSHIP SINIESTROS','01',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('8899767', compania.Id, cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoSini(poliza.Id,cuenta.Id, compania.Id);
		caso.CAS_TXT_Num_Caso_HS__c = '2018000002';
		caso.CAS_TXT_Direccion__c = 'CALLE Chimbo 22 2 B';
		caso.CAS_TXT_DirRiesgo_CP__c = '28025';
		caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '28';
		caso.Type = '1';
		caso.Status = '001';
		caso.CAS_DIV_Importe_Total__c = 0;
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		ordenTrabajo.Status = '002';
		ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c = date.newInstance(2018, 01, 30);
		ordenTrabajo.OTR_SEL_Rango_Primera_Cita__c = '09';
		insert ordenTrabajo;
		datetime fechaInicio = datetime.newInstance(2018, 03, 12);
		datetime fechaVencimiento = datetime.newInstance(2018, 03, 24);
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		politicaGeo = Util_Tests.crearPolitica('Política con objetivo Ranking');
		insert politicaGeo;
		horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario por defecto','Europe/Paris');
        insert horaFuncionamiento;
        timeSlot1 = new TimeSlot();
        timeSlot1.OperatingHoursId = horaFuncionamiento.Id;
        timeSlot1.Type = 'Normal';
        timeSlot1.DayOfWeek = 'Monday';
        timeSlot1.StartTime = Time.newInstance(10,00,00,00);
        timeSlot1.EndTime = Time.newInstance(12,00,00,00);
        insert timeSlot1;
        timeSlot2 = new TimeSlot();
        timeSlot2.OperatingHoursId = horaFuncionamiento.Id;
        timeSlot2.Type = 'Normal';
        timeSlot2.DayOfWeek = 'Monday';
        timeSlot2.StartTime = Time.newInstance(12,00,00,00);
        timeSlot2.EndTime = Time.newInstance(14,00,00,00);
        insert timeSlot2;
        timeSlot3 = new TimeSlot();
        timeSlot3.OperatingHoursId = horaFuncionamiento.Id;
        timeSlot3.Type = 'Normal';
        timeSlot3.DayOfWeek = 'Tuesday';
        timeSlot3.StartTime = Time.newInstance(10,00,00,00);
        timeSlot3.EndTime = Time.newInstance(12,00,00,00);
        insert timeSlot3;
        
	}
	
	/*Test*/
	@isTest static void TestKO1(){
		inicializarVariablesMembership();
		test.startTest();
		
		Rest_ObtenerFranjaHoraria_RP franjas = new Rest_ObtenerFranjaHoraria_RP();

		List<ServiceAppointment> numCita = [SELECT Id, AppointmentNumber FROM ServiceAppointment WHERE Id =: citaServicio.Id limit 1];
		system.debug('SVV. Numero de Cita: ' + numCita[0].AppointmentNumber);
		franjas = Rest_ObtenerFranjaHoraria.getSlots(numCita[0].AppointmentNumber);
		
		Rest_B2C_SolicitudCita_RP cita = new Rest_B2C_SolicitudCita_RP();
		cita = Rest_ObtenerFranjaHoraria.setAppointment('2018-03-12', '07', numCita[0].AppointmentNumber, '01');
		cita = Rest_ObtenerFranjaHoraria.setAppointment('2018-03-12', '07', 'SA-99000', '01');

		test.stopTest();
	}
}

	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	 /*
	@testSetup
	public static void test(){
		TestSetup loadData = new Test_Rest_ObtenerFranjaHoraria();
		loadData.setTestData();
	}

	@isTest static void testOK1() {
		test.startTest();
		Rest_ObtenerFranjaHoraria_RP franjas = new Rest_ObtenerFranjaHoraria_RP();

		List<WorkOrder> woCita = [SELECT Id FROM WorkOrder WHERE OTR_TXT_Num_OrdenTrabajo_HS__c = '17210.0'];
		List<ServiceAppointment> numCita = [SELECT AppointmentNumber FROM ServiceAppointment WHERE ParentRecordId =: woCita[0].Id limit 1];

		franjas = Rest_ObtenerFranjaHoraria.getSlots(numCita[0].AppointmentNumber);
		franjas = Rest_ObtenerFranjaHoraria.getSlots('SA-99000', '01');

		Rest_B2C_SolicitudCita_RP cita = new Rest_B2C_SolicitudCita_RP();
		cita = Rest_ObtenerFranjaHoraria.setAppointment('2017-12-12', '04', 'SA-18001', '01');
		cita = Rest_ObtenerFranjaHoraria.setAppointment('2017-11-12', '08', 'SA-18001', '01');
		cita = Rest_ObtenerFranjaHoraria.setAppointment('2017-12-12', '04', 'SA-99000', '01');

		test.stopTest();
	}
}*/