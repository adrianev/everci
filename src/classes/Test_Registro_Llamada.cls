@isTest
public without sharing class Test_Registro_Llamada {

    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType tipoTrabajo;
    
    @isTest static void Registro_Llamada(){
        
        Test.startTest();
        compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        cuenta.type = '01';
		insert cuenta;

        Account cuentaSec = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuenta.Id,'X1114567X');
        cuentaSec.type = '01';
		insert cuentaSec;
        
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
        
        User newUser = new User();
		newUser.FirstName = 'Manolo';
		newUser.LastName = 'tena';
		newUser.Email = 'manolo@manolo.com';
		newUser.Alias = 'Manolo';
		newUser.ProfileId = system.UserInfo.getProfileId();
		newUser.Username = ' john784poi@acme7.com';
		newUser.CommunityNickname = 'pepe';
		newUser.TimeZoneSidKey = 'Europe/Paris';
		newUser.LocaleSidKey = system.UserInfo.getLocale();
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.LanguageLocaleKey = 'es';

		insert newUser;
        
        
        system.runAs(newUser){
            
            caso = Util_Tests.crearCasoB2B(sv.Id, cuentaSec.Id, cuenta.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.OwnerId = newUser.Id;
            caso.CreatedDate = system.now();
            caso.Status = '993';
            insert caso;
            
        }
        
        Contact cont = Util_Tests.crearContacto('sera', 'roca', cuenta.Id, 'fgsdgsdfgsf');
        insert cont;
        
        List<Task> tareasInsertar = new List<Task>();
        tareasInsertar.add(Registro_Llamada.crearTareaLlamada(newUser.Id, caso.Id, cont.Id, system.now(), system.now().addHours(3), 2000, 'idSesion', true));
        
        Test.stopTest();
    }
}