/**
 * Clase controladora de la Visualforce "SiniIndemnPartidasController" encargada de gestionar las partidas de un Siniestro Indemnizable.
 * 
 * @author EVERIS
 */
public without sharing class SiniIndemnPartidasController {
	public String fase {get; set;}
	private String idTabBusqClientes;
	private String codigoVDN;
	private String paginaRetorno;
	public Case caso {get; set;}
	public Boolean creacionItem {get; set;}
	public Boolean actualizacionItem {get;set;}
	public List<Indemnizable_Partida__c> listaItems {get; set;}
	public Integer indiceListaItems {get; set;}
	public Indemnizable_Partida__c nuevoItem{get; set;}
	public String tituloFormularioEdicion {get; set;}
	public Indemnizable_Documento__c agrupador {get; set;}
	public String tipoDocumento {get;set;}
	public String tipoActuacion {get; set;}

	public SiniIndemnPartidasController(ApexPages.standardController stdCtr){
		PageReference paginaActual = ApexPages.currentPage();

		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}

		if(paginaActual.getParameters().containsKey('VDN')){
			codigoVDN = paginaActual.getParameters().get('VDN');
		}

		if(paginaActual.getParameters().containsKey('idTabBusqClientes')){
			idTabBusqClientes = paginaActual.getParameters().get('idTabBusqClientes');
		}

		if(paginaActual.getParameters().containsKey('retorno')){
			paginaRetorno = paginaActual.getParameters().get('retorno');
		}

		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			caso = (Case)stdCtr.getRecord();
			List<Case> listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{caso.Id}).values();
			//List<Case> listaCasosQuery = Util_Caso.queryMapSiniCaso(new Set<Id>{caso.Id},null,1).values();
			//List<Case> listaCasosQuery = Util_Siniestro.queryCaso(caso.Id, null, 1);
			if(listaCasosQuery.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
			else {
				caso = listaCasosQuery.get(0);
				tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
				List<Indemnizable_Documento__c> listaAgrupador = Util_Indemnizables.queryMapDocs(new Set<Id>{paginaActual.getParameters().get('idDocIndemnizable')}).values();
				System.debug('Lista_Agrupador>>>'+listaAgrupador);
				if(listaAgrupador.isEmpty()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				}
				else {
					agrupador = listaAgrupador.get(0);
					listaItems = Util_Indemnizables.queryMapPartidasByDoc(new Set<Id>{agrupador.Id}).values();
				}
			}
		}
	}//FIN CONSTRUCTOR

	public void crearItem(){
		actualizacionItem = false;
		creacionItem = true;
		//nuevoItem = new WorkOrderLineItem();
		nuevoItem = new Indemnizable_Partida__c();
		nuevoItem.INDP_LKP_Documento_Indemnizable__c = agrupador.Id;
		tituloFormularioEdicion = 'Datos de nueva partida';
	}//FIN crearItem()

	public void guardarItem(){
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try	{
			upsert nuevoItem;   
			nuevoItem = Util_Indemnizables.queryMapPartidas(new Set<Id>{nuevoItem.Id}).get(nuevoItem.Id);
			listaItems.add(nuevoItem);
			creacionItem = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
	        if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
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
        system.debug(listaItems + ' listaItems');
        system.debug(indiceListaItems + ' indiceListaItems');
		nuevoItem = listaItems.get(indiceListaItems);
		tituloFormularioEdicion = 'Datos de actualización de partida';
	}// FIN seleccionarResultado

	public void actualizarItem(){
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
		PageReference paginaRedireccion = new PageReference(paginaRetorno);
		paginaRedireccion.getParameters().put('id', caso.Id);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		if(idTabBusqClientes != null){
			paginaRedireccion.getParameters().put('idTabBusqClientes', idTabBusqClientes);
		}
		if(codigoVDN != null){
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver()
}