/**
 * Clase de funciones auxiliares relativas a los Presupuestos.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Presupuesto {

	/*
	 *  Genera el presupuesto sin llegar a insertarlo.
	 *  @param Case caso        - Caso sobre el que se genera el presupuesto
	 *
	 *  @return presupuesto     - Devuelve el presupuesto generado con los datos correspondientes
	 *
	 **/
	public static Presupuesto__c generarPresupuesto(Case caso, Presupuesto__c presupuestoAnterior){
		Presupuesto__c presupuesto = new Presupuesto__c();
		presupuesto.PRE_LKP_Caso__c = caso.Id;
		if (presupuestoAnterior != null){
			presupuesto.PRE_NUM_Version__c = ((Integer) presupuestoAnterior.PRE_NUM_Version__c) + 1;
		}
		else {
			presupuesto.PRE_NUM_Version__c = 1;
		}
		return presupuesto;
	}

	/*
	 *  Genera el presupuesto y sus líneas e inserta.
	 *  @param Case caso        - Caso sobre el que se genera el presupuesto
	 *  @param String estado	- Estado inicial del presupuesto
	 *
	 *  @return presupuesto     - Devuelve el presupuesto generado con los datos correspondientes
	 *
	 **/
	public static Presupuesto__c insertarPresupuesto(Case caso, List<WorkOrderLineItem> listaPartidas, String estado, Presupuesto__c presupuestoAnterior){
		//Generamos una nueva versión del presupuesto para el caso que corresponda
		Presupuesto__c presupuesto = generarPresupuesto(caso, presupuestoAnterior);
		//Si en el método especificamos la lista de partidas que queremos que haya en el presupuesto, rellenamos la variable "listaLineasPresupuesto" con esas partidas
		//En caso contrario, rellenamos la lista con todas las partidas de todas las WorkOrder del caso
		List<Linea_Presupuesto__c> listaLineasPresupuesto;
		if (listaPartidas == null){
			listaLineasPresupuesto = generarLineasPresupuesto(caso);
		}
		else {
			listaLineasPresupuesto = generarLineasPresupuesto(listaPartidas);
		}
		//Si existe un presupuesto anterior rechazado de forma parcial:
		if (presupuestoAnterior != null &&
				presupuestoAnterior.PRE_SEL_Estado__c == Label.PRESU_RECHAZADO_PARCIAL) {
			//El nuevo presupuesto nace con el estado anterior al rechazo
			presupuesto.PRE_SEL_Estado__c = presupuestoAnterior.PRE_SEL_Estado_Anterior__c;
		}
		else if (!String.isBlank(estado)){
			presupuesto.PRE_SEL_Estado__c = estado;
		}
		//Insertamos el presupuesto y las lineas en la base de datos 
		insertarPresupuestoYLineas(presupuesto,listaLineasPresupuesto);     
		return presupuesto;
	}

	/*
	 *  Genera el presupuesto sin llegar a insertarlo.
	 *  @param Case caso            - Caso sobre el que se genera el presupuesto
	 *
	 *  @return listaLinPresu       - Devuelve las lineas de presupuesto 
	 *
	 **/
	public static List<Linea_Presupuesto__c> generarLineasPresupuesto(Case caso){
		List<Linea_Presupuesto__c> listaLinPresu = new List<Linea_Presupuesto__c>();
		//Obtengo todas las OTLs vinculadas a las OTs que estan vinculadas al Caso
		List <WorkOrderLineItem> listaWOLI = Util_Caso.getListaPartidasCaso(caso.Id);
		//Creo una Linea de presupuesto por cada WOLI que exista
		for(WorkOrderLineItem woli : listaWOLI){
			//if(woli.Status != Label.PAR_ESTADO_RECHAZADA){
			if(!Util_Partida.SET_ESTADOS_RECHAZADOS.contains(woli.Status)){
				listaLinPresu.add(partidaOT2LineaPresupuesto(woli));
			}
		}
		return listaLinPresu;
	}

	/*
	 *  Genera el presupuesto sin llegar a insertarlo.
	 *  @param Case caso            - Caso sobre el que se genera el presupuesto
	 *
	 *  @return listaLinPresu       - Devuelve las lineas de presupuesto 
	 *
	 **/
	public static List<Linea_Presupuesto__c> generarLineasPresupuesto(List<WorkOrderLineItem> listaPartidas){
		List<Linea_Presupuesto__c> listaLinPresu = new List<Linea_Presupuesto__c>();
		//Creo una Linea de presupuesto por cada WOLI que exista
		if (listaPartidas != null) {
			for(WorkOrderLineItem woli : listaPartidas){
				//if(woli.Status != Label.PAR_ESTADO_RECHAZADA){
				if(!Util_Partida.SET_ESTADOS_RECHAZADOS.contains(woli.Status)){
					listaLinPresu.add(partidaOT2LineaPresupuesto(woli));
				}
			}
		}
		return listaLinPresu;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */  

	public static Presupuesto__c insertarPresupuestoYLineas(Presupuesto__c presupuesto, List<Linea_Presupuesto__c> listaLineasPresu){
		system.debug('***** presupuesto : ' + presupuesto);
		insert presupuesto;
		for(Linea_Presupuesto__c linP : listaLineasPresu){
			linP.PREL_LKP_Presupuesto__c = presupuesto.Id;
		}
		system.debug('***** listaLineasPresu : ' + listaLineasPresu);
		insert listaLineasPresu;

		return presupuesto;
	}


	/**
	 * Devuelve los presupuestos filtrados por los IDs.
	 *
	 * @param setIdPresupuesto: conjunto de IDs de Presupuesto
	 *
	 * @return mapa que contiene los presupuestos encontrados
	 */
	public static Map<Id,Presupuesto__c> getPresupuestoById(Set<Id> setIdPresupuesto){
		Map<Id,Presupuesto__c> mapa = new Map<Id,Presupuesto__c>();
		if(setIdPresupuesto != null && !setIdPresupuesto.isEmpty()){
			mapa = new Map<Id,Presupuesto__c>(
				[SELECT Id,
						CreatedDate,
						Name,
						PRE_LKP_Caso__c,
						PRE_NUM_Version__c,
						PRE_RES_Importe_total__c,
						PRE_RES_Importe_Total_Cia_AI__c,
						PRE_RES_Importe_Total_Cia_DI__c,
						PRE_RES_Importe_Total_Cliente_AI__c,
						PRE_RES_Importe_Total_Cliente_DI__c,
						PRE_RES_Importe_Total_DI__c,
						PRE_RES_Porcentaje_Imp_Cia_Cliente__c,
						PRE_SEL_Motivo_Rechazo__c,
						PRE_SEL_Estado__c,
						PRE_SEL_Estado_Anterior__c,
						PRE_TXT_Identificador__c,
						PRE_TXT_MotivoAprobacion__c
				 FROM Presupuesto__c
				 WHERE Id IN :setIdPresupuesto
				 ORDER BY PRE_NUM_Version__c DESC]);
		}
		return mapa;
	}


	/**
	 * Devuelve un mapa con las últimas versiones de presupuesto para cada uno de los casos recibidos.
	 * @param setIdCaso: Conjunto de Ids de Caso
	 * 
	 * @return mapa con las últimas versiones de presupuesto para cada uno de los casos recibidos
	 */
	public static Map<Id,Presupuesto__c> getPresupuestosActuales(Set<Id> setIdCaso){
		Map<Id, Presupuesto__c> mapa = new Map<Id, Presupuesto__c>();
		if(setIdCaso != null && !setIdCaso.isEmpty()){
			List<Presupuesto__c> lista = new List<Presupuesto__c>(
				[SELECT Id, 
						CreatedDate,
						Name,
						PRE_LKP_Caso__c,
						PRE_NUM_Version__c,
						PRE_RES_Importe_total__c,
						PRE_RES_Importe_Total_Cia_AI__c,
						PRE_RES_Importe_Total_Cia_DI__c,
						PRE_RES_Importe_Total_Cliente_AI__c,
						PRE_RES_Importe_Total_Cliente_DI__c,
						PRE_RES_Importe_Total_DI__c,
						PRE_RES_Porcentaje_Imp_Cia_Cliente__c,
						PRE_SEL_Motivo_Rechazo__c,
						PRE_SEL_Estado__c,
						PRE_SEL_Estado_Anterior__c,
						PRE_TXT_Identificador__c,
						PRE_TXT_MotivoAprobacion__c 
				 FROM Presupuesto__c
				 WHERE PRE_LKP_Caso__c IN :setIdCaso
				 ORDER BY PRE_LKP_Caso__c, PRE_NUM_Version__c DESC]);

			Id idCaso = null;
			for(Presupuesto__c registro : lista){
				if(registro.PRE_LKP_Caso__c != idCaso){
					idCaso = registro.PRE_LKP_Caso__c;
					mapa.put(idCaso, registro);
				}
			}
		}
		return mapa;
	}//FIN getPresupuestosActuales()



	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	//METODO QUE YA NO SE USA
	/*public static List<Presupuesto__c> queryPresupuesto(Id idPresupuesto, Id idCaso){
		List<Presupuesto__c> lista = new List<Presupuesto__c>();    
		if (idPresupuesto != null || idCaso !=null){
			String sentencia = 'SELECT Id,';
			sentencia += ' CreatedDate,';
			sentencia += ' Name,';
			sentencia += ' PRE_LKP_Caso__c,';
			sentencia += ' PRE_NUM_Version__c,';
			sentencia += ' PRE_RES_Importe_total__c,';
			sentencia += ' PRE_RES_Importe_Total_Cia_AI__c,';
			sentencia += ' PRE_RES_Importe_Total_Cia_DI__c,';
			sentencia += ' PRE_RES_Importe_Total_Cliente_AI__c,';
			sentencia += ' PRE_RES_Importe_Total_Cliente_DI__c,';
			sentencia += ' PRE_RES_Importe_Total_DI__c,';
			sentencia += ' PRE_RES_Porcentaje_Imp_Cia_Cliente__c,';
			sentencia += ' PRE_SEL_Motivo_Rechazo__c,';
			sentencia += ' PRE_SEL_Estado__c,';
			sentencia += ' PRE_SEL_Estado_Anterior__c,';
			sentencia += ' PRE_TXT_Identificador__c,';
			sentencia += ' PRE_TXT_MotivoAprobacion__c';
			sentencia += ' FROM Presupuesto__c';
			if (idPresupuesto != null) {
				sentencia += ' WHERE Id = \'' + idPresupuesto + '\'';	
			}
			else {
				sentencia += ' WHERE PRE_LKP_Caso__c = \'' + idCaso + '\' ORDER BY PRE_NUM_Version__c DESC';
			}

			lista = database.query(sentencia);
		}
		return lista;
	}*/

	/**
	  * [PENDIENTE]
	  * 
	  * @param idGrupo: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	/*public static List<Linea_Presupuesto__c> queryLineasPresupuesto(Id idPresupuesto){
		List<Linea_Presupuesto__c> lista = new List<Linea_Presupuesto__c>();    
		if (idPresupuesto != null){
			String sentencia = 'SELECT Id,';
			sentencia += ' Name,';
			sentencia += ' PREL_DIV_Cargar_Cliente_AI__c,';
			sentencia += ' PREL_DIV_Cargar_Cliente_DI__c,';
			sentencia += ' PREL_DIV_Cargar_Comp_AI__c,';
			sentencia += ' PREL_DIV_Cargar_Comp_DI__c,';
			sentencia += ' PREL_DIV_Facturacion_Total_AI__c,';
			sentencia += ' PREL_DIV_Facturacion_Total_DI__c,';
			sentencia += ' PREL_LKP_Orden_Trabajo__c,';
			sentencia += ' PREL_LKP_Presupuesto__c,';
			sentencia += ' PREL_NUM_Unidades__c,';
			sentencia += ' PREL_POR_Impuesto_Cliente__c,';
			sentencia += ' PREL_TXT_Codigo_Baremo__c,';
			sentencia += ' PREL_TXT_Codigo_Estado__c,';
			sentencia += ' PREL_TXT_Codigo_Gremio__c,';
			sentencia += ' PREL_TXT_Descripcion__c,';
			sentencia += ' PREL_TXT_Descripcion_Baremo__c,';
			sentencia += ' PREL_TXT_Detalle__c,';
			sentencia += ' PREL_TXT_Estado__c,';
			sentencia += ' PREL_TXT_Gremio__c,';
			sentencia += ' PREL_TXT_Num_Orden_Trabajo__c';
			sentencia += ' FROM Linea_Presupuesto__c';
			sentencia += ' WHERE PREL_LKP_Presupuesto__c = \'' + idPresupuesto + '\'';
			lista = database.query(sentencia);
		}
		return lista;
	}*/
	
	/**
	 * Devuelve las lineas de presupuesto filtradss por los IDs de presupuesto.
	 *
	 * @param setIdPresupuesto: conjunto de IDs de Presupuesto
	 *
	 * @return mapa que contiene las lineas de presupuesto encontradas
	 */
	public static Map<Id,Linea_Presupuesto__c> getLineaPresupuestoByPresupuesto(Set<Id> setIdPresupuesto){
		Map<Id,Linea_Presupuesto__c> mapa = new Map<Id,Linea_Presupuesto__c>();
		if(setIdPresupuesto != null && !setIdPresupuesto.isEmpty()){
			for(List<Linea_Presupuesto__c> lista:[SELECT Id,Name,PREL_DIV_Cargar_Cliente_AI__c,PREL_DIV_Cargar_Cliente_DI__c,
			PREL_DIV_Cargar_Comp_AI__c,PREL_DIV_Cargar_Comp_DI__c,PREL_DIV_Facturacion_Total_AI__c,PREL_DIV_Facturacion_Total_DI__c,
			PREL_LKP_Orden_Trabajo__c,PREL_LKP_Presupuesto__c,PREL_NUM_Unidades__c,PREL_POR_Impuesto_Cliente__c,PREL_TXT_Codigo_Baremo__c,
			PREL_TXT_Codigo_Estado__c,PREL_TXT_Codigo_Gremio__c,PREL_TXT_Descripcion__c,PREL_TXT_Descripcion_Baremo__c,
			PREL_TXT_Detalle__c,PREL_TXT_Estado__c,PREL_TXT_Gremio__c,PREL_TXT_Num_Orden_Trabajo__c
			FROM Linea_Presupuesto__c WHERE PREL_LKP_Presupuesto__c IN :setIdPresupuesto]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	private static Linea_Presupuesto__c partidaOT2LineaPresupuesto(WorkOrderLineItem partidaOT){
		Linea_Presupuesto__c linPresu = null;
		if (partidaOT != null) {
			linPresu = new Linea_Presupuesto__c();
			linPresu.PREL_LKP_Orden_Trabajo__c = partidaOT.WorkOrderId;
			linPresu.PREL_DIV_Facturacion_Total_AI__c = partidaOT.PAR_DIV_Facturacion_Total_AI__c;
			linPresu.PREL_DIV_Facturacion_Total_DI__c = partidaOT.PAR_DIV_Facturacion_Total_DI__c;
			linPresu.PREL_DIV_Cargar_Cliente_AI__c = partidaOT.PAR_DIV_Cargar_Cliente_AI__c;
			linPresu.PREL_DIV_Cargar_Cliente_DI__c = partidaOT.PAR_FOR_Cargar_Cliente_DI__c;
			linPresu.PREL_DIV_Cargar_Comp_AI__c = partidaOT.PAR_DIV_Cargar_Comp_AI__c;
			linPresu.PREL_DIV_Cargar_Comp_DI__c = partidaOT.PAR_FOR_Cargar_Comp_DI__c;
			linPresu.PREL_POR_Impuesto_Cliente__c = partidaOT.PAR_POR_Porcentaje_Imp_Cia_Cliente__c;
			linPresu.PREL_TXT_Descripcion__c = partidaOT.Description;
			linPresu.PREL_TXT_Codigo_Baremo__c = partidaOT.PAR_TXT_Baremo_Codigo__c;
			linPresu.PREL_TXT_Descripcion_Baremo__c = partidaOT.PAR_TXT_Baremo_Desc__c;
			linPresu.PREL_TXT_Num_Orden_Trabajo__c = partidaOT.WorkOrder.WorkOrderNumber;
			linPresu.PREL_TXT_Detalle__c = partidaOT.PAR_TXT_Detalle_WOLI__c;
			linPresu.PREL_NUM_Unidades__c = partidaOT.PAR_NUM_Unidades__c;
			linPresu.PREL_TXT_Estado__c = Util_Listas_seleccion.getLabelDesdeAPI('WorkOrderLineItem', 'Status').get(partidaOT.Status);
			linPresu.PREL_TXT_Gremio__c = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Gremio__c').get(partidaOT.WorkOrder.OTR_SEL_Gremio__c);
			linPresu.PREL_TXT_Codigo_Estado__c = partidaOT.Status;
			linPresu.PREL_TXT_Codigo_Gremio__c = partidaOT.WorkOrder.OTR_SEL_Gremio__c;
		}
		return linPresu;
	}
	
	/**
	 * Devuelve un mapa de Casos con su último Presupuesto.
	 * 
	 * @param setIds: Conjunto de Ids de Casos
	 * @return mapa de Casos con su último Presupuesto
	 */
	public static Map<Id, Presupuesto__c> getMapaUltPresupCasos(Set<Id> setIds){
		Map<Id, Presupuesto__c> mapa = new Map<Id, Presupuesto__c>();
		if(setIds != null && (!setIds.isEmpty())){
			List<Presupuesto__c> lista = new List<Presupuesto__c>(
				[SELECT Id,
						CreatedDate,
						Name,
						PRE_LKP_Caso__c,
						PRE_NUM_Version__c,
						PRE_RES_Importe_total__c,
						PRE_RES_Importe_Total_Cia_AI__c,
						PRE_RES_Importe_Total_Cia_DI__c,
						PRE_RES_Importe_Total_Cliente_AI__c,
						PRE_RES_Importe_Total_Cliente_DI__c,
						PRE_RES_Importe_Total_DI__c,
						PRE_RES_Porcentaje_Imp_Cia_Cliente__c,
						PRE_SEL_Motivo_Rechazo__c,
						PRE_SEL_Estado__c,
						PRE_SEL_Estado_Anterior__c,
						PRE_TXT_Identificador__c,
						PRE_TXT_MotivoAprobacion__c
				 FROM Presupuesto__c WHERE PRE_LKP_Caso__c IN :setIds
				 ORDER BY PRE_LKP_Caso__c ASC, PRE_NUM_Version__c DESC]);
			for(Presupuesto__c registro : lista){
				if(mapa.get(registro.PRE_LKP_Caso__c) == null){
					mapa.put(registro.PRE_LKP_Caso__c, registro);
				}
			}
		}
		return mapa;
	}
}