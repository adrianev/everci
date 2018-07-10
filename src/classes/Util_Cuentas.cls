/**
 * Clase de funciones auxiliares relativas a las Cuentas.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Cuentas {
	// Almacena cuentas que se necesitan actualizar pero se recogen en el trigger.before. Se actualizaran en el after
	public final static List<Account> cuentasActualizarTrigger = new List<Account>();

	/**
	 * Obtiene por query las cuentas a partir de un conjunto de IDs.
	 * 
	 * @param setIdCuenta: IDs de las cuentas a buscar
	 * @return mapa con las cuentas encontradas
	 */
	public static Map<Id,Account> getMapCuentasById(Set<Id> setIdCuenta){
		Map<Id,Account> mapa = new Map<Id,Account>();
		if(setIdCuenta != null && !setIdCuenta.isEmpty()){
			mapa = new Map<Id,Account>(
				[SELECT Id,
						CUE_CAS_Aceptado_LOPD__c,
						CUE_CAS_Activado__c,
						CUE_CAS_Dada_de_Baja__c,
						CUE_CAS_Embargado__c,
						CUE_CAS_No_Interviene_Perito__c,
						CUE_CAS_Permite_Apertura_Sin_Poliza__c,
						CUE_CAS_Profesional_Fianza__c,
						CUE_CAS_Profesional_Rappel__c,
						CUE_CAS_Robinson__c,
						CUE_CAS_Vetado__c,
						CUE_DAT_Fecha_Alta__c,
						CUE_DAT_Fecha_Baja__c,
						CUE_DAT_Profesional_Franquicia__c,
						CUE_DIV_Importe_Fianza_Devuelta__c,
						CUE_DIV_Importe_fianza_Maxima__c,
						CUE_DIV_Importe_Franquicia__c,
						CUE_DIV_Importe_Total_Fianza__c,
						CUE_DIV_Limite_Actuacion__c,
						CUE_EMA_Correo_Contacto_Informes__c,
						CUE_EMA_Email__c,
						CUE_FOR_DireccionEnvio__c,
						CUE_FOR_IBAN__c,
						CUE_FOR_RTDevName__c,
						CUE_LKP_Cliente_contable__c,
						CUE_LKP_contacto_principal__c,
						CUE_LKP_contacto_principal__r.Email,
						CUE_LKP_contacto_principal__r.FirstName,
						CUE_LKP_contacto_principal__r.LastName,
						CUE_LKP_contacto_principal__r.MobilePhone,
						CUE_LKP_contacto_principal__r.Phone,
						CUE_LKP_Cuenta_principal__c,
						CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
						CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
						CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
						CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
						CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
						CUE_LKP_Cuenta_principal__r.Name,
						CUE_LKP_CuentaPrincipalProf__r.Name,
						CUE_LKP_VDN_principal__c,
						CUE_NUM_Vencimientos_Franquicia__c,
						CUE_POR_Porcentaje_Fianza__c,
						CUE_SEL_GestionIndemnizable__c,
						CUE_SEL_Idioma__c,
						CUE_SEL_Motivo_Reapertura__c,
						CUE_SEL_Pais__c,
						CUE_SEL_Provincia__c,
						CUE_SEL_Tipo_Documento__c,
						CUE_TXT_Ayuda_Busqueda__c,
						CUE_TXT_Cbanc_Codigo_Entidad__c,
						CUE_TXT_Cbanc_Digito_Control__c,
						CUE_TXT_Cbanc_Digito_Control_IBAN__c,
						CUE_TXT_Cbanc_Numero__c,
						CUE_TXT_Cbanc_Pais__c,
						CUE_TXT_Cbanc_Sucursal_Oficina__c,
						CUE_TXT_Codigo_Retencion_Fiscal__c,
						CUE_TXT_Condicion_Pago__c,
						CUE_TXT_Establecimiento__c,
						CUE_TXT_Identificador__c,
						CUE_TXT_Metodo_Pago__c,
						CUE_TXT_Nombre__c,
						CUE_TXT_Numero_Documento__c,
						CUE_TXT_Presentacion__c,
						CUE_TXT_PrimerApellido__c,
						CUE_TXT_Prof_NumPoliza__c,
						CUE_TXT_SegundoApellido__c,
						CUE_TXT_Tipologia_Rappel__c,
						Description,
						Name,
						Phone,
						RecordType.Name,
						RecordTypeId,
						ShippingCity,
						ShippingCountry,
						ShippingPostalCode,
						ShippingState,
						ShippingStreet,
						Type,
						(SELECT Id,
								CON_CAS_Contacto_principal__c,
								AccountId
								FROM Contacts)
				 FROM Account
				 WHERE Id IN :setIdCuenta]);
		}
		return mapa;
	}


	public static Map<Id, Account> queryCuentasByNumeroDocumento(Set<String> setNumeroDocumentos, Set<String> setCompanias){
		Map<Id, Account> mapa = new Map<Id, Account>();
		if(!setNumeroDocumentos.isEmpty() && !setCompanias.isEmpty()) {
			mapa = new Map<Id, Account>(
				[SELECT Id,
						CUE_SEL_Pais__c,
						CUE_SEL_Provincia__c,
						CUE_SEL_Tipo_Documento__c,
						CUE_TXT_Numero_Documento__c,
						CUE_TXT_Nombre__c,
						CUE_TXT_PrimerApellido__c,
						CUE_TXT_SegundoApellido__c,
						Name,
						ShippingCity,
						ShippingCountry,
						ShippingPostalCode,
						ShippingState,
						ShippingStreet
				 FROM Account
				 WHERE CUE_TXT_Numero_Documento__c IN :setNumeroDocumentos
				 AND CUE_LKP_Cuenta_principal__c IN :setCompanias]);
		}
		return mapa;
	}


	/**
	 * Obtiene las cuentas a partir de un conjunto de IDs de cuenta.
	 *
	 * @param setIdCuentas: ids de cuentas a buscar
	 * @return mapa de ids de cuenta asociados a sus respectivas cuentas
	 */
	/*public static Map<Id,Account> getMapaCuentas(Set<Id> setIdCuentas){
		if(setIdCuentas != null && !setIdCuentas.isEmpty()){
			return new Map<Id,Account>([SELECT Id,
												CUE_TXT_Identificador__c,
												Name,
												CUE_EMA_Email__c,
												ShippingStreet,
												ShippingPostalCode,
												ShippingCity,
												ShippingState,
												CUE_LKP_VDN_principal__c,
												CUE_TXT_Presentacion__c,
												CUE_TXT_Ayuda_Busqueda__c
										FROM Account
										WHERE Id IN :setIdCuentas]);
		}
		return new Map<Id,Account>(); 
	}*/

	/**
	 * Obtiene por query las cuentas filtradas por el RecordType.
	 * 
	 * @param setRecordType: conjunto de RecordTypeId's
	 *
	 * @return mapa con las cuentas encontradas
	 */
	public static Map<Id,Account> queryMapCuentaByRT(Set<Id> setRecordType){
		Map<Id,Account> mapaCuentas = new Map<Id,Account>();
		if(setRecordType != null && !setRecordType.isEmpty()){
			for(List<Account> listaCuentas : [SELECT Id,
													CUE_CAS_Aceptado_LOPD__c,
													CUE_CAS_Activado__c,
													CUE_CAS_Dada_de_Baja__c,
													CUE_CAS_Embargado__c,
													CUE_CAS_No_Permite_Servicio_B2C__c,
													CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CUE_CAS_Profesional_Fianza__c,
													CUE_CAS_Profesional_Rappel__c,
													CUE_CAS_Robinson__c,
													CUE_CAS_Vetado__c,
													CUE_DAT_Fecha_Alta__c,
													CUE_DAT_Fecha_Baja__c,
													CUE_DAT_Profesional_Franquicia__c,
													CUE_DIV_Importe_Fianza_Devuelta__c,
													CUE_DIV_Importe_fianza_Maxima__c,
													CUE_DIV_Importe_Franquicia__c,
													CUE_DIV_Importe_Total_Fianza__c,
													CUE_DIV_Limite_Actuacion__c,
													CUE_DIV_Limite_Graves__c,
													CUE_EMA_Email__c,
													CUE_FOR_DireccionEnvio__c,
													CUE_FOR_IBAN__c,
													CUE_FOR_RTDevName__c,
													CUE_LKP_Cliente_contable__c,
													CUE_LKP_Cuenta_principal__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CUE_LKP_Cuenta_principal__r.Name,
													CUE_LKP_CuentaPrincipalProf__r.Name,
													CUE_LKP_VDN_principal__c,
													CUE_NUM_Vencimientos_Franquicia__c,
													CUE_POR_Porcentaje_Fianza__c,
													CUE_SEL_Idioma__c,
													CUE_SEL_Pais__c,
													CUE_SEL_Provincia__c,
													CUE_SEL_Tipo_Documento__c,
													CUE_TXT_Ayuda_Busqueda__c,
													CUE_TXT_Cbanc_Codigo_Entidad__c,
													CUE_TXT_Cbanc_Digito_Control__c,
													CUE_TXT_Cbanc_Digito_Control_IBAN__c,
													CUE_TXT_Cbanc_Numero__c,
													CUE_TXT_Cbanc_Pais__c,
													CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CUE_TXT_Codigo_Retencion_Fiscal__c,
													CUE_TXT_Condicion_Pago__c,
													CUE_TXT_Establecimiento__c,
													CUE_TXT_Identificador__c,
													CUE_TXT_Metodo_Pago__c,
													CUE_TXT_Nombre__c,
													CUE_TXT_Numero_Documento__c,
													CUE_TXT_Presentacion__c,
													CUE_TXT_PrimerApellido__c,
													CUE_TXT_SegundoApellido__c,
													CUE_TXT_Tipologia_Rappel__c,
													Description,
													Name,
													RecordType.Name,
													RecordTypeId,
													ShippingCity,
													ShippingCountry,
													ShippingPostalCode,
													ShippingState,
													ShippingStreet,
													Type
												FROM Account
												WHERE RecordTypeId IN :setRecordType]){
				mapaCuentas.putAll(listaCuentas);
			}
		}
		return mapaCuentas;
	}
	
	/**
	 * Obtiene por query las cuentas por y el check robinson 
	 * 
	 * @param setidsCuenta: conjunto de ids de Cuentas a encontrar
	 * @param robinson: valor de check robinson (boolean) que se usa para filtar
	 *
	 * @return mapa con las cuentas encontradas
	 */
	public static Map<Id,Account> queryMapCuentaById(Set<Id> setidsCuenta){
		Map<Id,Account> mapaCuentas = new Map<Id,Account>();
		if(setidsCuenta != null && !setidsCuenta.isEmpty() ){
			for(List<Account> listaCuentas: [SELECT Id,
													CUE_CAS_Aceptado_LOPD__c,
													CUE_CAS_Activado__c,
													CUE_CAS_Dada_de_Baja__c,
													CUE_CAS_Embargado__c,
													CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CUE_CAS_Profesional_Fianza__c,
													CUE_CAS_Profesional_Rappel__c,
													CUE_CAS_Robinson__c,
													CUE_CAS_Vetado__c,
													CUE_DAT_Fecha_Alta__c,
													CUE_DAT_Fecha_Baja__c,
													CUE_DAT_Profesional_Franquicia__c,
													CUE_DIV_Importe_Fianza_Devuelta__c,
													CUE_DIV_Importe_fianza_Maxima__c,
													CUE_DIV_Importe_Franquicia__c,
													CUE_DIV_Importe_Total_Fianza__c,
													CUE_DIV_Limite_Actuacion__c,
													CUE_DIV_Limite_Graves__c,
													CUE_EMA_Email__c,
													CUE_FOR_DireccionEnvio__c,
													CUE_FOR_IBAN__c,
													CUE_FOR_RTDevName__c,
													CUE_LKP_Cliente_contable__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CUE_LKP_Cuenta_principal__r.Name,
													CUE_LKP_CuentaPrincipalProf__r.Name,
													CUE_LKP_VDN_principal__c,
													CUE_NUM_Vencimientos_Franquicia__c,
													CUE_POR_Porcentaje_Fianza__c,
													CUE_SEL_Idioma__c,
													CUE_SEL_Pais__c,
													CUE_SEL_Provincia__c,
													CUE_SEL_Tipo_Documento__c,
													CUE_TXT_Ayuda_Busqueda__c,
													CUE_TXT_Cbanc_Codigo_Entidad__c,
													CUE_TXT_Cbanc_Digito_Control__c,
													CUE_TXT_Cbanc_Digito_Control_IBAN__c,
													CUE_TXT_Cbanc_Numero__c,
													CUE_TXT_Cbanc_Pais__c,
													CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CUE_TXT_Codigo_Retencion_Fiscal__c,
													CUE_TXT_Condicion_Pago__c,
													CUE_TXT_Establecimiento__c,
													CUE_TXT_Identificador__c,
													CUE_TXT_Metodo_Pago__c,
													CUE_TXT_Nombre__c,
													CUE_TXT_Numero_Documento__c,
													CUE_TXT_Presentacion__c,
													CUE_TXT_PrimerApellido__c,
													CUE_TXT_SegundoApellido__c,
													CUE_TXT_Tipologia_Rappel__c,
													Description,
													Name,
													RecordType.Name,
													RecordTypeId,
													ShippingCity,
													ShippingCountry,
													ShippingPostalCode,
													ShippingState,
													ShippingStreet,
													Type
												FROM Account
												WHERE Id IN :setidsCuenta]){
				mapaCuentas.putAll(listaCuentas);
			}
		}
		return mapaCuentas;
	}
	
	/**
	 * Obtiene por query las cuentas por y el check robinson 
	 * 
	 * @param setidsCuenta: conjunto de ids de Cuentas a encontrar
	 * @param robinson: valor de check robinson (boolean) que se usa para filtar
	 *
	 * @return mapa con las cuentas encontradas
	 */
	public static Map<Id,Account> queryMapCuentaByIdAndCheckRobinson(Set<Id> setidsCuenta, boolean robinson){
		Map<Id,Account> mapaCuentas = new Map<Id,Account>();
		if(setidsCuenta != null && !setidsCuenta.isEmpty() && robinson!=null ){
			for(List<Account> listaCuentas: [SELECT Id,
													CUE_CAS_Aceptado_LOPD__c,
													CUE_CAS_Activado__c,
													CUE_CAS_Dada_de_Baja__c,
													CUE_CAS_Embargado__c,
													CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CUE_CAS_Profesional_Fianza__c,
													CUE_CAS_Profesional_Rappel__c,
													CUE_CAS_Robinson__c,
													CUE_CAS_Vetado__c,
													CUE_DAT_Fecha_Alta__c,
													CUE_DAT_Fecha_Baja__c,
													CUE_DAT_Profesional_Franquicia__c,
													CUE_DIV_Importe_Fianza_Devuelta__c,
													CUE_DIV_Importe_fianza_Maxima__c,
													CUE_DIV_Importe_Franquicia__c,
													CUE_DIV_Importe_Total_Fianza__c,
													CUE_DIV_Limite_Actuacion__c,
													CUE_DIV_Limite_Graves__c,
													CUE_EMA_Email__c,
													CUE_FOR_DireccionEnvio__c,
													CUE_FOR_IBAN__c,
													CUE_FOR_RTDevName__c,
													CUE_LKP_Cliente_contable__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CUE_LKP_Cuenta_principal__r.Name,
													CUE_LKP_CuentaPrincipalProf__r.Name,
													CUE_LKP_VDN_principal__c,
													CUE_NUM_Vencimientos_Franquicia__c,
													CUE_POR_Porcentaje_Fianza__c,
													CUE_SEL_Idioma__c,
													CUE_SEL_Pais__c,
													CUE_SEL_Provincia__c,
													CUE_SEL_Tipo_Documento__c,
													CUE_TXT_Ayuda_Busqueda__c,
													CUE_TXT_Cbanc_Codigo_Entidad__c,
													CUE_TXT_Cbanc_Digito_Control__c,
													CUE_TXT_Cbanc_Digito_Control_IBAN__c,
													CUE_TXT_Cbanc_Numero__c,
													CUE_TXT_Cbanc_Pais__c,
													CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CUE_TXT_Codigo_Retencion_Fiscal__c,
													CUE_TXT_Condicion_Pago__c,
													CUE_TXT_Establecimiento__c,
													CUE_TXT_Identificador__c,
													CUE_TXT_Metodo_Pago__c,
													CUE_TXT_Nombre__c,
													CUE_TXT_Numero_Documento__c,
													CUE_TXT_Presentacion__c,
													CUE_TXT_PrimerApellido__c,
													CUE_TXT_SegundoApellido__c,
													CUE_TXT_Tipologia_Rappel__c,
													Description,
													Name,
													RecordType.Name,
													RecordTypeId,
													ShippingCity,
													ShippingCountry,
													ShippingPostalCode,
													ShippingState,
													ShippingStreet,
													Type
												FROM Account
												WHERE Id IN :setidsCuenta AND CUE_CAS_Robinson__c=:robinson]){
				mapaCuentas.putAll(listaCuentas);
			}
		}
		return mapaCuentas;
	}

	/**
	 * Obtiene por query las cuentas filtradas por las cuentas profesionales padre sin los tipos especificados.
	 * 
	 * @param setRecordType: conjunto de IDs de cuentas profesionales padre
	 * @param setNotType: conjunto de tipos a los que no pertenecen las cuentas
	 *
	 * @return mapa con las cuentas encontradas
	 */
	public static Map<Id,Account> queryMapCuentaByCuentaPpalAndNotInType(Set<Id> setCuentasPadre, Set<String> setNotType){
		Map<Id,Account> mapaCuentas = new Map<Id,Account>();
		if(setCuentasPadre != null && !setCuentasPadre.isEmpty() && setNotType != null && !setNotType.isEmpty()){
			for(List<Account> listaCuentas : [SELECT Id,
													CUE_CAS_Aceptado_LOPD__c,
													CUE_CAS_Activado__c,
													CUE_CAS_Dada_de_Baja__c,
													CUE_CAS_Embargado__c,
													CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CUE_CAS_Profesional_Fianza__c,
													CUE_CAS_Profesional_Rappel__c,
													CUE_CAS_Robinson__c,
													CUE_CAS_Vetado__c,
													CUE_DAT_Fecha_Alta__c,
													CUE_DAT_Fecha_Baja__c,
													CUE_DAT_Profesional_Franquicia__c,
													CUE_DIV_Importe_Fianza_Devuelta__c,
													CUE_DIV_Importe_fianza_Maxima__c,
													CUE_DIV_Importe_Franquicia__c,
													CUE_DIV_Importe_Total_Fianza__c,
													CUE_DIV_Limite_Actuacion__c,
													CUE_EMA_Email__c,
													CUE_FOR_DireccionEnvio__c,
													CUE_FOR_IBAN__c,
													CUE_FOR_RTDevName__c,
													CUE_LKP_Cliente_contable__c,
													CUE_LKP_Cuenta_principal__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CUE_LKP_Cuenta_principal__r.Name,
													CUE_LKP_CuentaPrincipalProf__r.Name,
													CUE_LKP_VDN_principal__c,
													CUE_NUM_Vencimientos_Franquicia__c,
													CUE_POR_Porcentaje_Fianza__c,
													CUE_SEL_Idioma__c,
													CUE_SEL_Pais__c,
													CUE_SEL_Provincia__c,
													CUE_SEL_Tipo_Documento__c,
													CUE_TXT_Ayuda_Busqueda__c,
													CUE_TXT_Cbanc_Codigo_Entidad__c,
													CUE_TXT_Cbanc_Digito_Control__c,
													CUE_TXT_Cbanc_Digito_Control_IBAN__c,
													CUE_TXT_Cbanc_Numero__c,
													CUE_TXT_Cbanc_Pais__c,
													CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CUE_TXT_Codigo_Retencion_Fiscal__c,
													CUE_TXT_Condicion_Pago__c,
													CUE_TXT_Establecimiento__c,
													CUE_TXT_Identificador__c,
													CUE_TXT_Metodo_Pago__c,
													CUE_TXT_Nombre__c,
													CUE_TXT_Numero_Documento__c,
													CUE_TXT_Presentacion__c,
													CUE_TXT_PrimerApellido__c,
													CUE_TXT_SegundoApellido__c,
													CUE_TXT_Tipologia_Rappel__c,
													Description,
													Name,
													RecordType.Name,
													RecordTypeId,
													ShippingCity,
													ShippingCountry,
													ShippingPostalCode,
													ShippingState,
													ShippingStreet,
													Type
												FROM Account
												WHERE CUE_LKP_Cuenta_principal__c IN :setCuentasPadre AND Type NOT IN :setNotType]){
				mapaCuentas.putAll(listaCuentas);
			}
		}
		return mapaCuentas;
	}


	/**
	 * Obtiene una cuenta a partir del ID de cuenta
	 * 
	 * @param idCuenta ID de cuenta a buscar
	 * @return lista de cuentas que coinciden con el ID
	 */
	/*public static List<Account> queryCuenta(Id idCuenta){
		List<Account> listaCuentas = new List<Account>();
		if(idCuenta != null){
			String sentenciaCuenta = 'SELECT Id,';
			sentenciaCuenta += ' CUE_CAS_Aceptado_LOPD__c,';
			sentenciaCuenta += ' CUE_CAS_Activado__c,';
			sentenciaCuenta += ' CUE_CAS_Dada_de_Baja__c,';
			sentenciaCuenta += ' CUE_CAS_Robinson__c,';
			sentenciaCuenta += ' CUE_CAS_Permite_Apertura_Sin_Poliza__c,';
			sentenciaCuenta += ' CUE_EMA_Email__c,';
			sentenciaCuenta += ' CUE_DAT_Fecha_Alta__c,';
			sentenciaCuenta += ' CUE_DAT_Fecha_Baja__c,';
			sentenciaCuenta += ' CUE_DIV_Limite_Actuacion__c,';
			sentenciaCuenta += ' CUE_SEL_Idioma__c,';
			sentenciaCuenta += ' CUE_SEL_Pais__c,';
			sentenciaCuenta += ' CUE_SEL_Provincia__c,';
			sentenciaCuenta += ' CUE_SEL_Tipo_Documento__c,';
			sentenciaCuenta += ' CUE_TXT_Identificador__c,';
			sentenciaCuenta += ' CUE_TXT_Establecimiento__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Pais__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Digito_Control_IBAN__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Codigo_Entidad__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Sucursal_Oficina__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Digito_Control__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Numero__c,';
			sentenciaCuenta += ' CUE_TXT_Nombre__c,';
			sentenciaCuenta += ' CUE_TXT_PrimerApellido__c,';
			sentenciaCuenta += ' CUE_TXT_SegundoApellido__c,';
			sentenciaCuenta += ' CUE_TXT_Numero_Documento__c,';
			sentenciaCuenta += ' CUE_FOR_DireccionEnvio__c,';
			sentenciaCuenta += ' CUE_FOR_RTDevName__c,';
			sentenciaCuenta += ' CUE_LKP_Cliente_contable__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.Name,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,';
			sentenciaCuenta += ' CUE_TXT_Presentacion__c,';
			sentenciaCuenta += ' CUE_TXT_Ayuda_Busqueda__c,';
			sentenciaCuenta += ' Description,';
			sentenciaCuenta += ' Name,';
			sentenciaCuenta += ' RecordType.Name,';
			sentenciaCuenta += ' RecordTypeId,';
			sentenciaCuenta += ' ShippingCity,';
			sentenciaCuenta += ' ShippingCountry,';
			sentenciaCuenta += ' ShippingPostalCode,';
			sentenciaCuenta += ' ShippingState,';
			sentenciaCuenta += ' ShippingStreet,';
			sentenciaCuenta += ' Type';
			sentenciaCuenta += ' FROM Account';
			sentenciaCuenta += ' WHERE Id = \'' + idCuenta + '\'';
			listaCuentas = database.query(sentenciaCuenta);
		}
		return listaCuentas;
	}*/
	
	public static Map<String, Account> queryCuentasByIdExt(Set<String> setName) {
		Map<String, Account> mapaCuentas=new Map<String, Account>();
		if(!setName.isEmpty()) {
			for(List<Account> listaCuentasAux:[SELECT Id,
													CUE_CAS_Aceptado_LOPD__c,
													CUE_CAS_Activado__c,
													CUE_CAS_Dada_de_Baja__c,
													CUE_CAS_Embargado__c,
													CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CUE_CAS_Profesional_Fianza__c,
													CUE_CAS_Profesional_Rappel__c,
													CUE_CAS_Robinson__c,
													CUE_CAS_Vetado__c,
													CUE_DAT_Fecha_Alta__c,
													CUE_DAT_Fecha_Baja__c,
													CUE_DAT_Profesional_Franquicia__c,
													CUE_DIV_Importe_Fianza_Devuelta__c,
													CUE_DIV_Importe_fianza_Maxima__c,
													CUE_DIV_Importe_Franquicia__c,
													CUE_DIV_Importe_Total_Fianza__c,
													CUE_DIV_Limite_Actuacion__c,
													CUE_EMA_Email__c,
													CUE_FOR_DireccionEnvio__c,
													CUE_FOR_IBAN__c,
													CUE_FOR_RTDevName__c,
													CUE_LKP_Cliente_contable__c,
													CUE_LKP_Cuenta_principal__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CUE_LKP_Cuenta_principal__r.Name,
													CUE_LKP_CuentaPrincipalProf__r.Name,
													CUE_LKP_VDN_principal__c,
													CUE_NUM_Vencimientos_Franquicia__c,
													CUE_POR_Porcentaje_Fianza__c,
													CUE_SEL_Idioma__c,
													CUE_SEL_Pais__c,
													CUE_SEL_Provincia__c,
													CUE_SEL_Tipo_Documento__c,
													CUE_TXT_Ayuda_Busqueda__c,
													CUE_TXT_Cbanc_Codigo_Entidad__c,
													CUE_TXT_Cbanc_Digito_Control__c,
													CUE_TXT_Cbanc_Digito_Control_IBAN__c,
													CUE_TXT_Cbanc_Numero__c,
													CUE_TXT_Cbanc_Pais__c,
													CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CUE_TXT_Codigo_Retencion_Fiscal__c,
													CUE_TXT_Condicion_Pago__c,
													CUE_TXT_Establecimiento__c,
													CUE_TXT_Identificador__c,
													CUE_TXT_Metodo_Pago__c,
													CUE_TXT_Nombre__c,
													CUE_TXT_Numero_Documento__c,
													CUE_TXT_Presentacion__c,
													CUE_TXT_PrimerApellido__c,
													CUE_TXT_SegundoApellido__c,
													CUE_TXT_Tipologia_Rappel__c,
													Description,
													Name,
													RecordType.Name,
													RecordTypeId,
													ShippingCity,
													ShippingCountry,
													ShippingPostalCode,
													ShippingState,
													ShippingStreet,
													Type
												FROM Account 
												WHERE CUE_TXT_Identificador__c  IN :setName]) {
				mapaCuentas.putAll(listaCuentasAux);
			}
		}
		return mapaCuentas;
	}

	public static Map<String, Account> queryCuentasByName(Set<String> setName) {
		Map<String, Account> mapaCuentas=new Map<String, Account>();
		if(!setName.isEmpty()) {
			for(List<Account> listaCuentasAux:[SELECT Id,
													CUE_CAS_No_Permite_Servicio_B2C__c,
													CUE_CAS_Aceptado_LOPD__c,
													CUE_CAS_Activado__c,
													CUE_CAS_Dada_de_Baja__c,
													CUE_CAS_Embargado__c,
													CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CUE_CAS_Profesional_Fianza__c,
													CUE_CAS_Profesional_Rappel__c,
													CUE_CAS_Robinson__c,
													CUE_CAS_Vetado__c,
													CUE_DAT_Fecha_Alta__c,
													CUE_DAT_Fecha_Baja__c,
													CUE_DAT_Profesional_Franquicia__c,
													CUE_DIV_Importe_Fianza_Devuelta__c,
													CUE_DIV_Importe_fianza_Maxima__c,
													CUE_DIV_Importe_Franquicia__c,
													CUE_DIV_Importe_Total_Fianza__c,
													CUE_DIV_Limite_Actuacion__c,
													CUE_EMA_Email__c,
													CUE_FOR_DireccionEnvio__c,
													CUE_FOR_IBAN__c,
													CUE_FOR_RTDevName__c,
													CUE_LKP_Cliente_contable__c,
													CUE_LKP_Cuenta_principal__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CUE_LKP_Cuenta_principal__r.Name,
													CUE_LKP_CuentaPrincipalProf__r.Name,
													CUE_LKP_VDN_principal__c,
													CUE_NUM_Vencimientos_Franquicia__c,
													CUE_POR_Porcentaje_Fianza__c,
													CUE_SEL_Idioma__c,
													CUE_SEL_Pais__c,
													CUE_SEL_Provincia__c,
													CUE_SEL_Tipo_Documento__c,
													CUE_TXT_Ayuda_Busqueda__c,
													CUE_TXT_Cbanc_Codigo_Entidad__c,
													CUE_TXT_Cbanc_Digito_Control__c,
													CUE_TXT_Cbanc_Digito_Control_IBAN__c,
													CUE_TXT_Cbanc_Numero__c,
													CUE_TXT_Cbanc_Pais__c,
													CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CUE_TXT_Codigo_Retencion_Fiscal__c,
													CUE_TXT_Condicion_Pago__c,
													CUE_TXT_Establecimiento__c,
													CUE_TXT_Identificador__c,
													CUE_TXT_Metodo_Pago__c,
													CUE_TXT_Nombre__c,
													CUE_TXT_Numero_Documento__c,
													CUE_TXT_Presentacion__c,
													CUE_TXT_PrimerApellido__c,
													CUE_TXT_SegundoApellido__c,
													CUE_TXT_Tipologia_Rappel__c,
													Description,
													Name,
													RecordType.Name,
													RecordTypeId,
													ShippingCity,
													ShippingCountry,
													ShippingPostalCode,
													ShippingState,
													ShippingStreet,
													Type
												FROM Account 
												WHERE Name  IN :setName]) {
				mapaCuentas.putAll(listaCuentasAux);
			}
		}
		return mapaCuentas;
	}

	/**
	 * Obtiene una cuenta a partir del filtro de búsqueda.
	 * 
	 * @param filtro: filtro de búsqueda aplicado en la query
	 * @return lista de cuentas que coinciden con el filtro de búsqueda
	 */
	/*public static List<Account> queryCuentaByFilter(String filtro){
		List<Account> listaCuentas = new List<Account>();
		if(filtro != null){
			String sentenciaCuenta = 'SELECT Id,';
			sentenciaCuenta += ' CUE_CAS_Aceptado_LOPD__c,';
			sentenciaCuenta += ' CUE_CAS_Activado__c,';
			sentenciaCuenta += ' CUE_CAS_Dada_de_Baja__c,';
			sentenciaCuenta += ' CUE_CAS_Robinson__c,';
			sentenciaCuenta += ' CUE_CAS_Permite_Apertura_Sin_Poliza__c,';
			sentenciaCuenta += ' CUE_EMA_Email__c,';
			sentenciaCuenta += ' CUE_DAT_Fecha_Alta__c,';
			sentenciaCuenta += ' CUE_DAT_Fecha_Baja__c,';
			sentenciaCuenta += ' CUE_DIV_Limite_Actuacion__c,';
			sentenciaCuenta += ' CUE_SEL_Idioma__c,';
			sentenciaCuenta += ' CUE_SEL_Pais__c,';
			sentenciaCuenta += ' CUE_SEL_Provincia__c,';
			sentenciaCuenta += ' CUE_SEL_Tipo_Documento__c,';
			sentenciaCuenta += ' CUE_TXT_Identificador__c,';
			sentenciaCuenta += ' CUE_TXT_Establecimiento__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Pais__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Digito_Control_IBAN__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Codigo_Entidad__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Sucursal_Oficina__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Digito_Control__c,';
			sentenciaCuenta += ' CUE_TXT_Cbanc_Numero__c,';
			sentenciaCuenta += ' CUE_TXT_Nombre__c,';
			sentenciaCuenta += ' CUE_TXT_PrimerApellido__c,';
			sentenciaCuenta += ' CUE_TXT_SegundoApellido__c,';
			sentenciaCuenta += ' CUE_TXT_Numero_Documento__c,';
			sentenciaCuenta += ' CUE_FOR_DireccionEnvio__c,';
			sentenciaCuenta += ' CUE_FOR_RTDevName__c,';
			sentenciaCuenta += ' CUE_LKP_Cliente_contable__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.Name,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,';
			sentenciaCuenta += ' CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,';
			sentenciaCuenta += ' CUE_TXT_Presentacion__c,';
			sentenciaCuenta += ' CUE_TXT_Ayuda_Busqueda__c,';
			sentenciaCuenta += ' Description,';
			sentenciaCuenta += ' Name,';
			sentenciaCuenta += ' RecordType.Name,';
			sentenciaCuenta += ' RecordTypeId,';
			sentenciaCuenta += ' ShippingCity,';
			sentenciaCuenta += ' ShippingCountry,';
			sentenciaCuenta += ' ShippingPostalCode,';
			sentenciaCuenta += ' ShippingState,';
			sentenciaCuenta += ' ShippingStreet,';
			sentenciaCuenta += ' Type';
			sentenciaCuenta += ' FROM Account';
			sentenciaCuenta += ' WHERE '+filtro;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Cuentas.queryCuentaByFilter.sentenciaCuenta: ' + sentenciaCuenta);
			listaCuentas = database.query(sentenciaCuenta);
		}
		return listaCuentas;
	}*/
	
	public static Map<Id, Direccion_Cuenta__c> queryByDireccionId(set<Id> idDireccionCuenta){
		 Map<Id, Direccion_Cuenta__c> mapaDireccionesCuenta=new Map<Id, Direccion_Cuenta__c>();
		if(!idDireccionCuenta.isEmpty()){
					for(List<Direccion_Cuenta__c> listaDireccionesAux:[SELECT Id, 
																			DCU_FOR_DireccionCompleta__c,
																			DCU_LKP_Cuenta__c,
																			DCU_SEL_Provincia__c,
																			DCU_SEL_Pais__c,
																			DCU_TXT_Codigo_Postal__c,
																			DCU_TXT_Direccion__c,
																			DCU_TXT_Poblacion__c
																		FROM Direccion_Cuenta__c
																		WHERE Id IN :idDireccionCuenta]) {
						mapaDireccionesCuenta.putAll(listaDireccionesAux);
					}
		}
		return mapaDireccionesCuenta;
	}

	/**
	 * Obtiene una dirección a partir del ID de dirección
	 * 
	 * @param idDireccion ID de direccion a buscar
	 * @param idCuenta ID de cuenta a buscar
	 * @return lista de direcciones que coinciden con el ID
	 */
	/*public static List<Direccion_Cuenta__c> queryDireccion(Id idDireccion, Id idCuenta){
		List<Direccion_Cuenta__c> listaDirecciones = new List<Direccion_Cuenta__c>();
		if(idDireccion != null || idCuenta != null){
			String sentenciaDireccion = 'SELECT Id,';
			sentenciaDireccion += ' DCU_FOR_DireccionCompleta__c,';
			sentenciaDireccion += ' DCU_LKP_Cuenta__c,';
			sentenciaDireccion += ' DCU_SEL_Provincia__c,';
			sentenciaDireccion += ' DCU_SEL_Pais__c,';
			sentenciaDireccion += ' DCU_TXT_Codigo_Postal__c,';
			sentenciaDireccion += ' DCU_TXT_Direccion__c,';
			sentenciaDireccion += ' DCU_TXT_Poblacion__c';
			sentenciaDireccion += ' FROM Direccion_Cuenta__c';
			if(idDireccion != null){
				sentenciaDireccion += ' WHERE Id = \'' + idDireccion + '\'';
			}
			else {
				sentenciaDireccion += ' WHERE DCU_LKP_Cuenta__c = \'' + idCuenta + '\'';
			}
			listaDirecciones = database.query(sentenciaDireccion);
		}
		return listaDirecciones;
	}*/

	/**
	 * Devuelve un mapa de direcciones de cuentas filtrado por un conjunto de ids de cuentas.
	 *
	 * @param setIdCuentas: ids de cuentas de las direcciones de cuenta
	 * @return mapa de direcciones de cuenta filtradas
	 */
	public static Map<Id,Direccion_Cuenta__c> getMapDireccionesCuenta(Set<Id> setIdCuentas){
		Map<Id,Direccion_Cuenta__c> mapa = new Map<Id,Direccion_Cuenta__c>();
		if(setIdCuentas != null && !setIdCuentas.isEmpty()){
			mapa = new Map<Id,Direccion_Cuenta__c>(
				[SELECT Id,
						DCU_FOR_DireccionCompleta__c,
						DCU_LKP_Cuenta__c,
						DCU_SEL_Pais__c,
						DCU_SEL_Provincia__c,
						DCU_TXT_Codigo_Postal__c,
						DCU_TXT_Direccion__c,
						DCU_TXT_Poblacion__c
				FROM Direccion_Cuenta__c
				WHERE DCU_LKP_Cuenta__c IN :setIdCuentas]);
		}
		return mapa;
	}

	/**
	 * Devuelve una lista de direcciones de cuentas filtrado por un conjunto de ids de cuentas.
	 *
	 * @param setIdCuentas: ids de cuentas de las direcciones de cuenta
	 * @return lista de direcciones de cuenta filtradas
	 */
	/*public static List<Direccion_Cuenta__c> getListaDireccionesCuenta(Set<Id> setIdCuentas){
		if(setIdCuentas != null && !setIdCuentas.isEmpty()){
			return [SELECT DCU_TXT_Codigo_Postal__c,
							DCU_TXT_Direccion__c,
							DCU_TXT_Poblacion__c,
							DCU_SEL_Provincia__c,
							DCU_FOR_DireccionCompleta__c,
							DCU_LKP_Cuenta__c
					FROM Direccion_Cuenta__c
					WHERE DCU_LKP_Cuenta__c IN :setIdCuentas];
		}
		return new List<Direccion_Cuenta__c>();
	}*/

	/**
	 * Concatena nombre y apellidos en un solo String separándolos con espacios
	 * 
	 * @param nombre Nombre a concatenar
	 * @param apellido1 Primer apellido a concatenar
	 * @param apellido2 Segundo apellido a concatenar
	 * @return lista de cuentas que coinciden con el ID
	 */
	public static String nombreCompleto(String nombre, String apellido1, String apellido2){
		String nombreCompleto = '';
		if(nombre != null && nombre != ''){
			nombreCompleto += nombre;
		}
		if(apellido1 != null && apellido1 != ''){
			if(nombreCompleto != ''){nombreCompleto += ' ';}
			nombreCompleto += apellido1;
		}
		if(apellido2 != null && apellido2 != ''){
			if(nombreCompleto != ''){nombreCompleto += ' ';}
			nombreCompleto += apellido2;
		}
		return nombreCompleto;
	}

	/**
	 * Crea una nueva procedencia a partir de una nueva cuenta B2B.
	 * 
	 * @param cuenta: Objeto Account de la Cuenta B2B
	 * @param tipo: 1-Servicios B2B, 2-Servicios B2C
	 * @return nuevo objeto Procedencia__c creado
	 */
	public static Procedencia__c crearProcedenciaB2B(Account cuenta, Integer tipo){
		Procedencia__c procedencia = null;
		if(cuenta != null){
			procedencia = new Procedencia__c();
			procedencia.PROC_LKP_Cuenta__c = cuenta.Id;
			String tipoStr = '' + tipo;
			if(tipo == 1){
				procedencia.PROC_SEL_Tipos_Caso__c = Label.PROCEDENCIA_SOLICITUD_SERVICIO_B2B_B2B2C + ';' + Label.PROCEDENCIA_SERVICIO_B2B_B2B2C;
				tipoStr = '';
			}
			else {
				procedencia.PROC_SEL_Tipos_Caso__c = Label.PROCEDENCIA_SOLICITUD_SERVICIO_B2C + ';' + Label.PROCEDENCIA_SERVICIO_B2C;
			}
			procedencia.Name = cuenta.CUE_TXT_Identificador__c + '' + tipoStr;
			procedencia.PROC_TXT_Identificador__c = cuenta.CUE_TXT_Identificador__c + '' + tipoStr;
		}
		return procedencia;
	}

	/**
	 * Crea una nueva procedencia a partir de una nueva cuenta B2C.
	 * 
	 * @param cuenta: Objeto Account de la Cuenta B2C
	 * @return nuevo objeto Procedencia__c creado
	 */
	public static Procedencia__c crearProcedenciaB2C(Account cuenta){
		Procedencia__c procedencia = null;
		if(cuenta != null){
			procedencia = new Procedencia__c();
			procedencia.PROC_LKP_Cuenta__c = cuenta.Id;
			procedencia.PROC_SEL_Tipos_Caso__c = Label.PROCEDENCIA_SOLICITUD_SERVICIO_B2C + ';' + Label.PROCEDENCIA_SERVICIO_B2C;
			procedencia.Name = cuenta.CUE_TXT_Identificador__c;
			procedencia.PROC_TXT_Identificador__c = cuenta.CUE_TXT_Identificador__c;
		}
		return procedencia;
	}


	/**
	*
	*
	*/
	public static void actualizarRobinson(String idCuenta, String Compania, String nombreIntegracion, String idBitacora){
		Callout_Actualizar_Check_Robin_RQ datos = new Callout_Actualizar_Check_Robin_RQ();
		
		List<Account> acc = [SELECT Id,CUE_TXT_Numero_Documento__c,CUE_CAS_Robinson__c,LastModifiedBy.Username FROM Account WHERE Id=: idCuenta LIMIT 1];
		
		datos.tomadorNumeroDocumentoCliente = acc[0].CUE_TXT_Numero_Documento__c ;
		datos.checkRobinson = acc[0].CUE_CAS_Robinson__c ;
		datos.usuario = acc[0].LastModifiedBy.Username;
		
		String body = Callout_Actualizar_Check_Robin.construirBody(datos); 
		system.debug('------ body util'+body);
		Callout_Actualizar_Check_Robin.updateDatos(body,nombreIntegracion,idBitacora,idCuenta,datos.tomadorNumeroDocumentoCliente);
	}
	
	/**
	 * Inicialización de la lista de tipos de cuenta
	 * 
	 * @return la lista de tipos de cuenta
	 */
	public static List<SelectOption> inicializarListaTiposCuenta(){
		List<SelectOption> typeList = new List<SelectOption>();
		Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map <String, Schema.SObjectField> typeFieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
		DescribeFieldResult typeAccount = typeFieldMap.get('Type').getDescribe();	   
		for(Schema.PicklistEntry type : typeAccount.getPicklistValues()){
			typeList.add(new SelectOption(type.getValue(), type.getLabel()));
		}
		return typeList;
	}
	
	/**
	 * Método que te devuelve una lista con los eventos de una cuenta
	 *
	 * @param casoIds: set de ids de cuenta
	 * @return eventos por id cuenta
	 */
	public static Map<Id, List<Propuesta_de_evento__c>> pEventosByCuenta(Set<Id> cuentaIds){
		Map<Id, List<Propuesta_de_evento__c>> resultados = new Map<Id,List<Propuesta_de_evento__c>>();
		List<Propuesta_de_evento__c> propEv = Util_Propuesta_de_evento.queryPropEvByCueId(cuentaIds).values();
		for(Propuesta_de_evento__c evt: propEv){
			List<Propuesta_de_evento__c> temp = resultados.get(evt.EV_AB_LKP_Cuenta_profesional__c);
			if(temp == null)
				temp = new List<Propuesta_de_Evento__c>();
				
			temp.add(evt);
			resultados.put(evt.EV_AB_LKP_Cuenta_profesional__c,temp);
		}
		return resultados;
	}
	
	/**
	 * Devuelve un mapa de Cuentas filtradas por Cuenta Principal y Numero de Documento
	 *
	 * @param setIdPrincipal: ids de cuentas Principales
	 * @param setNumDoc: numero de documento
	 *
	 * @return mapa de cuentas filtradas
	 */
	public static Map<Id,Account> getMapAccByPrincAndNumDoc(Set<Id> setIdPrincipal,Set <String> setNumDoc){
		Map<Id,Account> mapa = new Map<Id,Account>();
		if(setIdPrincipal != null && !setIdPrincipal.isEmpty() && setNumDoc != null && !setNumDoc.isEmpty()){
			for(List<Account> lista :[SELECT Id,
											ShippingPostalCode,
											ShippingCity,
											ShippingStreet,
											Phone,
											ShippingState,
											CUE_TXT_Numero_Documento__c,
											CUE_LKP_Cuenta_principal__c,
											Name,
											CUE_SEL_Tipo_Documento__c
										 FROM Account
										 WHERE CUE_LKP_Cuenta_principal__c IN : setIdPrincipal AND CUE_TXT_Numero_Documento__c IN : setNumDoc]){
				  	mapa.putAll(lista);
				  }
		}
		return mapa;
	}

	
	/**
	 * metodo para traer las cuentas a partir del numero de documento
	 * @param setDNIs: conjunto de DNIS de las cuentas a buscar
	 * @return mapaCuentas: mapa con las cuentas resultado
	 */
	public static Map<Id, Account> getCuentasByNumDoc(Set<String> setDNIs){
		Map<Id, Account> mapaCuentas=new Map<Id, Account>();
		if(!setDNIs.isEmpty()) {
			for(List<Account> listaCuentasAux: [SELECT Id,
				   								CUE_TXT_Numero_Documento__c,
				   								CUE_LKP_Cuenta_principal__c,
				   								RecordTypeId
				   								FROM Account
				   								WHERE CUE_TXT_Numero_Documento__c IN :setDNIs]){
				mapaCuentas.putAll(listaCuentasAux); 
			}
		}
		return mapaCuentas;
	} 
	/**
	 * Crea una nueva Habilidad CIA a partir de una nueva cuenta B2B/B2B2C o B2C.
	 * 
	 * @param cuenta: Objeto Account de la Cuenta
	 * @return nuevo objeto Skill creado
	 */
	public static Skill crearHabilidadCIA(Account cuenta){
		Skill habilidadCIA = null;
		if(cuenta != null){
			habilidadCIA = new Skill();
			habilidadCIA.DeveloperName = 'CIA_' + cuenta.CUE_TXT_Identificador__c;
			habilidadCIA.MasterLabel = cuenta.Name;
			habilidadCIA.Language = 'es';
		}
		return habilidadCIA;
	}
	
	public static Map<Id, Account> queryCuentasByCIAAndType(Set<Id>setCIA, Set<String> setTypeSiniestro) {
		Map<Id, Account> mapaCuentas=new Map<Id, Account>();
		if(!setTypeSiniestro.isEmpty()) {
			for(List<Account> listaCuentasAux:[SELECT Id,
													CUE_CAS_No_Permite_Servicio_B2C__c,
													CUE_SEL_Tipo_Siniestro__c,
													CUE_CAS_Aceptado_LOPD__c,
													CUE_CAS_Activado__c,
													CUE_CAS_Dada_de_Baja__c,
													CUE_CAS_Embargado__c,
													CUE_CAS_Permite_Apertura_Sin_Poliza__c,
													CUE_CAS_Profesional_Fianza__c,
													CUE_CAS_Profesional_Rappel__c,
													CUE_CAS_Robinson__c,
													CUE_CAS_Vetado__c,
													CUE_DAT_Fecha_Alta__c,
													CUE_DAT_Fecha_Baja__c,
													CUE_DAT_Profesional_Franquicia__c,
													CUE_DIV_Importe_Fianza_Devuelta__c,
													CUE_DIV_Importe_fianza_Maxima__c,
													CUE_DIV_Importe_Franquicia__c,
													CUE_DIV_Importe_Total_Fianza__c,
													CUE_DIV_Limite_Actuacion__c,
													CUE_EMA_Email__c,
													CUE_FOR_DireccionEnvio__c,
													CUE_FOR_IBAN__c,
													CUE_FOR_RTDevName__c,
													CUE_LKP_Cliente_contable__c,
													CUE_LKP_Cuenta_principal__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_No_permite_Servicio_B2B2C__c,
													CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c,
													CUE_LKP_Cuenta_principal__r.CUE_DIV_Limite_Actuacion__c,
													CUE_LKP_Cuenta_principal__r.CUE_TXT_Identificador__c,
													CUE_LKP_Cuenta_principal__r.Name,
													CUE_LKP_CuentaPrincipalProf__r.Name,
													CUE_LKP_VDN_principal__c,
													CUE_NUM_Vencimientos_Franquicia__c,
													CUE_POR_Porcentaje_Fianza__c,
													CUE_SEL_Idioma__c,
													CUE_SEL_Pais__c,
													CUE_SEL_Provincia__c,
													CUE_SEL_Tipo_Documento__c,
													CUE_TXT_Ayuda_Busqueda__c,
													CUE_TXT_Cbanc_Codigo_Entidad__c,
													CUE_TXT_Cbanc_Digito_Control__c,
													CUE_TXT_Cbanc_Digito_Control_IBAN__c,
													CUE_TXT_Cbanc_Numero__c,
													CUE_TXT_Cbanc_Pais__c,
													CUE_TXT_Cbanc_Sucursal_Oficina__c,
													CUE_TXT_Codigo_Retencion_Fiscal__c,
													CUE_TXT_Condicion_Pago__c,
													CUE_TXT_Establecimiento__c,
													CUE_TXT_Identificador__c,
													CUE_TXT_Metodo_Pago__c,
													CUE_TXT_Nombre__c,
													CUE_TXT_Numero_Documento__c,
													CUE_TXT_Presentacion__c,
													CUE_TXT_PrimerApellido__c,
													CUE_TXT_SegundoApellido__c,
													CUE_TXT_Tipologia_Rappel__c,
													Description,
													Name,
													RecordType.Name,
													RecordTypeId,
													ShippingCity,
													ShippingCountry,
													ShippingPostalCode,
													ShippingState,
													ShippingStreet,
													Type
												FROM Account 
												WHERE RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2)
												AND Type =: Label.CUE_TIPO_CONTABLE
												AND CUE_SEL_Tipo_Siniestro__c  IN :setTypeSiniestro 
												AND CUE_LKP_Cuenta_principal__c IN: setCIA ]) {
				mapaCuentas.putAll(listaCuentasAux);
			}
		}
		System.debug('mapaCuentas Util_Cuenta siniRetornoSondeoExterno'+mapaCuentas);
		return mapaCuentas;
	}
	
}