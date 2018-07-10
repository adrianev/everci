@isTest
public without sharing class Test_TRG_Recurso_Servicio {


	@isTest
	public static void testTriggerRecursoServicio(){
        Account compania = Util_Tests.crearCuentaCompania('Compania', '1018', 'X1234567X');
        Insert compania;
		Account ac;
		User newUser;
		ServiceResource rS;
        RecordType rt = [SELECT ID FROM RecordType WHERE Name= 'Profesional Contrato'];
		ac = Util_Tests.crearCuentaProfesionalContrato('PR123456', 'RP123456', 'U0087255F',null);  
        ac.CUE_SEL_Tipo_de_Profesional__c = '01';
        ac.CUE_LKP_CuentaPrincipalProf__c = compania.Id;
        insert ac;
        ac.CUE_SEL_Estado__c = '02';
        update ac;
			
		Profile p = [SELECT Id FROM Profile LIMIT 1] ;
		//Asignamos permisos 
		PermissionSet permSet  = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_License'];
			
		PermissionSetAssignment psAss =  [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id].get(0);
			
		newUser = [SELECT Id FROM User WHERE isActive = true].get(0);

		Account ac1 = [SELECT id, CUE_TXT_identificador__c FROM Account WHERE Id = :ac.Id];
		
		rS = Util_Tests.crearRecursoServicio('Hola','1234', ac.Id,newUser);
		rS.Name = ac1.CUE_TXT_identificador__c + '_01_1';
		insert rS ;
        
		rS.RSE_CAS_Disponible_24Hrs__c = false; 
		rS.isActive = true;
		rS.RSE_DAT_Fecha_Baja__c = datetime.now();
		rS.RSE_DAT_Fecha_BajaTemp_Venc__c = datetime.now();
		rS.RSE_DAT_Fecha_BajaTemp_Venc__c = datetime.now(); 
		rS.RSE_DAT_Fecha_Baja__c= null;
		rS.RSE_TXT_Observaciones_BajaDef__c  = 'nonull';
		rS.RSE_TXT_Observaciones_BajaTemp__c  = 'nonull';
		update rS;
			
		rS.RSE_DAT_Fecha_BajaTemp_Venc__c = datetime.now();
		rS.RSE_DAT_Fecha_Baja__c = null;
		rS.RSE_DAT_Fecha_Baja__c = datetime.now();
		rS.RSE_SEL_Motivo_Baja_Temp__c ='0';
		rS.RSE_SEL_Motivo_Baja_Def__c= '0';
			
		update rS;
			
		rS.RSE_DAT_Fecha_BajaTemp_Venc__c = datetime.now();
		rS.RSE_DAT_Fecha_Baja__c = null;
			
		update rS;
		rS.isActive = false;
			
	    update rS;
		rS.isActive = true;
		rS.RSE_DAT_Fecha_Baja__c = datetime.now();
		rS.RSE_SEL_Motivo_Baja_Def__c = '0';
		rS.RSE_SEL_Motivo_Baja_Def__c = '0';
		update rS;
			
		}
		
	}