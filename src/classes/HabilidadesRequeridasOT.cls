/**
 * Clase controladora de la Visualforce "Sini_Habilidades" encargada de gestionar las habilidades de la WorkOrder
 * 
 * @author EVERIS
 */
public without sharing class HabilidadesRequeridasOT {
	public Case caso {get; set;}
	public Boolean esB2C {get; set;}
	private String solicitudExistente;
	public String fase {get; set;}
	private String paginaRetorno;
	public Boolean creacionItem {get; set;}
	public Boolean actualizacionItem {get;set;}
	public List<SkillRequirement> listaItems {get; set;}
	public Integer indiceListaItems {get; set;}
	public SkillRequirement nuevoItem {get; set;}
	public WorkOrder agrupador {get; set;}
	public String categoria {get; set;}
	public List<SelectOption> listaCategorias {get; set;}
	public String habilidad {get; set;}
	public List<SelectOption> listaHabilidades {get; set;}
	public Map<String, Id> mapaHabFiltradas = new Map<String, Id>();
	public List<Skill> listaHabilidadesFiltradas;
	public String nombreCategoria {get; set;}
	public Map<String, String> mapaCategorias {get; set;}
	public String itemCategoria {get;set;}
	public String tipoActuacion {get; set;}
	public Integer tipoCaso {get; set;}
	public Account cuenta {get; set;}
	private String idConfirmacion{get;set;}
	private String numeroGremiosArbolSalida{get;set;}
	/**
 	 * Constructor de la clase
 	 */  
	public HabilidadesRequeridasOT(ApexPages.standardController stdCtr){
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

		if (!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		if (paginaActual.getParameters().containsKey('idConfirmacion')){
			idConfirmacion = paginaActual.getParameters().get('idConfirmacion');
		}
		if (paginaActual.getParameters().containsKey('numeroGremiosArbolSalida')){
			numeroGremiosArbolSalida = paginaActual.getParameters().get('numeroGremiosArbolSalida');	
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
                    system.debug(agrupador + ' WOINFO');

					itemCategoria = '';
					mapaCategorias = new Map<String, String>();
					//Llamo a una funcion que rellene las categorías
					rellenarListaCategorias();

					List<SkillRequirement> listaItemsAux = Util_Habilidades.getSkillRequirementByRelatedRecord(new set<Id>{agrupador.Id}).values();
					//List<SkillRequirement> listaItemsAux = Util_Habilidades.queryMapHabilidadesRequeridas(null,new set<Id>{agrupador.Id}).values();
					//List<SkillRequirement> listaItemsAux = Util_Habilidades.queryHabilidadesRequeridas(null,agrupador.Id);
					/*List<SkillRequirement> listaItemsAux = new List<SkillRequirement>(
							[SELECT SkillId,
							 SkillLevel,
							 SkillNumber,
							 RelatedRecordId,
							 Skill.Description,
							 Skill.MasterLabel,
							 Skill.DeveloperName 
							 FROM SkillRequirement 
							 WHERE RelatedRecordId = :agrupador.Id
							 //AND (NOT Skill.DeveloperName LIKE 'G_%')
							 //AND (NOT Skill.DeveloperName LIKE 'CIA_%')]);*/
					listaItems = new List<SkillRequirement>();
					for(SkillRequirement reqHab : listaItemsAux){
						if(!reqHab.Skill.DeveloperName.contains('G_') && !reqHab.Skill.DeveloperName.contains('CIA_')){
							listaItems.add(reqHab);
						}
					}			
				}
			}
		}
	}//FIN CONSTRUCTOR	


	/**
 	 * Método encargado de rellenar la lista desplegable de categorías de habilidades
 	 */  
	public void rellenarListaCategorias(){
		DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Configuracion_General__mdt').getDescribe();
		system.debug('*** obj: ' + obj);
		DescribeFieldResult campoCategoria = obj.fields.getMap().get('CF_SEL_Categoria_Habilidad__c').getDescribe();
		system.debug('****** campoCategoria : ' + campoCategoria);
		listaHabilidades = new List<SelectOption>();
		listaHabilidades.add(new SelectOption('', ' -- Ninguno -- ')); 
		listaCategorias = new List<SelectOption>(); 
		listaCategorias.add(new SelectOption('', ' -- Ninguno -- '));	 
		for(Schema.PicklistEntry valorCampoCategoria : campoCategoria.getPicklistValues()){
			mapaCategorias.put(valorCampoCategoria.getValue(), valorCampoCategoria.getLabel());
			system.debug('********** valorCampoCategoria : ' + valorCampoCategoria);
			listaCategorias.add(new SelectOption(valorCampoCategoria.getValue(), valorCampoCategoria.getLabel())); 
		}
		system.debug('********** listaCategorias : ' + listaCategorias);
		system.debug('********** mapaCategorias : ' + mapaCategorias);
	}//FIN rellenarListaCategorias


	/**
 	 * Método encargado de iniciar el proceso de añadir una nueva habilidad
 	 */  
	public void crearItem()
	{
		//Llamo a una funcion que rellene las categorías
		//rellenarListaCategorias();
		actualizacionItem = false;
		creacionItem = true;
		nuevoItem = new SkillRequirement();
		nuevoItem.RelatedRecordId = agrupador.Id;
	}//FIN crearItem()


	/**
 	 * Método encargado de guardar la nueva habilidad añadida
 	 */  
	public void guardarItem(){
		if(habilidad != null && categoria != null){
			nuevoItem.SkillId = mapaHabFiltradas.get(habilidad);
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				insert nuevoItem;
				List<SkillRequirement> listaHabilidadesRequeridas = Util_Habilidades.getSkillRequirementById(new set<Id>{nuevoItem.Id}).values();
				//List<SkillRequirement> listaHabilidadesRequeridas = Util_Habilidades.queryMapHabilidadesRequeridas(new set<Id>{nuevoItem.Id},null).values();
				//List<SkillRequirement> listaHabilidadesRequeridas = Util_Habilidades.queryHabilidadesRequeridas(nuevoItem.Id,null);
				if(!listaHabilidadesRequeridas.isEmpty()){
					nuevoItem = listaHabilidadesRequeridas.get(0);
					listaItems.add(nuevoItem);
				}
				/*nuevoItem = [SELECT SkillId,
				             SkillLevel,
				             SkillNumber,
				             RelatedRecordId,
				             Skill.Description,
				             Skill.MasterLabel,
				             Skill.DeveloperName
				             FROM SkillRequirement 
				             WHERE Id = :nuevoItem.Id];	*/					 
				creacionItem = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				system.debug(e.getStackTraceString());
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
		}

	}//Fin guardarItem


	/**
 	 * Método encargado de cancelar el proceso de añadir una nueva habilidad requerida iniciado
 	 */	 
	public void cancelarCreacionItem(){
		nuevoItem = null;
		creacionItem = false;
		actualizacionItem = false;
	}//Fin cancelarCreacionItem


	/**
 	 * Método encargado de guardar la habilidad requerida en edición con los cambios realizados
 	 */  
	public void actualizarItem(){
		update nuevoItem;
		nuevoItem = null;
		actualizacionItem = false;
		creacionItem = false;		
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
	}//FIN actualizarItem


	/**
 	 * Método encargado de mostrar la lista de habilidades disponibles según categoría y gremio seleccionados
 	 */  
	public void buscarHabilidades(){
		listaHabilidades = new List<SelectOption>();
		listaHabilidades.add(new SelectOption('', ' -- Ninguno -- ')); 
		system.debug('********* categoria : ' + categoria );
		String gremioComun = '00';
		String gremio;
		if(agrupador.OTR_SEL_Gremio__c.length() == 1){
			gremio = '0' + agrupador.OTR_SEL_Gremio__c;
		}else{
			gremio = agrupador.OTR_SEL_Gremio__c;
		}

		String devName1 = categoria + gremio + '_';
		String devName2 = categoria + gremioComun + '_';
		//String filtroQuery = 'DeveloperName LIKE \''+devName1+'%'+'\' OR DeveloperName LIKE \''+devName2+'%'+'\'';
		listaHabilidadesFiltradas = Util_FSL.getSkillByDevNames(devName1,devName2).values();
		//listaHabilidadesFiltradas = Util_Habilidades.queryHabilidadesByFilter(filtroQuery);
		/*listaHabilidadesFiltradas = new List<Skill>(
				[ SELECT MasterLabel,
				  DeveloperName 
				  FROM Skill
				  WHERE DeveloperName LIKE :devName1 + '%' OR DeveloperName LIKE :devName2 + '%']);*/
		for(Skill hab : listaHabilidadesFiltradas){
			mapaHabFiltradas.put(hab.DeveloperName, hab.Id);
			listaHabilidades.add(new SelectOption(hab.DeveloperName, hab.MasterLabel));
		}
	}//FIN buscarHabilidades


	/**
 	 * Método encargado de eliminar la habilidad requerida seleccionada
 	 */  
	public void eliminarItem(){	   
		delete listaItems.get(indiceListaItems-1); 
		listaItems.remove(indiceListaItems-1);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
	}//FIN eliminarItem


	/**
 	 * Método encargado de navegar a la página anterior al proceso actual
 	 * 
 	 * @return página a navegar tras la acción 'volver'
 	 */  
	public PageReference volver(){
		PageReference paginaRedireccion = new PageReference(paginaRetorno);
		paginaRedireccion.getParameters().put('id', caso.Id);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		if (paginaRetorno  == '/apex/' + Label.VF_RESERVARCITA){
			paginaRedireccion.getParameters().put('idOrdenTrabajo', agrupador.Id);		
		}
		paginaRedireccion.getParameters().put('idConfirmacion',idConfirmacion);
		paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',numeroGremiosArbolSalida);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver()
}