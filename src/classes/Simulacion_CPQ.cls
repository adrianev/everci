/**
 * Clase controladora de la Visualforce "Simulacion_CPQ" encargada de gestionar las partidas de una reparación.
 * 
 * @author EVERIS
 */
public without sharing class Simulacion_CPQ {
	public Case caso {get; set;}
	public Boolean esB2C {get; set;}
	private String solicitudExistente;
	public String fase {get; set;}
	private String paginaRetorno;
	public WorkOrder agrupador {get; set;}
	public Boolean creacionItem {get; set;}
	public Boolean actualizacionItem {get;set;}
	public List<WorkOrderLineItem> listaItems {get; set;}
	public Integer indiceListaItems {get; set;}
	public WorkOrderLineItem nuevoItem {get; set;}
	public String gremio {get; set;}	
	public String tipoActuacion {get; set;}
	public Integer tipoCaso {get; set;}//Almacena 1 si es un caso y un 2 si es un servicio B2B/B2B2C
	public Account cuenta {get; set;}   

	public Simulacion_CPQ(ApexPages.standardController stdCtr){
		PageReference paginaActual = ApexPages.currentPage();
		if (paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}
		if (paginaActual.getParameters().containsKey('solicitudExistente')){
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}
		if (paginaActual.getParameters().containsKey('retorno')){
			paginaRetorno = paginaActual.getParameters().get('retorno');
		} 

		// Comprobar parametros de entrada
		if ((!paginaActual.getParameters().containsKey('id')) || (!paginaActual.getParameters().containsKey('idOrdenTrabajo'))){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			caso = (Case) stdCtr.getRecord();
			List<Case> listaCasosQuery = new List<Case>();
			if (Util_Siniestro.esSiniestro(caso)){
				tipoCaso = 1;
				listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{caso.Id}).values();
				//listaCasosQuery = Util_Caso.queryMapSiniCaso(new Set<Id>{caso.Id},null,1).values();
				//listaCasosQuery = Util_Siniestro.queryCaso(caso.Id, null, 1);
			}
			else {
				tipoCaso = 2;
				listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{caso.Id}).values();
				//listaCasosQuery = Util_Caso.getMapaCasos(new Set<Id>{caso.Id}).values();
				//listaCasosQuery = Util_B2B.queryCaso(caso.Id);
			}
			if (listaCasosQuery.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
			else {
				caso = listaCasosQuery.get(0);
				esB2C = caso.CAS_FOR_EsB2C__c;
				tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);

				List<WorkOrder> listaAgrupador = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{paginaActual.getParameters().get('idOrdenTrabajo')}).values();
				//List<WorkOrder> listaAgrupador = Util_Orden_Trabajo.queryOT(paginaActual.getParameters().get('idOrdenTrabajo'), null, null);
				if (listaAgrupador.isEmpty()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				}
				else {
					agrupador = listaAgrupador.get(0);
					listaItems = Util_Orden_Trabajo.getListaPartidasOT(agrupador.Id, false);
					/*listaItems = new List<WorkOrderLineItem>(
						[SELECT Description,
								PAR_TXT_Baremo_Codigo__c,
								PAR_DIV_Liquidar_Prof_DI__c,
								Status,
								WorkOrderId,
								PAR_DIV_Facturacion_Total_AI__c,
								PAR_DIV_Facturacion_Total_DI__c,
								PAR_DIV_Cargar_Comp_AI__c,
								PAR_DIV_Cargar_Cliente_AI__c,
								PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
								PAR_POR_Impuesto_Prof__c,
								PAR_DIV_Liquidar_Prof_AI__c,
								PAR_FOR_Cargar_Comp_DI__c,
								PAR_FOR_Cargar_Cliente_DI__c,
								PAR_TXT_Detalle_WOLI__c,
								PAR_NUM_Unidades__c
						FROM WorkOrderLineItem
						WHERE WorkOrderId = :agrupador.Id]);*/
				}
			}

		}
	}//FIN CONSTRUCTOR

	public void crearItem(){
		actualizacionItem = false;
		creacionItem = true;
		nuevoItem = new WorkOrderLineItem();
		nuevoItem.WorkOrderId = agrupador.Id;
	}//FIN crearItem()

	public void guardarItem(){
		system.Savepoint puntoGuardado = Database.setSavepoint();

		try {
			nuevoItem.PAR_DIV_Facturacion_Total_AI__c = nuevoItem.PAR_DIV_Cargar_Cliente_AI__c + nuevoItem.PAR_DIV_Cargar_Comp_AI__c;
			nuevoItem.PAR_DIV_Facturacion_Total_DI__c = ((nuevoItem.PAR_DIV_Cargar_Cliente_AI__c + (nuevoItem.PAR_DIV_Cargar_Cliente_AI__c*(nuevoItem.PAR_POR_Porcentaje_Imp_Cia_Cliente__c/100))) + (nuevoItem.PAR_DIV_Cargar_Comp_AI__c + (nuevoItem.PAR_DIV_Cargar_Comp_AI__c*(nuevoItem.PAR_POR_Porcentaje_Imp_Cia_Cliente__c/100))));

			insert nuevoItem;
			nuevoItem = Util_Partida.queryMapPartidasOT(new Set<Id>{nuevoItem.Id}).get(nuevoItem.Id);
			//nuevoItem = Util_Partida.queryPartidasOT(nuevoItem.Id);
			/*nuevoItem = [SELECT
						 Description,
						 PAR_TXT_Baremo_Codigo__c,
						 PAR_DIV_Liquidar_Prof_DI__c,
						 Status,
						 WorkOrderId,
						 PAR_DIV_Facturacion_Total_AI__c, 
						 PAR_DIV_Facturacion_Total_DI__c, 
						 PAR_DIV_Cargar_Comp_AI__c,
						 PAR_DIV_Cargar_Cliente_AI__c,
						 PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
						 PAR_POR_Impuesto_Prof__c,
						 PAR_DIV_Liquidar_Prof_AI__c,
						 PAR_FOR_Cargar_Comp_DI__c,
						 PAR_FOR_Cargar_Cliente_DI__c, 
						 PAR_TXT_Detalle_WOLI__c
						 FROM WorkOrderLineItem 
						 WHERE Id = :nuevoItem.Id];*/
			listaItems.add(nuevoItem);
			creacionItem = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			system.debug(e.getStackTraceString());
		}
	}//Fin guardarItem

	public void cancelarCreacionItem(){
		nuevoItem = null;
		creacionItem = false;
		actualizacionItem = false;
	}//Fin cancelarCreacionItem

	public void seleccionarItem(){ 
		actualizacionItem = true;
		creacionItem = true;
		nuevoItem = listaItems.get(indiceListaItems);
	}// FIN seleccionarResultado

	public void actualizarItem(){
		nuevoItem.PAR_DIV_Facturacion_Total_AI__c = nuevoItem.PAR_DIV_Cargar_Cliente_AI__c + nuevoItem.PAR_DIV_Cargar_Comp_AI__c;
		nuevoItem.PAR_DIV_Facturacion_Total_DI__c = ((nuevoItem.PAR_DIV_Cargar_Cliente_AI__c + (nuevoItem.PAR_DIV_Cargar_Cliente_AI__c*(nuevoItem.PAR_POR_Porcentaje_Imp_Cia_Cliente__c/100))) + (nuevoItem.PAR_DIV_Cargar_Comp_AI__c + (nuevoItem.PAR_DIV_Cargar_Comp_AI__c*(nuevoItem.PAR_POR_Porcentaje_Imp_Cia_Cliente__c/100))));

		update nuevoItem;
		nuevoItem = null;
		actualizacionItem = false;
		creacionItem = false;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
	}//FIN actualizarItem

	public void eliminarItem(){
		delete listaItems.get(indiceListaItems-1); 
		listaItems.remove(indiceListaItems-1);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
	}//FIN eliminarItem

	public PageReference volver(){
		System.debug('Simulacion_CPQ: volver: '+paginaRetorno);
		PageReference paginaRedireccion = new PageReference(paginaRetorno);
		paginaRedireccion.getParameters().put('id', caso.Id);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver()  
}