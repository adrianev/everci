@isTest
public without sharing class Test_Util_Identificadores {
    
    private static Case caso {get; set;}
    private static Procedencia__c procedencia {get; set;}
    private static WorkOrder wo {get; set;}
    
    
    @isTest static void testGenerarNumHS() {
        Test.startTest();
        inicializarVariables();
        String numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        //System.assertEquals(numeroHS, '9' + String.valueOf(procedencia.PROC_NUM_Contador_Rechazos__c));
        system.debug(numeroHS + ' NumeroHS');
        update caso;
        numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        Pattern MyPattern = Pattern.compile('B[0-9]+');
        system.debug(MyPattern + ' MyPattern');
        Matcher MyMatcher = MyPattern.matcher(numeroHS);
        system.debug(MyMatcher + ' MyMatcher');
        System.assertEquals(MyMatcher.matches(), false);
        caso.CAS_TXT_Num_Caso_HS__c = numeroHS;
        update caso;
        Util_Identificadores.generarNumIntervencionCIA(caso,procedencia);
        Test.stopTest();
    }
    
    @isTest static void testGenerarNumHS2() {
        Test.startTest();
        Baipas.establecerVariableControl();
        inicializarVariables();
        //caso.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
        procedencia.PROC_NUM_Contador__c = 1;
        caso.Type = '2';
        update procedencia;
        update caso;
        String numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        Test.stopTest();
    }
    @isTest static void testGenerarNumHS3() {
        Test.startTest();
        Baipas.establecerVariableControl();
        inicializarVariables();
        caso.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
        procedencia.PROC_NUM_Contador__c = 1;
        caso.Type = '2';
        update procedencia;
        update caso;
        String numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        Test.stopTest();
    }
    
    
    @isTest static void testGenerarNumHS4() {
        Test.startTest();
        Baipas.establecerVariableControl();
        inicializarVariables();
        caso.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
        procedencia.PROC_NUM_Contador__c = 1;
        caso.Type = '2';
        update procedencia;
        update caso;
        String numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        Test.stopTest();
    }
    
    @isTest static void testGenerarNumHS5() {
        Test.startTest();
        Baipas.establecerVariableControl();
        inicializarVariables();
        caso = null;
        wo.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA);
        procedencia.PROC_NUM_Contador__c = 1;
        update wo;
        update procedencia;
        String numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        Test.stopTest();
    }
    
    
    @isTest static void testgenerarIdExternoCaso() {
        Test.startTest();
        inicializarVariables();
        caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
        String numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        numeroHS = Util_Identificadores.generarNumeroHS(caso, wo, procedencia);
        caso.CAS_TXT_Num_Caso_HS__c = numeroHS;
        update caso;
        String idExterno = Util_Identificadores.generarIdExternoCaso(caso.RecordTypeId, '1018', caso.CAS_TXT_Num_Caso_HS__c);
        system.debug(idExterno + ' idExterno');
   		system.assertEquals(idExterno, '1018_'+caso.CAS_TXT_Num_Caso_HS__c);
        Id b2b = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
        idExterno = Util_Identificadores.generarIdExternoCaso(b2b, null, caso.CAS_TXT_Num_Caso_HS__c);
        system.assertEquals(idExterno, caso.CAS_TXT_Num_Caso_HS__c);
        Test.stopTest();
    }
        
    private static void inicializarVariables() {
        Baipas.establecerVariableControl();
        List<Account> listaCuentas = new List<Account>();
        //cuenta = Util_Tests.crearCuentaAsegurado('Asegurado','19783886E','aseguradoExample@gmail.es','12345678A','Paco','Fernadez','Lopez','12345678X');
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1234567X');
        insert cuentaPrincipal;
        Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1134567X');
        Account compania = Util_Tests.crearCuentaCompania(Label.IDE_ALMUDENA,'1018','X1114567X');
        listaCuentas.add(cuenta);
        listaCuentas.add(compania);
        insert listaCuentas;
        Tipo_Producto_CIA__c tipoProd = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
        insert tipoProd;
        Producto_CIA__c prod = Util_Tests.crearProductoCIA('KIT 107','12345678', tipoProd.Id);
        insert prod;
        Poblacion__c pobl =  Util_Tests.crearPoblacion('Madrid','28');
        insert pobl;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, prod.Id);
        insert poliza;
        procedencia = Util_Tests.crearProcedencia(0.0,0,0,0,0,cuentaPrincipal.Id,'101444',Label.PROCEDENCIA_SERVICIO_B2C);
        procedencia.PROC_SEL_Gremios_Disp__c = '02';
        insert procedencia;
        WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21',2.00);
        tipoTrabajo.TDT_SEL_Categoria__c = '02';
        insert tipoTrabajo;
        Id Recordtype =Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_SINIESTRO);
        caso = Util_Tests.crearCasoSini(poliza.Id,cuenta.Id,compania.Id);
        caso.CAS_SEL_Gremio_Principal__c = '21';
        caso.Type = Label.CAS_TIPO_RECHAZADO;
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.RecordTypeId = Recordtype;
        insert caso;
        Contact contacto = Util_Tests.crearContacto('Ruben','Gomez',cuenta.Id,'55558888');
        contacto.CON_CAS_Contacto_principal__c  = false;
        insert contacto;
        Contact contacto2 = Util_Tests.crearContacto('Sergio','Manzano',cuenta.Id,'55558878');
        contacto.CON_CAS_Contacto_principal__c  = true;
        insert contacto2;
        wo = Util_Tests.crearOrdenTrabajo('0WO9E0000003T9t', '21', tipoTrabajo.Id,caso.Id);
        insert wo;
    }
}