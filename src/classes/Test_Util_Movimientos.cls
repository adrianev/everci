@isTest
public without sharing class Test_Util_Movimientos {

    static testMethod void util_Movimientos(){
        Test.startTest();
        Baipas.establecerVariableControl();
        Account compania = Util_Tests.crearCuentaCompania('compania', '1042','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
        
		Account cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		cuenta.Type = Label.CUE_TIPO_CONTABLE;
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert cuenta;
        
		Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		Producto_CIA__c producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		producto.PRD_TXT_Cod_Producto__c = '12345678\\|234';
		insert producto;
        
		ServiceContract sv = Util_Tests.crearPolizaContrato('1234', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        
        Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        Case casoParent = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
        insert casoParent;
        

        Case caso = Util_Tests.crearCasoConClienteContable(sv.Id, cuenta.Id, compania.Id, cuenta.Id);
		caso.CAS_SEL_Encuestador__c = 'Servitelco';
		caso.CAS_LKP_Compania__c = compania.Id;
		caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CreatedDate = system.now();
        caso.Status = '993';
        caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);

        insert caso;
        caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_VAL_PER;
        caso.CAS_CAS_Informe_Definitivo_Recibido__c = true;
        caso.CAS_DIV_Importe_Total__c = 45.00;
        caso.CAS_CAS_Requiere_Perito__c = true;
        caso.Subject = 'PRUEBA APERTURA';
        caso.ParentId = casoParent.Id;
        update caso;
        Contact contacto = Util_Tests.crearContacto('Manolo','García Serrano',cuenta.Id,'43256');
		contacto.Phone = '657753457';
		contacto.HomePhone = '988888888';
		insert contacto;
		Contacto_telefonico__c contel = new Contacto_telefonico__c();
		contel.CTF_LKP_Caso__c = caso.Id;
		contel.CTF_SEL_Tipo_Relacion__c = Label.SINI_TIPOCONTACT_ASEG;
		contel.CTF_LKP_contacto__c = contacto.Id;
        contel.CTF_LKP_Poliza_Contrato__c = sv.Id;
		insert contel;
		System.Debug('Primera entrada');
        Util_Movimientos.compruebaEnviable(caso.Id, compania.CUE_TXT_Identificador__c, '1');
        caso.CAS_CAS_Requiere_Perito__c = true;
        update caso;
		// [INI] Siguientes pruebas:
		Baipas.establecerVariableControl();
		WorkType wt = Util_Tests.crearTipoTrabajo('Tipo Trabajo','07',10);
		insert wt;
		WorkOrder wo = Util_Tests.crearOrdenTrabajo('7','07',wt.Id,caso.Id);
		insert wo;
		Perjudicado_Siniestro__c persin = new Perjudicado_Siniestro__c();
		persin.PRJ_LKP_Siniestro__c = caso.Id;
		insert persin;
		Baipas.deshabilitarVariableControl();
		System.Debug('2a entrada');
		Util_Movimientos.compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'1',wo.Id);
		Util_Movimientos.ParametrosPB paramPB = new Util_Movimientos.ParametrosPB();
		paramPB.casoIdPB = caso.Id;
		paramPB.CIAIdPB = compania.CUE_TXT_Identificador__c;
		paramPB.accionPB = '1';
		paramPB.WOIdPB = wo.Id;
		List<Util_Movimientos.ParametrosPB> listaParamPB = new List<Util_Movimientos.ParametrosPB>();
		listaParamPB.add(paramPB);
		System.Debug('3a entrada');
		caso.RecordTypeId= Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
		update caso;
		Util_Movimientos.compruebaEnviablePB(listaParamPB);
		Baipas.deshabilitarVariableControl();
		// [FIN] Siguientes pruebas.
    }
}