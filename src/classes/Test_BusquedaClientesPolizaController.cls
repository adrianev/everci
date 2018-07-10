@isTest
public class Test_BusquedaClientesPolizaController {
	private static String identificador{get;set;}
	private static Account cuenta {get;set;}
	private static Account compania {get; set;}
	private static Boolean esBusquedaAvanzada{get;set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get;set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	private static FSL__Scheduling_Policy__c politicaGeo {get; set;}
	private static OperatingHours horaFuncionamiento {get; set;}
	private static BusquedaClientesPolizaController prueba {get; set;}
	private static Callout_ConsultaPolizaVesta_RP nuevaPolizaVesta {get; set;}
	private static ServiceTerritory territorioServicio {get; set;}
	private static BusquedaClientesPolizaController.WrapperBusquedaAvanzada prueba1 {get; set;} 
	private static String numeroSiniestroHS {get;set;}
	private static String numeroPoliza {get;set;}
	private static String numeroDocumento {get;set;}
	private static String nombre {get;set;}
	private static String primerApellido {get;set;}
	private static String segundoApellido {get;set;}
	private static String viaDomicilio {get;set;}
	private static String codigoPostal {get;set;}
	private static String poblacion {get;set;}
	private static String provincia {get;set;}
	private static VDN_Compania__c companiaVDN {get; set;}
	private static Poblacion__c poblacion1 {get; set;}
	public static Account asegurado {get; set;}

	Private static List<SelectOption> listaPoblaciones {set;}
	Private static List<SelectOption> listaProvincias {set;}
	Private static Version_ContratoServicio__c NuevaVersion {get; set;}

	
	public static void InicializarVariables(boolean aseguradoV, boolean companyDNI, boolean polizaB, boolean DatosContacto){
		//Creamos COMPAÑIA
		compania = Util_Tests.crearCuentaCompania('Membership','1999','H79023677');
		compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = false;
		insert compania;
		//Creamos Cliente Asegurado
		asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '89074907R','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		if(companyDNI){
			asegurado.CUE_LKP_Cuenta_principal__c = compania.Id;
		//asegurado.CUE_TXT_Numero_Documento__c = '89074907R';
	}
	if(aseguradoV){
		insert asegurado;
		companiaVDN = Util_Tests.crearVDNCompania('6000',compania.Id);
		companiaVDN.name = 'VDN';
		insert companiaVDN;
		system.debug([SELECT Name,VDN_FOR_Cuenta__c,VDN_FOR_CuentaIdRT__c,VDN_LKP_Compania__c,VDN_LKP_Compania__r.Type,VDN_LKP_Compania__r.CUE_TXT_Identificador__c,VDN_LKP_Compania__r.Name,VDN_LKP_Compania__r.CUE_FOR_RTDevName__c,VDN_TXT_Ayuda_Busqueda__c,VDN_LKP_Compania__r.RecordType.Id,VDN_TXT_Presentacion__c FROM VDN_Compania__c] + ' carloooooooos');
	}
		//Creamos tipo de Producto
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('MEMBERSHIP - Hogar','01',compania.Id);
		insert tipoProductoCIA;
		//Creamos Producto
		productoCIA = Util_Tests.crearProductoCIA('MEMBERSHIP - MEMBERSHIP SINIESTROS','01',tipoProductoCIA.Id);
		insert productoCIA;
	 	//Creamos Poliza


		/*TODO Util_Test.CrearPoliza
	 
		poliza=new ServiceContract();
		poliza.Name='10';
		poliza.POL_TXT_Id_Version_Poliza__c='10';
		poliza.POL_TXT_Poblacion__c='Madrid';
		poliza.POL_TXT_Codigo_Postal__c='28001';
		poliza.POL_SEL_Tipo_Riesgo__c ='PISO';
		
		 
		 
	   
		if(companyDNI){
		poliza.POL_LKP_Compania__c = compania.Id;
		}
			if(aseguradoV){
			
		poliza.AccountId = asegurado.Id;
		}
		poliza.POL_LKP_Producto_Cia__c = productoCIA.Id;
		poliza.POL_CAS_IsGold__c = true;
			if(polizaB){
		insert poliza;
			   system.debug(poliza + ' poliza');
		}	
		*/		
		//Creamos Caso
		caso = new Case();
		caso.CAS_LKP_Compania__c = compania.Id;//Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
		insert caso;
		system.debug(caso + ' cassssss');

		//Creamos Nueva Poliza Vesta
		nuevaPolizaVesta = new Callout_ConsultaPolizaVesta_RP();
		nuevaPolizaVesta.estado = 'Activa';
		nuevaPolizaVesta.numeroPoliza = '1';
		nuevaPolizaVesta.idClienteEnsura='15524';
		nuevaPolizaVesta.rolAsegurado='m';
		nuevaPolizaVesta.codigoMunicipio='1234';
		nuevaPolizaVesta.numeroDocumento = '89074907R';
		nuevaPolizaVesta.identificadorVersion = '10';
		Date myDate1 = Date.newInstance(2018, 5, 6);
		Date newDate1 = mydate1.addDays(2);
		nuevaPolizaVesta.fechaInicioCobertura = myDate1;
		nuevaPolizaVesta.fechaFinCobertura = newDate1;

		

	   	//if(aseguradoV){
			 //nuevaPolizaVesta.nombre = asegurado.name;
			//}

			nuevaPolizaVesta.codigoDelegacion = '1';
			nuevaPolizaVesta.descProdAux = 'Dangerous';
			nuevaPolizaVesta.idSFProducto = productoCIA.Id;
			if(companyDNI){
				nuevaPolizaVesta.idSFCompania = compania.Id;   
			}
			nuevaPolizaVesta.perteneceHS = True;
			nuevaPolizaVesta.isGold = true;
			if (DatosContacto){
			   nuevaPolizaVesta.nombre = asegurado.name;
			   nuevaPolizaVesta.apellido1 = 'Soler';
			   nuevaPolizaVesta.apellido2 = 'Muñoz';  
			   nuevaPolizaVesta.telefono1 = '673179498';
			   nuevaPolizaVesta.telefono2 = '673145647';   
			   nuevaPolizaVesta.telefono3 = '968865340';   
			   nuevaPolizaVesta.telefono4 = '675987568';
		   }
		   poliza = Util_tests.crearPolizaContrato('10', compania.id, asegurado.id, productoCIA.id);
		   insert poliza;
		   horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
		   insert horaFuncionamiento;

		   territorioServicio = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
		   territorioServicio.isActive = true;
		   territorioServicio.TDS_TXT_Identificador__c = '28001';
		   insert territorioServicio;

		   poblacion1 =  Util_Tests.crearPoblacion('Madrid','28');
		   poblacion1.POB_TXT_Identificador__c = 'Madrid';
		   insert poblacion1;

		   Poblacion_CP__c Poblation = Util_Tests.crearPoblacionCP('Madrid',poblacion1.Id,territorioServicio.Id,'28001');
		   poblation.Name = 'Poblation';
		   insert poblation; 
	   }
	   /* Test para probar los distintos casos para obtener URL's diferentes */


	
  /*	  @isTest
		public static void NoExisteClienteAseNiPoliza(){
		InicializarVariables(false,false,false,false);
		nuevaPolizaVesta.identificadorVersion='0';
		PageReference pageRef = Page.BusquedaClientesPoliza;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0');  
		ApexPages.currentPage().getParameters().put('caseId', caso.Id);
		ApexPages.currentPage().getParameters().put('retURL', 'Y');
		ApexPages.currentPage().getParameters().put('sfdc.tabName','BusquedaClientesPolizaController');
		ApexPages.currentPage().getParameters().put('identificador','IDE1800');
		prueba = new  BusquedaClientesPolizaController();
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.buscarPolizas();
		prueba.listaPolizas.add(nuevaPolizaVesta);
		prueba.busquedaAvanzadaWrapper.provincia = 'Madrid'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '28001';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = nuevaPolizaVesta.numeroPoliza;
		prueba.busquedaAvanzadaWrapper.numeroDocumento = nuevaPolizaVesta.numeroDocumento;
		prueba.esBusquedaAvanzada=false;
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		PageReference pag = prueba.seleccionarPoliza();
		system.debug(pag.getUrl() + ' esperamos URL');
 
		//String expected = '' ;
		//System.assertEquals(expected, pag.getUrl(), 'msg');

		prueba.mostrarAyudaTelefonoCompania();
		prueba.cancelar();
		prueba.compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = True;
		//prueba.navegarAltaConfirmacionAsegurado();
		prueba.validarAvisoACia();
	  	
  
	}
	
		@isTest
		public static void NoExisteClienteAseExistePoliza(){
		InicializarVariables(false,true,true,false);
		poliza.POL_TXT_Id_Version_Poliza__c='0';
		update poliza;
		nuevaPolizaVesta.identificadorVersion='0';
		PageReference pageRef = Page.BusquedaClientesPoliza;
		Test.setCurrentPage(pageRef);
		//ApexPages.currentPage().getParameters().put('VDN',companiaVDN.Id);
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0');  
		ApexPages.currentPage().getParameters().put('caseId', caso.Id);
		ApexPages.currentPage().getParameters().put('retURL', 'Y');
		ApexPages.currentPage().getParameters().put('sfdc.tabName','BusquedaClientesPolizaController');
		ApexPages.currentPage().getParameters().put('identificador','IDE1800'); 
		prueba = new  BusquedaClientesPolizaController();
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.buscarPolizas();
		prueba.listaPolizas.add(nuevaPolizaVesta);
		prueba.busquedaAvanzadaWrapper.provincia = 'Madrid'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '28001';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = nuevaPolizaVesta.numeroPoliza;
		prueba.busquedaAvanzadaWrapper.numeroDocumento = nuevaPolizaVesta.numeroDocumento;
		prueba.esBusquedaAvanzada=false;
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.seleccionarPoliza();
		prueba.mostrarAyudaTelefonoCompania();
		prueba.cancelar();
		prueba.compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = True;
		//prueba.navergarAltaConfirmacionAsegurado();
		prueba.validarAvisoACia();
	  
	}
	
			@isTest
		public static void NoExisteClienteAseExistePolizaConVersionAnterior(){
		InicializarVariables(false,true,true,false);
		poliza.POL_TXT_Id_Version_Poliza__c='10';
		poliza.POL_CAS_Activo__c = true;
		update poliza;
		nuevaPolizaVesta.identificadorVersion='20';
		PageReference pageRef = Page.BusquedaClientesPoliza;
		Test.setCurrentPage(pageRef);
		//ApexPages.currentPage().getParameters().put('VDN',companiaVDN.Id);
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0');  
		ApexPages.currentPage().getParameters().put('caseId', caso.Id);
		ApexPages.currentPage().getParameters().put('retURL', 'Y');
		ApexPages.currentPage().getParameters().put('sfdc.tabName','BusquedaClientesPolizaController');
		ApexPages.currentPage().getParameters().put('identificador','IDE1800'); 
		prueba = new  BusquedaClientesPolizaController();
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.buscarPolizas();
		prueba.listaPolizas.add(nuevaPolizaVesta);
		prueba.busquedaAvanzadaWrapper.provincia = 'Madrid'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '28001';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = nuevaPolizaVesta.numeroPoliza;
		prueba.busquedaAvanzadaWrapper.numeroDocumento = nuevaPolizaVesta.numeroDocumento;
		prueba.esBusquedaAvanzada=false;
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.seleccionarPoliza();
		prueba.mostrarAyudaTelefonoCompania();
		prueba.cancelar();
		prueba.compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = True;
		//prueba.navergarAltaConfirmacionAsegurado();
		prueba.validarAvisoACia();
	  
	}
	
			@isTest
		public static void ExisteClienteNoExistePoliza(){
		InicializarVariables(true,false,false,false);

		nuevaPolizaVesta.identificadorVersion='0';
		PageReference pageRef = Page.BusquedaClientesPoliza;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN',companiaVDN.Id);
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0');  
		ApexPages.currentPage().getParameters().put('caseId', caso.Id);
		ApexPages.currentPage().getParameters().put('retURL', 'Y');
		ApexPages.currentPage().getParameters().put('sfdc.tabName','BusquedaClientesPolizaController');
		ApexPages.currentPage().getParameters().put('identificador','IDE1800'); 
		prueba = new  BusquedaClientesPolizaController();
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.buscarPolizas();
		prueba.listaPolizas.add(nuevaPolizaVesta);
		prueba.busquedaAvanzadaWrapper.provincia = 'Madrid'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '28001';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = nuevaPolizaVesta.numeroPoliza;
		prueba.busquedaAvanzadaWrapper.numeroDocumento = nuevaPolizaVesta.numeroDocumento;
		prueba.esBusquedaAvanzada=false;
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.seleccionarPoliza();
		prueba.mostrarAyudaTelefonoCompania();
		prueba.cancelar();
		prueba.compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = True;
		//prueba.navergarAltaConfirmacionAsegurado();
		prueba.validarAvisoACia();
	  
	  
	}
	
		 @isTest
		public static void ExisteClienteExistePoliza(){
		InicializarVariables(true,true,true,false);

		nuevaPolizaVesta.identificadorVersion='10';
		PageReference pageRef = Page.BusquedaClientesPoliza;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN',companiaVDN.Id);
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0');  
		ApexPages.currentPage().getParameters().put('caseId', caso.Id);
		ApexPages.currentPage().getParameters().put('retURL', 'Y');
		ApexPages.currentPage().getParameters().put('sfdc.tabName','BusquedaClientesPolizaController');
		ApexPages.currentPage().getParameters().put('identificador','IDE1800'); 
		prueba = new  BusquedaClientesPolizaController();
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.buscarPolizas();
		prueba.listaPolizas.add(nuevaPolizaVesta);
		prueba.busquedaAvanzadaWrapper.provincia = 'Madrid'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '28001';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = nuevaPolizaVesta.numeroPoliza;
		prueba.busquedaAvanzadaWrapper.numeroDocumento = nuevaPolizaVesta.numeroDocumento;
		prueba.esBusquedaAvanzada=false;
		PageReference pag = prueba.seleccionarPoliza();
		system.assertEquals('/apex/altaconfirmacioncliente?id=' +asegurado.Id + '&idCaso=' + caso.Id + '&idCompania=' + compania.Id + '&idPoliza=' + poliza.Id + '&nuevaPoliza=false&numeroDocumento=89074907R&retURL=apex%2FBusquedaClientesPoliza%3F%26caseId%3D' + caso.Id + '%26VDN%3DVDN%26identificador%3DIDE1800&VDN=VDN',pag.getUrl() + '');
		prueba.caso.CAS_LKP_Compania__c = compania.Id;
		prueba.mostrarAyudaTelefonoCompania();
		prueba.cancelar();
		prueba.compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = True;
		//prueba.navergarAltaConfirmacionAsegurado();
		prueba.validarAvisoACia();
	  
	  
	}
	
	*/
	
   
	@isTest
	public static void ExisteClienteExistePolizaSinCaso(){
		InicializarVariables(true,true,true,false);
		update poliza;
		nuevaPolizaVesta.identificadorVersion='20';
		nuevaPolizaVesta.identificadorVersion='10';
		PageReference pageRef = Page.BusquedaClientesPoliza;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('VDN',companiaVDN.Id);
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0');  
		//ApexPages.currentPage().getParameters().put('caseId', caso.Id);
		ApexPages.currentPage().getParameters().put('retURL', 'Y');
		ApexPages.currentPage().getParameters().put('sfdc.tabName','BusquedaClientesPolizaController');
		ApexPages.currentPage().getParameters().put('identificador','IDE1800'); 
		prueba = new  BusquedaClientesPolizaController();
		prueba.cuentaFiltro = asegurado;
		prueba.buscarPolizas();
		prueba.listaPolizas = new List<Callout_ConsultaPolizaVesta_RP>();
		prueba.listaPolizas.add(nuevaPolizaVesta);
		prueba.busquedaAvanzadaWrapper.provincia = 'Madrid'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '28001';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = nuevaPolizaVesta.numeroPoliza;
		prueba.busquedaAvanzadaWrapper.numeroDocumento = nuevaPolizaVesta.numeroDocumento;
		prueba.esBusquedaAvanzada=false;
		prueba.seleccionarPoliza();
		//system.assertEquals('/apex/altaconfirmacioncliente?id=' +asegurado.Id + '&idCaso=' + caso.Id + '&idCompania=' + compania.Id + '&idPoliza=' + poliza.Id + '&nuevaPoliza=false&numeroDocumento=89074907R&retURL=apex%2FBusquedaClientesPoliza%3F%26caseId%3D' + caso.Id + '%26VDN%3DVDN%26identificador%3DIDE1800&VDN=VDN',pag.getUrl() + '');
		prueba.mostrarAyudaTelefonoCompania();
		prueba.cancelar();
		prueba.compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = True;
		prueba.validarAvisoACia();
		prueba.navegarSiniIntervencionSinPoliza();

	}
	
