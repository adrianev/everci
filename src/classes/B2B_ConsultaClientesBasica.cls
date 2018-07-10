/**
 * Clase controladora de la Visualforce "B2B_ConsultaClientesBasica" encargada de exponer un servicio que liste las entidades de una compañía con datos básicos para la visualización en una lista.
 * 
 * @author EVERIS
 */
public without sharing class B2B_ConsultaClientesBasica {

	public without sharing class Resultado{
		String code = '';
		String message = '';
	}

	public static List<Contact> Consulta(B2B_ConsultaClientesBasica_RQ datos){
		system.debug('>>>>>mostrarEntrada: '+datos);
		List<Account> accountQuery = new List<Account>();
		accountQuery = [SELECT CUE_CAS_Activado__c,CUE_TXT_Numero_Documento__c,Id,Name,ShippingCity,ShippingCountry,ShippingPostalCode,
		                ShippingState,ShippingStreet FROM Account WHERE CUE_TXT_Identificador__c =: datos.CUE_TXT_Identificador AND CUE_CAS_Dada_de_Baja__c = false];
		system.debug('>>>>>MostrarLista: '+accountQuery);

		List<Contact> ctc_all = [SELECT AccountId,Email,Id,MobilePhone,Phone FROM Contact];

		List<Contact> cntct = new List<Contact>();

		for(Account acc:accountQuery){
			for(Contact ctc:ctc_all){
				if(acc.Id == ctc.AccountId){
					Contact contacto = new Contact();
					contacto.Email = ctc.Email;
					contacto.Id = ctc.Id;
					contacto.MobilePhone = ctc.MobilePhone;
					contacto.Phone = ctc.Phone;

					cntct.add(contacto);
				}
			}

		}
		system.debug('>>>>>MostrarResultado: '+cntct);
		return cntct;

	}

}