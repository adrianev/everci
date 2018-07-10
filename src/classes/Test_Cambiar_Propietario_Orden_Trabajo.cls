@isTest
public without sharing class Test_Cambiar_Propietario_Orden_Trabajo {

    
    @isTest static void testEnOtraPagina(){
        cambiar_Propietario_Orden_Trabajo(false);
    }

    @isTest static void testEnPaginaActual(){
        cambiar_Propietario_Orden_Trabajo(true);
    }

    private static void cambiar_Propietario_Orden_Trabajo(boolean estadoPaginaActual){
        Profile perfil = [select id, name from profile where name = 'Supervisor Auditoria de Gestion'];
        User usuario1 = Util_Tests.nuevoUsuario('PR123456_01_1', '00000001', 'PR123456_01_1@prueba.es', 'PR123456_01_1', 'PR123456_01_1', perfil);
        insert usuario1;
        System.runAs(usuario1){
        Test.startTest();
        Baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
        insert compania;
        Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018','miguel@gmail.es', '99088976P','Miguel', 'Sagrado', 'Velasco');
        asegurado.CUE_SEL_Tipo_Documento__c='N';
        asegurado.CUE_LKP_Cuenta_principal__c = compania.Id;
        insert asegurado;    
        Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
        insert tipoProductoCIA;
        Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;
        ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', asegurado.Id, compania.Id, productoCIA.Id);
        insert poliza;
        Case caso = Util_Tests.crearCasoB2B(poliza.Id, asegurado.Id, compania.Id);
        WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
        WorkOrder ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0', '21',tipoTrabajo.Id,caso.Id);
        ordenTrabajo.OwnerId = system.UserInfo.getUserId();
        List<WorkOrder> listWO = new List<WorkOrder>();
        listWO.add(ordenTrabajo);
        insert listWO;
        if(estadoPaginaActual)
            Test.setCurrentPage(Page.Cambiar_Propietario_Orden_Trabajo);
        else
            Test.setCurrentPage(Page.TelefonosConsulta);

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listWO);
        Cambiar_Propietario_Orden_Trabajo cWO = new Cambiar_Propietario_Orden_Trabajo(sc);
        cWO.volver();
        cWO.cambiarPropAutoWorkOrders();
        cWO.wo = ordenTrabajo;
        cWO.guardar();
        Baipas.deshabilitarVariableControl();
        Test.stopTest();
        }
    }
}