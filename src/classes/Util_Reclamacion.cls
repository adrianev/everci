/**
 * Clase de funciones auxiliares relativas a las reclamaciones.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Reclamacion {
	public static void completarDireccionesReclamaciones(List<Case> reclamaciones, Map<Id, WorkOrder> mapaOTs){
		if(reclamaciones != null
				&& !reclamaciones.isEmpty()){
			Set<Id> casoRelacionado = new Set<Id>();
			Set<Id> woRelacionada = new Set<Id>();
			for(Case rec: reclamaciones){
				if(rec.ParentId != null
						&& !casoRelacionado.contains(rec.ParentId)){
					casoRelacionado.add(rec.ParentId);
				}
			}

			Map<Id,Case> mapaCasoRelacionado = new Map<Id,Case>();

			if(!casoRelacionado.isEmpty()) mapaCasoRelacionado = Util_Caso.getCaseById(casoRelacionado);

			for(Case rec: reclamaciones){
				if(rec.ParentId != null){
					Case origen = mapaCasoRelacionado.get(rec.ParentId);
					rec.CAS_TXT_Direccion__c = origen.CAS_TXT_Direccion__c;
					rec.CAS_TXT_DirRiesgo_Poblacion__c = origen.CAS_TXT_DirRiesgo_Poblacion__c;
					rec.CAS_TXT_DirRiesgo_CP__c = origen.CAS_TXT_DirRiesgo_CP__c;
					rec.CAS_SEL_DirRiesgo_Estado_Provincia__c = origen.CAS_SEL_DirRiesgo_Estado_Provincia__c;
					rec.CAS_LKP_Compania__c = origen.CAS_LKP_Compania__c;
				} else if(rec.CAS_LKP_Recl_Orden_Trabajo__c != null){
					WorkOrder wo = mapaOTs.get(rec.CAS_LKP_Recl_Orden_Trabajo__c);
					rec.CAS_TXT_Direccion__c = wo.Street;
					rec.CAS_TXT_DirRiesgo_Poblacion__c = wo.City;
					rec.CAS_TXT_DirRiesgo_CP__c = wo.PostalCode;
					rec.CAS_SEL_DirRiesgo_Estado_Provincia__c = Util_Listas_Seleccion.getValorAPIDesdeLabel('Case','CAS_SEL_DirRiesgo_Estado_Provincia__c',wo.State);
					rec.CAS_LKP_Compania__c = wo.Case.CAS_LKP_Compania__c;
				}
			}
		}
	}

	public static void configurarReclamacionesCorreo(List<Case> reclamaciones){

		Set<String> codigosSiniestro = new Set<String>();

		for(Case caso: reclamaciones){
			List<String> parseAsunto = caso.Subject.split(' ');
			String numeroSiniestro='';

			for(Integer i = 0; i<parseAsunto.size();i++){
				if(parseAsunto[i] == 'Siniestro:')
					numeroSiniestro = parseAsunto[i+1];
			}

			if(numeroSiniestro != '')
				codigosSiniestro.add(numeroSiniestro);
		}

		List<Case> relacionado =  Util_Caso.getCaseByCaseNumber(codigosSiniestro).values();
		Map<String, Case> relacionadoPorNumero = new Map<String,Case>();

		for(Case caso: relacionado){
			relacionadoPorNumero.put(caso.CaseNumber,caso);
		}

		for(Case caso: reclamaciones){

			List<String> parseAsunto = caso.Subject.split(' ');
			String numeroSiniestro='';

			for(Integer i = 0; i<parseAsunto.size();i++){
				if(parseAsunto[i] == 'Siniestro:')//TODO: Label
					numeroSiniestro = parseAsunto[i+1];
			}

			Case rel = null;

			if(numeroSiniestro != '')
				rel = relacionadoPorNumero.get(numeroSiniestro);

			if(rel != null){
				caso.ParentId = rel.Id;
				caso.AccountId = rel.AccountId;
			}

			caso.ContactId = null; //si se deja y existe el contacto, pero no es del accountId, peta.
		}
	}
	public static void sleep(integer milliseconds) 
	{
			  Long timeDiff = 0;
			DateTime firstTime = System.now();
			do
			{
				timeDiff = System.now().getTime() - firstTime.getTime();
			}
			while(timeDiff <= milliseconds);	  
	}
}