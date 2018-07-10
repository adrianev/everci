/**
 * Clase de Test de la Clase GenerarAlbaranController 
 * 
 */
@isTest
public without sharing class Test_GenerarAlbaranController {

	private static Account cuentaPrincipal {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
	
	private static Account cuentaProfesional {get; set;}
	private static User usuari {get; set;}
	private static ServiceResource profesional {get; set;}

	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X1234567X');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;

		poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaPrincipal.Id, compania.Id, productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		caso.Status = '993';
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
        
         RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
		
		cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('CuentaProf','1020','X1114567X',compania.Id);
        cuentaProfesional.RecordTypeId = rt.Id;
        cuentaProfesional.Name = 'PR123456';
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c='01';
        cuentaProfesional.CUE_CAS_Activado__c=false;
		insert cuentaProfesional;

		cuentaProfesional.CUE_SEL_Estado__c = '02';
		cuentaProfesional.CUE_CAS_Activado__c=true;
		update cuentaProfesional;


		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuari;
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :cuentaProfesional.Id ];
		profesional = Util_Tests.crearRecursoServicio('David','Estanislao',acc1.Id,usuari);
        profesional.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        profesional.RSE_SEL_Gremio__c='01';
		insert profesional;
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('19210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', datetime.newInstance(2018, 02, 21), datetime.newInstance(2018, 02, 24));
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;

		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
	}
	
	/*Test*/
	@isTest static void Test(){
		inicializarVariables();
		test.startTest();
		ApexPages.currentPage().getParameters().put('id',citaServicio.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran = new GenerarAlbaranController(sc);
		albaran.guardarYEnviarAlbaran();
		albaran.volver();
		albaran.firmaCliente();
		albaran.firmaProfesional();
		
		test.stopTest();
	}
	
	/*Test*/
	@isTest  static void Test2(){
		inicializarVariables();
		test.startTest();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran2 = new GenerarAlbaranController(sc);
		
		test.stopTest();
	}
	
	/*Test*/
	@isTest static void Test3(){
		inicializarVariables();
		test.startTest();
		
		Case casoSini = Util_Tests.crearCasoSini(poliza.Id, cuentaPrincipal.Id, compania.Id);
		insert casoSini;
		WorkOrder ordenTrabajo1 = Util_Tests.crearOrdenTrabajo('34210.0','21',tipoTrabajo.Id,casoSini.Id);
		ordenTrabajo1.AccountId = cuentaPrincipal.Id;
		ordenTrabajo1.Status = '002';
		insert ordenTrabajo1;
		datetime fechaInicio = datetime.newInstance(2018, 02, 21);
		datetime fechaVencimiento = datetime.newInstance(2018, 02, 24);
		ServiceAppointment citaServicio1 = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio1.Status = 'Pte. de asignar';
		citaServicio1.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio1;
		ordenTrabajo1.OTR_LKP_Primera_Cita__c = citaServicio1.Id;
		update ordenTrabajo1;
		
		ApexPages.currentPage().getParameters().put('id',citaServicio1.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran3 = new GenerarAlbaranController(sc);
		
		test.stopTest();
	}
	
	/*Test*/
	@isTest (SeeAllData=true)
	static void Test4(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X1234567X');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('compania', '1018yrtruru','X1234567X');
        insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
        tipoProductoCIA.TPR_LKP_Compania__c = compania.Id;
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaPrincipal.Id, compania.Id, productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		caso.Status = '993';
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',compania.Id);
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c='01';
        cuentaProfesional.CUE_CAS_Activado__c=false;
		insert cuentaProfesional;

		cuentaProfesional.CUE_SEL_Estado__c = '02';
		cuentaProfesional.CUE_CAS_Activado__c=true;
		update cuentaProfesional;

		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		usuari = Util_Tests.nuevoUsuario('pruebas2','pruebas2','asdd2@hotmail.com','pruebas2','pruebas2',perfil);
		insert usuari;
        Account cuentaProfesional2 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :cuentaProfesional.Id ];
		profesional = Util_Tests.crearRecursoServicio('David2','Estanislao2',cuentaProfesional.Id,usuari);
        profesional.Name = cuentaProfesional2.CUE_TXT_Identificador__c + '_01_1';
		insert profesional;
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('19210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', datetime.newInstance(2018, 02, 21), datetime.newInstance(2018, 02, 24));
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;

		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		test.startTest();
		
		ordenTrabajo.OTR_DAT_Fecha_Ultima_Cita__c = date.newInstance(2018,04,02);
		ordenTrabajo.OTR_SEL_Rango_Ultima_Cita__c = '07';
		update ordenTrabajo;
		
		citaServicio.Status = 'Asignada';
		update citaServicio;
		citaServicio.Status = 'En curso';
		update citaServicio;
		
		ApexPages.currentPage().getParameters().put('id',citaServicio.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran4 = new GenerarAlbaranController(sc);
		
		test.stopTest();
	}
	
	/*Test*/
	@isTest static void Test5(){
		inicializarVariables();
		test.startTest();
		
		ordenTrabajo.Status = '402';
		update ordenTrabajo;
		
		ApexPages.currentPage().getParameters().put('id',citaServicio.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran5 = new GenerarAlbaranController(sc);
		albaran5.guardarYEnviarAlbaran();
		
		test.stopTest();
	}
    @isTest (SeeAllData=true)
	static void Test41(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X1234567X');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('compania', '1018yrtruru','X1234567X');
        insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
        tipoProductoCIA.TPR_LKP_Compania__c = compania.Id;
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA; 
		ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaPrincipal.Id, compania.Id, productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		caso.Status = '993';
       	caso.CAS_EMA_Solicitud_Email__c = 'albertosolermatas@gmail.com' ;
        caso.CAS_TXT_Nombre__c = 'Alberto';
        caso.CAS_TXT_Apellidos__c = 'Soler';
        caso.CAS_TXT_Apellidos_2__c = ' Muñoz';
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		
		cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','1020','X1114567X',compania.Id);
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c='01';
		cuentaProfesional.CUE_CAS_Activado__c=false;
		insert cuentaProfesional;

		cuentaProfesional.CUE_SEL_Estado__c = '02';
		cuentaProfesional.CUE_CAS_Activado__c=true;
		update cuentaProfesional;

		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		usuari = Util_Tests.nuevoUsuario('pruebas2','pruebas2','asdd2@hotmail.com','pruebas2','pruebas2',perfil);
		insert usuari;
        Account cuentaProfesional2 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :cuentaProfesional.Id ];
		profesional = Util_Tests.crearRecursoServicio('David2','Estanislao2',cuentaProfesional.Id,usuari);
        profesional.Name = cuentaProfesional2.CUE_TXT_Identificador__c + '_01_1';
		insert profesional;
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('19210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', datetime.newInstance(2018, 02, 21), datetime.newInstance(2018, 02, 24));
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;

		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		test.startTest();
		
		ordenTrabajo.OTR_DAT_Fecha_Ultima_Cita__c = date.newInstance(2018,04,02);
		ordenTrabajo.OTR_SEL_Rango_Ultima_Cita__c = '07';
		update ordenTrabajo;
		
		citaServicio.Status = 'Asignada';
		update citaServicio;
		citaServicio.Status = 'En curso';
		update citaServicio;
		
		ApexPages.currentPage().getParameters().put('id',citaServicio.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran5 = new GenerarAlbaranController(sc);
		albaran5.guardarYEnviarAlbaran();
		
		test.stopTest();
	}
	
	/*Test*/
	@isTest static void Test51(){
		inicializarVariables();
		test.startTest();
		
		ordenTrabajo.Status = '402';
		update ordenTrabajo;
		
		ApexPages.currentPage().getParameters().put('id',citaServicio.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran5 = new GenerarAlbaranController(sc);
		albaran5.guardarYEnviarAlbaran();
		
		test.stopTest();
	}

    
    
    
	
	/*Test*/
	@isTest static void Test6(){
		inicializarVariables();
		test.startTest();
		
		caso.CAS_EMA_Solicitud_Email__c = 'prueba@prueba.com';
		caso.CAS_TXT_Nombre__c = 'Maria';
		caso.CAS_TXT_Apellidos__c = 'Perez';
		update caso;
		
		ApexPages.currentPage().getParameters().put('id',citaServicio.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(cuentaPrincipal);
		GenerarAlbaranController albaran6 = new GenerarAlbaranController(sc);
		albaran6.guardarYEnviarAlbaran();
		
		test.stopTest();
	}
}