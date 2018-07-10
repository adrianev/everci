@isTest 
public class Util_Orden_Trabajo_Test {
    private static Account cuenta;
    private static Account cuentaProfesional;
    private static Account compania;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static WorkType wt;
    private static WorkOrder wo;
    private static Set<Id> setIdOT = new Set<Id>();
    private static Set<Id> setIdCaso = new Set<Id>();
    private static ContentVersion cv;
    private static Skill sk;
    private static SkillRequirement skr;
    private static ServiceResource profesional;
    private static Propuesta_de_Evento__c pv;
    private static Propuesta_de_Abono__c pa;
    private static RecordType rt;
    private static User usuario;

    static void inicializarVariables(){
        
        
        Account compania = Util_Tests.crearCuentaCompania('CuentaCompañia', '1019', 'X1264567X');
        compania.Type = '01';
        insert compania; 
        
        
        cuenta = Util_Tests.crearCuentaB2BPpal('Name','12345', 'X1234567X');
        cuenta.type = Label.CUE_TIPO_CLIENTEFINAL;
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
         cuenta.Type = '01';
        insert cuenta;
        

        cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR666666','PR666666_00_0','X1114567X', cuenta.id);
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c='01';
        cuentaProfesional.CUE_CAS_Activado__c = false;
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = compania.Id;
        cuentaProfesional.Type = '01';
        insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;

        tipoProducto = Util_Tests.crearTipoProductoCIA('nombre','01', compania.Id);
        insert tipoProducto;

        producto = Util_Tests.crearProductoCIA('nombre','1234',tipoProducto.Id);
        insert producto;

		sv = Util_Tests.crearPolizaContrato('Alberto', compania.Id, cuenta.Id, producto.Id);
        insert sv;

        caso = Util_Tests.crearCasoB2B(sv.Id,cuenta.Id,compania.Id);
        insert caso;

        wt = Util_Tests.crearTipoTrabajo('Trabajo_Test','21',2.00);
        insert wt;

        wo = Util_Tests.crearOrdenTrabajo('10030399', '41', wt.Id, caso.id);
        wo.OTR_SEL_Gremio__c = '41';
        insert wo;

        pv = Util_Tests.crearPropuestaDeEvento('estado', caso.id, wo.id);

        sk = Util_Tests.crearSkill('skilTest', 'etiqueta');        
        skr = Util_Tests.crearSkillRequirement(wo.id, sk.id, 1);
        
    }

    @isTest 
    static void getWorkOrderByCaseAndRecordType_Test(){
        inicializarVariables();

        rt = [SELECT Id, Name, DeveloperName, Description, BusinessProcessId, IsActive FROM RecordType LIMIT 1];
        
        System.debug('@Laura: rt: ' + rt);
        System.debug('@Laura: caso: ' + caso);
        wo.RecordTypeId = rt.id;
        //wo.CaseId = caso.id;

        Set<Id> setIdCase;
        //setIdCase.add(caso.id);

        Set<Id> setRecordTypeId;
        //setRecordTypeId.add(rt.id);

        Util_Orden_Trabajo.getWorkOrderByCaseAndRecordType(setIdCase,setRecordTypeId);
        
    }
/*
    @isTest
    static void queryOT_Test() {

        inicializarVariables();

        Util_Orden_Trabajo.queryOT(wo.Id, caso.Id, 'Id !=\'5008E00099AeOKaQAN\'');
        
        Util_Orden_Trabajo.queryOT(null , caso.Id, 'Id !=\'5008E00099AeOKaQAN\'');
        
        Util_Orden_Trabajo.queryOT(wo.Id , null, 'Id !=\'5008E00099AeOKaQAN\'');

        Util_Orden_Trabajo.queryOT(null , null, 'Id !=\'5008E00099AeOKaQAN\'');
        
        Util_Orden_Trabajo.queryOT(null , null, null);

    }*/

    /*@isTest
    static void queryOTBySet_Test(){
        inicializarVariables();

        setIdOT.add(wo.Id);
        setIdCaso.add(caso.Id);

        Util_Orden_Trabajo.queryOTBySet(setIdOT, setIdCaso, 'Id !=\'5008E00099AeOKaQAN\'');

        Util_Orden_Trabajo.queryOTBySet(null, setIdCaso, 'Id !=\'5008E00099AeOKaQAN\'');
        
        Util_Orden_Trabajo.queryOTBySet(setIdOT, null, 'Id !=\'5008E00099AeOKaQAN\'');

        Util_Orden_Trabajo.queryOTBySet(null, null, 'Id !=\'5008E00099AeOKaQAN\'');

        Util_Orden_Trabajo.queryOTBySet(null, null, null);

    }*/

    @isTest
    static void obtenerIdTipoDeRegistroOT_Test(){

        RecordType rt = [SELECT Name, DeveloperName, Description, BusinessProcessId, IsActive FROM RecordType LIMIT 1];
        
        String tipoActuacion = Label.CAS_TIPO_INDEMNIZABLE;
        Util_Orden_Trabajo.obtenerIdTipoDeRegistroOT(rt.id, tipoActuacion);

        tipoActuacion = Label.CAS_TIPO_REPARABLE;
        Util_Orden_Trabajo.obtenerIdTipoDeRegistroOT(rt.id, tipoActuacion);

    }

