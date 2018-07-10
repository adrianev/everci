@isTest
public without sharing class Test_Util_SincronizacionMKT {
	private static Account compania {get; set;}
    private static Account cuentaPrincipal {get; set;}
    private static Account cuenta {get; set;}
    private static Account cuentaProfesional {get; set;}
    private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
    private static Poblacion__c poblacion {get; set;}
    private static ServiceContract poliza {get; set;}
    private static Procedencia__c procedencia {get; set;}
    private static Case caso {get; set;}
    private static WorkType tipoTrabajo {get; set;}
    private static WorkType tipoTrabajo2 {get; set;}
    private static Contract contrato {get; set;}
    private static Linea_Contrato__c lineaContrato {get; set;}
    private static Linea_Contrato__c lineaContrato2 {get; set;}
    private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
    private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas2 {get; set;}
    private static WorkOrder ordenTrabajo {get; set;}
    private static WorkOrderLineItem lineaOrdenTrabajo {get; set;}
    private static ServiceResource profesional {get; set;}
    private static ServiceResource profesional1 {get; set;}
    private static User usuari {get; set;}
    private static User usuario {get; set;}
    private static Account cuentaProfesionalContrato {get; set;}
    private static Case casoReclamacion {get; set;}
    private static OperatingHours horaFuncionamiento {get; set;}
    private static ServiceTerritory territorioServicio {get; set;}
    private static ServiceTerritoryMember miembroTerritorioServicio {get; set;}
    //private static ServiceAppointment citaDeServicio {get;set;}
   
    private static void inicializarVariables(){
    	Baipas.establecerVariableControl();
    	List<Account> listaCuentas = new List<Account>();
    	cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
    	cuentaPrincipal.type = Label.CUE_TIPO_CLIENTEFINAL;
    	insert cuentaPrincipal;
    	cuentaProfesionalContrato = Util_Tests.crearCuentaProfesionalContrato('PR000001','1030','X1111567X', cuentaPrincipal.Id);
    	cuentaProfesionalContrato.CUE_SEL_Estado__c = Label.CUE_ESTADO_PREACTIVADO;
    	cuentaProfesionalContrato.CUE_CAS_Activado__c = false;
    	//cuentaProfesionalContrato.CUE_SEL_Estado__c = Label.CUE_ESTADO_ACTIVADO;
    	System.debug('@@@@@@@@ '+ cuentaProfesionalContrato.CUE_SEL_Estado__c);
    	cuentaProfesionalContrato.CUE_SEL_Tipo_de_Profesional__c='01';
    	System.debug('@@@@@@@@ '+ cuentaProfesionalContrato);
    	insert cuentaProfesionalContrato;
    	cuentaProfesionalContrato.CUE_SEL_Estado__c = Label.CUE_ESTADO_ACTIVADO;
    	cuentaProfesionalContrato.CUE_CAS_Activado__c = true;
    	update cuentaProfesionalContrato;
    	compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
    	insert compania;
    	RecordType rt = [select id from RecordType Where name = 'Profesional Contrato'];
    	cuentaProfesional = Util_Tests.crearCuentaB2BPpal('PR123456','1020','X1114567X');
    	cuentaProfesional.CUE_SEL_Estado__c = Label.CUE_ESTADO_PREACTIVADO;
    	cuentaProfesional.RecordTypeId = rt.Id;
    	cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.id;
    	cuentaProfesional.CUE_LKP_Cuenta_principal__c = null;
    	System.debug('@@@@@@@@ CUE_SEL_Estado__c'+ cuentaProfesional.CUE_SEL_Estado__c);
    	cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c='01';
    	cuentaProfesional.CUE_CAS_Activado__c=false;
    	System.debug('@@@@@@@@ '+ cuentaProfesional);
    	insert cuentaProfesional;
    	cuentaProfesional.CUE_SEL_Estado__c = Label.CUE_ESTADO_ACTIVADO;
    	cuentaProfesional.CUE_CAS_Activado__c=true;
    	update cuentaProfesional;
    	Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuari;
        perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_PROFESIONAL];
        usuario = Util_Tests.nuevoUsuario('pruebas1','pruebas1','asd@hotmail.com','pruebas1','pruebas1',perfil);
        insert usuario;
    	profesional = Util_Tests.crearRecursoServicio(cuentaProfesional.CUE_TXT_Identificador__c+'_01_1','Estanislao',cuentaProfesionalContrato.Id,usuari);
        profesional.RSE_LKP_Cuenta__r=cuentaProfesional;
        profesional.RSE_LKP_Cuenta__c=cuentaProfesional.Id;
        profesional1 = Util_Tests.crearRecursoServicio(cuentaProfesional.CUE_TXT_Identificador__c+'_01_2','Estanislao1',cuentaProfesionalContrato.Id,usuario);
        profesional1.RSE_LKP_Cuenta__r=cuentaProfesional;
        profesional1.RSE_LKP_Cuenta__c=cuentaProfesional.Id;
        insert profesional;
        insert profesional1;
        insert listaCuentas;
        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
        insert tipoProductoCIA;
        productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;
        poblacion =  Util_Tests.crearPoblacion('Madrid','28');
        insert poblacion;
        cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1021',cuentaPrincipal.Id,'X1111567X');
        insert cuenta;
        poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
        insert poliza;
        procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta.Id,'101801','CAS_Siniestro');
        insert procedencia;
        caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        insert caso;
        tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
        tipoTrabajo2 = Util_Tests.crearTipoTrabajo(Label.TDT_TEXTO_MANUAL,'21', 2);
        insert tipoTrabajo;
        insert tipoTrabajo2;
	    contrato = Util_Tests.crearContrato(cuenta.Id,'b2b_p_1');
	    insert contrato;
	    lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
	    lineaContrato2 = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
	    insert lineaContrato;
	    insert lineaContrato2;
	    direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id,lineaContrato.Id,2);
	    direccionBB_lineas.DLC_TXT_Identificador__c = String.valueOf(cuenta.Id) + '_' + String.valueOf(lineaContrato.Id);
	    direccionBB_lineas2 = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id,lineaContrato2.Id,2);
	    direccionBB_lineas2.DLC_TXT_Identificador__c = String.valueOf(cuenta.Id) + '_' + String.valueOf(lineaContrato2.Id);
	    insert direccionBB_lineas;
	    insert direccionBB_lineas2;
	    horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
        insert horaFuncionamiento;
	    territorioServicio = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
        territorioServicio.TDS_TXT_Identificador__c = '28001';
        territorioServicio.isActive = true;
        insert territorioServicio;
        miembroTerritorioServicio = Util_Tests.crearMiembroTerritorioServicio(profesional ,territorioServicio ,'P',Datetime.newInstance(2015,01,01));
        miembroTerritorioServicio.PostalCode = '28001';
        miembroTerritorioServicio.State = '01';
        insert miembroTerritorioServicio;
	    Baipas.deshabilitarVariableControl();
    }
    //Asigno un profesional y cierro la WO para que borre el woMKT creado
    @isTest static void programaCitaEnInsert(){
    	inicializarVariables();
    	ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    	ordenTrabajo.OTR_LKP_Recurso_Servicio__c = null;
    	ordenTrabajo.OTR_LKP_Profesional_Programado__c =profesional.Id;
    	insert ordenTrabajo;
    	List<Work_Order_MKT__c> woMKTList = new List<Work_Order_MKT__c>([SELECT Id FROM Work_Order_MKT__c]);
    	System.assertEquals(1,woMKTList.size());
    	ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO;
    	update ordenTrabajo;
    	woMKTList = new List<Work_Order_MKT__c>([SELECT Id FROM Work_Order_MKT__c]);
    	System.assertEquals(true,woMKTList.isEmpty());
    }
    
    //Asigno un profesional y acepta
    @isTest static void programaCitaEnInsertYAcepta(){
    	inicializarVariables();
    	ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    	ordenTrabajo.OTR_LKP_Recurso_Servicio__c = null;
    	ordenTrabajo.OTR_LKP_Profesional_Programado__c =profesional.Id;
    	insert ordenTrabajo;
    	ordenTrabajo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{ordenTrabajo.Id}).values().get(0);
    	List<Work_Order_MKT__c> woMKTList = new List<Work_Order_MKT__c>([SELECT Id FROM Work_Order_MKT__c]);
    	System.assertEquals(1,woMKTList.size());
    	List<ServiceAppointment> cita = new List<ServiceAppointment>([SELECT Id, Status FROM ServiceAppointment]);
    	cita.get(0).CSE_TXT_Estado_Anterior__c = Label.CIT_ESTADO_DESASIGNADA;
    	cita.get(0).Status = null;
    	Baipas.establecerVariableControl();
    	update cita;
    	cita.get(0).Status = Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL;
    	cita.get(0).SchedStartTime=Datetime.now().addHours(200);
    	cita.get(0).SchedEndTime=Datetime.now().addHours(200);
    	cita.get(0).ServiceTerritory = territorioServicio;
    	update cita;
    	Baipas.deshabilitarVariableControl();
    	
    	//WorkAround para que no falle en el trg de cita de servicio
    	Map<Id,WorkOrder> triggerOld = new Map<Id,WorkOrder>();
    	triggerOld.put(ordenTrabajo.Id,ordenTrabajo);
    	Map<Id,WorkOrder> triggerNew = new Map<Id,WorkOrder>();
    	WorkOrder ordenTrabajoNew = new WorkOrder();
    	ordenTrabajoNew = ordenTrabajo.clone(true,true,false,false);
    	ordenTrabajoNew.OTR_LKP_Recurso_Servicio__c  = profesional.Id;
    	triggerNew.put(ordenTrabajo.Id,ordenTrabajoNew);
    	Util_SincronizacionMKT.sincronizarOTs(triggerNew,triggerOld);
    	woMKTList = new List<Work_Order_MKT__c>([SELECT Id FROM Work_Order_MKT__c]);
    	System.assertEquals(2,woMKTList.size());
    }
    //Asigno un profesional, rechaza y le asigno otro
    @isTest static void programarCitaCambiarProfAsignado(){
    	inicializarVariables();
    	ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    	ordenTrabajo.OTR_LKP_Recurso_Servicio__c = null;
    	ordenTrabajo.OTR_LKP_Profesional_Programado__c =profesional.Id;
    	insert ordenTrabajo;
    	List<Work_Order_MKT__c> woMKTList = new List<Work_Order_MKT__c>([SELECT Id FROM Work_Order_MKT__c]);
    	System.assertEquals(1,woMKTList.size());
    	List<ServiceAppointment> cita = new List<ServiceAppointment>([SELECT Id, Status FROM ServiceAppointment]);
    	cita.get(0).CSE_TXT_Estado_Anterior__c = Label.CIT_ESTADO_DESASIGNADA;
		//cita.get(0).ParentRecordId = ordenTrabajo.Id;
    	update cita;
    	ordenTrabajo.Status ='En Espera de Profesional, Pdte. Recepción de Máquina';
    	ordenTrabajo.OTR_LKP_Profesional_Programado__c =profesional1.Id;
    	update ordenTrabajo;
    	woMKTList = new List<Work_Order_MKT__c>([SELECT Id FROM Work_Order_MKT__c]);
    	System.assertEquals(2,woMKTList.size());
    }
}