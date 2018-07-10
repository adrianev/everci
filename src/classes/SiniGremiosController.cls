/**
 * Clase controladora de la Visualforce "SiniGremiosController" encargada de agregar nuevos gremios a un Siniestro Reparable.
 * 
 * @author EVERIS
 */
public without sharing class SiniGremiosController {
	public Case caso {get; set;}
	public String fase {get; set;}
	private String idTabBusqClientes;
	private String codigoVDN;
	public String gremio {get; set;}
	public List<SelectOption> listaGremios {get; set;}
	public List<Resultado> listaResultados {get; set;}
	public Integer indiceResultado {get; set;}
	public Boolean nuevoGremio {get; set;}
	public WorkOrder ordenTrabajo {get; set;}
	public Comentario_Orden_de_Trabajo__c nuevoComentario {get; set;}
	public Boolean booleanUrgente {get; set;}
	public String tipoActuacion {get; set;}
	public String gremioConf {get; set;}
	public Procedencia__c procedencia {get; set;}
	public Boolean gravesGremioUrg {get; set;}
	private String apexMessageError;
	public Boolean esSiniestro {get; set;} // Nº48 - 07_06_2018 / SMM
	public Map<String,Integer> mapaLimiteManitasPorGremio; // Nº49 - 07_06_2018 / MDVG
	public Boolean superaLimitePermitido {get; set;}
	public Boolean superaLimiteGlobal {get; set;}
	private String idConfirmacion{get;set;}
	private String numeroGremiosArbolSalida{get;set;}
	/**
	 * Constructor de la clase.
	 * 
	 * @param stdCtr: Controlador estándar de la visual
	 */ 
	public SiniGremiosController(ApexPages.standardController stdCtr){
		booleanUrgente = false;
		superaLimitePermitido = false;
		nuevoComentario = new Comentario_Orden_de_Trabajo__c();
		PageReference paginaActual = ApexPages.currentPage();
		system.debug('***** paginaActual.getParameters(). : ' + paginaActual.getParameters());
		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}
		if(paginaActual.getParameters().containsKey('VDN')){
			codigoVDN = paginaActual.getParameters().get('VDN');
		}
		if(paginaActual.getParameters().containsKey('idTabBusqClientes')){
			idTabBusqClientes = paginaActual.getParameters().get('idTabBusqClientes');
		}
		if(paginaActual.getParameters().containsKey('idConfirmacion')) {
			idConfirmacion = paginaActual.getParameters().get('idConfirmacion');
		}
		if(paginaActual.getParameters().containsKey('numeroGremiosArbolSalida')) {
			numeroGremiosArbolSalida=paginaActual.getParameters().get('numeroGremiosArbolSalida');
		}
		gravesGremioUrg = (paginaActual.getParameters().containsKey('gravesGremioUrg'));

		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_Caso.queryMapSiniCaso(new Set<Id>{stdCtr.getRecord().Id},null,1).values();
			//List<Case> listaCasos = Util_Siniestro.queryCaso(stdCtr.getRecord().Id, null, 1);
			if(!listaCasos.isEmpty()){
				caso = listaCasos.get(0);
				esSiniestro = Util_Siniestro.esSiniestro(caso); // Nº48 - 06_06_2018 / SMM
				tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
				if(caso.CAS_LKP_Procedencia__c == null){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_PROCEDENCIA));
				}

				//Cargamos los metadatos de la cong general
			  	Configuracion_General__mdt confGeneral = Util_Metadatos.CONFIG_GENERAL.get('GremiosUrgentes');
				if(confGeneral != null && confGeneral.CF_TXT_Valor__c != null){
					gremioConf = ';'  + confGeneral.CF_TXT_Valor__c + ';';
				}

				//Compruebo si es un siniestro grave, si tiene el check de siniestro grave marcado, 
				//solo se muestra la opcion en la picklist de siniestro grave
				listaGremios = new List<SelectOption>();
				listaGremios.add(new SelectOption('', '--Ninguno--'));
				DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Case').getDescribe();
				DescribeFieldResult campoGremio = obj.fields.getMap().get('CAS_SEL_Sondeo_Gremios__c').getDescribe();

				List<WorkOrder> listaOTs = Util_Orden_Trabajo.getWorkOrderByCaseAndNotInStatus(new Set<Id>{caso.Id},new Set<String>{Label.OTR_ESTADO_CERRADO,Label.OTR_ESTADO_ANULADO,Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO}).values();
				//List<WorkOrder> listaOTs = Util_Orden_Trabajo.queryOT(null, caso.Id, 'Status != \'' + Label.OTR_ESTADO_CERRADO + '\' AND Status != \'' + Label.OTR_ESTADO_ANULADO + '\' AND Status != \'' + Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO + '\'');
				Map<String, Id> listaGremiosOT = new Map<String, Id>();
				for (WorkOrder grem : listaOTs){
					listaGremiosOT.put(grem.OTR_SEL_Gremio__c, grem.Id);
				}

				String gremiosDisp = ''; 
				if(caso.CAS_LKP_Procedencia__c != null && caso.CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c != null){
					gremiosDisp = ';' + caso.CAS_LKP_Procedencia__r.PROC_SEL_Gremios_Disp__c + ';';
				}
				List<Schema.PicklistEntry> listaPicklistGremios = campoGremio.getPicklistValues();
				List<String> listaGremiosSugeridos = new List<String>();
				String gremioValor = '';
				String gremioEtiqueta = '';
				system.debug('SiniGremiosController : Constructor : gravesGremioUrg : '+gravesGremioUrg+' : '+((!gravesGremioUrg) ? 'Cumple' : 'NO cumple')+' la condición');
				system.debug('SiniGremiosController : Constructor : fase : '+fase+' : '+((fase != null) ? 'Cumple' : 'NO cumple')+' la condición');
				system.debug('SiniGremiosController : Constructor : caso.CAS_SEL_Sondeo_Gremios__c : '+caso.CAS_SEL_Sondeo_Gremios__c+' : '+((caso.CAS_SEL_Sondeo_Gremios__c != null) ? 'Cumple' : 'NO cumple')+' la condición');
				if(!gravesGremioUrg && fase != null && caso.CAS_SEL_Sondeo_Gremios__c != null){
					system.debug('SiniGremiosController : Constructor : Pasa dentro del IF');
					for (Schema.PicklistEntry valorCampoGremio : listaPicklistGremios){
						gremioValor = valorCampoGremio.getValue();
						gremioEtiqueta = valorCampoGremio.getLabel();
						Boolean agregarGremio = (
								(gremioValor != Label.SINI_GREMIO_GRAVES) &&
								(caso.CAS_SEL_Sondeo_Gremios__c.contains(gremioValor)) &&
								((fase != Label.SINI_FASE_CONFIRMACION) ||
										(fase == Label.SINI_FASE_CONFIRMACION && (!listaGremiosOT.containsKey(gremioValor)))));
						String grupoGremios = 'Sugeridos del sondeo_';
						if(agregarGremio){
							// Nº49 - 06 Junio 2018 / MDVG
							listaGremiosSugeridos.add(gremioValor);
							// FIN Nº49
							listaGremios.add(new SelectOption(grupoGremios + gremioValor, gremioEtiqueta));
						}
					}
				}
				if(caso.Type != Label.CAS_TIPO_MANITAS && caso.Type != Label.CAS_TIPO_SERVICIO_ESPECIAL_REP && caso.Type != Label.CAS_TIPO_SERVICIO_ESPECIAL_IND){
					if(fase != Label.SINI_FASE_CONFIRMACION){
						for (Schema.PicklistEntry valorCampoGremio : listaPicklistGremios){
							gremioValor = valorCampoGremio.getValue();
							gremioEtiqueta = valorCampoGremio.getLabel();
							Boolean agregarGremio = (
									(gremioValor != Label.SINI_GREMIO_GRAVES) &&
									(gremiosDisp.contains(';'  + gremioValor + ';')) && (
											(gravesGremioUrg && gremioConf.contains(';'  + gremioValor + ';')) ||
											(!gravesGremioUrg && fase != Label.SINI_FASE_APERTURA) ||
											(!gravesGremioUrg && fase == Label.SINI_FASE_APERTURA && (caso.CAS_SEL_Sondeo_Gremios__c == null || (!caso.CAS_SEL_Sondeo_Gremios__c.contains(gremioValor))))));
							String grupoGremios = 'Resto de gremios_';
							if(fase != Label.SINI_FASE_APERTURA || gravesGremioUrg){
								grupoGremios = 'Todos los gremios_';
							}
							if(agregarGremio){
								listaGremios.add(new SelectOption(grupoGremios + gremioValor, gremioEtiqueta));
							}
						}
					}
				}
				
				// Nº49 - 06 Junio 2018 / MDVG
				mapaLimiteManitasPorGremio = new Map<String, Integer>();
				if(caso.Type == Label.CAS_TIPO_MANITAS){
					//Metemos en un set los gremios de la lista de sugeridos
					Set<String> setGremios = new Set<String>();
					if(listaGremiosSugeridos != null && !listaGremiosSugeridos.isEmpty()){
						setGremios.addAll(listaGremiosSugeridos);
					}
					//Nos traemos un mapa con los gremios sugeridos y el límite de servicios permitidos para cada uno de ellos
					mapaLimiteManitasPorGremio = Util_Siniestro.getMapaLimiteManitasPorGremio(caso,setGremios);
				}// FIN Nº49
				
				// Nº49 - 25 Junio 2018 / MDVG
				//Si se superas el límite global de siniestro de tipo manitas, en el propio constructor de la vf debe saltar un aviso
				system.debug('SiniGremiosController : Constructor : caso.Type : '+caso.Type+' : '+((caso.Type == Label.CAS_TIPO_MANITAS) ? 'Cumple' : 'NO cumple')+' la condición');
				system.debug('SiniGremiosController : Constructor : Util_Siniestro.verificarLimiteManitas(caso) : '+Util_Siniestro.verificarLimiteManitas(caso)+' : '+((Util_Siniestro.verificarLimiteManitas(caso)) ? ' Cumple' : ' NO cumple')+' la condición');
				superaLimiteGlobal = (caso.Type == Label.CAS_TIPO_MANITAS && Util_Siniestro.verificarLimiteManitas(caso));
				system.debug('SiniGremiosController : Constructor : superaLimiteGlobal : '+superaLimiteGlobal);

				system.debug('[amc]supera limite' + superaLimiteGlobal);
				if(superaLimiteGlobal){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, label.ERROR_SIN_LIMITE_MANITAS));
					superaLimitePermitido = true;
				}// FIN Nº49

				nuevoGremio = true;
				booleanUrgente = gravesGremioUrg;
			}
		}
	}

	/**
     * Método para cargar los Tipos de Trabajo en función del Gremio seleccionado
     */
	public void buscarTiposTrabajo(){
		listaResultados = new List<Resultado>();
		Boolean superaLimitePorGremio = false;
		if(gremio != null){
			// Nº49 - 07 Junio 2018 / MDVG // 25 Junio 2018
			//Comprobamos que supera el límite permitido por gremio
			if(caso.Type == Label.CAS_TIPO_MANITAS && mapaLimiteManitasPorGremio.get(gremio.right(2)) != null){
				superaLimitePorGremio = Util_Siniestro.verificarLimiteManitasGremio(caso,gremio.right(2),mapaLimiteManitasPorGremio.get(gremio.right(2)));
			}
			//Si el siniestro es de tipo manitas y se supera el límite de servicios permitidos para el gremio en concreto, salta un warning
			if(superaLimitePorGremio){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_SIN_LIMITE_MANITAS_GREMIO));
				superaLimitePermitido = true;
			}
			//Si no supera el límite permitido por gremio, se pone a false el booleano "superaLimitePermitido" (siempre y cuando no se supere el límite global), para permitir navegar a siniReparable 
			else{
				if(!superaLimiteGlobal){
					superaLimitePermitido = false;
				}				
			}
			List<WorkType> listaTiposTrabajo = Util_TipoTrabajo.getWorkTypeByGremioAndCategoria(new Set<String> {gremio.split('_').get(1)}, '01').values();
			for(WorkType tipoTrabajo : listaTiposTrabajo){
				listaResultados.add(new Resultado(false, tipoTrabajo));
			}
		}// FIN Nº49
	}


	/**
     * Método para crear la Orden de Trabajo a partir del Gremio y del Tipo de Trabajo
     * 
     * 
     * @return true si ha sido creado e insertado correctamente
     */ 
	private Boolean crearODT(){
		Boolean creado = false;
		String labelGremio = gremio.split('_').get(1);
		WorkType tipoTrabajo;
		Id idTipoTrabajo = null;
		for(Resultado resultado : listaResultados){
			if(resultado.seleccionado){
				tipoTrabajo = resultado.tipoTrabajo;
				idTipoTrabajo = tipoTrabajo.Id;
				break;
			}
		}
		if(!listaResultados.isEmpty() && idTipoTrabajo == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_SELEC_TIPO_TRABAJO));
		}
		else {
			ordenTrabajo = Util_Orden_Trabajo.crearOrdenDeTrabajo(caso, null, labelGremio, idTipoTrabajo, null, booleanUrgente);
			insert ordenTrabajo;
			system.debug('SiniGremiosController : crearODT : ¿Se establece gremio principal?');
			//Si no existe Orden de Trabajo principal: la vinculamos y establecemos el gremio como principal
			if(fase == Label.SINI_FASE_APERTURA){
				// Nº32 En la reapertura no se debe cambiar el gremio de cabecera actual - 04_07_2018 - SMM
				if(caso.Status != Label.CAS_ESTADO_REAPERTURADO){
					system.debug('SiniGremiosController : crearODT : Se establece gremio principal');
					caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
					caso.CAS_SEL_Gremio_Principal__c = labelGremio;
					caso.CAS_LKP_Tipo_Trabajo__c = idTipoTrabajo;
				}
				// FIN Nº32
			}
			update caso;
			creado = true;
		}
		return creado;
	}

	/**
	 * Guarda el proceso actual en la página
	 * 
	 * @return página a navegar tras guardar el registro
	 */
	public PageReference guardar(){
		system.Savepoint puntoGuardado = Database.setSavepoint();
		PageReference paginaRedireccion = null;
		if(gremio == null || nuevoComentario.COT_TXT_Comentario__c == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
		}
		else if(validarCheckUrgente()){
			try {
				if(crearODT()){
					insertarComentario(); 
					nuevoGremio = false;
					continuar_paso1();
					paginaRedireccion = continuar_paso2();
				}
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug('***** EXCEPTION e :' + e.getStackTraceString());
		   		if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					if(!ApexPages.hasMessages()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
					}
				}
	 		}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug(e.getStackTraceString());
				if(!ApexPages.hasMessages()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
				}
			}
		}
		return paginaRedireccion;
	}//FIN guardar()

	/**
	 * Realiza una serie de comprobaciones antes de continuar con la apertura/tramitación del siniestro.
	 * A continuación de este método se ejecuta el continuar_paso2
	 *
	 */
	public void continuar_paso1(){
		if (superaLimitePermitido){
			try {
				caso.Type = Label.CAS_TIPO_NOABIERTO;
				caso.Status = Label.CAS_ESTADO_CERRADO;
				caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_SINIESTRO);
				caso.CAS_SEL_Motivo_No_Apertura__c = Label.SINI_MOTIVO_SUPERA_LIMITE;
				update caso;
			}catch(DmlException e){
				system.debug(e.getStackTraceString());
		   		if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar el caso. ' + e.getMessage()));
				}
 			}
		}
	}

	/**
	 * Continua el proceso actual en la página
	 * 
	 * @return página a navegar tras continuar
	 */
	public PageReference continuar_paso2(){
		PageReference paginaRedireccion = null;
		if(fase != null){
			if(superaLimitePermitido){
				paginaRedireccion = new PageReference('/' + caso.Id);
			}
			else{
				if('APERTURA'.equalsIgnoreCase(fase)) {
					paginaRedireccion = Page.SiniReparableApertura;
					paginaRedireccion.getParameters().put('id', caso.Id);
				} else {
					paginaRedireccion=Page.SiniReparableConfirmacion;
					paginaRedireccion.getParameters().put('id', caso.Id);
					paginaRedireccion.getParameters().put('fase', fase);
					if(idTabBusqClientes != null){
						paginaRedireccion.getParameters().put('idTabBusqClientes', idTabBusqClientes);
					}
					if(!String.isEmpty('idConfirmacion')) {
						 paginaRedireccion.getParameters().put('idConfirmacion',idConfirmacion);
					}
					if(!String.isEmpty(String.valueOf(numeroGremiosArbolSalida))) {
						paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',String.valueOf(numeroGremiosArbolSalida));
					}
				}
			}// FIN Nº49
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	/**
	 * Inserta un nuevo comentario en el Obejto Comentario_Orden_de_Trabajo__c
	 */
	private void insertarComentario(){
		if(nuevoComentario.COT_TXT_Comentario__c != null){
			Comentario_Orden_de_Trabajo__c comentarioInsertar = Util_Orden_Trabajo.crearComentarioOrdenTrabajo(ordenTrabajo.Id, nuevoComentario.COT_TXT_Comentario__c);
			if(comentarioInsertar != null){
				insert comentarioInsertar;
			}
		}
	}

	/**
	 * Valida si el gremio permite urgente
	 * 
     * @return true si el gremio permite urgente, si no devuelve false
     */
	public Boolean validarCheckUrgente(){
		Boolean varReturn = true;
		//Si se ha marcado el check de urgente de la visual
		if(booleanUrgente && (!gravesGremioUrg)){
			//Compruebo si el gremio permite urgente
			if(gremio != null && gremioConf.contains(';'  + gremio.split('_').get(1) + ';')){
				varReturn = true;
			}
			else {
				booleanUrgente = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.INFO_GREMIO_NO_URGENTE));
				varReturn = false;
			}
		}
		return varReturn;
	}

	/**
	 * Clase encargada de almacenar los tipos de trabajo seleccionados
	 */ 
	public without sharing class Resultado{
		public Boolean seleccionado {get; set;}
		public WorkType tipoTrabajo {get; set;}
		public Resultado(Boolean seleccionado, WorkType tipoTrabajo){
			this.seleccionado = seleccionado;
			this.tipoTrabajo = tipoTrabajo;
		}
	}

	public void salir_paso1(){
		apexMessageError = null;
		if(fase == Label.SINI_FASE_APERTURA){
			try	{
				Util_Siniestro.cancelarAperturaSiniestro(caso);
			}
			catch(DmlException e){
				system.debug(e.getStackTraceString());
		   		if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
				}
	 		}
			catch(Exception e){
				apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
				system.debug(e.getStackTraceString());
			}
		}
	}

	public PageReference salir_paso2(){
		PageReference paginaRedireccion = null;
		system.debug('siniGremio - salir paso2');
		Callout_ActualizaSiniestroVesta.Resultado resultadoUpdVesta;
		system.debug('siniGremio - salir paso2 act');
		if(apexMessageError != null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, apexMessageError));
		}
		else {
			// Si se cancela una vez iniciado el proceso de apertura: establecemos la Solicitud de Siniestro como "No Abierta"
			if(fase == Label.SINI_FASE_APERTURA){
				try {
					if(caso.CAS_NUM_Id_Actuacion_SondeoExt__c != null){
						resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c), 7, null, Label.SINI_COMENTARIO_CANCELACION,
								null, null, null, null, null, null);
						if(resultadoUpdVesta.codigo_error != null && resultadoUpdVesta.codigo_error != '0'){
							throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
						}
					}
					paginaRedireccion = new PageReference('/' + caso.CAS_LKP_PolizaContrato__c);
					if(idTabBusqClientes!= null){
						//Si hemos llegado desde la pantalla de Búsqueda: regresamos a la pantalla de Búsqueda
						//Se pasa por URL lo necesario para ir a la busqueda de asegurados
						paginaRedireccion = new PageReference('/apex/' + label.VF_BUSQ_CLIENTES);
						paginaRedireccion.getParameters().put('sfdc.tabName', idTabBusqClientes);
						paginaRedireccion.getParameters().put('VDN', codigoVDN);
					}
					paginaRedireccion.setRedirect(true);
				}
				catch(DmlException e){
					system.debug(e.getStackTraceString());
			   		if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
					}
	 			}
				catch(Exception e){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
					system.debug(e.getStackTraceString());
				}
			}
			else {
				paginaRedireccion = new PageReference('/' + caso.Id);
				paginaRedireccion.setRedirect(true);
			}
		}
		return paginaRedireccion;
	}

	// Nº48 - 07_06_2018 / SMM
	/**
	 * Reabre la intervención registrando los motivos de reapertura por compañía.
	 *
	 * @return página a navegar tras guardar el registro
	 */
	public PageReference reabrirIntervencion(){
		PageReference paginaRedireccion = null;
		// -- En la pantalla de Sini_Gremios cuando se está abriendo una OT estando cerrado el caso, debe obligar a registrar los motivos de reapertura específicos de cada Compañía:
		caso.CAS_SEL_Motivo_Reapertura__c = caso.CAS_LKP_Compania__r.CUE_SEL_Motivo_Reapertura__c;
		if(String.isBlank(caso.CAS_SEL_Motivo_Reapertura__c)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MOTIVO_REAPERTURA));
		} else {
			system.debug('ControlAccionesController : navegacionControlAccion : else');
			caso.Status = Label.CAS_ESTADO_REAPERTURADO;
			// -- Si el Siniestro tuviese marcados los check de Facturado y/o Liquidado, se desmarcan, ya que se tiene que volver a facturar y/o liquidar:
			if(caso.CAS_CAS_Siniestro_Facturado__c || caso.CAS_CAS_Liquidado__c){
				caso.CAS_CAS_Siniestro_Facturado__c = false;
				caso.CAS_CAS_Liquidado__c = false;
			}
			try{
				update caso;
			}
			catch(Exception e){
				system.debug('ControlAccionesController : navegacionControlAccion : caso : '+caso);
				system.debug('ControlAccionesController : navegacionControlAccion : try update caso : e.getMessage() : '+e.getMessage());
			}
		}
		system.debug('SiniGremiosController : reabrirIntervencion : [Antes de guardar()] : caso.Status : '+caso.Status);
		paginaRedireccion = guardar();
		system.debug('SiniGremiosController : reabrirIntervencion : [Después de guardar()] : caso.Status : '+caso.Status);
		system.debug('SiniGremiosController : reabrirIntervencion : paginaRedireccion : '+paginaRedireccion);
		return paginaRedireccion;
	}
	// FIN Nº48
}