	@isTest
	public static void ExisteClienteExistePolizaConVerInferior(){
		InicializarVariables(true,true,true,false);
		update poliza;
		nuevaPolizaVesta.identificadorVersion='20';
		PageReference pageRef = Page.BusquedaClientesPoliza;
		Test.setCurrentPage(pageRef);
		//ApexPages.currentPage().getParameters().put('VDN',companiaVDN.Name);
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0');  
		ApexPages.currentPage().getParameters().put('caseId', caso.Id);
		ApexPages.currentPage().getParameters().put('retURL', 'Y');
		ApexPages.currentPage().getParameters().put('sfdc.tabName','BusquedaClientesPolizaController');
		ApexPages.currentPage().getParameters().put('identificador','IDE1800'); 
		prueba = new  BusquedaClientesPolizaController();
		prueba.buscarPolizas();
		prueba.listaPolizas = new List<Callout_ConsultaPolizaVesta_RP>();
		prueba.listaPolizas.add(nuevaPolizaVesta);
		prueba.busquedaAvanzadaWrapper.provincia = 'Madrid'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '28001';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = nuevaPolizaVesta.numeroPoliza;
		prueba.busquedaAvanzadaWrapper.numeroDocumento = nuevaPolizaVesta.numeroDocumento;
		prueba.esBusquedaAvanzada=false;
		prueba.seleccionarPoliza();
		prueba.mostrarAyudaTelefonoCompania();
		prueba.cancelar();
		prueba.compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c = True;
		prueba.validarAvisoACia();
	}