    @isTest
    static void crearComentarioOrdenTrabajo_and_getComentariosOT_Test(){
        inicializarVariables();

        Util_Orden_Trabajo.crearComentarioOrdenTrabajo(wo.id, 'comentario');
        setIdOT.add(wo.Id);
        Util_Orden_Trabajo.getComentariosOT(setIdOT);
    }

    @isTest
    static void crearOrdenDeTrabajo_Test(){
        inicializarVariables();
        Util_Orden_Trabajo.crearOrdenDeTrabajo(caso, 'estadoOT', 'gremio', wt.id, 'tipoDocumentoIndem', true);
    }

    @isTest
    static void permiteReservaPrimeraCita_Test(){
        
        Util_Orden_Trabajo.permiteReservaPrimeraCita(null);

        inicializarVariables();

        WorkOrder ordenTrabajo = new WorkOrder();

        caso.AccountId = null;
        Util_Orden_Trabajo.permiteReservaPrimeraCita(ordenTrabajo);
        
        ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = '10030400';
        ordenTrabajo.WorkTypeId = wt.Id;
        ordenTrabajo.Case = caso;
        ordenTrabajo.Status = Label.OTR_ESTADO_ANULADO;
        caso.AccountId = cuenta.id;
                
        insert ordenTrabajo;
        update caso;

        System.debug('@Laura: ordenTrabajo.Status: ' + ordenTrabajo.Status);
        System.debug('@Laura: ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c: ' +ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c);
        System.debug('@Laura: ordenTrabajo.caso.AccountId: ' + ordenTrabajo.Case.AccountId);

        Util_Orden_Trabajo.permiteReservaPrimeraCita(ordenTrabajo);

        ordenTrabajo.Status = Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO;

        Util_Orden_Trabajo.permiteReservaPrimeraCita(ordenTrabajo);

    }

    @isTest
    static void permiteCerrarOrdenTrabajo_Test(){

        Datetime fechaInicio = Date.newInstance(2018,12,31);
        Datetime fechaVencimiento = Date.newInstance(2019,12,31);

        inicializarVariables();
		test.startTest();
        Workorder wo1 = new Workorder();
        Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(wo1, true, null, false);


        Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(wo, true, null, false);
        
        Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(wo, true, null, false);
        Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(wo, false, null, false);

        wo.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;        
        Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(wo, true, cv, false);
        
        wo.Status = Label.OTR_ESTADO_PDTE_ATENCION_PROF;
        Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(wo, true, cv, false);
        
        wo.Status = Label.OTR_ESTADO_ANULADO_POR_PROF;
        Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(wo, true, cv, false);

        WorkOrderLineItem woli = Util_Tests.crearNuevaPartidaTrabajo(wo.Id);
        woli.Status = Label.PAR_ESTADO_ACEPTADA;
        insert woli;
        test.stopTest();
        System.debug('@Laura: (woli.WorkorderId == wo.id): '+ (woli.WorkorderId == wo.id));
    }

    @isTest
    static void getListaCitasOT_and_getMapaCitasOTs_Test(){
        inicializarVariables();

        Set<String> estadosExcluidos = new Set<String>();
        estadosExcluidos.add('estadosExcluidos');
        setIdOT.add(wo.id);

        Util_Cita_Servicio.getListCitasOTsNotInStatus(wo.id, estadosExcluidos);

        Util_Cita_Servicio.getMapCitasOTsNotInStatus(setIdOT, estadosExcluidos);
    }

    @isTest
    static void ordenesTrabajoDePartidas_Test(){

        WorkOrderLineItem woli = new WorkOrderLineItem();

        List<WorkOrderLineItem> listaPartidasOT = new List<WorkOrderLineItem>();
        listaPartidasOT.add(woli);
        Util_Orden_Trabajo.ordenesTrabajoDePartidas(listaPartidasOT);
    }

    @isTest
    static void crearOTparaCaso_Test(){
        inicializarVariables();

        Map<Id, WorkOrder> mapaOTs = new Map<Id, WorkOrder>();
        List<Case> listCase = new List<Case>();
        Map<Id, Case> mapIdCase = new Map<Id,Case>();

        caso.CAS_SEL_Requiere_profesional__c = '01';
        caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
        Case caso1 = new Case();
        caso1.CAS_CAS_Solicitud_Urgente__c = true;
        caso.CAS_SEL_Gremio_Principal__c = '38';
        listCase.add(caso);
        listCase.add(caso1);
        mapIdCase.put(caso.id,caso);
        mapIdCase.put(caso1.id,caso1);

        Util_Orden_Trabajo.crearOTparaCaso(listCase, mapIdCase, mapaOTs);

    }
/*
    
    @isTest
    static void avisoModificacionPartidas_Test(){

        inicializarVariables();

        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;

        string identificador = [SELECT CUE_TXT_Identificador__c FROM Account WHERE Id = :cuentaProfesional.Id LIMIT 1].CUE_TXT_Identificador__c;

        profesional = Util_Tests.crearRecursoServicio('RP123456','PR666666_00_0',cuentaProfesional.Id,usuario);
        profesional.RSE_LKP_Cuenta__r = cuentaProfesional;
        profesional.Name = identificador + '_01_1';
        insert profesional;

        wo.OTR_LKP_Recurso_Servicio__c = profesional.id;

        setIdOT.add(wo.Id);

        Util_Orden_Trabajo.avisoModificacionPartidas(setIdOT);
    }

*/
    @isTest
    static void insertaCiasEnOrden_Test(){
        inicializarVariables();

        List<Workorder> listWO = new List<Workorder>();
        listWO.add(wo);

        Util_Orden_Trabajo.insertaCiasEnOrden(listWO);

    }

