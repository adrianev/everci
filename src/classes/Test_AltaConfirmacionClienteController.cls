@isTest 
public without sharing class Test_AltaConfirmacionClienteController{

    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static AltaConfirmacionClienteController accc;
    private static Contact contacto;
    private static Contacto_telefonico__c contactoTelefonico;
    private static Version_ContratoServicio__c  NuevaVersion;

    static void InicializarVariables(){
    	cuenta = Util_Tests.crearCuentaB2BPpal('Name','12345', 'X1234567X');
        insert cuenta;
        
      	compania = Util_Tests.crearCuentaCompania('Miguel','1018','H79023677');
		insert compania;
        
        Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '73661110E','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_LKP_Cuenta_principal__c = compania.id;
		insert asegurado;
 

        tipoProducto = Util_Tests.crearTipoProductoCIA('nombre','01', compania.Id);
        insert tipoProducto;

        producto = Util_Tests.crearProductoCIA('nombre','1234',tipoProducto.Id);
        insert producto;
        
        
        sv=new ServiceContract();
        sv.Name='10';
        sv.POL_LKP_Compania__c = compania.Id;
        sv.AccountId = cuenta.Id;
        sv.POL_LKP_Producto_Cia__c = producto.Id;
        insert sv;

        
        
      	NuevaVersion = new  Version_ContratoServicio__c();
       	NuevaVersion.Name = '10';
        NuevaVersion.POLV_LKP_PolizaContrato__c = sv.Id;
        NuevaVersion.POLV_SEL_Pais__c = 'ES';
        NuevaVersion.POLV_SEL_Idioma__c = '2';
        Date myDate = Date.newInstance(2018, 5, 6);
        Date newDate = mydate.addDays(2);
        NuevaVersion.POLV_DAT_FechaFin__c = newDate;
        NuevaVersion.POLV_DAT_FechaInicio__c = myDate;
        
        Insert NuevaVersion;

        caso = Util_Tests.crearCasoB2B(sv.Id,asegurado.Id,compania.id);
        insert caso;
        
        sv.POL_LKP_Version_Actual__c= NuevaVersion.Id; 
        update sv;

        contacto = new Contact();
        contacto.FirstName = 'Laura';
        contacto.LastName = 'Hdez';
        contacto.Phone = '666999888';
        insert contacto;

        contactoTelefonico = new Contacto_telefonico__c();
        contactoTelefonico.CTF_SEL_Tipo_Relacion__c = 'Asegurado';
        contactoTelefonico.CTF_SEL_Hora_desde__c = '16:00';
        contactoTelefonico.CTF_SEL_Hora_hasta__c = '18:00';
        contactoTelefonico.CTF_LKP_Poliza_Contrato__c = sv.id;
        contactoTelefonico.CTF_LKP_Contacto__c = contacto.id;
        insert contactoTelefonico;
    }

    @isTest 
	public static void noEsCliente(){
        Test.startTest();

		PageReference pageRef = Page.AltaConfirmacionCliente;
        Test.setCurrentPage(pageRef);

		accc = pruebaPage();
        AltaConfirmacionClienteController.ContactoTelefonicoPoliza accc2 = new AltaConfirmacionClienteController.ContactoTelefonicoPoliza(contacto,contactoTelefonico);     

        accc.addContactoDePoliza();
        accc.cargarUbicacion();

        Test.stopTest();

	}

	@isTest
	public static void sinClienteLlamada(){
		InicializarVariables();

		Test.startTest();

		PageReference pageRef = Page.AltaConfirmacionCliente;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('idPoliza',sv.id);
        ApexPages.currentPage().getParameters().put('idCompania',compania.id);
        ApexPages.currentPage().getParameters().put('numeroDocumento','X1234446X');

		accc = pruebaPage();
        AltaConfirmacionClienteController.ContactoTelefonicoPoliza accc2 = new AltaConfirmacionClienteController.ContactoTelefonicoPoliza(contacto,contactoTelefonico);     

		Test.stopTest();
	}

	@isTest 
	public static void noEsPolizaNueva(){        
		InicializarVariables();

        Test.startTest();

		PageReference pageRef = Page.AltaConfirmacionCliente;
        Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',cuenta.id);
        ApexPages.currentPage().getParameters().put('idPoliza',sv.id);
        ApexPages.currentPage().getParameters().put('idCompania',compania.id);
        ApexPages.currentPage().getParameters().put('idCaso',caso.id);
        ApexPages.currentPage().getParameters().put('numeroDocumento','X1234446X');
        ApexPages.currentPage().getParameters().put('telefono1','697381155');
        ApexPages.currentPage().getParameters().put('telefono2','697381156');
        ApexPages.currentPage().getParameters().put('telefono3','697381157');
        ApexPages.currentPage().getParameters().put('telefono4','697381158');
        ApexPages.currentPage().getParameters().put('nombreCliente','Laura');
        ApexPages.currentPage().getParameters().put('nuevaPoliza','viejaPoliza');
        
		accc = pruebaPage();
        AltaConfirmacionClienteController.ContactoTelefonicoPoliza accc2 = new AltaConfirmacionClienteController.ContactoTelefonicoPoliza(contacto,contactoTelefonico);

        accc.addContactoDePoliza();
        Boolean emailValidarEliminar = accc.validaEliminarContacto(1);
        accc.nuevoContacto();
        accc.cancelarContacto();
        accc.volverBusquedaPoliza();
        //accc.navegarDetallePoliza();
        accc.navegarSiniTipoInterlocutor();
        //accc.navegarB2BGremios();
        accc.cargarUbicacion();

        Test.stopTest();

	}

	@isTest 
	public static void esPolizaNueva(){
		InicializarVariables();

        Test.startTest();

		PageReference pageRef = Page.AltaConfirmacionCliente;
        Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',cuenta.id);
        ApexPages.currentPage().getParameters().put('idPoliza',sv.id);
        ApexPages.currentPage().getParameters().put('idCompania',compania.id);
        ApexPages.currentPage().getParameters().put('idCaso',caso.id);
        ApexPages.currentPage().getParameters().put('numeroDocumento','X1234446X');
        ApexPages.currentPage().getParameters().put('telefono1','697381155');
        ApexPages.currentPage().getParameters().put('telefono2','697381156');
        ApexPages.currentPage().getParameters().put('telefono3','697381157');
        ApexPages.currentPage().getParameters().put('telefono4','697381158');
        ApexPages.currentPage().getParameters().put('nombreCliente','Laura');
        ApexPages.currentPage().getParameters().put('apellido1','Hdez');
        ApexPages.currentPage().getParameters().put('apellido2','zor');
        ApexPages.currentPage().getParameters().put('nuevaPoliza','true');

		accc = pruebaPage();
        AltaConfirmacionClienteController.ContactoTelefonicoPoliza accc2 = new AltaConfirmacionClienteController.ContactoTelefonicoPoliza(contacto,contactoTelefonico);     

        accc.addContactoDePoliza();
        accc.mostrarAyudaTelefonoCompania();
        Boolean emailValidarEliminar = accc.validaEliminarContacto(1);
        accc.nuevoContacto();
        accc.cancelarContacto();
        accc.volverBusquedaPoliza();
        //accc.navegarDetallePoliza();
        accc.navegarSiniTipoInterlocutor();
        //accc.navegarB2BGremios();
        accc.cargarUbicacion();

        Test.stopTest();

	}

	@isTest
	static void mostrarAyudaTelefonica(){
		InicializarVariables();

		Test.startTest();
		PageReference pageRef = Page.AltaConfirmacionCliente;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('indiceResultado','0');
        ApexPages.currentPage().getParameters().put('id',cuenta.id);
        ApexPages.currentPage().getParameters().put('idPoliza',sv.id);
        ApexPages.currentPage().getParameters().put('idCompania',compania.id);
        ApexPages.currentPage().getParameters().put('idCaso',caso.id);
        ApexPages.currentPage().getParameters().put('numeroDocumento','X1234446X');
        ApexPages.currentPage().getParameters().put('telefono1','697381155');
        ApexPages.currentPage().getParameters().put('telefono2','697381156');
        ApexPages.currentPage().getParameters().put('telefono3','697381157');
        ApexPages.currentPage().getParameters().put('telefono4','697381158');
        ApexPages.currentPage().getParameters().put('nombreCliente','Laura');
        ApexPages.currentPage().getParameters().put('apellido1','Hdez');
        ApexPages.currentPage().getParameters().put('apellido2','zor');
        ApexPages.currentPage().getParameters().put('nuevaPoliza','true');
		accc = pruebaPage();
        AltaConfirmacionClienteController.ContactoTelefonicoPoliza accc2 = new AltaConfirmacionClienteController.ContactoTelefonicoPoliza(contacto,contactoTelefonico);     

		accc.telefonoSeleccionado = compania.id;
		
        accc.addContactoDePoliza();
        accc.seleccionarResultado();
        accc.addContactoDePoliza();
 
		Test.stopTest();
	}

    @isTest
    static void eleminarContacto(){
        InicializarVariables();

        Test.startTest();
        PageReference pageRef = Page.AltaConfirmacionCliente;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('indiceResultado','1');
        ApexPages.currentPage().getParameters().put('id',cuenta.id);
        ApexPages.currentPage().getParameters().put('idPoliza',sv.id);
        ApexPages.currentPage().getParameters().put('idCompania',compania.id);
        ApexPages.currentPage().getParameters().put('idCaso',caso.id);
        ApexPages.currentPage().getParameters().put('numeroDocumento','X1234446X');
        ApexPages.currentPage().getParameters().put('telefono1','697381155');
        ApexPages.currentPage().getParameters().put('telefono2','697381156');
        ApexPages.currentPage().getParameters().put('telefono3','697381157');
        ApexPages.currentPage().getParameters().put('telefono4','697381158');
        ApexPages.currentPage().getParameters().put('nombreCliente','Laura');
        ApexPages.currentPage().getParameters().put('apellido1','Hdez');
        ApexPages.currentPage().getParameters().put('apellido2','zor');
        ApexPages.currentPage().getParameters().put('nuevaPoliza','true');

        accc = pruebaPage();
        AltaConfirmacionClienteController.ContactoTelefonicoPoliza accc2 = new AltaConfirmacionClienteController.ContactoTelefonicoPoliza(contacto,contactoTelefonico);     
        
        Account cliente = accc.cliente;
        cliente.CUE_SEL_Tipo_Documento__c = 'C';
        accc.cliente = cliente;
        accc.poblacion = 'Murcia';

        accc.guardar();
        accc.eliminarContacto();
    }

    @isTest
    static void eleminarContactoConError(){
        InicializarVariables();

        Test.startTest();
        PageReference pageRef = Page.AltaConfirmacionCliente;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('indiceResultado','1');
        ApexPages.currentPage().getParameters().put('id',cuenta.id);
        ApexPages.currentPage().getParameters().put('idPoliza',sv.id);
        ApexPages.currentPage().getParameters().put('idCompania',compania.id);
        ApexPages.currentPage().getParameters().put('idCaso',caso.id);
        ApexPages.currentPage().getParameters().put('numeroDocumento','SSSDDSSSD');
        ApexPages.currentPage().getParameters().put('telefono1','697381155');
        ApexPages.currentPage().getParameters().put('telefono2','697381156');
        ApexPages.currentPage().getParameters().put('telefono3','697381157');
        ApexPages.currentPage().getParameters().put('telefono4','697381158');
        ApexPages.currentPage().getParameters().put('nombreCliente','Laura');
        ApexPages.currentPage().getParameters().put('apellido1','Hdez');
        ApexPages.currentPage().getParameters().put('apellido2','zor');
        ApexPages.currentPage().getParameters().put('nuevaPoliza','true');

        accc = pruebaPage();
        AltaConfirmacionClienteController.ContactoTelefonicoPoliza accc2 = new AltaConfirmacionClienteController.ContactoTelefonicoPoliza(contacto,contactoTelefonico);     
        
        Account cliente = accc.cliente;
        cliente.CUE_SEL_Tipo_Documento__c = 'C';
        accc.cliente = cliente;
        accc.poblacion = 'Murcia';

        accc.guardar();
        accc.eliminarContacto();
    }

	static AltaConfirmacionClienteController pruebaPage(){
        Account a = Util_Tests.crearCuentaB2BPpal('Name2','12355', 'X1234667X');
        insert a;

        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        accc = new AltaConfirmacionClienteController(sc);

		return accc;
    }

}