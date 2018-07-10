public class TRG_Handler_Confirmacion {
	//private static Map<Id,Case> mapaCaso;
	private static Map<Id,List<WorkOrder>> mapaWOPorIdCaso;
	private static Map<Id,List<Garantia_Siniestro__c>> mapaGarantSiniPorIdConfirm;
	public static void tratamientoBefore(Map<Id, Confirmacion__c> triggerNewMap, List<Confirmacion__c> triggerNew, Map<Id, Confirmacion__c> triggerOldMap, List<Confirmacion__c> triggerOld) {  
		if(Trigger.IsDelete){
			if(mapaGarantSiniPorIdConfirm!=null){
				mapaGarantSiniPorIdConfirm=Util_Siniestro.queryIdCasoGarantiasExistentes(triggerNewMap.keySet());
			}
			List<Garantia_Siniestro__c> garantiasBorrar = new List<Garantia_Siniestro__c>();
			for(List<Garantia_Siniestro__c> listaGarant : mapaGarantSiniPorIdConfirm.values()){
				garantiasBorrar.addAll(listaGarant);
			}
			delete garantiasBorrar;
		}
	}

	public static void tratamientoAfter(Map<Id, Confirmacion__c> triggerNewMap, List<Confirmacion__c> triggerNew, Map<Id, Confirmacion__c> triggerOldMap, List<Confirmacion__c> triggerOld) {
		List<WorkOrder> listWOc2c = new List<WorkOrder>();
		if(Trigger.IsUpdate){
			if(mapaWOPorIdCaso==null){
				inicializaVariables(triggerNew,triggerNewMap);
			}
			for (Confirmacion__c confirm : triggerNew){
				//Comprobamos si el profesional
				if(Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId())){
					//Comprobamos si le ha salido un rechazo
					if(confirm.CNF_SEL_Tipo__c == Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_PARCIAL 
							|| confirm.CNF_SEL_Tipo__c == Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL){
						listWOc2c.addAll(mapaWOPorIdCaso.get(confirm.CNF_LKP_ParentId__c));
					}
				}
			}
		}
	}
    /**
     * Método para inicializar las variables necesarias para el funcionamiento del trigger
     * @param triggerNew: List<Confirmacion__c> del triggerNew
	 * @param triggerNewMap: Map<Id,Confirmacion__c> del triggerNew
     */
	private static void inicializaVariables(List<Confirmacion__c> triggerNew, Map<Id,Confirmacion__c> triggerNewMap){
		Set<Id> setIdCaso = new Set<Id>();
		for(Confirmacion__c c:triggerNew){
			setIdCaso.add(c.CNF_LKP_ParentId__c);
		}
		//mapaCaso = Util_Caso.getCaseById(setIdCaso);
		//mapaCaso = Util_Caso.getMapaCasos(setIdCaso);
		mapaWOPorIdCaso = Util_Orden_Trabajo.queryMapIdCaseOTByCase(setIdCaso);
		//mapaWOPorIdCaso = Util_Orden_Trabajo.queryOTBySet(null,mapaCaso.keySet(),null);
	}
}