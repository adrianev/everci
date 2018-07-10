@isTest
public with sharing class Test_Util_ExtraccionBitacora {
    private static Account compania {get; set;}
    private static Account cuentaPrincipal {get; set;}
    private static Account cuenta {get; set;}
    private static Account cuentaContable {get; set;}
    private static Account cuentaProfesional {get; set;}
    private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
    private static Poblacion__c poblacion {get; set;}
    private static ServiceContract poliza {get; set;}
    private static Procedencia__c procedencia {get; set;}
    private static Case caso {get; set;}
    private static WorkType tipoTrabajo {get; set;}
    private static Contract contrato {get; set;}
    private static Linea_Contrato__c lineaContrato {get; set;}
    private static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccionBB_lineas {get; set;}
    private static WorkOrder ordenTrabajo {get; set;}
    private static WorkOrderLineItem lineaOrdenTrabajo {get; set;}
    private static ServiceResource profesional {get; set;}
    private static User usuari {get; set;}
    private static OperatingHours horasFuncionamiento {get; set;}
    private static ServiceTerritory territorio {get; set;}
    private static List<ContentDocumentLink> listaDoc {get;set;}
    private static Account cuentaPoliza {get;set;}
    
   		private static void inicializarVariables(){
        Baipas.establecerVariableControl();
        List<Account> listaCuentas = new List<Account>();
        compania = Util_Tests.crearCuentaCompania('Endesa',Label.IDE_ENDESA,'X1234567X');
        cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','X1134567X');
        insert cuentaPrincipal;
        Account cuentaProfesional = new Account();
        cuentaProfesional.Name = 'PR123456';
        cuentaProfesional.CUE_TXT_Identificador__c = 'PR123456';
        cuentaProfesional.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_PROFESIONAL_CONTRATO);
        cuentaProfesional.CUE_SEL_Tipo_Documento__c = 'C';
        cuentaProfesional.CUE_TXT_Numero_Documento__c = 'X1114567X';
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
         update cuentaProfesional;
        
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuari;
        profesional = Util_Tests.crearRecursoServicio('RP123456','Estanislao',cuentaProfesional.Id,usuari);
        //new
        profesional.IsActive =  true;
        //insert profesional;
        
        
        //Fragmento copiado de Test_GenerarAlbaranController
        
          
        RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
        Account cuentaProfesional1 = Util_Tests.crearCuentaProfesionalContrato('CuentaProf','1020','X1114567X',null);
        cuentaProfesional1.RecordTypeId = rt.Id;
        cuentaProfesional1.Name = 'PR123456';
        cuentaProfesional1.CUE_SEL_Tipo_de_Profesional__c = '01';
        cuentaProfesional1.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        insert cuentaProfesional1;
        cuentaProfesional1.CUE_SEL_Estado__c = '02';
        update cuentaProfesional1;
             
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :cuentaProfesional1.Id ];
        profesional = Util_Tests.crearRecursoServicio('David','Estanislao',acc1.Id,usuari);
        //profesional.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        profesional.RSE_SEL_Gremio__c = '31';
        profesional.Name = acc1.CUE_TXT_Identificador__c + '_' + profesional.RSE_SEL_Gremio__c + '_1';
        system.debug('>>>>>profesional.Name: ' + profesional.Name);
        insert profesional;
        
        cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1021',cuentaPrincipal.Id,'X1111567X');
        listaCuentas.add(compania);
        listaCuentas.add(cuenta);
        insert listaCuentas;
        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
        insert tipoProductoCIA;
        productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;
        /*poblacion =  Util_Tests.crearPoblacion('Madrid','28');
        insert poblacion;*/
        poliza = Util_Tests.crearPolizaContrato('Alberto', cuenta.Id, compania.Id, productoCIA.Id);
        insert poliza;
        procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,cuenta.Id,'101801','CAS_Siniestro');
        insert procedencia;
        caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
        caso.CAS_TXT_DirRiesgo_CP__c = '28001';
        insert caso;
        update compania;
        tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
        //tipoTrabajo = Util_Tests.crearTipoTrabajo('Arregla mesa','21', 2);
        insert tipoTrabajo;
        contrato = Util_Tests.crearContrato(cuenta.Id,'b2b_p_1');
        insert contrato;
        lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,5,'21',Label.RT_LIN_CON_CORRECTIVO);
        insert lineaContrato;
        direccionBB_lineas = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(cuenta.Id,lineaContrato.Id,3);
        direccionBB_lineas.DLC_TXT_Identificador__c = cuenta.Id + '_' + lineaContrato.Id;
        insert direccionBB_lineas;
        List<FSL__Scheduling_Policy__c> listaPoliticas = new List<FSL__Scheduling_Policy__c>();
        FSL__Scheduling_Policy__c primerPoliticas = new FSL__Scheduling_Policy__c();
        primerPoliticas.Name = 'Política de Asignación – Geolocalización - Primario';
        listaPoliticas.add(primerPoliticas);
        FSL__Scheduling_Policy__c segundoPoliticas = new FSL__Scheduling_Policy__c();
        segundoPoliticas.Name = 'Política de Asignación – Geolocalización';
        listaPoliticas.add(segundoPoliticas);
        insert listaPoliticas;
        horasFuncionamiento = Util_Tests.crearHoraFuncionamiento('horaF', 'Europe/Paris');
        insert horasFuncionamiento;
        territorio = Util_Tests.crearTerritorioServicio('28001', horasFuncionamiento.Id, '28001');
        territorio.IsActive = true;
        insert territorio;
        
        ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('18210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
        ordenTrabajo.AccountId = cuenta.Id;
        ordentrabajo.CaseId = caso.Id; 
        ordentrabajo.PostalCode = '28001';
        ordentrabajo.status = '999';
        ordentrabajo.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA);
        //ordentradajo.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA);
        
        //new
        ordentrabajo.OTR_LKP_Recurso_Servicio__c = profesional.Id ;
        upsert ordenTrabajo;
        system.debug('>>>>>verOT: ' + ordentrabajo);
        system.debug('>>>>>verOT.RecordTypeId: ' + ordentrabajo.RecordTypeId);
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo;
    }
    
    @isTest static void testing(){
        inicializarVariables();
        Baipas.establecerVariableControl();
        Util_ExtraccionBitacora.extraccionProfesionales();
        Util_ExtraccionBitacora.extraccionClientes();
        Util_ExtraccionBitacora.extraccionPrefacturas();
    }
}