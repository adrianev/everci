/**
 * Clase controladora de la Visualforce "CambiarNaturalezaReclamacion" encargada de gestionar la creación de reclamaciones
 * 
 * @author EVERIS
 */
 public with sharing class CambiarNaturalezaReclamacion {
 	
	public Case reclamacion;
	public Case reclCampos;
 	public Boolean customNaturaleza {get;set;}
 	public ApexPages.standardController controlador;
 	
 	public String cia{get;set;}
 	
 	public Boolean todoCorrecto {get;set;}
 	public List<String> listaNaturalezasBorrar;
 	public Map<String,String> naturalezaClaveValor;
	public Map<String,String> reemplazos;
	public List<String> nClaveValor;
 	
 	
 	public CambiarNaturalezaReclamacion(ApexPages.standardController stdCtr){
 		
 		todoCorrecto = true;
 		Set<String> customCIA = new Set<String>{'1023','1040','1018'};
		
		List<String> fields = new List<String> {'Id','CAS_SEL_Padre_reclamacion__c','CAS_SEL_Naturaleza__c'};
		
		if(!Test.isRunningTest()){
			stdCtr.addFields(fields);
		}
		
		
		PageReference paginaActual = ApexPages.currentPage();
		
		if (!paginaActual.getParameters().containsKey('id')){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
			todoCorrecto = false;
		} else {

			Id idReclamacion = stdCtr.getRecord().Id;

			List<Case> recAux = Util_Caso.getCaseById(new Set<Id>{idReclamacion}).values();
			
			if(!recAux.isEmpty()){
				reclCampos = recAux.get(0);
				reclamacion = (Case)stdCtr.getRecord();
				
				cia = reclCampos.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
				
				controlador = stdCtr;
			
				listaNaturalezasBorrar = new List<String>();
				Map<String,List<Naturaleza__mdt>> naturalezas = Util_Metadatos.mapaNaturalezaCIA;
				List<Naturaleza__mdt> temp = new List<Naturaleza__mdt>();
				for(List<Naturaleza__mdt> nats : naturalezas.values()){
					temp.addAll(nats);
				}
				for(Naturaleza__mdt nat: temp){
					listaNaturalezasBorrar.add(nat.MTD_NAT_TXT_Naturaleza_cia__c);
				}
		
				if(customCia.contains(cia)){
					customNaturaleza = true;
					rellenarReemplazosNaturaleza();
				}
					
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
				todoCorrecto = false;
			}
			
			
		}
		

 	}
 	
 	/**
    * 
 	* Método encargado de reemplazar las naturalezas de HS por las de la compañía en cuestión
 	* 
 	*/ 
	public void rellenarReemplazosNaturaleza(){

		if(!String.isBlank(cia)){

			List<Naturaleza__mdt> naturalezas = Util_Metadatos.mapaNaturalezaCIA.get(cia);
			Set<String> nuevosVal = new Set<String>();
			naturalezaClaveValor = new Map<String,String>();    
			nClaveValor = new List<String>();
			reemplazos = new Map<String,String>();

			if(naturalezas != null){

				for(Naturaleza__mdt nat: naturalezas){
					listaNaturalezasBorrar.add(nat.MTD_NAT_TXT_Naturaleza_HS__c);
					nuevosVal.add(nat.MTD_NAT_TXT_Naturaleza_cia__c);
					reemplazos.put(nat.MTD_NAT_TXT_Naturaleza_HS__c, nat.MTD_NAT_TXT_Naturaleza_cia__c);
				}
				Schema.DescribeFieldResult fieldResult = Case.CAS_SEL_Naturaleza__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

				for(Schema.PicklistEntry f : ple){
					if(nuevosVal.contains(f.getLabel())){
						naturalezaClaveValor.put(f.getLabel(), f.getValue());
						nClaveValor.add(f.getLabel()+';'+f.getValue());
					}
				}
			}
		}
	}
	
	public String getListaNaturalezasBorrar(){
		return String.escapeSingleQuotes(JSON.serialize(listaNaturalezasBorrar));
	}
	
	public String getNClaveValor(){
		return String.escapeSingleQuotes(JSON.serialize(nClaveValor));
	}

	public String getNaturalezaClaveValor(){
		return String.escapeSingleQuotes(JSON.serialize(naturalezaClaveValor));
	}

	public String getReemplazos(){
		return String.escapeSingleQuotes(JSON.serialize(reemplazos));
	}
 	
    
}