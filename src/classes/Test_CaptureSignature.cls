@isTest
public without sharing class Test_CaptureSignature {
	public static FSL__Scheduling_Policy__c scheduling{get; set;}
	public static ServiceAppointment serviceApp{get; set;}
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account asegurada {get; set;}
	private static Account cuenta {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get;set;}
	private static Festivos__c festivo {get; set;}
	private static OperatingHours horaFuncionamiento {get; set;}
	private static ServiceTerritory territorioServicio {get; set;}
	private static String tipoFirma {get;set;}
	
    private static void inicializarVariables(){
    	Baipas.establecerVariableControl();
    	scheduling = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		insert scheduling;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
    	insert compania;
    	cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
    	insert cuentaPrincipal;
    	asegurada = Util_Tests.crearCuentaB2BSec('Asegurado','1020',cuentaPrincipal.Id,'X1114567X');
    	cuenta = Util_Tests.crearCuentaB2BSec('SegurCaixa1','1021',cuentaPrincipal.Id,'X1111567X');
    	tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
        insert tipoProductoCIA;
        productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', asegurada.Id, cuentaPrincipal.Id, productoCIA.Id);
        insert poliza;
        caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        insert caso;
        tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '51', 5.30);
        insert tipoTrabajo;
        ordenTrabajo = Util_Tests.crearOrdenTrabajo('0000000739','01',tipoTrabajo.Id,caso.Id);
        insert ordenTrabajo;
    	
    	List<ServiceAppointment> listCit = [SELECT Id,ParentRecordId FROM ServiceAppointment WHERE ParentRecordId = :ordenTrabajo.Id];
		system.debug('cita creada automaticamente al crear un workorder '+listCit);
		delete listCit;
		
		datetime mydate = system.today() + 1;
        datetime newDate = mydate.addHours(2);
        //Datetime myDateTime = Datetime.newInstance(2018, 02, 19);
        Datetime myDateTime = Datetime.newInstance(2018, 03,06,12,10,10);
		Datetime dueDate = myDateTime.addDays(2);
        //Datetime arrivalDate = myDateTime.addDays(-2);
        Datetime arrivalDate = myDateTime;
        Datetime arrivalStartDate = arrivalDate.addDays(-15);
	   	serviceApp = Util_Tests.crearCitaServicio('Madrid','España','','','',myDateTime,dueDate);
	   
        
        serviceApp.CreatedById = system.UserInfo.getUserId();
        serviceApp.ArrivalWindowEndTime = arrivalDate;
        serviceApp.ArrivalWindowStartTime = arrivalDate;
        serviceApp.CSE_CAS_Asignada__c = false;
        serviceApp.CSE_CAS_Asignar_como_Urgencias__c = false;
        serviceApp.CSE_CAS_Asignar_territorio_prim_no_franq__c = false;
        serviceApp.CSE_CAS_Asignar_Como_Franquiciado__c = false;
        serviceApp.CSE_CAS_Asignar_Mizad__c = false;
        serviceApp.CSE_CAS_Comprobado_Horario__c = false;
        serviceApp.CSE_CAS_Crear_cita_app__c = false;
        serviceApp.CSE_CAS_Urgente__c = false;
        serviceApp.CSE_NUM_Numero_de_Ofrecimientos__c = 1.0;
        serviceApp.Duration = 2;
        serviceApp.DurationType = 'Hours';
        serviceApp.FSL__Auto_Schedule__c = false;
        serviceApp.FSL__Emergency__c = false;
        serviceApp.FSL__InJeopardy__c = false;
        serviceApp.FSL__InternalSLRGeolocation__Latitude__s = 40.381038;
        serviceApp.FSL__InternalSLRGeolocation__Longitude__s = 	-3.734841;
        serviceApp.FSL__IsFillInCandidate__c = true;
        serviceApp.FSL__IsMultiDay__c = false;
        serviceApp.FSL__Pinned__c = false;
        serviceApp.FSL__Prevent_Geocoding_For_Chatter_Actions__c = false;
        serviceApp.FSL__Same_Day__c = false;
        serviceApp.FSL__Same_Resource__c = false;
        serviceApp.FSL__Schedule_Mode__c = 'Automatic';
        serviceApp.FSL__Scheduling_Policy_Used__c = scheduling.Id;
        serviceApp.FSL__UpdatedByOptimization__c = false;
        serviceApp.FSL__Virtual_Service_For_Chatter_Action__c = false;
        serviceApp.GeocodeAccuracy = 'Zip';
        serviceApp.Latitude = 40.38096;
        serviceApp.Longitude = -3.73376;
        serviceApp.CSE_DAT_Fecha_Proxima_Programacion__c = system.today() +2;
        serviceApp.CSE_DAT_Fecha_Ultima_Programacion__c = system.today() +1;
        serviceApp.status = 'Pte. de asignar';
        serviceApp.ParentRecordId = ordenTrabajo.Id;
    	
    	horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
        insert horaFuncionamiento;
        territorioServicio = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
        territorioServicio.IsActive=true;
        insert territorioServicio;
        serviceApp.ServiceTerritoryId=territorioServicio.Id;
        festivo = Util_Tests.crearFestivo('Nacional',territorioServicio.Id,Date.newInstance(2018, 3, 08));
        insert festivo;
    	insert serviceApp;
    	tipoFirma = 'Firma';
    	Baipas.deshabilitarVariableControl();
    }
    @isTest static void test1(){
		inicializarVariables();
		Test.startTest();
		PageReference pageRef = Page.CaptureSignature;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('idCita',serviceApp.Id);
        ApexPages.currentPage().getParameters().put('idOrdenTrabajo',ordenTrabajo.Id);
        ApexPages.currentPage().getParameters().put('tipoFirma',tipoFirma);
        CaptureSignature pagina = new CaptureSignature();
		
		Test.stopTest();
    }
    @isTest static void test2(){
		inicializarVariables();
		Test.startTest();
		CaptureSignature.saveSignature('cuerpo',serviceApp.Id,'nombreArchivo');
		
		Test.stopTest();
    }
}