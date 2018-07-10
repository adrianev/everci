@isTest
public without sharing class Test_Util_Abonos_Eventos {

    private static Profile perfil;
    private static User usuario;
    private static User usuario2;
    private static Account compania;
    private static Account cuentaPrincipal;
    private static Account cuentaProfesionalPrincipal;
    private static Account cuentaProfesional;
    private static ServiceResource recursoServ;
    private static ServiceResource recursoServ2;
    private static Account cuentaSec;
    private static Account cuentaAsegurado;
    private static Tipo_Producto_CIA__c tipoProductoCIA;
    private static Producto_CIA__c productoCia;
    private static ServiceContract poliza;
    private static Case casoB2B;
    private static Case casoSini;
    private static WorkType tipoTrabajo;
    private static WorkOrder ordenTrabajo;
    private static Propuesta_de_Abono__c propAbono;

    private static void inicializarVariables(){
        List<Account> listaCuentas = new List<Account>();
        
        perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_GESTOR_FRONT_TRAMITACION];

        usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;

        compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
        cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
        cuentaProfesionalPrincipal = Util_Tests.crearCuentaB2C('PR123456','PR123456','X1234568X');

        listaCuentas.add(compania);
        listaCuentas.add(cuentaPrincipal);
        listaCuentas.add(cuentaProfesionalPrincipal);
        insert listaCuentas;

        cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR636325','PR636325','X1234567X',cuentaProfesionalPrincipal.id);
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01'; //AUTONOMO
        listaCuentas.add(cuentaProfesional);
        upsert listaCuentas;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        upsert listaCuentas;

        recursoServ = Util_Tests.crearRecursoServicio('PR636325_01_1', '00000', cuentaProfesional.Id, usuario);
        recursoServ.RSE_LKP_Cuenta__r = cuentaProfesional;
        insert recursoServ;

        recursoServ2 = Util_Tests.crearRecursoServicio('PR636325_01_2', '00001', cuentaProfesional.Id, usuario2);
        recursoServ2.isActive = true;
        insert recursoServ2;

        cuentaSec=Util_Tests.crearCuentaB2BSec('Name','13132', cuentaPrincipal.Id, 'X5544663X');
        listaCuentas.add(cuentaSec);

        cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1021','email@gmail.es','03629033R','nombre','apellido1','apellido2');
        cuentaAsegurado.CUE_LKP_CUENTA_Principal__c = cuentaPrincipal.id;
        listaCuentas.add(cuentaAsegurado);
        upsert listaCuentas;

        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
        insert tipoProductoCIA;

        productoCia=Util_Tests.crearProductoCIA('nombre','01', tipoProductoCIA.Id);
        insert productoCia;

        poliza=Util_Tests.crearPolizaContrato('4523814',compania.Id, cuentaPrincipal.Id, productoCia.Id);
        insert poliza;

        createCaseSini();

        tipoTrabajo = Util_Tests.crearTipoTrabajo('Siniestro', '21', 2.5);
        insert tipoTrabajo;

        ordenTrabajo = Util_Tests.crearOrdenTrabajo('26032018', '75', tipoTrabajo.id, casoSini.Id);
        ordenTrabajo.OTR_LKP_Recurso_Servicio__c = recursoServ.id;
        Test.startTest();
        insert ordenTrabajo;

    }

    private static void createCaseSini(){
        poliza.AccountId = cuentaAsegurado.id;
        update poliza;

        casoSini = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,cuentaPrincipal.Id);
        casoSini.CAS_DIV_Total_Facturar_Cliente_AI__c = 101.00;
        casoSini.CAS_DIV_Total_Facturar_Profesional__c = 101.00;
        insert casoSini;
        
    }

    @isTest static void test(){
        inicializarVariables();
        propAbono = new Propuesta_de_Abono__c();
        propAbono.AB_SEL_Estado__c = '04';
        propAbono.AB_LKP_CASO__c = casoSini.id;
        propAbono.AB_LKP_Imputar_a__c = usuario.id;
        propAbono.AB_LKP_Ingresar_a__c  = casoSini.AccountId;
        propAbono.AB_DIV_Importe_a_Imputar__c = 50;
        propAbono.AB_SEL_Descripcion_evento__c = 'E11';
        propAbono.AB_DIV_Importe_a_ingresar__c = 50;
        propAbono.AB_LKP_Imputar_a4__c = ordenTrabajo.OTR_LKP_Recurso_Servicio__c;
        propAbono.AB_DIV_Importe_a_Imputar4__c = 1;
        insert propAbono;

        Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
        evento.EV_AB_SEL_Estado__c = '04';
        insert evento;

        Util_Abonos_Y_Eventos.cambiarEstadoAbono(propAbono.Id);
        Util_Abonos_Y_Eventos.cambiarEstadoEvento(evento.Id);
    }
}