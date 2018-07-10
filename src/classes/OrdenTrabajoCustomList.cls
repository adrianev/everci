public with sharing class OrdenTrabajoCustomList {
    
    private ApexPages.StandardSetController controller;
    private transient ApexPages.StandardSetController controllerPropio;
    
    private Map<Id,Vista_de_lista_personalizada__c> vistasMapa;
    
    public Boolean existeRedireccion {get;set;}

    public List<Workorder> registrosMostrar {get;set;}
    public List<SelectOption> vistas {get;set;}
    public Map<Id,Boolean> checkboxes {get;set;}
    public String vistaSeleccionada{get;set;}
    public Integer woPorPag{get;set;}
    public Integer woSeleccionar{get;set;}
    public Integer woEnPag{get;set;}
    public Integer woTotal{get;set;}
    
    public Integer enPag {get;set;}
    public Integer numPag {get;set;}
    
    public Boolean haySig{get;set;}
    public Boolean hayPrev{get;set;}
    public Boolean masterCheckbox{get;set;}
    public Boolean misServicios{get;set;}
    public Boolean rechazados{get;set;}
    
    private String lastQuery;
    
    public Boolean esGestor{get;set;}
    
    public String nombreVistaNueva{get;set;}
    
    //SelectOptions
    public List<SelectOption> picklistGremios{get;set;}
    public List<SelectOption> picklistCompanias{get;set;}
    public List<SelectOption> picklistNombreTipoProducto{get;set;}
    public List<SelectOption> picklistDireccionesTerritoriales{get;set;}
    public List<SelectOption> picklistProvincias{get;set;}
    public List<SelectOption> picklistTiposServicio{get;set;}
    public List<SelectOption> picklistTipoIntervencion{get;set;}
    
    
    
    public Workorder woNuevoFiltro {get;set;}
    public Case casoNuevoFiltro {get;set;}
    
    public Date inicioRecepcionAlbaran {get;set;}
    public Date finRecepcionAlbaran {get;set;}
    
    public Date inicioCierre {get;set;}
    public Date finCierre {get;set;}
    
    //ADDED 12/06/2018 ARL
    //public List<String> companiaSeleccionada {get;set;} 
    //public List<String> direccionTerritorialSeleccionada {get;set;}
    //public List<String> provinciaSeleccionada {get;set;}
    //public List<String> gremioSeleccionado {get;set;}
    //public List<String> tipologiaDeServicioSeleccionada {get;set;}
    //public List<String> tipoIntervencionSeleccionada {get;set;}
    //public List<String> productoSeleccionado {get;set;}
    public List<SelectOption> gremioSeleccionado {get;set;}
    public List<SelectOption> companiaSeleccionada {get;set;} 
    public List<SelectOption> direccionTerritorialSeleccionada {get;set;}
    public List<SelectOption> provinciaSeleccionada {get;set;}
    public List<SelectOption> tipologiaDeServicioSeleccionada {get;set;}
    public List<SelectOption> tipoIntervencionSeleccionada {get;set;}
    public List<SelectOption> productoSeleccionado {get;set;}
    
    public String numeroPartidasMin {get;set;}
    public String numeroPartidasMax {get;set;}
    
    //public Boolean requierePeritoCheck {get;set;}
    public String importeLiquidarProfMin {get;set;}
    public String importeLiquidarProfMax {get;set;}
    public String importeSubtotalPartidasMin {get;set;}
    public String importeSubtotalPartidasMax {get;set;}
    public String filtroConfianzaRed {get;set;}
    public String filtroRequierePerito {get;set;}
    public String importeCIAIntervencionMin {get;set;}
    public String importeCIAIntervencionMax {get;set;}
    public String filtroCodigoBaremo {get; set;}
    
    
    public Boolean excluirGremio {get;set;}
    public Boolean excluirCompania {get;set;}
    public Boolean excluirProvincia {get;set;}
    public Boolean excluirDireccionTerritorial {get;set;}
    public Boolean excluirTipologiaServicio {get;set;}
    public Boolean excluirTipoIntervencion {get;set;}
    public Boolean excluirProducto {get;set;}
    
    //Atributos para pendiente gestor
    public Boolean esPendiente {get;set;}
    private Integer numPageUpdate = 0;
	public boolean isOver {get;set;}
	public WorkOrder woUpdate {get;set;} 
   
    
    private List<String> campos = new List<String> {'Id','WorkOrderNumber','OwnerId', 'Status','OTR_FOR_Compania__c',
        										'OTR_FOR_Codigo_Profesional__c','OTR_DAT_Fecha_Recepcion_Albaran__c','OTR_SEL_Gremio__c',
        										'EndDate','RecordType.Name','OTR_FOR_DT__c','OTR_FOR_Provincia__c','OTR_RES_Liquidar_prof_AI__c',
        										'OTR_RES_Facturar_Compania_DI__c','OTR_TXT_Codigo_de_baremo__c','Case.CAS_LKP_Compania__c',
        										'OTR_LKP_Recurso_Servicio__c','OTR_FOR_Tipo_de_Caso__c','OTR_SEL_Tipologia_de_Servicio__c','OTR_RES_Partidas__c',
        										'OTR_CAS_Confianza_en_la_red__c'};
    
    public OrdenTrabajoCustomList(ApexPages.StandardSetController ctr){

		if(!Test.isRunningTest()){
			ctr.addFields(campos);
		}
        
        esGestor = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_AUDITORIA_GESTION);
        
        controller = ctr;
        
        existeRedireccion = false;

        woPorPag = 200;
        woSeleccionar = 6000;
        woEnPag = 0;
        woTotal = 0;
        enPag = 0;
        numPag = Integer.valueOf(Math.ceil(Decimal.valueOf(woTotal)/woPorPag));
       	woNuevoFiltro = new Workorder();
       	casoNuevoFiltro = new Case();
       	haySig = false;
       	hayPrev = false;
		//initController();
        //vistas = controller.getListViewOptions();
        
        //inicializamos campos a nulo
		limpiarFiltros();
        
        
        
        
        cargarVistasCustom();
        system.debug(vistas);
        
        esPendiente = false;
        numPageUpdate = 0;
		isOver = false;
		woUpdate = new Workorder();
    }
    
    public void sigPag(){
    	enPag++;
    	controllerPropio = new ApexPages.StandardSetController(Database.query(lastQuery));
    	initController();

        /*controllerPropio.next();
		registrosMostrar = (List<Workorder>)controllerPropio.getRecords();
		woEnPag = registrosMostrar.size();
        checkboxes = new Map<Id,Boolean>();
        for(Workorder wo: registrosMostrar){
        	checkboxes.put(wo.Id,false);
        }
        haySig = controllerPropio.getHasNext();
        hayPrev = controllerPropio.getHasPrevious();
        masterCheckbox = false;*/
    }
    
    public void antPag(){
    	enPag--;
    	controllerPropio = new ApexPages.StandardSetController(Database.query(lastQuery));
    	initController();
        /*controllerPropio.previous();
        registrosMostrar = (List<Workorder>)controllerPropio.getRecords();
        checkboxes = new Map<Id,Boolean>();
        woEnPag = registrosMostrar.size();
        for(Workorder wo: registrosMostrar){
        	checkboxes.put(wo.Id,false);
        }
        haySig = controllerPropio.getHasNext();
        hayPrev = controllerPropio.getHasPrevious();
        masterCheckbox = false;*/
    }
    
    public void limpiarFiltros(){
    	nombreVistaNueva = null;
    	woNuevoFiltro.OTR_LKP_Recurso_Servicio__c = null;
    	woNuevoFiltro.OTR_CAS_Pendiente_de_Gestor__c = false;
    	woNuevoFiltro.OTR_SEL_AG_Motivo__c = '';
    	inicioRecepcionAlbaran = null;
    	finRecepcionAlbaran = null;
    	inicioCierre = null;
    	finCierre = null;
    	//companiaSeleccionada = null;
    	//direccionTerritorialSeleccionada = null;
    	//provinciaSeleccionada = null;
    	//gremioSeleccionado = null;
    	//tipologiaDeServicioSeleccionada = null;
    	//tipoIntervencionSeleccionada = null;
    	//productoSeleccionado = null;
    	companiaSeleccionada = new List<SelectOption>();
    	direccionTerritorialSeleccionada = new List<SelectOption>();
    	provinciaSeleccionada = new List<SelectOption>();
    	gremioSeleccionado = new List<SelectOption>();
    	tipologiaDeServicioSeleccionada = new List<SelectOption>();
    	tipoIntervencionSeleccionada = new List<SelectOption>();
    	productoSeleccionado = new List<SelectOption>();
    	numeroPartidasMin = null;
    	numeroPartidasMax = null;
    	importeLiquidarProfMin = null;
    	importeLiquidarProfMax = null;
    	importeSubtotalPartidasMin = null;
    	importeSubtotalPartidasMax = null;
    	filtroConfianzaRed = null;
    	filtroRequierePerito = null;
    	importeCIAIntervencionMin = null;
    	importeCIAIntervencionMax = null;
    	filtroCodigoBaremo = null;
    	excluirGremio = false;
    	excluirCompania = false;
    	excluirProvincia = false;
    	excluirDireccionTerritorial = false;
    	excluirTipologiaServicio = false;
    	excluirTipoIntervencion = false;
    	excluirProducto = false;
    	misServicios = false;
    	rechazados = false;
    	
    	//Reinicializamos picklist
    	picklistGremios = getPicklistGremios();
		picklistCompanias = getpicklistCompanias();
    	picklistNombreTipoProducto = getpicklistNombreTipoProducto();
    	picklistDireccionesTerritoriales = getpicklistDireccionesTerritoriales();
    	picklistProvincias = getpicklistProvincias();
    	picklistTiposServicio = getpicklistTiposServicio();
    	picklistTipoIntervencion = getpicklistTipoIntervencion();
    	
    }
    
    public void recargaFiltroExistente(){
    	if(!String.isBlank(vistaSeleccionada)){
	    	Vista_de_lista_personalizada__c nuevaVista = vistasMapa.get(vistaSeleccionada);
	    	List<Filtro_de_lista__c> filtrosNuevos = nuevaVista.Filtros__r;
	    	rellenarFiltros(nuevaVista,filtrosNuevos);
	    	String query = construirFiltro(nuevaVista,filtrosNuevos);
	    	controllerPropio = new ApexPages.StandardSetController(Database.query(query));
	    	initController();
    	} else {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha seleccionado vista'));
    	}
    }
    
    private void rellenarFiltros(Vista_de_lista_personalizada__c nuevaVista, List<Filtro_de_lista__c> filtrosNuevos){
    	limpiarFiltros();
    	nombreVistaNueva = nuevaVista.Name;
    	for(Filtro_de_lista__c filtro: filtrosNuevos){
    		if(filtro.Campo__c == 'OTR_FOR_Compania__c'){
    			if(filtro.Comparacion__c == 'NOT IN')
    				excluirCompania = true;
    			String valores = filtro.Valor__c.removeEnd(')').removeStart('(');
    			List<String> valSeparado = valores.split(',');
    			for(Integer i=picklistCompanias.size()-1; i>= 0; i--){
    				if(valSeparado.contains('\''+picklistCompanias[i].getValue()+'\'')){
    					companiaSeleccionada.add(picklistCompanias[i]);
    					picklistCompanias.remove(i);
    				}
    			}
    		} else if(filtro.Campo__c == 'OTR_FOR_Provincia__c'){
    			if(filtro.Comparacion__c == 'NOT IN')
    				excluirProvincia = true;
    			String valores = filtro.Valor__c.removeEnd(')').removeStart('(');
    			List<String> valSeparado = valores.split(',');
    			for(Integer i=picklistProvincias.size()-1; i>= 0; i--){
    				if(valSeparado.contains('\''+picklistProvincias[i].getValue()+'\'')){
    					provinciaSeleccionada.add(picklistProvincias[i]);
    					picklistProvincias.remove(i);
    				}
    			}
    		} else if(filtro.Campo__c == 'OTR_SEL_Gremio__c'){
    			if(filtro.Comparacion__c == 'NOT IN')
    				excluirGremio = true;
    			String valores = filtro.Valor__c.removeEnd(')').removeStart('(');
    			List<String> valSeparado = valores.split(',');
    			for(Integer i=picklistGremios.size()-1; i>= 0; i--){
    				if(valSeparado.contains('\''+picklistGremios[i].getValue()+'\'')){
    					gremioSeleccionado.add(picklistGremios[i]);
    					picklistGremios.remove(i);
    				}
    			}
    		} else if(filtro.Campo__c == 'OTR_FOR_DT__c'){
    			if(filtro.Comparacion__c == 'NOT IN')
    				excluirDireccionTerritorial = true;
    			String valores = filtro.Valor__c.removeEnd(')').removeStart('(');
    			List<String> valSeparado = valores.split(',');
    			for(Integer i=picklistDireccionesTerritoriales.size()-1; i>= 0; i--){
    				if(valSeparado.contains('\''+picklistDireccionesTerritoriales[i].getValue()+'\'')){
    					direccionTerritorialSeleccionada.add(picklistDireccionesTerritoriales[i]);
    					picklistDireccionesTerritoriales.remove(i);
    				}
    			}
    		} else if(filtro.Campo__c == 'OTR_SEL_Tipologia_de_Servicio__c'){
    			if(filtro.Comparacion__c == 'NOT IN')
    				excluirTipologiaServicio = true;
    			String valores = filtro.Valor__c.removeEnd(')').removeStart('(');
    			List<String> valSeparado = valores.split(',');
    			for(Integer i=picklistTiposServicio.size()-1; i>= 0; i--){
    				if(valSeparado.contains('\''+picklistTiposServicio[i].getValue()+'\'')){
    					tipologiaDeServicioSeleccionada.add(picklistTiposServicio[i]);
    					picklistTiposServicio.remove(i);
    				}
    			}
    		} else if(filtro.Campo__c == 'OTR_FOR_Tipo_de_Caso__c'){
    			if(filtro.Comparacion__c == 'NOT IN')
    				excluirTipoIntervencion = true;
    			String valores = filtro.Valor__c.removeEnd(')').removeStart('(');
    			List<String> valSeparado = valores.split(',');
    			for(Integer i=picklistTipoIntervencion.size()-1; i>= 0; i--){
    				if(valSeparado.contains('\''+picklistTipoIntervencion[i].getValue()+'\'')){
    					tipoIntervencionSeleccionada.add(picklistTipoIntervencion[i]);
    					picklistTipoIntervencion.remove(i);
    				}
    			}
    		} else if(filtro.Campo__c == 'OTR_FOR_Producto__c'){
    			if(filtro.Comparacion__c == 'NOT IN')
    				excluirProducto = true;
    			String valores = filtro.Valor__c.removeEnd(')').removeStart('(');
    			List<String> valSeparado = valores.split(',');
    			for(Integer i=picklistNombreTipoProducto.size()-1; i>= 0; i--){
    				if(valSeparado.contains('\''+picklistNombreTipoProducto[i].getValue()+'\'')){
    					productoSeleccionado.add(picklistNombreTipoProducto[i]);
    					picklistNombreTipoProducto.remove(i);
    				}
    			}
    		} else if(filtro.Campo__c == 'OTR_LKP_Recurso_Servicio__c'){
    			woNuevoFiltro.OTR_LKP_Recurso_Servicio__c = filtro.Valor__c.removeEnd('\'').removeStart('\'');
    		} else if(filtro.Campo__c == 'OTR_DAT_Fecha_Recepcion_Albaran__c'){
    			if(filtro.Comparacion__c == '>=')
    				inicioRecepcionAlbaran = date.valueOf(filtro.Valor__c);
    			else if(filtro.Comparacion__c == '<=')
    				finRecepcionAlbaran = date.valueOf(filtro.Valor__c);
    		} else if(filtro.Campo__c == 'OTR_DAT_Fecha_Cierre_servicio__c'){
    			if(filtro.Comparacion__c == '>=')
    				inicioCierre = date.valueOf(filtro.Valor__c);
    			else if(filtro.Comparacion__c == '<=')
    				finCierre = date.valueOf(filtro.Valor__c);
    		} else if(filtro.Campo__c == 'OTR_RES_Partidas__c'){
    			if(filtro.Comparacion__c == '>=')
    				numeroPartidasMin = filtro.Valor__c;
    			else if(filtro.Comparacion__c == '<=')
    				numeroPartidasMax = filtro.Valor__c;
    		} else if(filtro.Campo__c == 'OTR_CAS_Confianza_en_la_red__c'){
    			filtroConfianzaRed = filtro.Valor__c;
    		} else if(filtro.Campo__c == 'OTR_RES_Liquidar_prof_AI__c'){
    			if(filtro.Comparacion__c == '>=')
    				importeLiquidarProfMin = filtro.Valor__c;
    			else if(filtro.Comparacion__c == '<=')
    				importeLiquidarProfMax = filtro.Valor__c;
    		} else if(filtro.Campo__c == 'OTR_RES_Subtotal_Partidas__c'){
    			if(filtro.Comparacion__c == '>=')
    				importeSubtotalPartidasMin = filtro.Valor__c;
    			else if(filtro.Comparacion__c == '<=')
    				importeSubtotalPartidasMax = filtro.Valor__c;
    		} else if(filtro.Campo__c == 'OTR_FOR_Siniestro_Peritado__c'){
    			filtroRequierePerito = filtro.Valor__c;
    		} else if(filtro.Campo__c == 'OwnerId' && filtro.Valor__c.removeEnd('\'').removeStart('\'') == String.valueOf(UserInfo.getUserId())){
    			misServicios = true;
    		} else if(filtro.Campo__c == 'OTR_CAS_Pendiente_de_Gestor__c' && filtro.Valor__c == 'true'){
    			woNuevoFiltro.OTR_CAS_Pendiente_de_Gestor__c = true;
    		} else if(filtro.Campo__c == 'OTR_CAS_Pendiente_de_Gestor__c' && filtro.Valor__c == 'false'){
    			woNuevoFiltro.OTR_CAS_Pendiente_de_Gestor__c = false;
    		} else if(filtro.Campo__c == 'OTR_SEL_AG_Motivo__c'){
    			woNuevoFiltro.OTR_SEL_AG_Motivo__c = filtro.Valor__c.removeEnd('\'').removeStart('\'');
    		} else if(filtro.Campo__c == 'Status' && filtro.Valor__c.removeEnd('\'').removeStart('\'') == LABEL.OTR_ESTADO_PDTE_AUDIT_GESTION){
    			rechazados = true;
    		} else if(filtro.Campo__c == 'OTR_FOR_Importe_CIA_Intervencion__c'){
    			if(filtro.Comparacion__c == '>=')
    				importeCIAIntervencionMin = filtro.Valor__c;
    			else if(filtro.Comparacion__c == '<=')
    				importeCIAIntervencionMax = filtro.Valor__c;
    		} else if(filtro.Campo__c == 'OTR_TXT_Codigo_de_baremo__c'){
    			filtroCodigoBaremo = filtro.Valor__c.removeEnd('\'').removeStart('\'');
    		}
    	
    	}
    }
    
    public void cargarRedireccion(){
    	
    	controller.setSelected(new List<Workorder>());
    	if(String.isBlank(vistaSeleccionada))
    		recargaFiltroNuevo();
    	else
    		recargaFiltroNoExistente(false);
    }
    
    
    public void recargaFiltroNuevo(){
    	vistaSeleccionada = null;
    	nombreVistaNueva = null;
    	recargaFiltroNoExistente(false);
    }
    
    public void recargaFiltroGuardar(){
    	recargaFiltroNoExistente(true);
    }
    
    private void recargaFiltroNoExistente(Boolean guardar){
    	Vista_de_lista_personalizada__c nuevaVista = new Vista_de_lista_personalizada__c(Tipo_de_objeto__c='WorkOrder');
    	List<Filtro_de_lista__c> filtrosNuevos = new List<Filtro_de_lista__c>();
    	Boolean todoVacio = true;
    	
    	system.debug('[ARL] [Compañía]: '+ companiaSeleccionada + ', '+ companiaSeleccionada.isEmpty());
    	system.debug('[ARL] [Provincia]: '+ provinciaSeleccionada);
    	system.debug('[ARL] [Gremio]: '+ gremioSeleccionado);
    	system.debug('[ARL] [Profesional] : '+woNuevoFiltro.OTR_LKP_Recurso_Servicio__c);
    	system.debug('[ARL] [Dirección Territorial]: '+direccionTerritorialSeleccionada);
    	system.debug('[ARL] [Fecha recepción Albarán]: '+woNuevoFiltro.OTR_DAT_Fecha_Recepcion_Albaran__c);
    	system.debug('[ARL] [Fecha Cierre]: '+ woNuevoFiltro.OTR_DAT_Fecha_Cierre_servicio__c);
    	system.debug('[ARL] [Partidas]:' + numeroPartidasMin+','+numeroPartidasMax);
    	system.debug('[ARL] [Tipología de Servicios]:' +woNuevoFiltro.OTR_SEL_Tipologia_de_Servicio__c);
  		system.debug('[ARL] [Tipo de intervención]:' +tipoIntervencionSeleccionada);
  		system.debug('[ARL] [Confianza en la red]:' +woNuevoFiltro.OTR_CAS_Confianza_en_la_red__c);
  		system.debug('[ARL] [Importe prof antes de imp ] :' +importeLiquidarProfMin+ ', '+importeLiquidarProfMax);
  		system.debug('[ARL] [Importe CIA antes de imp]:' +importeSubtotalPartidasMin+ ', '+importeSubtotalPartidasMax);
  		system.debug('[ARL] [Requiere perito ]:' +woNuevoFiltro.OTR_FOR_Siniestro_Peritado__c);
  		system.debug('[ARL] [Producto]:' +woNuevoFiltro.OTR_SEL_Tipologia_de_Servicio__c);
  
  
    	//[VF][Compañía] Filtro campo: OTR_FOR_Compania__c
    	if(companiaSeleccionada != null && !companiaSeleccionada.isEmpty()){
    		String comparacion = 'IN';
    		if(excluirCompania)
    			comparacion = 'NOT IN';
    		
    		List<String> conjunto = new List<String>();
    		for(SelectOption so: companiaSeleccionada)
    			conjunto.add(so.getValue());
    		
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Compania__c',Comparacion__c=comparacion,Valor__c=''+formatInFields(conjunto)));
    		todoVacio = false;
    	}
    	//[VF][Provincia] Filtro campo: OTR_FOR_Provincia__c
    	if(provinciaSeleccionada != null && !provinciaSeleccionada.isEmpty()){
    		String comparacion = 'IN';
    		if(excluirProvincia)
    			comparacion = 'NOT IN';
    			
    		List<String> conjunto = new List<String>();
    		for(SelectOption so: provinciaSeleccionada)
    			conjunto.add(so.getValue());
    		
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Provincia__c',Comparacion__c=comparacion,Valor__c=''+formatInFields(conjunto)));
    		todoVacio = false;
    	}
    	//[VF][Gremio]  Filtro campo: OTR_SEL_Gremio__c
    	if(gremioSeleccionado != null && !gremioSeleccionado.isEmpty()){
    		String comparacion = 'IN';
    		if(excluirGremio)
    			comparacion = 'NOT IN';
    		
    		List<String> conjunto = new List<String>();
    		for(SelectOption so: gremioSeleccionado)
    			conjunto.add(so.getValue());
    		
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_SEL_Gremio__c',Comparacion__c=comparacion,Valor__c=''+formatInFields(conjunto) ));
    		todoVacio = false;
    	}
    	
    	//[VF][Profesional]  Filtro campo: OTR_LKP_Recurso_Servicio__c
    	if(woNuevoFiltro.OTR_LKP_Recurso_Servicio__c != null){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_LKP_Recurso_Servicio__c',Comparacion__c='=',Valor__c='\''+woNuevoFiltro.OTR_LKP_Recurso_Servicio__c+'\''));
    		todoVacio = false;
    	}
    	
    	//[VF][Dirección Territorial]  Filtro campo: OTR_FOR_DT__c
    	if(direccionTerritorialSeleccionada != null && !direccionTerritorialSeleccionada.isEmpty()){
    		String comparacion = 'IN';
    		if(excluirDireccionTerritorial)
    			comparacion = 'NOT IN';
    			
    		List<String> conjunto = new List<String>();
    		for(SelectOption so: direccionTerritorialSeleccionada)
    			conjunto.add(so.getValue());
    			
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_DT__c',Comparacion__c=comparacion,Valor__c=''+formatInFields(conjunto)));
    		todoVacio = false;
    	}
    	
    	//[VF][Fecha recepción Albarán]  Filtro campo: OTR_DAT_Fecha_Recepcion_Albaran__c
    	//if(woNuevoFiltro.OTR_DAT_Fecha_Recepcion_Albaran__c != null){
    	if(inicioRecepcionAlbaran != null){
    		
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_DAT_Fecha_Recepcion_Albaran__c',Comparacion__c='>=',Valor__c=''+DateTime.newInstanceGMT(inicioRecepcionAlbaran.year(),inicioRecepcionAlbaran.month(),inicioRecepcionAlbaran.day() ).formatGMT('yyyy-MM-dd')+''));
    		todoVacio = false;
    	}
    	
    	//if(woNuevoFiltro.OTR_DAT_Fecha_Recepcion_Albaran__c != null){
    	if(finRecepcionAlbaran != null){
    		
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_DAT_Fecha_Recepcion_Albaran__c',Comparacion__c='<=',Valor__c=''+DateTime.newInstanceGMT(finRecepcionAlbaran.year(),finRecepcionAlbaran.month(),finRecepcionAlbaran.day() ).formatGMT('yyyy-MM-dd')+''));
    		todoVacio = false;
    	}
    	
    	
    	// [VF][Fecha Cierre] Filtro campo: OTR_DAT_Fecha_Cierre_servicio__c
    	//if(woNuevoFiltro.OTR_DAT_Fecha_Cierre_servicio__c != null){
    	if(inicioCierre != null){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_DAT_Fecha_Cierre_servicio__c',Comparacion__c='>=',Valor__c=''+DateTime.newInstanceGMT(inicioCierre.year(),inicioCierre.month(),inicioCierre.day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')/*format('yyyy-MM-dd')*//*date.valueOf(woNuevoFiltro.OTR_DAT_Fecha_Cierre_servicio__c)*/));
    		todoVacio = false;
    	}
    	
    	if(finCierre != null){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_DAT_Fecha_Cierre_servicio__c',Comparacion__c='<=',Valor__c=''+DateTime.newInstanceGMT(finCierre.year(),finCierre.month(),finCierre.day(),23,59,59).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')/*format('yyyy-MM-dd')*//*date.valueOf(woNuevoFiltro.OTR_DAT_Fecha_Cierre_servicio__c)*/));
    		todoVacio = false;
    	}
    	
    	//[VF][Partidas] Filtro campo: OTR_RES_Partidas__c
    	if(!String.isBlank(numeroPartidasMin)){
    		try{
    			Decimal.valueof(numeroPartidasMin);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El número de partidas introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_RES_Partidas__c',Comparacion__c='>=',Valor__c=''+numeroPartidasMin));
    		todoVacio = false;
    	}
    	
    	if(!String.isBlank(numeroPartidasMax)){
    		try{
    			Decimal.valueof(numeroPartidasMax);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El número de partidas introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_RES_Partidas__c',Comparacion__c='<=',Valor__c=''+numeroPartidasMax));
    		todoVacio = false;
    	}
    	
    	//[VF][Tipología de Servicio] Filtro campo: OTR_SEL_Tipologia_de_Servicio__c
    	if(tipologiaDeServicioSeleccionada != null && !tipologiaDeServicioSeleccionada.isEmpty()){
    		String comparacion = 'IN';
    		if(excluirTipologiaServicio)
    			comparacion = 'NOT IN';
    			
    		List<String> conjunto = new List<String>();
    		for(SelectOption so: tipologiaDeServicioSeleccionada)
    			conjunto.add(so.getValue());
    			
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_SEL_Tipologia_de_Servicio__c',Comparacion__c=comparacion,Valor__c=''+formatInFields(conjunto)));
    		todoVacio = false;
    	}
    	//[VF][Tipo de intervención] Filtro campo: OTR_FOR_Tipo_de_Caso__c
    	if(tipoIntervencionSeleccionada != null && !tipoIntervencionSeleccionada.isEmpty()){
    		String comparacion = 'IN';
    		if(excluirTipoIntervencion)
    			comparacion = 'NOT IN';
    			
    		List<String> conjunto = new List<String>();
    		for(SelectOption so: tipoIntervencionSeleccionada)
    			conjunto.add(so.getValue());
    			
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Tipo_de_Caso__c',Comparacion__c=comparacion,Valor__c=''+formatInFields(conjunto)));
    		todoVacio = false;
    	}
    	
    	//[VF][Confianza en la red] Filtro campo: OTR_CAS_Confianza_en_la_red__c
    	/*if(woNuevoFiltro.OTR_CAS_Confianza_en_la_red__c != null){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_CAS_Confianza_en_la_red__c',Comparacion__c='=',Valor__c=''+woNuevoFiltro.OTR_CAS_Confianza_en_la_red__c+''));
    		todoVacio = false;
    	}*/
    	if(!String.isBlank(filtroConfianzaRed)){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_CAS_Confianza_en_la_red__c',Comparacion__c='=',Valor__c=''+filtroConfianzaRed+''));
    		todoVacio = false;
    	}
    	
    	// [Importe prof antes de imp ] Filtro campo: OTR_RES_Liquidar_prof_AI__c
    	if(!String.isBlank(importeLiquidarProfMin)){
    		try{
    			Decimal.valueof(importeLiquidarProfMin);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El importe mínimo de profesional introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_RES_Liquidar_prof_AI__c',Comparacion__c='>=',Valor__c=''+double.valueOf(importeLiquidarProfMin)));
    		todoVacio = false;
    	}
    	// TO_REVIEW [Importe prof antes de imp ] Filtro campo: OTR_RES_Liquidar_prof_AI__c
    	if(!String.isBlank(importeLiquidarProfMax)){
    		try{
    			Decimal.valueof(importeLiquidarProfMax);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El importe máximo de profesional introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_RES_Liquidar_prof_AI__c',Comparacion__c='<=',Valor__c=''+double.valueOf(importeLiquidarProfMax)));
    		todoVacio = false;
    	}
    	
    	
    	//[Importe CIA antes de imp] Filtro campo: OTR_RES_Subtotal_Partidas__c
    	if(!String.isBlank(importeSubtotalPartidasMin)){
    		try{
    			Decimal.valueof(importeSubtotalPartidasMin);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El importe mínimo CIA introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_RES_Subtotal_Partidas__c',Comparacion__c='>=',Valor__c=''+double.valueOf(importeSubtotalPartidasMin)));
    		todoVacio = false;
    	}
    	//[Importe CIA antes de imp] Filtro campo: OTR_RES_Subtotal_Partidas__c
    	if(!String.isBlank(importeSubtotalPartidasMax)){
    		try{
    			Decimal.valueof(importeSubtotalPartidasMax);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El importe máximo CIA introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_RES_Subtotal_Partidas__c',Comparacion__c='<=',Valor__c=''+double.valueOf(importeSubtotalPartidasMax)));
    		todoVacio = false;
    	}
    	
    	//[Importe Total Intervención CIA Antes Imp] Filtro campo: OTR_FOR_Importe_CIA_Intervencion__c
    	if(!String.isBlank(importeCIAIntervencionMin)){
    		try{
    			Decimal.valueof(importeCIAIntervencionMin);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El importe mínimo intervención CIA introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Importe_CIA_Intervencion__c',Comparacion__c='>=',Valor__c=''+double.valueOf(importeCIAIntervencionMin)));
    		todoVacio = false;
    	}
    	
    	//[Importe Total Intervención CIA Antes Imp] Filtro campo: OTR_FOR_Importe_CIA_Intervencion__c
    	if(!String.isBlank(importeCIAIntervencionMax)){
    		try{
    			Decimal.valueof(importeCIAIntervencionMax);
    		} catch(exception e){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El importe máximo intervención CIA introducido no es correcto'));
    			return;
    		}
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Importe_CIA_Intervencion__c',Comparacion__c='<=',Valor__c=''+double.valueOf(importeCIAIntervencionMax)));
    		todoVacio = false;
    	}
    	
    	//[Código de baremo] Filtro campo: OTR_TXT_Codigo_de_baremo__c
    	if(!String.isBlank(filtroCodigoBaremo)){
    		List<String> codsBaremo = filtroCodigoBaremo.split(',');
    		codsBaremo.sort();
    		filtroCodigoBaremo = '';
    		for(String cod: codsBaremo)
    			filtroCodigoBaremo += (cod +',');
    		
    		filtroCodigoBaremo = filtroCodigoBaremo.removeEnd(',');
    		
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_TXT_Codigo_de_baremo__c',Comparacion__c='=',Valor__c='\''+filtroCodigoBaremo+'\''));
    	}
    	
    	//[Requiere perito ] Filtro campo: OTR_FOR_Siniestro_Peritado__c
    	/*if(woNuevoFiltro.OTR_FOR_Siniestro_Peritado__c != null){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Siniestro_Peritado__c',Comparacion__c='=',Valor__c=''+woNuevoFiltro.OTR_FOR_Siniestro_Peritado__c+''));
    		todoVacio = false;
    	}*/
    	if(!String.isBlank(filtroRequierePerito)){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Siniestro_Peritado__c',Comparacion__c='=',Valor__c=''+filtroRequierePerito+''));
    		todoVacio = false;
    	}
    	
    	//[Producto] Filtro campo: OTR_FOR_Producto__c
    	if(productoSeleccionado != null && !productoSeleccionado.isEmpty()){
    		String comparacion = 'IN';
    		if(excluirProducto)
    			comparacion = 'NOT IN';
    			
    		List<String> conjunto = new List<String>();
    		for(SelectOption so: productoSeleccionado)
    			conjunto.add(so.getValue());
    			
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_FOR_Producto__c',Comparacion__c=comparacion,Valor__c=''+formatInFields(conjunto)));
    		todoVacio = false;
    	}
    	
    	if(misServicios){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OwnerId',Comparacion__c='=',Valor__c='\''+UserInfo.getUserId()+'\''));
    		todoVacio = false;
    	}
    	
		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_CAS_Pendiente_de_Gestor__c',Comparacion__c='=',Valor__c=''+woNuevoFiltro.OTR_CAS_Pendiente_de_Gestor__c+''));
		
		if(!String.isBlank(woNuevoFiltro.OTR_SEL_AG_Motivo__c)){
			filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='OTR_SEL_AG_Motivo__c',Comparacion__c='=',Valor__c='\''+woNuevoFiltro.OTR_SEL_AG_Motivo__c+'\''));
    		todoVacio = false;
    	}
    	
    	if(rechazados){
    		filtrosNuevos.add(new Filtro_de_lista__c(Campo__c='Status',Comparacion__c='=',Valor__c='\''+LABEL.OTR_ESTADO_PDTE_AUDIT_GESTION+'\''));
    		todoVacio = false;
    	}
		
 	
    	if(guardar){
    		
    		if(todoVacio){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha rellenado ningún campo de filtro'));
    			return;
    		}
    		
    		if(String.isBlank(nombreVistaNueva)){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Debe rellenar un nombre para guardar la vista'));
    			return;
    		}
    		
    		nuevaVista.Name = nombreVistaNueva;
    		
    		if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION)
    			nuevaVista.Compartir_con__c = 'Supervisores de Auditoría';
    		else if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_AUDITORIA_GESTION)
    			nuevaVista.Compartir_con__c = 'Nadie';
    		
    		for(Vista_de_lista_personalizada__c vista: vistasMapa.values()){
    			if(vista.Name == nuevaVista.Name){
    				delete vista;
    				break;
    			}
    		}
    		
    		insert nuevaVista;
    		
    		for(Filtro_de_lista__c filtro: filtrosNuevos){
    			filtro.vista__c = nuevaVista.Id;
    		}
    		
    		insert filtrosNuevos;
    		
    		cargarVistasCustom();
    		
    		vistaSeleccionada = nuevaVista.Id;
    		
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Vista guardada correctamente'));
    	}
    	
    	
    	lastQuery = construirFiltro(nuevaVista,filtrosNuevos);
    	enPag = 0;
    	system.debug('-------query: '+ lastQuery);
    	controllerPropio = new ApexPages.StandardSetController(Database.query(lastQuery));
	    initController();
	    woSeleccionar = woTotal;
    }
    
    public void initController(){
    	system.debug('-----enPag:'+enPag);        	
    	if(controllerPropio != null){
	        controllerPropio.setPageSize(woPorPag);
	        
	        /*if(!String.isBlank(vistaSeleccionada))
	            controllerPropio.setFilterId(vistaSeleccionada);*/
	        for(Integer i=0; i<enPag;i++){
	        	system.debug('-----i:'+i);
	        	controllerPropio.next();
	        }
	        
	        registrosMostrar = (List<Workorder>)controllerPropio.getRecords();
	        woEnPag = registrosMostrar.size();
	        woTotal = controllerPropio.getResultSize();
	        numPag = Integer.valueOf(Math.ceil(Decimal.valueOf(woTotal)/woPorPag));
	        checkboxes = new Map<Id,Boolean>();
	        for(Workorder wo: registrosMostrar){
	        	checkboxes.put(wo.Id,false);
	        }
	        
	
	        haySig = controllerPropio.getHasNext();
	        hayPrev = controllerPropio.getHasPrevious();
	        masterCheckbox = false;
    	}
    }
    
    public void setSelected(){
    	
    	
    	
    	List<Workorder> woSeleccionadas = new List<Workorder>();
    	
    	if(masterCheckbox){
    		
    		woSeleccionadas = Database.query(lastQuery + ' LIMIT ' + woSeleccionar);
    		
    	} else {
    		system.debug(checkboxes);
	    	for(Workorder wo: registrosMostrar){
	    		system.debug(wo);
	    		system.debug(checkboxes.get(wo.Id));
	    		if(checkboxes.get(wo.Id)){
	    			woSeleccionadas.add(wo);
	    		}
	    	}
    	}
    	
    	
    	system.debug(woSeleccionadas);
    	/*for(Id woId: checkboxes.keySet()){
    		if(checkboxes.get(woId)){
    			woSeleccionadas.add(new Workorder(Id=woId));
    		}
    	}*/
    	
    	controller.setSelected(woSeleccionadas);
    	
    	controllerPropio = null;
    	registrosMostrar = new List<Workorder>();
    }
    
    public Pagereference cambioPropietario(){
    	
    	setSelected();
    	existeRedireccion = true;
    	PageReference pag = new PageReference('/apex/Cambiar_Propietario_Orden_Trabajo');
    	pag.getParameters().put('retURL', '/apex/OrdenTrabajoCustomList');
    	pag.getParameters().put('wrapMassAction', '1');
    	pag.getParameters().put('scontrolCaching','1');
    	pag.setRedirect(false);
    	
    	return pag;
    	
    }
    
    public Pagereference revisarAutomaticamente(){
    	
    	setSelected();
    	existeRedireccion = true;
    	PageReference pag = new PageReference('/apex/Cambiar_Estado_WorkOrder_al_pulsar_boton');
    	pag.getParameters().put('retURL', '/apex/OrdenTrabajoCustomList');
    	pag.getParameters().put('wrapMassAction', '1');
    	pag.getParameters().put('scontrolCaching','1');
    	pag.setRedirect(false);
    	
    	return pag;
    	
    }
    
    private void cargarVistasCustom(){
    	List<SelectOption> options = new List<SelectOption>();
    	
    	if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION){
    		vistasMapa = new Map<Id,Vista_de_lista_personalizada__c>([Select Id,Name,Tipo_de_objeto__c, (Select Id,Campo__c,Comparacion__c,Valor__c,Vista__c from Filtros__r) from Vista_de_lista_personalizada__c where Tipo_de_objeto__c like 'WorkOrder' and (Compartir_con__c = 'Supervisores de Auditoría' or OwnerId = :UserInfo.getUserId())]);
    	} else if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_AUDITORIA_GESTION){
    		vistasMapa = new Map<Id,Vista_de_lista_personalizada__c>([Select Id,Name,Tipo_de_objeto__c, (Select Id,Campo__c,Comparacion__c,Valor__c,Vista__c from Filtros__r) from Vista_de_lista_personalizada__c where Tipo_de_objeto__c like 'WorkOrder' and OwnerId = :UserInfo.getUserId()]);
    	} else {
    		vistasMapa = new Map<Id,Vista_de_lista_personalizada__c>([Select Id,Name,Tipo_de_objeto__c, (Select Id,Campo__c,Comparacion__c,Valor__c,Vista__c from Filtros__r) from Vista_de_lista_personalizada__c where Tipo_de_objeto__c like 'WorkOrder']);
    	}
    	
		options.add(new SelectOption('','--Ninguno--'));
		
		for(Vista_de_lista_personalizada__c vista: vistasMapa.values()){
			options.add(new SelectOption(vista.Id,vista.Name));
		}
		
		vistas = options;
    }
    
    private String construirFiltro(Vista_de_lista_personalizada__c vista, List<Filtro_de_lista__c> filtros){
    	
    	String query = 'Select '+ String.join(campos,', ') +' from '+vista.Tipo_de_objeto__c;
    	String linkClause = ' WHERE ';
    	
    	if(!filtros.IsEmpty()){
    		for(Filtro_de_lista__c filtro: filtros){
    			query += linkClause;
    			linkClause = ' AND ';
    			
    			if(filtro.Comparacion__c != 'not like'){
    				query += filtro.Campo__c + ' ' + filtro.Comparacion__c + ' ' + filtro.Valor__c;
    			} else {
    				query += '(Not ' + filtro.Campo__c + ' ' + filtro.Comparacion__c + ' ' + filtro.Valor__c +')';
    			}
    			
    		}
    	}
    	
    	//Añadimos filtros invisibles
    	
    		
    	query += linkclause + 'RecordtypeId  = \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA) + '\'';
    	query += ' AND Case.RecordtypeId  != \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION) + '\'';
    	
    	if(!rechazados)
    		query += ' AND Status = \'' + Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO + '\'';
    	
    	if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION && !misServicios){
    		query += ' AND OwnerId not In (SELECT ID from User where Profile.Name = \''+Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION+'\' OR Profile.Name = \''+ Label.PERFIL_GESTOR_AUDITORIA_GESTION +'\')';
    	} else if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_AUDITORIA_GESTION){
    		query += ' AND OwnerId = \''+UserInfo.getUserId()+'\'';
    	}
    	
    	system.debug('THE QUERY: '+query);
    	
    	return query;
    }
    
    public void borrarVista(){
    	
    	if(String.isBlank(vistaSeleccionada)) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha seleccionado vista'));
    	} else {
    		Vista_de_lista_personalizada__c vista = new Vista_de_lista_personalizada__c(Id=vistaSeleccionada);
    		delete vista;
    		vistaSeleccionada = '';
    		cargarVistasCustom();
    		limpiarFiltros();
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Vista eliminada correctamente'));
    	}
    	
    }
    
    public void seleccionarTodos(){
    	
    	//registrosMostrar = (List<Workorder>)controllerPropio.getRecords();
		//woEnPag = registrosMostrar.size();
    	
    	for(Id woId: checkboxes.keySet()){
    		checkboxes.put(woId,masterCheckbox);
    	}
    }
    
    /* FUNCIONES AUXILIARES PARA GENERACIÓN DE PICKLISTS */
    
    /* Obtiene una lista de selección donde aparecen los tipos de Registro Asociados a Caso
     *		[Valor en NuevoFiltro] OTR_FOR_Producto__c  
    */
   public List<selectOption> getPicklistNombreTipoProducto(){
   	
    	 List<SelectOption> tiposDeProductosCIA = new List<SelectOption>();
    	 
    	 List <Tipo_Producto_CIA__c> listaTipoProductosCIA ;
    	 
    	/*  if(companiaSeleccionada!=null){//Si se ha introducido compañía, devolvemos solamente los valores de picklist asociados a esa compañía
    	 	 listaTipoProductosCIA= Util_Compania.queryTipoDeProductosCIAByCIAId(new Set<Id>{companiaSeleccionada}).values();
    	  }
    	  else{*/
    	  	listaTipoProductosCIA= Util_Compania.queryAllTipoDeProductosCIA().values();
    	  //}
    	 
    	 tiposDeProductosCIA.add(new SelectOption('','--Ninguno--'));
    	 
	   for( Tipo_Producto_CIA__c  f : listaTipoProductosCIA)
	   {
	      tiposDeProductosCIA.add(new SelectOption(f.Name,f.Name));
	   }       
		 
    	 system.debug('ARL EXEC: getPicklistNombreTipoProducto'+ tiposDeProductosCIA);
    	 return tiposDeProductosCIA;
    }
    

    /* Obtiene una lista de selección donde aparecen los tipos de Registro Asociados a Caso
     *		[Valor en NuevoFiltro] OTR_FOR_Tipo_de_Caso__c  
    */
    public List<selectOption> getPicklistTipoIntervencion(){
    	 List<SelectOption> tiposDeCasos = new List<SelectOption>();
    	 tiposDeCasos.add(new SelectOption('','--Ninguno--'));
    	 
    	 Map<Id,RecordType> casoRT = Util_mapasTiposDeRegistro.getRecordTypeByType(new Set<String>{'Case'});
    	 if(!casoRT.isEmpty()){
    	 	for(RecordType rt: casoRT.values()){
    	 		if(rt.Name != 'Reclamación'){
    	 			tiposDeCasos.add(new SelectOption(rt.Name,rt.Name));
    	 		}
    	 	}
    	 }
    	 
    	 /* Schema.DescribeFieldResult fieldResult =
			 Case.Type.getDescribe();
			   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			   for( Schema.PicklistEntry f : ple)
			   {
			      tiposDeCasos.add(new SelectOption(f.getValue(),f.getLabel()));
			   }       
    	*/
    	 system.debug('ARL EXEC: getPicklistTipoIntervencion'+ tiposDeCasos);
    	 return tiposDeCasos;
    }
   
   /* Obtiene una lista de selección donde aparecen las Provincias que pueden seleccionarse
     *		[Valor en NuevoFiltro] OTR_FOR_DT__c  
    */
    public List<selectOption> getPicklistProvincias(){
    	 List<SelectOption> provincias = new List<SelectOption>();
    	 provincias.add(new SelectOption('','--Ninguna--'));
    	  Schema.DescribeFieldResult fieldResult =
			 Case.CAS_SEL_DirRiesgo_Estado_Provincia__c.getDescribe();
			   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			   for( Schema.PicklistEntry f : ple)
			   {
			      provincias.add(new SelectOption(f.getLabel(),f.getLabel()));
			   }       
    	
    	 system.debug('ARL EXEC: getPicklistProvincias'+ provincias);
    	 return provincias;
    }
   
 
    /* Obtiene una lista de selección donde aparecen las Direcciones Territoriales posibles
     *		[Valor en NuevoFiltro] OTR_FOR_DT__c  
    */
    public List<selectOption> getPicklistDireccionesTerritoriales(){
    	 List<SelectOption> direccionesTerritoriales = new List<SelectOption>();
    	 direccionesTerritoriales.add(new SelectOption('','--Ninguna--'));
    	  Schema.DescribeFieldResult fieldResult =
			 Case.CAS_SEL_Direccion_Territorial__c.getDescribe();
			   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			   for( Schema.PicklistEntry f : ple)
			   {
			      direccionesTerritoriales.add(new SelectOption(/*f.getLabel()*/f.getValue(),f.getValue()));
			   }       
    	
    	 system.debug('ARL EXEC: getPicklistDireccionesTerritoriales'+ direccionesTerritoriales);
    	 return direccionesTerritoriales;
    }
    
    /* Obtiene una lista de selección donde aparecen los nombres de todas las compañías que pueden seleccionarse, sin necesidad de buscar
   	 *			OTR_FOR_Compania__c
     */
    public List<selectOption> getPicklistCompanias(){
    	 List<SelectOption> companias = new List<SelectOption>();
    	 companias.add(new SelectOption('','--Ninguna--'));
    	 for( Account compania:Util_Compania.CIA_BY_IDSF.values()){
    	 	//companias.add(new SelectOption(compania.Id,compania.Name));
    	 	companias.add(new SelectOption(compania.Name,compania.Name));
    	 }
    	 system.debug('ARL EXEC: getPicklistCompanias'+ companias);
    	 return companias;
    }
    
    /* Obtiene una lista de selección donde aparecen los gremios posibles
     *		[Valor en NuevoFiltro] OTR_SEL_Gremio__c  
    */
    public List<selectOption> getPicklistGremios(){
    	 List<SelectOption> gremios = new List<SelectOption>();
    	 gremios.add(new SelectOption('','--Ninguno--'));
    	  Schema.DescribeFieldResult fieldResult =
			 WorkOrder.OTR_SEL_Gremio__c.getDescribe();
			   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			   for( Schema.PicklistEntry f : ple)
			   {
			      gremios.add(new SelectOption(/*f.getLabel()*/f.getValue(),f.getLabel()));
			   }       
    	
    	 system.debug('ARL EXEC: getPicklistGremios'+ gremios);
    	 return gremios;
    }
    
     /* Obtiene una lista de selección donde aparecen los tipos de servicio posibles para el filtro
     *		[Valor en NuevoFiltro] OTR_SEL_Tipologia_de_Servicio__c  
    */
    public List<selectOption> getPicklistTiposServicio(){
    	 List<SelectOption> tiposServicio = new List<SelectOption>();
    	 tiposServicio.add(new SelectOption('','--Ninguno--'));
    	  Schema.DescribeFieldResult fieldResult =
			 WorkOrder.OTR_SEL_Tipologia_de_Servicio__c.getDescribe();
			   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			   for( Schema.PicklistEntry f : ple)
			   {
			      tiposServicio.add(new SelectOption(/*f.getLabel()*/f.getValue(),f.getLabel()));
			   }       
    	
    	 system.debug('ARL EXEC: getPicklistTiposServicio'+ tiposServicio);
    	 return tiposServicio;
    }
    
    
    public static String formatInFields (List<String> lista){
    	List<String> listaFormateadaParaINClause = new List<String>();
    	
    	for(String s:lista){
    		listaFormateadaParaINClause.add('\''+s+'\'');
    	}
    	
    	return '('+String.join(listaFormateadaParaINClause,',')+')';
    	
    }
    
    
    //---------------------------------------
    //étodos para pendiente gestor
    //---------------------------------------
    
    public void pendienteGestor(){
    	esPendiente = true;
        numPageUpdate = 0;
		isOver = false;
		woUpdate = new Workorder();
		setSelected();
    }
    
    public void volverLista(){
    	esPendiente = false;
        numPageUpdate = 0;
		isOver = false;
		woUpdate = new Workorder();
		cargarRedireccion();
    }
    
    public void marcarPendiente(){

    	if(String.isBlank(woUpdate.OTR_SEL_AG_Motivo__c)){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El motivo no puede estar vacío'));
    		isOver = true;
    	} else {
    		isOver = false;
    		List<Workorder> selectedWorkOrders = (List<WorkOrder>) controller.getSelected();
			List<Workorder> selWoUpd = new List<Workorder>();
			
			system.debug('--------enUpdate: ' + numPageUpdate + ',' + selectedWorkOrders.size());
			
			//for(WorkOrder woSelec : selectedWorkOrders){
			for(Integer i = 1000*numPageUpdate; (i<1000*(numPageUpdate+1) && i<selectedWorkOrders.size());i++){
				Workorder woSelec = selectedWorkOrders[i];
				woSelec.OTR_SEL_AG_Motivo__c = woUpdate.OTR_SEL_AG_Motivo__c; 
				woSelec.OTR_CAS_Pendiente_de_Gestor__c = true;
				selWoUpd.add(woSelec);
			}
			
			if(1000*(numPageUpdate+1) > selectedWorkOrders.size()){
				isOver = true;
			}
			
			numPageUpdate++;
			
			system.debug('----------------'+numPageUpdate);
			system.debug('----------------'+isOver);
			
			
			try{
				
				Baipas.establecerVariableControl();
				update selWoUpd;
				Baipas.deshabilitarVariableControl();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Se ha marcado correctamente como pendiente de gestor.'));
			}catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				system.debug('****** EXCEPTION : ' + e);
				isOver = true;
			}
    	}
    }
    
    
    
}