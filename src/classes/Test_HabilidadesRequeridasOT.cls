@isTest
public without sharing class Test_HabilidadesRequeridasOT extends TestSetup {
    public static HabilidadesRequeridasOT habRequeridasOT  {get; set;} 
    
    @testSetup
	public static void test(){
		Baipas.establecerVariableControl();
		Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel', '2018','miguel@gmail.es', '99088976P','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		asegurado.CUE_LKP_Cuenta_Principal__c = compania.id;
        insert asegurado;
        Tipo_Producto_CIA__c tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		Producto_CIA__c productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		ServiceContract poliza = Util_tests.crearPolizaContrato('9729187', compania.id, asegurado.id, productoCIA.id);
		insert poliza;
		
		Case caso = Util_Tests.crearCasoB2B(poliza.Id, asegurado.Id, compania.Id);
		insert caso;
		/*Contract contrato = Util_Tests.crearContrato(asegurado.Id,'contrato');
		insert contrato;
		Linea_Contrato__c lineaCon = Util_Tests.crearLineaContrato(contrato.Id,3,'21', Label.RT_LIN_CON_CORRECTIVO);
		insert lineaCon;
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccion = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(asegurado.Id, lineaCon.Id, 3);
		insert direccion;*/
		Presupuesto__c presupuesto = Util_Tests.crearPresupuesto('100', caso.Id,1);
		insert presupuesto;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '02', 20.0);
		insert tipoTrabajo;
		WorkOrder ordenTrabajo = Util_Tests.crearOrdenTrabajo('19410.0', '02', tipoTrabajo.Id, caso.Id);
		ordenTrabajo.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;
		Date primeraCita = Date.newInstance(2018, 12, 31);
		ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c = primeraCita;
		//ordenTrabajo.OTR_CAS_Urgente__c = true;
		ordenTrabajo.AccountId = asegurado.Id;
		insert ordenTrabajo;
		datetime fechaInicio = datetime.newInstance(2018, 12, 31);
		datetime fechaVencimiento = datetime.newInstance(2019, 12, 31);
		ServiceAppointment citaServicio = Util_Tests.crearCitaServicio('Madrid', 'Espana', '28000', 'Espana', 'Virgen de la Cabeza', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
		caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
		//caso.CAS_CAS_Supera_Limite_Actuacion__c = true;
		//caso.Type = Label.B2B_TIPO_CORRECTIVO;
		update caso;
		//Skill habilidad = [SELECT Description,DeveloperName,MasterLabel FROM Skill WHERE DeveloperName = 'E_02_4'];
		List<Skill> habilidadList = new List<Skill>([SELECT Description,DeveloperName,MasterLabel FROM Skill]);
		SkillRequirement requisito = Util_Tests.crearSkillRequirement(ordenTrabajo.Id,habilidadList.get(0).Id, 1);
		insert requisito;
	}
	
	@isTest static void testHabilidadesRequeridasOT(){
		PageReference pageRef = Page.HabilidadesRequeridasOT;
		Test.setCurrentPage(pageRef);
		ServiceContract poliza = Util_Tests.getServiceContractByName('9729187');
		Case caso = Util_Tests.getCaseById(poliza.Id);
		WorkOrder ordenTrabajo = Util_Tests.getWorkOrderByTXT('19410.0');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('solicitudExistente','N');
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('idOrdenTrabajo',ordenTrabajo.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		Test.startTest();
		habRequeridasOT = new HabilidadesRequeridasOT(stdc);
		habRequeridasOT.crearItem();
		habRequeridasOT.cancelarCreacionItem();
		habRequeridasOT.crearItem();
		habRequeridasOT.categoria = 'E_';
		habRequeridasOT.buscarHabilidades();
		habRequeridasOT.habilidad = habRequeridasOT.listaHabilidades.get(0).getValue();
		habRequeridasOT.guardarItem();
		Skill habilidad = [SELECT Description,DeveloperName,MasterLabel FROM Skill WHERE DeveloperName Like '%E' Limit 1];
		SkillRequirement requisito = Util_Tests.crearSkillRequirement(ordenTrabajo.Id,habilidad.Id, 1);
		insert requisito;
		habRequeridasOT.nuevoItem = requisito;
		habRequeridasOT.actualizarItem();
		habRequeridasOT.indiceListaItems = 1;
		habRequeridasOT.eliminarItem();
		Test.stopTest();
	}
	
	@isTest static void testVolver(){
		PageReference pageRef = Page.HabilidadesRequeridasOT;
		Test.setCurrentPage(pageRef);
		ServiceContract poliza = Util_Tests.getServiceContractByName('9729187');
		Case caso = Util_Tests.getCaseById(poliza.Id);
		WorkOrder ordenTrabajo = Util_Tests.getWorkOrderByTXT('19410.0');
        
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('solicitudExistente','N');
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('idOrdenTrabajo',ordenTrabajo.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		Test.startTest();
		habRequeridasOT = new HabilidadesRequeridasOT(stdc);
		habRequeridasOT.volver();
		Test.stopTest();
	}
    
    
    	@isTest static void testMejorasTest(){
		PageReference pageRef = Page.HabilidadesRequeridasOT;
		Test.setCurrentPage(pageRef);
		ServiceContract poliza = Util_Tests.getServiceContractByName('9729187');
		Case caso = Util_Tests.getCaseById(poliza.Id);
        Id Nuevo = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
        system.debug(Nuevo + ' RecordTYPE');
       	String Developed = Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(Nuevo);
        caso.recordtypeId = Nuevo;
       
          //  system.debug()
        //caso.RecordTypeId =nuevo;
        
        //caso.RecordTypeId.developerName = Label.RT_CAS_B2C;
        system.debug(caso + ' que es el caso');
		WorkOrder ordenTrabajo = Util_Tests.getWorkOrderByTXT('19410.0');
        ordenTrabajo.OTR_SEL_Gremio__c = '01';
       	update ordenTrabajo;
            System.debug(ordenTrabajo + ' infoWorkOrder');
		ApexPages.currentPage().getParameters().put('fase',Label.SINI_FASE_APERTURA);
		ApexPages.currentPage().getParameters().put('solicitudExistente','N');
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('retorno','/'+caso.Id);
		ApexPages.currentPage().getParameters().put('idOrdenTrabajo',ordenTrabajo.Id);
		ApexPages.StandardController stdc = new ApexPages.StandardController(caso);
		Test.startTest();
		habRequeridasOT = new HabilidadesRequeridasOT(stdc);
		habRequeridasOT.crearItem();
		habRequeridasOT.cancelarCreacionItem();
		habRequeridasOT.crearItem();
		habRequeridasOT.categoria = 'E_';
		habRequeridasOT.buscarHabilidades();
		habRequeridasOT.habilidad = habRequeridasOT.listaHabilidades.get(0).getValue();
		habRequeridasOT.guardarItem();
		Skill habilidad = [SELECT Description,DeveloperName,MasterLabel FROM Skill WHERE DeveloperName Like '%E' Limit 1];
		SkillRequirement requisito = Util_Tests.crearSkillRequirement(ordenTrabajo.Id,habilidad.Id, 1);
		insert requisito;
		habRequeridasOT.nuevoItem = requisito;
		habRequeridasOT.actualizarItem();
		habRequeridasOT.indiceListaItems = 1;
		habRequeridasOT.eliminarItem();
		Test.stopTest();
    
    
    

 }
    
    
}