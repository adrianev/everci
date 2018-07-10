/**
 * Clase de Test de la Clase Rest_B2B_ConsultaClientes
 *
 * @author EVERIS
 *
 */
@isTest
public without sharing class Test_Rest_B2B_ConsultaClientes extends TestSetup{
	
	private static Account cuentaPrincipal {get; set;}
	private static VDN_Compania__c vdn {get; set;}
	private static Procedencia__c procedencia {get; set;}
	private static Procedencia__c procedencia1 {get; set;}
	private static Procedencia__c procedencia2 {get; set;}
	private static Contract contrato {get; set;}
	private static Contact contacto {get; set;}
	private static Contact contacto1 {get; set;}
	private static Contact contacto2 {get; set;}
	
	private static Account cuentaSecundaria {get; set;}
	private static Contact contacto3 {get; set;}
	private static Contact contacto4 {get; set;}
	
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'V7070692D');
		cuentaPrincipal.ShippingStreet = 'Camino del Cerro de los Gamos 1';
		cuentaPrincipal.ShippingCity = 'Pozuelo de Alarcon2	';
		cuentaPrincipal.ShippingState = 'Madrid';
		cuentaPrincipal.ShippingPostalCode = '28225';
		cuentaPrincipal.ShippingCountry = 'ES';
		cuentaPrincipal.CUE_CAS_Activado__c = true;
		cuentaPrincipal.CUE_EMA_Email__c = 'holidaygymhs@gmail.com';
		cuentaPrincipal.CUE_CAS_Permite_Servicio_CodActivac__c = false;
		cuentaPrincipal.CUE_CAS_No_permite_Servicio_B2B2C__c = false;
        cuentaPrincipal.CUE_DAT_Inicio_ola_calor__c = Date.newInstance(2018, 06, 01);
        cuentaPrincipal.CUE_DAT_Fin_ola_calor__c = Date.newInstance(2018, 09, 01);
		insert cuentaPrincipal;
		vdn = Util_Tests.crearVDNCompania('2208', cuentaPrincipal.Id);
		insert vdn;
		procedencia = Util_Tests.crearProcedencia(0,0,0,0,10000000,cuentaPrincipal.Id,'555001','CAS_Servicio_B2B_B2B2C;CAS_Solicitud_de_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Gremios_Disp__c = '01;03;02;05;06;07;10;31';
		insert procedencia;
		procedencia1 = Util_Tests.crearProcedencia(0,0,0,0,10000000,cuentaPrincipal.Id,'125302','CAS_Solicitud_de_Servicio_B2C;CAS_Servicio_B2C');
		procedencia1.PROC_SEL_Gremios_Disp__c = '01;03;02;04;05;06;07;08;09;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;33;34;35;36;37;38;39;40;41;42;43;44;45;46;47;48;49;50;51;52;53;55;56;57;58;70;54;59;60;61;62;63;71;72;73;74;75;64;76;77;78;79';
		insert procedencia1;
		procedencia2 = Util_Tests.crearProcedencia(1,1,1,1,1,cuentaPrincipal.Id,'200293','CAS_Servicio_B2C');
		procedencia2.PROC_SEL_Gremios_Disp__c = '21';
		insert procedencia2;
		contrato = Util_Tests.crearContrato(cuentaPrincipal.Id, 'Contrato Básico');
		contrato.CTR_NUM_Version_Contrato__c = 1;
		insert contrato;
		contacto = Util_Tests.crearContacto('Maria','Sarmiento',cuentaPrincipal.Id,'1519007206758');
		contacto.CON_CAS_Contacto_principal__c = false;
		contacto.Email = 'compania@prueba.es';
		insert contacto;
		contacto1 = Util_Tests.crearContacto('Francisco','Alegre Pérez',cuentaPrincipal.Id,'1519750627279');
		contacto1.CON_CAS_Contacto_principal__c = false;
		contacto1.Email = 'compania@prueba.es';
		insert contacto1;
		contacto2 = Util_Tests.crearContacto('Juana','Gómez',cuentaPrincipal.Id,'1518113254609');
		contacto2.CON_CAS_Contacto_principal__c = true;
		contacto2.Email = 'compania@prueba.es';
		insert contacto2;
		
		//Creación de un cliente secundario con sus datos necesarios
		cuentaSecundaria = Util_Tests.crearCuentaB2BSec('B2BSecundaria', '1515595538177', cuentaPrincipal.Id, 'P6225905F');
		cuentaSecundaria.Type = '01';
		cuentaSecundaria.CUE_CAS_Permite_Servicio_CodActivac__c = false;
		cuentaSecundaria.CUE_CAS_No_permite_Servicio_B2B2C__c = false;
		cuentaSecundaria.CUE_CAS_Activado__c = true;
		cuentaSecundaria.ShippingCity = 'Madrid';
		cuentaSecundaria.ShippingCountry = 'ES';
		cuentaSecundaria.ShippingPostalCode = '28020';
		cuentaSecundaria.ShippingState = 'Madrid';
		cuentaSecundaria.ShippingStreet = 'Calle del Condado de Treviño, 33';
		insert cuentaSecundaria;
		contacto3 = Util_Tests.crearContacto('Angel','Muñoz',cuentaSecundaria.Id,'1516309099939');
		contacto3.CON_CAS_Contacto_principal__c = true;
		contacto3.Email = 'compania@prueba.es';
		insert contacto3;
		contacto4 = Util_Tests.crearContacto('Rocio','Gil',cuentaSecundaria.Id,'1515595686834');
		contacto4.CON_CAS_Contacto_principal__c = false;
		contacto4.Email = 'compania@prueba.es';
		insert contacto4;
		
	}
	
	/*Test*/
	@isTest static void Test(){
		
		List<String> tipo = new List<String>();
        List<String> tipo1 = new List<String>();
		inicializarVariables();
		test.startTest();
		
		//Caso OK, cliente principal
		Rest_B2B_ConsultaClientes.doPost('1516013658675', tipo);
		//Caso OK, cliente secundario
		tipo.add('01');
		Rest_B2B_ConsultaClientes.doPost('1515595538177', tipo);
		//Caso KO. No existe cliente
		Rest_B2B_ConsultaClientes.doPost('4522595568144', tipo);
        //Caso KO. Formato de tipo mal introducido
        tipo.add(' 03');
		Rest_B2B_ConsultaClientes.doPost('1515595538177', tipo);
        //Caso KO. Formato de tipo mal introducido
        tipo1.add(' 01');
		Rest_B2B_ConsultaClientes.doPost('1515595538177', tipo1);
        
        cuentaPrincipal.CUE_DAT_Inicio_ola_calor__c = Date.newInstance(2018, 07, 01);
        cuentaPrincipal.CUE_DAT_Fin_ola_calor__c = Date.newInstance(2018, 09, 01);
        Baipas.establecerVariableControl();
		update cuentaPrincipal;
        //Caso OK. No está en ola de calor
        tipo.clear();
        tipo.add('01');
		Rest_B2B_ConsultaClientes.doPost('1516013658675', tipo);
		
		test.stopTest();
	}
	
}