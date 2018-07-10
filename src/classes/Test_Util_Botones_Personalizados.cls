@isTest
public without sharing class Test_Util_Botones_Personalizados{
    
	private static Account compania {get; set;}
	private static Account cuentaPrincipal {get; set;}
	private static Account cuenta {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkType tipoTrabajoPadre {get; set;}
	private static WorkOrder ordenTrabajoPadre {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static WorkOrder ordenTrabajoBorrar {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	private static ServiceReport albaran {get; set;}
	private static WorkOrderLineItem partidaPadre {get; set;}
	private static WorkOrderLineItem partidaHija {get; set;}
	private static ServiceResource profesional {get; set;}
	private static User usuario {get; set;}
	private static Comentario_Orden_de_Trabajo__c comentario {get; set;}

	private static void inicializarVariables(){
		List<Account> listaCuentas = new List<Account>();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','U0241731I');
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1019','D69133874');
		insert cuentaPrincipal;
		Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','PR123456','B32158032',null);
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.Id;
        cuentaProfesional.Type = '01';
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;
        Account cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','1021',cuentaPrincipal.Id,'X1111567X');
        insert cuenta;
        cuenta.CUE_SEL_Estado__c = '02';
        update cuenta;
		listaCuentas.add(compania);
		insert listaCuentas;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuentaProfesional.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaProfesional.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;	
		ordenTrabajoPadre = Util_Tests.crearOrdenTrabajo('18210.0','22',tipoTrabajo.Id,caso.Id);
		ordenTrabajoPadre.AccountId = cuenta.Id;
		insert ordenTrabajoPadre;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('17210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuenta.Id;
		ordenTrabajo.ParentWorkOrderId = ordenTrabajoPadre.Id;
		insert ordenTrabajo;
		ordenTrabajoBorrar = Util_Tests.crearOrdenTrabajo('16210.0','22',tipoTrabajo.Id,caso.Id);
		ordenTrabajoBorrar.AccountId = cuenta.Id;
		insert ordenTrabajoBorrar;
		partidaPadre = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajoPadre.Id);
		insert partidaPadre;
		partidaHija = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
		insert partidaHija;
		Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Gestor Front/Tramitacion'];
        usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;
        profesional = Util_Tests.crearRecursoServicio('David','Estanislao',cuentaProfesional.Id,usuario);
        profesional.Name = cuentaProfesional.CUE_TXT_Identificador__c + '_01_1';
        profesional.IsActive =  true;
        insert profesional;
        datetime fechaInicio = datetime.newInstance(2018, 12, 31);
		datetime fechaVencimiento = datetime.newInstance(2019, 12, 31);
		citaServicio = Util_Tests.crearCitaServicio('Madrid', 'Espana', '28000', 'Espana', 'Virgen de la Cabeza', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = profesional.Id;
		update ordenTrabajo;
		comentario = Util_Tests.crearComentarioOT('Esta pasando por aquí', ordenTrabajo.Id);
		comentario.COT_LKP_Orden_de_trabajo__c = ordenTrabajo.ParentWorkOrderId;
		insert comentario;
	}

	@isTest static void testUtilBotonesPersonalizados(){
		Test.startTest();
		Baipas.establecerVariableControl();
		inicializarVariables();
		Id revision = Util_Botones_Personalizados.cogerRevision(ordenTrabajo);
		String Cita = Util_Botones_Personalizados.clonarCita(ordenTrabajo.Id);
		Id woClon = Util_Botones_Personalizados.clonarOT(ordenTrabajo);
		Id woDel = Util_Botones_Personalizados.eliminarOT(ordenTrabajoBorrar);
		//Id woAce = Util_Botones_Personalizados.aceptarOT(ordenTrabajo);
		Boolean error = Util_Botones_Personalizados.asignarPreferencias(ordenTrabajo.Id, woClon, true);
		Id TipoRegistro = Util_Botones_Personalizados.getRTIdbyDevNameBoton(Label.RT_OTR_EN_REVISION);	
		Baipas.ejecutarTrigger();
		Test.stopTest();
	}
    
}