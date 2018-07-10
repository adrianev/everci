/**
 * Clase de Test de la Clase Rest_B2B2C_FranjasCambioCita
 *
 * @author EVERIS
 *
 */
@isTest
public without sharing class Test_Rest_B2B2C_FranjasCambioCita {
	
	private static Account cuentaPrincipal {get; set;}
	private static Account cuentaSecundaria {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
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
		compania = Util_Tests.crearCuentaCompania('Worten','507513','S5735385F');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('Worten - TV','01',compania.ID);
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
		datetime fechaInicio = datetime.newInstance(2018, 05, 22);
		datetime fechaVencimiento = datetime.newInstance(2018, 05, 31);
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		citaServicio.CSE_SEL_Gremio__c = '21';
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		
		Rest_B2B2C_FranjasCambioCita.Resultado respuesta = new Rest_B2B2C_FranjasCambioCita.Resultado();
		List<ServiceAppointment> sa = [SELECT AppointmentNumber, CSE_SEL_Gremio__c, Id FROM ServiceAppointment WHERE Id =: citaServicio.Id];
		List<Case> casoList = [SELECT CAS_CAS_Urgente__c, Id FROM Case WHERE Id =: caso.Id];
		List<Account> cuentaList = [SELECT CUE_CAS_Ola_calor__c, Id FROM Account WHERE Id =: cuentaPrincipal.Id];
		
		//Caso KO. No existe la cita de servicio
		respuesta = Rest_B2B2C_FranjasCambioCita.doPost('2010-05-22', 'SA-2222');
		//Caso KO. Formato de datos no correcto
		respuesta = Rest_B2B2C_FranjasCambioCita.doPost('2010-05-22', 'SA-2222444444555555');
		//Caso OK. Tiene gremio 'Aire acondicionado', urgente = false, ola de calor = false
		respuesta = Rest_B2B2C_FranjasCambioCita.doPost('2010-05-22', sa[0].AppointmentNumber);
		
		//Caso OK. Tiene gremio 'Aire acondicionado', urgente = true, ola de calor = false
		casoList[0].CAS_CAS_Urgente__c = true;
		Baipas.establecerVariableControl();
		update casoList[0];
		respuesta = Rest_B2B2C_FranjasCambioCita.doPost('2010-05-22', sa[0].AppointmentNumber);
		
		//Caso OK. Tiene gremio 'Aire acondicionado', urgente = false, ola de calor = true
		casoList[0].CAS_CAS_Urgente__c = false;
		cuentaList[0].CUE_CAS_Ola_calor__c = true;
		Baipas.establecerVariableControl();
		update casoList[0];
		update cuentaList[0];
		respuesta = Rest_B2B2C_FranjasCambioCita.doPost('2010-05-22', sa[0].AppointmentNumber);
		
		test.stopTest();
	}
}