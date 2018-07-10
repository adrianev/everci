@isTest
private class Test_CierreReclamaciones {
    
    private static Case reclamacion;
	private static Case reclCampos;
    private static Account compania;
    private static ServiceContract poliza;
	private static WorkOrder ordTbj;
    private static Propuesta_de_evento__c evento;
    private static Case reclamacionFake;
    private static Propuesta_de_abono__c propAbono;
    private static User usuari;

	
	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
        Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema'];
        usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuari;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
        Account cuentaSecundaria = Util_Tests.crearCuentaB2BSec('Alberto2','1080', compania.Id);
        cuentaSecundaria.CUE_TXT_Numero_Documento__c = '89074907R';
        cuentaSecundaria.CUE_SEL_Tipo_Documento__c = 'N';
        insert cuentaSecundaria;
		Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('SEGURCAIXA - Hogar', '01', compania.Id);
		insert tipoProducto;
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('Segurcaixa - HOGAR', '01', tipoProducto.Id);
		insert producto;
		
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaSecundaria.Id, compania.Id, producto.Id);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0.00, 0, 1, 0, 0, compania.Id, '1620334609050', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
		procedencia.PROC_SEL_Motivos_Anulacion__c = '02;03';
		procedencia.PROC_CAS_No_Requiere_Albaran__c = true;
		insert procedencia;
		reclamacion = Util_Tests.crearCasoReclamacion(poliza.Id, compania.Id, compania.Id);
		reclamacion.CAS_LKP_Procedencia__c = procedencia.Id;
		insert reclamacion;

        
		
	}
	

	static testMethod void testCierreReclamaciones(){
		inicializarVariables();
		Test.startTest();
		PageReference pageRef = Page.CierreReclamaciones;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',reclamacion.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(reclamacion);
		CierreReclamaciones clase = new CierreReclamaciones(stdc);
		List<SelectOption> estados = clase.getOpcionesEstado();
		reclamacion.Status = Label.CAS_ESTADO_CERRADO_FACTURADO;
        clase.reclCampos.CAS_SEL_Padre_reclamacion__c = '1';
		clase.reclCampos.CAS_SEL_Reclamacion__c = '002';
        clase.reclCampos.CAS_SEL_Comunicador_Recl__c = '003';
		clase.reclCampos.CAS_SEL_Naturaleza__c = '001';
		List<SelectOption> motivos = clase.getOpcionesCierre();
		reclamacion.CAS_SEL_Motivo_de_Cierre__c = '';
		clase.guardar();
		Test.stopTest();

	}
    
    	static testMethod void partidasLLenas(){
		inicializarVariables();
        reclamacion.status = Label.PAR_ESTADO_PENDIENTE;
        update reclamacion;
		Test.startTest();
		PageReference pageRef = Page.CierreReclamaciones;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',reclamacion.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(reclamacion);
		CierreReclamaciones clase = new CierreReclamaciones(stdc);
		List<SelectOption> estados = clase.getOpcionesEstado();
		clase.reclCampos.CAS_SEL_Padre_reclamacion__c = '1';
		clase.reclCampos.CAS_SEL_Reclamacion__c = '001';
		clase.reclCampos.CAS_SEL_Naturaleza__c = '001';
       	system.debug(clase.reclamacion  + ' claseeeeeee');
        WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Aplicación de estetica', '02', 120.00);
		insert tipoTrabajo;
		ordTbj = Util_Tests.crearOrdenTrabajo('0010100244', '02', tipoTrabajo.Id,reclamacion.Id);
		ordTbj.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbj.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
		insert ordTbj;
        WorkOrderLineItem partidaWO = new WorkOrderLineItem();
		partidaWO = Util_Tests.crearNuevaPartidaTrabajo(ordTbj.Id);
        insert partidaWO;
        evento = new Propuesta_de_Evento__c();
		evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
        evento.EV_AB_LKP_Imputar_a_profesional__c = ordTbj.OTR_LKP_Recurso_Servicio__c;
        evento.EV_DIV_Importe_a_imputar_Departamento__c = 100;
		evento.EV_AB_SEL_Descripcion__c = 'E19';
		evento.EV_AB_LKP_Orden_de_Trabajo__c = ordTbj.Id;
		evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
		evento.EV_AB_SEL_Estado__c = '04'; //Diferente a Label.EV_AB_ESTADO_APROBADO and Label.EV_AB_ESTADO_RECHAZADO
		evento.EV_AB_LKP_Caso__c = reclamacion.Id;
            
		insert evento;
		clase.guardar();
		Test.stopTest();
	}
      
      	static testMethod void CamposReclamacion(){
        
     	inicializarVariables();
        reclamacion.status = Label.PAR_ESTADO_PENDIENTE;
        update reclamacion;
        reclamacionFake = new Case();
        reclamacionFake.AccountId = compania.Id;
        reclamacionFake.CAS_LKP_Compania__c = compania.Id;
        insert reclamacionFake;
		Test.startTest();
		PageReference pageRef = Page.CierreReclamaciones;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',reclamacion.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(reclamacion);
		CierreReclamaciones clase = new CierreReclamaciones(stdc);
		List<SelectOption> estados = clase.getOpcionesEstado();
		clase.reclCampos.CAS_SEL_Padre_reclamacion__c = '1';
        clase.reclCampos.CAS_SEL_Conformidad_del_Cliente__c = '';
        clase.reclCampos.CAS_SEL_Conformidad_del_Cliente_2__c = '';
        clase.reclCampos.CAS_SEL_Conformidad_del_Cliente_3__c = '';  
		clase.reclCampos.CAS_SEL_Reclamacion__c = '001';
		clase.reclCampos.CAS_SEL_Naturaleza__c = '001';
       	system.debug(clase.reclamacion  + ' claseeeeeee');
        WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Aplicación de estetica', '02', 120.00);
		insert tipoTrabajo;
		ordTbj = Util_Tests.crearOrdenTrabajo('0010100244', '02', tipoTrabajo.Id,reclamacionFake.Id);
		ordTbj.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
		ordTbj.OTR_TXT_Estado_Anterior__c = Label.OTR_ESTADO_ESPERA_PROF_PEND_TERMINAR;
		insert ordTbj;
        WorkOrderLineItem partidaWO = new WorkOrderLineItem();
		partidaWO = Util_Tests.crearNuevaPartidaTrabajo(ordTbj.Id);
        insert partidaWO;
		clase.guardar();
            
        clase.reclCampos.CAS_SEL_Padre_reclamacion__c = '1';
        clase.reclCampos.CAS_SEL_Conformidad_del_Cliente__c = '1';
        clase.reclCampos.CAS_SEL_Conformidad_del_Cliente_2__c = '1';
        clase.reclCampos.CAS_SEL_Conformidad_del_Cliente_3__c = '1';  
		clase.reclCampos.CAS_SEL_Reclamacion__c = '001';
		clase.reclCampos.CAS_SEL_Naturaleza__c = '001'; 
        clase.reclCampos.CAS_LKP_Responsable_Reclamacion__c = usuari.Id ;      	
        clase.comentario = 'TEST OK Espero que con estos caracteres sea suficiente' ;
 
         clase.guardar();   
            
		Test.stopTest();
        
    }
    
    
    
    
}