/**
 * Clase de test de la clase Rest_B2C_CodigoActivacion
 * 
 */
@isTest public without sharing class Test_Rest_B2C_CrearActualizarCliente extends TestSetup{
	
	private static Account cuentaPrincipal {get;set;}
	private static Account cuentaSecundaria {get;set;}
    private static Account cuentaSecundariaDireccion {get;set;}
	
	@isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
		
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1514713658675', 'R8459488F');
		insert cuentaPrincipal;
		
		cuentaSecundaria = Util_Tests.crearCuentaB2BSec('B2BSecundariaFinal', 'RP123456', cuentaPrincipal.Id, 'Q5446313H');
		cuentaSecundaria.Type = '03';
		insert cuentaSecundaria;
        
        cuentaSecundariaDireccion = Util_Tests.crearCuentaB2BSec('B2BSecundariaDireccion', 'RP987654', cuentaPrincipal.Id, 'C30276968');
		cuentaSecundaria.Type = '01';
		insert cuentaSecundariaDireccion;
		
		Baipas.deshabilitarVariableControl();
		
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		
		Rest_B2C_CrearActualizarCliente_RP respuesta = new Rest_B2C_CrearActualizarCliente_RP();
		
		//Caso OK. Crear
		respuesta = Rest_B2C_CrearActualizarCliente.doPost('Camino del Cerro de los Gamos 2,  escalera A, puerta 2', 'Pozuelo de Alarcón', '28', '28224', 
			'ES', 'Naomi', 'Gómez', 'García', 'prueba@prueba.es', '654347867', '653456347', cuentaPrincipal.Id, 'N', '85529701S', 'Account:CUE_Cliente_B2B_B2B2C_sec', 
			'03', true);
		//Caso OK. Actualizar
		respuesta = Rest_B2C_CrearActualizarCliente.doPost('Camino del Cerro de los Gamos 2,  escalera A, puerta 2', 'Pozuelo de Alarcón', '28', '28224', 
			'ES', 'Laura', 'Gómez', 'García', 'prueba@prueba.es', '654347867', '653456347', cuentaPrincipal.Id, 'C', 'Q5446313H', 'Account:CUE_Cliente_B2B_B2B2C_sec', 
			'03', true);
		
		//Caso KO. Formato de datos no correcto
		respuesta = Rest_B2C_CrearActualizarCliente.doPost('Camino del Cerro de los Gamos 2,  escalera A, puerta 2', 'Pozuelo de Alarcón', '28', '28224', 
			'ES', 'Naomi', 'Gómez', 'García', 'pruebaprueba.es', '654347867', '653456347', cuentaPrincipal.Id, 'N', '85529701S', 'Account:CUE_Cliente_B2B_B2B2C_sec', 
			'03', true);
		
		
		test.stopTest();
	}
	
}