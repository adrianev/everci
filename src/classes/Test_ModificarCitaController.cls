@isTest
public class Test_ModificarCitaController {
		
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
    
      @TestSetup
    	static void setUp(){

      
        Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X1234567X');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('NombrePoliza',compania.Id,cuentaPrincipal.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		caso.Status = '993';
		insert caso;
		
        
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
        List<Profile> lp = [SELECT Id,Name  FROM Profile];
		System.debug(lp);            
		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuari;
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :cuentaProfesional.Id ];
		profesional = Util_Tests.crearRecursoServicio('David','Estanislao',acc1.Id,usuari);
        profesional.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
        profesional.RSE_SEL_Gremio__c='21';
		insert profesional;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('nombreTipoTrabajo','21',2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('19210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
		citaServicio = Util_Tests.crearCitaServicio('Guadabili', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', datetime.newInstance(2018, 02, 21), datetime.newInstance(2018, 02, 24));
		//citaServicio.Status = 'Pte. de asignar';
		citaServicio.Status = Label.CIT_ESTADO_ANULADA;
        citaServicio.ParentRecordId = ordenTrabajo.Id;
        citaServicio.ArrivalWindowStartTime = Datetime.newInstance(2018, 12, 21);
		insert citaServicio;
         
 
    }
    
    @isTest static void estaCitaAnulada()
    {
        ServiceAppointment cita = [Select id,City from ServiceAppointment WHERE City='Guadabili'];
       
        //System.debug(cita);
        Boolean citaAnulada  = ModificarCitaController.estaCitaAnulada(cita.Id);
        System.debug(citaAnulada);
        System.assertEquals(citaAnulada, true);
       
    }
    @isTest static void testCancelarCita()
    {
        ServiceAppointment cita = [Select id,City from ServiceAppointment WHERE City='Guadabili'];

        try
        {
            ModificarCitaController.anularCita(cita.Id);
        }
        catch(Exception e)
        {
            //System.debug(e.getMessage());//Script-thrown exception
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Script-thrown exception')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }        
       // System.debug(iCita);
       // System.assertEquals(infoCita.Status, cita.Status);       
    }
    @isTest static void  testGetURLModificarCita()
    {
		ServiceAppointment cita = [Select id,City,ArrivalWindowStartTime from ServiceAppointment WHERE City='Guadabili'];
	
        Datetime dt = Datetime.newInstance(2018, 12, 21);
    	cita.ArrivalWindowStartTime=dt;
        Baipas.establecerVariableControl();
        update cita;
        Baipas.deshabilitarVariableControl(); 
     //   System.debug(cita.ArrivalWindowStartTime.month());
     //   System.debug(cita.ArrivalWindowStartTime.day());
     	String URLcita = 'www.google.es';
        Datetime dtNow = Datetime.now();
        String URLresult = ModificarCitaController.getURLModificacionCita(cita.Id,dtNow+'',URLcita);
        System.assertNotEquals(URLcita,URLresult);
    }
    @isTest static void testGetURLModificarCitaException()
    {
        ServiceAppointment cita = [Select id,City from ServiceAppointment WHERE City='Guadabili'];
        cita.ArrivalWindowStartTime = Datetime.now();
        Baipas.establecerVariableControl();
        update cita;
        Baipas.deshabilitarVariableControl(); 
        try
        {
          	String URLcita = 'www.google.es';
        	String URLresult = ModificarCitaController.getURLModificacionCita(cita.Id,datetime.now()+'',URLcita);
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());//Script-thrown exception
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Script-thrown exception')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }        
    }
}