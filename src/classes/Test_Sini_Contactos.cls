@isTest
public without sharing class Test_Sini_Contactos extends TestSetup {
	
	public static SiniContactosController siniContactos  {get; set;}  
 	
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
 
 	private static Case siniestroPoliza ;
 	private static Case casob2b ;
 	private static Perito__c perito;
 
 	private static WorkType tipoTrabajo;
 	private static WorkOrder ordenDeTrabajoAsociadaSiniestro;
 	private static WorkOrder ordenDeTrabajoAsociadaCasoB2B;
 
 	private static Contact contacto;
 	private static Contacto_telefonico__c contactoTelefonico;
 
 	@isTest
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
		cuentaDePoliza.CUE_LKP_Cuenta_principal__c = cuentaAux.Id;
		cuentaDePoliza.CUE_LKP_Cuenta_principal__c=compania.Id;
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
		system.debug('@ARL ProductoDeCompania[OK]:'+ productoDeCompania);
		//6.CREAMOS LA PÓLIZA crearPolizaContrato(String nombre, Id idCompania, Id idCuenta, Id idProductoCIA)
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuentaDePoliza.Id,productoDeCompania.Id);
		insert poliza;
		system.debug('@ARL Póliza[OK]:'+poliza);
		//7.CREAMOS LA VERSIÓN DE LA PÓLIZA crearVersionPoliza( Id poliza, Date fechaInicio)
		versionPolizaActiva = Util_Tests.crearVersionPoliza(poliza.Id,date.today());
		insert versionPolizaActiva;
		system.debug('@ARL Versión de la póliza[OK]:'+versionPolizaActiva);
		poliza.POL_LKP_Version_Actual__c = versionPolizaActiva.Id;
		
		//8. CREACIÓN DE CASOS 
		siniestroPoliza = Util_Tests.crearCasoB2B(poliza.Id, cuentaDePoliza.Id ,compania.Id);
		siniestroPoliza.CAS_LKP_PolizaContrato__c =poliza.Id ;
		//siniestroPoliza.CAS_LKP_Cliente_contable_cliente__c = compania.Id;
		//casob2b = Util_Tests.crearCasoB2B(poliza.Id,cuentaDePoliza.Id, compania.Id);
		//Asignamos un perito
		
		//8.1.CREACIÓN DE PERITO
		perito =  Util_Tests.crearPerito(compania.Id, false, 'Pepe Perito Star');
		perito.PER_SEL_Tipo_Documento__c='N';
		perito.PER_TXT_Numero_Documento__c='44726455B';
		
		insert perito;
		siniestroPoliza.CAS_LKP_Perito__c = perito.Id;
		
		insert siniestroPoliza;
		//insert casob2b;
		
		
		//9. Creación de WORKTYPE para Orden de trabajo
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		
		//10. CREAR ORDEN DE TRABAJO: crearOrdenTrabajo(String numHS, String gremio, Id idTipoTrabajo, Id idCaso)
		//10.1. Orden de trabajo asociada a un siniestro
		ordenDeTrabajoAsociadaSiniestro = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,siniestroPoliza.Id);
		ordenDeTrabajoAsociadaSiniestro.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		ordenDeTrabajoAsociadaSiniestro.AccountId = cuentaDePoliza.Id;
		insert ordenDeTrabajoAsociadaSiniestro;
		//10.2. Orden de trabajo asociada a un caso b2b
		//ordenDeTrabajoAsociadaCasoB2B = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,casob2b.Id);
		//ordenDeTrabajoAsociadaCasoB2B.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		//ordenDeTrabajoAsociadaCasoB2B.AccountId = cuentaDePoliza.Id;
		//insert ordenDeTrabajoAsociadaCasoB2B;
		
		//12.CREAMOS CONTACTOS
		//crearContacto(String nombre, String apellidos)
		contacto = Util_Tests.crearContacto('Juan','Magán');
		insert contacto;
		
		//13.Creamos CONTACTOS TELEfÓNICOS crearContactoTelefonico(String name, Id idCaso, Id idContacto , boolean isContactoPoliza, boolean sms)
		contactoTelefonico = Util_Tests.crearContactoTelefonico(siniestroPoliza.Id, contacto.Id ,true,false);
		contactoTelefonico.CTF_LKP_Poliza_Contrato__c = poliza.Id;
		insert contactoTelefonico;
		
	   
 	}
 	
 	 @isTest static void testSiniContactos(){
 	 	
 	 	InicializarVariables();
 	 	PageReference pageRef = Page.Sini_Contactos;
		Test.setCurrentPage(pageRef);
		Test.startTest();
 	 	//Ejecución de constructor sin incorporar id
 	 	ApexPages.currentPage().getParameters().put('ohgad','');
 	 	ApexPages.StandardController stdc = new ApexPages.StandardController(new Case());
		siniContactos = new SiniContactosController(stdc);
 	 	
 	 	ApexPages.currentPage().getParameters().put('id','123456789');
		stdc = new ApexPages.StandardController(new Case());
		siniContactos = new SiniContactosController(stdc);
		
		
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('VDN',compania.CUE_TXT_Identificador__c);
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','/'+siniestroPoliza.Id);
		ApexPages.currentPage().getParameters().put('id',siniestroPoliza.Id);
		ApexPages.currentPage().getParameters().put('guardadoOK','true');
		
		//Ejecución con caso sin póliza asociada.
	  /* 	siniestroPoliza.CAS_LKP_Compania__c = null ;
		update siniestroPoliza;*/
		
		//Ejecución normal, 
		system.debug('@NUMBER 1');
		stdc = new ApexPages.StandardController(siniestroPoliza);
		siniContactos = new SiniContactosController(stdc);
		
		siniestroPoliza.CAS_LKP_Compania__c = compania.Id ;
		
	
		
		system.debug('@NUMBER 2');
		//prueba Crear Contacto
		siniContactos.crearContacto();
		//pruebaGuardarContacto
		siniContactos.creacionContacto = true ;
		siniContactos.nuevoContacto = contacto;
		siniContactos.nuevoContacto.LastName = 'Apellidoo';
		siniContactos.nuevoContactoT = contactoTelefonico;
		siniContactos.nuevoContactoT.Id = null;
		siniContactos.nuevoContacto = contacto;
		siniContactos.nuevoContacto.Id = null;
		siniContactos.cancelarCreacionContacto();
		siniContactos.guardarContacto();	  
		
		system.debug('@NUMBER 3');
		//Actualización contacto 
		siniContactos.creacionContacto = false ;
		siniContactos.actualizacionContacto = true ;
		siniContactos.nuevoContacto = contacto;
		siniContactos.nuevoContactoT = contactoTelefonico;
		siniContactos.nuevoContacto.LastName = 'Apellidoo2';
		siniContactos.nuevoContactoT.CTF_CAS_Contacto_Poliza__c = true;
		siniContactos.guardarContacto();	  
		  
		system.debug('@NUMBER 4');
		//SeleccionarResultado contacto poliza
		siniContactos.indiceResultado = 0;
		siniContactos.contactoDePoliza= true; 
		siniContactos.seleccionarResultado();
		 //SeleccionarResultado contacto poliza
		siniContactos.crearContacto();
		siniContactos.contactoDePoliza =false ;
		siniContactos.nuevoContacto = contacto;
		siniContactos.nuevoContacto.LastName = 'Apellidoo';
		siniContactos.nuevoContactoT.CTF_CAS_Contacto_Poliza__c = false;
		siniContactos.nuevoContactoT.CTF_CAS_SMS__c = true ;
		siniContactos.nuevoContactoT.CTF_LKP_Caso__c = siniestroPoliza.Id;
		siniContactos.nuevoContactoT.CTF_LKP_Contacto__c = contacto.Id;
		siniContactos.guardarContacto();
	  // siniContactos.seleccionarResultado();
		
		//Eliminar contacto
		siniContactos.crearContacto();
		siniContactos.nuevoContactoT.CTF_CAS_Contacto_Poliza__c = false;
		siniContactos.nuevoContactoT.CTF_LKP_Contacto__c = contacto.Id;
		siniContactos.nuevoContactoT.CTF_CAS_SMS__c = true ;
		siniContactos.nuevoContactoT.CTF_LKP_Caso__c = siniestroPoliza.Id;
		siniContactos.listaContactosCaso = new List <Contacto_Telefonico__c>();
		siniContactos.listaContactosCaso.add(contactoTelefonico);
		//insert siniContactos.nuevoContactoT;
		siniContactos.indiceListaContactos = 1;
		siniContactos.eliminarContacto();
		
		siniContactos.crearContacto();
		//pruebaGuardarContacto (Aux)
		siniContactos.creacionContacto = true ;
		siniContactos.nuevoContactoT = contactoTelefonico;
		siniContactos.nuevoContactoT.Id = null;
		siniContactos.nuevoContacto = contacto;
		siniContactos.nuevoContacto.Id = null;
		siniContactos.cancelarCreacionContacto();
		siniContactos.guardarContacto();	  
		//cancelarCreacionContacto
		siniContactos.cancelarCreacionContacto();
		
		//volver
		 siniContactos.volver();
		 
		 //navegarDetalleCaso
		siniContactos.navegarDetalleCaso(siniestroPoliza);
		
		
		Test.stopTest();
 	 	
 	 }
 	
 	 @isTest static void testSiniContactos2(){
 	 	
 	 	InicializarVariables();
 	 	PageReference pageRef = Page.Sini_Contactos;
		Test.setCurrentPage(pageRef);
		Test.startTest();
 	 	//Ejecución de constructor sin incorporar id
 	 	ApexPages.currentPage().getParameters().put('ohgad','');
 	 	ApexPages.StandardController stdc = new ApexPages.StandardController(new Case());
		siniContactos = new SiniContactosController(stdc);
 	 	
 	 	ApexPages.currentPage().getParameters().put('id','123456789');
		stdc = new ApexPages.StandardController(new Case());
		siniContactos = new SiniContactosController(stdc);
		
		
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('VDN',compania.CUE_TXT_Identificador__c);
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','/'+siniestroPoliza.Id);
		ApexPages.currentPage().getParameters().put('id',siniestroPoliza.Id);
		ApexPages.currentPage().getParameters().put('guardadoOK','true');
		
		siniContactos.indiceResultado = 10;
		siniContactos.contactoDePoliza= true;
		siniContactos.seleccionarResultado();
		
		Test.stopTest();
		 
 	 }
 	 @isTest static void testSiniContactos3(){
 	 	
 	 	InicializarVariables();
 	 	PageReference pageRef = Page.Sini_Contactos;
		Test.setCurrentPage(pageRef);
		Test.startTest();
 	 	//Ejecución de constructor sin incorporar id
 	 	ApexPages.currentPage().getParameters().put('ohgad','');
 	 	ApexPages.StandardController stdc = new ApexPages.StandardController(new Case());
		siniContactos = new SiniContactosController(stdc);
 	 	
 	 	ApexPages.currentPage().getParameters().put('id','123456789');
		stdc = new ApexPages.StandardController(new Case());
		siniContactos = new SiniContactosController(stdc);
		
		
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('VDN',compania.CUE_TXT_Identificador__c);
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','/'+siniestroPoliza.Id);
		ApexPages.currentPage().getParameters().put('id',siniestroPoliza.Id);
		ApexPages.currentPage().getParameters().put('guardadoOK','true');
		siniContactos.crearContacto();
		siniContactos.indiceResultado = 0;
		siniContactos.contactoDePoliza= false;
		siniContactos.indiceResultado = 0;
		siniContactos.seleccionarResultado();
		
		Test.stopTest();
		 
 	 }
 
