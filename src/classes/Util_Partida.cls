/**
 * Clase de funciones auxiliares relativas a las Partidas.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Partida {

	public static final Set<String> SET_ESTADOS_ACEPTADOS = new Set<String>{
		Label.PAR_ESTADO_ACEPTADA,
		Label.PAR_ESTADO_ACEPTADA_GEST,
		Label.PAR_ESTADO_ACEPTADA_POR_PERITO_CIA,
		Label.PAR_ESTADO_ACEPTADA_CLIENTE,
		Label.PAR_ESTADO_ACEPTADA_PERITO
	};
	
	public static final Set<String> SET_ESTADOS_RECHAZADOS = new Set<String>{
		Label.PAR_ESTADO_RECHAZADA,
		Label.PAR_ESTADO_RECHAZADA_PERITO,
		Label.PAR_ESTADO_RECHAZADA_CIA,
		Label.PAR_ESTADO_RECHAZADA_CLIENTE,
		Label.PAR_ESTADO_RECHAZADA_GESTOR		
	};
	
	
	public static Set<String> estadosValidos(String estadoDestino){
		Set<String> estados = new Set<String>();
		if(estadoDestino == Label.PAR_ESTADO_PDTE_CIA){
			estados = new Set<String>{
				Label.PAR_ESTADO_PENDIENTE
			}; 
		} else if(estadoDestino == Label.PAR_ESTADO_PDTE_CLIENTE){
			estados = new Set<String>{
				Label.PAR_ESTADO_PENDIENTE,
				Label.PAR_ESTADO_ACEPTADA,
				Label.PAR_ESTADO_ACEPTADA_CLIENTE,
				Label.PAR_ESTADO_ACEPTADA_GEST,
				Label.PAR_ESTADO_ACEPTADA_POR_PERITO_CIA,
				Label.PAR_ESTADO_ACEPTADA_PERITO
			}; 
		} else if(estadoDestino == Label.PAR_ESTADO_ACEPTADA_POR_PERITO_CIA){
			estados = new Set<String>{
				Label.PAR_ESTADO_PDTE_CIA
			}; 
		} else if(estadoDestino == Label.PAR_ESTADO_ACEPTADA_CLIENTE){
			estados = new Set<String>{
				Label.PAR_ESTADO_PDTE_CLIENTE
			}; 
		} else if(estadoDestino == Label.PAR_ESTADO_RECHAZADA_CIA){
			estados = new Set<String>{
				Label.PAR_ESTADO_PDTE_CIA
			}; 
		} else if(estadoDestino == Label.PAR_ESTADO_RECHAZADA_CLIENTE){
			estados = new Set<String>{
				Label.PAR_ESTADO_PDTE_CLIENTE
			}; 
		}
		
		return estados;
	}

	/**
	 * Devuelve las Partidas de Orden de Trabajo cuyos IDs se encuentren en el conjunto especificado por parámetro.
	 *
	 * @param setIdPartidas: IDs de las Partidas de Orden de Trabajo a buscar
	 *
	 * @return mapa que contienen las Partidas de Orden de Trabajo encontradas
	 */
	public static Map<Id,WorkOrderLineItem> queryMapPartidasOT(Set<Id> setIdPartidas){
		Map<Id,WorkOrderLineItem> mapa = new Map<Id,WorkOrderLineItem>();
		if(setIdPartidas != null && !setIdPartidas.isEmpty()){
			for(List<WorkOrderLineItem> lista : [SELECT Id,Description,Discount,PAR_CAS_Danos_Esteticos__c,PAR_CAS_Orden_Trabajo_Anulada__c,PAR_DIV_Cantidad_Venta__c,PAR_DIV_Cargar_Cliente_AI__c,PAR_DIV_Cargar_Comp_AI__c,PAR_DIV_Facturacion_Total_AI__c,PAR_DIV_Facturacion_Total_DI__c,PAR_DIV_Liquidar_Prof_AI__c,PAR_DIV_Liquidar_Prof_DI__c,PAR_DIV_ListPrice__c,PAR_DIV_Precio_Unitario_Venta__c,PAR_DIV_UnitPrice__c,PAR_FOR_Cargar_Cliente_DI__c,PAR_FOR_Cargar_Comp_DI__c,PAR_FOR_Precio_Unitario_Venta_Cli__c,PAR_NUM_Altura__c,PAR_NUM_Ancho__c,PAR_NUM_Igic__c,PAR_NUM_Ipsi__c,PAR_NUM_Iva__c,PAR_NUM_Unidades__c,PAR_POR_Descuento__c,PAR_POR_Impuesto_Prof__c,PAR_POR_Materiales__c,PAR_POR_Porcentaje_Imp_Cia_Cliente__c,PAR_SEL_Codigo_Impuesto_Venta__c,PAR_SEL_Danios_Del__c,PAR_SEL_Unidades_Medida__c,PAR_TXT_Baremo_Codigo__c,PAR_TXT_Baremo_Desc__c,PAR_TXT_Ceco__c,PAR_TXT_Detalle_Venta__c,PAR_TXT_Detalle_WOLI__c,PAR_TXT_Identificador__c,PAR_TXT_S_Ref__c,PAR_TXT_Unidades_Medida_Gastos__c,Status,WorkOrder.CaseId,WorkOrder.OTR_RES_Facturar_Cliente_AI__c,Workorder.OTR_RES_Liquidar_prof_AI__c,Workorder.OTR_RES_Subtotal_Partidas__c,WorkOrderId,ParentWorkOrderLineItemId
							FROM WorkOrderLineItem
							WHERE Id IN :setIdPartidas]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las Partidas de Orden de Trabajo cuyos IDs se encuentren en el conjunto especificado por parámetro.
	 *
	 * @param setIdPartidas: IDs de las Partidas de Orden de Trabajo a buscar
	 *
	 * @return lista que contienen las Partidas de Orden de Trabajo encontradas
	 */
	/*public static List<WorkOrderLineItem> queryPartidasOT(Set<Id> setIdPartidas){
		List<WorkOrderLineItem> partidasOT = new List<WorkOrderLineItem>();
		if(setIdPartidas != null && !setIdPartidas.isEmpty()){
			partidasOT = [SELECT Id,
								 Status,
								 WorkOrderId,
								 Description,
								 PAR_DIV_Cargar_Cliente_AI__c,
								 PAR_DIV_Liquidar_Prof_DI__c,
								 PAR_DIV_Facturacion_Total_AI__c,
								 PAR_DIV_Facturacion_Total_DI__c,
								 PAR_DIV_Cargar_Comp_AI__c,
								 PAR_DIV_Liquidar_Prof_AI__c,
								 PAR_NUM_Unidades__c,
								 PAR_TXT_Baremo_Codigo__c,
								 PAR_TXT_Detalle_WOLI__c,
								 PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
								 PAR_POR_Impuesto_Prof__c,
								 PAR_DIV_Precio_Unitario_Venta__c,
								 PAR_FOR_Cargar_Comp_DI__c,
								 PAR_FOR_Cargar_Cliente_DI__c, 
								 PAR_FOR_Precio_Unitario_Venta_Cli__c
							FROM WorkOrderLineItem
							WHERE Id IN :setIdPartidas];
		}
		return partidasOT;
	}*/

	/**
	 * Devuelve la Partidas de Orden de Trabajo a partir de su ID.
	 *
	 * @param idPartida: ID de la Partida de Orden de Trabajo a buscar
	 *
	 * @return Partida de Orden de Trabajo encontrada
	 */
	/*public static WorkOrderLineItem queryPartidasOT(Id idPartida){
		List<WorkOrderLineItem> partidas = queryPartidasOT(new Set<Id>{idPartida});
		if(!partidas.isEmpty()){
			return partidas[0];
		}
		return null;
	}*/
	
	/**
	 * Devuelve las partidas asociadas a una workorder
	 *
	 * @param setIdWorkOrder: IDs de las Ordene de Trabajo relacionadas a buscar
	 *
	 * @return mapa que contienen las Partidas de Orden de Trabajo encontradas
	 */
	public static Map<Id,WorkOrderLineItem> queryMapPartidasOTByWorkOrder(Set<Id> setIdWorkOrder){
		Map<Id,WorkOrderLineItem> mapa = new Map<Id,WorkOrderLineItem>();
		if(setIdWorkOrder != null && !setIdWorkOrder.isEmpty()){
			for(List<WorkOrderLineItem> lista : [SELECT Id,CreatedbyId,Createdby.Name,Description,Discount,PAR_CAS_Danos_Esteticos__c,PAR_CAS_Orden_Trabajo_Anulada__c,PAR_DIV_Cantidad_Venta__c,PAR_DIV_Cargar_Cliente_AI__c,PAR_DIV_Cargar_Comp_AI__c,PAR_DIV_Facturacion_Total_AI__c,PAR_DIV_Facturacion_Total_DI__c,PAR_DIV_Importe_a_imputar_Departamento__c,PAR_DIV_Importe_a_Imputar_gestor1__c,PAR_DIV_Importe_a_Imputar_gestor2__c,PAR_DIV_Importe_a_Imputar_gestor3__c,PAR_DIV_Importe_a_Imputar_prof1__c,PAR_DIV_Importe_a_Imputar_prof2__c,PAR_DIV_Importe_a_Imputar_prof3__c,PAR_DIV_Liquidar_Prof_AI__c,PAR_DIV_Liquidar_Prof_DI__c,PAR_DIV_ListPrice__c,PAR_DIV_Precio_Unitario_Venta__c,PAR_DIV_UnitPrice__c,PAR_FOR_Cargar_Cliente_DI__c,PAR_FOR_Cargar_Comp_DI__c,PAR_FOR_Precio_Unitario_Venta_Cli__c,PAR_LKP_Imputar_a_gestor1__c,PAR_LKP_Imputar_a_gestor2__c,PAR_LKP_Imputar_a_gestor3__c,PAR_LKP_Imputar_a_prof1__c,PAR_LKP_Imputar_a_prof2__c,PAR_LKP_Imputar_a_prof3__c,PAR_NUM_Altura__c,PAR_NUM_Ancho__c,PAR_NUM_Igic__c,PAR_NUM_Ipsi__c,PAR_NUM_Iva__c,PAR_NUM_Unidades__c,PAR_POR_Descuento__c,PAR_POR_Impuesto_Prof__c,PAR_POR_Materiales__c,PAR_POR_Porcentaje_Imp_Cia_Cliente__c,PAR_SEL_Codigo_Impuesto_Venta__c,PAR_SEL_Danios_Del__c,PAR_SEL_Departamento_Imputacion__c,PAR_SEL_Unidades_Medida__c,PAR_TXT_Baremo_Codigo__c,PAR_TXT_Baremo_Desc__c,PAR_TXT_Ceco__c,PAR_TXT_Detalle_Venta__c,PAR_TXT_Detalle_WOLI__c,PAR_TXT_Identificador__c,PAR_TXT_S_Ref__c,PAR_TXT_Unidades_Medida_Gastos__c,ParentWorkOrderLineItemId,Status,WorkOrder.CaseId,WorkOrder.OTR_RES_Facturar_Cliente_AI__c,Workorder.OTR_RES_Liquidar_prof_AI__c,Workorder.OTR_RES_Subtotal_Partidas__c,WorkOrderId
											 	 FROM WorkOrderLineItem
										  		 WHERE WorkOrderId IN :setIdWorkOrder
										  		 ORDER BY WorkOrderId ASC]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las partidas asociadas a una WorkOrder y filtradas por los estados de estas.
	 *
	 * @param setStatus: conjunto estados de las Ordenes de Trabajo relacionadas
	 *
	 * @return mapa que contienen las Partidas de Orden de Trabajo encontradas
	 */
	public static Map<Id,WorkOrderLineItem> queryMapPartidasOTByInStatusOT(Set<String> setStatus){
		Map<Id,WorkOrderLineItem> mapa = new Map<Id,WorkOrderLineItem>();
		if(setStatus != null && !setStatus.isEmpty()){
			for(List<WorkOrderLineItem> lista : [SELECT Id,Description,Discount,PAR_CAS_Danos_Esteticos__c,PAR_CAS_Orden_Trabajo_Anulada__c,PAR_DIV_Cantidad_Venta__c,PAR_DIV_Cargar_Cliente_AI__c,PAR_DIV_Cargar_Comp_AI__c,PAR_DIV_Facturacion_Total_AI__c,PAR_DIV_Facturacion_Total_DI__c,PAR_DIV_Liquidar_Prof_AI__c,PAR_DIV_Liquidar_Prof_DI__c,PAR_DIV_ListPrice__c,PAR_DIV_Precio_Unitario_Venta__c,PAR_DIV_UnitPrice__c,PAR_FOR_Cargar_Cliente_DI__c,PAR_FOR_Cargar_Comp_DI__c,PAR_FOR_Precio_Unitario_Venta_Cli__c,PAR_NUM_Altura__c,PAR_NUM_Ancho__c,PAR_NUM_Igic__c,PAR_NUM_Ipsi__c,PAR_NUM_Iva__c,PAR_NUM_Unidades__c,PAR_POR_Descuento__c,PAR_POR_Impuesto_Prof__c,PAR_POR_Materiales__c,PAR_POR_Porcentaje_Imp_Cia_Cliente__c,PAR_SEL_Codigo_Impuesto_Venta__c,PAR_SEL_Danios_Del__c,PAR_SEL_Unidades_Medida__c,PAR_TXT_Baremo_Codigo__c,PAR_TXT_Baremo_Desc__c,PAR_TXT_Ceco__c,PAR_TXT_Detalle_Venta__c,PAR_TXT_Detalle_WOLI__c,PAR_TXT_Identificador__c,PAR_TXT_S_Ref__c,PAR_TXT_Unidades_Medida_Gastos__c,Status,WorkOrder.CaseId,WorkOrder.OTR_RES_Facturar_Cliente_AI__c,Workorder.OTR_RES_Liquidar_prof_AI__c,Workorder.OTR_RES_Subtotal_Partidas__c,WorkOrderId,ParentWorkOrderLineItemId
											 	 FROM WorkOrderLineItem
										  		 WHERE WorkOrderId IN (SELECT Id FROM WorkOrder WHERE Status IN :setStatus)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}


	/**
	 * Devuelve las partidas filtrando por las OTs y los estados.
	 *
	 * @param setWorkOrderId: conjunto de WorkOrderId's
	 * @param setNotStatus: conjunto de estados en los que no deben encontrarse las partidas
	 *
	 * @return mapa que contienen las Partidas de Orden de Trabajo encontradas
	 */
	public static Map<Id,WorkOrderLineItem> queryMapPartidasOTByNotInStatusOT(Set<Id> setWorkOrderId, Set<String> setNotStatus){
		Map<Id,WorkOrderLineItem> mapa = new Map<Id,WorkOrderLineItem>();
		if(setWorkOrderId != null && !setWorkOrderId.isEmpty() && setNotStatus != null && !setNotStatus.isEmpty()){
			for(List<WorkOrderLineItem> lista:[SELECT Id,Description,Discount,PAR_CAS_Danos_Esteticos__c,PAR_CAS_Orden_Trabajo_Anulada__c,PAR_DIV_Cantidad_Venta__c,PAR_DIV_Cargar_Cliente_AI__c,PAR_DIV_Cargar_Comp_AI__c,PAR_DIV_Facturacion_Total_AI__c,PAR_DIV_Facturacion_Total_DI__c,PAR_DIV_Importe_a_imputar_Departamento__c,PAR_DIV_Importe_a_Imputar_gestor1__c,PAR_DIV_Importe_a_Imputar_gestor2__c,PAR_DIV_Importe_a_Imputar_gestor3__c,PAR_DIV_Importe_a_Imputar_prof1__c,PAR_DIV_Importe_a_Imputar_prof2__c,PAR_DIV_Importe_a_Imputar_prof3__c,PAR_DIV_Liquidar_Prof_AI__c,PAR_DIV_Liquidar_Prof_DI__c,PAR_DIV_ListPrice__c,PAR_DIV_Precio_Unitario_Venta__c,PAR_DIV_UnitPrice__c,PAR_FOR_Cargar_Cliente_DI__c,PAR_FOR_Cargar_Comp_DI__c,PAR_FOR_Precio_Unitario_Venta_Cli__c,PAR_LKP_Imputar_a_gestor1__c,PAR_LKP_Imputar_a_gestor2__c,PAR_LKP_Imputar_a_gestor3__c,PAR_LKP_Imputar_a_prof1__c,PAR_LKP_Imputar_a_prof2__c,PAR_LKP_Imputar_a_prof3__c,PAR_NUM_Altura__c,PAR_NUM_Ancho__c,PAR_NUM_Igic__c,PAR_NUM_Ipsi__c,PAR_NUM_Iva__c,PAR_NUM_Unidades__c,PAR_POR_Descuento__c,PAR_POR_Impuesto_Prof__c,PAR_POR_Materiales__c,PAR_POR_Porcentaje_Imp_Cia_Cliente__c,PAR_SEL_Codigo_Impuesto_Venta__c,PAR_SEL_Danios_Del__c,PAR_SEL_Departamento_Imputacion__c,PAR_SEL_Unidades_Medida__c,PAR_TXT_Baremo_Codigo__c,PAR_TXT_Baremo_Desc__c,PAR_TXT_Ceco__c,PAR_TXT_Detalle_Venta__c,PAR_TXT_Detalle_WOLI__c,PAR_TXT_Identificador__c,PAR_TXT_S_Ref__c,PAR_TXT_Unidades_Medida_Gastos__c,ParentWorkOrderLineItemId,Status,WorkOrder.CaseId,WorkOrder.OTR_RES_Facturar_Cliente_AI__c,Workorder.OTR_RES_Liquidar_prof_AI__c,Workorder.OTR_RES_Subtotal_Partidas__c,WorkOrderId
											 	FROM WorkOrderLineItem
										  		WHERE WorkOrderId IN :setWorkOrderId AND Status NOT IN :setNotStatus
										  		ORDER BY WorkOrderId ASC]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	public static Map<Id,WorkOrderLineItem> getWorkOrderLineItenByCaseAndNotStatus(Set<Id> setIds, Set<String> setStatus){
		Map<Id,WorkOrderLineItem> mapa = new Map<Id,WorkOrderLineItem>();
		system.debug('@Laura: setIds --->'+ setIds);
		system.debug('@Laura: setStatus --->'+ setStatus);
		if(setIds != null && !setIds.isEmpty() && setStatus != null && !setStatus.isEmpty()){
			for(List<WorkOrderLineItem> lista :[SELECT Id, 
						Status, 
						PAR_DIV_Facturacion_Total_AI__c,
						PAR_DIV_Facturacion_Total_DI__c,
						PAR_DIV_Cargar_Cliente_AI__c,
						PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
						PAR_FOR_Cargar_Comp_DI__c,
						PAR_FOR_Cargar_Cliente_DI__c,
						PAR_DIV_Cargar_Comp_AI__c,
						PAR_TXT_Detalle_WOLI__c,
						PAR_NUM_Unidades__c,
						Description,
						PAR_TXT_Baremo_Codigo__c,
						PAR_TXT_Baremo_Desc__c,
						PAR_DIV_Importe_a_Imputar_prof1__c,
						PAR_DIV_Importe_a_Imputar_prof2__c,
						PAR_DIV_Importe_a_Imputar_prof3__c,
						PAR_DIV_Importe_a_Imputar_gestor1__c,
						PAR_DIV_Importe_a_Imputar_gestor2__c,
						PAR_DIV_Importe_a_Imputar_gestor3__c,
						PAR_LKP_Imputar_a_prof1__c,
						PAR_LKP_Imputar_a_prof2__c,
						PAR_LKP_Imputar_a_prof3__c,
						PAR_LKP_Imputar_a_gestor1__c,
						PAR_LKP_Imputar_a_gestor2__c,
						PAR_LKP_Imputar_a_gestor3__c,
						WorkOrderId,
						WorkOrder.CaseId,
						WorkOrder.Status,
						WorkOrder.OTR_CAS_Urgente__c,
						WorkOrder.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,
						WorkOrder.OTR_SEL_Gremio__c,
						WorkOrder.OTR_TXT_Num_OrdenTrabajo_HS__c,
						WorkOrder.WorkOrderNumber
				 FROM WorkOrderLineItem WHERE WorkOrder.CaseId IN :setIds
				 //AND Status != :Label.PAR_ESTADO_RECHAZADA
				 AND Status NOT IN :setStatus
				 ORDER BY WorkOrder.CaseId ASC]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las partidas filtrando por el caso y los estados.
	 *
	 * @param setCaseId: conjunto de Ids de caso
	 * @param setStatus: conjunto de estados en los que deben encontrarse las partidas
	 *
	 * @return mapa que contienen las Partidas de Orden de Trabajo encontradas
	 */	
	public static Map<Id,WorkOrderLineItem> getWorkOrderLineItemByCaseAndStatus(Set<Id> setCaseId, Set<String> setStatus){
		Map<Id,WorkOrderLineItem> mapa = new Map<Id,WorkOrderLineItem>();
		if(setCaseId != null && !setCaseId.isEmpty() && setStatus != null && !setStatus.isEmpty()){
			for(List<WorkOrderLineItem> lista :[SELECT Id, 
													Status, 
													PAR_DIV_Facturacion_Total_AI__c,
													PAR_DIV_Facturacion_Total_DI__c,
													PAR_DIV_Cargar_Cliente_AI__c,
													PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
													PAR_FOR_Cargar_Comp_DI__c,
													PAR_FOR_Cargar_Cliente_DI__c,
													PAR_DIV_Cargar_Comp_AI__c,
													PAR_TXT_Detalle_WOLI__c,
													PAR_NUM_Unidades__c,
													Description,
													PAR_TXT_Baremo_Codigo__c,
													PAR_TXT_Baremo_Desc__c,
													PAR_DIV_Importe_a_Imputar_prof1__c,
													PAR_DIV_Importe_a_Imputar_prof2__c,
													PAR_DIV_Importe_a_Imputar_prof3__c,
													PAR_DIV_Importe_a_Imputar_gestor1__c,
													PAR_DIV_Importe_a_Imputar_gestor2__c,
													PAR_DIV_Importe_a_Imputar_gestor3__c,
													PAR_LKP_Imputar_a_prof1__c,
													PAR_LKP_Imputar_a_prof2__c,
													PAR_LKP_Imputar_a_prof3__c,
													PAR_LKP_Imputar_a_gestor1__c,
													PAR_LKP_Imputar_a_gestor2__c,
													PAR_LKP_Imputar_a_gestor3__c,
													WorkOrderId,
													WorkOrder.CaseId,
													WorkOrder.Status,
													WorkOrder.OTR_CAS_Urgente__c,
													WorkOrder.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c,
													WorkOrder.OTR_SEL_Gremio__c,
													WorkOrder.OTR_TXT_Num_OrdenTrabajo_HS__c,
													WorkOrder.WorkOrderNumber
											 FROM WorkOrderLineItem WHERE WorkOrder.CaseId IN :setCaseId
											 AND Status IN :setStatus]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}