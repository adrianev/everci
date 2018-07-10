/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:			Everis
Company:		Everis España
Description:	Test del trigger para el objeto INT_Movimiento_CIA__c

History:		Se han añadido asertos
 
<18/12/2017>	Everis	<Inicio de clase>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public without sharing class Test_TRG_Handler_Movimientos {
	private static Account compania;
	private static Account compania2;
	private static Account cuenta;
	private static Tipo_Producto_CIA__c tipoProducto;
	private static Producto_CIA__c producto;
	private static ServiceContract sv;
	private static Procedencia__c procedencia;
	private static Case caso;
	private static Case caso2;
	private static Case caso3;
	private static INT_Movimiento_CIA__c movimientoCasoError;
	private static INT_Movimiento_CIA__c movimiento;

	/**
	 * Método privado que inicializa todos los objetos que utiliza el test.
	 */
	private static void inicializaVariables(){
		Baipas.establecerVariableControl();

		List<Account> listCuentas= new List<Account>();
		compania = Util_Tests.crearCuentaCompania('Nationale Nederlanden',Label.IDE_NATIONALE_NETHERLANDEN,'X1234567X');
		compania2 = Util_Tests.crearCuentaCompania('SegurCaixa',Label.IDE_SEGURCAIXA,'Y1234568Y');
		listCuentas.add(compania);
		listCuentas.add(compania2);
		insert listCuentas;

		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo','01',compania.Id);
		insert tipoProducto;
		
		producto = Util_Tests.crearProductoCIA('producto','292',tipoProducto.Id);
		producto.PRD_TXT_Cod_Producto__c = 'te|s|t';
		insert producto;

		sv = Util_Tests.crearPolizaContrato('poliza',compania.Id,compania.Id,producto.Id);

		procedencia = Util_Tests.crearProcedencia(0.0,0.0,0.0,0.0,0.0,compania.Id,'545687','CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
		insert procedencia;
		List<Case> listCasos = new List<Case>();
		caso = Util_Tests.crearCasoSini(sv.Id,compania.Id,compania.Id);
		caso.CAS_TXT_Num_Caso_HS__c = '1234567890';
		listCasos.add(caso);

		caso2 = Util_Tests.crearCasoSini(sv.Id,compania2.Id,compania2.Id);
		caso2.CAS_TXT_Num_Caso_HS__c = '0987654321';
		caso2.CAS_TXT_Num_Caso_CIA__c = '87654321';
		listCasos.add(caso2);

		caso3 = Util_Tests.crearCasoSini(sv.Id,compania.Id,compania2.Id);
		caso3.CAS_TXT_Num_Caso_HS__c = '0987654322';
		caso3.CAS_TXT_Num_Caso_CIA__c = '87654322';
		listCasos.add(caso3);

		insert listCasos;

		movimientoCasoError = crearMovimiento(compania,caso3,caso3.CAS_TXT_Num_Caso_HS__c);
		movimientoCasoError.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_ERROR;
		insert movimientoCasoError;

		Baipas.deshabilitarVariableControl();
	}

	@isTest static void testRecepcionNN(){
		INT_Movimiento_CIA__c mov;
		inicializaVariables();

		Test.startTest();

		movimiento = crearMovimiento(compania,caso,caso.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '2';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_EN_ESPERA);

		movimiento = crearMovimiento(compania,caso,caso.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '1';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_NO_ENVIADO);
		
		movimiento = crearMovimiento(compania,caso,caso.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '1';
		movimiento.MOV_TXT_Num_Caso_CIA__c = '12345678';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_RECIBIDO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimiento.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_RECIBIDO);

		movimiento = crearMovimiento(compania,caso,caso.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '2';
		movimiento.MOV_TXT_Num_Caso_CIA__c = '12345678';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimiento.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_NO_ENVIADO);

		movimiento = crearMovimiento(compania,caso,caso.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '1';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_ERROR;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_ERROR);

		movimiento = crearMovimiento(compania,caso,caso.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '2';
		movimiento.MOV_TXT_Num_Caso_CIA__c = '12345678';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimiento.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_EN_ESPERA);

		Test.stopTest();
	}

	@isTest static void testRecepcionEnError() {
		INT_Movimiento_CIA__c mov;
		inicializaVariables();

		Test.startTest();

		movimiento = crearMovimiento(compania2,caso2,caso2.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '2';
		movimiento.MOV_TXT_Num_Caso_CIA__c = '1234567890';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_RECIBIDO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimiento.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_RECIBIDO);

		movimiento = crearMovimiento(compania2,caso2,caso2.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '2';
		movimiento.MOV_TXT_Num_Caso_CIA__c = '1234567890';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimiento.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_NO_ENVIADO);

		movimiento = crearMovimiento(compania2,caso2,caso2.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '2';
		movimiento.MOV_TXT_Num_Caso_CIA__c = '1234567890';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_ERROR;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimiento.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_ERROR);

		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_RESUELTO;

		update movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimiento.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_RESUELTO);

		Test.stopTest();
	}

	@isTest static void testCasoMovimientoError() {
		INT_Movimiento_CIA__c mov;
		inicializaVariables();

		Test.startTest();

		movimiento = crearMovimiento(compania2,caso3,caso3.CAS_TXT_Num_Caso_HS__c);
		movimiento.MOV_TXT_Codigo_Modificacion__c = '00';
		movimiento.MOV_TXT_Tipo_Movimiento__c = '1';
		movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;

		insert movimiento;
		mov = selectMovimientoQuery(movimiento.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimiento.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimiento.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_EN_ESPERA);

		Test.stopTest();
	}

	@isTest static void testErrorResuelto() {
		INT_Movimiento_CIA__c mov;
		inicializaVariables();

		Test.startTest();

		movimientoCasoError.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_RESUELTO;
		system.debug('SMM1 - TEST: Antes del update');

		update movimientoCasoError;
		mov = selectMovimientoQuery(movimientoCasoError.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimientoCasoError.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimientoCasoError.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimientoCasoError.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_RESUELTO);

		Test.stopTest();
	}

	@isTest static void testErrorResuelto2() {
		INT_Movimiento_CIA__c mov;
		inicializaVariables();

		Baipas.establecerVariableControl();
		movimientoCasoError.MOV_LKP_Caso__c = caso.Id;
		update movimientoCasoError;
		Baipas.deshabilitarVariableControl();

		Test.startTest();
		
		movimientoCasoError.MOV_TXT_Codigo_Modificacion__c = '00';
		movimientoCasoError.MOV_TXT_Tipo_Movimiento__c = '1';
		movimientoCasoError.MOV_TXT_Num_Caso_CIA__c = '12345678';
		movimientoCasoError.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_RESUELTO;

		update movimientoCasoError;
		mov = selectMovimientoQuery(movimientoCasoError.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimientoCasoError.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimientoCasoError.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimientoCasoError.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_RESUELTO);

		Test.stopTest();
	}

	@isTest static void testErrorResuelto3() {
		INT_Movimiento_CIA__c mov;
		inicializaVariables();

		Baipas.establecerVariableControl();
		movimientoCasoError.MOV_LKP_Caso__c = caso.Id;
		update movimientoCasoError;
		Baipas.deshabilitarVariableControl();

		Test.startTest();
		
		movimientoCasoError.MOV_TXT_Codigo_Modificacion__c = '00';
		movimientoCasoError.MOV_TXT_Tipo_Movimiento__c = '4';
		movimientoCasoError.MOV_TXT_Num_Caso_CIA__c = '12345678';
		movimientoCasoError.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_RESUELTO;

		update movimientoCasoError;
		mov = selectMovimientoQuery(movimientoCasoError.Id);

		System.AssertNotEquals(mov,null);
		System.AssertEquals(mov.MOV_TXT_Codigo_Modificacion__c,movimientoCasoError.MOV_TXT_Codigo_Modificacion__c);
		System.AssertEquals(mov.MOV_TXT_Tipo_Movimiento__c,movimientoCasoError.MOV_TXT_Tipo_Movimiento__c);
		System.AssertEquals(mov.MOV_TXT_Num_Caso_CIA__c,movimientoCasoError.MOV_TXT_Num_Caso_CIA__c);
		System.AssertEquals(mov.MOV_SEL_Estado_Movimiento__c,Label.BIT_ESTADO_RESUELTO);

		Test.stopTest();
	}

	/**
	 * Método privado que recupera de la BBDD el Movimiento del Id especificado.
	 *
	 * @param mId: Id del movimiento a recuperar
	 */
	private static INT_Movimiento_CIA__c selectMovimientoQuery(Id mId){
		INT_Movimiento_CIA__c m;
		List<INT_Movimiento_CIA__c> l = [SELECT Id,
												MOV_TXT_Codigo_Modificacion__c,
												MOV_TXT_Tipo_Movimiento__c,
												MOV_SEL_Estado_Movimiento__c,
												MOV_TXT_Num_Caso_CIA__c
										 FROM INT_Movimiento_CIA__c
										 WHERE Id = :mId];
		if(!l.isEmpty()){
			m = l.get(0);
		}
		return m;
	}

	/**
	 * Método privado que crea y devuelve un movimiento.
	 */
	private static INT_Movimiento_CIA__c crearMovimiento(Account cuenta, Case caso, String numCasoHS){
		INT_Movimiento_CIA__c movimiento = new INT_Movimiento_CIA__c();
		movimiento.MOV_LKP_Compania__c = cuenta.id;
		movimiento.MOV_LKP_Caso__c = caso.id;
		movimiento.MOV_TXT_Num_Caso_HS__c = numCasoHS;
		return movimiento;
	}
}