	/*Test para cubrir la maxima cantidad posible de codigo */
	

 
 
 
	@isTest
	public static void testmetodo(){
	   InicializarVariables(false,true,true,false);
	   update poliza;
	   prueba1 = new BusquedaClientesPolizaController.WrapperBusquedaAvanzada();
	   prueba1.poblacion = 'Santomera';
	   prueba1.provincia = 'Madrid';
	   prueba1.cargarCodigoPostal();
	   prueba1.cargarPoblacion();
	   prueba1.cargarUbicacion();
	   prueba1.codigoPostal = '28001';
	   prueba1.cargarUbicacion();
   }


	@isTest
	public static void Validaciones (){
		InicializarVariables(true,true,true,false);
		update poliza;
		prueba = new  BusquedaClientesPolizaController();
		prueba.esBusquedaAvanzada= true;
		prueba.busquedaAvanzadaWrapper.provincia = 'Murcia';
		ApexPages.currentPage().getParameters().put('polizaSeleccionada', '0'); 
		//prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '30140';
		prueba.busquedaAvanzadaWrapper.nombre = 'Alberto';
		//prueba.busquedaAvanzadaWrapper.primerApellido = 'Soler';
		prueba.busquedaAvanzadaWrapper.segundoApellido = 'Muñoz';
		//prueba.busquedaAvanzadaWrapper.viaDomicilio = 'C/Santo Domingo';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = '1020304050';
		prueba.busquedaAvanzadaWrapper.numeroDocumento = 'X1234567X';
		prueba.buscarPolizas();

	}

