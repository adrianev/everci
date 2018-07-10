public without sharing class Util_Factura {

	/**
	 * Método para recuperar facturas por Número de factura.
	 * @param setNumerosFacturas: Conjunto de números de factura.
	 * @return mapa que contiene las facturas encontradas
	 */
	public static Map<Id,Factura__c> queryFacturaByNumeroFactura(Set<String> setNumerosFacturas) {
		Map<Id, Factura__c> mapFacturas=new Map<Id, Factura__c>();
		if(setNumerosFacturas != null && !setNumerosFacturas.isEmpty()) {
			for(List<Factura__c> listaFacturas:[SELECT Id,FAC_TXT_Numero_factura__c FROM Factura__c WHERE FAC_TXT_Numero_factura__c IN :setNumerosFacturas]) {
				mapFacturas.putAll(listaFacturas);
			}
		}
		return mapFacturas;
	}

	/**
	 * Método para recuperar facturas por los IDs.
	 * @param setId: Conjunto de IDs de factura.
	 * @return mapa que contiene las facturas encontradas
	 */
	public static Map<Id,Factura__c> queryFacturaById(Set<Id> setId) {
		Map<Id, Factura__c> mapFacturas=new Map<Id, Factura__c>();
		if(setId != null && !setId.isEmpty()) {
			for(List<Factura__c> listaFacturas:[SELECT Id,FAC_TXT_Numero_factura__c FROM Factura__c WHERE Id IN :setId]) {
				mapFacturas.putAll(listaFacturas);
			}
		}
		return mapFacturas;
	}
	
	/**
	 * Método para recuperar facturas por Id de caso.
	 * @param setNumerosFacturas: conjunto de Ids de caso.
	 * @return mapa que contiene las facturas encontradas
	 */
	public static Map<Id,Factura__c> queryFacturaByIdCaso(Set<Id> setIdsCaso) {
		Map<Id, Factura__c> mapFacturas=new Map<Id, Factura__c>();
		if(setIdsCaso != null && !setIdsCaso.isEmpty()) {
			for(List<Factura__c> listaFacturas:[SELECT Id,FAC_DAT_FechaFactura__c,FAC_DIV_RetencionPago__c,FAC_NUM_MesPago__c,FAC_NUM_IndicadorQuincena__c, 
				FAC_CAS_IndicadorPagoFranquicia__c,FAC_DIV_ImporteFranquicia__c,FAC_DIV_Importe_Pago__c,FAC_TXT_Codigo_Capital__c,FAC_NUM_Ano_Pago__c,FAC_POR_PorcentajeIVA__c,
				FAC_TXT_Numero_factura__c,FAC_NUM_Base_Imponible__c,FAC_DIV_ImporteFactura__c,FAC_NUM_ImporteFinal__c,FAC_TXT_Tipo_Registro__c,FAC_NUM_ImporteIVA__c, FAC_CAS_Factura_de_Gestion__c 
				FROM Factura__c WHERE FAC_LKP_Caso__c IN :setIdsCaso OR FAC_LKP_WorkOrkder__r.CaseId IN :setIdsCaso ORDER BY FAC_DAT_FechaFactura__c DESC]){
				mapFacturas.putAll(listaFacturas);
			}
		}
		return mapFacturas;
	}
	
	/**
	 * Método para recuperar facturas por Id de work order.
	 * @param setNumerosFacturas: conjunto de Ids de work order.
	 * @return mapa que contiene las facturas encontradas
	 */
	public static Map<Id,Factura__c> queryFacturaByIdWorkOrder(Set<Id> setIdsWO) {
		Map<Id, Factura__c> mapFacturas=new Map<Id, Factura__c>();
		if(setIdsWO != null && !setIdsWO.isEmpty()) {
			for(List<Factura__c> listaFacturas:[SELECT Id,FAC_DAT_FechaFactura__c,FAC_DIV_RetencionPago__c,FAC_NUM_MesPago__c,FAC_NUM_IndicadorQuincena__c, 
				FAC_CAS_IndicadorPagoFranquicia__c,FAC_DIV_ImporteFranquicia__c,FAC_DIV_Importe_Pago__c,FAC_TXT_Codigo_Capital__c,FAC_NUM_Ano_Pago__c,FAC_POR_PorcentajeIVA__c,
				FAC_TXT_Numero_factura__c,FAC_NUM_Base_Imponible__c,FAC_NUM_ImporteFinal__c,FAC_TXT_Tipo_Registro__c,FAC_NUM_ImporteIVA__c, FAC_CAS_Factura_de_Gestion__c, FAC_DIV_ImporteFactura__c
				FROM Factura__c WHERE FAC_LKP_WorkOrkder__c IN :setIdsWO]){
				mapFacturas.putAll(listaFacturas);
			}
		}
		return mapFacturas;
	}
}