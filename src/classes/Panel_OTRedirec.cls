public without sharing class Panel_OTRedirec {

	public Panel_OTRedirec(){}

	public PageReference irOTencurso(){
		List<Report> rep = Util_Report.queryMapInforme(new Set<String>{Label.OTR_PANEL_EN_CURSO}).values();
		//List<Report> rep = [SELECT ID FROM REPORT WHERE DEVELOPERNAME =: Label.OTR_PANEL_EN_CURSO];
		PageReference paginaRedireccion;
		if (!rep.isEmpty()){
			paginaRedireccion = new PageReference('/'+rep.get(0).Id);
		}
		paginaRedireccion.setRedirect(true);


		return paginaRedireccion;
	}

	public PageReference irOTcerrada(){
		List<Report> rep = Util_Report.queryMapInforme(new Set<String>{Label.OTR_PANEL_CERRADAS}).values();
		//List<Report> rep = [SELECT ID FROM REPORT WHERE DEVELOPERNAME =: Label.OTR_PANEL_CERRADAS];
		PageReference paginaRedireccion;
		if (!rep.isEmpty()){
			paginaRedireccion = new PageReference('/'+rep.get(0).Id);
		}
		paginaRedireccion.setRedirect(true);

		return paginaRedireccion;
	}
	
	
	public PageReference irReclamaciones(){
		List<Report> rep = Util_Report.queryMapInforme(new Set<String>{Label.CAS_PANEL_RECLAMACION}).values();
		//List<Report> rep = [SELECT ID FROM REPORT WHERE DEVELOPERNAME =: Label.CAS_PANEL_RECLAMACION];
		PageReference paginaRedireccion;
		if (!rep.isEmpty()){
			paginaRedireccion = new PageReference('/'+rep.get(0).Id);
		}
		paginaRedireccion.setRedirect(true);

		return paginaRedireccion;
	}
}