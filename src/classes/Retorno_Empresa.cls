public without sharing class Retorno_Empresa{
	private PageReference paginaRedireccion;

	public PageReference redireccionEmpresa(){
		paginaRedireccion = new PageReference('/apex/Visor_Informe');
		paginaRedireccion.getParameters().put('informe','Empresas_y_contratos');
		paginaRedireccion.getParameters().put('inline','1');
		paginaRedireccion.getParameters().put('isdtp','nv');
		return paginaRedireccion;
	}
}