	@isTest
	public static void Validaciones1 (){
		InicializarVariables(true,true,true,false);
		update poliza;
		prueba = new  BusquedaClientesPolizaController();
		prueba.esBusquedaAvanzada= true;
		prueba.busquedaAvanzadaWrapper.provincia = 'Murcia'; 
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = '1020304050';
		prueba.busquedaAvanzadaWrapper.numeroDocumento = 'X1234567X';
		prueba.buscarPolizas();
	}

	@isTest
	public static void Validaciones2 (){
		InicializarVariables(true,true,true,false);
		update poliza;
		prueba = new  BusquedaClientesPolizaController();
		prueba.esBusquedaAvanzada= true;
		prueba.cuentaFiltro = asegurado;
		prueba.busquedaAvanzadaWrapper.provincia = 'Murcia'; 
		prueba.busquedaAvanzadaWrapper.poblacion =  ' Santomera';
		prueba.busquedaAvanzadaWrapper.codigoPostal =  '30140';
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = '1020304050';
		prueba.busquedaAvanzadaWrapper.numeroDocumento = 'X1234567X';
		prueba.buscarPolizas();
		
	}

	@isTest
	public static void populateSectionCompaniaFromVisual (){
		InicializarVariables(true,true,true,false); 
		update poliza;
		prueba = new  BusquedaClientesPolizaController();
		prueba.esBusquedaAvanzada= true;
		prueba.busquedaAvanzadaWrapper.viaDomicilio = 'C/Santo Domingo';
		prueba.buscarPolizas();
		prueba.populateSectionCompaniaFromVisual();

	}

