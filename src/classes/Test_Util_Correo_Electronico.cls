/*
* Clase de test para la clase de Util_Correo_Electronico
*/

@isTest public without sharing class Test_Util_Correo_Electronico {
    
    private static Account cuentaPrincipal {get; set;}
    private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
    private static Contact contacto1 {get; set;}
    private static Contact contacto2 {get; set;}
    private static OrgWideEmailAddress owea {get; set;}
    
    private static Buzon_CIA__c buzon {get; set;}
    
    @isTest static void inicializarVariables(){
		Baipas.establecerVariableControl();
        cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X86547823');
		insert cuentaPrincipal;
        compania = Util_Tests.crearCuentaCompania('SegurCaixa','507508','X5634567X');
        compania.CUE_TXT_Identificador__c = '507508';
		insert compania;
        Account cuentaSecundaria = Util_Tests.crearCuentaB2BSec('Alberto2','1080', compania.Id);
        cuentaSecundaria.CUE_TXT_Numero_Documento__c = '89074907R';
        cuentaSecundaria.CUE_SEL_Tipo_Documento__c = 'N';
        insert cuentaSecundaria;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaSecundaria.Id, compania.Id, productoCIA.Id);
        insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		insert caso;
        contacto1 = Util_Tests.crearContacto('Marta', 'Rubio', cuentaPrincipal.id, '354576');
        contacto1.AccountId = cuentaPrincipal.Id;
        contacto1.Email = 'prueba1@prueba.com';
        insert contacto1;
        contacto2 = Util_Tests.crearContacto('Irene', 'Martinez', cuentaPrincipal.id, '354579');
        contacto2.AccountId = cuentaPrincipal.Id;
        contacto2.Email = 'prueba2@prueba.com';
        insert contacto2;
        
        buzon = Util_Tests.crearBuzon('BuzonCE',cuentaPrincipal.Id,'buzonce@prueba.es');
        buzon.BUZ_SEL_Tipo_Programa__c = Label.CON_TIPO_PROGRAMA_ALBARAN;
        insert buzon;
	}
    
    /*Test*/
	@isTest static void TestEnvioMasivo(){
		
        inicializarVariables();
        test.startTest();
        
        List<Contact> listaContactos = new List<Contact>();
        listaContactos.add(contacto1);
        listaContactos.add(contacto2);
        Util_Correo_Electronico.envioMasivoTemplate(caso.Id, null, Label.CON_TIPO_PROGRAMA_COMPROBANTE_SERVICIO, null, listaContactos, null, null, null, null);
        Util_Correo_Electronico.envioMasivoTemplate(null, null, Label.CON_TIPO_PROGRAMA_COMPROBANTE_SERVICIO, null, listaContactos, null, null, null, null);
        Util_Correo_Electronico.envioMasivoTemplate(caso.Id, null, Label.CON_TIPO_PROGRAMA_COMPROBANTE_SERVICIO, null, listaContactos, Label.CUE_EMA_Test_Util_Correo_Electronico, null, null, null);
        
		test.stopTest();
	}
    
    /*Test*/
	@isTest static void TestEnvioSimple(){
		
        inicializarVariables();
        test.startTest();
        
        Contact con = Util_Correo_Electronico.generarDummyContact('Marta', 'Rubio Martin', 'irenerm@prueba.es', '678901232', null);
		String casoSerializado = JSON.serialize(caso);
		Util_Correo_Electronico.enviarSingleEmailMessage(casoSerializado, Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO, Label.IDIOMA_POR_DEFECTO, con, null, null, null, null);
        Contact con1 = Util_Correo_Electronico.generarDummyContact('Sara', 'Rubio Martin', 'sararm@prueba.es', '676901232', null);
        //Util_Correo_Electronico.enviarSingleEmailMessage(casoSerializado, Label.CON_TIPO_PROGRAMA_COMPROBANTE_SERVICIO, Label.IDIOMA_POR_DEFECTO, con1, Label.CUE_EMA_Test_Util_Correo_Electronico, null, null, null);
        
		test.stopTest();
	}
	
    /*Test*/
	@isTest static void TestEnvioSimpleSinPlantilla(){
		
        inicializarVariables();
        test.startTest();
        
        Contact contactoDestinatario = Util_Correo_Electronico.generarDummyContact('Marta', 'Rubio Martin', 'irenerm@prueba.es',null, null);
        String body = '<p>Buenos días: <br/><br/> El presente correo, lleva adjunto el Albarán que se ha rechazado y que tiene que revisar, y volver a enviar.<br/><br/>Un saludo</p>';
		Util_Correo_Electronico.enviarSingleEmailSinPlantilla(null, 'Aviso modificación albarán', body, 'HTML',contactoDestinatario.Id, null, null, null, null);
        Contact contactoDestinatario1 = Util_Correo_Electronico.generarDummyContact('Lucía', 'Rubio Martin', 'luciarm@prueba.es',null, null);
        Util_Correo_Electronico.enviarSingleEmailSinPlantilla(null, 'Aviso modificación albarán', body, 'HTML',contactoDestinatario1.Id, null, null, Label.CUE_EMA_Test_Util_Correo_Electronico, null);
		test.stopTest();
	}
    
    /*Test*/
	@isTest static void TestGetListaContactos(){
		
        inicializarVariables();
        test.startTest();
        
        List<Contact> ContactosCIA = Util_Correo_Electronico.getListaContactos(cuentaPrincipal.Id, null, Label.CON_TIPO_PROGRAMA_ALBARAN);
        List<Contact> ContactosCIA1 = Util_Correo_Electronico.getListaContactos(cuentaPrincipal.Id, null, null);
        List<Contact> ContactosCIA2 = Util_Correo_Electronico.getListaContactos(null, Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_ALBARAN);
        List<Contact> ContactosCIA3 = Util_Correo_Electronico.getListaContactos(null, Label.IDE_HOMESERVE, null);
        
		test.stopTest();
	}
    
    /*Test*/
	@isTest static void TestGetBuzonCIA(){
		
        inicializarVariables();
        test.startTest();
        
        String BuzonCIA = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_ALBARAN);
        
		test.stopTest();
	}
    
    /*Test*/
	@isTest static void TestSingleSinPasarTemplate(){
		
        inicializarVariables();
        test.startTest();
        
        Contact con = Util_Correo_Electronico.generarDummyContact('Teresa', 'Martin García', 'teresamg@prueba.es', null, null);
		String casoSerializado = JSON.serialize(caso);
        
		Util_Correo_Electronico.enviarSingleEmailMessage(casoSerializado, '02', '2', con, null, null, null, 'CLIENTE');
        
		test.stopTest();
	}
    
}