public without sharing class BATCH_Festivos implements Database.Batchable<sObject>, Database.Stateful{

	private static List<ServiceResource> profesionalLista = new List<ServiceResource>();
	private String tipoBatch;

	public BATCH_Festivos(String tipoBatchInput){
		tipoBatch = tipoBatchInput;
	}

	/* ---------------------------------------------------------------------------------------------------------------------------------------
        BATCHABLE METHODS
    ----------------------------------------------------------------------------------------------------------------------------------------*/

	public Database.QueryLocator start(final Database.BatchableContext BC) {
		
		//1.Se recogen todos los registros no procesados por el BATCH del objeto elegido a procesar por parámetro
		String query;
		if(tipoBatch == 'Festivos')
			query = 'SELECT FES_SEL_Tipo_de_Festivo__c, FES_DAT_Fecha__c, FES_LKP_Territorio__c, FES_CAS_Procesado__c, FES_SEL_Provincia__c,FES_LKP_Territorio__r.PostalCode FROM Festivos__c WHERE FES_CAS_Procesado__c = false';
		else if (tipoBatch == 'MiembrosTerritorio')
			query = 'SELECT ServiceResourceId, ServiceTerritory.TDS_SEL_Provincia__c, PostalCode, ServiceResource.RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c, MTS_FOR_Provincia__c FROM ServiceTerritoryMember WHERE MTS_CAS_Procesado_Festivo__c = false AND ServiceResource.IsActive = true AND TerritoryType = \'P\'';
		else if (tipoBatch == 'Profesional')
			query = 'SELECT Id, RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c FROM ServiceResource WHERE RSE_CAS_Procesado_Festivo__c = false AND IsActive = true';

		return Database.getQueryLocator(query);
	}	


	public void execute(final Database.BatchableContext BC, final List<sObject> scope) {
		
		//2.Según el tipo de BATCH ejecutado, se recogen las listas de Profesionales, Festivos y Miembros de Territorio a usar para asignar los Absentismos
		boolean festNacional = false;
		List<Festivos__c> festivosLista = new List<Festivos__c>();
		List<ServiceTerritoryMember> territorioMiembroLista = new List<ServiceTerritoryMember>();
		//2.1.Si se procesan Festivos,  se recogen todas las provincias y códigos postales involucrados, y se marca si existe alguno nacional
		if (tipoBatch == 'Festivos'){
			festivosLista = (List<Festivos__c>) scope;
			Set<String> cPostales = new Set<String>(); 
			Set<String> provincias = new Set<String>(); 
			for(Festivos__c fest:(List<Festivos__c>) festivosLista){system.debug('ESTA ES LA LISTA'+fest.FES_SEL_Tipo_de_Festivo__c);
				if(fest.FES_SEL_Tipo_de_Festivo__c == 'Nacional'){
					festNacional = true;
				}else if(fest.FES_SEL_Tipo_de_Festivo__c == 'Provincial'){
					provincias.addAll(fest.FES_SEL_Provincia__c.split(';'));
				}else{
					cPostales.add(fest.FES_LKP_Territorio__r.PostalCode);
				}
			}
			//2.1.1.Si hay algún festivo nacional, se usarán todos los profesionales activos
			if (profesionalLista.isEmpty() && festNacional){
				//profesionalLista = [SELECT Id, RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c FROM ServiceResource WHERE IsActive = true];
				profesionalLista = Util_Service_Resource.getProfAct(true).values();
			}
			
			//2.1.2.Se recogen los Miembros de Territorio principales activos cuya provincia/CP se encuentre entre los Festivos a procesar
			/*territorioMiembroLista = [SELECT ServiceResourceId, MTS_FOR_Provincia__c, ServiceResource.RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c,PostalCode FROM ServiceTerritoryMember 
										WHERE (PostalCode IN: cPostales OR MTS_FOR_Provincia__c IN: provincias)  AND TerritoryType = 'P'
										AND ServiceResource.IsActive = true];*/
			territorioMiembroLista = Util_TerritorioServicio.getMiembrosFestivos(cPostales,provincias).values();
		}
		//2.2.Si se procesan Miembros de Territorio, se recogen todas los códigos postales involucrados
		else if (tipoBatch == 'MiembrosTerritorio'){
			territorioMiembroLista = (List<ServiceTerritoryMember>) scope;
			Set<String> cPostales = new Set<String>(); 
			for(ServiceTerritoryMember stm:(List<ServiceTerritoryMember>) territorioMiembroLista){
				cPostales.add(stm.PostalCode);
			}
			//2.2.1.Se recogen los festivos locales y provinciales cuyo CP se encuentre entre los Miembros de Territorio a procesar
			/*festivosLista = [SELECT FES_SEL_Tipo_de_Festivo__c, FES_DAT_Fecha__c, FES_LKP_Territorio__c, 
									FES_CAS_Procesado__c, FES_SEL_Provincia__c, FES_LKP_Territorio__r.PostalCode FROM Festivos__c 
			                 WHERE (FES_LKP_Territorio__r.PostalCode IN: cPostales AND FES_SEL_Tipo_de_Festivo__c = 'Local')
			                 	OR (FES_SEL_Tipo_de_Festivo__c = 'Provincial')];*/
			festivosLista = Util_Festivos.getFestMiemb(cPostales).values();
    
			profesionalLista = new List<ServiceResource>();
		}
		//2.3.Si se procesan Profesionales, se recogen todos los festivos nacionales a asignarles
		else if (tipoBatch == 'Profesional'){
			profesionalLista = (List<ServiceResource>) scope;
			Set<String> tipo = new Set<String>();
			tipo.add('Nacional');
			/*festivosLista = [SELECT FES_SEL_Tipo_de_Festivo__c, FES_DAT_Fecha__c, FES_LKP_Territorio__c, FES_CAS_Procesado__c, FES_SEL_Provincia__c, FES_LKP_Territorio__r.PostalCode FROM Festivos__c 
							WHERE FES_SEL_Tipo_de_Festivo__c = 'Nacional'];*/
			festivosLista = Util_Festivos.getFestivos(tipo).values();
			territorioMiembroLista = new List<ServiceTerritoryMember>();
		}
		
		///3.Se recorre la lista de Festivos recogidos, asignando las Abstinencias a los Profesionales que corresponda
		Id ausenciaRecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_FSL_FESTIVO);
		List<ResourceAbsence> ausenciasLista = new List<ResourceAbsence>();
		for(Festivos__c fest:festivosLista){
			//3.1.Si es Nacional, se asigna una Abstinencia a cada Profesional ese día
			if(fest.FES_SEL_Tipo_de_Festivo__c == 'Nacional'){
				for (ServiceResource sr:profesionalLista){
					//Al requerirse inicio y fin en las abstinencias, se marca desde las 0:00 a las 23:59 de ese día
					DateTime fechaIni = Datetime.newInstance(fest.FES_DAT_Fecha__c.year(), fest.FES_DAT_Fecha__c.month(), fest.FES_DAT_Fecha__c.day(), 0, 0, 0);
					DateTime fechaFin = Datetime.newInstance(fest.FES_DAT_Fecha__c.year(), fest.FES_DAT_Fecha__c.month(), fest.FES_DAT_Fecha__c.day(), 23, 59, 59);
					
					//Si es de Canarias se suma una hora para que aparezca bien en su pantalla al insertar la abstinencia con usuario peninsular
					if(sr.RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c == 'A7'){
						fechaIni=fechaIni.addHours(1);
						fechaFin=fechaFin.addHours(1);
						
					}
					ResourceAbsence ra = new ResourceAbsence(Type = Label.ABS_Tipo_Festivo_Nacional, ResourceId = sr.Id, Start = fechaIni, End = fechaFin, 
					Description = 'Festivo Nacional', RecordTypeId = ausenciaRecordTypeId);
							
					ausenciasLista.add(ra);
				}
			}
			//3.2.Si no es Nacional, se recorre la lista de Miembros de Territorio, 										
			//asignando una Abstinencia a su Profesional si la provincia/CP del Festivo coincide con la del Miembro de territorio
			else{
				for(ServiceTerritoryMember stm:territorioMiembroLista){
						if((fest.FES_LKP_Territorio__c!=null && stm.PostalCode == fest.FES_LKP_Territorio__r.PostalCode) || (fest.FES_SEL_Provincia__c!=null && fest.FES_SEL_Provincia__c.contains(stm.MTS_FOR_Provincia__c))){
							//Al requerirse inicio y fin en las abstinencias, se marca desde las 0:00 a las 23:59 de ese día
							DateTime fechaIni = Datetime.newInstance(fest.FES_DAT_Fecha__c.year(), fest.FES_DAT_Fecha__c.month(), fest.FES_DAT_Fecha__c.day(), 0, 0, 0);
							DateTime fechaFin = Datetime.newInstance(fest.FES_DAT_Fecha__c.year(), fest.FES_DAT_Fecha__c.month(), fest.FES_DAT_Fecha__c.day(), 23, 59, 59);
							
							//Si es de Canarias se suma una hora para que aparezca bien en su pantalla al insertar la abstinencia con usuario peninsular
							if(stm.ServiceResource.RSE_LKP_Cuenta__r.CUE_SEL_Direccion_Territorial__c == 'A7'){
								fechaIni=fechaIni.addHours(1);
								fechaFin=fechaFin.addHours(1);
							}
							ResourceAbsence ra = new ResourceAbsence(Type = Label.ABS_Tipo_Festivo_LocalProvincial, ResourceId = stm.ServiceResourceId, Start = fechaIni, End = fechaFin, 
									Description = 'Festivo Local/Provincial', RecordTypeId = ausenciaRecordTypeId);
									
							ausenciasLista.add(ra);	 
						}
				}
			}
		}
		//4.Se insertan todas las Abstinencias creadas
		insert ausenciasLista;

		//5.Se marcan todos los elementos involucrados como procesados para excluirlos de la siguiente ejecución del BATCH
		if (tipoBatch == 'Festivos'){
			for(Festivos__c fest:festivosLista){
				fest.FES_CAS_Procesado__c = true;
			}
			update festivosLista;
		}else if (tipoBatch == 'MiembrosTerritorio'){
			for(ServiceTerritoryMember stm:territorioMiembroLista){
				stm.MTS_CAS_Procesado_Festivo__c = true;
			}
			update territorioMiembroLista;
		}else if (tipoBatch == 'Profesional'){
			for(ServiceResource sr:profesionalLista){
				sr.RSE_CAS_Procesado_Festivo__c = true;
			}
			update profesionalLista;
		}

	}

	public void finish(final Database.BatchableContext BC){
		//sendErrorEmail(BC.getJobId());
	}   

}