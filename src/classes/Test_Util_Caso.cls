@isTest
public without sharing class Test_Util_Caso {

    @isTest static void Util_Caso(){
        Account compania = Util_Tests.crearCuentaCompania('compania', Label.IDE_MEMBERSHIP,'X1234567X');
        compania.type = '01';
		insert compania;
        Account compania2 = Util_Tests.crearCuentaCompania('compania', '1018','X1134567X');
		insert compania2;
        Account cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1334567X');
        cuenta.type = '01';
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert cuenta;
        
        Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
        Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        insert procedencia;
        
       	ServiceContract sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        
        Case caso = new Case();
        caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        caso.CAS_SEL_Encuestador__c = 'Servitelco';
        caso.CAS_LKP_Compania__c = compania.Id;
        caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CreatedDate = system.now();
        caso.Status = '993';
        caso.OwnerId = system.UserInfo.getUserId();
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso;
        
        
        WorkType wt = new WorkType();
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
        
        WorkOrder wo = new WorkOrder();
		wo.AccountId = cuenta.Id;
        wo.CaseId = caso.Id;
		wo.City = 'Madrid';
		wo.StartDate = system.now();
		wo.Duration = 2.0;
		wo.DurationType = 'Hours';
		wo.Latitude = 40.48023673004623;
		wo.Longitude = -3.6690412312805356;
		wo.WorkTypeId = wt.Id;
		wo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815917';
		wo.ServiceTerritoryId = st.Id;
		Datetime posibleFechaReserva = Datetime.now().addDays(Util_Cita_Servicio.sumarDias(Datetime.now()));
		wo.OTR_DAT_Fecha_Primera_Cita__c = posibleFechaReserva.date();
		//wo.CreatedDate = system.now();
		//wo.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo.OTR_SEL_Rango_Primera_Cita__c = '07';
        wo.OwnerId = System.UserInfo.getUserId();
        wo.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';

		insert wo;
        
        Util_Caso.getIdTipoDeRegistro(Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('Siniestro'), Label.CAS_TIPO_ASISTENCIA_COBERTURA, compania, Label.SINI_ESTADO_NO_ABIERTO);
        Util_Caso.getIdTipoDeRegistro(Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('Siniestro'), Label.CAS_TIPO_ASISTENCIA_COBERTURA, compania, 'Otro');
        Util_Caso.getIdTipoDeRegistro(Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('Siniestro'), Label.CAS_TIPO_ASISTENCIA_COBERTURA, compania2, 'Otro');
        Util_Caso.devolverDireccionTerritorial(caso);
        
        List<WorkOrder> listaOT = new List<WorkOrder>();
        Util_Caso.casosDeOT(listaOT);
        listaOT.add(wo);
        Util_Caso.calcularTotalFacturarCIA(listaOT);
        Util_caso.calcularTotalFacturarCliente(listaOT);
        Util_Caso.calcularTotalFacturarProfesional(listaOT);
        Util_Caso.getListaOTsCaso(caso.Id);
        Util_Caso.getListaPartidasCaso(caso.Id);
        Util_Caso.guardarCaso(caso);
        Util_Caso.crearComentarioCaso(caso.Id, 'comentario');
        Set<Id> setIds = new Set<Id>();
        setIds.add(caso.Id);
        Util_Tarea.getMapaTareasCaso(setIds);
        Util_Presupuesto.getMapaUltPresupCasos(setIds);
        Util_Caso.getMapaSharesCaso(setIds);
        Util_Caso.getMapaPartidasCasos(setIds);
        Util_Orden_Trabajo.getMapaOTsCasosFull(setIds);
        
        
        Map<Id, Case> mapaCasos = new Map<Id, Case>();
        mapaCasos.put(caso.Id, caso);
        Map<Id, WorkOrder> mapaOTs = new Map<Id, WorkOrder>();
        mapaOTs.put(wo.Id, wo);
        Map<Id, WorkOrder> mapaActualizado = new Map<Id, WorkOrder>();
        mapaActualizado.put(wo.Id, wo);
        Util_Caso.heredarDatosCaseOT(mapaCasos, mapaOTs, mapaActualizado);
        
        Test.startTest();
        /*
        Case caso2 = new Case();
        caso2 = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        caso2.CAS_SEL_Encuestador__c = 'Servitelco';
        caso2.CAS_LKP_Compania__c = compania.Id;
        caso2.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso2.CAS_LKP_Procedencia__c = procedencia.Id;
        caso2.CreatedDate = system.now();
        caso2.Status = LABEL.CAS_ESTADO_EN_CURSO;
        caso2.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso2;
        */
        /*
         Case caso3 = new Case();
        caso3 = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        caso3.CAS_SEL_Encuestador__c = 'Servitelco';
        caso3.CAS_LKP_Compania__c = compania.Id;
        caso3.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso3.CAS_LKP_Procedencia__c = procedencia.Id;
        caso3.CreatedDate = system.now();
        caso3.Status = LABEL.CAS_ESTADO_EN_CURSO;
        caso3.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso3;
*/
        Util_Caso.actualizarFechasParo(caso, caso);
        //Util_Caso.actualizarFechasParo(caso3, caso2);
       
        Test.stopTest();
        
        
    }
    
    @isTest public static void util_caso2(){
        Test.startTest();
        Account compania = Util_Tests.crearCuentaCompania('compania', Label.IDE_MEMBERSHIP,'X1234567X');
        compania.type = '01';
		insert compania;
        Account compania2 = Util_Tests.crearCuentaCompania('compania', '1018','X1134567X');
		insert compania2;
        Account cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1334567X');
        cuenta.type = '01';
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert cuenta;
        
        Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
        Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        insert procedencia;
        
        ServiceContract sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id,producto.Id);
        insert sv;
        
        Case caso = new Case();
        caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        caso.CAS_SEL_Encuestador__c = 'Servitelco';
        caso.CAS_LKP_Compania__c = compania.Id;
        caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CreatedDate = system.now();
        caso.Status = '993';
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso;
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '46';
        update caso;
        Util_Caso.devolverDireccionTerritorial(caso);
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '52';
        update caso;
        Util_Caso.devolverDireccionTerritorial(caso);
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '45';
        update caso;
        Util_Caso.devolverDireccionTerritorial(caso);
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '49';
        update caso;
        Util_Caso.devolverDireccionTerritorial(caso);
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '50';
        update caso;
        Util_Caso.devolverDireccionTerritorial(caso);
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '38';
        update caso;
        Util_Caso.devolverDireccionTerritorial(caso);
        Test.stopTest();
    }
        
}