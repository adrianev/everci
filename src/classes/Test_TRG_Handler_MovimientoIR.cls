@isTest
public without sharing class Test_TRG_Handler_MovimientoIR {

	private static TRG_Handler_MovimientoIR trg;
	private static Account compania;
	private static Account cuenta;
	private static Account cuentaSec;
	private static Tipo_Producto_CIA__c tipoProducto;
	private static Producto_CIA__c producto;
	private static ServiceContract sc;
	private static ServiceContract sc2;
	private static Case caso;
	private static Contact c;
	private static WorkType wt;
	private static WorkOrder wo;
	private static Account cuentappal;

	private static void inicializarVariables(boolean crearContacto, String contenidoLista, boolean crearVariosContactosYCasos, boolean asignarRecordTypeACasos, boolean casoPerteneceAUsuario,  boolean segmentacionVip, boolean numDocumentoNulo){
		compania = Util_Tests.crearCuentaCompania('compania', '2002', 'X7654567X');
		insert compania;

		cuenta=Util_Tests.crearCuentaB2BPpal('Name','1018', 'X1234999X');
		cuenta.Type = '01';
        insert cuenta;
		
		Account cuentaSec = Util_Tests.crearCuentaB2BSec('SegurCaixa1','1022',cuenta.Id, 'X1111167X');
		cuentaSec.Type = '01';
		cuentaSec.CUE_LKP_Cliente_contable__c = cuenta.id;
		insert cuentaSec;

		if(crearContacto){
	        c=Util_Tests.crearContacto('nombre','apellidos');
			c.LastName = 'Gonzalez';
			c.MobilePhone = '683928347';
			c.Phone = '683928347';
			c.HomePhone = '683928347';
			c.AccountId = cuenta.Id;
			c.Account = cuenta;
			insert c;
			if(numDocumentoNulo){
				Account a=c.Account;
				a.CUE_TXT_Numero_Documento__c=null;
				c.Account=a;
			}
		}

        tipoProducto=Util_Tests.crearTipoProductoCIA('nombre','01', compania.Id);
        insert tipoProducto;

        producto=Util_Tests.crearProductoCIA('nombre','1234',tipoProducto.Id);
        insert producto;

        sc=Util_Tests.crearPolizaContrato('nombre', compania.Id, cuenta.Id, producto.Id);
		sc.POL_TXT_Cliente_Ensura__c = 'ensura';
        insert sc;

        caso = Util_Tests.crearCasoB2B(sc.Id,cuentaSec.Id,cuenta.Id);
        if(asignarRecordTypeACasos)
        	caso.RecordTypeId=Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.MIR_Reclamacion).getRecordTypeId();

        caso.Status=Label.CAS_ESTADO_NUEVO;
        caso.CAS_CAS_Confirmado__c=true;

        if(casoPerteneceAUsuario){
			User u=new User();
			u.USR_TXT_Presence_Login__c = 'hola';
			u.FirstName = 'Manolo';
   			u.LastName = 'tena';
   			u.Email = 'manolo@gmail.com';
   			u.Username=u.Email;
   			u.Alias = 'manolo90';
   			u.CommunityNickname=u.Username;
   			u.TimeZoneSidKey= 'Pacific/Kiritimati';
   			u.LocaleSidKey= 'sq_AL';
   			u.EmailEncodingKey= 'UTF-8';
   			u.ProfileId=[SELECT Id FROM Profile LIMIT 1].Id;
   			u.LanguageLocaleKey= 'en_US';
			insert u;

			caso.OwnerId=u.Id;
        }
        insert caso;

        wt=Util_Tests.crearTipoTrabajo('Hola','12',10);
        insert wt;

        wo=Util_Tests.crearOrdenTrabajo('1','01',wt.Id,caso.Id);
        wo.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA);
        Baipas.establecerVariableControl();
        insert wo;
        Baipas.deshabilitarVariableControl();

	    if(contenidoLista.equals('caso'))
	    	trg=new TRG_Handler_MovimientoIR(new List<Case>{caso}, '');
	    else if(contenidoLista.equals('ordenTrabajo'))
	    	trg=new TRG_Handler_MovimientoIR(new List<WorkOrder>(), '');
	    else{
	    	Map<Id,Case> mapaCasos= new Map<Id,Case>();
	    	mapaCasos.put(caso.Id, caso);
	    	if(crearVariosContactosYCasos){

				Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal2','1246678','X1134597X');
				cuentaPrincipal.Type='01';
				insert cuentaPrincipal;

		    	Account cuenta2=Util_Tests.crearCuentaB2BSec('Name2','15552', cuentaPrincipal.Id, 'X5544663X');
		    	cuenta2.CUE_TXT_PrimerApellido__c='Perez';
		    	cuenta2.CUE_TXT_SegundoApellido__c='Ruiz';
		    	cuenta2.CUE_TXT_Nombre__c='Carlos';
		    	cuenta2.CUE_LKP_Cuenta_Principal__c = cuentaPrincipal.id;
		    	cuenta2.Type = '01';

		    	if(segmentacionVip)
		    		cuenta2.CUE_TXT_Segmentacion_num__c='06';
		    	else
		    		cuenta2.CUE_TXT_Segmentacion_num__c='04';

		    	cuenta2.ParentId=cuentaPrincipal.Id;
		    	//cuenta2.Parent=cuentaPrincipal;
				insert cuenta2;
				    	
		    	Contact c2=Util_Tests.crearContacto('nombre', 'apellidos');
		    	c2.Account=cuenta2;
		    	c2.AccountId=cuenta2.Id;
		    	insert c2;

	  			Procedencia__c procedencia = Util_tests.crearProcedencia(0,0, 0, 0,0, cuenta2.Id, '1255346', 'CAS_Siniestro');
		    	procedencia.Name='01';
		    	insert procedencia;

		    	ServiceContract sc2 = Util_Tests.crearPolizaContrato('nombre', compania.Id, cuentaPrincipal.Id, producto.Id);
		    	//sc2.POL_TXT_Cliente_Ensura__c = 'ensura';
        		insert sc2;

	  			Case caso2=Util_Tests.crearCasoB2B(sc2.Id, cuenta2.Id,cuentaPrincipal.Id);
		    	caso2.Status=Label.MIR_CodiReclamacion1;
		    	caso2.CreatedDate=Date.today().addDays(-2);
		    	caso2.ClosedDate=Date.today().addDays(-1);
		    	caso2.CAS_TXT_Num_Caso_HS__c= '888888888';
		    	insert caso2;

		    	caso2.CAS_SEL_Motivo_Indemnizable__c='03';
		    	caso2.CAS_LKP_Procedencia__c=procedencia.Id;
		    	//caso2.CAS_LKP_Procedencia__r=procedencia;
		    	caso2.CAS_CAS_Confirmado__c=null;

		  		if(asignarRecordTypeACasos)
			    	caso2.RecordTypeId=Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.MIR_Reclamacion).getRecordTypeId();
	  			
	  			caso2.Status=Label.MIR_CodiReclamacion2;
		    	mapaCasos.put(caso2.Id, caso2);
		    }
		    trg=new TRG_Handler_MovimientoIR(mapaCasos, '');
		}
	}	

	private static void actualizarTelefonoConDatos(){

		List<TRG_Handler_Contacto.actPhone> datos = new List<TRG_Handler_Contacto.actPhone>();
		TRG_Handler_Contacto.actPhone dato = new TRG_Handler_Contacto.actPhone();
		
		if(c!=null)
			dato.id=c.Id;
		else
			dato.id=null;

		datos.add(dato);
		TRG_Handler_MovimientoIR.actualizaTelefono(datos);
	}
    	
	
	@isTest
	public static void Testing(){
		
		//Aquí empezamos a hacer los test
		List<WorkOrder> ListWO = new List<WorkOrder>(
		[SELECT Id
			,OTR_TXT_Num_OrdenTrabajo_HS__c
			,CaseId
			,OTR_SEL_Gremio__c
			,OTR_DAT_Fecha_Primera_Cita__c
			,AccountId
			,OTR_SEL_Rango_Primera_Cita__c
			,OTR_CAS_Urgente__c
			,OTR_DIV_Importe_recibido_de_cliente__c
			,OTR_SEL_Modo_de_pago__c
			,Status 
		FROM WorkOrder]);
		
	
		test.startTest();
		TRG_Handler_MovimientoIR.actualizarOrdenTrabajo(ListWO);
		test.stopTest();		
	}
	
	
	@isTest //En este método insertaremos un Caso, para que salte TRG_Reclamacion_IR.trigger
	public static void triggerReclamacionIR(){
		Account cuentaB2BPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1018','X1999567X');
		insert cuentaB2BPrincipal;

		Account cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1019','X1134567X');
		insert cuentaCompania;

		Account cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1021','email@gmail.es','03629033R','nombre','apellido1','apellido2');
		cuentaAsegurado.CUE_LKP_Cuenta_Principal__c = cuentaCompania.id;
		insert cuentaAsegurado;

		Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.id);
		insert tipoProductoCIA;

		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;

		ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393',cuentaCompania.Id,cuentaAsegurado.Id, productoCIA.Id);
		poliza.POL_TXT_Cliente_Ensura__c = 'ensura';
		insert poliza;

		//Creamos un contacto
		Contact ct = new Contact();
		ct.LastName = 'Gonzalez';
		ct.MobilePhone = '683928347';
		ct.Phone = '683928347';
		ct.HomePhone = '683928347';
		ct.AccountId = cuentaAsegurado.Id;//cuenta.Id;
		insert ct;

		Case casoSini = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,cuentaB2BPrincipal.Id);
		casoSini.Contact = ct;
		casoSini.CAS_TXT_Identificador__c = '99998888';
		insert casoSini;
		
	}

	@isTest static void testActualizaTelefonoConContactos(){
		inicializarVariables(true, '',false, true, false, false, false);

		actualizarTelefonoConDatos();
	}

	@isTest static void testActualizaTelefonoSinContactos(){
		inicializarVariables(false, '',false, true, false, false, false);

		List<Contact> contactosABorrar=[SELECT ID FROM Contact];
		delete contactosABorrar;
		actualizarTelefonoConDatos();
	}

	@isTest static void testActualizarOrdenDeTrabajoConCaso(){
		inicializarVariables(true, '',false, true, false, false, false);
		List<WorkOrder> datos=new List<WorkOrder>();
		datos.add(wo);
		TRG_Handler_MovimientoIR.actualizarOrdenTrabajo(datos);
	}

	@isTest static void testInsertaCasoIRExisteTel(){
		inicializarVariables(true, 'caso',false, true, false, false, false);

		Movimiento_IR__c movimientoAActualizar=[SELECT MIR_TXT_NUM_SINIESTRO__c,MIR_TXT_TELEFONO__c FROM Movimiento_IR__c WHERE MIR_CAS_ENVIADO__c = False LIMIT 1];
		movimientoAActualizar.MIR_TXT_TELEFONO__c=c.MobilePhone;
		update movimientoAActualizar;

		trg.insertaCasoIR();

	}

	@isTest static void testInsertaCasoIRNoExisteTel(){
		inicializarVariables(true, 'caso',false, true, false, false, false);

		trg.insertaCasoIR();

	}
	
	@isTest static void testInsertaCasoIRConCuentaSinRecordType(){
		inicializarVariables(true, '',true,false, false, false, false);

		trg.insertaCasoIR();

	}

	@isTest static void testInsertaCasoIRConCuentaSinRecordTypeConUsuario(){
		inicializarVariables(true, '',true,false, true, false, false);

		trg.insertaCasoIR();

	}
	@isTest static void testInsertaCasoIRConCuentaConRecordTypeSinUsuario(){
		inicializarVariables(true, '',true,true, false, false, false);

		trg.insertaCasoIR();

	}
	@isTest static void testInsertaCasoIRConCuentaConRecordTypeConUsuarioNumDocumentoNoNulo(){
		inicializarVariables(true, '',true,true, true, false, false);

		trg.insertaCasoIR();


	}
	@isTest static void testInsertaCasoIRConCuentaConRecordTypeConUsuarioNumDocumentoNulo(){
		inicializarVariables(true, '',true,true, true, false, true);

		trg.insertaCasoIR();

	}

	@isTest static void testInsertaCasoIRFechaCierreServicioNoNulaNormal(){
		wo=new WorkOrder();
		wo.Status = Label.OTR_ESTADO_CERRADO;
		wo.LastModifiedDate=Date.today();

		trg=new TRG_Handler_MovimientoIR(new List<WorkOrder>{wo}, '');

		trg.insertaWOIR();

		inicializarVariables(true, '',true,true, true, false, true);

		//trg.fechaCierreServicio=Date.today();

		trg.insertaCasoIR();
	}
	@isTest static void testInsertaCasoIRFechaCierreServicioNoNulaVip(){
		wo=new WorkOrder();
		wo.Status = Label.OTR_ESTADO_CERRADO;
		wo.LastModifiedDate=Date.today();

		trg=new TRG_Handler_MovimientoIR(new List<WorkOrder>{wo}, '');

		trg.insertaWOIR();

		inicializarVariables(true, '',true,true, true, true, true);

		//trg.fechaCierreServicio=Date.today();

		trg.insertaCasoIR();
	}

	@isTest static void testSelectorMapaCasesLleno(){
		inicializarVariables(true, '',false,false,false,false,false);

		trg.selector();
	}

}