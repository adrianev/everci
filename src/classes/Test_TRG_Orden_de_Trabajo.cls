@isTest
public without sharing class Test_TRG_Orden_de_Trabajo {
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
    private static User usuari {get; set;}
    private static Account cuentaProfesionalContrato {get; set;}
    private static Case casoReclamacion {get; set;}
    //private static ServiceAppointment citaDeServicio {get;set;}
   
    private static void inicializarVariables(){
      	Baipas.establecerVariableControl();
      	List<Account> listaCuentas = new List<Account>();
        cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
        cuentaPrincipal.type = Label.CUE_TIPO_CLIENTEFINAL;
        insert cuentaPrincipal;
      	cuentaProfesionalContrato = Util_Tests.crearCuentaProfesionalContrato('PR000001','1030','X1111567X', cuentaPrincipal.Id);
      	cuentaProfesionalContrato.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.id;
      	cuentaProfesionalContrato.CUE_LKP_Cuenta_principal__c = null;
      	cuentaProfesionalContrato.CUE_SEL_Tipo_de_Profesional__c = '01';
      
      	insert cuentaProfesionalContrato;
        cuentaProfesionalContrato.CUE_SEL_Estado__c = Label.CUE_ESTADO_ACTIVADO;
        update cuentaProfesionalContrato;
    	compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
    	RecordType rt = [select id from RecordType Where name = 'Profesional Contrato'];
        cuentaProfesional = Util_Tests.crearCuentaB2BPpal('PR123456','1020','X1114567X');
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuentaProfesional.RecordTypeId = rt.Id;
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.id;
        cuentaProfesional.CUE_LKP_Cuenta_principal__c = null;
    	insert cuentaProfesional;
        cuentaProfesional.CUE_CAS_Activado__c=true;
        cuentaProfesional.CUE_SEL_Estado__c= '02';
     	update cuentaProfesional;
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuari;


        profesional = Util_Tests.crearRecursoServicio(cuentaProfesional.CUE_TXT_Identificador__c+'21_1','Estanislao',cuentaProfesionalContrato.Id,usuari);
        profesional.RSE_LKP_Cuenta__r=cuentaProfesional;
        profesional.RSE_SEL_Gremio__c = '21';
        profesional.RSE_LKP_Cuenta__c=cuentaProfesional.Id;
        insert profesional;
    	cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1021',cuentaPrincipal.Id,'X1111567X');
    	listaCuentas.add(compania);
    	listaCuentas.add(cuenta);
    	insert listaCuentas;
    	tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
    	insert tipoProductoCIA;
    	productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
    	insert productoCIA;
    	poblacion =  Util_Tests.crearPoblacion('Madrid','28');
    	insert poblacion;
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
    	List<FSL__Scheduling_Policy__c> listaPoliticas = new List<FSL__Scheduling_Policy__c>();
    	FSL__Scheduling_Policy__c primerPoliticas = new FSL__Scheduling_Policy__c();
    	primerPoliticas.Name = 'Política de Asignación – Geolocalización - Primario';
    	listaPoliticas.add(primerPoliticas);
    	FSL__Scheduling_Policy__c segundoPoliticas = new FSL__Scheduling_Policy__c();
    	segundoPoliticas.Name = 'Política de Asignación – Geolocalización';
    	listaPoliticas.add(segundoPoliticas);
    	insert listaPoliticas;
    	casoReclamacion = Util_Tests.crearCasoReclamacion(poliza.Id, cuenta.Id, compania.Id);
    	insert casoReclamacion;
    	datetime ahora = system.now();
    //citaDeServicio = Util_tests.crearCitaServicio('Madrid', 'Spain', '28003', 'Madrid', 'Castellana', ahora, ahora);
    //insert citaDeServicio;
    
    
    Baipas.deshabilitarVariableControl();
    }

    
  
  @isTest static void segundoTestTriggerOT(){
    inicializarVariables();
    Test.startTest();
    //insertamos politcas que se utilizan en TRG_Handler Orden de trabajo
    
    Baipas.deshabilitarVariableControl();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.AccountId = cuenta.Id;
    
    
    ordentrabajo.CaseId = caso.Id;
    ordentrabajo.WorkTypeId = tipoTrabajo.Id;
    insert ordenTrabajo;
   
    update ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        Test.stopTest();
  }
  
  @isTest static void segundoTestBISTriggerOT(){
    inicializarVariables();
    Test.startTest();
    //insertamos politcas que se utilizan en TRG_Handler Orden de trabajo
    
    Baipas.establecerVariableControl();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.AccountId = cuenta.Id;
    
    ordentrabajo.CaseId = caso.Id;
    insert ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo;
        Baipas.deshabilitarVariableControl();
        
        ordenTrabajo.Status = '101';
        ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
        Boolean aux2 = Baipas.deshabilitarVariableControl();
        update ordenTrabajo;
        
        Test.stopTest();
  }
  
  @isTest static void tercerTestTriggerOT(){
    inicializarVariables();
    Test.startTest();
    system.debug('>>>>>caso.Id: ' + caso.Id);
    
    //Insertamos un nuevo caso para hacer saltar la condición: if (woOld != null && wo.caseId != woOld.caseId)
    Case casoWO = new Case();
    casoWO = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
    Baipas.establecerVariableControl();
        insert casoWO;
        Baipas.deshabilitarVariableControl();
    system.debug('>>>>>casoWO.Id: ' + casoWO.Id);
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordentrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
    ordenTrabajo.AccountId = cuenta.Id;
    
    ordentrabajo.CaseId = caso.Id;
    insert ordenTrabajo;
    casoWO.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
    /*Baipas.establecerVariableControl();
    update casoWO;
    Baipas.deshabilitarVariableControl();*/
    ordentrabajo.CaseId = casoWO.Id;
    update ordenTrabajo;
    delete ordenTrabajo;
        Test.stopTest();
  }
  
  @isTest static void cuartoTestTriggerOT(){
    inicializarVariables();
    Test.startTest();
    system.debug('>>>>>caso.Id: ' + caso.Id);
    
    //Insertamos un nuevo caso para hacer saltar la condición: if (woOld != null && wo.caseId != woOld.caseId)
    Case casoWO = new Case();
    casoWO = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
    Baipas.establecerVariableControl();
        insert casoWO;
        Baipas.deshabilitarVariableControl();
    system.debug('>>>>>casoWO.Id: ' + casoWO.Id);
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.AccountId = cuenta.Id;
    
    ordentrabajo.CaseId = caso.Id;
    insert ordenTrabajo;
    ordentrabajo.CaseId = casoWO.Id;
    ordentrabajo.OTR_SEL_Rango_Primera_Cita__c = '09';
    update ordenTrabajo;
    delete ordenTrabajo;
        Test.stopTest();
  }
  
  @isTest static void quintoTestTriggerOT(){
    inicializarVariables();
    Test.startTest();
    
    Baipas.deshabilitarVariableControl();
    
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.AccountId = cuenta.Id;
    
    ordentrabajo.CaseId = caso.Id;
    insert ordenTrabajo;
        /*lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        Baipas.establecerVariableControl();
        insert lineaOrdenTrabajo;
        Baipas.deshabilitarVariableControl();
        ordenTrabajo.Status = '06';
        ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
        Boolean aux2 = Baipas.deshabilitarVariableControl();
        update ordenTrabajo;
        List<WorkOrder> listaWO = new List<WorkOrder>();
        listaWO.add(ordenTrabajo);
        TRG_Handler_Orden_de_Trabajo.maestroClientesTRG(listaWO);
        delete listaWO;*/
        
        //Actualizamos CP, Gremio 
        //y Tipo de trabajo de la WO
        //ordenTrabajo.PostalCode = '28300';
        //ordenTrabajo.OTR_SEL_Gremio__c = '02';
        //ordenTrabajo.Name = 'Arregla mesa';
        //update ordenTrabajo;
        Test.stopTest();
  }

  @isTest static void quintoTestBISTriggerOT(){
    inicializarVariables();
    Test.startTest();
    
    Baipas.establecerVariableControl();
    
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.AccountId = cuenta.Id;
    
    ordentrabajo.CaseId = caso.Id;
    insert ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo;
        ordenTrabajo.Status = '06';
        ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
        update ordenTrabajo;
      /*
        List<WorkOrder> listaWO = new List<WorkOrder>();
        listaWO.add(ordenTrabajo);
     	insert listaWO;
        //TRG_Handler_Orden_de_Trabajo.maestroClientesTRG(listaWO);
        delete listaWO;
       */ 
        //Actualizamos CP, Gremio 
        //y Tipo de trabajo de la WO
        //ordenTrabajo.PostalCode = '28300';
        //ordenTrabajo.OTR_SEL_Gremio__c = '02';
        //ordenTrabajo.Name = 'Arregla mesa';
        //update ordenTrabajo;
        Baipas.deshabilitarVariableControl();
        Test.stopTest();
  }

  /*@isTest static void sextoTestTriggerOT(){
    inicializarVariables();
    Test.startTest();
    
    Baipas.deshabilitarVariableControl();
    
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.AccountId = cuenta.Id;
    
    ordentrabajo.CaseId = caso.Id;
    insert ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        Baipas.establecerVariableControl();
        insert lineaOrdenTrabajo;
        Baipas.deshabilitarVariableControl();
        ordenTrabajo.Status = '501';
        ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
        caso.CAS_DIV_Total_Facturar_CIA_AI__c=100.0;
        update caso;
        Boolean aux2 = Baipas.deshabilitarVariableControl();
        update ordenTrabajo;
        List<WorkOrder> listaWO = new List<WorkOrder>();
        listaWO.add(ordenTrabajo);
        //TRG_Handler_Orden_de_Trabajo.maestroClientesTRG(listaWO);
        delete listaWO;
        
        //Actualizamos CP, Gremio 
        //y Tipo de trabajo de la WO
        //ordenTrabajo.PostalCode = '28300';
        //ordenTrabajo.OTR_SEL_Gremio__c = '02';
        //ordenTrabajo.Name = 'Arregla mesa';
        update ordenTrabajo;
        Test.stopTest();
  }*/
  /*@isTest static void septimoTestTriggerOT(){
    inicializarVariables();
    Test.startTest();
    
    Baipas.deshabilitarVariableControl();
    
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.AccountId = cuenta.Id;
    
    ordentrabajo.CaseId = caso.Id;
    //ordentrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c=null;
    insert ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        Baipas.establecerVariableControl();
        insert lineaOrdenTrabajo;
        Baipas.deshabilitarVariableControl();
        ordentrabajo.Status = Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO;
        ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
        caso.CAS_DIV_Total_Facturar_CIA_AI__c=100.0;
        update caso;
        Boolean aux2 = Baipas.deshabilitarVariableControl();
        update ordenTrabajo;
        List<WorkOrder> listaWO = new List<WorkOrder>();
        listaWO.add(ordenTrabajo);
       // TRG_Handler_Orden_de_Trabajo.maestroClientesTRG(listaWO);
        delete listaWO;
        
        //Actualizamos CP, Gremio 
        //y Tipo de trabajo de la WO
        //ordenTrabajo.PostalCode = '28300';
        //ordenTrabajo.OTR_SEL_Gremio__c = '02';
        //ordenTrabajo.Name = 'Arregla mesa';
        //update ordenTrabajo;
        //Test.stopTest();
  }*/
  /*@isTest static void octavoTestTriggerOT(){
        Test.startTest();
        Boolean aux = Baipas.establecerVariableControl();
                               List<Account> listaCuentas = new List<Account>();
                               compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
                               cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
                               insert cuentaPrincipal;
        cuentaProfesional = Util_Tests.crearCuentaB2BPpal('CuentaProf','1020','X1114567X');
                               insert cuentaProfesional;
        List<Profile> perfiles = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfiles.get(0));
        insert usuari;
        Account cuentaProfesionalContrato = Util_Tests.crearCuentaProfesionalContrato('PR000001','1030','X1111567X');
        cuentaProfesionalContrato.CUE_SEL_Estado__c = Label.CUE_ESTADO_ACTIVADO;
      insert cuentaProfesionalContrato;
        profesional = Util_Tests.crearRecursoServicio('Nombre','Estanislao',cuentaProfesionalContrato.Id,usuari);
    insert profesional;
       cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1021',cuentaPrincipal.Id,'X1111567X');
       listaCuentas.add(compania);
       listaCuentas.add(cuenta);
       insert listaCuentas;
       tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
       insert tipoProductoCIA;
       productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
       insert productoCIA;
       poblacion =  Util_Tests.crearPoblacion('Madrid','28');
       insert poblacion;
       poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,true,'79167066','28001','PISO',Date.newInstance(2016, 12, 31),'Madrid',productoCIA.Id,'2');
       insert poliza;
       procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta.Id,'101801','CAS_Siniestro');
       insert procedencia;
       caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
       insert caso;
       tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
       insert tipoTrabajo;
       contrato = Util_Tests.crearContrato(cuenta.Id,'b2b_p_1');
       insert contrato;
       lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
       insert lineaContrato;
       direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id,lineaContrato.Id,3);
       direccionBB_lineas.DLC_TXT_Identificador__c = String.valueOf(cuenta.Id) + '_' + String.valueOf(lineaContrato.Id);
       insert direccionBB_lineas;
       ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
       ordenTrabajo.AccountId = cuenta.Id;
       insert ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo;
        ordenTrabajo.Status = '501';
        Boolean aux2 = Baipas.deshabilitarVariableControl();
        upsert ordenTrabajo;
        delete ordenTrabajo;
        Test.stopTest();
  }*/

  @isTest
  public static void testUltimo(){
    Test.startTest();
    inicializarVariables();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato.Id;
    ordenTrabajo.OTR_TXT_Identificador_DLC__c = direccionBB_lineas.DLC_TXT_Identificador__c;
    insert ordenTrabajo;
    ordenTrabajo.OTR_LKP_Linea_Contrato__c = lineaContrato2.Id;
    ordenTrabajo.OTR_TXT_Identificador_DLC__c = direccionBB_lineas2.DLC_TXT_Identificador__c;
    update ordenTrabajo;
    Test.stopTest();
  }
  
  /*@isTest
  public static void CambioEstadoCerrado(){
    Test.startTest();
    inicializarVariables();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',null,caso.Id,profesional.Id);
    ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
    insert ordenTrabajo;
    ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO;
    WorkOrderLineItem partidaWO = new WorkOrderLineItem();
    partidaWO = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
    insert partidaWO;
    update ordenTrabajo;
    Test.stopTest();
  }*/
  
  @isTest
  public static void woCasoReclamacion(){
    Test.startTest();
    inicializarVariables();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,casoReclamacion.Id,profesional.Id);
    ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = false;
    insert ordenTrabajo;
    ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
    update ordenTrabajo;
    WorkOrderLineItem partidaWO = new WorkOrderLineItem();
    partidaWO = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
    Test.stopTest();
  }
  
  @isTest
  public static void woCasoNoReclamacion(){
    Test.startTest();
    inicializarVariables();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
    ordenTrabajo.Status = Label.OTR_ESTADO_ANULADO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = false;
    insert ordenTrabajo;
    caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
    update caso;
    ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
    update ordenTrabajo;
    WorkOrderLineItem partidaWO = new WorkOrderLineItem();
    partidaWO = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
    Test.stopTest();
  }
  
  @isTest
  public static void woCambioEstado(){
    Test.startTest();
    inicializarVariables();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,casoReclamacion.Id,profesional.Id);
    ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = false;
    insert ordenTrabajo;
    caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
    update caso;
    ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
    update ordenTrabajo;
    WorkOrderLineItem partidaWO = new WorkOrderLineItem();
    partidaWO = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
    Test.stopTest();
  }
  
  @isTest
  public static void enEsperaDeConf(){
    
    inicializarVariables();
    Test.startTest();
    ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,casoReclamacion.Id,profesional.Id);
    ordenTrabajo.Status = Label.OTR_ESTADO_REVISADO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = false;
    caso.CAS_DIV_Total_Facturar_CIA_AI__c = 10.22;
    update caso;
    insert ordenTrabajo;
    caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
    caso.CAS_DIV_Total_Facturar_CIA_AI__c = 43.34;
    update caso;
    ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO;
    ordenTrabajo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
    ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = '';
    //ordenTrabajo.OTR_LKP_Primera_Cita__c = citaDeServicio.iD;
    update ordenTrabajo;
    WorkOrderLineItem partidaWO = new WorkOrderLineItem();
    partidaWO = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
    
    List<WorkOrder> listWO = new List<WorkOrder>();
    listWO.add(ordenTrabajo);
    Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>();
    Set<Id> setIdsWO = new Set<Id>();   
    mapWO.put(ordenTrabajo.Id,ordenTrabajo);
    setIdsWO.add(ordenTrabajo.Id);
    TRG_Handler_Orden_de_Trabajo.calcularLimiteOrdenEnCurso(listWO,mapWO,setIdsWO);
    TRG_Handler_Orden_de_Trabajo.calcularLimiteOrdenMensual(listWO,mapWO,setIdsWO);
    Test.stopTest();
  }
}