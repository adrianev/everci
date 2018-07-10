/**
 * Clase de Test de la Clase Rest_B2B_ConsultaClientesBasica
 * 
 */
@isTest
public without sharing class B2B_ConsultaClientesBasica_Test{
	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 */
	
	@isTest
	static void testing(){
		test.startTest();
        Account compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
		insert compania;
        Contact contacto = Util_Tests.crearContacto('María', 'García Maza');
		contacto.AccountId = compania.Id;
		insert contacto;
		B2B_ConsultaClientesBasica_RQ datos = new B2B_ConsultaClientesBasica_RQ();
		datos.CUE_TXT_Identificador = '1018';
		List<Contact> listaPrueba =  B2B_ConsultaClientesBasica.Consulta(datos);
		Test.stopTest();
	}

}