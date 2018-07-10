@isTest
public without sharing class Test_Batch_actualizar_evento_E21 {

    private static Account compania;
	private static Account cuentaPrincipal;
	private static Account cuenta;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCIA;
	private static ServiceContract poliza;
	private static Case caso;
	private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo;
    private static User usuario;
     
    static void setup() {
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',compania.Id,'X1114567X');
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('NamePoliza', compania.Id, cuenta.Id, productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
    
        Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',compania.Id);
        cuentaProfesional.CUE_LKP_Cuenta_principal__c = Null;
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = compania.Id;
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;
        
        Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
        usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;
        
        Account cuentaProfUp = [SELECT Id, Name, CUE_TXT_Identificador__c FROM Account WHERE Id=:cuentaProfesional.Id];
        ServiceResource sr = Util_Tests.crearRecursoServicio('David','Estanislao',cuentaProfUp.Id,usuario);
        sr.Name = cuentaProfUp.CUE_TXT_Identificador__c + '_01_1';
        insert sr;
        
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		ordenTrabajo.OTR_DAT_Fecha_cambio_estado__c = system.now();
		ordenTrabajo.OTR_NUM_Horas_verde__c = 0;
		ordenTrabajo.OTR_NUM_Horas_amarillo__c = 0;
		ordenTrabajo.AccountId = cuenta.Id;
		ordenTrabajo.Status = '999';
        ordenTrabajo.OTR_LKP_Recurso_Servicio__c = sr.Id;
		insert ordenTrabajo;
		Baipas.deshabilitarVariableControl();
    }
    
    static testmethod void test(){
        Test.startTest();
        setup();
		Datetime fCambioSemaforo = ordenTrabajo.OTR_DAT_Fecha_cambio_estado__c.addHours(ordenTrabajo.OTR_NUM_Horas_verde__c.intValue() + ordenTrabajo.OTR_NUM_Horas_amarillo__c.intValue());
        Batch_actualizar_evento_E21 obj = new Batch_actualizar_evento_E21(ordenTrabajo, fCambioSemaforo);
        Integer minutos = fCambioSemaforo.minute();
		integer horas = fCambioSemaforo.hour();
		integer anyo = fCambioSemaforo.year();
		String sch = '0' + ' ' + minutos + ' ' + horas + ' ' + '*' + ' ' + '*' + ' ' + '?' + ' ' + anyo;
        system.schedule('E21_'+ordenTrabajo.Id, sch, obj);
            
        Test.stopTest();
    }
    
    static testmethod void test2(){
        Test.startTest();
        setup();
 		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
		evento.EV_AB_LKP_Imputar_a_profesional__c = ordenTrabajo.OTR_LKP_Recurso_Servicio__c;
		evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
		evento.EV_AB_SEL_Descripcion__c = 'E21';
		evento.EV_AB_LKP_Orden_de_Trabajo__c = ordenTrabajo.Id;
		evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
		evento.EV_AB_SEL_Estado__c = '02';
		evento.EV_AB_LKP_Caso__c = ordenTrabajo.CaseId;
        evento.EV_DIV_Importe_a_imputar_Departamento__c = 1000.26;
		evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;
		evento.EV_AB_DIV_Importe_profesional__c = 1000.0;
        evento.EV_AB_LKP_Imputar_a_gestor__c = usuario.Id;
        //evento.EV_AB_LKP_Liquidar_a_prof__c = ordenTrabajo.OTR_LKP_Recurso_Servicio__c;

		insert evento;
	
		Datetime fCambioSemaforo = ordenTrabajo.OTR_DAT_Fecha_cambio_estado__c.addHours(ordenTrabajo.OTR_NUM_Horas_verde__c.intValue() + ordenTrabajo.OTR_NUM_Horas_amarillo__c.intValue());
        Batch_actualizar_evento_E21 obj = new Batch_actualizar_evento_E21(ordenTrabajo, fCambioSemaforo);
        Integer minutos = fCambioSemaforo.minute();
		integer horas = fCambioSemaforo.hour();
		integer anyo = fCambioSemaforo.year();
		String sch = '0' + ' ' + minutos + ' ' + horas + ' ' + '*' + ' ' + '*' + ' ' + '?' + ' ' + anyo;
        system.schedule('E21_'+ordenTrabajo.Id, sch, obj);
            
        Test.stopTest();
    }
    
}