@isTest

public without sharing class B2C_Argumentario_Test{
    
	private static ServiceContract poliza {get; set;}
    private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
 	private static Version_ContratoServicio__c nuevaVersion {get; set;}

	@isTest
	static void test_B2C_ArgumentarioTest() {
        
		PageReference pageRef = Page.B2C_Argumentario;
		Test.setCurrentPage(pageRef); 
		Account account=new Account();
        account.CUE_TXT_Numero_Documento__c='47474774F';
        account.CUE_SEL_Tipo_Documento__c='P';
        account.Name='Pedro';
        account.RecordTypeId='0129E0000004pciQAA';
        account.CUE_TXT_Identificador__c = Label.IDE_HOMESERVE;
        insert account;

        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1111111X');
		insert compania;
        
        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;

		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
               
        Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018', 'miguel@gmail.es', '73661110E','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_LKP_Cuenta_principal__c = compania.id;
		insert asegurado;

		poliza = Util_tests.crearPolizaContrato('10', compania.id, asegurado.id, productoCIA.id);
		insert poliza;
        Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        insert caso; 

        Procedencia__c p=new Procedencia__c();
        p.PROC_TXT_Identificador__c = '15184235625251';
        p.PROC_LKP_Cuenta__c = account.Id;
        p.PROC_SEL_Tipos_Caso__c='CAS_Servicio_B2B_B2B2C;CAS_Solicitud_de_Servicio_B2B_B2B2C';
        insert p;
        
        Telefonos_Transfer_CIA__c t=new Telefonos_Transfer_CIA__c();
        t.TTC_LKP_Cuenta__c=account.Id;
        t.TTC_TXT_Descripcion__c='ET Telefono mi casa';
        t.TTC_TXT_Ayuda__c = 'Este es el numero';
        insert t;
        
        Direccion_Cuenta__c d=new Direccion_Cuenta__c();
        d.DCU_LKP_Cuenta__c=account.Id;
        insert d;

        //Account account = getAccountByName('SegurCaixa'); 
		//Case caso = getCaseByAccountId(account.Id);
		ApexPages.currentPage().getParameters().put('id',caso.Id);
		ApexPages.currentPage().getParameters().put('idCuenta',account.Id);
		ApexPages.currentPage().getParameters().put('idCIA',caso.CAS_LKP_Compania__c);
		ApexPages.currentPage().getParameters().put('idPoliza',caso.CAS_LKP_PolizaContrato__c);
		ApexPages.currentPage().getParameters().put('idDireccion',d.Id);
        ApexPages.currentPage().getParameters().put('VDN','1018');
        ApexPages.currentPage().getParameters().put('retURL','Y');
		ApexPages.currentPage().getParameters().put('idTelefonoCIA',t.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(caso);

		B2C_Argumentario argumentario = new B2C_Argumentario(sc);
		Map<String, Object> mapFlow = new Map<String, Object>();
        mapFlow.put('IdCasoNoReparableConPoliza', caso.Id);


        //Creación de flujo_Argumentario_B2C
       	//Flow.Interview.Flujo_argumentario_B2C flujoA = new Flow.Interview.Flujo_argumentario_B2C();
        //flujoA.IdCasoNoReparableConPoliza = caso.Id;
        //argumentario.flujoArgumentario = flujoA;
        //flujoA.start();
        //argumentario.flujoArgumentario = flujo;
        
        //argumentario.flujoArgumentario.IdCasoNoReparableConPoliza=caso.Id;
        
        //argumentario.flujoArgumentario;
        
        //argumentario.flujoArgumentario.start();
        
		argumentario.getPaginaRedireccionar();

       	argumentario.cancelar();
        
		ApexPages.currentPage().getParameters().put('idDireccion','a1C9E000000jVps');
		argumentario.idTelefonoCIA = 'a129E000000W406';
        argumentario.mostrarAyudaTelefonoCIA();
        
	}

	private static Account getAccountByName(String name){
		Account cuenta;

		List<Account> listaCuentas = new List<Account>([Select Id,
		                                                Name,
		                                                CUE_TXT_Identificador__c,
		                                                RecordTypeId,
		                                                CUE_TXT_Numero_Documento__c,
		                                                CUE_TXT_PrimerApellido__c,
		                                                CUE_TXT_Nombre__c,
		                                                CUE_CAS_No_Permite_Servicio_B2C__c,
		                                                CUE_TXT_Presentacion__c,
		                                                CUE_TXT_SegundoApellido__c 
		                                                FROM Account Where Name = :name LIMIT 1]);

		if( !listaCuentas.isEmpty() ){
			cuenta = listaCuentas.get(0);
		}else{
			throw new TestException('No existen cuentas con el nombre especificado');
		}

		return cuenta;
	}

	private static Case getCaseByAccountId(Id accountId){
		Case caso;
		//List<Case> listaCasos = Util_Caso.getMapaCasosByAccount(new Set<Id>{accountId},1).values();
		List<Case> listaCasos = new List<Case>([Select Id,      
		                                        CAS_LKP_PolizaContrato__c,
		                                        AccountId,
		                                        CAS_LKP_Compania__c,
		                                        Origin,
		                                        CAS_TXT_Persona_que_llama__c,
		                                        RecordTypeId,
		                                        Status,
		                                        CAS_SEL_Motivo_No_Apertura__c,
		                                        CAS_SEL_Tipo_Interlocutor__c
		                                        FROM Case Where AccountId = :accountId LIMIT 1]);

		if(!listaCasos.isEmpty()){
			caso = listaCasos.get(0);
		}else{
			throw new TestException('No existen casos con el nombre especificado');
		}
		return caso;
	}
}