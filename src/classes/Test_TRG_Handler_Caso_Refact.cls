@isTest
public without sharing class Test_TRG_Handler_Caso_Refact{
    private static Account cuentaAsegurado {get; set;}
    private static Account cuentaAsegurado2 {get; set;}
    private static Account cuentaPrincipal {get; set;}
    private static Account cuentaSec {get; set;}
    private static Account cuentaSec2 {get; set;}
    private static Account cuentaCompania {get; set;}
    private static Account cuentaCompania2 {get; set;}
    private static Buzon_CIA__c buzon {get; set;}
    private static Case caso{get;set;}
    private static Case casoHijo{get;set;}
    private static Contact contacto1 {get; set;}
    private static Contact contacto2 {get; set;}
    private static Contact contactoCuentaPrincipal {get; set;}
    private static Contract contrato {get; set;}
    private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
    private static EmailMessage mensaje;
    private static Group g;
    private static Linea_Contrato__c lineaContrato {get; set;}
    private static List<Task> listaTareasACerrar;
    private static Map<Id, List<Task>> mapaTareasCaso;
    private static Procedencia__c procedencia {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
    private static Producto_CIA__c productoCIA2 {get; set;}
    private static ServiceContract poliza {get; set;}
    private static ServiceContract poliza2 {get; set;}
    private static ServiceContract polizaReclamacion {get; set;}
    private static ServiceContract polizaReclamacion2 {get; set;}
    private static Set<String> setEmail = new Set<String>();
    private static String userType {get; set;}
    private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
    private static Tipo_Producto_CIA__c tipoProductoCIA2 {get; set;}
    private static User u;
    private static WorkOrder ordenTrabajo {get; set;}
    private static WorkOrderLineItem partidaOT {get; set;}
    private static WorkType tipoTrabajo {get; set;}


    private static void inicializarVariables(){
        Baipas.establecerVariableControl();
        userType = Schema.SObjectType.User.getKeyPrefix();
        List<Tipo_Producto_CIA__c> listaTipoPCIA = new List<Tipo_Producto_CIA__c>();
        List<Producto_CIA__c> listaProductoCIA = new List<Producto_CIA__c>();
        List<ServiceContract> listaPolizas = new List<ServiceContract>();
        List<Contact> listaContactos = new List<Contact>();
        cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1019','X1134567X');
        insert cuentaCompania;
        cuentaCompania2 = Util_Tests.crearCuentaCompania('SegurCaixa3','1020','X1114567X');
        insert cuentaCompania2;
        cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('ReclamacionPrincipal','1030','X1234567X');
        cuentaPrincipal.Type='01';
        cuentaPrincipal.CUE_LKP_Cuenta_principal__c=cuentaCompania.Id;
        insert cuentaPrincipal;

        
        cuentaSec = Util_Tests.crearCuentaB2BSec('SegurCaixa2','1023',cuentaPrincipal.Id,'X1111567X');
        cuentaSec.CUE_LKP_Cliente_contable__c=cuentaPrincipal.Id;
        cuentaSec.Type='01';
        cuentaSec.CUE_LKP_Cuenta_principal__c=cuentaCompania.Id;
        insert cuentaSec;
        cuentaSec2 = Util_Tests.crearCuentaB2BSec('SegurCaixa4','1024',cuentaPrincipal.Id,'X1111167X');
        cuentaSec2.Type= '01';
		cuentaSec2.CUE_LKP_Cuenta_principal__c=cuentaCompania2.Id;
		insert cuentaSec2;
        cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1021','email@gmail.es','03629033R','nombre','apellido1','apellido2');
        cuentaAsegurado.CUE_SEL_Tipo_Documento__c = 'N';
        cuentaAsegurado.Type = 'Direccion';
        cuentaAsegurado.CUE_LKP_Cuenta_principal__c=cuentaCompania.Id;
        insert cuentaAsegurado;
        cuentaAsegurado2 = Util_Tests.crearCuentaAsegurado('Asegurado2','1022','email2@gmail.es','97759574Y','nombre2','apellido1','apellido2');
        cuentaAsegurado2.CUE_SEL_Tipo_Documento__c = 'N';
        cuentaAsegurado2.CUE_LKP_Cuenta_principal__c=cuentaCompania2.Id;
        insert cuentaAsegurado2;
        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.id);
        tipoProductoCIA2 = Util_Tests.crearTipoProductoCIA('SegurCaixa2 - HOGAR','01',cuentaCompania2.id);
        listaTipoPCIA.add(tipoProductoCIA);
        listaTipoPCIA.add(tipoProductoCIA2);
        insert listaTipoPCIA;
        productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        productoCIA2 = Util_Tests.crearProductoCIA('KIT 108','12345679',tipoProductoCIA2.Id);
        listaProductoCIA.add(productoCIA);
        listaProductoCIA.add(productoCIA2);
        insert listaProductoCIA;

        poliza = Util_Tests.crearPolizaContrato('2277393',cuentaCompania.Id,cuentaAsegurado.Id,productoCIA.Id);
        poliza2 = Util_Tests.crearPolizaContrato('2277394',cuentaCompania2.Id,cuentaAsegurado2.Id,productoCIA2.Id);
        polizaReclamacion = Util_Tests.crearPolizaContrato('2277384',cuentaPrincipal.Id,cuentaSec.Id,productoCIA.Id);
        polizaReclamacion2 = Util_Tests.crearPolizaContrato('2277385',cuentaCompania2.Id,cuentaSec2.Id,productoCIA2.Id);
        listaPolizas.add(poliza);
        listaPolizas.add(poliza2);
        listaPolizas.add(polizaReclamacion);
        listaPolizas.add(polizaReclamacion2);
        insert listaPolizas;
        procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuentaSec.Id,'101801','CAS_Siniestro');
        procedencia.Name = Label.IDE_PROCEDENCIA_HOMESERVE;
        insert procedencia;
        buzon = Util_Tests.crearBuzon('Buzon',cuentaPrincipal.Id,'correo@email.com');
        insert buzon;

        tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
        insert tipoTrabajo;
        contrato = Util_Tests.crearContrato(cuentaSec.Id,'Reclamacion_p_1');
        insert contrato;
        lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
        lineaContrato.LDC_LKP_Tipo_Trabajo__c = tipoTrabajo.Id;
        insert lineaContrato;
        direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuentaSec.Id,lineaContrato.Id,3);
        direccionBB_lineas.DLC_LKP_Linea_de_Contrato__c = lineaContrato.Id;
        insert direccionBB_lineas;
        contacto1 = Util_Tests.crearContacto('Manuel', 'Rosas Castillo', cuentaAsegurado.Id, '53568187A');
        contacto2 = Util_Tests.crearContacto('Manuelito', 'Castellano Manzano', cuentaSec.Id, '63568187A');
        contactoCuentaPrincipal = Util_Tests.crearContacto('Manuelita', 'Castellana Manzana', cuentaPrincipal.Id, '11223344B');
        listaContactos.add(contacto1);
        listaContactos.add(contacto2);
        listaContactos.add(contactoCuentaPrincipal);
        insert listaContactos;
        
        Baipas.deshabilitarVariableControl();
    }

    @isTest static void testInsertCasoSini(){
        Test.startTest();
        inicializarVariables();
        caso=iniciarDatosCaso('Sini');
        insert caso;
        Test.stopTest();
    }

    @isTest static void testInsertCasoReclamacion(){
        Test.startTest();
        inicializarVariables();
        caso=iniciarDatosCaso('Reclamacion');
        insert caso;
        Test.stopTest();
    }

    @isTest static void testInsertCasoReclamacionPendienteAnalisis(){
        inicializarVariables();
        caso=Util_Tests.crearCasoReclamacion(poliza.Id, cuentaSec.Id, cuentaPrincipal.Id);
        caso.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
        caso.Status=Label.CAS_ESTADO_PDTE_ANALISIS;
        insert caso;
    }

    @isTest static void testInsertCasoSolicitudConContacto(){
        inicializarVariables();
        caso=iniciarDatosCaso('Reclamacion');
        caso.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
        caso.ContactId=contacto2.Id;

        insert caso;
    }

    @isTest static void testInsertCasoConCuentaConContactoPrincipal(){
        operarCasoConCuentaConContacto(true, true);
    }

    @isTest static void testInsertCasoConCuentaSinContactoPrincipal(){
        operarCasoConCuentaConContacto(true, false);
    }

    @isTest static void testInsertCasoSolicitudSiniEnApertura(){
        inicializarVariables();
        caso=iniciarDatosCaso('Sini');
        caso.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_SINIESTRO);
        caso.Type = Label.CAS_TIPO_RECHAZO_EN_APERTURA;
        insert caso;
    }

    @isTest static void testInsertCasoSolicitudSiniRechazo(){
        inicializarVariables();
        caso=iniciarDatosCaso('Sini');
        caso.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_SINIESTRO);
        caso.Type = Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL;
        insert caso;
    }

    @isTest static void testInsertCasoConReclamacionAsociada(){
		inicializarVariables();
        caso=insertCaso('Contable',false);
        iniciarOrdenTrabajo();
        insert ordenTrabajo;

        caso=iniciarDatosCaso('Reclamacion');
        caso.CAS_LKP_Recl_Orden_Trabajo__c=ordenTrabajo.Id;

        insert caso;
    }



    /*@isTest static void testPrueba(){
        inicializarVariables();
        caso=insertCaso('Contable',false);
        iniciarOrdenTrabajo();
        insert ordenTrabajo;

        caso=iniciarDatosCaso('Reclamacion');
        caso.Status= '990';
        caso.CAS_LKP_Recl_Orden_Trabajo__c=ordenTrabajo.Id;
        caso.CAS_SEL_Estado_Expediente__c= '03';
        insert caso;
    }*/

    @isTest static void testUpdateCasoMixto(){
        iniciarCasoIndemnizable();
        
        caso.Type = Label.CAS_TIPO_MIXTO;
        caso.Status=Label.SINI_ESTADO_PDTE_DOC_INI;

        update caso;
    }

    @isTest static void testUpdateCasoSiniConCompaniaContable(){
        Test.startTest();
        inicializarVariables();
        caso=insertCaso('Sini',false);
        
        contacto1.Account=cuentaAsegurado;
        contacto1.AccountId=cuentaAsegurado.Id;
        contacto1.Account.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1);
        update contacto1.Account;
        
        iniciarOrdenTrabajo();
        insert ordenTrabajo;

        cuentaSec.Type=Label.CUE_TIPO_CONTABLE;
        cuentaSec.CUE_SEL_Tipo_Siniestro__c='1';
        update cuentaSec;

        caso.CAS_LKP_Recl_Orden_Trabajo__c = ordenTrabajo.Id;
        caso.Status = Label.CAS_ESTADO_PDTE_TRATAMIENTO;
        caso.CAS_TXT_Subestado_Codigo__c = 'XYZ';
        caso.CAS_LKP_PolizaContrato__c = poliza2.Id;
        caso.Type=cuentaSec.CUE_SEL_Tipo_Siniestro__c;
        update caso;
        Test.stopTest();
    }
    
    @isTest static void testUpdateCasoSiniMail(){
        test.startTest();
        inicializarVariables();
        
        LiveChatVisitor lcv=new LiveChatVisitor();
        insert lcv;
        
        
        LiveChatTranscript lct=new LiveChatTranscript();
        lct.LiveChatVisitorId=lcv.Id;
        insert lct;
        
        
        caso=insertCaso('Sini', false);
        caso.Type=Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_PARCIAL;
        caso.CAS_TXT_Subestado_Codigo__c=null;
        caso.Origin='Email';
        caso.SourceId=lct.Id;
        update caso;
        Test.stopTest();
    }
    
    @isTest static void testUpdateCasoReclamacion(){
        Test.startTest();
        inicializarVariables();
        caso=insertCaso('Reclamacion', false);
        
        iniciarOrdenTrabajo();

        Baipas.establecerVariableControl();
        insert ordenTrabajo;
        partidaOT = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert partidaOT;
        Baipas.deshabilitarVariableControl();
        casoHijo=Util_Tests.crearCasoReclamacion(poliza.Id, cuentaSec.Id, cuentaPrincipal.Id);
        casoHijo.CAS_LKP_Recl_Orden_Trabajo__c = ordenTrabajo.Id;
        casoHijo.ParentId=caso.Id;
        casoHijo.CAS_TXT_Num_Caso_HS__c='96';
        insert casoHijo;
        caso.AccountId = cuentaAsegurado.Id;
        caso.Status = Label.CAS_ESTADO_PDTE_ANALISIS;
        caso.CAS_DAT_Fecha_Activacion_Contador__c = null;
        caso.CAS_TXT_Subestado_Codigo__c = ordenTrabajo.OTR_SEL_Subestado__c;
        update caso;
        caso.CAS_DAT_Fecha_Activacion_Contador__c = Date.newInstance(2017, 12, 31);
        caso.Status = Label.CAS_ESTADO_PDTE_CIERRE;
        caso.CAS_SEL_Reclamacion__c = '001';
        update caso;
        Test.stopTest();
    }

    @isTest static void testUpdateCasoReclamacionCerradoConUnHijo(){
        updateCasosConHijos(true);
    }

    @isTest static void testUpdateCasoReclamacionCerradoConDosHijos(){
        updateCasosConHijos(false);
    }

    @isTest static void testUpdateCasoConCuentaConContactoPrincipal(){
        operarCasoConCuentaConContacto(false, false);
    }

    private static void updateCasosConHijos(Boolean tieneVariosHijos){
        inicializarVariables();
        caso=iniciarDatosCaso('Reclamacion');
        insert caso;
        iniciarOrdenTrabajo();

        ordenTrabajo.CaseId=caso.Id;
        insert ordenTrabajo;

        List<Case> casosAInsertar=new List<Case>();

        casoHijo=iniciarDatosCaso('Reclamacion');
        casoHijo.ParentId=caso.Id;
        casoHijo.CAS_TXT_Num_Caso_HS__c='04';
        casoHijo.Status=Label.CAS_ESTADO_CERRADO_FACTURADO;

        if(tieneVariosHijos){
            casoHijo.CAS_LKP_Recl_Orden_Trabajo__c=ordenTrabajo.Id;
            casoHijo.CAS_LKP_Recl_Orden_Trabajo__r=ordenTrabajo;

            Case casoB2B=Util_Tests.crearCasoB2B(null, cuentaSec.Id, cuentaPrincipal.Id);
            casoB2B.CAS_TXT_Num_Caso_HS__c='98';
            insert casoB2B;

            Case casoHijoAbierto=iniciarDatosCaso('Reclamacion');
            casoHijoAbierto.ParentId=casoB2B.Id;
            casoHijoAbierto.CAS_LKP_Recl_Orden_Trabajo__c=ordenTrabajo.Id;
            casoHijoAbierto.CAS_TXT_Num_Caso_HS__c='11';
            casoHijoAbierto.Status= '001';

            casosAInsertar.add(casoHijoAbierto);
        }

        casosAInsertar.add(casoHijo);
        
        Test.startTest();

        insert casosAInsertar;

        update casosAInsertar;
        Test.stopTest();
    }

    @isTest static void testUpdateCasoEsperaConfirmacionGestor(){
        inicializarVariables();
        caso=insertCaso('Sini',false);
        caso.Status=Label.CAS_ESTADO_ESPERA_GESTOR_CONFIRMACION;
        update caso;
    }

    @isTest static void testInsertYUpdateCasoEmail(){
        Test.startTest();
        inicializarVariables();
        caso=insertCaso('Reclamacion', false);

        iniciarMensaje();

        caso=insertCaso('Email',false);

        caso.CAS_LKP_Compania__c = null;
        caso.ContactId=contacto2.Id;

        update caso;

        Test.stopTest();
    }

    @isTest static void testInsertYUpdateCasoReclamacionConPadre(){
        inicializarVariables();
        caso=insertCaso('Sini',false);
        casoHijo=iniciarDatosCaso('Reclamacion');
        casoHijo.ParentId=caso.Id;
        insert casoHijo;
        update casoHijo;
    }

    @isTest static void testDeleteCasoSini(){
        Test.startTest();
        inicializarVariables();
        caso=iniciarDatosCaso('Sini');
        insert caso;
        delete caso;
        Test.stopTest();
    }

    @isTest static void testDeleteCasoReclamacion(){
        Test.startTest();
        inicializarVariables();
        caso=iniciarDatosCaso('Reclamacion');
        insert caso;
        delete caso;
        Test.stopTest();
    }

    @isTest static void testCambiarEstadosCaso(){
        inicializarVariables();
        caso=insertCaso('Reclamacion', false);
        caso.Status=Label.CAS_ESTADO_PDTE_TRATAMIENTO;
        update caso;
        caso.Status=Label.CAS_ESTADO_PDTE_CIERRE;
        caso.CAS_SEL_Reclamacion__c=Label.CAS_RECLAMACION_FUNDADA;
        update caso;
        caso.Status=Label.CAS_ESTADO_PDTE_ANALISIS;
        update caso;
    }

    @isTest static void testCambiarRecordTypeYDirRiesgoCaso(){
        inicializarVariables();
        caso=insertCaso('Reclamacion',false);
        caso.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c= '03';
        update caso;
    }

    @isTest static void testCasoContable(){
        Test.startTest();
        inicializarVariables();
        caso=iniciarDatosCaso('Contable');
        insert caso;
        delete caso;
        Test.stopTest();
    }
    
    @isTest static void testCrearAbonoClientesNulos(){ 
        accederACrearAbono(true,true);
    }

    @isTest static void testCrearAbonoClienteContableNulo(){ 
        accederACrearAbono(true,false);
    }

    @isTest static void testCrearAbonoClienteContableClienteNulo(){ 
        accederACrearAbono(false,true);
    }

    @isTest static void testEnviarMailClickHogar(){
        inicializarVariables();
        caso=iniciarDatosCaso('Reclamacion');
        Account cuentaCompaniaSegurCaixa=Util_Tests.crearCuentaCompania('La verdadera caixa',Label.IDE_SEGURCAIXA,'X4827596X');
        insert cuentaCompaniaSegurCaixa;
        caso.CAS_TXT_Usuario_Clic_Hogar__c='Hello';
        caso.CAS_LKP_Procedencia__c=procedencia.id;
        caso.CAS_TXT_Num_Caso_HS__c='21';
        caso.CAS_EMA_Email__c='hola@hola.com';
        insert caso;
    }

    @isTest static void testUpdateTaskOwnerCasoEnBd(){
        inicializarVariables();
        caso=insertCaso('Reclamacion', true);
        update caso;
    }

    @isTest static void testErrorUpdateCasoReclamacionNoFundadaConPartidasAceptadas(){
        inicializarVariables();

        caso=insertCaso('Reclamacion', false);
        
        ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
        insert ordenTrabajo;

        WorkOrderLineItem woli=Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert woli;
        woli.Status= Label.PAR_ESTADO_ACEPTADA;
        update woli;

        caso.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
        caso.Status=Label.CAS_ESTADO_PDTE_CIERRE;
        caso.CAS_SEL_Reclamacion__c=Label.CAS_RECLAMACION_NO_FUNDADA;

        Test.startTest();
        try{
            update caso;
        }catch(DmlException e){}
        Test.stopTest();
        
    }

    @isTest static void testErrorAsociarWoAbiertoACaso(){
        inicializarVariables();
        caso=insertCaso('Reclamacion', false);
        
        iniciarOrdenTrabajo();
        ordenTrabajo.CaseId=caso.Id; 
        insert ordenTrabajo;

        try{
            update caso;
        }catch(DmlException e){}
    }
    
    private static Case iniciarDatosCaso(String tipoCaso){
        Case caso;
        if(tipoCaso.equals('Reclamacion')){
            caso = Util_Tests.crearCasoReclamacion(polizaReclamacion.Id,cuentaSec.Id,cuentaPrincipal.Id);
            caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
            finalizarDatosCaso(caso);
        }
        else if(tipoCaso.equals('Sini')){
            caso = Util_Tests.crearCasoSini(polizaReclamacion.Id,cuentaSec.Id,cuentaPrincipal.Id);
            caso.ContactId = contacto2.Id;
            caso.Type = Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_PARCIAL;
            finalizarDatosCaso(caso);
        }
        else if(tipoCaso.equals('Contable')){
            caso = Util_Tests.crearCasoConClienteContable(polizaReclamacion.Id,cuentaSec.Id,cuentaPrincipal.Id,cuentaPrincipal.Id);
            finalizarDatosCaso(caso);
        }
        else{

            u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_ADMINISTRADOR].Id,
                LastName = 'last',
                Email = 'email@email.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );

            insert u;            

            System.runAs(u){

                g=[SELECT Id, Email FROM Group WHERE Email != null LIMIT 1];

                Buzon_CIA__c b=new Buzon_CIA__c();
                b.BUZ_EMA_Direccion__c=g.Email;
                b.BUZ_LKP_Cuenta__c=cuentaPrincipal.Id;
                insert b;

                caso=Util_Tests.crearCasoReclamacion(polizaReclamacion.Id, cuentaSec.Id, null);
                caso.Origin = 'Email';
                caso.SourceId = mensaje.Id;
                caso.CAS_CAS_Supera_Limite_Actuacion__c = false;
                caso.ContactId = contactoCuentaPrincipal.Id;
                Caso.CAS_TXT_Num_Caso_HS__c='48';
                caso.OwnerId=g.Id;

                finalizarDatosCaso(caso);
            }
        }

        return caso;
    }
    
    private static Case insertCaso(String tipoCaso, boolean ownedByUser){
        Case caso=iniciarDatosCaso(tipoCaso);

        if(ownedByUser)
            caso.OwnerId = UserInfo.getUserId();
        caso.CAS_LKP_Cliente_contable_cliente__c=cuentaAsegurado.Id;
        caso.CAS_LKP_Compania__c = cuentaCompania.Id;
        insert caso;
        caso.Status=Label.CAS_ESTADO_CERRADO_FACTURADO;

        return caso;
    }

    private static void iniciarOrdenTrabajo(){
        ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
        ordenTrabajo.AccountId = cuentaSec.Id;
    }

    private static void iniciarMensaje(){
        mensaje=new EmailMessage();
        mensaje.ParentId=caso.Id;
        mensaje.ToAddress=buzon.BUZ_EMA_Direccion__c;
        insert mensaje;
    }

    private static void finalizarDatosCaso(Case caso){
        caso.Status = Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR;
        caso.CAS_LKP_Linea_de_Contrato__c = lineaContrato.Id;
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CAS_TXT_Subestado_Codigo__c = 'ABC';
    }

    private static void accederACrearAbono(boolean clienteContableNulo, boolean clienteContableClienteNulo){
        Test.startTest();
        inicializarVariables();
        
        //insert cuentaCompania;
        Case caso = Util_Tests.crearCasoReclamacion(polizaReclamacion.Id,cuentaSec.Id,cuentaCompania2.Id);
        caso.CAS_LKP_Cliente_contable_cliente__c = cuentaAsegurado2.Id;
        //insert cuentaAsegurado;
        insert caso;

        update caso;
        
        WorkOrder ordenTrabajo=new WorkOrder();
        ordenTrabajo.CaseId=caso.Id;
        ordenTrabajo.Status=Label.OTR_ESTADO_REVISADO;
        
        insert ordenTrabajo;
        
        if(clienteContableNulo)
            caso.CAS_LKP_Cliente_contable__c=null;
        
        if(clienteContableClienteNulo)
            caso.CAS_LKP_Cliente_contable_cliente__c=null;

        update caso;

        Test.stopTest();
    }

    private static void operarCasoConCuentaConContacto(boolean llevaCuentaEnInsert, boolean llevaContactoEnInsert){
        inicializarVariables();

        contacto1.AccountId=cuentaSec.Id;
        update contacto1;

        cuentaSec.CUE_LKP_contacto_principal__c = contacto1.Id;

        update cuentaSec;

        caso=Util_Tests.crearCasoReclamacion(poliza.Id, cuentaSec.Id, cuentaPrincipal.Id);
        //insert caso;

        caso.RecordTypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
        
        if(!llevaCuentaEnInsert)
            caso.AccountId=null;
        
        if(llevaContactoEnInsert)
            caso.ContactId=contacto1.Id;

        insert caso;

        if(!llevaCuentaEnInsert || !llevaContactoEnInsert){
            caso.AccountId=cuentaSec.Id;
            caso.ContactId=contacto1.Id;
            update caso;
        }
    }

    private static void iniciarCasoIndemnizable(){
        inicializarVariables();
        caso=iniciarDatosCaso('Reclamacion');
        caso.Type = Label.CAS_TIPO_INDEMNIZABLE;
        caso.CAS_SEL_Sondeo_DocsIndemnizable__c='02';
        
        Util_variablesGlobales.faseVueltaSondeo='No confirmado';

        insert caso;
    }
}