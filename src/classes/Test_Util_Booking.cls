@isTest
public without sharing class Test_Util_Booking {
	
	private static Account cuentaPrincipal {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	private static FSL__Scheduling_Policy__c politicaGeo1 {get; set;}
	private static FSL__Scheduling_Policy__c politicaGeo2 {get; set;}
	
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'Y2517623B');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','N2508906A');
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
		ordenTrabajo.Status = '997';
		insert ordenTrabajo;
		datetime fechaInicio = datetime.newInstance(2018, 04, 11);
		datetime fechaVencimiento = datetime.newInstance(2018, 04, 24);
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		List<FSL__Scheduling_Policy__c> listaPoliticas = new List<FSL__Scheduling_Policy__c>();
		politicaGeo1 = Util_Tests.crearPolitica('Política con objetivo Ranking');
		listaPoliticas.add(politicaGeo1);
		politicaGeo2 = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		listaPoliticas.add(politicaGeo2);
		insert listaPoliticas;
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		
		list<ServiceAppointment> citaServicio = [SELECT AppointmentNumber FROM ServiceAppointment WHERE ParentRecordId =: ordenTrabajo.Id];
		Rest_B2C_SolicitudCita_RP ConfirmarCita = Util_Booking.setAppointment('2018-04-12', '07', citaServicio[0].AppointmentNumber, '04');
		
		test.stopTest();
	}
	
	/*Test*/
	@isTest static void Test1(){
		inicializarVariables();
		
		OperatingHours horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario por defecto','Europe/Paris');
		insert horaFuncionamiento;
		TimeSlot timeSlot1 = new TimeSlot();
		timeSlot1.OperatingHoursId = horaFuncionamiento.Id;
		timeSlot1.Type = 'Normal';
		timeSlot1.DayOfWeek = 'Monday';
		timeSlot1.StartTime = Time.newInstance(10,00,00,00);
		timeSlot1.EndTime = Time.newInstance(12,00,00,00);
		insert timeSlot1;
		TimeSlot timeSlot2 = new TimeSlot();
		timeSlot2.OperatingHoursId = horaFuncionamiento.Id;
		timeSlot2.Type = 'Normal';
		timeSlot2.DayOfWeek = 'Monday';
		timeSlot2.StartTime = Time.newInstance(12,00,00,00);
		timeSlot2.EndTime = Time.newInstance(14,00,00,00);
		insert timeSlot2;
		TimeSlot timeSlot3 = new TimeSlot();
		timeSlot3.OperatingHoursId = horaFuncionamiento.Id;
		timeSlot3.Type = 'Normal';
		timeSlot3.DayOfWeek = 'Tuesday';
		timeSlot3.StartTime = Time.newInstance(10,00,00,00);
		timeSlot3.EndTime = Time.newInstance(12,00,00,00);
		insert timeSlot3;
		
		test.startTest();
		
		//List<Rest_Franja_RP> Franjas = Util_Booking.BookingFranjas(cuentaPrincipal.Id, caso.Id, tipoTrabajo.Id, '04');
		
		test.stopTest();
	}
}