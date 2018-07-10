/**
 * Clase que expone un servicio para la consulta de clientes B2B padres, y clientes B2B hijos
 *
 * @author EVERIS
 *
 */
@RestResource(urlMapping='/b2bConsultaClientes/*')

global without sharing class Rest_B2B_ConsultaClientes {

	private static String requestBody;
	private static Integer contParametros;

	/**
	 * Método para la consulta de clientes B2B padres e hijos
	 *
	 * @param CUE_TXT_Identificador: Identificador de la compañía B2B2C.
	 *
	 */

	@HttpPost
	global static void doPost(String CUE_TXT_Identificador, List<String> Type){
		
        //Control para los errores del campo "Type"
        if (Type != null && Type.size() != 0) {
        	if (Type.size() == 1) {
        		if (String.valueOf(Type[0]).length() != 2 || Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'Type').get(Type[0]) == null) {
        			requestBody = '{'+ Util_WS_Error.devolverMensaje('API-021') +'}';
        			if (!test.isRunningTest()) {
						RestContext.response.addHeader('Content-Type', 'application/json');
						RestContext.response.responseBody = Blob.valueOf(requestBody);
					}
        		}
        		else {
        			consultaClientes(CUE_TXT_Identificador,Type);
        		}
        	}
        	else {
        		//Cuando es mayor que uno el tamaño
        		for (String typeSplit: Type) {
        			if (typeSplit.length() != 2 || Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'Type').get(typeSplit) == null) {
            			requestBody = '{'+ Util_WS_Error.devolverMensaje('API-021') +'}';
            			if (!test.isRunningTest()) {
							RestContext.response.addHeader('Content-Type', 'application/json');
							RestContext.response.responseBody = Blob.valueOf(requestBody);
						}
            		}
        		}
        		if (String.isEmpty(requestBody)) {
        			consultaClientes(CUE_TXT_Identificador,Type);
        		}
        	}
        }
        else {
        	consultaClientes(CUE_TXT_Identificador,Type);
        }
		system.debug('Respuesta: ' + requestBody);
	}
	
	/**
	 * Método que realiza la consulta de los clientes
	 *
	 * @param CUE_TXT_Identificador: Identificador de la compañia
	 * @param Type: Tipo de clientes que se quiere consultar
	 *
	 */
	
	private static void consultaClientes(String CUE_TXT_Identificador, List<String> Type) {
		try{
            List<Account> listaCuentaFind = new List<Account>();
            List<VDN_Compania__c> listaVDN = new List<VDN_Compania__c>();
            List<Configuracion_VDN__mdt> listaVDNmdt = new List<Configuracion_VDN__mdt>();
            List<String> listaIdentificadores = new List<String>();
            Map<String, List<Configuracion_VDN__mdt>> mapaVDNmdt = new Map<String, List<Configuracion_VDN__mdt>>();
			
        	if(validateId(CUE_TXT_Identificador)!=null)
            {
            	listaCuentaFind= new List<Account>([SELECT Id,RecordTypeId,CUE_TXT_Identificador__c FROM Account WHERE Id =: CUE_TXT_Identificador AND CUE_CAS_Dada_de_Baja__c = false]);
            }    
            else {
            	listaCuentaFind = new List<Account>([SELECT Id,RecordTypeId,CUE_TXT_Identificador__c FROM Account WHERE (CUE_TXT_Identificador__c =: CUE_TXT_Identificador AND CUE_CAS_Dada_de_Baja__c = false)]);
            }
            
			List<String> listaRecordTypeIds = new List<String>();
			List<RecordType> listaRecordTypeName = new List<RecordType>([SELECT Name FROM RecordType WHERE Id =: listaCuentaFind[0].RecordTypeId]);
			
			//contParametros se usa para el control de las "," de los JSON
			contParametros = 0;
			//Código para Cliente B2B/B2B2C principal
			if (listaRecordTypeName[0].Name == 'Cliente B2B/B2B2C principal'){
				List<Account> listaClientesfinalesInfo;
				//Conseguir clientesFinales de la clase principal
				List<Account> listaClientesfinales = new List<Account>([SELECT Id FROM Account WHERE Id =: listaCuentaFind[0].Id]);
				//List<Account> listaClientesfinales = new List<Account>([SELECT Id FROM Account WHERE CUE_LKP_Cuenta_principal__c =: listaCuentaFind[0].Id]);		
				List<String> listaClientesFin = new List<String>();
				for(Account recordTypeIds : listaClientesfinales){
					listaClientesFin.add(recordTypeIds.Id);
				}
				if (Type != null && Type.size() > 0) {
					listaClientesfinalesInfo = new List<Account>([SELECT CUE_CAS_No_permite_Servicio_B2B2C__c
				                                                            ,CUE_TXT_Establecimiento__c
				                                                            ,CUE_CAS_Activado__c,CUE_EMA_Email__c
				                                                            ,CUE_TXT_Numero_Documento__c
				                                                            ,CUE_CAS_Permite_Servicio_CodActivac__c
				                                                            ,CUE_FOR_Ppal_No_Permite_Servicio_B2C__c
				                                                            ,CUE_LKP_Cuenta_principal__c
				                                                            ,Id
				                                                            ,Name
				                                                            ,Phone
				                                                            ,Type
				                                                            ,ShippingCity
				                                                            ,ShippingCountry
				                                                            ,ShippingPostalCode
				                                                            ,ShippingState
				                                                            ,ShippingStreet
				                                                            ,RecordTypeId 
				                                                            ,CUE_DAT_Inicio_ola_calor__c
				                                                            ,CUE_DAT_Fin_ola_calor__c
				                                                            ,CUE_TXT_Identificador__c
				                                                            FROM Account 
				                                                            WHERE (CUE_LKP_Cuenta_principal__c  IN: listaClientesFin AND CUE_CAS_Dada_de_Baja__c = false AND Type IN: Type)]);
				}
				else {
					listaClientesfinalesInfo = new List<Account>([SELECT CUE_CAS_No_permite_Servicio_B2B2C__c
				                                                            ,CUE_TXT_Establecimiento__c
				                                                            ,CUE_CAS_Activado__c
				                                                            ,CUE_EMA_Email__c
				                                                            ,CUE_TXT_Numero_Documento__c
				                                                            ,CUE_CAS_Permite_Servicio_CodActivac__c
				                                                            ,CUE_FOR_Ppal_No_Permite_Servicio_B2C__c
				                                                            ,CUE_LKP_Cuenta_principal__c
				                                                            ,Id
				                                                            ,Name
				                                                            ,Phone
				                                                            ,Type
				                                                            ,ShippingCity
				                                                            ,ShippingCountry
				                                                            ,ShippingPostalCode
				                                                            ,ShippingState
				                                                            ,ShippingStreet
				                                                            ,RecordTypeId 
				                                                            ,CUE_DAT_Inicio_ola_calor__c
				                                                            ,CUE_DAT_Fin_ola_calor__c
				                                                            ,CUE_TXT_Identificador__c
				                                                            FROM Account 
				                                                            WHERE (CUE_LKP_Cuenta_principal__c  IN: listaClientesFin AND CUE_CAS_Dada_de_Baja__c = false)]);
				}
				
				contParametros = 0;
				List<Account> listaCliente = new List<Account>([SELECT CUE_CAS_No_permite_Servicio_B2B2C__c
				                                                ,CUE_CAS_Activado__c
				                                                ,CUE_EMA_Email__c
				                                                ,CUE_LKP_Cuenta_principal__c
				                                                ,Id
				                                                ,Type
				                                                ,Name
				                                                ,Phone
				                                                ,ShippingCity
				                                                ,ShippingCountry
				                                                ,ShippingPostalCode
				                                                ,ShippingState
				                                                ,ShippingStreet 
				                                                ,RecordTypeId
				                                                ,CUE_CAS_Permite_Servicio_CodActivac__c
				                                                ,CUE_TXT_Numero_Documento__c
				                                                ,CUE_FOR_Ppal_No_Permite_Servicio_B2C__c
				                                                ,CUE_TXT_Identificador__c
				                                                ,CUE_TXT_Establecimiento__c
				                                                ,CUE_DAT_Inicio_ola_calor__c
				                                                ,CUE_DAT_Fin_ola_calor__c
				                                                FROM Account WHERE (CUE_TXT_Identificador__c =: listaCuentaFind[0].CUE_TXT_Identificador__c AND CUE_CAS_Dada_de_Baja__c = false)]);						
				// Lista que se utiliza para los gremios													
				List<Procedencia__c> listaProcedencia = new List<Procedencia__c>([SELECT PROC_SEL_Gremios_Disp__c, PROC_SEL_Tipos_Caso__c, PROC_TXT_Identificador__c, Id FROM Procedencia__c WHERE PROC_LKP_Cuenta__c =: listaCliente[0].Id]);
				// Lista que se utiliza para guardar los contactos
				List<Contact> listaContactos = new List<Contact>([SELECT CON_CAS_Contacto_principal__c
				                                                  ,Email
				                                                  ,FirstName
				                                                  ,Phone
				                                                  ,Id
				                                                  ,LastName
				                                                  ,MobilePhone
				                                                  ,Name 
				                                                  FROM Contact WHERE AccountId =: listaCliente[0].Id]);		
				
				
				//Lista que se utiliza para guardar VDN
				listaVDN = [SELECT VDN_SEL_Idioma__c,VDN_TXT_Identificador__c, VDN_TLF_Telefono__c FROM VDN_Compania__c WHERE VDN_LKP_Compania__c =: listaCliente[0].Id];
				for (VDN_Compania__c identVDN: listaVDN) {
					listaIdentificadores.add(identVDN.VDN_TXT_Identificador__c);
				}
				if (listaVDN != null && listaVDN.size() > 0) {
					listaVDNmdt = [SELECT LoadId__c,ServiceId__c,VDN_Number__c FROM Configuracion_VDN__mdt WHERE VDN_Number__c IN : listaIdentificadores AND LoadId__c != NULL AND ServiceId__c != NULL];
				}
				if (!listaVDNmdt.isEmpty()) {
					for (Configuracion_VDN__mdt VDNmdt: listaVDNmdt) {
						if (mapaVDNmdt.containsKey(VDNmdt.VDN_Number__c)) {
							mapaVDNmdt.get(VDNmdt.VDN_Number__c).add(VDNmdt);
						}
						else {
							mapaVDNmdt.put(VDNmdt.VDN_Number__c,new List<Configuracion_VDN__mdt>{VDNmdt});
						}
					}
				}
				
				
				List<Contract> listaContrat = new List<Contract>([SELECT ContractNumber,CTR_NUM_Version_Contrato__c,Name FROM Contract WHERE AccountId =: listaCuentaFind[0].Id]);			
				requestBody = '{';
				requestBody += Util_WS_Error.devolverMensaje('API-001')+',';
				concatenarParametroJSON('PROC_TXT_Identificador',  listaProcedencia[0].PROC_TXT_Identificador__c);
				anadirVDN(listaVDN, mapaVDNmdt);
				anadirContratos(listaContrat);
				requestBody +=',"listadoClientes" :[';
				requestBody +='{"cliente" :{';
				String calle;
				if(listaCliente[0].ShippingStreet != null){
					calle = listaCliente[0].ShippingStreet;
					if (calle.contains('\n')){
						calle = calle.replaceAll('\n',' ');
					}
				}
				concatenarParametroJSON('ShippingStreet',  calle);
				concatenarParametroJSON('ShippingCity',  listaCliente[0].ShippingCity);
				concatenarParametroJSON('CUE_SEL_Provincia',  listaCliente[0].ShippingState);
				concatenarParametroJSON('ShippingPostalCode',  listaCliente[0].ShippingPostalCode);
				concatenarParametroJSON('CUE_SEL_Pais',  listaCliente[0].ShippingCountry);
				concatenarParametroJSON('CUE_CAS_Activado', listaCliente[0].CUE_CAS_Activado__c);
				concatenarParametroJSON('Id',  listaCliente[0].Id);
				concatenarParametroJSON('CUE_LKP_Cuenta_principal', '');
				String nombre;
				if(listaCliente[0].Name != null){
					nombre = listaCliente[0].Name;
					if (nombre.contains('"')){
						nombre = nombre.replaceAll('"','');
					}
				}
				concatenarParametroJSON('Name',  nombre);//concatenarParametroJSON('Name',  listaCliente[0].Name);
				concatenarParametroJSON('CUE_EMA_Email',  listaCliente[0].CUE_EMA_Email__c);
				concatenarParametroJSON('Phone',  listaCliente[0].Phone);
				concatenarParametroJSON('esPrincipal',  true);
				concatenarParametroJSON('Type',  listaCliente[0].Type);
				concatenarParametroJSON('CUE_CAS_Permite_Servicio_CodActivac',  listaCliente[0].CUE_CAS_Permite_Servicio_CodActivac__c);	
				concatenarParametroJSON('CUE_TXT_Numero_Documento',  listaCliente[0].CUE_TXT_Numero_Documento__c);	
				concatenarParametroJSON('CUE_FOR_Ppal_No_Permite_Servicio_B2C',  listaCliente[0].CUE_FOR_Ppal_No_Permite_Servicio_B2C__c);	
				concatenarParametroJSON('CUE_CAS_No_permite_Servicio_B2B2C',  listaCliente[0].CUE_CAS_No_permite_Servicio_B2B2C__c);
				concatenarParametroJSON('CUE_TXT_Establecimiento',  listaCliente[0].CUE_TXT_Establecimiento__c);
				/*Cambios realizados para añadir la ola de calor*/
				Date fechaHoy = date.today().addDays(2);
				if (!String.isEmpty(String.valueOf(listaCliente[0].CUE_DAT_Inicio_ola_calor__c)) && !String.isEmpty(String.valueOf(listaCliente[0].CUE_DAT_Fin_ola_calor__c))) {
					if (fechaHoy.month() > listaCliente[0].CUE_DAT_Inicio_ola_calor__c.month() && fechaHoy.month() < listaCliente[0].CUE_DAT_Fin_ola_calor__c.month()) {
						concatenarParametroJSON('OlaCalor',  true);
					}
					else if (fechaHoy.month() == listaCliente[0].CUE_DAT_Inicio_ola_calor__c.month()) {
						if (fechaHoy.day() >= listaCliente[0].CUE_DAT_Inicio_ola_calor__c.day()) {
							concatenarParametroJSON('OlaCalor',  true);
						}
						else {
							concatenarParametroJSON('OlaCalor',  false);
						}
					}
					else if (fechaHoy.month() == listaCliente[0].CUE_DAT_Fin_ola_calor__c.month()) {
						if (fechaHoy.day() <= listaCliente[0].CUE_DAT_Fin_ola_calor__c.day()) {
							concatenarParametroJSON('OlaCalor',  true);
						}
						else {
							concatenarParametroJSON('OlaCalor',  false);
						}
					}
					else {
						concatenarParametroJSON('OlaCalor',  false);
					}
				}
				else {
					concatenarParametroJSON('OlaCalor',  false);
				}
				/*Fin de cambios de ola de calor*/			
				requestBody +='}}';
				//Bucle clientes hijos							
				for(Account clientes:listaClientesfinalesInfo){
					if(contParametros != 0)
						requestBody += ',';
					contParametros = 0;
					requestBody +='{"cliente":{';	
					if(clientes.ShippingStreet != null){
						calle = clientes.ShippingStreet;
						if (calle.contains('\n')){
							calle = calle.replaceAll('\n',' ');
						}
					}	
					concatenarParametroJSON('ShippingStreet',  calle);
					concatenarParametroJSON('ShippingCity',  clientes.ShippingCity);
					concatenarParametroJSON('CUE_SEL_Provincia',  clientes.ShippingState);
					concatenarParametroJSON('ShippingPostalCode',  clientes.ShippingPostalCode);	
					concatenarParametroJSON('CUE_SEL_Pais',  clientes.ShippingCountry);	
					concatenarParametroJSON('CUE_CAS_Activado', clientes.CUE_CAS_Activado__c);		
					concatenarParametroJSON('Id',  clientes.Id);
					concatenarParametroJSON('CUE_LKP_Cuenta_principal', clientes.CUE_LKP_Cuenta_principal__c);
					concatenarParametroJSON('CUE_TXT_Establecimiento',  clientes.CUE_TXT_Establecimiento__c);
					if(clientes.Name != null){
						nombre = clientes.Name;
						if (nombre.contains('"')){
							nombre = nombre.replaceAll('"','');
						}
					}
					concatenarParametroJSON('Name', nombre);//concatenarParametroJSON('Name', clientes.Name);
					concatenarParametroJSON('CUE_EMA_Email',  clientes.CUE_EMA_Email__c);
					concatenarParametroJSON('Phone',  clientes.Phone);
					concatenarParametroJSON('esPrincipal',  false);
					concatenarParametroJSON('Type',  clientes.Type);
					concatenarParametroJSON('CUE_CAS_Permite_Servicio_CodActivac',  clientes.CUE_CAS_Permite_Servicio_CodActivac__c);	
					concatenarParametroJSON('CUE_TXT_Numero_Documento',  clientes.CUE_TXT_Numero_Documento__c);	
					concatenarParametroJSON('CUE_FOR_Ppal_No_Permite_Servicio_B2C',  clientes.CUE_FOR_Ppal_No_Permite_Servicio_B2C__c);	
					concatenarParametroJSON('CUE_CAS_No_permite_Servicio_B2B2C',  clientes.CUE_CAS_No_permite_Servicio_B2B2C__c);	
					/*Cambios realizados para añadir la ola de calor*/
					if (!String.isEmpty(String.valueOf(clientes.CUE_DAT_Inicio_ola_calor__c)) && !String.isEmpty(String.valueOf(clientes.CUE_DAT_Fin_ola_calor__c))) {
						if (fechaHoy.month() > clientes.CUE_DAT_Inicio_ola_calor__c.month() && fechaHoy.month() < clientes.CUE_DAT_Fin_ola_calor__c.month()) {
							concatenarParametroJSON('OlaCalor',  true);
						}
						else if (fechaHoy.month() == clientes.CUE_DAT_Inicio_ola_calor__c.month()) {
							if (fechaHoy.day() >= clientes.CUE_DAT_Inicio_ola_calor__c.day()) {
								concatenarParametroJSON('OlaCalor',  true);
							}
							else {
								concatenarParametroJSON('OlaCalor',  false);
							}
						}
						else if (fechaHoy.month() == clientes.CUE_DAT_Fin_ola_calor__c.month()) {
							if (fechaHoy.day() <= clientes.CUE_DAT_Fin_ola_calor__c.day()) {
								concatenarParametroJSON('OlaCalor',  true);
							}
							else {
								concatenarParametroJSON('OlaCalor',  false);
							}
						}
						else {
							concatenarParametroJSON('OlaCalor',  false);
						}
					}
					else {
						concatenarParametroJSON('OlaCalor',  false);
					}
					/*Fin de cambios de ola de calor*/	
					requestBody +='}}';
				}
				requestBody +=']';	
				anadirGremios(listaProcedencia);	
				anadirContactos(listaContactos);	
				requestBody += '}';	

				//código para Cliente B2B/B2B2C secundario		
			}else if(listaRecordTypeName[0].Name == 'Cliente B2B/B2B2C secundario'){
				
				List<Procedencia__c> listaProcedencia;
				List<Contact> listaContactos;
				List<Contract> listaContrat;
				List<Account> listaCliente;
				
				// Lista usada para el cliente hijo
				if (Type != null && Type.size() > 0) {
					listaCliente = new List<Account>([SELECT Type,CUE_FOR_Ppal_No_Permite_Servicio_B2C__c,CUE_CAS_Permite_Servicio_CodActivac__c,
												CUE_CAS_No_permite_Servicio_B2B2C__c,CUE_LKP_Cuenta_principal__c, CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c, 
												CUE_TXT_Establecimiento__c,CUE_CAS_Activado__c,CUE_EMA_Email__c,CUE_TXT_Numero_Documento__c,Id,Name,Phone,ShippingCity,
												ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,CUE_DAT_Inicio_ola_calor__c,CUE_DAT_Fin_ola_calor__c,
												CUE_TXT_Identificador__c FROM Account WHERE (CUE_TXT_Identificador__c =: listaCuentaFind[0].CUE_TXT_Identificador__c 
												AND CUE_CAS_Dada_de_Baja__c = false AND Type IN: Type)]);
				}
				else {
					listaCliente = new List<Account>([SELECT Type,CUE_FOR_Ppal_No_Permite_Servicio_B2C__c,CUE_CAS_Permite_Servicio_CodActivac__c,
												CUE_CAS_No_permite_Servicio_B2B2C__c,CUE_LKP_Cuenta_principal__c, CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c, 
												CUE_TXT_Establecimiento__c,CUE_CAS_Activado__c,CUE_EMA_Email__c,CUE_TXT_Numero_Documento__c,Id,Name,Phone,ShippingCity,
												ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,CUE_DAT_Inicio_ola_calor__c,CUE_DAT_Fin_ola_calor__c,
												CUE_TXT_Identificador__c FROM Account WHERE (CUE_TXT_Identificador__c =: listaCuentaFind[0].CUE_TXT_Identificador__c 
												AND CUE_CAS_Dada_de_Baja__c = false)]);
				}
				

				if(listaCliente != null && listaCliente.size() > 0) {
					// Lista que se usa para los gremios
					listaProcedencia = new List<Procedencia__c>([SELECT PROC_SEL_Gremios_Disp__c, PROC_SEL_Tipos_Caso__c, PROC_TXT_Identificador__c, Id FROM Procedencia__c WHERE PROC_LKP_Cuenta__c =: listaCliente[0].CUE_LKP_Cuenta_principal__c]);
					// Lista que se utiliza para los contactos
					listaContactos = new List<Contact>([SELECT CON_CAS_Contacto_principal__c,Email,FirstName,Phone,Id,LastName,MobilePhone,Name FROM Contact WHERE AccountId =: listaCliente[0].Id]);
					// Lista  que se utiliza para los contratos
					listaContrat =  new List<Contract>([SELECT ContractNumber,CTR_NUM_Version_Contrato__c,Name FROM Contract WHERE AccountId =: listaCliente[0].CUE_LKP_Cuenta_principal__c]);
					
					
					//Lista que se utiliza para guardar VDN
					listaVDN = [SELECT VDN_SEL_Idioma__c,VDN_TXT_Identificador__c, VDN_TLF_Telefono__c FROM VDN_Compania__c WHERE VDN_LKP_Compania__c =: listaCliente[0].CUE_LKP_Cuenta_principal__c];
					for (VDN_Compania__c identVDN: listaVDN) {
						listaIdentificadores.add(identVDN.VDN_TXT_Identificador__c);
					}
					if (listaVDN != null && listaVDN.size() > 0) {
						listaVDNmdt = [SELECT LoadId__c,ServiceId__c,VDN_Number__c FROM Configuracion_VDN__mdt WHERE VDN_Number__c IN : listaIdentificadores AND LoadId__c != NULL AND ServiceId__c != NULL];
					}
					if (!listaVDNmdt.isEmpty()) {
						for (Configuracion_VDN__mdt VDNmdt: listaVDNmdt) {
							if (mapaVDNmdt.containsKey(VDNmdt.VDN_Number__c)) {
								mapaVDNmdt.get(VDNmdt.VDN_Number__c).add(VDNmdt);
							}
							else {
								mapaVDNmdt.put(VDNmdt.VDN_Number__c,new List<Configuracion_VDN__mdt>{VDNmdt});
							}
						}
					}
				}
				
				
				requestBody = '{';
				requestBody += Util_WS_Error.devolverMensaje('API-001')+',';
				if (listaCliente != null && listaCliente.size() > 0) {
					concatenarParametroJSON('PROC_TXT_Identificador',  listaProcedencia[0].PROC_TXT_Identificador__c);
				}
				else {
					concatenarParametroJSON('PROC_TXT_Identificador',  '');
				}
				anadirVDN(listaVDN, mapaVDNmdt);
				anadirContratos(listaContrat);
				requestBody +=',"listadoClientes" :[';
				if (listaCliente != null && listaCliente.size() > 0) {
					requestBody +='{"cliente" :{';
					String calle;
					if(listaCliente[0].ShippingStreet != null){
						calle = listaCliente[0].ShippingStreet;
						if (calle.contains('\n')){
							calle = calle.replaceAll('\n',' ');
						}
					}
					concatenarParametroJSON('ShippingStreet',  calle);
					concatenarParametroJSON('ShippingCity',  listaCliente[0].ShippingCity);
					concatenarParametroJSON('CUE_SEL_Provincia',  listaCliente[0].ShippingState);
					concatenarParametroJSON('ShippingPostalCode',  listaCliente[0].ShippingPostalCode);
					concatenarParametroJSON('CUE_SEL_Pais',  listaCliente[0].ShippingCountry);
					concatenarParametroJSON('CUE_CAS_Activado', listaCliente[0].CUE_CAS_Activado__c);
					concatenarParametroJSON('Id',  listaCliente[0].Id);				
					concatenarParametroJSON('CUE_LKP_Cuenta_principal', listaCliente[0].CUE_LKP_Cuenta_principal__c);
					concatenarParametroJSON('CUE_TXT_Establecimiento',  listaCliente[0].CUE_TXT_Establecimiento__c);
					String nombre;
					if(listaCliente[0].Name != null){
						nombre = listaCliente[0].Name;
						if (nombre.contains('"')){
							nombre = nombre.replaceAll('"','');
						}
					}
					concatenarParametroJSON('Name', nombre);//concatenarParametroJSON('Name', listaCliente[0].Name);				
					concatenarParametroJSON('CUE_EMA_Email',  listaCliente[0].CUE_EMA_Email__c);	
					concatenarParametroJSON('Phone',  listaCliente[0].Phone);	
					concatenarParametroJSON('esPrincipal',  false);
					concatenarParametroJSON('Type',  listaCliente[0].Type);
					concatenarParametroJSON('CUE_CAS_Permite_Servicio_CodActivac',  listaCliente[0].CUE_CAS_Permite_Servicio_CodActivac__c);	
					concatenarParametroJSON('CUE_TXT_Numero_Documento',  listaCliente[0].CUE_TXT_Numero_Documento__c);	
					concatenarParametroJSON('CUE_FOR_Ppal_No_Permite_Servicio_B2C',  listaCliente[0].CUE_FOR_Ppal_No_Permite_Servicio_B2C__c);	
					concatenarParametroJSON('CUE_CAS_No_permite_Servicio_B2B2C',  listaCliente[0].CUE_CAS_No_permite_Servicio_B2B2C__c);
					
					/*Cambios realizados para añadir la ola de calor*/
					Date fechaHoy = date.today().addDays(2);
					if (!String.isEmpty(String.valueOf(listaCliente[0].CUE_DAT_Inicio_ola_calor__c)) && !String.isEmpty(String.valueOf(listaCliente[0].CUE_DAT_Fin_ola_calor__c))) {
						if (fechaHoy.month() > listaCliente[0].CUE_DAT_Inicio_ola_calor__c.month() && fechaHoy.month() < listaCliente[0].CUE_DAT_Fin_ola_calor__c.month()) {
							concatenarParametroJSON('OlaCalor',  true);
						}
						else if (fechaHoy.month() == listaCliente[0].CUE_DAT_Inicio_ola_calor__c.month()) {
							if (fechaHoy.day() >= listaCliente[0].CUE_DAT_Inicio_ola_calor__c.day()) {
								concatenarParametroJSON('OlaCalor',  true);
							}
							else {
								concatenarParametroJSON('OlaCalor',  false);
							}
						}
						else if (fechaHoy.month() == listaCliente[0].CUE_DAT_Fin_ola_calor__c.month()) {
							if (fechaHoy.day() <= listaCliente[0].CUE_DAT_Fin_ola_calor__c.day()) {
								concatenarParametroJSON('OlaCalor',  true);
							}
							else {
								concatenarParametroJSON('OlaCalor',  false);
							}
						}
						else {
							concatenarParametroJSON('OlaCalor',  false);
						}
				}
				else {
					concatenarParametroJSON('OlaCalor',  false);
				}
				/*Fin de cambios de ola de calor*/
				requestBody += '}}]';
				}
				else {
					requestBody +=']';
				}
				//Lista de Gremios
				anadirGremios(listaProcedencia);
				//Lista de Contactos
				anadirContactos(listaContactos);
				requestBody += '}';							
	
			}else{
				requestBody = '{'+ Util_WS_Error.devolverMensaje('API-002') +'}';
			}
			if (!test.isRunningTest()) {
				RestContext.response.addHeader('Content-Type', 'application/json');
				RestContext.response.responseBody = Blob.valueOf(requestBody);
			}
            system.debug('---- SVV. Request body: ' + requestBody);
   
		}catch(Exception e){
			system.debug('---- Excepción: ' + e + ' ' + e.getStackTraceString());
			requestBody = '{'+ Util_WS_Error.devolverMensaje('API-004') +'}';
			if (!test.isRunningTest()) {
				RestContext.response.addHeader('Content-Type', 'application/json');
				RestContext.response.responseBody = Blob.valueOf(requestBody);
			}	
		}
													  
	}
	

	/**
	 * Método que construye la parte del body correspondiente a los gremios
	 *
	 * @param listaProcedencia: lista en la que se encuentran los gremios disponibles y los tipos de registro de caso
	 *
	 */

	private static void anadirGremios(List<Procedencia__c> listaProcedencia){
		DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Case').getDescribe();
		DescribeFieldResult campoGremio = obj.fields.getMap().get('CAS_SEL_Sondeo_Gremios__c').getDescribe(); 
		List<Schema.PicklistEntry> listaPicklistGremios = campoGremio.getPicklistValues(); 
		List<String> gremiosSplit = new List<String>();
		integer i = 0;
		boolean encontrado =false;
		if(listaProcedencia != null && listaProcedencia.size() > 0){
			requestBody +=',"listadoGremiosB2B2C" :[';
			contParametros = 0;
			for(Procedencia__c tipoCaso:listaProcedencia){
				// Se comprueba si es B2B2C
				gremiosSplit = new List<String>();
				if (String.isNotBlank(listaProcedencia[i].PROC_SEL_Gremios_Disp__c)) {
					gremiosSplit = listaProcedencia[i].PROC_SEL_Gremios_Disp__c.split(';');
				}
				if(tipoCaso.PROC_SEL_Tipos_Caso__c.indexOf('CAS_Servicio_B2B_B2B2C') != -1){
					encontrado = true;
					contruirGremio(gremiosSplit,listaPicklistGremios);
				}
				i++;  
			}
			encontrado = false;
			requestBody +=']';
			requestBody +=',"listadoGremiosB2C" :[';
			contParametros = 0;i = 0;
			for(Procedencia__c tipoCaso:listaProcedencia){
				gremiosSplit = new List<String>();	
				if (String.isNotBlank(listaProcedencia[i].PROC_SEL_Gremios_Disp__c)) {
					gremiosSplit = listaProcedencia[i].PROC_SEL_Gremios_Disp__c.split(';');
				}
				// Se comprueba si es B2C
				if(tipoCaso.PROC_SEL_Tipos_Caso__c.indexOf('B2C') != -1 && tipoCaso.PROC_SEL_Tipos_Caso__c.indexOf('B2B2C') == -1){
					encontrado = true;
					contruirGremio(gremiosSplit,listaPicklistGremios);
				}
				i++;
			}
			requestBody +=']';
		}else{
			requestBody +=',"listadoGremiosB2B2C" :[]';
			requestBody +=',"listadoGremiosB2C" :[]';
		}	
	}	

	/**
	 * Método reutilizable para la construccion de gremios
	 *
	 * @param gremiosSplit: gremios disponibles
	 * @param listaPicklistGremios: valores que puede tomar el gremio
	 *
	 */

	private static void contruirGremio(List<String> gremiosSplit, List<Schema.PicklistEntry> listaPicklistGremios){
		String gremioValor = '';
		for (String valorCampoGremio : gremiosSplit){
			for (Schema.PicklistEntry valorGremio : listaPicklistGremios){
				gremioValor = valorGremio.getValue();
				if (gremioValor == valorCampoGremio){
					if(contParametros != 0)
						requestBody += ',';
					contParametros = 0;
					requestBody +='{"gremio" :{';
					concatenarParametroJSON('PROC_SEL_Gremios_Disp',  gremioValor);
					concatenarParametroJSON('literalGremio',  valorGremio.getLabel());
					requestBody +='}}';
				}  
			}
		}			
	}
	/**
	 * Método reutilizable para la construccion de gremios
	 *
	 */
	private static void contruirGremio(){
		contParametros = 0;
		requestBody +='{"gremio" :{';
		concatenarParametroJSON('PROC_SEL_Gremios_Disp',  '');
		concatenarParametroJSON('literalGremio', '');						
	}	

	/**
	 * Método que construye la parte del body correspondiente a los contactos.
	 *
	 * @param listaContactos: lista de contactos
	 *
	 */
	private static void anadirContactos(List<Contact> listaContactos){
		requestBody +=',"listadoContactos" :[';
		contParametros = 0;
		if(listaContactos != null && listaContactos.size() > 0){
			for(Contact contacto:listaContactos){
				if(contParametros != 0)
					requestBody += ',';
				contParametros = 0;
				requestBody +='{"contacto" :{';					
				concatenarParametroJSON('Id',  contacto.Id);
				concatenarParametroJSON('FirstName',  contacto.FirstName);
				concatenarParametroJSON('LastName',  contacto.LastName);
				concatenarParametroJSON('Email',  contacto.Email);
				concatenarParametroJSON('MobilePhone',  contacto.MobilePhone);
				concatenarParametroJSON('Phone',  contacto.Phone);
				concatenarParametroJSON('CON_CAS_Contacto_principal', contacto.CON_CAS_Contacto_principal__c);
				requestBody +='}}';
			}
			requestBody +=']';	
		}else{
			contParametros = 0;
			requestBody +=']';			
		}	
	}

	/**
	 * Método que construye la parte del body correspondiente a los contratos
	 *
	 * @param listaContratos: lista de contratos
	 *
	 */
	private static void anadirContratos(List<Contract> listaContratos){
		
		requestBody +=',"lineasContrato":[';
		contParametros =0;
		if(listaContratos != null && listaContratos.size() > 0){
			for(Contract contratos:listaContratos){
				if(contParametros != 0)
					requestBody += ',';
				contParametros =0;
				requestBody +='{"contrato" :{';
				concatenarParametroJSON('CTR_NUM_Version_Contrato',  contratos.CTR_NUM_Version_Contrato__c);
				concatenarParametroJSON('ContractNumber',  contratos.ContractNumber);
				String nombre;
				if(contratos.Name != null){
						nombre = contratos.Name;
						if (nombre.contains('"')){
							nombre = nombre.replaceAll('"','');
						}
					}
				concatenarParametroJSON('Name',  nombre);	
				requestBody +='}}';		
			}
			requestBody +=']';
		}else{
			requestBody +=']';	
		}
		contParametros =0;
	}	
	
	/**
	 * Método que construye la parte del body correspondiente a VDNs
	 *
	 * @param listaContratos: lista de VDNs
	 *
	 */
	private static void anadirVDN(List<VDN_Compania__c> listaVDN, Map<String, List<Configuracion_VDN__mdt>> mapaVDNmdt){
        requestBody +=',"datosTelefonia":[';
		
		contParametros = 0;
		if (mapaVDNmdt.isEmpty()) {
			requestBody +=']';
		}
		else {
			for (VDN_Compania__c VDN: listaVDN) {
				
				if (mapaVDNmdt.containsKey(VDN.VDN_TXT_Identificador__c)) {
					if(contParametros != 0){
						requestBody += ',';
					}
					contParametros = 0;
					requestBody +='{';
					concatenarParametroJSON('VDN_TLF_Telefono', VDN.VDN_TLF_Telefono__c);
					concatenarParametroJSON('VDN_SEL_Idioma', VDN.VDN_SEL_Idioma__c);
					requestBody +=',"datosLlamadaEntrante":[';
					contParametros = 0;
					for (Configuracion_VDN__mdt VDNmdt: mapaVDNmdt.get(VDN.VDN_TXT_Identificador__c)) {
						if(contParametros != 0){
							requestBody += ',';
						}
						contParametros = 0;
						requestBody +='{';
						concatenarParametroJSON('ServiceId', VDNmdt.ServiceId__c);
						concatenarParametroJSON('LoadId', VDNmdt.LoadId__c);
						requestBody +='}';
					}
					requestBody +=']';
					requestBody +='}';
				}
			}
			requestBody +=']';
		}
		contParametros = 0;
	}

	/**
	 * Métodos para concatenar los parámetros en formato JSON, dependiendo si el valor del parámetro es: String, Boolean o Decimal
	 *
	 * @param nombreParametro: nombre del parámetro a concatenar
	 * @param valorParametro: valor del parámetro a concatenar
	 *
	 */
	//Concatenadores para el body del response
	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}else{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '" : ""';
			contParametros++;
		}
	}	

	private static void concatenarParametroJSON(String nombreParametroBool, Boolean valorParaBoolean)
	{
		if (contParametros > 0) {requestBody += ',';}
		requestBody += '"' + nombreParametroBool + '" : "' + valorParaBoolean + '"';
		contParametros++;
	}

	private static void concatenarParametroJSON(String nombreParametroInt, Decimal valorParaInt)
	{
		if (contParametros > 0) {requestBody += ',';}
		requestBody += '"' + nombreParametroInt + '" : ' + valorParaInt + '';
		contParametros++;
	}
    
    /** Método para comprobar por patrón si el parámetro de entrada es un literal normal o es un identificador interno
     * @param Idparam: string del parámetro de entrada a evaluar
	 *
	 */
    static public String validateId(String Idparam) {
        String id = String.escapeSingleQuotes(Idparam);
    	if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return id;
    	}
         	return null;
	}
}