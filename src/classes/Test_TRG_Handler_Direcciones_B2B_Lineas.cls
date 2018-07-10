@isTest
public without sharing class Test_TRG_Handler_Direcciones_B2B_Lineas extends TestSetup{
	
	private static void InicializarVariables(){
		
		Baipas.establecerVariableControl();
		Account compania = Util_Tests.crearCuentaB2BPpal('Holiday Gym','2000','X1234567X');
		insert compania;		
		Account cuenta = Util_Tests.crearCuentaB2BSec('Holiday Gym2','1000',compania.Id,'X1134567X');
		insert cuenta;
		//Creo e inserto Contratos
		Contract contrato = Util_Tests.crearContrato(cuenta.Id,'b2b_p_1');
		insert contrato;
		//Creo e inserto linea de contrato
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '21', 2);
		insert tipoTrabajo;
		Linea_Contrato__c lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_PREVENTIVO);
		lineaContrato.LDC_LKP_Tipo_Trabajo__c = tipoTrabajo.Id;
		lineaContrato.LDC_NUM_Preaviso_dias__c = 5;
		insert lineaContrato;
		Tareas_Tipo_Trabajo__c tareaTipoTrabajo = Util_Tests.crearTareaTipoTrabajo('Tarea para un tipo de trabajo', tipoTrabajo.Id);
		insert tareaTipoTrabajo;
		Tarea_Linea_Contrato__c tareaLineaContrato = Util_Tests.crearTareaLineaContrato(lineaContrato.Id, tareaTipoTrabajo.Id);
		insert tareaLineaContrato;
		Baipas.deshabilitarVariableControl();
		//Creo e inserto dirección dec linea de contrato
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccion = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id, lineaContrato.Id, 8);
		direccion.DLC_DAT_Activacion_primer_servicio__c = DateTime.Now().Date();
		insert direccion;
	}	
	
	static testMethod void EliminarVariables(){		
		
		Test.startTest();
		InicializarVariables();
		List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> direccion = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>([SELECT id from Direcciones_B2B_B2B2C_Lineas_de_Contrato__c]);
		delete direccion;
		Test.stopTest();
	}

}