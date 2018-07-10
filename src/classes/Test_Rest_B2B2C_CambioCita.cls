/**
 * Clase de Test de la Clase Rest_B2B2C_CambioCita
 *
 * @author EVERIS
 *
 */
@isTest(SeeAllData=true)
public without sharing class Test_Rest_B2B2C_CambioCita {
	
	private static Account cuentaPrincipal {get; set;}
	private static Account cuentaSecundaria {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Version_ContratoServicio__c versionPoliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '2224', 'G69746881');
		cuentaPrincipal.ShippingPostalCode = '28028';
		insert cuentaPrincipal;
		cuentaSecundaria = Util_Tests.crearCuentaB2BSec('B2BSecundaria','22242', cuentaPrincipal.Id, 'R7553064B');
		insert cuentaSecundaria;
		compania = Util_Tests.crearCuentaCompania('Worten','50751322','S5735385F');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('Worten - TV','01',compania.ID);
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
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
        
        caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
        update caso;
		/*datetime fechaInicio = datetime.newInstance(2018, 05, 22);
		datetime fechaVencimiento = datetime.newInstance(2018, 05, 31);
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		citaServicio.CSE_SEL_Gremio__c = '21';
        citaServicio.CSE_CAS_Cambio_de_cita__c  = true;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;*/
        Baipas.deshabilitarVariableControl();
	}
	
	/*Test*/
	@isTest
    static void Test(){
		inicializarVariables();
		test.startTest();
		
		Rest_B2B2C_CambioCita.Resultado respuesta = new Rest_B2B2C_CambioCita.Resultado();
		List<ServiceAppointment> sa = [SELECT AppointmentNumber, CSE_SEL_Gremio__c, Id FROM ServiceAppointment WHERE ParentRecordId =: ordenTrabajo.Id];
		List<Case> casoList = [SELECT CAS_CAS_Urgente__c, Id FROM Case WHERE Id =: caso.Id];
		List<Account> cuentaList = [SELECT CUE_CAS_Ola_calor__c, Id FROM Account WHERE Id =: cuentaPrincipal.Id];
		
		//Caso KO. Formato de datos no correcto
		respuesta = Rest_B2B2C_CambioCita.setAppointment('', '07', sa[0].AppointmentNumber, 'test cambio cita', Date.newInstance(2018,05,20));
		//Caso KO. No existe la cita
		respuesta = Rest_B2B2C_CambioCita.setAppointment('2018-05-28', '07', 'SA-2222', 'test cambio cita', Date.newInstance(2018,05,20));
		//Caso OK.
		respuesta = Rest_B2B2C_CambioCita.setAppointment('2018-05-28', '07', sa[0].AppointmentNumber, 'test cambio cita', Date.newInstance(2018,05,20));
		
		test.stopTest();
	}
}