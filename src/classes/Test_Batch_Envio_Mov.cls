/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:             everis
Company:        everis España
Description:    <Clase de testeo para Batch_Envio_Mov>

History:  <DESCRIPCIÓN DEL CAMBIO, REQUISITO, INCIDENCIA, CORRECTIVO O MEJORA QUE HIZO ACTUALIZAR/CREAR LA CLASE>

<27/11/2017>                      everis                       <Inicio de clase>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
global without sharing class Test_Batch_Envio_Mov {
	private static String CRON_EXP = '0 0 0 15 3 ? 2032';
	private static Account compania;
	private static Account cuenta;
	private static Tipo_Producto_CIA__c tipoProducto;
	private static Producto_CIA__c producto;
	private static ServiceContract sv;
	private static Procedencia__c procedencia;
	private static Case caso;
	private static Contact contacto;
	private static Contacto_telefonico__c contactoT;
	private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo;
	private static Perjudicado_Siniestro__c perjudicado;
	private static Garantia__c garantia;
	private static Garantia_Siniestro__c garantiaSini;
	private static INT_Movimiento_CIA__c mov;
	private static List<Comentario_caso__c> comentarios;
	private static List<INT_Envio_Programado__c> envioProg;
	private static List<INT_Config_Fichero_CIA__c> fichConfig;
	private static List<INT_Movimiento_CIA__c> movList;
	private static List<Account> listCuentas;
	private static List<Case> listCasos;
	

	static void setup() {

		envioProg = new List<INT_Envio_Programado__c>();
		fichConfig = new List<INT_Config_Fichero_CIA__c>();
		movList = new List<INT_Movimiento_CIA__c>();
		listCuentas = new List<Account>();
		listCasos = new List<Case>();
		

		//Genero días malos y buenos e idem con las horas
		Date hoyDate = Date.today();
		String[] diasSemana = new String[]{'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'};
		Integer intDiaSemana = hoyDate.ToStartOfWeek().DaysBetween(hoyDate);
		String diaSemanaBueno = diasSemana[intDiaSemana];
		String diaSemanaMalo = diasSemana[intDiaSemana + 1];
		String horaBuena;
		if(Datetime.now().time().minute()<29){
			horaBuena = String.valueOf(Datetime.now().time().hour());
		} else{
			horaBuena = String.valueOf(Datetime.now().time().addHours(1).hour());
		}
		if(horaBuena.length() < 2){
			horaBuena = '0' + horaBuena;
		}
		horaBuena = horaBuena + ':00';
		String horaMala = Datetime.now().time().addHours(2).hour() + ':00';

        compania = Util_Tests.crearCuentaCompania('Name', '1234', 'X1234566X');
		compania.Type = '01';
        insert compania;
		
		cuenta = Util_Tests.crearCuentaB2BPpal('Name','12345', 'X1234567X');
		cuenta.CUE_LKP_CUENTA_PRINCIPAL__c = compania.id;
		cuenta.CUE_LKP_Cliente_contable__c = compania.id;
		cuenta.Type = '01';
        insert cuenta;

        tipoProducto = Util_Tests.crearTipoProductoCIA('nombre','01', compania.Id);
        insert tipoProducto;

        producto = Util_Tests.crearProductoCIA('nombre','1234',tipoProducto.Id);
        insert producto;

        sv = Util_Tests.crearPolizaContrato('nombre', compania.Id, cuenta.Id,producto.Id);
        insert sv;
        
        listCasos.add(caso = Util_Tests.crearCasoB2B(sv.Id,cuenta.Id,compania.Id) );
        listCasos.add(caso = Util_Tests.crearCasoB2B(sv.Id,cuenta.Id,compania.Id) );
        insert listCasos;

	    //Creo un par de cuentas
	    listCuentas.add(compania = Util_Tests.crearCuentaCompania('compania1', '1042','X1234567X'));
	    listCuentas.add(compania = Util_Tests.crearCuentaCompania('compania2', '1043','Y1234567Y'));
	    insert listCuentas;

		// inserto varios INT_Config_Fichero_CIA__c
		fichConfig.add(new INT_Config_Fichero_CIA__c( FIC_TXT_Query__c = 'SELECT Name FROM INT_Movimiento_CIA__c WHERE MOV_TXT_Tipo_Movimiento__c = \'1\' AND MOV_LKP_Bitacora__c != null', FIC_LKP_Compania__c = listCuentas.get(0).Id));
		fichConfig.add(new INT_Config_Fichero_CIA__c(FIC_TXT_Query__c = 'SELECT Name FROM INT_Movimiento_CIA__c WHERE MOV_TXT_Tipo_Movimiento__c != \'2\' AND MOV_LKP_Bitacora__c != null', FIC_LKP_Compania__c = listCuentas.get(1).Id));
		insert fichConfig;

        //system.debug(fichConfig.get(0) + ' aaaaaaaaaaa1');
        //system.debug(fichConfig + ' aaaaaaaa');
		// inserto varios INT_Envio_Programado__c
		envioProg.add(new INT_Envio_Programado__c(ENV_CAS_Activo__c = true, 
				ENV_SEL_Hora__c = horaBuena, ENV_LKP_Fichero__c=fichConfig.get(0).id, ENV_SEL_Dias_Semana__c = diaSemanaBueno,ENV_NUM_Contador_Lote__c=1));

		envioProg.add(new INT_Envio_Programado__c(ENV_CAS_Activo__c = true, 
				ENV_SEL_Hora__c = horaBuena, ENV_LKP_Fichero__c=fichConfig.get(1).id, ENV_SEL_Dias_Semana__c = diaSemanaBueno, ENV_DAT_Fecha_Inicio__c = Datetime.now().date().addMonths(-1),ENV_NUM_Contador_Lote__c=1));

        
		envioProg.add(new INT_Envio_Programado__c(ENV_CAS_Activo__c = true, 
				ENV_SEL_Hora__c = horaBuena, ENV_LKP_Fichero__c=fichConfig.get(1).Id, ENV_SEL_Dias_Semana__c = diaSemanaBueno, ENV_DAT_Fecha_Inicio__c = Datetime.now().date().addMonths(-1),ENV_NUM_Contador_Lote__c=1));
		insert envioProg;

		//Inserto algunos movimientos
		movList.add(new INT_Movimiento_CIA__c(MOV_TXT_Tipo_Movimiento__c = '1' ,MOV_LKP_Cliente__c=listCuentas.get(0).Id,MOV_LKP_Caso__c = listCasos.get(0).Id));
		movList.add(new INT_Movimiento_CIA__c(MOV_TXT_Tipo_Movimiento__c = '2',MOV_LKP_Cliente__c=listCuentas.get(1).Id,MOV_LKP_Caso__c = listCasos.get(1).Id));
		insert movList;
	}

	static testmethod void test() {
        setup();
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
		String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new Batch_Envio_Mov_Desencadenador());

		Test.stopTest();
	}

	global class TestHttpCalloutMock implements HttpCalloutMock {
		// Implement this interface method
		global HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"code":"INT-001","identificadorDestino":"123456", "message" : "peligroo" }');

			response.setStatusCode(200);
			return response; 
		}
	}
}