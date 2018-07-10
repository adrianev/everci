@isTest
public without sharing class Test_ReservarCitaUrgente {

    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static WorkOrder wo;
    private static WorkType tipoTrabajo;
    
    @isTest static void ReservarCitaUrgente(){
        Test.startTest();
    	compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.Type = '01';
        
        //compania.CUE_TXT_Numero_Documento__c = 'A1234567';
		insert compania;
        
		cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
        cuenta.Type = '01';
		insert cuenta;

        
		tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
		insert tipoProducto;
        
		producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
		insert producto;
        
		sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        procedencia.PROC_SEL_Motivos_rechazo_presupuesto__c = '09;07;02;08;06;21;03;01';
        insert procedencia;
        
            caso = Util_Tests.crearCasoB2B(sv.Id, cuenta.Id, compania.Id);
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.CreatedDate = system.now();
        	caso.CAS_TXT_DirRiesgo_CP__c = '28001';
            caso.Status = '993';
            insert caso;
            
            caso.Status = '001';
            update caso;
            
            tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto', '01', 120.0);
            insert tipoTrabajo;
        
         FSL__Scheduling_Policy__c sched = new FSL__Scheduling_Policy__c();
        sched.Name = 'Política de Asignación – Geolocalización';
        insert sched;
        
        
        User newUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        system.runAs(newUser){
            wo = Util_Tests.crearOrdenTrabajo('0000000545','01',tipoTrabajo.Id,caso.Id);
        	wo.OTR_DAT_Fecha_Primera_Cita__c = system.today();
        	wo.OTR_SEL_Rango_Primera_Cita__c = '07';
        	wo.OTR_CAS_Urgente__c = true;
            wo.PostalCode = '28001';
        	insert wo;
            system.debug(wo.status + ' Workorder nada mas insertada en el test');
           List<ServiceAppointment> listaSAs = [SELECT ArrivalWindowStartTime, ArrivalWindowEndTime, CSE_CAS_Asignar_Mizad__c, postalCode FROM ServiceAppointment WHERE ParentRecordId =: wo.Id AND Status = 'Pte. de asignar'];
            ServiceAppointment sa = listaSAs.get(0);
            sa.CSE_CAS_Asignar_Mizad__c = true;
            sa.PostalCode = '28001';
            update sa;
            system.debug(sa + ' Workorder despues de updatear el serviceAppoinment');
            

            ReservarCitaUrgente.reservaCita(wo.Id);
        }
        Test.stopTest();
    }
}