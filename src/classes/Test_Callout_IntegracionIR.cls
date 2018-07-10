/**
 * Clase de Test de la Clase Callout_IntegracionIR
 * 
 */
@isTest
public without sharing class Test_Callout_IntegracionIR extends TestSetup{
	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	@testSetup
	public static void test(){
		TestSetup loadData = new Test_Callout_IntegracionIR();
		loadData.setTestData();
	}

	@isTest
	public static void TestNoComillas(){
		test.startTest();
		Movimiento_IR__c datosMovIR= new Movimiento_IR__c();
		datosMovIR.MIR_CAS_ENVIADO__c = False;
		datosMovIR.MIR_TXT_CLIENTE_VALOR__c = '47531512B';
		datosMovIR.Name = 'PruebaTest';
		datosMovIR.MIR_TXT_OPERACION__c = 'insert';
		datosMovIR.MIR_DAT_fechaCierre__c = Datetime.now();
        datosMovIR.MIR_TXT_NOMBRE__c = 'Nombre';
		insert datosMovIR;
		system.debug('Test Callout_IntegracionIR');
		Callout_IntegracionIR.updateDatos();
		test.stopTest();
	}

	@isTest
	public static void TestComillasDobles(){
		test.startTest();
		Movimiento_IR__c datosMovIR= new Movimiento_IR__c();
		datosMovIR.MIR_CAS_ENVIADO__c = False;
		datosMovIR.MIR_TXT_CLIENTE_VALOR__c = '47531512B';
		datosMovIR.Name = 'PruebaTest';
		datosMovIR.MIR_TXT_OPERACION__c = 'insert';
		datosMovIR.MIR_DAT_fechaCierre__c = Datetime.now();
        datosMovIR.MIR_TXT_NOMBRE__c = 'Avenida. de Bilbao 99 D -  CC."Los Ochos"  Sierrapando,  Torrelavega (Cantabria)';
		insert datosMovIR;
		system.debug('Test Callout_IntegracionIR');
		Callout_IntegracionIR.updateDatos();
		test.stopTest();
	}

	@isTest
	public static void TestComillasSimples(){
		test.startTest();
		Movimiento_IR__c datosMovIR= new Movimiento_IR__c();
		datosMovIR.MIR_CAS_ENVIADO__c = False;
		datosMovIR.MIR_TXT_CLIENTE_VALOR__c = '47531512B';
		datosMovIR.Name = 'PruebaTest';
		datosMovIR.MIR_TXT_OPERACION__c = 'insert';
		datosMovIR.MIR_DAT_fechaCierre__c = Datetime.now();
        datosMovIR.MIR_TXT_NOMBRE__c = 'Avenida. de Bilbao 99 D -  CC.L\'Ochos  Sierrapando,  Torrelavega (Cantabria)';
		insert datosMovIR;
		system.debug('Test Callout_IntegracionIR');
		Callout_IntegracionIR.updateDatos();
		test.stopTest();
	}

	@isTest
	public static void TestComillasDoblesYSimples(){
		test.startTest();
		Movimiento_IR__c datosMovIR= new Movimiento_IR__c();
		datosMovIR.MIR_CAS_ENVIADO__c = False;
		datosMovIR.MIR_TXT_CLIENTE_VALOR__c = '47531512B';
		datosMovIR.Name = 'PruebaTest';
		datosMovIR.MIR_TXT_OPERACION__c = 'insert';
		datosMovIR.MIR_DAT_fechaCierre__c = Datetime.now();
        datosMovIR.MIR_TXT_NOMBRE__c = 'Avenida. de Bilbao 99 D -  CC."L\'Ochos"  Sierrapando,  Torrelavega (Cantabria)';
		insert datosMovIR;
		system.debug('Test Callout_IntegracionIR');
		Callout_IntegracionIR.updateDatos();
		test.stopTest();
	}

}