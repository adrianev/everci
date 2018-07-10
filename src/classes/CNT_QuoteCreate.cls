public without sharing class CNT_QuoteCreate {
	Public String paginaRetorno;
	Public String solicitudExistente;
	Public String fase {get; set;}
	Public String casoRet{get; set;}

	Public CNT_QuoteCreate(){
		PageReference paginaActual = ApexPages.currentPage();
		if (paginaActual.getParameters().containsKey('id'))
		{
			casoRet = paginaActual.getParameters().get('id');
		} 
		if (paginaActual.getParameters().containsKey('retorno'))
		{
			paginaRetorno = paginaActual.getParameters().get('retorno');
		} 
		if (paginaActual.getParameters().containsKey('solicitudExistente'))
		{
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}
		if (paginaActual.getParameters().containsKey('fase'))
		{
			fase = paginaActual.getParameters().get('fase');
		}
	}

	public PageReference volver()
	{
		// Navegar al alta de gremios
		PageReference paginaRedireccion = new PageReference(paginaRetorno);
		paginaRedireccion.getParameters().put('id', casoRet);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver() 
}