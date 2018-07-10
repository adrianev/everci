@isTest
public without sharing class Test_NuevaReclamacion{
	private static Account cuenta {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
    private static Case caso1 {get; set;}
	private static Case casoPrincipal {get; set;}
	private static WorkOrder ot {get; set;}
    private static ServiceResource profesional {get; set;}
	private static AssignedResource recurso {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
    private static User usuario {get; set;}
    private static Account cuentaProfesional {get; set;}

	
	@isTest static void testCrearReclamacionCaso() {
		Test.startTest();
		inicializarVariables();
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		PageReference pageRef = Page.NuevaReclamacion;
		Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('caso',casoPrincipal.Id);
		ApexPages.currentPage().getParameters().put('cuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('gremio','22');
		ApexPages.currentPage().getParameters().put('workorder',caso.CAS_LKP_Recl_Orden_Trabajo__c);
		NuevaReclamacion prueba = new NuevaReclamacion(stdc);
		prueba.guardar();
		prueba.getListaNaturalezasBorrar();
		prueba.getNClaveValor();
		prueba.getNaturalezaClaveValor();
		prueba.getReemplazos();
		Test.stopTest();
	}
    

    @isTest static void testCrearReclamacionCaso1() {
        Test.startTest();
		inicializarVariables();
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        caso.CAS_LKP_Recl_Orden_Trabajo__c = Null;
        caso.ParentId = caso1.id;

        update caso;
        system.debug(caso + 'casooooooooooooooooooooooooo');
        ApexPages.currentPage().getParameters().put('caso',casoPrincipal.Id);
		ApexPages.currentPage().getParameters().put('cuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('gremio','22');
		ApexPages.currentPage().getParameters().put('workorder',caso.CAS_LKP_Recl_Orden_Trabajo__c);
		NuevaReclamacion prueba = new NuevaReclamacion(stdc);
		prueba.guardar();
		prueba.getListaNaturalezasBorrar();
		prueba.getNClaveValor();
		prueba.getNaturalezaClaveValor();
		prueba.getReemplazos();

        
        



		Test.stopTest();        
        
        
        
        
    }
     @isTest static void testCrearReclamacionCaso2() {
        Test.startTest();
		inicializarVariables();
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        caso.ParentId = caso1.id;
       	caso.CAS_SEL_Gremio_Principal__c = '';
        update caso;
        system.debug(caso + 'casooooooooooooooooooooooooo');
        ApexPages.currentPage().getParameters().put('caso',casoPrincipal.Id);
		ApexPages.currentPage().getParameters().put('cuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('gremio','22');
		ApexPages.currentPage().getParameters().put('workorder',caso.CAS_LKP_Recl_Orden_Trabajo__c);
		NuevaReclamacion prueba = new NuevaReclamacion(stdc);
		prueba.guardar();
		prueba.getListaNaturalezasBorrar();
		prueba.getNClaveValor();
		prueba.getNaturalezaClaveValor();
		prueba.getReemplazos();

        
        



		Test.stopTest();        
        
        
        
        
    }
    
     @isTest static void testCrearReclamacionCaso3() {
        Test.startTest();
		inicializarVariables();
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
        caso.ParentId = caso1.id;
       	caso.CAS_SEL_Gremio_Principal__c = '22';
        caso.CAS_SEL_Requiere_el_mismo_profesional__c = '';
        update caso;
        system.debug(caso + 'casooooooooooooooooooooooooo');
        ApexPages.currentPage().getParameters().put('caso',casoPrincipal.Id);
		ApexPages.currentPage().getParameters().put('cuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('gremio','22');
		ApexPages.currentPage().getParameters().put('workorder',caso.CAS_LKP_Recl_Orden_Trabajo__c);
		NuevaReclamacion prueba = new NuevaReclamacion(stdc);
		prueba.guardar();
		prueba.getListaNaturalezasBorrar();
		prueba.getNClaveValor();
		prueba.getNaturalezaClaveValor();
		prueba.getReemplazos();

        
        



		Test.stopTest();        
        
        
        
        
    }
    
  @isTest static void testCrearReclamacionCaso4() {
        Test.startTest();
		inicializarVariables();
        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		caso.CAS_DAT_Fecha_Vencimiento__c = System.today().addMonths(4);
        update caso;
        system.debug(caso + 'casooooooooooooooooooooooooo');
        ApexPages.currentPage().getParameters().put('caso',casoPrincipal.Id);
		ApexPages.currentPage().getParameters().put('cuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('gremio','22');
		ApexPages.currentPage().getParameters().put('workorder',caso.CAS_LKP_Recl_Orden_Trabajo__c);
		NuevaReclamacion prueba = new NuevaReclamacion(stdc);
		prueba.guardar();
		prueba.getListaNaturalezasBorrar();
		prueba.getNClaveValor();
		prueba.getNaturalezaClaveValor();
		prueba.getReemplazos();

        
        



		Test.stopTest();        
        
        
        
        
    }   
     @isTest static void testCrearReclamacionCaso5() {
        Test.startTest();
		inicializarVariables();


        ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
         //caso.Status = '801';

         //caso.CAS_SEL_Estado_Expediente__c = '01';
         //caso.CAS_SEL_Naturaleza__c = '042';
         //update caso;

          //caso.CAS_SEL_Estado_Expediente__c = Condition;

        system.debug(caso + 'casooooooooooooooooooooooooo');
        ApexPages.currentPage().getParameters().put('caso',casoPrincipal.Id);
		ApexPages.currentPage().getParameters().put('cuenta',cuenta.Id);
		ApexPages.currentPage().getParameters().put('gremio','22');
		ApexPages.currentPage().getParameters().put('workorder',caso.CAS_LKP_Recl_Orden_Trabajo__c);
		NuevaReclamacion prueba = new NuevaReclamacion(stdc);
		prueba.guardar();
		prueba.getListaNaturalezasBorrar();
		prueba.getNClaveValor();
		prueba.getNaturalezaClaveValor();
		prueba.getReemplazos();

        
        



		Test.stopTest();        
    
    
        
    
    
            
    
    
    
     }
    
    
    
	
	private static void inicializarVariables() {
        
        
        
		Baipas.establecerVariableControl();
        
        
        
		List<Account> listaCuentas = new List<Account>();
		//cuenta = Util_Tests.crearCuentaAsegurado('Asegurado','19783886E','aseguradoExample@gmail.es','12345678A','Paco','Fernadez','Lopez');
		Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1018','X1234567X');
		insert cuentaPrincipal;
        cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','PRX1111567X','X1111567X',cuentaPrincipal.Id);
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
		insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;

		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1019',cuentaPrincipal.Id,'X1134567X');
		Account compania = Util_Tests.crearCuentaCompania('SegurCaixa','1023','X1114567X');
		listaCuentas.add(cuenta);
		listaCuentas.add(compania);
		insert listaCuentas;

		Tipo_Producto_CIA__c tipoProd = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProd;
		Producto_CIA__c prod = Util_Tests.crearProductoCIA('KIT 107','12345678', tipoProd.Id);
		insert prod;
		Poblacion__c pobl =  Util_Tests.crearPoblacion('Madrid','28');
		insert pobl;
		poliza = Util_Tests.crearPolizaContrato('2277393', compania.Id, cuenta.Id,prod.Id);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0,0,0,0,0,cuentaPrincipal.Id,'101444',Label.PROCEDENCIA_SERVICIO_B2C);
		procedencia.PROC_SEL_Gremios_Disp__c = '02';
		insert procedencia;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21',2.00);
		tipoTrabajo.TDT_SEL_Categoria__c = '02';
		insert tipoTrabajo;
        caso1 = Util_Tests.crearCasoB2B(poliza.Id,cuenta.Id,compania.Id);
        insert caso1;
		caso = Util_Tests.crearCasoB2B(poliza.Id,cuenta.Id,compania.Id);
		caso.CAS_SEL_Gremio_Principal__c = '21';
		caso.CAS_LKP_Procedencia__c = procedencia.Id;
		caso.CAS_SEL_Requiere_profesional__c = '01';
        insert caso;
		casoPrincipal = Util_Tests.crearCasoB2B(poliza.Id,cuenta.Id,compania.Id);
		insert casoPrincipal;
		Contact contacto = Util_Tests.crearContacto('Ruben','Gomez',cuenta.Id,'55558888');
		contacto.CON_CAS_Contacto_principal__c  = false;
		insert contacto;
		Contact contacto2 = Util_Tests.crearContacto('Sergio','Manzano',cuenta.Id,'55558878');
		contacto.CON_CAS_Contacto_principal__c  = true;
		insert contacto2;
		ot = Util_Tests.crearOrdenTrabajo('000000','21',tipoTrabajo.Id,caso.Id);
		insert ot;
		caso.CAS_LKP_Recl_Orden_Trabajo__c = ot.Id;
		update caso;
        
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

		Poblacion__c poblacion = new Poblacion__c();
		poblacion.Name = 'MADRID';
		poblacion.POB_SEL_Provincia__c = '28';
		poblacion.POB_TXT_Identificador__c = '28#MADRID';

		//insert poblacion;


		ServiceTerritory st = new ServiceTerritory();
		st.IsActive = true;
		st.Name = '28015 MADRID';
		st.PostalCode = '28015';
		st.TDS_TXT_Identificador__c = '28015#MADRID';
		st.OperatingHoursId = oh.Id;
		//st.TDS_LKP_Poblacion__c = poblacion.Id; 

		insert st;

         
        
        ServiceResource sr = new ServiceResource();
		sr.RSE_LKP_Cuenta__c = cuentaProfesional.Id;
		sr.Name = cuentaProfesional.CUE_TXT_Identificador__c + '_01_2';
	
		sr.RelatedRecordId = system.UserInfo.getUserId();
		sr.RSE_TXT_Codigo_Recurso__c = '1242141';
		sr.IsCapacityBased = true;
		sr.IsActive = true;
		sr.RSE_SEL_Gremio__c='01';

		insert sr;
      
        
        WorkOrder wo2 = new WorkOrder();
		wo2.AccountId = cuenta.Id;
		wo2.City = 'Madrid';
		wo2.StartDate = system.now();
		wo2.Duration = 2.0;
		wo2.DurationType = 'Hours';
		wo2.Latitude = 40.48023673004623;
		wo2.Longitude = -3.6690412312805356;
		wo2.WorkTypeId = wt.Id;
		wo2.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516809815817';
		wo2.ServiceTerritoryId = st.Id;
		wo2.CreatedDate = system.now();
		wo2.OTR_DAT_Fecha_Primera_Cita__c = Date.today();
		wo2.OTR_SEL_Rango_Primera_Cita__c = '07';
        wo2.OwnerId = System.UserInfo.getUserId();
        wo2.OTR_SEL_Motivos_de_Rechazo_de_Albaran__c = '09';
		wo2.CaseId = caso.Id;
        Datetime posibleFechaReserva = Datetime.now().addDays(Util_Cita_Servicio.sumarDias(Datetime.now()));
		wo2.OTR_DAT_Fecha_Primera_Cita__c = posibleFechaReserva.date();
		wo2.OTR_SEL_Rango_Primera_Cita__c = '07';
        wo2.OTR_LKP_Recurso_Servicio__c = sr.id;
        
  
        
        
		wo2.ParentWorkOrderId = ot.Id;
		
        //listaOTs.add(wo2);
        insert wo2;
        
        
 
        
          Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;
        
        
        
        
        
        datetime mydate = system.today() + 1;
        datetime newDate = mydate.addHours(2);
        //Datetime myDateTime = Datetime.newInstance(2018, 02, 19);
        Datetime myDateTime = Datetime.newInstance(2018, 03,06,12,10,10);
		Datetime dueDate = myDateTime.addDays(2);
        //Datetime arrivalDate = myDateTime.addDays(-2);
        Datetime arrivalDate = myDateTime;
        Datetime arrivalStartDate = arrivalDate.addDays(-15); 
        
        citaServicio = Util_Tests.crearCitaServicio('Madrid','España','','','',myDateTime,dueDate);
	   
        
        citaServicio.CreatedById = system.UserInfo.getUserId();
        citaServicio.ArrivalWindowEndTime = arrivalDate;
        citaServicio.ArrivalWindowStartTime = arrivalDate;
        //citaServicio.FSL__Auto_Schedule__c = true;
        citaServicio.CSE_CAS_Asignada__c = false;
        citaServicio.CSE_CAS_Asignar_como_Urgencias__c = false;
        citaServicio.CSE_CAS_Asignar_territorio_prim_no_franq__c = false;
        citaServicio.CSE_CAS_Asignar_Como_Franquiciado__c = false;
        citaServicio.CSE_CAS_Asignar_Mizad__c = false;
        citaServicio.CSE_CAS_Comprobado_Horario__c = false;
        citaServicio.CSE_CAS_Crear_cita_app__c = false;
        citaServicio.CSE_CAS_Urgente__c = false;
        citaServicio.CSE_NUM_Numero_de_Ofrecimientos__c = 1.0;
        citaServicio.Duration = 2;
        citaServicio.DurationType = 'Hours';
        citaServicio.FSL__Auto_Schedule__c = false;
        citaServicio.FSL__Emergency__c = false;
        citaServicio.FSL__InJeopardy__c = false;
        citaServicio.FSL__InternalSLRGeolocation__Latitude__s = 40.381038;
        citaServicio.FSL__InternalSLRGeolocation__Longitude__s = 	-3.734841;
        citaServicio.FSL__IsFillInCandidate__c = true;
        citaServicio.FSL__IsMultiDay__c = false;
        citaServicio.FSL__Pinned__c = false;
        citaServicio.FSL__Prevent_Geocoding_For_Chatter_Actions__c = false;
        citaServicio.FSL__Same_Day__c = false;
        citaServicio.FSL__Same_Resource__c = false;
        //citaServicio.FSL__Schedule_Mode__c = 'Automatic';
        citaServicio.FSL__UpdatedByOptimization__c = false;
        citaServicio.FSL__Virtual_Service_For_Chatter_Action__c = false;
        citaServicio.GeocodeAccuracy = 'Zip';
        citaServicio.Latitude = 40.38096;
        citaServicio.Longitude = -3.73376;
        citaServicio.CSE_DAT_Fecha_Proxima_Programacion__c = system.today() +2;
        citaServicio.CSE_DAT_Fecha_Ultima_Programacion__c = system.today() +1;
        citaServicio.status = 'Scheduled';
        citaServicio.ParentRecordId = wo2.ParentWorkOrderId; 
        citaServicio.SchedStartTime = system.today() +2;
        citaServicio.SchedEndTime = system.today() +6;
       
        

			
        
            
        
        insert citaServicio;
        
                recurso = Util_Tests.asignarRecurso(citaServicio, sr);
        recurso.FSL__EstimatedTravelDistanceFrom__c = 100.21;
        recurso.FSL__EstimatedTravelDistanceTo__c = 299.21;
        recurso.FSL__EstimatedTravelTimeFrom__c = 198.21;
        recurso.FSL__UpdatedByOptimization__c = true;
//wo2.ParentWorkOrderId = citaservicio.ParentRecordId;
        //update wo2;
        
        
       

  

        insert recurso;

        
        
        
        


        
        
        
        
        
		/*List<ServiceAppointment> listCit = [SELECT Id,ParentRecordId FROM ServiceAppointment WHERE ParentRecordId = :ot.Id];
		system.debug('cita creada automaticamente al crear un workorder '+listCit);
		delete listCit;
		FSL__Scheduling_Policy__c scheduling = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		insert scheduling;
		OperatingHours horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
        insert horaFuncionamiento;
        ServiceTerritory territorioServicio = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
        territorioServicio.IsActive = true;
        insert territorioServicio;
		Datetime fechaInicio = datetime.newInstance(2018, 12, 31);
		Datetime fechaVencimiento = datetime.newInstance(2019, 12, 31);
		Datetime mydate = system.today() + 1;
        Datetime newDate = mydate.addHours(2);
        Datetime myDateTime = Datetime.newInstance(2018, 03,06,12,10,10);
		Datetime dueDate = myDateTime.addDays(2);
        Datetime arrivalDate = myDateTime;
        Datetime arrivalStartDate = arrivalDate.addDays(-15);
		ServiceAppointment cita = Util_Tests.crearCitaServicio('Madrid','Espana','28000','Espana','Virgen de la Cabeza',fechaInicio,fechaVencimiento);
		cita.ParentRecordId = ot.Id;
		cita.CreatedById = system.UserInfo.getUserId();
        cita.ArrivalWindowEndTime = arrivalDate;
        cita.ArrivalWindowStartTime = arrivalDate;
        cita.CSE_CAS_Asignada__c = false;
        cita.CSE_CAS_Asignar_como_Urgencias__c = false;
        cita.CSE_CAS_Asignar_territorio_prim_no_franq__c = false;
        cita.CSE_CAS_Asignar_Como_Franquiciado__c = false;
        cita.CSE_CAS_Asignar_Mizad__c = false;
        cita.CSE_CAS_Comprobado_Horario__c = false;
        cita.CSE_CAS_Crear_cita_app__c = false;
        cita.CSE_CAS_Urgente__c = false;
        cita.CSE_NUM_Numero_de_Ofrecimientos__c = 1.0;
        cita.Duration = 2;
        cita.DurationType = 'Hours';
        cita.FSL__Auto_Schedule__c = false;
        cita.FSL__Emergency__c = false;
        cita.FSL__InJeopardy__c = false;
        cita.FSL__InternalSLRGeolocation__Latitude__s = 40.381038;
        cita.FSL__InternalSLRGeolocation__Longitude__s = 	-3.734841;
        cita.FSL__IsFillInCandidate__c = true;
        cita.FSL__IsMultiDay__c = false;
        cita.FSL__Pinned__c = false;
        cita.FSL__Prevent_Geocoding_For_Chatter_Actions__c = false;
        cita.FSL__Same_Day__c = false;
        cita.FSL__Same_Resource__c = false;
        cita.FSL__Schedule_Mode__c = 'Automatic';
        cita.FSL__Scheduling_Policy_Used__c = scheduling.Id;
        cita.FSL__UpdatedByOptimization__c = false;
        cita.FSL__Virtual_Service_For_Chatter_Action__c = false;
        cita.GeocodeAccuracy = 'Zip';
        cita.Latitude = 40.38096;
        cita.Longitude = -3.73376;
        cita.CSE_DAT_Fecha_Proxima_Programacion__c = system.today() +2;
        cita.CSE_DAT_Fecha_Ultima_Programacion__c = system.today() +1;
        cita.status = Label.CIT_ESTADO_PTE_ASIGNAR;
        cita.SchedStartTime = arrivalStartDate;
        cita.SchedEndTime = arrivalDate;
        cita.ServiceTerritoryId = territorioServicio.Id;
		insert cita;
		Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_GESTOR_FRONT_TRAMITACION];
		User usuario = Util_Tests.nuevoUsuario('Perez','Alias','correo@mail.com','Arturo','Artu',perfil);
		insert usuario;
		ServiceResource recursoServicio = Util_Tests.crearRecursoServicio('Recurso Prueba','1234',cuentaPrincipal.Id,usuario);
		recursoServicio.isActive = true;
		insert recursoServicio;
		Account cuentaProfesional = Util_Tests.crearCuentaB2BPpal('CuentaProf','1024','X1111111X');
		insert cuentaProfesional;
		//Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Administrador IT'];
        //User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        //insert usuario;
        OperatingHours horasOperacion = Util_Tests.crearHoraFuncionamiento('Horas Funcion','Europe/Paris');
        insert horasOperacion;
        ServiceTerritory territorio = Util_Tests.crearTerritorioServicio('Territorio',horasOperacion.Id,'01002');
        territorio.isActive = true;
        insert territorio;
        //ServiceResource recursoServicio = Util_Tests.crearRecursoServicio('Recurso Prueba','1234',cuentaProfesional.Id,usuario);
        recursoServicio.isActive = true;
        //insert recursoServicio;
        Datetime fecha = Datetime.newInstance(2018,03,05);
        ServiceTerritoryMember miembro = Util_Tests.crearMiembroTerritorioServicio(recursoServicio,territorio,'S',fecha);
        insert miembro;
		AssignedResource recursoAsignado = Util_Tests.asignarRecurso(cita,recursoServicio);
		insert recursoAsignado;*/
	}
}