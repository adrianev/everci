@isTest
public without sharing class Test_TRG_Festivo extends TestSetup{
    private static ServiceContract NuevaPoliza{get; set;}
    private static Case Nuevocaso {get; set;}
    public static SiniIndemnDocumentosController siniDocumentos  {get; set;}
    private static Account compania {get; set;}
    private static Account cuenta {get; set;}
    private static Account cuentaPrincipal {get; set;}
    private static Tipo_Producto_CIA__c  tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
    
/*
     @testSetup
	public static void test(){
		TestSetup loadData = new Test_TRG_Festivo();
		loadData.setTestData();

	}
    */
     public static void InicializarVariables(){
        
       	compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.CUE_DIV_Limite_Actuacion__c = 2000.00;
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','111019','X1134567X');
		cuentaPrincipal.Type = '01';
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','101120',cuentaPrincipal.Id,'X1114567X');
		cuenta.CUE_LKP_Cliente_contable__c = cuentaPrincipal.Id;
		cuenta.Type = '01';
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.Id);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		NuevaPoliza = Util_Tests.crearPolizaContrato('4523814',cuentaPrincipal.Id,cuenta.Id,productoCIA.Id);
        insert NuevaPoliza;
        Nuevocaso = Util_Tests.crearCasoB2B(NuevaPoliza.Id, cuenta.id, cuentaPrincipal.Id);
		insert Nuevocaso;	  
        
    }
    
    @isTest
    public static void datosTest(){
        InicializarVariables();
        Test.startTest();
        OperatingHours op = Util_Tests.crearHoraFuncionamiento('Horario por defecto','Europe/Paris');
        insert op;
        ServiceTerritory st = Util_Tests.crearTerritorioServicio('28001 MADRID',op.Id,'28001'); 
        st.TDS_TXT_Identificador__c = '28001';
        insert st;
        
        Festivos__c fest = new Festivos__c();
        
        fest.FES_CAS_Procesado__c = false;
        fest.FES_DAT_Fecha__c = System.today();
        fest.FES_LKP_Territorio__c = st.Id;
        fest.FES_SEL_Provincia__c = '28';
        fest.FES_SEL_Tipo_de_Festivo__c	= 'Nacional';
        fest.Name = 'Prueba';
        
        insert fest;
        
        Test.stopTest();
    }
}