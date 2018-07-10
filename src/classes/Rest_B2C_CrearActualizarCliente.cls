/**
 * Clase utilizada para la creación o actualización de un cliente
 *
 * @author EVERIS
 */
@RestResource(urlMapping='/crearCliente')
global without sharing class Rest_B2C_CrearActualizarCliente {

	@HttpPost
	global static Rest_B2C_CrearActualizarCliente_RP doPost(String ShippingStreet, String ShippingCity, String CUE_SEL_Provincia, String ShippingPostalCode, 
		String CUE_SEL_Pais, String CUE_TXT_Nombre, String CUE_TXT_PrimerApellido, String CUE_TXT_SegundoApellido, String CUE_EMA_Email, String Phone,
		String Phone2, String CUE_LKP_Cuenta_principal, String CUE_SEL_Tipo_Documento, String CUE_TXT_Numero_Documento, String DeveloperName, String Type, 
		Boolean CUE_CAS_Robinson){

		Account cliente;
		Contact contacto;
		
		Rest_B2C_CrearActualizarCliente_RP respuesta = new Rest_B2C_CrearActualizarCliente_RP();

		try {
			
			//Comentado porque en DEV solo están cargados los CP de Madrid
			/*List<ServiceTerritory> codigoPostal = [SELECT Id FROM ServiceTerritory WHERE Name =: ShippingPostalCode];
			if (codigoPostal == null || codigoPostal.size() == 0) {
				respuesta.code = 'API-022';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				return respuesta;
			}*/
			
			if (Type != Label.CUE_TIPO_DIRECCION) {
				CUE_TXT_Numero_Documento = CUE_TXT_Numero_Documento.toUpperCase();
			}
			
			List<Account> cuenta = [SELECT Id, CUE_LKP_contacto_principal__c FROM Account WHERE CUE_TXT_Numero_Documento__c =: CUE_TXT_Numero_Documento AND CUE_LKP_Cuenta_principal__c =: CUE_LKP_Cuenta_principal];
			if (cuenta == null || cuenta.size() == 0) {
				
				cliente = new Account();
				
				if (Type == Label.CUE_TIPO_DIRECCION) {
					cliente.CUE_CAS_Activado__c = false;
					List<String> establecimientos = new List<String>();
					List<Account> establecimientosLista = [SELECT CUE_TXT_Establecimiento__c FROM Account WHERE (CUE_TXT_Identificador__c =: Label.IDE_WORTEN OR CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c =: Label.IDE_WORTEN) AND CUE_TXT_Establecimiento__c != null];
					for (Account tienda: establecimientosLista) {
						establecimientos.add(tienda.CUE_TXT_Establecimiento__c);
					}
					String numEstablecimiento = generarNumero(10000);
					while (establecimientos.contains(numEstablecimiento)) {
						numEstablecimiento = generarNumero(10000);
					}
					cliente.CUE_TXT_Establecimiento__c = numEstablecimiento;
				}
				else {
					cliente.CUE_CAS_Activado__c = true;
				}
				cliente.ShippingStreet = ShippingStreet;
				cliente.ShippingCity = ShippingCity;
				cliente.ShippingState = Util_Listas_Seleccion.getLabelDesdeAPI('Account','CUE_SEL_Provincia__c').get(CUE_SEL_Provincia);
				cliente.CUE_SEL_Provincia__c = CUE_SEL_Provincia;
				cliente.ShippingPostalCode = ShippingPostalCode;
				cliente.CUE_SEL_Pais__c = CUE_SEL_Pais;
				cliente.CUE_TXT_Nombre__c = CUE_TXT_Nombre;
				cliente.CUE_TXT_PrimerApellido__c = CUE_TXT_PrimerApellido;
				cliente.CUE_TXT_SegundoApellido__c = CUE_TXT_SegundoApellido;
				cliente.CUE_EMA_Email__c = CUE_EMA_Email;
				cliente.Phone = Phone;
				cliente.CUE_LKP_Cuenta_principal__c = CUE_LKP_Cuenta_principal;
				cliente.CUE_SEL_Tipo_Documento__c = CUE_SEL_Tipo_Documento;
				cliente.CUE_TXT_Numero_Documento__c = CUE_TXT_Numero_Documento;
				cliente.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(DeveloperName);
				cliente.Type = Type;
				cliente.CUE_CAS_Robinson__c = CUE_CAS_Robinson;
				insert cliente;
				
				if (Type != Label.CUE_TIPO_DIRECCION) {
					contacto = new Contact();
					contacto.AccountId = cliente.Id;
					contacto.FirstName = CUE_TXT_Nombre;
					contacto.LastName = CUE_TXT_PrimerApellido;
					if (!String.isEmpty(CUE_TXT_SegundoApellido)) {
						contacto.LastName += ' ' + CUE_TXT_SegundoApellido;
					}
					contacto.Phone = Phone;
					contacto.MobilePhone = Phone2;
					contacto.Email = CUE_EMA_Email;
					contacto.CON_CAS_Contacto_principal__c = true;
					insert contacto;
				}
				else {
					//Se tiene que crear una tarea
					List<Account> ownerCuenta = [SELECT CUE_LKP_Cuenta_principal__r.OwnerId FROM Account WHERE Id =: cliente.Id];
					Task tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN, 'Activación y configuración de Dirección', Label.TAR_ESTADO_EN_CURSO, Label.TAR_TIPO_ACTIVACION_CONFIGURACION_DIRECCION, ownerCuenta[0].CUE_LKP_Cuenta_principal__r.OwnerId, cliente.Id, CUE_LKP_Cuenta_principal);
					insert tarea;
				}
				
				respuesta.Id = cliente.Id;
			}
			else {
				
				//actualizarContacto
				cuenta[0].ShippingStreet = ShippingStreet;
				cuenta[0].ShippingCity = ShippingCity;
				cuenta[0].ShippingState = Util_Listas_Seleccion.getLabelDesdeAPI('Account','CUE_SEL_Provincia__c').get(CUE_SEL_Provincia);
				cuenta[0].CUE_SEL_Provincia__c = CUE_SEL_Provincia;
				cuenta[0].ShippingPostalCode = ShippingPostalCode;
				cuenta[0].CUE_SEL_Pais__c = CUE_SEL_Pais;
				cuenta[0].CUE_TXT_Nombre__c = CUE_TXT_Nombre;
				cuenta[0].CUE_TXT_PrimerApellido__c = CUE_TXT_PrimerApellido;
				cuenta[0].CUE_TXT_SegundoApellido__c = CUE_TXT_SegundoApellido;
				cuenta[0].CUE_EMA_Email__c = CUE_EMA_Email;
				cuenta[0].Phone = Phone;
				cuenta[0].CUE_LKP_Cuenta_principal__c = CUE_LKP_Cuenta_principal;
				cuenta[0].CUE_SEL_Tipo_Documento__c = CUE_SEL_Tipo_Documento;
				cuenta[0].CUE_TXT_Numero_Documento__c = CUE_TXT_Numero_Documento;
				cuenta[0].RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(DeveloperName);
				cuenta[0].Type = Type;
				cuenta[0].CUE_CAS_Robinson__c = CUE_CAS_Robinson;
				update cuenta;
				
				if (Type != Label.CUE_TIPO_DIRECCION) {
					if (String.isEmpty(cuenta[0].CUE_LKP_contacto_principal__c)) {
						
						contacto = new Contact();
						contacto.AccountId = cuenta[0].Id;
						contacto.FirstName = CUE_TXT_Nombre;
						contacto.LastName = CUE_TXT_PrimerApellido;
						if (!String.isEmpty(CUE_TXT_SegundoApellido)) {
							contacto.LastName += ' ' + CUE_TXT_SegundoApellido;
						}
						contacto.Phone = Phone;
						contacto.MobilePhone = Phone2;
						contacto.Email = CUE_EMA_Email;
						contacto.CON_CAS_Contacto_principal__c = true;
						insert contacto;
					}
					else {
						List<Contact> contactoPrincipal = Util_Contacto.getContactById(new Set<Id>{cuenta[0].CUE_LKP_contacto_principal__c}).values();
						
						contactoPrincipal[0].AccountId = cuenta[0].Id;
						contactoPrincipal[0].FirstName = CUE_TXT_Nombre;
						contactoPrincipal[0].LastName = CUE_TXT_PrimerApellido;
						if (!String.isEmpty(CUE_TXT_SegundoApellido)) {
							contactoPrincipal[0].LastName += ' ' + CUE_TXT_SegundoApellido;
						}
						contactoPrincipal[0].Phone = Phone;
						contactoPrincipal[0].MobilePhone = Phone2;
						contactoPrincipal[0].Email = CUE_EMA_Email;
						contactoPrincipal[0].CON_CAS_Contacto_principal__c = true;
						update contactoPrincipal;
					}
				}
				
				respuesta.Id = cuenta[0].Id;
			}
			respuesta.code = 'API-001';
			respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
		}
		catch(Exception e){
			system.debug('>>>>>>>EXCEPTION: ' + e + ' ' + e.getStackTraceString());
			//Comprobamos si están los datos mal formados
			if ((!String.isEmpty(ShippingStreet) && ShippingStreet.length() > 255) || !String.isEmpty(ShippingCity) && ShippingCity.length() > 40 || !String.isEmpty(CUE_SEL_Provincia) && CUE_SEL_Provincia.length() > 255 || !String.isEmpty(ShippingPostalCode) && ShippingPostalCode.length() > 20 ||
				!String.isEmpty(CUE_SEL_Pais) && CUE_SEL_Pais.length() > 255 || !String.isEmpty(CUE_TXT_Nombre) && CUE_TXT_Nombre.length() > 40 || !String.isEmpty(CUE_TXT_PrimerApellido) && CUE_TXT_PrimerApellido.length() > 80 || 
				!String.isEmpty(CUE_TXT_SegundoApellido) && CUE_TXT_SegundoApellido.length() > 80 || (!String.isEmpty(CUE_EMA_Email) && CUE_EMA_Email.contains('@') == false || CUE_EMA_Email.length() > 80) || !String.isEmpty(Phone) && Phone.length() > 40 ||
				!String.isEmpty(CUE_LKP_Cuenta_principal) && CUE_LKP_Cuenta_principal.length() > 15 || !String.isEmpty(CUE_SEL_Tipo_Documento) && CUE_SEL_Tipo_Documento.length() > 255 || !String.isEmpty(CUE_TXT_Numero_Documento) && CUE_TXT_Numero_Documento.length() > 20 ||
				!String.isEmpty(Type) && Type.length() > 255) {
				respuesta.code = 'API-004';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
			}
			else {
				respuesta.code = 'API-014';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
			}
		}
		system.debug('>>>>>>>doPost.respuesta: ' + respuesta);
		return respuesta;
	}
	
	/**
    * Función para generar un número aleatorio
    *
    */
    public static String generarNumero(Integer size){
    	Double d = math.random() * size;
    	Integer i = Integer.valueOf(d);
    	return string.valueOf(i);
    }
	
}