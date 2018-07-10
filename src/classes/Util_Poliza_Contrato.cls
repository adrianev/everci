/**
 * Clase de funciones auxiliares relativas a las Pólizas.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Poliza_Contrato {

	/**
	 * Devuelve las polizas filtrando por las Cuentas y las Compañías.
	 *
	 * @param setCuenta: conjunto de IDs de Cuentas
	 * @param setName: conjunto de nombres de Compañías
	 *
	 * @return mapa que contiene las polizas encontradas
	 */
	public static Map<Id, ServiceContract> queryPolizaByAccountIdAndCompania(Set<Id> setCuenta, Set<String> setName) {
		Map<Id, ServiceContract> mapa=new Map<Id, ServiceContract>();
		if(!setName.isEmpty() && !setCuenta.isEmpty()) {
			mapa = new Map<Id, ServiceContract>(
				[SELECT Id,
						AccountId,
						Name,
						POL_LKP_Compania__c,
						POL_LKP_Compania__r.CUE_TXT_Identificador__c,
						POL_LKP_Compania__r.CUE_CAS_No_Permite_Servicio_B2C__c,
						POL_LKP_Compania__r.Name,
						POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
						POL_LKP_Version_Actual__r.Name
				 FROM ServiceContract
				 WHERE AccountId IN :setCuenta
				 AND POL_LKP_Compania__r.CUE_TXT_Identificador__c IN :setName]);
		}
		return mapa;
	}

	/**
	 * Devuelve las polizas filtrando por el nombre y las Compañías.
	 *
	 * @param setName: conjunto de nombres de Polizas
	 * @param setCompania: conjunto de nombres de Compañías
	 *
	 * @return mapa que contiene las polizas encontradas
	 */
	public static Map<Id, ServiceContract> queryPolizaByNameAndCompania(Set<String> setName, Set<Id> setCompania) {
		Map<Id, ServiceContract> mapa = new Map<Id, ServiceContract>();
		if(!setName.isEmpty() && !setCompania.isEmpty()){
			mapa = new Map<Id, ServiceContract>(
				[SELECT Id, 
						AccountId,
						Name,
						POL_LKP_Compania__c,
						POL_LKP_Compania__r.CUE_TXT_Identificador__c,
						POL_LKP_Compania__r.CUE_CAS_No_Permite_Servicio_B2C__c,
						POL_LKP_Compania__r.Name,
						POL_LKP_Producto_Cia__c,
						POL_LKP_Producto_Cia__r.Name,
						POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_TiposRiesgo_Seleccionables__c,
						POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
						POL_LKP_Version_Actual__c,
						POL_LKP_Version_Actual__r.name
				 FROM ServiceContract
				 WHERE Name IN :setName
				 AND POL_LKP_Compania__c IN :setCompania]);
		}
		return mapa;
	}
	
	/**
	* Obtiene un mapa de las polizas por el accountID que tienen cliente ensura informado
	*
	* @param setAccountId
	*
	* @return mapa de polizas coincidentes
   **/
	public static Map<Id, ServiceContract> queryPolizaByAccountAndEnsuraNotNull(Set<Id> setAccountId){
		Map<Id, ServiceContract> mapa = new Map<Id, ServiceContract>();
		if(setAccountId != null && !setAccountId.isEmpty()){
			mapa = new Map<Id, ServiceContract>(
				[SELECT Id, 
						AccountId,
						Name,
						POL_LKP_Compania__c,
						POL_LKP_Compania__r.CUE_TXT_Identificador__c,
						POL_LKP_Compania__r.CUE_CAS_No_Permite_Servicio_B2C__c,
						POL_LKP_Compania__r.Name,
						POL_LKP_Producto_Cia__c,
						POL_LKP_Producto_Cia__r.Name,
						POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_TiposRiesgo_Seleccionables__c,
						POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
                 		POL_TXT_Cliente_Ensura__c
				 FROM ServiceContract
				 WHERE AccountId IN :setAccountId
				 AND POL_TXT_Cliente_Ensura__c != null]);
		}
		return mapa;
	}
	
		/**
	* Obtiene un mapa de las polizas por el campo Name
	* 
	* @param setNames
	*
	* @return mapa de polizas coincidentes
   **/
	public static Map<Id, ServiceContract> queryPolizaByName(Set<String> setNames) {
		Map<Id, ServiceContract> mapa = new Map<Id, ServiceContract>();
		if(setNames != null && !setNames.isEmpty()) {
			mapa = new Map<Id, ServiceContract>(
				[SELECT Id,
						POL_LKP_Compania__r.Name,
						POL_LKP_Compania__r.CUE_EMA_Email__c,
						POL_LKP_Version_Actual__r.POLV_TXT_Calle__c,
						POL_LKP_Version_Actual__r.POLV_TXT_Codigo_Postal__c,
						POL_LKP_Version_Actual__r.POLV_SEL_Estado_Provincia__c,
						POL_LKP_Version_Actual__r.POLV_TXT_Poblacion__c,
						AccountId,
						Account.Name,
						POL_LKP_Version_Actual__r.POLV_CAS_Corresponde_a_HomeServe__c,
						POL_LKP_Version_Actual__r.Name,
						POL_LKP_Version_Actual__r.POLV_SEL_Tipo_Riesgo__c,
						startDate,
						POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Autorizados__c,
						Name
				 FROM ServiceContract
				 WHERE Name IN :setNames]);
		}
		return mapa;
	}
	

	public static Map<Id, ServiceContract> queryPolizaById(Set<Id> setId) {
		Map<Id, ServiceContract> mapa = new Map<Id, ServiceContract>();
		if(setId != null && !setId.isEmpty()) {
			mapa = new Map<Id, ServiceContract>(
				[SELECT Id, 
						AccountId,
						Account.Name,
						Account.CUE_EMA_Email__c,
						Account.CUE_TXT_Numero_Documento__c,
						ContactId,
						Name,
						POL_LKP_Compania__c,
						POL_LKP_Compania__r.CUE_TXT_Identificador__c,
						POL_LKP_Compania__r.CUE_CAS_No_Permite_Servicio_B2C__c,
						POL_LKP_Compania__r.Name,
						POL_LKP_Producto_Cia__c,
						POL_LKP_Producto_Cia__r.Name,
						POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_TiposRiesgo_Seleccionables__c,
						POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Autorizados__c,
						POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Seleccionables__c,				 
						POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,
						POL_LKP_Version_Actual__r.Name,
						POL_LKP_Version_Actual__r.POLV_SEL_Estado_Provincia__c,
						POL_LKP_Version_Actual__r.POLV_CAS_Corresponde_a_HomeServe__c,
						POL_LKP_Version_Actual__r.POLV_SEL_Idioma__c,
						POL_LKP_Version_Actual__r.POLV_SEL_Pais__c,
						POL_LKP_Version_Actual__r.POLV_SEL_Tipo_Riesgo__c,
						POL_LKP_Version_Actual__r.POLV_TXT_Calle__c,
						POL_LKP_Version_Actual__r.POLV_TXT_Codigo_Postal__c,
						POL_LKP_Version_Actual__r.POLV_TXT_Poblacion__c,
						POL_LKP_Version_Actual__r.POLV_CAS_IsGold__c
				 FROM ServiceContract
				 WHERE Id IN :setId]);
		}
		return mapa;
	}

	
	public static Map<Id, Version_ContratoServicio__c> queryVersionPoliza(Set<Id> setId) {
		Map<Id, Version_ContratoServicio__c> mapa = new Map<Id, Version_ContratoServicio__c>();
		if(setId != null && !setId.isEmpty()) {
			mapa = new Map<Id, Version_ContratoServicio__c>(
				[SELECT Id,
						Name,
						POLV_CAS_Activa__c,
						POLV_CAS_Corresponde_a_HomeServe__c,
						POLV_CAS_IsGold__c,
						POLV_DAT_Fecha_Alta_CIA__c,
						POLV_DAT_FechaFin__c,
						POLV_DAT_FechaInicio__c,
						POLV_DIV_Capital_Contenido__c,
						POLV_DIV_Capital_Continente__c,
						POLV_DIV_Capital_Objetos__c,
						POLV_DIV_Importe_Franquicia__c,
						POLV_FOR_Activo__c,
						POLV_LKP_PolizaContrato__c,
						POLV_NUM_Control_SegurCaixa__c,
						POLV_NUM_Superficie_Garaje__c,
						POLV_NUM_Superficie_Trastero__c,
						POLV_NUM_Superficie_Vivienda__c,
						POLV_NUM_Tipo_Transferencia__c,
						POLV_SEL_Estado_Provincia__c,
						POLV_SEL_Idioma__c,
						POLV_SEL_Pais__c,
						POLV_FOR_Cod_Segmentacion__c,
						POLV_SEL_Tipo_Riesgo__c,
						POLV_TXT_Calle__c,
						POLV_TXT_Certificado__c,
						POLV_TXT_Cod_Delegacion__c,
						POLV_TXT_Cod_Sucursal__c,
						POLV_TXT_Codigo_Cliente_ING__c,
						POLV_TXT_Codigo_Gestor_CIA__c,
						POLV_TXT_Codigo_Postal__c,
						POLV_TXT_Datos_Vivienda__c,
						POLV_TXT_Poblacion__c,
						POLV_TXT_Suplemento_Poliza__c,
						POLV_TXT_Tipo_Divisa__c,
						POLV_TXT_Tipo_Reg_Vivienda__c,
						POLV_TXT_VIPCompany__c
				 FROM Version_ContratoServicio__c
				 WHERE Id  IN :setId]);
		}
		return mapa;
	}
	

	/**
	 * Asocia una nueva póliza a un cliente
	 * 
	 * @param polizaSeleccionada póliza a crear
	 * @param idCliente cliente a asociar con la póliza
	 * @return objeto de tipo póliza
	 */ 
	public static ServiceContract nuevaPoliza(Callout_ConsultaPolizaVesta_RP polizaSeleccionada, Id idCliente){
		ServiceContract poliza = new ServiceContract();
		poliza.AccountId = idCliente;
		poliza.Name = polizaSeleccionada.numeroPoliza;		
		poliza.POL_LKP_Producto_Cia__c = polizaSeleccionada.idSFProducto;
		poliza.POL_LKP_Compania__c = polizaSeleccionada.idSFCompania;
		poliza.EndDate = Date.valueOf(polizaSeleccionada.fechaFinCobertura);
		poliza.StartDate = Date.valueOf(polizaSeleccionada.fechaInicioCobertura);
		return poliza;
	}
 
	/**
	 * Obtiene a partir de una póliza, un listado de opciones con los interlocutores seleccionables
	 * para el tipo de producto de la misma.
	 * 
	 * @param poliza
	 * @return lista de opciones del selector
	 */
	public static List<SelectOption> cargarSelectorTipoInterlocutor(ServiceContract poliza){
		List<SelectOption> listaSelOpt = new List<SelectOption>();
		listaSelOpt.add(new SelectOption('', '--Ninguno--'));
		DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Case').getDescribe();
		DescribeFieldResult campo = obj.fields.getMap().get('CAS_SEL_Tipo_Interlocutor__c').getDescribe();
		if(poliza.POL_LKP_Producto_Cia__c != null && poliza.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Seleccionables__c != null){
			String seleccionables = poliza.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Seleccionables__c;
			if(seleccionables != null){
				seleccionables = ';' + seleccionables + ';';
				for(Schema.PicklistEntry valorPCK : campo.getPicklistValues()){
					if(seleccionables.contains(';' + valorPCK.getValue() + ';')){
						listaSelOpt.add(new SelectOption(valorPCK.getValue(), valorPCK.getLabel()));
					}
				}
			}
		}
		return listaSelOpt;
	} // FIN cargarSelectorTipoInterlocutor

	/**
	 * Obtiene a partir de una póliza, un listado de opciones con los tipos de riesgo seleccionables
	 * para el tipo de producto de la misma.
	 * 
	 * @param poliza
	 * @return lista de opciones del selector
	 */
	public static List<SelectOption> cargarSelectorTipoRiesgo(ServiceContract poliza, String seleccionables){
		List<SelectOption> listaSelOpt = new List<SelectOption>();
		listaSelOpt.add(new SelectOption('', '--Ninguno--'));
		DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Version_ContratoServicio__c').getDescribe();
		DescribeFieldResult campo = obj.fields.getMap().get('POLV_SEL_Tipo_Riesgo__c').getDescribe();
		if(poliza.POL_LKP_Producto_Cia__c != null && poliza.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_TiposRiesgo_Seleccionables__c != null){
			seleccionables = poliza.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_TiposRiesgo_Seleccionables__c;
		}
		if(seleccionables != null){
			seleccionables = ';' + seleccionables + ';';
			for(Schema.PicklistEntry valorPCK : campo.getPicklistValues()){
				if(seleccionables.contains(';' + valorPCK.getValue() + ';')){
					listaSelOpt.add(new SelectOption(valorPCK.getValue(), valorPCK.getLabel()));
				}
			}
		}
		return listaSelOpt;
	} // FIN cargarSelectorTipoInterlocutor
	
	/**
	 * Obtiene a partir de una versión de una póliza, el listado de garantías asociadas
	 *
	 * @param setIdVersionPolizas
	 * @return mapa de garantias asociadas a pólizas
	 */
	public static Map<Id, Garantia_Poliza__c> queryGarantiasPolizaByPoliza(Set<Id> setIdVersionPolizas) {
		Map<Id, Garantia_Poliza__c> mapa = new Map<Id, Garantia_Poliza__c>();
		if(setIdVersionPolizas != null && !setIdVersionPolizas.isEmpty()) {
			mapa = new Map<Id, Garantia_Poliza__c>(
				[SELECT GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c
				 FROM Garantia_Poliza__c
				 WHERE GPOL_LKP_VersionPolizaContrato__r.POLV_LKP_PolizaContrato__c IN :setIdVersionPolizas]);
		}
		return mapa;
	}
	
	
	/**
	 * Obtiene a partir de un set de AccountIds, una lista de Contracts
	 *
	 *
	 * @param setAccountIds
	 * @return mapa de Contract asociadas a cuentas
	 */
	public static Map<Id, Contract> getContractByAccountId(Set<Id> setAccountIds) {
		Map<Id, Contract> mapa = new Map<Id, Contract>();
		if(!setAccountIds.isEmpty()) {
			for(List<Contract> listaContratosAux:
			[Select Id,
			  Status,
			  AccountId,
			  ContractNumber
			  FROM Contract WHERE AccountId IN :setAccountIds
			  ]) {
		 	   mapa.putAll(listaContratosAux);
	   		}
		}
		return mapa;
	}


	public static Version_ContratoServicio__c nuevaVersion(Callout_ConsultaPolizaVesta_RP polizaSeleccionada) {
		Version_ContratoServicio__c nuevaVersion = new Version_ContratoServicio__c(
			Name=polizaSeleccionada.identificadorVersion,
			POLV_DAT_FechaInicio__c = Date.valueOf(polizaSeleccionada.fechaInicioCobertura),
			POLV_DAT_FechaFin__c = Date.valueOf(polizaSeleccionada.fechaFinCobertura),		
			POLV_TXT_VIPCompany__c=polizaSeleccionada.VIPCompany,
			POLV_TXT_Calle__c = polizaSeleccionada.direccionRiesgoDomicilio,
			POLV_TXT_Poblacion__c = polizaSeleccionada.direccionRiesgoPoblacion,
			POLV_SEL_Estado_Provincia__c = polizaSeleccionada.direccionRiesgoCodProvincia,
			POLV_TXT_Codigo_Postal__c = polizaSeleccionada.direccionRiesgoCp,
			POLV_SEL_Pais__c = Label.PAIS_ESPANA,
			POLV_SEL_Idioma__c = polizaSeleccionada.idioma,
			POLV_DIV_Capital_Contenido__c = polizaSeleccionada.capitalContenido,
			POLV_DIV_Capital_Continente__c = polizaSeleccionada.capitalContinente,
			POLV_DIV_Capital_Objetos__c = polizaSeleccionada.capitalObjetos,
			POLV_TXT_Certificado__c = polizaSeleccionada.certificado,
			POLV_TXT_Cod_Delegacion__c = polizaSeleccionada.codigoDelegacion,
			POLV_TXT_Cod_Sucursal__c = polizaSeleccionada.codigoSucursal,
			POLV_TXT_Datos_Vivienda__c = polizaSeleccionada.datosVivienda,
			POLV_DAT_Fecha_Alta_CIA__c = polizaSeleccionada.fechaAltaCompania,
			POLV_CAS_IsGold__c = polizaSeleccionada.isGold,
			POLV_NUM_Superficie_Garaje__c = polizaSeleccionada.superficieGaraje,
			POLV_NUM_Superficie_Trastero__c = polizaSeleccionada.superficieTrastero,
			POLV_NUM_Superficie_Vivienda__c = polizaSeleccionada.superficieVivienda,
			POLV_TXT_Suplemento_Poliza__c = polizaSeleccionada.suplemento,
			POLV_TXT_Tipo_Divisa__c = polizaSeleccionada.tipoDivisa,
			POLV_TXT_Tipo_Reg_Vivienda__c = polizaSeleccionada.tipoRegimenVivienda,
			POLV_NUM_Tipo_Transferencia__c = polizaSeleccionada.tipoTransferencia,
			POLV_TXT_Codigo_Gestor_CIA__c = polizaSeleccionada.codigoGestor,
			POLV_TXT_Codigo_Cliente_ING__c = polizaSeleccionada.codigocliente,
			POLV_NUM_Control_SegurCaixa__c = polizaSeleccionada.controlDigitoSegurcaixa,
			POLV_CAS_Corresponde_a_HomeServe__c = polizaSeleccionada.perteneceHS
			);
		return nuevaVersion;
	} 
}