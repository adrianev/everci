/**
 * Clase de Test de la Clase controladora B2B_BusquedaClientes
 * 
 */
@isTest
public without sharing class Test_B2B_BusquedaClientes extends TestSetup{
	private static Account cuenta {get; set;}
	
    //public static  B2B_BusquedaClientes b2b_busquedaCliente {get; set;}
    
    /**
    * Este metodo se encarga de realizar la carga de datos de static resources
    * 
    */
  
    /*
    @isTest static void Testing(){
    	PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('VDN','1038');
        pageRef.getParameters().put('telefono','123456789');
        Test.setCurrentPage(pageRef);
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        
        System.assertNotEquals(b2b_busquedaCliente, null);
        System.assertEquals(pageRef.getParameters().get('sfdc.tabName'), 'B2B_BusquedaClientes');
        System.assertEquals(b2b_busquedaCliente.codigoVDN, '1038');
        //System.assertEquals(b2b_busquedaCliente.valorTelefono, '123456789');
    }
    
    
    
    @testSetup
    public static void test(){
        TestSetup loadData = new Test_B2B_BusquedaClientes();
        loadData.setTestData();
    }*/
    
    @isTest static void testBusqueda1(){
    	Baipas.establecerVariableControl();
    	Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '46745581G','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
        asegurado.CUE_TXT_Numero_Documento__c='01463486L';
        asegurado.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert asegurado;
		Date startDate = Date.newInstance(2016, 12, 31);
		ServiceContract poliza = Util_Tests.crearPolizaContrato('9729187', compania.Id, asegurado.Id, null);
		insert poliza;
    	
    	
    	
    	
        PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('VDN','1018');
        //pageRef.getParameters().put('VDN','1038');
        pageRef.getParameters().put('telefono','123456789');
        Test.setCurrentPage(pageRef);
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        
        System.assertNotEquals(b2b_busquedaCliente, null);
        System.assertEquals(pageRef.getParameters().get('sfdc.tabName'), 'B2B_BusquedaClientes');
        System.assertEquals(b2b_busquedaCliente.codigoVDN, '1018');
        //System.assertEquals(b2b_busquedaCliente.codigoVDN, '1038');
        System.assertEquals(b2b_busquedaCliente.valorTelefono, null);//'123456789');
        
        
        //b2b_busquedaCliente.nuevaCuentaB2B();
        //b2b_busquedaCliente.nuevaCuentaSecB2B();
        //b2b_busquedaCliente.abrirCtaPpal();
        //b2b_busquedaCliente.simularHoliday();
        Baipas.deshabilitarVariableControl();
    }
    
    @isTest static void testBusqueda2(){
    	Baipas.establecerVariableControl();
    	Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1134567X');
		insert compania;
		Account companiaVDN = Util_Tests.crearCuentaCompania('CuentaVDN', '1019','X1114567X');
		//(String nombre, Id idCompania)
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018','miguel@gmail.es', '79106916A','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		asegurado.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert asegurado;
		Date startDate = Date.newInstance(2016, 12, 31);
		ServiceContract poliza = Util_Tests.crearPolizaContrato('9729187', compania.Id, asegurado.Id, null);
		insert poliza;
    	
    	
        PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('VDN','1038');
        //ServiceContract poliza = Util_Tests.getServiceContractByName('2277393');
        //System.assertEquals(poliza.Name, '2277393');     
        System.assertEquals(poliza.Name, '9729187');
        Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        System.assertEquals(caso.CAS_LKP_PolizaContrato__c, poliza.Id);
        Test.setCurrentPage(pageRef);
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        
        System.assertNotEquals(b2b_busquedaCliente, null);
        System.assertEquals(pageRef.getParameters().get('sfdc.tabName'), 'B2B_BusquedaClientes');
        System.assertEquals(b2b_busquedaCliente.codigoVDN, '1038');
        
        //b2b_busquedaCliente.buscarPresentacionCIA();
        b2b_busquedaCliente.cargarListaPoblacionPorCP();
        b2b_busquedaCliente.valorCodigoPostal = null;
        b2b_busquedaCliente.valorProvincia = 'Madrid';
        b2b_busquedaCliente.busquedaServicios();
        b2b_busquedaCliente.valorN_Servicio = caso.Id;
        b2b_busquedaCliente.busqueda();
        b2b_busquedaCliente.indiceResultado = 0;
        b2b_busquedaCliente.listaCasos= new List<Case>();
        b2b_busquedaCliente.listaCasos.add(caso);
        b2b_busquedaCliente.seleccionarCaso();
        Baipas.deshabilitarVariableControl();
    }
    
   @isTest static void testBusqueda3(){
        
        PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('VDN','1019');
        Baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1111567X');
		insert compania;
		Account companiaVDN = Util_Tests.crearCuentaCompania('CuentaVDN', '1019','X1111167X');
		insert companiaVDN;
		//(String nombre, Id idCompania)
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '19329010V','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		asegurado.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert asegurado;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393', compania.Id, asegurado.Id,null);
        insert poliza;
        System.assertEquals(poliza.Name, '2277393');
        Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        insert caso;
        pageRef.getParameters().put('idCaso', caso.Id);
        Test.setCurrentPage(pageRef);
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();

        System.assertNotEquals(b2b_busquedaCliente, null);
        System.assertEquals(pageRef.getParameters().get('sfdc.tabName'), 'B2B_BusquedaClientes');

        //b2b_busquedaCliente.buscarPresentacionCIA();
        b2b_busquedaCliente.cargarProvinciaPoblacion();
        b2b_busquedaCliente.cargarListaPoblacionPorCP();
        b2b_busquedaCliente.valorCodigoPostal = '28050';
       	b2b_busquedaCliente.valorN_Servicio = caso.Id;
       	b2b_busquedaCliente.valorN_Documento = '12458764F';
        //b2b_busquedaCliente.valorTipo = 'test2';
        b2b_busquedaCliente.valorNombre = 'Alex';
        b2b_busquedaCliente.valorApellido_1 = 'Martinez';
        b2b_busquedaCliente.valorApellido_2 = 'Sanchez';
        b2b_busquedaCliente.valorTelefono = '961234567';
        b2b_busquedaCliente.valorDomicilio = 'Paseo de la Castellana 200';
        b2b_busquedaCliente.valorCodigoPostal = '28050';
        b2b_busquedaCliente.valorPoblacion = 'Madrid';
        b2b_busquedaCliente.valorProvincia = 'Madrid';
       // b2b_busquedaCliente.busqueda();
        b2b_busquedaCliente.nuevaCuenta();
        b2b_busquedaCliente.indiceResultado = 0;
        //b2b_busquedaCliente.seleccionarResultado();       
        // system.debug('>>>>listaClientesB2BB2B2C' + b2b_busquedaCliente.listaClientesB2BB2B2C);
        Baipas.deshabilitarVariableControl();
    }
    
    @isTest static void testBusqueda4(){
    	PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('VDN','1038');
        pageRef.getParameters().put('fase','B2B_BusquedaClientes');
        Test.setCurrentPage(pageRef);
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        
        System.assertNotEquals(b2b_busquedaCliente, null);
        System.assertEquals(pageRef.getParameters().get('sfdc.tabName'), 'B2B_BusquedaClientes');
        System.assertEquals(b2b_busquedaCliente.codigoVDN, '1038');
        
        Account clienteFiltro = new Account();
        //b2b_busquedaCliente.buscarPresentacionCIA();
        b2b_busquedaCliente.cargarProvinciaPoblacion();
        b2b_busquedaCliente.cargarListaPoblacionPorCP();
        b2b_busquedaCliente.busquedaServicios();
        b2b_busquedaCliente.busquedaClientes();
        b2b_busquedaCliente.volver();
        /*/////
        b2b_busquedaCliente.nuevaCuenta();
        b2b_busquedaCliente.seleccionarCaso();
        b2b_busquedaCliente.seleccionarResultado();
11111111º        b2b_busquedaCliente.volver();
        //b2b_busquedaCliente.nuevaCuentaB2B();
        //b2b_busquedaCliente.nuevaCuentaSecB2B();
        //b2b_busquedaCliente.abrirCtaPpal();
        //b2b_busquedaCliente.simularHoliday();*/
        Baipas.deshabilitarVariableControl();
    }
    /*@isTest static void testBusqueda5(){
    	PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('fase','B2B_BusquedaClientes');
        pageRef.getParameters().put('telefono','681955713');
        Test.setCurrentPage(pageRef);
        Baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaB2C('SegurCaixa', '1018','X1111117X');
		insert compania;
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '89999872K','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		asegurado.CUE_LKP_Cuenta_principal__c=compania.Id;
        insert asegurado;
		VDN_Compania__c companiaVDN = Util_Tests.crearVDNCompania('6000',asegurado.Id);
		insert companiaVDN;
		pageRef.getParameters().put('VDN',companiaVDN.Name);
		//(String nombre, Id idCompania)
		ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393', compania.Id, asegurado.Id, null);
        insert poliza;
        Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        insert caso;
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        b2b_busquedaCliente.nuevaCuenta();
        b2b_busquedaCliente.seleccionarCIA();
        b2b_busquedaCliente.valorN_Servicio='1';
        b2b_busquedaCliente.listaCasos=new List<Case>();
        b2b_busquedaCliente.listaCasos.add(caso);
        b2b_busquedaCliente.busqueda();
        Baipas.deshabilitarVariableControl();
    }*/
    @isTest static void testBusqueda6(){
    	PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('fase','B2B_BusquedaClientes');
        pageRef.getParameters().put('solicitudExistente','Y');
        Test.setCurrentPage(pageRef);
        Baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1111111X');
		insert compania;
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '73661110E','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_LKP_Cuenta_principal__c=compania.Id;
		insert asegurado;
		VDN_Compania__c companiaVDN = Util_Tests.crearVDNCompania('6000',asegurado.Id);
		insert companiaVDN;
		pageRef.getParameters().put('VDN',companiaVDN.Name);
		//(String nombre, Id idCompania)
		ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393', compania.Id, asegurado.Id, null);
        insert poliza;
        Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        insert caso;
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        //b2b_busquedaCliente.buscarPresentacionCIA();
        b2b_busquedaCliente.nuevaCuenta();
        b2b_busquedaCliente.busquedaClientes();
        b2b_busquedaCliente.valorN_Servicio='1';
        b2b_busquedaCliente.listaCasos=new List<Case>();
        b2b_busquedaCliente.listaCasos.add(caso);
        b2b_busquedaCliente.busqueda();
        Baipas.deshabilitarVariableControl();
    }
    
    @isTest static void testBusqueda7(){
    	PageReference pageRef = Page.B2B_BusquedaClientes;
        pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('fase','B2B_BusquedaClientes');
        pageRef.getParameters().put('telefono','681955713');
        Test.setCurrentPage(pageRef);
        Baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1111117X');
		insert compania;
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '69022476M','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		asegurado.CUE_LKP_Cuenta_principal__c=compania.Id;
        insert asegurado;
		VDN_Compania__c companiaVDN = Util_Tests.crearVDNCompania('6000',asegurado.Id);
		insert companiaVDN;
		pageRef.getParameters().put('VDN',companiaVDN.Name);
		//(String nombre, Id idCompania)
		ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393', compania.Id, asegurado.Id, null);
        insert poliza;
        Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        insert caso;
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        b2b_busquedaCliente.nuevaCuenta();
        b2b_busquedaCliente.busquedaServicios();
        b2b_busquedaCliente.seleccionarCIA();
        b2b_busquedaCliente.valorN_Servicio='1';
        b2b_busquedaCliente.listaCasos=new List<Case>();
        b2b_busquedaCliente.listaCasos.add(caso);
        b2b_busquedaCliente.busqueda();
       
        Baipas.deshabilitarVariableControl();
    }
    
    
    
	@isTest static void testBusqueda8(){
    	
    	PageReference pageRef = Page.B2B_BusquedaClientes;
    	//Creamos diversas cuentas
    	pageRef.getParameters().put('sfdc.tabName','B2B_BusquedaClientes');
        pageRef.getParameters().put('fase','B2B_BusquedaClientes');
        pageRef.getParameters().put('telefono','969320109');
        
    	pageRef.getParameters().put('vincularCliB2BRep','Y');
    	
    	Test.setCurrentPage(pageRef);
        Baipas.establecerVariableControl();
    	Account compania1 =	Util_Tests.crearCuentaCompania('Segurcaixa','1018','X2518273A');
    	compania1.CUE_LKP_Cuenta_principal__c = null;
    	insert compania1;
    	Account compania2 =  Util_Tests.crearCuentaCompania('Almudena Seguros', '1042','X1420245H');
    	insert compania2;
    	
    	Account  cuentaB2C = Util_Tests.crearCuentaB2C('DB2C','2020', '01241851X');
    	
    	Tipo_Producto_CIA__c tipoProductoCIA1 = Util_Tests.crearTipoProductoCIA('SEGURCAIXA - Hogar','01',compania1.ID);
		insert tipoProductoCIA1;
    	Tipo_Producto_CIA__c tipoProductoCIA2 = Util_Tests.crearTipoProductoCIA('ALMUDENA - Hogar','02',compania2.ID);
		insert tipoProductoCIA2;
    	
    	Producto_CIA__c productoCIA1 = Util_Tests.crearProductoCIA('PRD 1','01',tipoProductoCIA2.Id);
		insert productoCIA1;
		Producto_CIA__c productoCIA2 = Util_Tests.crearProductoCIA('PRD 2','02',tipoProductoCIA2.Id);
		insert productoCIA2;
		
		Account asegurado = Util_Tests.crearCuentaAsegurado('Alejandro','2018', 'aleh@gmail.es', '04626393N','Alejandro', 'Rey', 'López');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		asegurado.CUE_LKP_Cuenta_principal__c=compania1.Id;
        insert asegurado;
        
		VDN_Compania__c companiaVDN = Util_Tests.crearVDNCompania('6000',asegurado.Id);
		insert companiaVDN;
		pageRef.getParameters().put('VDN',companiaVDN.Name);
		
		//crearPolizaContrato(String nombre, Id idCompania, Id idCuenta, Boolean correspondeHS, String version, String codigoPostal, 
		//String tipoRiesgo, Date fechaInicio, String poblacion, Id idProductoCIA, String idioma)
		ServiceContract poliza1 = Util_Tests.crearPolizaContrato('79', compania1.Id, asegurado.Id, productoCIA1.Id);
        insert poliza1;
        
        ServiceContract poliza2 = Util_Tests.crearPolizaContrato('80', compania2.Id, asegurado.Id,productoCIA2.Id);
        insert poliza2;
        
        Case caso1 = Util_tests.crearCasoB2B(poliza1.Id,asegurado.Id,compania1.Id);
        insert caso1;
        
        Case caso2 = Util_tests.crearCasoB2B(poliza2.Id,asegurado.Id,compania2.Id);
        insert caso2;
        
        
       Case caso3 = Util_tests.crearCasoB2B(poliza2.Id,cuentaB2C.Id,compania2.Id);
       insert caso3;
         
        
        B2B_BusquedaClientes b2b_busquedaCliente = new B2B_BusquedaClientes();
        //
         b2b_busquedaCliente.clienteFiltros = compania1;
        
        b2b_busquedaCliente.nuevaCuenta();
        b2b_busquedaCliente.busquedaServicios();
        b2b_busquedaCliente.seleccionarCIA();
        b2b_busquedaCliente.valorN_Servicio='1';
        b2b_busquedaCliente.listaCasos=new List<Case>();
        b2b_busquedaCliente.listaCasos.add(caso1);
        b2b_busquedaCliente.busqueda();
        
        b2b_busquedaCliente.busquedaServicios = false;
        b2b_busquedaCliente.valorTelefono = '969320109';
        b2b_busquedaCliente.valorCodigoPostal = '28943';
//        b2b_busquedaCliente.limiteBusqueda = 0 ;
        b2b_busquedaCliente.valorN_Documento = '04626693N';
        b2b_busquedaCliente.clienteFiltros = compania2;
        b2b_busquedaCliente.valorNombre='Alejandro';
        b2b_busquedaCliente.valorApellido_1 = 'Rey';
        b2b_busquedaCliente.valorApellido_2= 'López';
        b2b_busquedaCliente.telefono = '666123123';
        b2b_busquedaCliente.busqueda();
        
        
        b2b_busquedaCliente.noExistenteB2C();
        
      	b2b_busquedaCliente.recPerPageChange();
        b2b_busquedaCliente.nextPage();
        b2b_busquedaCliente.previousPage();
        b2b_busquedaCliente.firstPage();
        b2b_busquedaCliente.lastPage();
        
        
       // asegurado.CUE_LKP_Cuenta_principal__c = compania2.Id;
        //update asegurado;
       // b2b_busquedaCliente.paginaRedireccion = Page.B2B_BusquedaClientes;
        b2b_busquedaCliente.clienteFiltros =asegurado;
       	b2b_busquedaCliente.busqueda();
       	
       	b2b_busquedaCliente.listaClientes.add(compania1);
       	b2b_busquedaCliente.listaClientes.add(compania2);
       	b2b_busquedaCliente.listaClientes.add(asegurado);
       	b2b_busquedaCliente.busqueda();
       	b2b_busquedaCliente.listaClientes.add(compania1);
       	b2b_busquedaCliente.listaClientes.add(compania2);
       	b2b_busquedaCliente.listaClientes.add(asegurado);
      
        b2b_busquedaCliente.indiceResultado = 1;
        b2b_busquedaCliente.cuentaPpalEsB2C = true ;
        b2b_busquedaCliente.seleccionarResultado();
       	
      
        b2b_busquedaCliente.seleccionarResultado();
        
        b2b_busquedaCliente.clienteFiltros.CUE_LKP_Cuenta_principal__c = compania2.ID;
        b2b_busquedaCliente.noExistenteB2C();
        
        b2b_busquedaCliente.idCaso= caso1.Id;
       	//b2b_busquedaCliente.setVincularCliB2BRep(true);
        b2b_busquedaCliente.volver();
        
        Baipas.deshabilitarVariableControl();
    }
}