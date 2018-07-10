/**
  * [PENDIENTE]
  * 
  * @author EVERIS
  */
public without sharing class CTI_Dispatcher{
	private String valorDni {get; set;}
	private String codigoVDN {get; set;}
	private VDN_Compania__c vdn {get; set;} 
	private String incomingPhone;
	private String workOrder {get; set;}

	/**
	  * Constructor de la clase.
	  * 
	  */
	public CTI_Dispatcher(){
		system.debug('Parámetros de entrada: '+ ApexPages.currentPage().getParameters());
		system.debug('>>>>>valorDni: ' + valorDni);
		system.debug('>>>>>codigoVDN: ' + codigoVDN);
		system.debug('>>>>>vdn: ' + vdn);
		system.debug('>>>>>incomingPhone: ' + incomingPhone);
		system.debug('>>>>>workOrder: ' + workOrder);
		system.debug('>>>>>URL: '+ ApexPages.currentPage().getUrl());
		incomingPhone = ApexPages.currentPage().getParameters().get('ani');
		//Recogida de la VDN
		if(ApexPages.currentPage().getParameters().containsKey('VDN')){
			codigoVDN = ApexPages.currentPage().getParameters().get('VDN');

			if (ApexPages.currentPage().getParameters().containsKey('UUI')
					&& ApexPages.currentPage().getParameters().get('UUI') != ''){
				String uui = ApexPages.currentPage().getParameters().get('UUI').replace('$', '').replace('*', '');
				system.debug('>>>>UUI recibido ' + valorDni);
				if(uui.contains('!')){
					system.debug('>>>>>PCH');
					List<String> listaUUI = uui.split('!');
					system.debug('>>>>> listaUUI : ' + listaUUI);
					if(!listaUUI.isEmpty()){
						if(listaUUI.get(0) != null){
							valorDni = listaUUI.get(0);
							system.debug('>>>>>PCG');
						}
						if(!String.isBlank(listaUUI.get(1))){
							codigoVDN = listaUUI.get(1);
							system.debug('>>>>>PCF');
						}
						if(!String.isBlank(listaUUI.get(2))){
							incomingPhone = listaUUI.get(2);
							system.debug('>>>>>PCE');
						}
						if(!String.isBlank(listaUUI.get(3))){
							workOrder = listaUUI.get(3);
							system.debug('>>>>>PCD');
						}
					}
				}else{
					valorDni = uui;
					//throw new CTI_DispatcherException('ERROR: El formato del DNI introducido no es válido');
				}
				system.debug('>>>>valorDni ' + valorDni);
			}/*else{
				throw new CTI_DispatcherException('ERROR: No se ha recibido el DNI del cliente');
			}*/

			List<VDN_Compania__c> listaVDN = Util_CTI.getVDNByName(new Set<String>{codigoVDN}).values();
			//List<VDN_Compania__c> listaVDN = Util_CTI.queryVDN(codigoVDN);
			system.debug('listaVDN: ' + listaVDN);
			if(listaVDN.size() == 1 && codigoVDN != ''){
				vdn = listaVDN.get(0);
				system.debug('>>>>>PCC');
				system.debug('>>>>>verCodigoVDN: ' + codigoVDN);
				system.debug('>>>>>verListaVDN: ' + listaVDN);
			}else{
				if(ApexPages.currentPage().getParameters().containsKey('calltype') && ApexPages.currentPage().getParameters().get('calltype') == 'OUTBOUND'){
					/// Buscamos la cuenta a partir del dnis
					List<Contact> listCon = new List<Contact>([SELECT AccountId FROM Contact WHERE MobilePhone =:ApexPages.currentPage().getParameters().get('dnis')]);
					system.debug('>>>>>PCB');
					if(listCon.size()>1){//Dará un error hasta que nos digan qué hacer
						throw new CTI_DispatcherException('Existe mas de una cuenta para el número de teléfono al que está intentando llamar');
					} else {
						system.debug('>>>>>PCA');
						Contact ctc = listCon.get(0);
						Set<Id> idAccount = new Set<Id>();
						idAccount.add(ctc.AccountId);
						List<Account> listaCuent = new List<Account>([SELECT Id, CUE_LKP_Cuenta_principal__r.CUE_LKP_VDN_principal__c, Name FROM Account WHERE Id IN :idAccount]);
						Set<Id> idVDN = new Set<Id>();
						idVDN.add(listaCuent.get(0).CUE_LKP_Cuenta_principal__r.CUE_LKP_VDN_principal__c);

						List<VDN_Compania__c> listaVDNS = new List<VDN_Compania__c>([SELECT Name, VDN_LKP_Compania__r.CUE_CAS_Permite_Apertura_Sin_Poliza__c, VDN_FOR_Cuenta__c, VDN_FOR_CuentaIdRT__c, VDN_LKP_Compania__c, VDN_LKP_Compania__r.Type,
																					VDN_LKP_Compania__r.CUE_TXT_Identificador__c, VDN_LKP_Compania__r.Name, VDN_LKP_Compania__r.CUE_FOR_RTDevName__c, VDN_TXT_Ayuda_Busqueda__c,
																					VDN_LKP_Compania__r.RecordType.Id, VDN_TXT_Presentacion__c FROM VDN_Compania__c WHERE Id IN :idVDN]);
						vdn = listaVDNS.get(0);
						system.debug('>>>>>mostrarVDN: ' + vdn);

					}

				}

				//throw new CTI_DispatcherException('El VDN recibido no se corresponde con ningún servicio');
			}
		}else{
			throw new CTI_DispatcherException('No se ha recibidio ningún VDN');
		}
	}

	/**
	 * Método que redirecciona a las paginas de busqueda de cliente segun el tipo de cliente que sea
	 * 
	 * @return página a navegar tras ejecutar la redirección
	 */   
	public PageReference redireccion (){
		Map<String, String> mapaFichas = fichasBusqueda();
		system.debug('>>>>>vdn: ' + vdn);
		String identificador = vdn.VDN_LKP_Compania__r.RecordType.Id;
		System.debug('RPM identificador: ' + identificador);
		System.debug('RPM identificadorq1: ' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1));
		System.debug('RPM identificadorq2: ' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2C_1));
		System.debug('RPM identificadorq3: ' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA));
		System.debug('RPM identificadorq4: ' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA_HS));
		PageReference paginaRedireccion = null;
		boolean redir = true;
		system.debug('>>>>>PC7');
		if (identificador == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_BUSQ_CLIENTES);
			paginaRedireccion.getParameters().put('sfdc.tabName', mapaFichas.get(Label.FICHA_BUSQ_B2B_B2B2C));
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
			paginaRedireccion.getParameters().put('telefono', incomingPhone);
			system.debug('>>>>>PC6');
		}
		else if (identificador == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2C_1)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_BUSQ_CLIENTES);
			paginaRedireccion.getParameters().put('sfdc.tabName', mapaFichas.get(Label.FICHA_BUSQ_B2B_B2B2C));
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
			paginaRedireccion.getParameters().put('telefono', incomingPhone);
			system.debug('>>>>>PC5');
		}
		else if (identificador == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_BUSQ_CLIENTES);
			paginaRedireccion.getParameters().put('sfdc.tabName', mapaFichas.get(Label.FICHA_BUSQ_ASEGURADOS));
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
			if(codigoVDN == null){
				system.debug('>>>>>verIdentificador: ' + identificador);
			}
			paginaRedireccion.getParameters().put('identificador', valorDni);
			system.debug('>>>>>PC4');
		}
		else if (identificador == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA_HS)){
			system.debug('>>>>>verIdentificador: ' + identificador);
			system.debug('>>>>>PC3');
			List<WorkOrder> woId;
			String data1;
			String objeto;
			String query;
			List <SObject> objetoList;
			if(ApexPages.currentPage().getParameters().get('calltype') == 'OUTBOUND'){
				data1 = ApexPages.currentPage().getParameters().get('data1');
				system.debug('>>>>>vercodigoVDN2: ' + codigoVDN);
				List<VDN_Compania__c> objetosVDN = [SELECT VDN_SEL_Mostrar_Objeto__c, VDN_LKP_Compania__c FROM VDN_Compania__c WHERE Id = :codigoVDN OR Name = :codigoVDN OR VDN_TXT_Identificador__c = :codigoVDN];
				VDN_Compania__c objetoVDN = new VDN_Compania__c();
				objetoVDN = objetosVDN.get(0);
				system.debug('>>>>>verObjetoVDN: ' + objetoVDN);
				if(data1 != null && data1 != '' && !objetosVDN.isEmpty()){
					system.debug('>>>>>PC2');
					query = 'SELECT Id FROM ' + objetoVDN.VDN_SEL_Mostrar_Objeto__c + ' WHERE ';
					system.debug('>>>>>verQuery: ' + query);
					system.debug('>>>>>objetoVDN.VDN_SEL_Mostrar_Objeto__c: ' + objetoVDN.VDN_SEL_Mostrar_Objeto__c);
					Id data1Id = data1;
					system.debug('>>>>>data1Id.getSObjectType(): ' + data1Id.getSObjectType());
					if(objetoVDN.VDN_SEL_Mostrar_Objeto__c == 'Case'){
						query += 'Id = ' + '\''+ data1 + '\'';
					}else if(objetoVDN.VDN_SEL_Mostrar_Objeto__c == 'WorkOrder'){
						query += 'WorkOrderNumber = ' + data1;
					}/*else{
						query += 'Id = ' + data1;					
					}*/
					system.debug('>>>>>verQuery2: ' + query);
					objetoList = Database.query(query);
					if(!objetoList.isEmpty()){
						paginaRedireccion = new PageReference('/' + objetoList[0].Id);
					}else{
						paginaRedireccion = new PageReference('/apex/selfClose'); 
					}
				}else{
					//paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_BUSQ_CLIENTES+'/'+objetoVDN[0].VDN_LKP_Compania__c); //Corregir, entramos aquí si objetoVND está vacío
					paginaRedireccion = new PageReference('/apex/selfClose');
					system.debug('>>>>>PC1');
				}

			}else{
				data1 = workOrder;
				woId = Util_Orden_Trabajo.getWorkOrderByWorkOrderNumber(new Set<String>{data1}).values();
				if(!woId.isEmpty()){
					paginaRedireccion = new PageReference('/' + woId[0].Id);
				}else{				   
					paginaRedireccion = new PageReference('/apex/selfClose'); 
				}
			}
		}
		//if(redir){
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
		/*}else{
			return null;
		}*/
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */   
	private Map<String, String> fichasBusqueda(){
		Map<String, String> mapaRetorno = new Map<String, String>();
		for(DescribeTabSetResult app : Schema.describeTabs()){
			for(DescribeTabResult ficha : app.getTabs()){
				system.debug('>>>>URL ' + ficha.getUrl());
				if(!mapaRetorno.containsKey(ficha.getLabel())
						&& ficha.getUrl().contains('?')){
					String parametrosURL = ficha.getUrl().split('\\?').get(1);
					system.debug('>>>>Parametros UereL ' + parametrosURL);
					String idFicha;
					for(String parametro : parametrosURL.split('&')){
						if(parametro.contains('lid')){
							idFicha = parametro.split('=').get(1);
						}
					}
					mapaRetorno.put(ficha.getLabel(), idFicha);
				}
			}
		}
		system.debug('>>>>mapaRetorno ' + mapaRetorno);
		return mapaRetorno;
	}
}