@isTest 
public without sharing class Test_Rest_validarCodigoAsistencia {
	
	private static Account cuentaPrincipal {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
    private static Version_ContratoServicio__c versionPoliza {get; set;}
	private static Case caso {get; set;}
	private static Case caso1 {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	private static WorkOrder ordenTrabajo1 {get; set;}
	private static ServiceAppointment citaServicio1 {get; set;}
	private static FSL__Scheduling_Policy__c politicaGeo {get; set;}
	private static OperatingHours horaFuncionamiento {get; set;}
	private static TimeSlot timeSlot1 {get; set;}
	private static TimeSlot timeSlot2 {get; set;}
	private static TimeSlot timeSlot3 {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'G8425767D');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','S2787313B');
        compania.CUE_CAS_BOManual__c = true;
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
        poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuentaPrincipal.Id,productoCIA.Id);
		insert poliza;
        versionPoliza = Util_Tests.crearVersionPoliza(poliza.Id, Date.newInstance(2018, 06, 12));
		insert versionPoliza;
		poliza.POL_LKP_Version_Actual__c = versionPoliza.Id;
		update poliza;
        
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		insert caso;
		caso1 = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		insert caso1;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '997';
		insert ordenTrabajo;
		datetime fechaInicio = datetime.newInstance(2018, 02, 21);
		datetime fechaVencimiento = datetime.newInstance(2018, 02, 24);
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		ordenTrabajo1 = Util_Tests.crearOrdenTrabajo('20210.0','21',tipoTrabajo.Id,caso1.Id);
		ordenTrabajo1.AccountId = cuentaPrincipal.Id;
		ordenTrabajo1.Status = '323';
		insert ordenTrabajo1;
		datetime fechaInicio1 = datetime.newInstance(2018, 02, 22);
		datetime fechaVencimiento1 = datetime.newInstance(2018, 02, 25);
		citaServicio1 = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio1, fechaVencimiento1);
		citaServicio1.Status = 'Pte. de asignar';
		citaServicio1.ParentRecordId = ordenTrabajo1.Id;
		insert citaServicio1;
		ordenTrabajo1.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo1;
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
	@isTest static void TestOK(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/validarCodigoAsistencia';
		req.addParameter('IdCaso', caso.Id);

		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_validarCodigoAsistencia_RP resultado = new Rest_validarCodigoAsistencia_RP();
		resultado = Rest_validarCodigoAsistencia.doGet();
		system.debug(resultado.message);
		
		test.stopTest();
	}
	
	/*Test KO. Existe el caso con WO pero no están en estado inactivo*/
	@isTest static void TestKO1(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/validarCodigoAsistencia';
		req.addParameter('IdCaso', caso1.Id);

		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_validarCodigoAsistencia_RP resultado = new Rest_validarCodigoAsistencia_RP();
		resultado = Rest_validarCodigoAsistencia.doGet();
		system.debug(resultado.message);
		
		test.stopTest();
	}
	
	/*Test KO. No existe el caso*/
	@isTest static void TestKO2(){
		inicializarVariables();
		test.startTest();
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/validarCodigoAsistencia';
		req.addParameter('IdCaso', '9009E000007HJZp');

		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Rest_validarCodigoAsistencia_RP resultado = new Rest_validarCodigoAsistencia_RP();
		resultado = Rest_validarCodigoAsistencia.doGet();
		system.debug(resultado.message);
		
		test.stopTest();
	}
}