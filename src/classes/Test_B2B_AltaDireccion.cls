@isTest
public without sharing class Test_B2B_AltaDireccion{

	private static Linea_Contrato__c lineaContrato {get;set;}
	private static B2B_AltaDireccion b2b{get;set;}
	private static List<Account> listaCuentas{get;set;}

	public static void test(Boolean esLineaPreventiva,Boolean esContratoActivo){
		//Creo e inserto cuentas
		listaCuentas = new List<Account>();
		listaCuentas.add(Util_Tests.crearCuentaB2BPpal('Holiday Gym2','1000','X1234567X'));
		listaCuentas.add(Util_Tests.crearCuentaB2BPpal('Holiday Gym Arturo Soria2','1001','X1134567X'));
		insert listaCuentas;
		System.debug('@@@@@@'+listaCuentas);
		//Creo e inserto Contratos
		Contract contrato = Util_Tests.crearContrato(listaCuentas[0].Id,'b2b_p_1');
        contrato.CTR_TXT_Identificador__c = '6574787';
		insert contrato;
		
		if(esContratoActivo){
			contrato.Status=Label.CONTRATO_ESTADO_ACTIVO;
			update contrato;
		}
		
		//Creo e inserto linea de contrato
		if(esLineaPreventiva)
			crearLineaContratoPreventiva();

		else{
			lineaContrato=Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
			insert lineaContrato;
			lineaContrato=[SELECT Id, LDC_FOR_RTDevName__c, LDC_LKP_Contrato__r.Status, LDC_NUM_Limite_de_servicios__c FROM Linea_Contrato__c Where ID=:lineaContrato.Id];
		}

		ApexPages.StandardController stdc=new ApexPages.StandardController(new Case());		
		b2b=new B2B_AltaDireccion(stdc);
		b2b.lineaContrato=lineaContrato;
	}

	static testMethod void altaDireccionConIdTest() {

		test(false, false);
		
		//PageReference pageRef = Page.B2C_Argumentario;
		//Test.setCurrentPage(pageRef);
		Test.startTest();
		Account account = Util_Tests.getAccountByName('Holiday Gym2'); 
		Contract contract = getContractByName('b2b_p_1');
		contract.Status = '02';
		system.debug('@@@@@@@Assert');
		system.debug('@@@@@@@Holiday Gym2 ' + account.Name);
		System.debug('@@@@@@@'+contract.accountId + ' ' + account.Id);
		System.assertEquals(account.Name, 'Holiday Gym2');
		System.assertEquals(contract.accountId, account.Id);
		System.assertEquals(contract.Status, '02');
		contract.Status=Label.CONTRATO_ESTADO_ACTIVO;
		contract.StartDate = Datetime.now().Date();
		contract.ContractTerm = 4;
		update contract;

		Account account2 = Util_Tests.getAccountByName('Holiday Gym Arturo Soria2');
		account2.CUE_LKP_Cuenta_principal__c = account.Id;
		account2.CUE_CAS_Dada_de_Baja__c = false;
		account2.Type = 'Direccion';

		System.assertEquals(account2.Name, 'Holiday Gym Arturo Soria2');
		System.assertEquals(account2.CUE_LKP_Cuenta_principal__c, account.Id);
		System.assertEquals(account2.CUE_CAS_Dada_de_Baja__c, false);
		System.assertEquals(account2.Type, 'Direccion');

		//update account2;

		Linea_Contrato__c lineaContrato = Util_Tests.getLineaContratoByContractId(contract.Id);
		ApexPages.currentPage().getParameters().put('id',account.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(lineaContrato);
		B2B_AltaDireccion altaDireccion = new B2B_AltaDireccion(sc);
		altaDireccion.dirLCFecha = new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c();
		altaDireccion.dirLCFecha.DLC_DAT_Activacion_primer_servicio__c = DateTime.now().date();
		B2B_AltaDireccion.wCCuenta WOCC = new B2B_AltaDireccion.wCCuenta(account,altaDireccion.dirLCFecha);
        altaDireccion.valorNombre = account2.Name;
		altaDireccion.valorVia_Domicilio = account2.ShippingStreet;
		altaDireccion.valorCodigoPostal = account2.ShippingPostalCode;
		altaDireccion.poblacion = account2.ShippingCity;
		altaDireccion.valorProvincia = account2.ShippingState;
		altaDireccion.valorNombre2 = '00000001';
		altaDireccion.valorVia_Domicilio2 = 'Avenida de Europa 34';
		altaDireccion.poblacion2 = 'Madrid';
		altaDireccion.valorPoblacion2 = 'Madrid';
		altaDireccion.valorProvincia2 = 'Madrid';
		altaDireccion.valorCodigoPostal2 = '28050';
		altaDireccion.lineaContrato=lineaContrato;
		altaDireccion.valorVia_Domicilio='01';
		altaDireccion.valorCodigoPostal='36155';
		altaDireccion.valorProvincia='01';
		altaDireccion.poblacion = 'Madrid';
		
		/*System.assertEquals(ApexPages.currentPage().getParameters().get('id'), account.Id);
		System.assertEquals(altaDireccion.valorNombre, account2.Name);
		System.assertEquals(altaDireccion.valorVia_Domicilio, account2.ShippingStreet);
		System.assertEquals(altaDireccion.valorCodigoPostal, account2.ShippingPostalCode);
		System.assertEquals(altaDireccion.poblacion, account2.ShippingCity);
		System.assertEquals(altaDireccion.valorProvincia, account2.ShippingState);
		System.assertEquals(altaDireccion.valorNombre2, '00000001');
		System.assertEquals(altaDireccion.valorVia_Domicilio2, 'Avenida de Europa 34');
		System.assertEquals(altaDireccion.poblacion2, 'Madrid');
		System.assertEquals(altaDireccion.valorPoblacion2, 'Madrid');
		System.assertEquals(altaDireccion.valorProvincia2, 'Madrid');
		System.assertEquals(altaDireccion.valorCodigoPostal2, '28050');*/

		altaDireccion.anadirDireccion();
		altaDireccion.filtrarLineasContrato();
		altaDireccion.seleccionarTodos();
		altaDireccion.cargarListaDirecciones();
		altaDireccion.listaDirecciones = new List<Account>([SELECT Id FROM Account]);
		altaDireccion.volver();
		altaDireccion.seleccionarTodosC();
		altaDireccion.todosCuenta = true;
		//System.assertEquals(altaDireccion.todosCuenta, true);
		altaDireccion.cargarListaPoblacionPorCP();
		altaDireccion.cargarListaPoblacionPorCP2();
		altaDireccion.cargarProvinciaPoblacion2();
		altaDireccion.cargarProvinciaPoblacion(); 
		altaDireccion.eliminarDireccion();
		Test.stopTest();
	}

	static testMethod void altaDireccionSinIdTest() {

		test(false, false);

		//PageReference pageRef = Page.B2C_Argumentario;
		//Test.setCurrentPage(pageRef); 
		Test.startTest();
		Account account = Util_Tests.getAccountByName('Holiday Gym Arturo Soria2');
		Contract contract = getContractByName('b2b_p_1');

		/*System.assertEquals(account.Name, 'Holiday Gym Arturo Soria2');
		System.assertEquals(contract.AccountId, account.Id);*/

		ApexPages.StandardController sc = new ApexPages.StandardController(contract);
		B2B_AltaDireccion altaDireccion = new B2B_AltaDireccion(sc);
		altaDireccion.lineaContrato=Util_Tests.getLineaContratoByContractId(contract.Id);
		altaDireccion.anadirDireccion();
		Test.stopTest();
	}

		static testMethod void testAnadirDireccionPrimerServicioPreventivoNulo(){
		test(true,false);
		b2b.dirLCFecha=new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c();

		b2b.anadirDireccion();
	}

	static testMethod void testAnadirDireccionListaTareasVacia(){
		test(true, true);

		

		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLCFecha=new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c();
		dirLCFecha.DLC_DAT_Activacion_primer_servicio__c=Date.today();
		List<Tarea_Linea_Contrato__c> listaTareasLC = [SELECT Id FROM Tarea_Linea_Contrato__c WHERE TLC_LKP_LineaContrato__c = :lineaContrato.Id];
		delete listaTareasLC;

		b2b.dirLCFecha=dirLCFecha;
		b2b.anadirDireccion();
	}

	static testMethod void testAnadirDireccionListasWCCuentaLlenas(){
		test(false,true);
		llenarListaWCCuenta();
		b2b.anadirDireccion();
	}

	private static void llenarListaWCCuenta(){
		List<B2B_AltaDireccion.wCCuenta> listaWCCuenta=new List<B2B_AltaDireccion.wCCuenta>();
		listaWCCuenta.add(new B2B_AltaDireccion.wCCuenta(null,null));
		b2b.listaWCCuentaConLinea=listaWCCuenta;

		B2B_AltaDireccion.wCCuenta wCC= new B2B_AltaDireccion.wCCuenta(null,null);
		wCC.selected=true;

		wCC.cuenta=listaCuentas.get(0);

		listaWCCuenta.add(wCC);
		b2b.listaWCCuenta=listaWCCuenta;
	}

	private static void crearLineaContratoPreventiva(){
		Contract contract = getContractByName('b2b_p_1');

		lineaContrato=new Linea_Contrato__c();
		//Sacamos el recordtype en base a su propiedad DeveloperName
		lineaContrato.RecordType=getRTByDevName(Label.RT_LIN_CON_PREVENTIVO);
		lineaContrato.LDC_LKP_Contrato__c=contract.Id;
		lineaContrato.LDC_LKP_Contrato__r=contract;
		lineaContrato.LDC_NUM_Limite_de_servicios__c=10;
		
		insert lineaContrato;
		
		lineaContrato=[SELECT Id, LDC_FOR_RTDevName__c, LDC_LKP_Contrato__r.Status, LDC_NUM_Limite_de_servicios__c FROM Linea_Contrato__c Where ID=:lineaContrato.Id];
	}

	private static RecordType getRTByDevName(String label){
		ID idRecordType=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(label);
		return Util_mapasTiposDeRegistro.RTBYID.get(idRecordType);
	}

	public static Contract getContractByName(String name){
		Contract contract;

		List<Contract> contractList = new List<Contract>([Select Id,
		                                                  Status,
		                                                  AccountId,
		                                                  ContractNumber
		                                                  FROM Contract WHERE Name = :name LIMIT 1
		                                                  ]);
		if(!contractList.isEmpty()){
			contract = contractList.get(0);
		}else{
			throw new TestException('No existen contrato con ese nombre');
		}

		return contract;
	}
}