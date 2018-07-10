@isTest
public without sharing class Test_Rest_Fac_infoFacturas extends TestSetup {
    
    /**
     * Este metodo se encarga de realizar la carga de datos de static resources
     * 
     */
    /*@testSetup
    public static void test(){
        TestSetup loadData = new Test_Rest_Fac_infoFacturas();
        loadData.setTestData();
        system.debug('>>>>>loadData: '+loadData);
    }*/
    
    @isTest
    public static void Testing(){
        Baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',compania.Id,'X1114567X');
		insert cuenta;
		Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		Case caso = Util_Tests.crearCasoSini(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		Case reclaAbono = Util_Tests.crearCasoReclamacion(poliza.Id, cuenta.Id, compania.Id);
		//Case caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert reclaAbono;
		
        
        //Creamos las cuentas que necesitamos
        Account cuenta1 = Util_Tests.crearCuentaProfesionalContrato('CuentaProf','29384-1','X1114567X',null);
  		cuenta1.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuenta1.Name = 'PR123456';
        cuenta1.CUE_LKP_contacto_principal__c = Null;
        cuenta1.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        cuenta1.CUE_TXT_Identificador__c = 'PR123456';
        insert cuenta1;
        cuenta1.CUE_SEL_Estado__c = '02';
        update cuenta1;
        system.debug('>>>>>cuenta1.Id: ' + cuenta1.Id);
        system.debug('>>>>>cuenta1.CUE_TXT_Identificador__c: ' + cuenta1.CUE_TXT_Identificador__c);
        RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_PROFESIONAL];
        
        User newUser = new User();
		newUser.FirstName = 'Manolo2';
		newUser.LastName = 'tena2';
		newUser.Email = 'manol2o@manolo.com';
		newUser.Alias = 'Manolo2';
		newUser.ProfileId = perfil.Id;
		newUser.Username = ' john784poi2@acme7.com';
		newUser.CommunityNickname = 'pepe2';
		newUser.TimeZoneSidKey = 'Europe/Paris';
		newUser.LocaleSidKey = system.UserInfo.getLocale();
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.LanguageLocaleKey = 'es';

		insert newUser;
        
        ServiceResource sr = Util_Tests.crearRecursoServicio('PR123456_01_1', '22062018', cuenta1.Id, newUser);
        system.debug('>>>>>VerRSE_LKP_Cuenta__c: ' + sr.RSE_LKP_Cuenta__c);
        system.debug('>>>>>VERsr: ' + sr);
        sr.RSE_SEL_Gremio__c='01';
        insert sr;
        
        Account cuenta2=Util_Tests.crearCuentaAsegurado('RP123456', 'RP123456', 'email', '12345678Z', 'PR123456', 'primerApellido', 'segundoApellido');   
        cuenta2.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuenta2.CUE_EMA_Email__c='test@email.com';
        cuenta2.CUE_TXT_Identificador__c='RP123456';
        cuenta2.RecordTypeId = rt.Id;
        cuenta2.CUE_SEL_Direccion_Territorial__c = 'A7';
        cuenta2.CUE_LKP_Cuenta_principal__c = Null;
        cuenta2.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        cuenta2.Name = 'PR123456';
        insert cuenta2;
        cuenta2.CUE_SEL_Estado__c = '02';
        update cuenta2;

        //Creamos los casos que necesitamos
        Case case1 = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        case1.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
        insert case1;
        system.debug('>>>>>case1: ' + case1);

        Case case2 = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        case2.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
        insert case2;
        system.debug('>>>>>case2: ' + case2);

        //Creamos las WO que necesitamos
        WorkOrder WO1 = new WorkOrder();
        WO1.OTR_TXT_Num_OrdenTrabajo_HS__c = '06032018-1';
        WO1.CaseId = case1.Id;
        insert WO1;
        
        WorkOrder WO2 = new WorkOrder();
        WO2.OTR_TXT_Num_OrdenTrabajo_HS__c = '06032018-2';
        WO2.CaseId = case2.Id;
        insert WO2;
        
        //Creamos propuesta de evento y propuesta de abono
        /*Propuesta_de_Evento__c propEvento = new Propuesta_de_Evento__c();
        upsert propEvento;*/
        Propuesta_de_Evento__c propEventoCobro = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = case1.Id);
		propEventoCobro.EV_AB_TXT_Identificador__c = '13042018';
		propEventoCobro.EV_AB_SEL_Descripcion__c = 'E21';
		propEventoCobro.EV_AB_SEL_Estado__c = '02';
		propEventoCobro.EV_AB_CAS_Evento_Ab_Facturado__c = false;
		propEventoCobro.EV_AB_LKP_Orden_de_Trabajo__c = WO1.Id;
		propEventoCobro.EV_AB_SEL_Tipo_de_Evento__c = Label.TIPO_EVENTO_COBRO;
		//Al ser un cobro; rellenamos los campos correspondientes a imputación;
		propEventoCobro.EV_AB_LKP_Imputar_a_profesional__c = sr.Id;
		propEventoCobro.EV_AB_DIV_Importe_profesional__c = 1;
		system.debug('>>>>>VERpropEventoCobro: ' + propEventoCobro);
		insert propEventoCobro;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		Propuesta_de_Evento__c propEventoPago = new Propuesta_de_Evento__c(EV_AB_SEL_Estado__c = '04', EV_AB_LKP_Caso__c = case1.Id);
		propEventoPago.EV_AB_TXT_Identificador__c = '22062018';
		propEventoPago.EV_AB_SEL_Descripcion__c = 'E12';
		propEventoPago.EV_AB_SEL_Estado__c = '02';
		propEventoPago.EV_AB_CAS_Evento_Ab_Facturado__c = false;
		propEventoPago.EV_AB_LKP_Orden_de_Trabajo__c = WO1.Id;
		propEventoPago.EV_AB_SEL_Tipo_de_Evento__c = Label.TIPO_EVENTO_PAGO;
		//Al ser un cobro; rellenamos los campos correspondientes a imputación;
		propEventoPago.EV_AB_LKP_Liquidar_a_prof__c = sr.Id;
		propEventoPago.EV_AB_DIV_Importe_a_liquidar_prof__c = 0.22;
		system.debug('>>>>>VERpropEventoPago: ' + propEventoPago);
		insert propEventoPago;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


		WorkOrder WO3 = new WorkOrder();
        WO2.OTR_TXT_Num_OrdenTrabajo_HS__c = '06032018-3';
        WO2.CaseId = case1.Id;
        insert WO3;
		WO3 = Rest_Fac_infoFacturas.liquidarServicioEvento(propEventoCobro);
		WO3 = Rest_Fac_infoFacturas.facturarServicioEvento(propEventoCobro);

        WorkOrder WOAbono = new WorkOrder();
        WOAbono.OTR_TXT_Num_OrdenTrabajo_HS__c = '06032018-3';
        WOAbono.CaseId = reclaAbono.Id;
        insert WOAbono;

        Propuesta_de_Abono__c propAbono = new Propuesta_de_Abono__c();
        propAbono.AB_SEL_Descripcion_evento__c = 'E02';
        propAbono.AB_LKP_Imputar_a__c = system.UserInfo.getUserId();
        propAbono.AB_DIV_Importe_a_Imputar__c = 50.0;
        propAbono.AB_DIV_Importe_a_ingresar__c = 0;
        propAbono.AB_LKP_Caso__c = reclaAbono.Id;
        propAbono.AB_LKP_Ingresar_a__c = compania.Id;
        propAbono.AB_LKP_Orden_de_Trabajo__c = WOAbono.Id;
        insert propAbono;
        
        //Asignamos valor y rellenamos las listas
        String caso1S = case1.Id;
        String caso2S = case2.Id;
        String WO1S = WO1.Id;
        String WO2S = WO2.Id;
        
        Rest_Fac_infoFacturas.listaCasos caso1 = new Rest_Fac_infoFacturas.listaCasos(caso1S);
        Rest_Fac_infoFacturas.listaCasos caso2 = new Rest_Fac_infoFacturas.listaCasos(caso2S);
        Rest_Fac_infoFacturas.listaWO WO11 = new Rest_Fac_infoFacturas.listaWO(WO1S);
        Rest_Fac_infoFacturas.listaWO WO12 = new Rest_Fac_infoFacturas.listaWO(WO2S);
        
        List<Rest_Fac_infoFacturas.listaCasos> listCases = new List<Rest_Fac_infoFacturas.listaCasos>();
        listCases.add(caso1);
        listCases.add(caso2);
        
        List<Rest_Fac_infoFacturas.listaWO> listOrdenesTrabajo = new List<Rest_Fac_infoFacturas.listaWO>();
        listOrdenesTrabajo.add(WO11);
        listOrdenesTrabajo.add(WO12);
        
        String identificadorUnicoCuentaProf = cuenta1.Id;//caso2S;
        String identificadorUnicoCuentaClie = cuenta2.Id; //caso2S;
        
        String IdentificadorUnicoEvento='' + propEventoCobro.Id;
        String IdentificadorUnicoAbono='' + propAbono.Id;
        
        Integer anioFactura=2017;
        Double importePago=100.43;
        Integer mesPago=02;
        Double retencionPago=1000.55;
        String numeroFactura='12121';
        Date fechaFactura=system.today();
        String codigoCapital='XXXXXXXXX';
        Double importeFranquicia=52.65;
        Double importeFinal=100.40;
        Double importeIva=10.43;
        Integer porcentajeIva=5;
        Boolean indicadorFranquicia=true;
        String tipoRegistro='oiuyt';
        Integer indicadorQuincena=2;
        Double totalImporte=90.43;
        Boolean facturaGestion = true;

        Test.startTest();

        system.debug('>>>>>identificadorUnicoEvento: ' + identificadorUnicoEvento);
        system.debug('>>>>>identificadorUnicoAbono: ' + identificadorUnicoAbono);

        Rest_Fac_infoFacturas.doPost(
                listCases,
                listOrdenesTrabajo,
                identificadorUnicoCuentaProf,
                identificadorUnicoCuentaClie,
                identificadorUnicoEvento,
                identificadorUnicoAbono,
                anioFactura,
                importePago,
                mesPago,
                retencionPago,
                numeroFactura,
                fechaFactura,
                codigoCapital,
                importeFranquicia,
                importeFinal, 
                importeIva,
                porcentajeIva,
                indicadorFranquicia,
                tipoRegistro,
                indicadorQuincena, 
                totalImporte,
            	facturaGestion	
                );


		IdentificadorUnicoEvento='' + propEventoPago.Id;

        facturaGestion = false;
        Rest_Fac_infoFacturas.doPost(
                listCases,
                listOrdenesTrabajo,
                identificadorUnicoCuentaProf,
                identificadorUnicoCuentaClie,
                identificadorUnicoEvento,
                identificadorUnicoAbono,
                anioFactura,
                importePago,
                mesPago,
                retencionPago,
                numeroFactura,
                fechaFactura,
                codigoCapital,
                importeFranquicia,
                importeFinal, 
                importeIva,
                porcentajeIva,
                indicadorFranquicia,
                tipoRegistro,
                indicadorQuincena, 
                totalImporte,
            	facturaGestion	
                );
                
                
        Test.stopTest();
             
    }

}