/**
 * Clase de Test de la Clase Rest_B2BB2B2C_CreacionServicio
 *
 * @author EVERIS
 *
 */
@isTest
public without sharing class Test_Rest_B2BB2B2C_CreacionServicio {
	
	private static Account cuentaPrincipal {get;set;}
	private static Account cuentaSecundaria {get;set;}
	private static Account cuentaCompania {get;set;}
    private static Procedencia__c procedencia {get;set;} 
    private static Baremo__c baremo {get;set;}
    private static Account puntoDeVenta {get;set;}
    private static WorkType tipoTrabajo {get;set;}
	
	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','123456', 'Q1523700A');
		insert cuentaPrincipal;
		
		cuentaSecundaria = Util_Tests.crearCuentaB2BSec('B2BSecundaria','987654', cuentaPrincipal.Id, 'Q3999970A');
		cuentaSecundaria.Type= '03'; 
		insert cuentaSecundaria;
		
		cuentaCompania = Util_Tests.crearCuentaCompania('Worten','507513','X1234567X');
		cuentaCompania.CUE_CAS_BOManual__c = true;
		insert cuentaCompania;

		puntoDeVenta=Util_Tests.crearCuentaB2BSec('WortenLeganes','RP2224227790888', cuentaPrincipal.Id, 'Q3999970B');
		puntoDeVenta.RecordType=[SELECT Id, Name FROM RecordType WHERE Name = 'Cliente B2B/B2B2C secundario'];
		puntoDeVenta.RecordTypeId=puntoDeVenta.RecordType.Id;
		puntoDeVenta.Type= '01';
		insert puntoDeVenta;


		system.debug([SELECT Type, RecordType.Name FROM Account WHERE ID = :puntoDeVenta.Id]);
		system.debug(puntoDeVenta.Type == '01');
		system.debug(puntoDeVenta.RecordType.Name == 'Cliente B2B/B2B2C secundario');

		baremo=new Baremo__c();
		baremo.BAR_LKP_Compania__c=cuentaPrincipal.Id;
		baremo.BAR_TXT_Identificador__c='ABAA33';
		baremo.BAR_SEL_Gremio__c= '21';
		insert baremo;
		
		tipoTrabajo = Util_Tests.crearTipoTrabajo('texto manual', '21', 2);
		insert tipoTrabajo;

		// Vincular automáticamente la Línea de Contrato Correctiva correspondiente
		// si el caso es un Servicio B2B/B2B2C Correctivo
		
        Baipas.deshabilitarVariableControl();
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		
		Rest_B2BB2B2C_CreacionServicio_RP resultado = new Rest_B2BB2B2C_CreacionServicio_RP();
		
		//Caso KO. No se encuentra el cliente
		resultado = Rest_B2BB2B2C_CreacionServicio.doPost('0020E00220coAzc','','','21','04','Presupuesto de cocina','','0','0');
		
		//Caso KO. No es de tipo B2B
		resultado = Rest_B2BB2B2C_CreacionServicio.doPost(cuentaPrincipal.Id,'','','21','03','Presupuesto de cocina','','0','0');
		
		//Caso KO. No existe el gremio
		resultado = Rest_B2BB2B2C_CreacionServicio.doPost(cuentaPrincipal.Id,'','','99','04','Presupuesto de cocina','','0','0');
		
		//Caso OK
		List<Baremo__c> baremoId = [SELECT Id, BAR_TXT_Identificador__c FROM Baremo__c WHERE Id =: baremo.Id];
		resultado = Rest_B2BB2B2C_CreacionServicio.doPost(cuentaSecundaria.Id,cuentaCompania.Id,puntoDeVenta.Id,'21','04','2018-05-22|Presupuesto de cocina',String.valueOf(baremoId[0].BAR_TXT_Identificador__c),'1','0');
		
/*
		//Primer return
		resultado = Rest_B2BB2B2C_CreacionServicio.doPost(cuentaPrincipal.Id, '', '21', '04', 'Presupuesto de cocina','','','1','1');

		//Catch del final
		Rest_B2BB2B2C_CreacionServicio.doPost(cuentaPrincipal.Id, '', '', '04', Label.CAS_ORIGEN_LANDING_B2B2C,'','','','');

		//Codigo tras insercion del caso
		Rest_B2BB2B2C_CreacionServicio.doPost(cuentaSecundaria.Id, cuentaPrincipal.Id, puntoDeVenta.Id, '04', Label.CAS_ORIGEN_LANDING_B2B2C,'','','1','1');
		

		//Caso con baremo en parametros
		Rest_B2BB2B2C_CreacionServicio.doPost(cuentaPrincipal.Id, cuentaCompania.Id, cuentaPrincipal.Id, '04', Label.CAS_ORIGEN_LANDING_B2B2C,'','hola','0','0');
		insert baremo;
		//Caso con baremo en base de datos
		Rest_B2BB2B2C_CreacionServicio.doPost(cuentaPrincipal.Id, cuentaCompania.Id, '', '04', Label.CAS_ORIGEN_LANDING_B2B2C,'',[SELECT BAR_TXT_Identificador__c FROM Baremo__c WHERE Id = :baremo.Id].get(0).BAR_TXT_Identificador__c,'0','0');
*/
		test.stopTest();
	}
}