/*	@isTest static void testSiniContactos(){
		PageReference pageRef = Page.Sini_Contactos;
		Test.setCurrentPage(pageRef);
		Account compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
		compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		insert cuentaPrincipal;
		Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		Tipo_Producto_CIA__c  tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract NuevaPoliza = Util_Tests.crearPolizaContrato('2277393',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
		insert NuevaPoliza;
		ServiceContract NuevaPoliza2 = Util_Tests.crearPolizaContrato('000000013',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
		insert NuevaPoliza2;
		Case Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
		insert Nuevocaso;
		ServiceContract poliza = getServiceContractByName(NuevaPoliza.Name);
		Case caso = getCaseById(poliza.Id);
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('VDN','1018');
		ApexPages.currentPage().getParameters().put('idTabBusqClientes','01r9E0000000');
		ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('guardadoOK','true');
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		siniContactos = new SiniContactosController(stdc);
		Test.startTest();
		siniContactos.crearContacto();
		siniContactos.cancelarCreacionContacto();
		siniContactos.crearContacto();
		siniContactos.nuevoContacto.LastName = 'Perez';
		siniContactos.nuevoContactoT.CTF_CAS_Contacto_Poliza__c = true;
		siniContactos.guardarContacto();		
		siniContactos.contactoDePoliza = true;
		siniContactos.indiceResultado = 0;
		*/
		/*
		ServiceContract poliza2 = getServiceContractByName(NuevaPoliza2.Name);
		Case caso2 = getCaseById(NuevaPoliza2.Id);
		Contact contacto = new Contact();
		contacto.FirstName = 'Laura';
		contacto.LastName = 'Hdez';
		contacto.Phone = '666999888';
		insert contacto;

		Contacto_telefonico__c contactoTelefonico = new Contacto_telefonico__c();
		contactoTelefonico.CTF_SEL_Tipo_Relacion__c = 'Asegurado';
		contactoTelefonico.CTF_SEL_Hora_desde__c = '16:00';
		contactoTelefonico.CTF_SEL_Hora_hasta__c = '18:00';
		contactoTelefonico.CTF_LKP_Poliza_Contrato__c = poliza2.id;
		contactoTelefonico.CTF_LKP_Contacto__c = contacto.id;
		contactoTelefonico.CTF_LKP_Caso__c = caso2.Id;
		insert contactoTelefonico;
		
		Contacto_telefonico__c contactoPoliza = getContactoTelefonicoById(caso2.Id);
		siniContactos.listaContactosPoliza.add(contactoPoliza);
		siniContactos.seleccionarResultado();
		siniContactos.contactoDePoliza = false;
		siniContactos.seleccionarResultado();
		siniContactos.guardarContacto();
		siniContactos.indiceListaContactos = 1;
		siniContactos.eliminarContacto();
		PageReference pageRef2 = siniContactos.volver();
		Test.setCurrentPage(pageRef2);
*/
 /*	  Test.stopTest();
	}
   */
   
	private static ServiceContract getServiceContractByName(String name){
		ServiceContract poliza;
		
		List<ServiceContract> listaPolizas = new List<ServiceContract>([Select Id,
								  POL_LKP_Compania__r.Name,
								  POL_LKP_Compania__r.CUE_EMA_Email__c,
								  AccountId,
								  Account.Name,
								  POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Autorizados__c
								  FROM ServiceContract Where Name = :name LIMIT 1]);
								  
	  	if(!listaPolizas.isEmpty()){
			poliza = listaPolizas.get(0);
		}else{
			throw new TestException('No existen polizas/contratos con el nombre especificado');
		}
	  	
		return poliza;
	}
	//Id,CAS_LKP_PolizaContrato__c,AccountId,CAS_LKP_Compania__c,Origin,CAS_TXT_Persona_que_llama__c
	//,RecordTypeId,status,CAS_SEL_Motivo_No_Apertura__c,CAS_SEL_Tipo_Interlocutor__c
	

  private static Case getCaseById(Id id){
		Case caso;
		
		List<Case> listaCasos = new List<Case>([Select Id,			
								  CAS_LKP_PolizaContrato__c,
								  AccountId,
								  CAS_LKP_Compania__c,
								  Origin,
								  CAS_TXT_Persona_que_llama__c,
								  RecordTypeId,
								  status,
								  CAS_SEL_Motivo_No_Apertura__c,
								  CAS_SEL_Tipo_Interlocutor__c,
								  CAS_LKP_Procedencia__c,
								  CAS_LKP_PolizaContrato__r.Name
								  FROM Case Where CAS_LKP_PolizaContrato__c = :id LIMIT 1]);
								  
	  	if(!listaCasos.isEmpty()){
			caso = listaCasos.get(0);
		}else{
			throw new TestException('No existen casos con el nombre especificado');
		}
	  	
		return caso;
	}
	
	 private static Contacto_telefonico__c getContactoTelefonicoById(Id id){
		Contacto_telefonico__c contacto;
		
		List<Contacto_telefonico__c> listaContactos = new List<Contacto_telefonico__c>([Select Id,			
								  CTF_LKP_Caso__c,
								  CTF_LKP_Contacto__c,
								  CTF_LKP_Poliza_Contrato__c,
								  CTF_CAS_Contacto_Poliza__c,
								  CTF_TXT_Observaciones__c,
								  CTF_SEL_Tipo_Relacion__c,
								  CTF_SEL_Hora_desde__c,
								  CTF_SEL_Hora_hasta__c,
								  CTF_CAS_SMS__c,
								  RecordTypeId
								  FROM Contacto_telefonico__c Where CTF_LKP_Caso__c = :id LIMIT 1]);
								  
	  	if(!listaContactos.isEmpty()){
			contacto = listaContactos.get(0);
		}else{
			throw new TestException('No existen contactos con el id especificado');
		}
	  	
		return contacto;
	}
	
}