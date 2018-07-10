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
    private static Account b2b_1 {get; set;}
	private static Account b2b_2 {get; set;}
    
      @TestSetup
    	static void setUp(){

      
       	Baipas.establecerVariableControl();
		/*cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal', '1516013658675', 'X1234567X');
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
        List<Profile> lp = [SELECT Id,Name  FROM Profile];
		System.debug(lp);            
		Profile perfil = [SELECT Id FROM Profile WHERE Name =: Label.PERFIL_ADMINISTRADOR];
		usuari = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
		insert usuari;
        Account acc1 = [SELECT id, Name,CUE_TXT_Identificador__c FROM Account WHERE id = :cuentaProfesional.Id ];
		profesional = Util_Tests.crearRecursoServicio('David','Estanislao',acc1.Id,usuari);
        profesional.Name = acc1.CUE_TXT_Identificador__c + '_01_1';
		insert profesional;
		ordenTrabajo = Util_Tests.crearOrdenTrabajoConProfesional('19210.0','21',tipoTrabajo.Id,caso.Id,profesional.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
		citaServicio = Util_Tests.crearCitaServicio('Guadabili', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', datetime.newInstance(2018, 02, 21), datetime.newInstance(2018, 02, 24));
		//citaServicio.Status = 'Pte. de asignar';
		citaServicio.Status = Label.CIT_ESTADO_ANULADA;
        citaServicio.ParentRecordId = ordenTrabajo.Id;
        citaServicio.ArrivalWindowStartTime = Datetime.newInstance(2018, 12, 21);
		insert citaServicio;*/
        system.debug('PERFIL COMUNIDAD'+Label.PERFIL_COMUNIDAD);
		compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
		b2b_1 = Util_Tests.crearCuentaB2BPpal('Manolo', '2018','X1134567X');
		b2b_1.Type= '01';
		insert b2b_1;
		b2b_2 = Util_Tests.crearCuentaB2BSec('Paco', '3018',b2b_1.Id,'X1114567X');
		b2b_2.Type= '01';
		insert b2b_2;
		Date startDate = Date.newInstance(2016, 12, 31);
		poliza = Util_Tests.crearPolizaContrato('9729187', compania.Id, b2b_2.Id, null);
		insert poliza;
		Procedencia__c procedencia = Util_Tests.crearProcedencia(0,0,0,0,0,compania.Id,'101801','CAS_Servicio_B2B_B2B2C');
		insert procedencia;
		caso = Util_Tests.crearCasoB2B(poliza.Id, b2b_2.Id, b2b_1.Id);
		insert caso;
		Contract contrato = Util_Tests.crearContrato(b2b_2.Id,'contrato');
		insert contrato;
		Linea_Contrato__c lineaCon = Util_Tests.crearLineaContrato(contrato.Id,3,'21', Label.RT_LIN_CON_CORRECTIVO);
		insert lineaCon;
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccion = Util_Tests.crearDireccionesB2B_B2B2CLineasContrato(b2b_2.Id, lineaCon.Id, 3);
		insert direccion;
		Presupuesto__c presupuesto = Util_Tests.crearPresupuesto('100', caso.Id,1);
		insert presupuesto;
		WorkType tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '21', 20.0);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19410.0', '21', tipoTrabajo.Id, caso.Id);
		ordenTrabajo.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;
		Date primeraCita = Date.newInstance(2018, 12, 31);
		ordenTrabajo.OTR_DAT_Fecha_Primera_Cita__c = primeraCita;
		ordenTrabajo.OTR_CAS_Urgente__c = false;
		ordenTrabajo.AccountId = b2b_2.Id;
		insert ordenTrabajo;
        
      
		datetime fechaInicio = datetime.newInstance(2018, 12, 31);
		datetime fechaVencimiento = datetime.newInstance(2019, 12, 31);
		ServiceAppointment citaServicio = Util_Tests.crearCitaServicio('Guadabili', 'Espana', '28000', 'Espana', 'Virgen de la Cabeza', fechaInicio, fechaVencimiento);
		citaServicio.Status = Label.CIT_ESTADO_ANULADA;
		citaServicio.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio;
            
        ServiceAppointment citaServicio2 = Util_Tests.crearCitaServicio('Guadabili2', 'Espana', '28000', 'Espana', 'Virgen de la Cabeza', fechaInicio, fechaVencimiento);
		citaServicio2.Status = 'Pte. de asignar';
		citaServicio2.ParentRecordId = ordenTrabajo.Id;
		insert citaServicio2;    
            
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
  
		caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
		caso.CAS_CAS_Supera_Limite_Actuacion__c = true;
		caso.Type = Label.B2B_TIPO_CORRECTIVO;
		update caso;
		Comentario_caso__c comentarioCaso = Util_Tests.crearComentarioCaso('comentario de caso para test', caso.Id);
		insert comentarioCaso;
		Comentario_Orden_de_Trabajo__c comentarioOT= Util_Tests.crearComentarioOT('comentario de Orden Trabajo para test', ordenTrabajo.Id);
		insert comentarioOT;
		FSL__Scheduling_Policy__c politicaGeo = Util_Tests.crearPolitica('Política de Asignación – Geolocalización');
		insert politicaGeo;
         
 
    }
    
    @isTest static void estaCitaAnulada()
    {
        ServiceAppointment cita = [Select id,City,status from ServiceAppointment WHERE City='Guadabili'];
        //System.debug(cita);
        Boolean citaAnulada  = ModificarCitaController.estaCitaAnulada(cita.Id);
        System.debug(citaAnulada);
        System.assertEquals(citaAnulada, true);
       
    }
    @isTest static void testCancelarCita()
    {
        ServiceAppointment cita = [Select id,City,status from ServiceAppointment WHERE City='Guadabili2'];
        Datetime dt = Datetime.newInstance(2018, 12, 21);
    	cita.ArrivalWindowStartTime=dt;
        Baipas.establecerVariableControl();
        update cita;
        Baipas.deshabilitarVariableControl(); 
		System.debug('CITA: '+cita.Id);
        try
        {
            ModificarCitaController.anularCita(cita.Id);
        }
        catch(Exception e)
        {
            System.debug('Exception='+e.getMessage());//Script-thrown exception
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