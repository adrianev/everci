public without sharing class SiniSimulacionSondeoExternoController {

	public String caseId {get; set;}
	public String companyExternalId {get; set;}
	public String customerEmail {get; set;}
	public String customerZipCode {get; set;}
	public String documentNumber {get; set;}
	public String language {get; set;}
	public String policyCompanyExternalId {get; set;}
	public String typeRisk {get; set;}
	public String whoCalls {get; set;}
	public String returnURLOK {get; set;}
	public String returnURLKO {get; set;}

	public SiniSimulacionSondeoExternoController(ApexPages.standardController stdCtr)
	{
		PageReference paginaActual = ApexPages.currentPage();
		caseId = paginaActual.getParameters().get('CaseId');
		companyExternalId = paginaActual.getParameters().get('CompanyExternalId');
		customerEmail = paginaActual.getParameters().get('CustomerEmail');
		customerZipCode = paginaActual.getParameters().get('CustomerZipCode');
		documentNumber = paginaActual.getParameters().get('DocumentNumber');
		language = paginaActual.getParameters().get('Language');
		policyCompanyExternalId = paginaActual.getParameters().get('PolicyCompanyExternalId');
		typeRisk = paginaActual.getParameters().get('TypeRisk');
		whoCalls = paginaActual.getParameters().get('WhoCalls');
		returnURLOK = paginaActual.getParameters().get('returnURLOK');
		returnURLKO = paginaActual.getParameters().get('returnURLKO');
	}

	public PageReference retornoSondeoOK()
	{
		PageReference paginaRedireccion = new PageReference(returnURLOK);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	public PageReference retornoSondeoKO()
	{
		PageReference paginaRedireccion = new PageReference(returnURLKO);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}
}