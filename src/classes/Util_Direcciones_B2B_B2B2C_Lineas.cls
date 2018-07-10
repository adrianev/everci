public without sharing class Util_Direcciones_B2B_B2B2C_Lineas {

	/**
	 * Devuelve las direcciones B2B B2B2C filtrados por: DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdCuenta AND DLC_FOR_Linea_Contrato_Activa__c = :boolLCActiva AND DLC_FOR_LC_RTDevName__c IN :setLCRTDevName AND (DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = null OR DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c IN :setGremios) AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Seleccion_Auto__c = :boolSeleccionAuto AND (DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c = null OR DLC_NUM_Servicios_restantes__c > :numServiciosRestantes).
	 *
	 * @param setIdCuenta: conjunto de IDs de Cuentas
	 * @param boolLCActiva: booleano true si la LC es activa, false en otro caso
	 * @param setLCRTDevName: conjunto de DevNames de RecordTypes de Línea de Contrato
	 * @param setGremios: conjunto de gremios
	 * @param boolSeleccionAuto: true si selección en auto, false en otro caso
	 * @param numServiciosRestantes: servicios restantes
	 *
	 * @return mapa que contiene las direcciones B2B B2B2C encontradas
	 */
	public static Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getLCsCorrectDisponiblesPorSeleccionAutoAndPorSaldo(Set<Id> setIdCuenta, Boolean boolLCActiva, Set<String> setLCRTDevName, Set<String> setGremios, Boolean boolSeleccionAuto, Integer numServiciosRestantes){
		Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapa = new Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(setIdCuenta != null && !setIdCuenta.isEmpty() && boolLCActiva != null && setLCRTDevName != null && !setLCRTDevName.isEmpty() && setGremios != null && !setGremios.isEmpty() && boolSeleccionAuto != null && numServiciosRestantes != null){
			for(List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista:[SELECT Id,
																				DLC_NUM_Servicios_restantes__c,
																				DLC_LKP_Linea_de_Contrato__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_TXT_Observaciones__c,
																				DLC_LKP_Linea_de_Contrato__r.Name,
																				DLC_LKP_Direccion_B2B_B2B2C__c,
																				DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
																				DLC_DAT_Activacion_primer_servicio__c,
																				DLC_FOR_Nombre_de_Cuenta__c,
																				DLC_FOR_Direccion__c,
																				DLC_FOR_Linea_Contrato_Activa__c,
																				DLC_FOR_Linea_Contrato_LimServ__c,
																				DLC_TXT_Identificador__c
																		 FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
																		 WHERE DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdCuenta
																		 AND DLC_FOR_Linea_Contrato_Activa__c = true
																		 AND DLC_FOR_LC_RTDevName__c IN :setLCRTDevName
																		 AND (DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = null
																		 		OR DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c IN :setGremios)
																		 AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Seleccion_Auto__c = :boolSeleccionAuto
																		 AND (DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c = null
																		 		OR DLC_NUM_Servicios_restantes__c > :numServiciosRestantes)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve las direcciones B2B B2B2C filtrados por: DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdCuenta AND DLC_FOR_Linea_Contrato_Activa__c = :boolLCActiva AND DLC_FOR_LC_RTDevName__c IN :setLCRTDevName AND (DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = null OR DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c IN :setGremios) AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c = :boolUrgente.
	 *
	 * @param setIdCuenta: conjunto de IDs de Cuentas
	 * @param boolLCActiva: booleano true si la LC es activa, false en otro caso
	 * @param setLCRTDevName: conjunto de DevNames de RecordTypes de Línea de Contrato
	 * @param setGremios: conjunto de gremios
	 * @param boolUrgente: true si urgente, false en otro caso
	 *
	 * @return mapa que contiene las direcciones B2B B2B2C encontradas
	 */
	public static Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getLCsCorrectDisponiblesPorUrgente(Set<Id> setIdCuenta, Set<String> setLCRTDevName, Set<String> setGremios, Boolean boolUrgente){
		Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapa = new Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(setIdCuenta != null && !setIdCuenta.isEmpty() && setLCRTDevName != null && !setLCRTDevName.isEmpty() && setGremios != null && !setGremios.isEmpty() && boolUrgente != null){
			for(List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista:[SELECT Id,
																				DLC_NUM_Servicios_restantes__c,
																				DLC_LKP_Linea_de_Contrato__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_TXT_Observaciones__c,
																				DLC_LKP_Linea_de_Contrato__r.Name,
																				DLC_LKP_Direccion_B2B_B2B2C__c,
																				DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
																				DLC_DAT_Activacion_primer_servicio__c,
																				DLC_FOR_Nombre_de_Cuenta__c,
																				DLC_FOR_Direccion__c,
																				DLC_FOR_Linea_Contrato_Activa__c,
																				DLC_FOR_Linea_Contrato_LimServ__c,
																				DLC_TXT_Identificador__c
																		FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
																		WHERE DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdCuenta
																		AND DLC_FOR_Linea_Contrato_Activa__c = true
																		AND DLC_FOR_LC_RTDevName__c IN :setLCRTDevName
																		AND (DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = null
																				OR DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c IN :setGremios)
																		AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c = :boolUrgente]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las direcciones B2B B2B2C filtrados por: DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdCuenta AND DLC_FOR_Linea_Contrato_Activa__c = :boolLCActiva AND DLC_FOR_LC_RTDevName__c IN :setLCRTDevName AND (DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = null OR DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c IN :setGremios) AND (DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c = null OR DLC_NUM_Servicios_restantes__c > :numServiciosRestantes) AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c = :boolUrgente.
	 *
	 * @param setIdCuenta: conjunto de IDs de Cuentas
	 * @param boolLCActiva: booleano true si la LC es activa, false en otro caso
	 * @param setLCRTDevName: conjunto de DevNames de RecordTypes de Línea de Contrato
	 * @param setGremios: conjunto de gremios
	 * @param numServiciosRestantes: servicios restantes
	 * @param boolUrgente: true si urgente, false en otro caso
	 *
	 * @return mapa que contiene las direcciones B2B B2B2C encontradas
	 */
	public static Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getLCsCorrectDisponiblesPorSaldoAndPorUrgente(Set<Id> setIdCuenta, Boolean boolLCActiva, Set<String> setLCRTDevName, Set<String> setGremios, Integer numServiciosRestantes, Boolean boolUrgente){
		Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapa = new Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(setIdCuenta != null && !setIdCuenta.isEmpty() && boolLCActiva != null && setLCRTDevName != null && !setLCRTDevName.isEmpty() && setGremios != null && !setGremios.isEmpty() && numServiciosRestantes != null && boolUrgente != null){
			for(List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista:[SELECT Id,
																				DLC_NUM_Servicios_restantes__c,
																				DLC_LKP_Linea_de_Contrato__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_TXT_Observaciones__c,
																				DLC_LKP_Linea_de_Contrato__r.Name,
																				DLC_LKP_Direccion_B2B_B2B2C__c,
																				DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
																				DLC_DAT_Activacion_primer_servicio__c,
																				DLC_FOR_Nombre_de_Cuenta__c,
																				DLC_FOR_Direccion__c,
																				DLC_FOR_Linea_Contrato_Activa__c,
																				DLC_FOR_Linea_Contrato_LimServ__c,
																				DLC_TXT_Identificador__c
																		FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
																		WHERE DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdCuenta
																		AND DLC_FOR_Linea_Contrato_Activa__c = true
																		AND DLC_FOR_LC_RTDevName__c IN :setLCRTDevName
																		AND (DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c = null
																				OR DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c IN :setGremios)
																 		AND (DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c = null
																 				OR DLC_NUM_Servicios_restantes__c > :numServiciosRestantes)
														 				AND DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c = :boolUrgente]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las Direcciones B2B B2B2C de Línea de Contrato filtradas por líneas de contratos y Direcciones B2BB2B2C.
	 *
	 * @param setIdDirB2BB2B2C: conjunto de IDs de Direcciones B2BB2B2C
	 * @param setIdLC: conjunto de IDs de Línea de Contrato
	 *
	 * @return mapa que contiene las Direcciones B2B B2B2C de Línea de Contrato encontradas
	 */
	public static Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getDLCByDirB2BB2B2CAndLC(Set<Id> setIdDirB2BB2B2C, Set<Id> setIdLC){
		Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapa = new Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(setIdDirB2BB2B2C != null && !setIdDirB2BB2B2C.isEmpty() && setIdLC != null && !setIdLC.isEmpty()){
			for(List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista:[SELECT Id,
																				DLC_NUM_Servicios_restantes__c,
																				DLC_LKP_Linea_de_Contrato__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_TXT_Observaciones__c,
																				DLC_LKP_Linea_de_Contrato__r.Name,
																				DLC_LKP_Direccion_B2B_B2B2C__c,
																				DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
																				DLC_DAT_Activacion_primer_servicio__c,
																				DLC_FOR_Nombre_de_Cuenta__c,
																				DLC_FOR_Direccion__c,
																				DLC_FOR_Linea_Contrato_Activa__c,
																				DLC_FOR_Linea_Contrato_LimServ__c,
																				DLC_TXT_Identificador__c
																		FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
																		WHERE DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdDirB2BB2B2C
																		AND DLC_LKP_Linea_de_Contrato__c IN :setIdLC]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las Direcciones B2B B2B2C de Línea de Contrato filtradas por líneas de contratos y cuentas.
	 *
	 * @param setIdLC: conjunto de IDs de Línea de Contrato
	 * @param setIdAccount: conjunto de IDs de Cuenta
	 *
	 * @return mapa que contiene las Direcciones B2B B2B2C de Línea de Contrato encontradas
	 */
	public static Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getDLCByLCAndAccount(Set<Id> setIdLC, Set<Id> setIdAccount){
		Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapa = new Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(setIdLC != null && !setIdLC.isEmpty() && setIdAccount != null && !setIdAccount.isEmpty()){
			for(List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista:[SELECT Id,
																				DLC_NUM_Servicios_restantes__c,
																				DLC_LKP_Linea_de_Contrato__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_TXT_Observaciones__c,
																				DLC_LKP_Linea_de_Contrato__r.Name,
																				DLC_LKP_Direccion_B2B_B2B2C__c,
																				DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
																				DLC_DAT_Activacion_primer_servicio__c,
																				DLC_FOR_Nombre_de_Cuenta__c,
																				DLC_FOR_Direccion__c,
																				DLC_FOR_Linea_Contrato_Activa__c,
																				DLC_FOR_Linea_Contrato_LimServ__c,
																				DLC_TXT_Identificador__c
																		FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
																		WHERE DLC_LKP_Linea_de_Contrato__c IN :setIdLC
																		AND DLC_LKP_Direccion_B2B_B2B2C__r.CUE_LKP_Cuenta_principal__c IN :setIdAccount]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las Direcciones B2B B2B2C de Línea de Contrato filtradas por los identificadores externos.
	 *
	 * @param setIdExt: conjunto de identificadores externos
	 *
	 * @return mapa que contiene las Direcciones B2B B2B2C de Línea de Contrato encontradas
	 */
	public static Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> getDLCByIdentificadorExt(Set<String> setIdExt){
		Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapa = new Map<Id,Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(setIdExt != null && !setIdExt.isEmpty()){
			for(List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> lista:[SELECT Id,
																				DLC_NUM_Servicios_restantes__c,
																				DLC_LKP_Linea_de_Contrato__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Urgente__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_DIV_Importe_Material_incluido__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Horas_de_Mano_de_obra__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_NUM_Limite_de_servicios__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,
																				DLC_LKP_Linea_de_Contrato__r.LDC_TXT_Observaciones__c,
																				DLC_LKP_Linea_de_Contrato__r.Name,
																				DLC_LKP_Direccion_B2B_B2B2C__c,
																				DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
																				DLC_DAT_Activacion_primer_servicio__c,
																				DLC_FOR_Nombre_de_Cuenta__c,
																				DLC_FOR_Direccion__c,
																				DLC_FOR_Linea_Contrato_Activa__c,
																				DLC_FOR_Linea_Contrato_LimServ__c,
																				DLC_TXT_Identificador__c
																			FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
																			WHERE DLC_TXT_Identificador__c IN :setIdExt]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las direcciones b2b_b2b2c de una línea de contrato.
	 *
	 * @param lineaContrato: línea de contrato de la dirección
	 * @return lista de direcciones encontradas
	 */
	/*public static List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> queryDirecciones(Linea_Contrato__c lineaContrato){
		List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> direcciones = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(lineaContrato != null){
			direcciones = [SELECT Id, 
								DLC_LKP_Direccion_B2B_B2B2C__c,
								DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
								DLC_LKP_Linea_de_Contrato__c,
								DLC_DAT_Activacion_primer_servicio__c,
								DLC_FOR_Nombre_de_Cuenta__c,
								DLC_FOR_Direccion__c
							FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
							WHERE DLC_LKP_Linea_de_Contrato__c = :lineaContrato.Id
							AND DLC_LKP_Direccion_B2B_B2B2C__r.CUE_LKP_Cuenta_principal__c = :lineaContrato.LDC_LKP_Contrato__r.AccountId];
		}
		return direcciones;
	}*/

	/**
	 * Devuelve las direcciones b2b_b2b2c de línea de contrato a partir de los IDs de línea de contrato y de dirección b2b_b2b2c.
	 *
	 * @param setIdElim: conjunto de ids de direcciones_b2b_b2b2c
	 * @param idLineaContrato: id de la línea de contrato
	 * @return lista de direcciones encontradas
	 */
	/*public static List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> queryDirecciones(Set<Id> setIdElim, Id idLineaContrato){
		List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> direcciones = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		if(idLineaContrato != null && setIdElim != null && !setIdElim.isEmpty()){
			direcciones = [SELECT Id, 
								DLC_LKP_Direccion_B2B_B2B2C__c,
								DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
								DLC_LKP_Linea_de_Contrato__c,
								DLC_DAT_Activacion_primer_servicio__c,
								DLC_FOR_Nombre_de_Cuenta__c,
								DLC_FOR_Direccion__c
							FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
							WHERE DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdElim AND DLC_LKP_Linea_de_Contrato__c = :idLineaContrato];
		}
		return direcciones;
	}*/
}