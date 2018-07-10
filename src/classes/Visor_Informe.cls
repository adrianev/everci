/**
 * Clase controladora de la Visualforce "Visor_Informe" encargada de visualizar informes con auto-recarga.
 * 
 * @author EVERIS
 */
public without sharing class Visor_Informe {
	private String informeDevName;
	private Id informeId;
	public Boolean recargar {get;set;}

	public Visor_Informe(){
		recargar = false;
		PageReference paginaActual = ApexPages.currentPage();
		String urlContexto = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
		system.debug('<<<<contexto' + urlContexto);
		if(paginaActual.getParameters().containsKey('informe')){
			informeDevName = paginaActual.getParameters().get('informe');
			List<Report> rep = Util_Report.queryMapInforme(new Set<String>{informeDevName}).values();
			if(!rep.isEmpty()){
				informeId = rep.get(0).Id;
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
	}

	public String getContenidoInforme(){
		PageReference paginaInforme = new PageReference('/' + informeId);
		paginaInforme.getParameters().put('inline','0');
		paginaInforme.setRedirect(false);
		return paginaInforme.getContent().toString();
	}
	public String getInformeId(){
		return informeId;
	}

	public void activarRecarga(){
		recargar = true;
	}	

	public String getURLRecarga(){
		return '/apex/Visor_Informe?informe=' + informeDevName;		
	}
}