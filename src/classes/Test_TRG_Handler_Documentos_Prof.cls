@isTest
public without sharing class Test_TRG_Handler_Documentos_Prof extends TestSetup{
	
	public static Documentos_Profesionales_Contrato__c crearDocumento(Id idProfesional, Id idTipoDocumento, Date fechaEntrega, Date fechaExpiracion){
		Documentos_Profesionales_Contrato__c Documento = new Documentos_Profesionales_Contrato__c();
		Documento.DPC_LKP_Profesional_Contrato__c = idProfesional;
		Documento.DPC_LKP_Tipo_de_Documento__c = idTipoDocumento;
		Documento.DPC_DAT_Fecha_Entrega__c = fechaEntrega;
		Documento.DPC_DAT_Fecha_Expiracion__c = fechaExpiracion;
		return Documento;
	}
	
	public static Tipo_de_Documento__c crearTipoDocumento(String identificador, String nombre, Boolean estado, Boolean validez, String tipoProf, Date fechaInicio, Decimal numDiasBaja, String email){
		Tipo_de_Documento__c tipoDocumento = new Tipo_de_Documento__c();
		tipoDocumento.DOC_TXT_Identificador__c = identificador;
		tipoDocumento.Name = nombre;
		tipoDocumento.DOC_CAS_Estado_Documento__c = estado;
		tipoDocumento.DOC_CAS_Validez__c = validez;
		tipoDocumento.DOC_SEL_Tipo_de_Profesional__c = tipoProf;
		tipoDocumento.DOC_DAT_Fecha_Inicio_Vigencia__c = fechaInicio;
		tipoDocumento.DOC_NUM_Dias_para_Baja__c = numDiasBaja;
		tipoDocumento.DOC_TXT_Texto_Email__c = email;
		return tipoDocumento;
	}

	private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		Account profesionalEmpresa = Util_Tests.crearCuentaCompania('profesionalEmpresa1','1111','Z1585459M');
		insert profesionalEmpresa;
		Account profesional = Util_Tests.crearCuentaProfesionalContrato('PR123456', 'PR123456', 'Z1585459M', profesionalEmpresa.Id);	
     	profesional.CUE_SEL_Tipo_de_Profesional__c = '01';
     	String a = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Profesional Contrato').getRecordTypeId();
     	profesional.RecordTypeId = a;
     	profesional.CUE_CAS_Activado__c = false;
     	profesional.CUE_SEL_Estado__c = '01';
     	insert profesional;
     	Baipas.deshabilitarVariableControl();
     	List <Tipo_de_Documento__c> tiposDocumento = new List <Tipo_de_Documento__c>();
     	Tipo_de_Documento__c tipo1 = crearTipoDocumento('DOC_01','Documento01', true, false, '01', Date.today().addDays(-10), null , null);
     	tiposDocumento.add(tipo1);
     	insert tiposDocumento; 
     	List <Documentos_Profesionales_Contrato__c> Documentos = new List <Documentos_Profesionales_Contrato__c>();
     	Documentos_Profesionales_Contrato__c Documento_1 = crearDocumento(profesional.Id, tipo1.Id, Date.today().addDays(30),null);
     	Documentos.add(Documento_1);
     	insert Documentos;   	
	}
	
	static testMethod void test_Handler_Documento(){
	 	inicializarVariables();
	}

}