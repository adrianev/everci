@isTest
public without sharing class Test_CambioEstadoOT{
	
	private static Case casoB2B;
	private static Case casoSini;
	private static WorkOrder ordTbj;
	private static WorkOrder ordTbjInactivo;
    private static User Usuario {get; set;}
	
	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_PROFESIONAL];
		User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;
		Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
		Account cuentaSecundaria = Util_Tests.crearCuentaB2BSec('Alberto2','1080', compania.Id);
        cuentaSecundaria.CUE_TXT_Numero_Documento__c = '89074907R';
        cuentaSecundaria.CUE_SEL_Tipo_Documento__c = 'N';
        insert cuentaSecundaria;
        Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('SeguCaisa - Hogar', '01', compania.Id);
		insert tipoProducto;
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('Segurcaixa1 - HOGAR', '01', tipoProducto.Id);
		insert producto;
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaSecundaria.Id, compania.Id, producto.Id);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.00, 0, 1, 0, 0, compania.Id, '1620334609050', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_Anulacion__c = '02;03';
		procedencia.PROC_CAS_No_Requiere_Albaran__c = true;
		insert procedencia;
		casoB2B = Util_Tests.crearCasoB2B(poliza.Id, compania.Id, compania.Id);
		casoB2B.CAS_LKP_Procedencia__c = procedencia.Id;
		casoSini = Util_Tests.crearCasoSini(poliza.Id,compania.Id,compania.Id);
		casoSini.CAS_LKP_Procedencia__c = procedencia.Id;
		insert casoB2B;
		insert casoSini;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Aplicación de estetica', '02', 120.00);
		insert tipoTrabajo;
		ordTbj = Util_Tests.crearOrdenTrabajo('0010100244', '02', tipoTrabajo.Id, casoB2B.Id);
		ordTbj.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbj.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
 		insert ordTbj;
		
	}
	

	static testMethod void constructorSinId(){
		inicializarVariables();
      
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		Test.setCurrentPage(pageRef);
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		Test.stopTest();

	}
	
	static testMethod void constructorSinCaso(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		Test.setCurrentPage(pageRef);
		delete casoB2B;
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
	}
	
	static testMethod void constructorSinOT(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		Test.setCurrentPage(pageRef);
		delete ordTbj;
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
	}
	
	static testMethod void constructorAnularOTEnEspera(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('anular','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		Test.stopTest();
	}
	
	static testMethod void constructorCerrar(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('cerrar','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		Test.stopTest();
	}
	
	static testMethod void constructorDormir(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('dormir','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		ordTbj.Status = null;
		update ordTbj;
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		Test.stopTest();
	}
	
	static testMethod void cambioEstadoOTAnular(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('anular','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		// Cambio de estado sin introducir comentario
		clase.cambiarEstadoOT();
		// Salta error, se introduce comentario
		clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
		// Cambio estado (anulacion)
		clase.motivoAnulacion = '01';
		// Salta Warning
		clase.cambiarEstadoOT();
		clase.cambiarEstadoOT();
		Test.stopTest();
	}
	
	static testMethod void cambioEstadoOTProfesional(){
		
		Test.startTest();
        Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL];
         User newUser = new User();
		newUser.FirstName = 'Manolo2';
		newUser.LastName = 'tena2';
		newUser.Email = 'manol2o@manolo.com';
		newUser.Alias = 'Manolo2';
		newUser.ProfileId = perfil.Id;
		newUser.Username = ' john784poi2@acme7.com';
		newUser.CommunityNickname = 'pepe2';
		newUser.TimeZoneSidKey = 'Europe/Paris';
		newUser.LocaleSidKey = system.UserInfo.getLocale();
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.LanguageLocaleKey = 'es';

		insert newUser;
		System.runAs(newUser){
            inicializarVariables();
			ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
			PageReference pageRef = Page.CambioEstadoOT;
			pageRef.getParameters().put('id',casoB2B.Id);
			pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
			pageRef.getParameters().put('fase','APERTURA');
			pageRef.getParameters().put('solicitudExistente','true');
			pageRef.getParameters().put('cerrar','true');
			pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
			Test.setCurrentPage(pageRef);
			CambioEstadoOT clase = new CambioEstadoOT(stdc);
			// Cambio de estado sin introducir comentario
			clase.cambiarEstadoOT();
			// Salta error, se introduce comentario
			clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
			// Cambio estado (anulacion)
			clase.motivoAnulacion = '01';
			// Salta Warning
			clase.cambiarEstadoOT();
			clase.cambiarEstadoOT();
		}
		Test.stopTest();
	}
	
	static testMethod void cambioEstadoOTAnularDesdeInactivo(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('anular','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		ordTbj.Status = Label.OTR_ESTADO_INACTIVO;
		update ordTbj;
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		// Cambio de estado sin introducir comentario
		clase.cambiarEstadoOT();
		// Salta error, se introduce comentario
		clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
		// Cambio estado (anulacion)
		clase.motivoAnulacion = '01';
		// Salta Warning
		clase.cambiarEstadoOT();
		clase.cambiarEstadoOT();
		Test.stopTest();
	}
	
	static testMethod void cambioEstadoOTSinAnular(){
		inicializarVariables();
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		ordTbj.Status = Label.OTR_ESTADO_INACTIVO;
		update ordTbj;
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
		clase.estadoNuevoOT = '002';
		Date fecha_despertar = Date.newInstance(2018,03,06);
		clase.ordenTrabajo.OTR_DAT_Fecha_Despertar__c = fecha_despertar;
		// Salta Warning
		clase.cambiarEstadoOT();
		clase.cambiarEstadoOT();
		Test.stopTest();
	}
	
	@isTest (seeAllData=true)
	static void cerrarOT(){
		Baipas.establecerVariableControl();
		Account Company = [SELECT Id FROM Account WHERE CUE_TXT_Identificador__c ='1019'];
		Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('SeguCaisa - Hogar', '01', Company.Id);
        system.debug(tipoProducto + ' TIPOPRODUCTO');
		insert tipoProducto;
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('Segurcaixa1 - HOGAR', '01', tipoProducto.Id);
        List<Producto_CIA__c> testDebug=[SELECT ID FROM Producto_CIA__c];
        for(Producto_CIA__c holiwis:testDebug){
        }
        system.debug(producto + ' prueba');
		insert producto;
        Account cuentaSecundaria = Util_Tests.crearCuentaB2BSec('Alberto2','1080', Company.Id);
        cuentaSecundaria.CUE_TXT_Numero_Documento__c = '89074907R';
        cuentaSecundaria.CUE_SEL_Tipo_Documento__c = 'N';
        insert cuentaSecundaria;
        
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaSecundaria.Id, Company.Id, producto.Id);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.00, 0, 1, 0, 0, company.Id, '1620334609050', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_Anulacion__c = '02;03';
		procedencia.PROC_CAS_No_Requiere_Albaran__c = true;
		insert procedencia;
		casoB2B = Util_Tests.crearCasoB2B(poliza.Id, company.Id, company.Id);
		casoB2B.CAS_LKP_Procedencia__c = procedencia.Id;
		casoSini = Util_Tests.crearCasoSini(poliza.Id,company.Id,company.Id);
		casoSini.CAS_LKP_Procedencia__c = procedencia.Id;
		insert casoB2B;
		casoB2B.RecordTypeId = [select id from RecordType where DeveloperName =: Label.RT_CAS_SINIESTRO.split(':')[1]].Id;       
		insert casoSini;
        update casoB2B;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Aplicación de estetica', '02', 120.00);
		insert tipoTrabajo;
        system.debug(tipoTrabajo + ' albertooooooo1');
		ordTbj = Util_Tests.crearOrdenTrabajo('0010100999', '02', tipoTrabajo.Id, casoB2B.Id);
		ordTbj.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbj.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
		insert ordTbj;
        
        system.debug(ordTbj + ' albertooooooo2');
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
        //pageRef.getParameters().put('anular','false');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
		clase.ordenTrabajo.Status = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
		Datetime fechaInicio = Date.newInstance(2018,12,31);
		Datetime fechaVencimiento = Date.newInstance(2019,12,31);
		List<ServiceAppointment> citas = new List<ServiceAppointment>([SELECT Id, Status FROM ServiceAppointment WHERE ParentRecordId = :clase.ordenTrabajo.Id]);
		for (ServiceAppointment cita : citas){
			cita.Status = Label.CIT_ESTADO_ANULADA;
		}
		update citas;
		WorkOrderLineItem partida = Util_Tests.crearNuevaPartidaTrabajo(clase.ordenTrabajo.Id);
		partida.Status = Label.PAR_ESTADO_ACEPTADA;
		insert partida;
        //clase.cambiarEstadoOT();
		clase.cerrarOrdenDeTrabajo();
        
        
        
		Test.stopTest();
	}
    @isTest
    static void StatusWo(){
        inicializarVariables();
        ordTbj.Status = Label.OTR_ESTADO_PDTE_PRESUP_CIA;
        update ordTbj;
		
        Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
		clase.ordenTrabajo.Status = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
		Datetime fechaInicio = Date.newInstance(2018,12,31);
		Datetime fechaVencimiento = Date.newInstance(2019,12,31);
		WorkOrderLineItem partida = Util_Tests.crearNuevaPartidaTrabajo(clase.ordenTrabajo.Id);
		partida.Status = Label.PAR_ESTADO_ACEPTADA;
		insert partida;
		clase.cerrarOrdenDeTrabajo();
        
        
        
		Test.stopTest();
        
        ordTbj.Status = Label.OTR_ESTADO_INACTIVO_CLIENTE;
        update ordTbj;
        
        CambioEstadoOT clase1 = new CambioEstadoOT(stdc);
        
        
    }
    
    
	
	@isTest (seeAllData=true)
	static void dormirOT(){
		Baipas.establecerVariableControl();
		Account compania = [SELECT Id FROM Account WHERE CUE_TXT_Identificador__c ='1023'];
		Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('SEGURCAIXA - Hogar', '01', compania.Id);
		insert tipoProducto;
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('Segurcaixa - HOGAR', '01', tipoProducto.Id);
		insert producto;
        Account cuentaSecundaria = Util_Tests.crearCuentaB2BSec('Alberto2','1080', compania.Id);
        cuentaSecundaria.CUE_TXT_Numero_Documento__c = '89074907R';
        cuentaSecundaria.CUE_SEL_Tipo_Documento__c = 'N';
        insert cuentaSecundaria;        
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaSecundaria.Id, compania.Id, producto.Id);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.00, 0, 1, 0, 0, compania.Id, '1620334609050', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_Anulacion__c = '02;03';
		procedencia.PROC_CAS_No_Requiere_Albaran__c = true;
		insert procedencia;
		casoB2B = Util_Tests.crearCasoB2B(poliza.Id, compania.Id, compania.Id);
		casoB2B.CAS_LKP_Procedencia__c = procedencia.Id;
		casoSini = Util_Tests.crearCasoSini(poliza.Id,compania.Id,compania.Id);
		casoSini.CAS_LKP_Procedencia__c = procedencia.Id;
		insert casoB2B;
		insert casoSini;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Aplicación de estetica', '02', 120.00);
		insert tipoTrabajo;
		ordTbj = Util_Tests.crearOrdenTrabajo('0010101111', '02', tipoTrabajo.Id, casoB2B.Id);
		ordTbj.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbj.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
        //ordTbj.RecordTypeId = [Select Id from RecordType where DeveloperName = 'OTR_EN_REVISION'].get(0).Id;
		insert ordTbj;
		Test.startTest();
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
		pageRef.getParameters().put('fase','APERTURA');
		pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('dormir','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
		//clase.ordenTrabajo.Status = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
		clase.ordenTrabajo.OTR_DAT_Fecha_Despertar__c = Date.newInstance(2018,03,12);
		Datetime fechaInicio = Date.newInstance(2018,12,31);
		Datetime fechaVencimiento = Date.newInstance(2019,12,31);
		ServiceAppointment cita = Util_Tests.crearCitaServicio('Madrid', 'Espana', '28000', 'Madrid', 'Virgen del Mar', fechaInicio,fechaVencimiento);
		cita.Status = 'Pte. de asignar';
		cita.ParentRecordId = clase.ordenTrabajo.Id;
		insert cita;
		clase.ordenTrabajo.OTR_LKP_Primera_Cita__c = cita.Id;
		//WorkOrderLineItem partida = Util_Tests.crearNuevaPartidaTrabajo(clase.ordenTrabajo.Id);
		//partida.Status = Label.PAR_ESTADO_ACEPTADA;
		//insert partida;
		clase.cambiarEstadoOT();
        clase.cerrarOrdenDeTrabajo();
        clase.seleccionarNuevoEstado();
		Test.stopTest();
	}
    
    
    
    
    
    @isTest (seeAllData=true)
	static void Prueba(){
		Baipas.establecerVariableControl();
		Account compania = [SELECT Id FROM Account WHERE CUE_TXT_Identificador__c ='1023'];
		Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('SEGURCAIXA - Hogar', '01', compania.Id);
		insert tipoProducto;
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('Segurcaixa - HOGAR', '01', tipoProducto.Id);
		insert producto;
        Account cuentaSecundaria = Util_Tests.crearCuentaB2BSec('Alberto2','1080', compania.Id);
        cuentaSecundaria.CUE_TXT_Numero_Documento__c = '89074907R';
        cuentaSecundaria.CUE_SEL_Tipo_Documento__c = 'N';
        insert cuentaSecundaria;
        ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaSecundaria.Id, compania.Id, producto.Id);
        insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.00, 0, 1, 0, 0, compania.Id, '1620334609050', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_Anulacion__c = '02;03';
		procedencia.PROC_CAS_No_Requiere_Albaran__c = true;
		insert procedencia;
		casoB2B = Util_Tests.crearCasoB2B(poliza.Id, compania.Id, compania.Id);
		casoB2B.CAS_LKP_Procedencia__c = procedencia.Id;
		casoSini = Util_Tests.crearCasoSini(poliza.Id,compania.Id,compania.Id);
		casoSini.CAS_LKP_Procedencia__c = procedencia.Id;
		insert casoB2B;
		insert casoSini;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Aplicación de estetica', '02', 120.00);
		insert tipoTrabajo;
		ordTbj = Util_Tests.crearOrdenTrabajo('0010101111', '02', tipoTrabajo.Id, casoB2B.Id);
		ordTbj.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbj.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
        ordTbjInactivo = Util_Tests.crearOrdenTrabajo('0010101211', '02', tipoTrabajo.Id, casoB2B.Id);
        ordTbjInactivo.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbjInactivo.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
        //ordTbj.RecordTypeId = [Select Id from RecordType where DeveloperName = 'OTR_EN_REVISION'].get(0).Id;
		insert ordTbj;
        insert ordTbjInactivo;
        Profile perfil = [select Id from Profile where name =: Label.PERFIL_PROFESIONAL];
        User usuario1 = Util_Tests.nuevoUsuario('PR123456_01_1', '00000001', 'PR123456_01_1@prueba.es', 'PR123456_01_1', 'PR123456_01_1', perfil);
        insert usuario1;
		Test.startTest();
        
        
		ApexPages.StandardController stdc = new ApexPages.StandardController(casoB2B);
		PageReference pageRef = Page.CambioEstadoOT;
		pageRef.getParameters().put('id',casoB2B.Id);
		pageRef.getParameters().put('idOrdenTrabajo',ordTbj.Id);
        pageRef.getParameters().put('idOrdenTrabajo',ordTbjInactivo.Id);
		pageRef.getParameters().put('fase','APERTURA');
        pageRef.getParameters().put('anular','true');
        //pageRef.getParameters().put('perfilUsuario',perfil.Id);
		//pageRef.getParameters().put('solicitudExistente','true');
		pageRef.getParameters().put('retorno','/apex/B2B_Reparable');
		Test.setCurrentPage(pageRef);
        System.runAs(Usuario1){
		CambioEstadoOT clase = new CambioEstadoOT(stdc);
		// Cambio de estado sin introducir comentario
		clase.cambiarEstadoOT();
		// Salta error, se introduce comentario
		clase.nuevoComentario.COT_TXT_Comentario__c = 'Comentario de Test para el cambio de estado';
		// Cambio estado (anulacion)
		clase.motivoAnulacion = '01';
		// Salta Warning
		clase.cambiarEstadoOT();
		clase.cambiarEstadoOT();
		clase.cerrarOrdenDeTrabajo();

 
        
        
        
		Test.stopTest();
        }
	}
    
    
    
    
    
    
}