    @isTest
    static void getListaPartidasOT_Test(){
        inicializarVariables();
        Util_Orden_Trabajo.getListaPartidasOT(wo.id, true);

        WorkOrderLineItem woli = new WorkOrderLineItem();
        setIdOT.add(woli.id);
        Util_Orden_Trabajo.getMapaPartidasOTs(setIdOT);
        Util_Orden_Trabajo.getMapaPartidasOTsFull(setIdOT);

    }

    @isTest
    static void getUltimoAlbaranOT_Test(){
        inicializarVariables();

        Util_Orden_Trabajo.getUltimoAlbaranOT(wo.id);
    }

    @isTest
    static void profesionalTieneGremio_Test(){
        inicializarVariables();

        Util_Orden_Trabajo.profesionalTieneGremio(UserInfo.getUserId(), wo.OTR_SEL_Gremio__c);
    }

    @isTest
    static void cargarListaEstadosSel_and_getConfigEstadosManualesCIA_Test(){

        inicializarVariables();

        String perfilUsuario = Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name;
        String codigoCIA = wo.OTR_FOR_Identificador_CIA__c;

        Util_Orden_Trabajo.cargarListaEstadosSel('estadoActual', perfilUsuario , codigoCIA );
        Util_Orden_Trabajo.getConfigEstadosManualesCIA(Label.PERFIL_PROFESIONAL, codigoCIA );
    }

    @isTest
    static void getListaImagenesOT_Test() {

        inicializarVariables();

        Util_Orden_Trabajo.getListaImagenesOT(wo.id);

    }

    @isTest
    static void getMapaArchivosOT_Test(){

        inicializarVariables();
        setIdOT.add(wo.id);
        WorkOrderShare wos = new WorkOrderShare();
        wos.RowCause = 'Manual';

        Util_Orden_Trabajo.getMapaArchivosOT(setIdOT);

    }

    @isTest
    static void getMapCasosOTRelacionadas_Test(){

        inicializarVariables();
        setIdCaso.add(caso.id);
        Util_Orden_Trabajo.getMapCasosOTRelacionadas(setIdCaso);
    }

    @isTest
    static void getServiceResourceSkillBySR_Test(){

        cuenta = Util_Tests.crearCuentaB2BPpal('Name','12345', 'X1234567X');
        cuenta.type = Label.CUE_TIPO_CLIENTEFINAL;
        insert cuenta;

        cuentaProfesional = new Account();
        cuentaProfesional.Name = 'PR123456';
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuenta.Id;
        cuentaProfesional.CUE_TXT_Identificador__c = 'PR123456';
        cuentaProfesional.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_PROFESIONAL_CONTRATO);
        cuentaProfesional.CUE_SEL_Tipo_Documento__c = 'C';
        cuentaProfesional.CUE_TXT_Numero_Documento__c = 'X1114567X';
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c='01';
        cuentaProfesional.CUE_CAS_Activado__c = false;
        insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;

        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;

        ServiceResource profesional = Util_Tests.crearRecursoServicio('RP123456','Estanislao',cuentaProfesional.Id,usuario);

        Util_Orden_Trabajo.getServiceResourceSkillBySR(profesional.id);

    }

    @isTest
    static void pEventosByWO_and_pAbonosByWO_Test(){

        inicializarVariables();
        setIdOT.add(wo.id);
        
        Util_Orden_Trabajo.pEventosByWO(setIdOT);
        Util_Orden_Trabajo.pAbonosByWO(setIdOT);    
    }
    
    @isTest
    static void facturarWOEventosAbonos_Test(){

        inicializarVariables();

        Set<Id> woIds = new Set<Id>();
        woIds.add(wo.id);
        
        Map<Id,List<Propuesta_de_evento__c>> eventosDeWo = Util_Orden_Trabajo.pEventosByWO(woIds);
        Map<Id,List<Propuesta_de_abono__c>> abonosDeWo = Util_Orden_Trabajo.pAbonosByWO(woIds);

        Map<Id,Workorder> woUpdate = new Map<Id,Workorder>();

        woUpdate.put(wo.id, wo);

        Util_Orden_Trabajo.facturarWOEventosAbonos(woIds, eventosDeWo, abonosDeWO, woUpdate);
    }
}