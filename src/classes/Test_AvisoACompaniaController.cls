@isTest 
public without sharing class Test_AvisoACompaniaController {
	
	private static Account compania;
	private static Account cuentaDePoliza;
	
	//Producto y sus dependencias:
	private static Producto_CIA__c productoDeCompania;
	private static Tipo_Producto_CIA__c tipoDeProductoCompania;
	
	private static Contact contactoDeCuenta;
	
	private static ServiceContract poliza;
	private static Version_ContratoServicio__c versionPolizaActiva;
	
	private static OperatingHours horaFuncionamiento;
	
	private static Poblacion__c poblacion;
	private static Poblacion_CP__c poblacionCP ;
	private static ServiceTerritory territorioDeServicio;
	
	
	
	public static void InicializarVariables(){
		
		//1.CREAMOS LA CUENTA DE UNA COMPAÑÍA (i.e. Patria Hispana)
			//-->compania = Util_Tests.crearCuentaCompania(String Name,String identificador, String cif);
		compania = Util_Tests.crearCuentaCompania('Patria Hispana','1008','C57852758');	
		insert compania;
		system.debug('@ARL Compania[OK]:'+compania);
		//2.CREAMOS UNA CUENTA QUE CORRESPONDERÁ AL CLIENTE DE LA PÓLIZA, EL ASEGURADO
			//	crearCuentaAsegurado(String Name, String identificador, String email,
			//	String numDocumento,String nombre, String primerApellido, String segundoApellido)
		cuentaDePoliza = Util_Tests.crearCuentaAsegurado('Alejandro Rey López', '010100100', 'coredamnwork@gmail.com',
			'04626393N','Alejandro','Rey', 'López');
		Account cuentaAux = Util_Tests.crearCuentaB2BPpal('Lolo','010100101','D62541818' );
		insert cuentaAux;
		cuentaDePoliza.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert cuentaDePoliza;
		system.debug('@ARL CuentaDePoliza[OK]:'+cuentaDePoliza);
		//3.CREAMOS EL CONTACTO DE ASOCIADO A LA CUENTA DEL ASEGURADO
			// crearContacto(String nombre, String apellidos)
		contactoDeCuenta = Util_Tests.crearContacto('Allehandro','RRey Lopess');
		contactoDeCuenta.Account = cuentaDePoliza;
		insert contactoDeCuenta;
		system.debug('@ARL ContactoDePóliza[OK]:'+contactoDeCuenta);
		//4.CREAMOS TIPO DE PRODUCTO (Tipo de póliza)
		tipoDeProductoCompania = Util_Tests.crearTipoProductoCIA('Patria - TIPO EJEMPLO','01',compania.ID);
		insert tipoDeProductoCompania;
		system.debug('@ARL TipoDeProductoCompañía[OK]:'+tipoDeProductoCompania);
		//5.CREAMOS EL OBJETO PRODUCTO DE COMPANIA
		productoDeCompania = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoDeProductoCompania.Id);
		insert productoDeCompania;
		system.debug('@ARL ProductoDeCompania[OK]:'+productoDeCompania);
		//6.CREAMOS LA PÓLIZA crearPolizaContrato(String nombre, Id idCompania, Id idCuenta, Id idProductoCIA)
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuentaDePoliza.Id,productoDeCompania.Id);
		insert poliza;
		system.debug('@ARL Póliza[OK]:'+poliza);
		//7.CREAMOS LA VERSIÓN DE LA PÓLIZA crearVersionPoliza( Id poliza, Date fechaInicio)
		versionPolizaActiva = Util_Tests.crearVersionPoliza(poliza.Id,date.today());
		insert versionPolizaActiva;
		system.debug('@ARL Versión de la póliza[OK]:'+versionPolizaActiva);
		poliza.POL_LKP_Version_Actual__c = versionPolizaActiva.Id;
		//8.CREAMOS POBLACION 
			//poblacion = Util_Tests.crearPoblacion(String nombre, String provincia)
			poblacion = Util_Tests.crearPoblacion('Madrid','28');
			insert poblacion;
				system.debug('@ARL Población[OK]:'+poblacion);
			//9, CREAMOS HORA DE FUNCIONAMIENTO
				//horaFuncionamiento = crearHoraFuncionamiento(String nombre, String zona)		
				horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
				insert horaFuncionamiento;
				system.debug('@ARL HoraFuncionamiento[OK]:'+poblacion);
		//10.CREAMOS TERRITORIO DE SERVICIO
		//territorioDeServicio =  Util_Tests.crearTerritorioServicio(String nombre,Id id_HoraFuncionamiento,String codigo_postal);
		territorioDeServicio  =  Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
		territorioDeServicio.TDS_TXT_Identificador__c = '28001';
		insert territorioDeServicio;
			system.debug('@ARL Territorio de Servicio[OK]:'+territorioDeServicio);
		//11.Poblacion_CP__c crearPoblacionCP(String nombre,Id id_poblacion,Id id_territorioServicio, String codigo_postal)
		poblacionCP  = Util_Tests.crearPoblacionCP('Madrid',poblacion.Id,territorioDeServicio.Id,'28001');
		insert poblacionCP;
			system.debug('@ARL PoblacionCP[OK]:'+poblacionCP);
	}
	
	@isTest
	public static void iniciarPrueba(){
		InicializarVariables();
		Test.setCurrentPage(Page.AvisoACompania);
		Test.StartTest();
		ApexPages.currentPage().getParameters().put('idCompania',compania.id);
		ApexPages.currentPage().getParameters().put('idPoliza',poliza.id);
		ApexPages.currentPage().getParameters().put('nombreCliente','Alejandro');
		ApexPages.currentPage().getParameters().put('numeroDocumento','04626393N');

		AvisoACompaniaController aacc;
		aacc = new AvisoACompaniaController();
		aacc.codigoPostal='28041';
		aacc.poblacion='Madrid';
		aacc.provincia='Madrid';
		aacc.cargarCodigoPostal();
		aacc.cargarPoblacion();
		aacc.codigoPostal='28041';
		aacc.cargarUbicacion();
		aacc.enviarEmail();
		aacc.cuerpoCambioSituacionRiesgo();
		aacc.formarCabeceraEmail();
		aacc.cuerpoClienteDesconocido();
		
		
		Test.StopTest();
	}

	@isTest
	public static void iniciarPruebaSinPoliza(){
		InicializarVariables();
		AvisoACompaniaController aacc;
		aacc = new AvisoACompaniaController();
		Test.setCurrentPage(Page.AvisoACompania);
		Test.StartTest();
		ApexPages.currentPage().getParameters().put('idCompania','');
		ApexPages.currentPage().getParameters().put('idPoliza',poliza.id);
		ApexPages.currentPage().getParameters().put('nombreCliente','Alejandro');
		ApexPages.currentPage().getParameters().put('numeroDocumento','04626393N');
		
		
		Test.StopTest();
	}
	
	@isTest
	public static void iniciarPruebaCompania(){
		InicializarVariables();
		AvisoACompaniaController aacc;
		aacc = new AvisoACompaniaController();
		Test.setCurrentPage(Page.AvisoACompania);
		Test.StartTest();
		ApexPages.currentPage().getParameters().put('idCompania',compania.id);
		aacc.codigoPostal='28041';
		aacc.poblacion='Madrid';
		aacc.provincia='Madrid';
		aacc.cargarCodigoPostal();
		aacc.cargarPoblacion();
		aacc.codigoPostal='28041';
		aacc.cargarUbicacion();
		aacc.numeroDocumentoClientePoliza='04626393N';
		aacc.nombreCompletoModificado='Alejandro';
		aacc.codigoPostal='28041';
		aacc.poblacion='Madrid';
		aacc.provincia='Madrid';
		aacc.enviarEmail();
		aacc.cuerpoCambioSituacionRiesgo();
		aacc.formarCabeceraEmail();
		aacc.cuerpoClienteDesconocido();
		Test.StopTest();
	}

	@isTest
	public static void iniciarPruebaPoblacion(){
		InicializarVariables();
		AvisoACompaniaController aacc;
		ApexPages.currentPage().getParameters().put('idPoliza',poliza.id);
		aacc = new AvisoACompaniaController();
		Test.setCurrentPage(Page.AvisoACompania);
		Test.StartTest();
		aacc.codigoPostal='28001';
		aacc.poblacion='Madrid';
		aacc.provincia='Madrid';
		aacc.cargarCodigoPostal();
		aacc.cargarPoblacion();
		aacc.codigoPostal='28001';
		aacc.cargarUbicacion();
		Test.StopTest();
	}

