/**
 * Clase de Test de la Clase AltaConfirmacionAsegurado
 * 
*/
@isTest
public without sharing class Test_Sini_IntervencionSinPoliza{
	
	private static Account compania {get; set;}
	private static Case caso {get; set;}
	
	/**
	 * Metodo Test para realizar el flujo cuando se recibe una idCompania e idCaso existente, se encuentra el cliente se modifica un campo
	 * y se realiza el flujo hacia una nueva asistencia
	 */
	private static void inicializarVariables(){
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018', 'J5340931D');
		Account asegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1019','email@gmail.es', '46595659M','Miguel', 'Sagrado', 'Corazón');
		insert compania;
		asegurado.CUE_LKP_Cuenta_principal__c = compania.Id;
		asegurado.Type='02';
		insert asegurado;
		OperatingHours horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
		insert horaFuncionamiento;
		ServiceTerritory territorioServicio = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
		territorioServicio.TDS_TXT_Identificador__c = '28001';
		insert territorioServicio;
		Poblacion__c poblacion =  Util_Tests.crearPoblacion('Madrid','28');
		insert poblacion;
		Poblacion_CP__c pobl = new Poblacion_CP__c();
		pobl.PCP_LKP_TerritorioServicio__c = territorioServicio.Id;
		pobl.PCP_LKP_Poblacion__c = poblacion.Id;
		pobl.Name = 'prueba';
		insert pobl;
		caso = new Case();
		caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
		caso.CAS_LKP_Compania__c = compania.Id;
		caso.AccountId=asegurado.Id;
		caso.CAS_LKP_Cliente_contable_cliente__c=compania.Id;
		insert caso;
	}
	
	/**
	 * Metodo test para realizar el flujo con una compania pero sin caso, se crea un campo nuevo, se intenta realizar la inserción de un nuevo cliente 
	 * pero falla porque no se ha rellenado el campo obligatorio nº documento, y se vuelve atras.
	 */
	@isTest static void testBuscarClienteCasoNuevaApertura(){
		inicializarVariables();
		PageReference pageRef = Page.Sini_IntervencionSinPoliza;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('idCompania',compania.Id);
		Sini_IntervencionSinPolizaController siniSinPoliza = new Sini_IntervencionSinPolizaController();
		siniSinPoliza.dniCliente = '46595659M';
		siniSinPoliza.clientesEncontrados();
		siniSinPoliza.valorCodigoPostal = '28001';
		siniSinPoliza.valorTel = '678345092';
		siniSinPoliza.valorCalle = 'Calle Falsa 23';
		siniSinPoliza.valorNombre = 'test2';
		siniSinPoliza.cargarListaPoblacionPorCP();
		siniSinPoliza.cargarProvinciaPoblacion();
		siniSinPoliza.guardarCliente();
		Test.startTest();
		Database.SaveResult result = Database.insert(siniSinPoliza.cliente,false);
		Test.stopTest();
		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
		System.assertEquals('cannot specify Id in an insert call', result.getErrors()[0].getMessage());
		Baipas.establecerVariableControl();
		siniSinPoliza.nuevaAsistencia();
		Baipas.deshabilitarVariableControl();
	}
	
	@isTest static void testFalloGuardarCliente(){
		inicializarVariables();
	 	PageReference pageRef = Page.Sini_IntervencionSinPoliza;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('idCompania',compania.Id);
		Sini_IntervencionSinPolizaController siniSinPoliza = new Sini_IntervencionSinPolizaController();
		siniSinPoliza.dniCliente = '02293950E';
		siniSinPoliza.clientesEncontrados();
		siniSinPoliza.valorNombre = 'test1';
		siniSinPoliza.valorCalle = 'calle test';
		siniSinPoliza.valorTel = '654344543';
		siniSinPoliza.valorCodigoPostal = '28001';
		siniSinPoliza.cargarListaPoblacionPorCP();
		Test.startTest();
		siniSinPoliza.guardarCliente();
		List<Account> listcuenta = new List<Account>{siniSinPoliza.cliente};
		Database.SaveResult result = Database.insert(listCuenta[0],false);
		Test.stopTest();
		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
		System.assertEquals('Nº de documento obligatorio', result.getErrors()[0].getMessage());
		siniSinPoliza.volver();
	}
	
}