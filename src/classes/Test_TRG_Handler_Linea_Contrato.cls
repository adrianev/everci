@isTest
public without sharing class Test_TRG_Handler_Linea_Contrato {

    @isTest static void test_TRG_Handler_Linea_Contrato(){
    	Baipas.establecerVariableControl();
        Id recordSec;
        Id recordPrin;
        List<RecordType> recordList = new List<recordType>([SELECT r.Id, r.DeveloperName, r.Name, r.SobjectType FROM RecordType r]);
        for(RecordType rec: recordList){
            if(rec.DeveloperName == 'CUE_Cliente_B2B_B2B2C_sec'){
                recordSec = rec.Id;
            }
            if(rec.DeveloperName == 'CUE_Cliente_B2B_B2B2C_ppal'){
                recordPrin = rec.Id;
            }
        }
        //Creo e inserto cuentas
		Account compania = Util_Tests.crearCuentaB2BPpal('Holiday Gym','2000','X1234567X');
		insert compania;
        Account principal = Util_Tests.crearCuentaB2BSec('Holiday Gym2','1000',compania.Id,'X1134567X');
        principal.RecordTypeId = recordPrin;
		insert principal;
		Account secundaria = Util_Tests.crearCuentaB2BSec('Holiday Gym Arturo Soria2','1001',principal.Id,'X1114567X');
        secundaria.RecordTypeId =recordSec;
        insert secundaria;
		//Creo e inserto Contratos
		Contract contrato = Util_Tests.crearContrato(principal.Id,'b2b_p_1');
		insert contrato;
		Baipas.deshabilitarVariableControl();
		//Creo e inserto linea de contrato
		Linea_Contrato__c lineaContrato = Util_Tests.crearLineaContrato(contrato.Id,3,'21',Label.RT_LIN_CON_CORRECTIVO);
		insert lineaContrato;
    }
}