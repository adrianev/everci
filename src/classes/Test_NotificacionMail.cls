@isTest
public without sharing class Test_NotificacionMail {

    public static Account compania;
    public static Account cuenta;
    public static Account Asegurado;
    public static Tipo_Producto_CIA__c tipoProducto;
    public static Producto_CIA__c producto;
    public static Procedencia__c procedencia;
    public static ServiceContract sv;
    public static Case caso;
    public static Contact contacto;

    private static void inicialize(){
        
        compania = Util_Tests.crearCuentaCompania('compania', Label.IDE_MEMBERSHIP,'X1234567X');
		insert compania;
        
        cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		insert cuenta;
        
		
        Account asegurado = Util_Tests.crearCuentaAsegurado('Manola','0002','manola@gmail.es','89074907R','Manola', 'Manolan', 'Manolozo');
        asegurado.CUE_LKP_Cuenta_principal__c = compania.Id;
        insert asegurado;
        
        tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto; 
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;  
        
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        insert procedencia;
        
        sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id,producto.Id);
        insert sv;
        
        caso = new Case();
        caso = Util_Tests.crearCasoB2B(sv.Id, asegurado.Id, compania.Id);
        caso.CAS_SEL_Encuestador__c = 'Servitelco';
        caso.CAS_LKP_Compania__c = compania.Id;
        caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CreatedDate = system.now();
        caso.Status = '993';
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        caso.CAS_TXT_Apellidos_2__c = 'Roca';
        caso.CAS_TXT_Apellidos__c = 'Vergara';
        caso.CAS_TFN_Solicitud_Telefono__c = '634700005';
        insert caso;
        
        contacto = Util_Tests.crearContacto('serafin', 'roca');
        insert contacto;
        
    }
    
    @isTest static void notificacionMail(){
        Test.startTest();
        inicialize();
        List<Case> casoList = new List<Case>();
        casoList.add(caso);
        NotificacionMail.filtroNotificaciones(casoList, caso.Id, compania.Id, null);
        List<Contact> contactList = new List<Contact>();
		contactList.add(contacto);   
        //NotificacionMail.filtroNotificaciones(contactList, caso.Id, compania.Id, null);
        Test.stopTest();
    }
}