	@isTest
	public static void validarAvisoACiaFalse (){
		InicializarVariables(true,true,true,false);
		update poliza;
		prueba = new  BusquedaClientesPolizaController();
		prueba.esBusquedaAvanzada= true;
		prueba.busquedaAvanzadaWrapper.viaDomicilio = 'C/Santo Domingo';
		prueba.validarAvisoACia();

	}

	@isTest
	public static void validarAvisoACiaTrue (){
		InicializarVariables(true,true,true,false);
		update poliza;
		prueba = new  BusquedaClientesPolizaController();
		prueba.esBusquedaAvanzada= true;
		prueba.setBusqueda();
		prueba.busquedaAvanzadaWrapper.viaDomicilio = 'C/Santo Domingo';
		prueba.validarAvisoACia();

	}
	
	 @isTest
	public static void populateFromVDN (){
		InicializarVariables(true,true,true,false);
		update poliza;
	   
		 ApexPages.currentPage().getParameters().put('vdnName',companiaVDN.Name) ;
	   	 ApexPages.currentPage().getParameters().put('idCompania', compania.Id);
	   	prueba = new  BusquedaClientesPolizaController();
		
		prueba.busquedaAvanzadaWrapper.viaDomicilio = 'C/Santo Domingo';
		prueba.cuentaFiltro = asegurado;
		prueba.esBusquedaAvanzada= true;
		prueba.buscarPolizas();
	   
	   //Sin Parámetros de búsqueda
	   prueba.busquedaAvanzadaWrapper = new BusquedaClientesPolizaController.WrapperBusquedaAvanzada();
	   prueba.buscarPolizas();
	   //Nombre relleno y apellido en blanco
	   	prueba.busquedaAvanzadaWrapper.nombre = 'Alejandro';
		prueba.busquedaAvanzadaWrapper.primerApellido = '';
	 	prueba.buscarPolizas();
	 	
	 	//búsqueda simple con ayuda creada
	 	Ayuda__c  ayudac = new Ayuda__c();
	 	ayudac.AYU_LKP_Compania__c = compania.Id;
	 	ayudac.AYU_SEL_Tipo__c ='Ayuda árbol: Grupo de causa';
	 	ayudac.AYU_TXT_Descripcion__c = 'Seleccionar este grupo para todos los siniestros provocados por el agua debido a rotura de conducciones, atascos, escapes de agua, etc. Excepto siniestros de Lluvia extraordinaria, Nieve, Inundación o Pedrisco que se deben de abrir por Extensión de garantías.Para la parte INDEMNIZABLE y Lesiones corporales remitir al asegurado al teléfono: 91 566 40 07 / 91 566 40 33 / 91 566 40 36 / 91 566 40 30 (Horario de Lunes a Viernes de 9h a 18h).';
	 	ayudac.AYU_TXT_Identificador__c =	'AY-GC-1';
	 	insert ayudac;
	 	prueba.esBusquedaAvanzada= false;
	 	prueba.identificador ='IDE9800'; 
	 	prueba.buscarPolizas();
	 	 
	 	//ejecución de: populateSectionCompaniaFromVisual
	 	prueba.populateSectionCompaniaFromVisual();
	 	
	 	//Búsqueda avanzada 
	 	prueba.busquedaAvanzadaWrapper.provincia = 'Murcia'; 
		prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '01';
		prueba.busquedaAvanzadaWrapper.numeroPoliza = '1020304050';
		prueba.busquedaAvanzadaWrapper.numeroDocumento = 'X1234567X';
	   	prueba.esBusquedaAvanzada= true;
		prueba.buscarPolizas();	
		//búsqueda avanzada 2
		prueba.busquedaAvanzadaWrapper.codigoPostal = '16400';
		prueba.busquedaAvanzadaWrapper.poblacion = 'Tarancón';
		prueba.busquedaAvanzadaWrapper.provincia = 'Cuenca';
		 prueba.buscarPolizas();	
		
	 
  /*  prueba.busquedaAvanzadaWrapper.numeroSiniestroHS = '';
	prueba.busquedaAvanzadaWrapper.numeroPoliza = ''
	prueba.busquedaAvanzadaWrapper.numeroDocumento

	prueba.busquedaAvanzadaWrapper.segundoApellido
	prueba.busquedaAvanzadaWrapper.viaDomicilio
	prueba.busquedaAvanzadaWrapper.codigoPostal
	prueba.busquedaAvanzadaWrapper.poblacion
	prueba.busquedaAvanzadaWrapper.provincia
	prueba.busquedaAvanzadaWrapper.listaPoblaciones
	prueba.busquedaAvanzadaWrapper.listaProvincias
	prueba.busquedaAvanzadaWrapper.numeroSiniestroCia*/
	   
	   
		Telefonos_Transfer_CIA__c tfnoTransfer =  Util_Tests.nuevoTransferCIA ('mensaje de ayuda', compania.Id, 'Descripcion telefono');
		insert tfnoTransfer;
		
		prueba.telefonoSeleccionado = String.valueOf(tfnoTransfer.Id) ;
	  	prueba.mostrarAyudaTelefonoCompania(); 
	  	
	  	

	}
	
	
	
	
}