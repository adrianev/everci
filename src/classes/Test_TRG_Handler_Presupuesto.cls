@isTest
public without sharing class Test_TRG_Handler_Presupuesto {

    private static Account compania;
    private static Account cuentaPrincipal;
    private static Account cuentaSec;
    private static Tipo_Producto_CIA__c tipoProductoCIA;
    private static Producto_CIA__c productoCia;
    private static ServiceContract poliza;
    private static Case casoB2B;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType wt;
    private static Presupuesto__c pre;

    static void inicializarVariables(boolean generarPresupuesto, String estado, boolean pendienteCita){

        compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
        insert compania;

        cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
        cuentaPrincipal.Type='01';
        insert cuentaPrincipal;

        cuentaSec=Util_Tests.crearCuentaB2BSec('Name','13132', cuentaPrincipal.Id, 'X5544663X');
        cuentaSec.Type='01';
        cuentaSec.CUE_LKP_Cliente_contable__c=cuentaPrincipal.Id;
        insert cuentaSec;

        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
        insert tipoProductoCIA;

        productoCia=Util_Tests.crearProductoCIA('nombre','01', tipoProductoCIA.Id);
        insert productoCia;


        poliza=Util_Tests.crearPolizaContrato('4523814',compania.Id, cuentaPrincipal.Id, productoCIA.Id);
        insert poliza;

        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuentaPrincipal.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;

        casoB2B = Util_Tests.crearCasoB2B(poliza.Id, cuentaSec.Id, compania.Id);
        casoB2B.CAS_SEL_Encuestador__c = 'Servitelco';
        casoB2B.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        casoB2B.CAS_LKP_Procedencia__c = procedencia.Id;
        casoB2B.OwnerId = System.UserInfo.getUserId();
        casoB2B.Status = '993';
        if (generarPresupuesto) {
            casoB2B.CAS_CAS_Generar_Presupuesto__c = true;
        }
        insert casoB2B;

        wt = new WorkType();
        wt.Name = 'Tipo de Trabajo por Defecto';
        wt.EstimatedDuration = 120.0;
        wt.DurationType = 'Minutes';
        wt.TDT_SEL_Categoria__c = '01;02';
        wt.TDT_SEL_Gremio__c = '07';
        wt.ShouldAutoCreateSvcAppt = true;
        wt.TDT_TXT_Identificador__c = '701';
        insert wt;

        OperatingHours oh = new OperatingHours();
        oh.name = 'Horario por defecto';
        oh.OPH_TXT_Identificador__c = '0001';
        insert oh;

        ServiceTerritory st = new ServiceTerritory();
        st.IsActive = true;
        st.Name = '28015 MADRID';
        st.PostalCode = '28015';
        st.TDS_TXT_Identificador__c = '28015#MADRID';
        st.OperatingHoursId = oh.Id;
        //st.TDS_LKP_Poblacion__c = poblacion.Id; 
        insert st;

        wo = new WorkOrder();
        wo.CaseId = casoB2B.Id;
        wo.AccountId = cuentaPrincipal.Id;
        wo.City = 'Madrid';
        wo.StartDate = system.now();
        wo.Duration = 2.0;
        wo.DurationType = 'Hours';
        wo.Latitude = 40.48023673004623;
        wo.Longitude = -3.6690412312805356;
        wo.WorkTypeId = wt.Id;
        wo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815917';
        wo.ServiceTerritoryId = st.Id;
        wo.CreatedDate = system.now();
        insert wo;

        WorkOrderLineItem lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(wo.Id);
        if (pendienteCita) {
            lineaOrdenTrabajo.status = Label.PAR_ESTADO_PDTE_CIA;
        }
        test.startTest();
        insert lineaOrdenTrabajo;

        pre = new Presupuesto__c();
        pre.PRE_LKP_Caso__c = casoB2B.Id;
        pre.PRE_NUM_Version__c = 1.0;
        pre.PRE_SEL_Estado_Anterior__c = Label.PRESUPUESTO_PENDIENTE_CIA;
        if (estado == 'pendienteCIA') {
            pre.PRE_SEL_Estado__c = Label.PRESUPUESTO_PENDIENTE_CIA;
        }else if(estado == 'rechazadoParcial'){
            pre.PRE_SEL_Estado__c = Label.PRESU_RECHAZADO_PARCIAL;
        }
        
        insert pre;
        
    }
    static testMethod void Handler_Presupuesto(){
        inicializarVariables(false,'pendienteCIA',true);
    }

    static testMethod void Handler_Presupuesto1(){
        inicializarVariables(false,'',false);
        pre.PRE_SEL_Estado__c = Label.PRESU_RECHAZADO_PARCIAL;
        update pre;
        test.stoptest();
    }

    static testMethod void Handler_Presupuesto2(){
        inicializarVariables(true,'rechazadoParcial',true);
    }
}