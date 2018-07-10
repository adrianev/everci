@isTest
public without sharing class Test_Util_Reclamacion {

    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType tipoTrabajo;
    private static WorkOrder ordenTrabajo;
    
    static testMethod void util_Reclamacion(){
        Test.startTest();
        compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		cuenta.Type = Label.CUE_TIPO_CONTABLE;
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert cuenta;
        
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        Case casoParent = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        insert casoParent;
        

        caso = Util_Tests.crearCasoConClienteContable(sv.Id, cuenta.Id, compania.Id, cuenta.Id);
		caso.CAS_LKP_Compania__c = compania.Id;  
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CreatedDate = system.now();
        caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
        insert caso;
        caso.CAS_CAS_Requiere_Perito__c = true;
        caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_VAL_PER;
        caso.Status = '993';
        caso.CAS_SEL_Encuestador__c = 'Servitelco';
        caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';
        caso.CAS_CAS_Informe_Definitivo_Recibido__c = true;
        caso.CAS_DIV_Importe_Total__c = 45.00;
        caso.Subject = 'PRUEBA APERTURA';
        caso.ParentId = casoParent.Id;
        update caso;
        
       
        
        tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
        insert tipoTrabajo;
        
        ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
        ordenTrabajo.AccountId = cuenta.Id; 
        Baipas.establecerVariableControl();
        insert ordenTrabajo;
        
         Case caso1 = Util_Tests.crearCasoConClienteContable(sv.Id, cuenta.Id, compania.Id, cuenta.Id);
		caso1.CAS_SEL_Encuestador__c = 'Servitelco';
        caso1.CAS_LKP_Recl_Orden_Trabajo__c = ordenTrabajo.Id;
		caso1.CAS_LKP_Compania__c = compania.Id;
		caso1.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso1.CAS_LKP_Procedencia__c = procedencia.Id;
        caso1.CreatedDate = system.now();
        caso1.Status = '993';
        caso1.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_VAL_PER;
        caso1.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
        caso1.CAS_CAS_Informe_Definitivo_Recibido__c = true;
        caso1.CAS_DIV_Importe_Total__c = 45.00;
        caso1.CAS_CAS_Requiere_Perito__c = true;
        insert caso1;
        
        List<Case> caseList = new  List<Case>();
        caseList.add(caso);
        Map<Id, WorkOrder> mapaOTs = new Map<Id, WorkOrder>();
        mapaOTs.put(ordenTrabajo.Id, ordenTrabajo);
        List<Case> caseList1 = new  List<Case>();
        caseList.add(caso1);
        
        Util_Reclamacion.completarDireccionesReclamaciones(caseList,mapaOTs);
        Util_Reclamacion.completarDireccionesReclamaciones(caseList1,mapaOTs);
        caso.Subject = 'PRUEBA APERTURA';
        update caso;
        List<Case> caseList2 = new  List<Case>();
        caseList2.add(caso);
        Util_Reclamacion.configurarReclamacionesCorreo(caseList2);
    }
}