@isTest
public without sharing class Test_Util_Tarea {

    private static Account cuenta;
    private static Account compania;
    private static Case caso;
    private static Case caso2;
    private static Case caso3;
    private static Case caso4;
    private static WorkOrder ordenTrabajo;
    
    private static void inicializarVariables() {
	    Baipas.establecerVariableControl();
	    compania = Util_Tests.crearCuentaCompania('compania', '556001','X1234567X');
	    compania.CUE_DIV_Limite_Actuacion__c = 20.00;
		insert compania;
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		cuenta.Type = Label.CUE_TIPO_CONTABLE;
		insert cuenta;
		Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
		ServiceContract sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
	    procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
	    insert procedencia;
	    caso = Util_Tests.crearCasoConClienteContable(sv.Id, cuenta.Id, compania.Id, cuenta.Id);//crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
		caso.CAS_SEL_Encuestador__c = 'Servitelco';
		caso.CAS_LKP_Compania__c = compania.Id;
		caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
	    caso.CAS_LKP_Procedencia__c = procedencia.Id;
	    caso.CreatedDate = system.now();
	    caso.Status = '001';
	    caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_VAL_PER;
	    caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
	    caso.CAS_CAS_Informe_Definitivo_Recibido__c = false;
	    caso.CAS_DIV_Importe_Total__c = 45.00;
	    caso.CAS_CAS_Requiere_Perito__c = false;
	    caso.CAS_DIV_Pago_de_Minuta__c=null;
	    caso.CAS_CAS_Informe_Preliminar_Recibido__c=true;
	    caso.CAS_DAT_Generar_Tarea_Semaforo__c = DateTime.Now();
	    caso.CAS_DAT_Fecha_Activacion_Contador__c = DateTime.Now();
	    caso.OwnerId = System.UserInfo.getUserId();
	    //caso.CAS_CAS_Requiere_Perito__c = true;
	    insert caso;
	    WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
	    ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
		insert ordenTrabajo;
	    Baipas.deshabilitarVariableControl();
    }

    @isTest static void creacionTareas() {
    	inicializarVariables();
    	Test.startTest();
    	Task tarea1 = Util_Tarea.recordatorioEnvioIP(caso);
    	Task tarea2 = Util_Tarea.recordatorioEnvioID(caso);
    	Task tarea3 = Util_Tarea.recordatorioEnvioRes(caso);
    	Task tarea4 = Util_Tarea.recordatorioEnvioMinuta(caso);
    	//Task tarea5 = Util_Tarea.revisionIP(caso);
    	//Task tarea6 = Util_Tarea.revisionID(caso);
    	Task tarea7 = Util_Tarea.crearTareaComun(caso, Label.TAR_ASUNTO_REVISION_ID);
    	List<Case> casos = new List<Case>();
    	Map<Id, Case> casosOld = new Map<Id, Case>();
    	Baipas.establecerVariableControl();
    	casosOld.put(caso.Id, caso);
    	caso.CAS_NUM_Dias_Verde__c = 5;
    	caso.CAS_NUM_Dias_Amarillo__c = 4;
    	caso.CAS_DAT_Generar_Tarea_Semaforo__c = null;
    	update caso;
    	Baipas.deshabilitarVariableControl();
    	casos.add(caso);
    	Map<Id,Account> cuentas = new Map<Id, Account>();
    	cuentas.put(caso.AccountId,compania);
    	List<Task> tareas = Util_Tarea.crearTareasParaCaso(casos, casosOld, cuentas);	
    	tareas.add(tarea1);
    	tareas.add(tarea2);
    	tareas.add(tarea3);
    	tareas.add(tarea4);
    	tareas.add(tarea7);
    	Map<Id,List<Task>> tareasCaso = new Map <Id,List<Task>>();
    	tareasCaso.put(caso.Id,tareas);
    	Map<Id, WorkOrder> ots = new Map<Id, WorkOrder>();
    	ots.put(ordenTrabajo.Id, ordenTrabajo);
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		Baipas.establecerVariableControl();
		caso.CAS_CAS_Informe_Preliminar_Recibido__c = false;
		update caso;
		Baipas.deshabilitarVariableControl();
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		Util_tarea.cerrarTareasCaso(caso,Label.TAR_ASUNTO_REVISION_ID, tareasCaso);
		caso.CAS_CAS_Informe_Definitivo_Recibido__c = true;
		update caso;
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_REV_RESP_PER;
		caso.CAS_CAS_Informe_Preliminar_Recibido__c = true;
		update caso;
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		caso.CAS_CAS_Informe_Preliminar_Recibido__c = false;
		caso.CAS_CAS_Informe_Definitivo_Recibido__c = true;
		update caso;
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_INFORME_PRELIMINAR;
		update caso;
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		Test.stopTest();
    }
    
    @isTest static void creacionTareas2() {
    	inicializarVariables();
    	Test.startTest();
    	Set<Id> idCas = new Set<Id>();
    	Task tarea1 = Util_Tarea.recordatorioEnvioIP(caso);
    	Task tarea2 = Util_Tarea.recordatorioEnvioID(caso);
    	
    	Task tarea7 = Util_Tarea.crearTareaComun(caso, Label.TAR_ASUNTO_REVISION_ID);
    	List<Case> casos = new List<Case>();
    	Map<Id, Case> casosOld = new Map<Id, Case>();
    	Baipas.establecerVariableControl();
    	casosOld.put(caso.Id, caso);
    	caso.CAS_NUM_Dias_Verde__c = 5;
    	caso.CAS_NUM_Dias_Amarillo__c = 4;
    	caso.CAS_DAT_Generar_Tarea_Semaforo__c = null;
    	 caso.CAS_DIV_Importe_Total__c = 10.00;
    	update caso;
    	Baipas.deshabilitarVariableControl();
    	casos.add(caso);
    	Map<Id,Account> cuentas = new Map<Id, Account>();
    	cuentas.put(caso.AccountId,compania);
    	List<Task> tareas = Util_Tarea.crearTareasParaCaso(casos, casosOld, cuentas);	
    	tareas.add(tarea1);
    	tareas.add(tarea2);
    	tareas.add(tarea7);
    	Map<Id,List<Task>> tareasCaso = new Map <Id,List<Task>>();
    	tareasCaso.put(caso.Id,tareas);
    	Map<Id, WorkOrder> ots = new Map<Id, WorkOrder>();
    	ots.put(ordenTrabajo.Id, ordenTrabajo);
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		idCas.add(caso.Id);
		Util_Tarea.tareasDeCasos(idCas);
		Util_Tarea.cerrarTareasCaso(caso,Label.TAR_ASUNTO_REVISION_ID, tareasCaso);
		Test.stopTest();
    }
    
    @isTest static void creacionTareas3() {
    	inicializarVariables();
    	Test.startTest();
    	Set<Id> idCas = new Set<Id>();
    	Task tarea1 = Util_Tarea.recordatorioEnvioIP(caso);
    	Task tarea2 = Util_Tarea.recordatorioEnvioID(caso);
    	
    	Task tarea7 = Util_Tarea.crearTareaComun(caso, Label.TAR_ASUNTO_REVISION_ID);
    	List<Case> casos = new List<Case>();
    	Map<Id, Case> casosOld = new Map<Id, Case>();
    	Baipas.establecerVariableControl();
    	casosOld.put(caso.Id, caso);
    	caso.CAS_NUM_Dias_Verde__c = 5;
    	caso.CAS_NUM_Dias_Amarillo__c = 4;
    	caso.CAS_DAT_Generar_Tarea_Semaforo__c = null;
    	 caso.CAS_DIV_Importe_Total__c = 10.00;
    	 caso.CAS_CAS_Requiere_Perito__c = true;
    	update caso;
    	Baipas.deshabilitarVariableControl();
    	casos.add(caso);
    	Map<Id,Account> cuentas = new Map<Id, Account>();
    	cuentas.put(caso.AccountId,compania);
    	List<Task> tareas = Util_Tarea.crearTareasParaCaso(casos, casosOld, cuentas);	
    	tareas.add(tarea1);
    	tareas.add(tarea2);
    	tareas.add(tarea7);
    	Map<Id,List<Task>> tareasCaso = new Map <Id,List<Task>>();
    	tareasCaso.put(caso.Id,tareas);
    	Map<Id, WorkOrder> ots = new Map<Id, WorkOrder>();
    	ots.put(ordenTrabajo.Id, ordenTrabajo);
		Util_Tarea.generarTareas(caso, null, cuentas, tareasCaso, ots, null);
		idCas.add(caso.Id);
		Util_Tarea.tareasDeCasos(idCas);
		Util_Tarea.cerrarTareasCaso(caso,Label.TAR_ASUNTO_REVISION_ID, tareasCaso);
		Test.stopTest();
    }
    
    @isTest static void prioridadTarea() {
    	inicializarVariables();
    	Util_Tarea.setPrioridadTarea('13');
    }
}