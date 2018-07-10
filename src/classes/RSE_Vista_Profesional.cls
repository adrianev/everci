public without sharing class RSE_Vista_Profesional {

	public RSE_Vista_Profesional(){

	}

	public PageReference irFichaProfesional(){
		PageReference paginaRedireccion = null;
		List<ServiceResource> profs = Util_Service_Resource.getMapaRecursoRelatedId(new Set<Id>{UserInfo.getUserId()}).values();
		//List<ServiceResource> profs = Util_Service_Resource.queryMapSR('RelatedRecordId = \''+UserInfo.getUserId()+'\'').values();
		//List<ServiceResource> profs = Util_documentacion.querySR('RelatedRecordId = \''+UserInfo.getUserId()+'\'');
		if(!profs.isEmpty()){
			ServiceResource prof = profs.get(0);//[Select Id from ServiceResource Where RelatedRecordId =: UserInfo.getUserId()];
			paginaRedireccion = new PageReference('/'+prof.Id);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}
}