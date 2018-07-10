/******************************************************************
Clase de extensión del Controlador de Encuesta_Datos
--Filtra la realización de la Encuesta según a la Compañia a la que pertenece el caso
--Dicho caso:
-- se pide en la Visualforce asociada (Llamada desde Layout de una Encuesta Realizada)
--o
--se recoge en la invocación(LLamada desde un Caso)
 ******************************************************************/

public without sharing class Encuesta_Datos_Controller {
	public Boolean casoPendiente {get;set;}
	public ENC_Encuesta__c encNueva {get;set;}
	public String idCaso {get;set;}
	public String idEncuestaTipo {get;set;}
	public Map<String,String> mapaEncuestas;
	public Encuesta_Datos_Controller(ApexPages.StandardController stdController){
		casoPendiente=true;
		encNueva = new ENC_Encuesta__c();
		system.debug('>>>>>verCurrentPage: ' + System.currentPageReference().getParameters());
		PageReference paginaActual = ApexPages.currentPage();
		if (ApexPages.currentPage().getParameters()!=null){
			idCaso = ApexPages.currentPage().getParameters().get('CF00N9E000001rKVJ_lkid');
			system.debug('>>>>>idCaso: ' + idCaso);
			if(idCaso!=null){ //tiene que ser cuando no haya introducido nada
				encNueva.ENC_LKP_Caso__c=idCaso;
				casoPendiente=false;
			}
		}
		mapaEncuestas = new Map<String,String>();
		mapaEncuestas.put('T1_0000_SI','/apex/Encuesta_Tipo_Largo');
		mapaEncuestas.put('T1_1018_CS','/apex/Encuesta_SC_Corto');
		mapaEncuestas.put('T1_1040_CA','/apex/Encuesta_NN_Cob_Adicionales');
		mapaEncuestas.put('T1_1040_IN','/apex/Encuesta_NN_Indemnizables');
		mapaEncuestas.put('T1_1040_MA','/apex/Encuesta_NN_Manitas');
		mapaEncuestas.put('T1_1040_RM','/apex/Encuesta_NN_Reparables');
		mapaEncuestas.put('T1_1999_AC','/apex/Encuesta_Tipo_Largo');
		mapaEncuestas.put('T1_1999_RE','/apex/Encuesta_Tipo_Largo');
		mapaEncuestas.put('T2_1018_CT','/apex/Encuesta_SC_Corto');
		mapaEncuestas.put('T3_1018_RM','/apex/Encuesta_Tipo_Largo');
		mapaEncuestas.put('T4_1018_MT','/apex/Encuesta_SC_Mantenimiento');
		mapaEncuestas.put('T5_1018_CS_CAT','/apex/Encuesta_SC_Corto');
		mapaEncuestas.put('T6_1018_CT_CAT','/apex/Encuesta_SC_Corto');
		mapaEncuestas.put('T7_1018_RM_CAT','/apex/Encuesta_Tipo_Largo');
		mapaEncuestas.put('T8_1018_MT_CAT','/apex/Encuesta_SC_Mantenimiento');
		mapaEncuestas.put('T1_5610_AS','/apex/Encuesta_END_Asistencia');
		mapaEncuestas.put('T1_5610_AS_CAT','/apex/Encuesta_END_Asistencia');

		system.debug('>>>>>>>Si esta relleno el caso es que viene la encuesta desde un caso');
		system.debug('>>>>>encNueva.ENC_LKP_Encuesta_Tipo__c antes de recargar: ' + encNueva.ENC_LKP_Encuesta_Tipo__c);
		system.debug('>>>>>encNueva.ENC_LKP_Caso__c antes de recargar: ' + encNueva.ENC_LKP_Caso__c);
	}
	public PageReference redirect()
	{
		system.debug('>>>>>idCaso: ' + idCaso);
		system.debug('>>>>>encNueva.ENC_LKP_Caso__c antesEmpezarEncuesta: ' + encNueva.ENC_LKP_Caso__c);
		PageReference pr;
		/*Set<Id> ids = new Set<Id>();
		ids.add(encNueva.ENC_LKP_Caso__c);
		List<Account> compania = Util_Cuentas.getMapCuentasById(new Set<Id>{Util_Caso.getCaseById(ids).get(encNueva.ENC_LKP_Caso__c).CAS_LKP_Compania__c}).values();
		//List<Account> compania = Util_Cuentas.getMapCuentasById(new Set<Id>{Util_Caso.getMapaCasos(ids).get(encNueva.ENC_LKP_Caso__c).CAS_LKP_Compania__c}).values();
		//List<Account> compania = Util_Cuentas.queryCuenta(Util_Caso.getMapaCasos(ids).get(encNueva.ENC_LKP_Caso__c).CAS_LKP_Compania__c);
		//List<Account> compania = [SELECT Id,Name FROM Account where Id IN (SELECT CAS_LKP_Compania__c FROM Case WHERE Id = :encNueva.ENC_LKP_Caso__c)];
		String nombre = compania[0].Name;
		system.debug('>>>>>Nombrecompania: ' + nombre);
		ENC_Encuesta_Tipo__c encuestaEncontrada = Util_Encuestas.queryMapEncuestaTipo(new Set<Id>{encNueva.ENC_LKP_Encuesta_Tipo__c}).get(encNueva.ENC_LKP_Encuesta_Tipo__c);
		//ENC_Encuesta_Tipo__c encuestaEncontrada = Util_Encuestas.queryEncuestaTipoById(encNueva.ENC_LKP_Encuesta_Tipo__c);
		//List<ENC_Encuesta_Tipo__c> encTipo = [SELECT Id,Name,ENT_LKP_Cuenta__c, ENT_TXT_Identificador__c,ENT_SEL_Long_Encuesta__c  FROM ENC_Encuesta_Tipo__c WHERE Id =  :encNueva.ENC_LKP_Encuesta_Tipo__c];
			String iden = mapaEncuestas.get(encuestaEncontrada.ENT_TXT_Identificador__c);
			system.debug(iden);
			pr = new PageReference(iden);
			system.debug('>>>>>Hago encuesta de: ' + nombre);
			system.debug('>>>>>Hago encuesta con: ' + encuestaEncontrada.ENT_TXT_Identificador__c);
			system.debug('>>>>>Hago encuesta con la visual: ' + iden);
			system.debug('>>>>>encNueva.ENC_LKP_Encuesta_Tipo__c : ' + encNueva.ENC_LKP_Encuesta_Tipo__c);
			system.debug('>>>>>encNueva.ENC_LKP_Caso__c : ' + encNueva.ENC_LKP_Caso__c);
		pr.getParameters().put('caso',encNueva.ENC_LKP_Caso__c);
		pr.getParameters().put('tipo',encNueva.ENC_LKP_Encuesta_Tipo__c);
		pr.setRedirect(true);*/
		return pr;
	}
}