/**TODO
		private static Account compania;
		private static Account cuenta;
		private static Contact contacto;
		private static Contact contacto2;
		private static Tipo_Producto_CIA__c tipoProducto;
		private static Producto_CIA__c producto;
		private static ServiceContract sv;
		private static AvisoACompaniaController aacc;
		private static ServiceTerritory st;
		private static Poblacion__c pc;

	static void InicializarVariables(){
		cuenta = Util_Tests.crearCuentaB2BPpal('Laura','12345', 'X1234567X');
		insert cuenta;

		compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1234', 'X1234566X');
		compania.CUE_TXT_Identificador__c = Label.IDE_SEGURCAIXA;
		insert compania;

		contacto = Util_Tests.crearContacto('Laura','Hdez',compania.Id,'77723855Z');
		contacto.CON_SEL_Tipo_Programa__c = '05'; //Coordinador de Cuenta
		contacto.email = 'email@email.com';
		insert contacto;

		contacto2 = Util_Tests.crearContacto('Laura2','Hdez2',compania.Id,'77722855Z');
		contacto2.CON_SEL_Tipo_Programa__c = '04'; //Aviso a Cia
		contacto2.email = 'email2@email.com';
		insert contacto2;

		tipoProducto = Util_Tests.crearTipoProductoCIA('tipoProducto','01', compania.Id);
		insert tipoProducto;

		producto = Util_Tests.crearProductoCIA('productoCia','1234',tipoProducto.Id);
		insert producto;


		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, false, '121215', '03183', 'COMERCIO', Date.today(), 'murcia', producto.Id, '2');
		sv.POL_SEL_Estado_Provincia__c = '30';
		sv.POL_TXT_Calle__c = 'C/Robles';
		//sv.POL_LKP_Version_Actual__c = version.id;/
		insert sv;

		Version_ContratoServicio__c version = new Version_ContratoServicio__c();
		version.POLV_LKP_PolizaContrato__c = sv.id;
		version.POLV_DAT_FechaInicio__c = Date.today();
		version.POLV_DAT_FechaFin__c = Date.today()+365;
		insert version;

		OperatingHours oh = new OperatingHours();
		oh.Name='horario de verano';
		insert oh;

		st=Util_Tests.crearTerritorioServicio('30002',oh.Id,'30002');
		insert st;

		pc=Util_Tests.crearPoblacion('Murcia','30');
		insert pc;

		Poblacion_CP__c pcp=Util_Tests.crearPoblacionCP('Murcia',pc.Id, st.Id, st.PostalCode);
		insert pcp;
	}

	@isTest public static void cargarCodigoPostalConPoblacion(){

		iniciarPrueba();

		aacc.codigoPostal = st.PostalCode;
		aacc.poblacion = pc.id;
		aacc.nombreCompletoModificado = 'Laura Hdez';
		aacc.comentarios = 'HOLA';

		aacc.cargarUbicacion();
		aacc.cargarPoblacion();
		aacc.cargarCodigoPostal();
		aacc.domicilioModificado = 'C/Robles';

		aacc.enviarEmail();

	}

	public static void iniciarPrueba(){
		InicializarVariables();
		ApexPages.currentPage().getParameters().put('idCompania',compania.id);
		ApexPages.currentPage().getParameters().put('idPoliza',sv.id);
		ApexPages.currentPage().getParameters().put('nombreCliente','Laura');
		ApexPages.currentPage().getParameters().put('numeroDocumento','X1234446X');
	 
		aacc = new AvisoACompaniaController();
	}
**/
}