/**
 * Clase controladora de la Visualforce "B2B_Gremios" encargada de agregar nuevos gremios a un Siniestro Reparable.
 * 
 * @author EVERIS
 */
public without sharing class B2B_Gremios {
	public Case caso {get; set;}
	public Boolean esB2C {get; set;}
	private String solicitudExistente;
	public String fase {get; set;}
	public String gremio {get; set;}
	public List<SelectOption> listaGremios {get; set;}
	public List<Resultado> listaResultados {get; set;}
	public Integer indiceResultado {get; set;}
	public WorkOrder ordenTrabajo {get; set;}
	public Comentario_Orden_de_Trabajo__c nuevoComentario {get; set;}
	public Boolean booleanUrgente {get; set;}
	public String tipoServicio {get; set;}
	public String gremioConf {get; set;}
	public Account cuenta {get; set;}
	public Procedencia__c procedencia {get; set;}
	public Boolean esReclamacion {get; set;}

	/**
	 * Constructor de la clase.
	 * 
	 * @param stdCtr: Controlador estándar de la visual
	 */ 
	public B2B_Gremios(ApexPages.standardController stdCtr){
		Id recordTypeIdReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
		solicitudExistente = 'N';
		esB2C = false;
		booleanUrgente = false;
		nuevoComentario = new Comentario_Orden_de_Trabajo__c();
		PageReference paginaActual = ApexPages.currentPage();
		system.debug('***** paginaActual.getParameters(). : ' + paginaActual.getParameters());
		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}
		if((!paginaActual.getParameters().containsKey('id')) && (!paginaActual.getParameters().containsKey('idCuenta'))){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else if(paginaActual.getParameters().containsKey('id')){
			solicitudExistente = 'Y';
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_B2B.queryCaso(stdCtr.getRecord().Id);
			if(!listaCasos.isEmpty()){
				caso = listaCasos.get(0);
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
				if(caso.CAS_LKP_Procedencia__c != null){
					List<Procedencia__c> listaProcedencias = Util_Procedencia.queryProcedencia(new Set<Id>{caso.CAS_LKP_Procedencia__c}).values();
					if(!listaProcedencias.isEmpty()){
						procedencia = listaProcedencias.get(0);
					}
					else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_PROCEDENCIA));
					}
					system.debug('>>>>>>>>>>>>Procedencia: ' + procedencia);
				}

				esB2C = caso.CAS_FOR_EsB2C__c;
				esReclamacion = (caso.RecordTypeId == recordTypeIdReclamacion);
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
		}
		else if(paginaActual.getParameters().containsKey('idCuenta')){
			cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{paginaActual.getParameters().get('idCuenta')}).get(paginaActual.getParameters().get('idCuenta'));
			if(cuenta != null){
				caso = new Case();
				caso.Status = Label.CAS_ESTADO_NUEVO;
				caso.AccountId = cuenta.Id;
				if(paginaActual.getParameters().containsKey('b2c')){
					caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
					if(paginaActual.getParameters().containsKey('idDireccion')){
						List<Direccion_Cuenta__c> listaDireccionesCuenta = Util_Cuentas.queryByDireccionId(new Set<Id>{paginaActual.getParameters().get('idDireccion')}).values();
						//List<Direccion_Cuenta__c> listaDireccionesCuenta = Util_Cuentas.queryDireccion(paginaActual.getParameters().get('idDireccion'), null);
						if(!listaDireccionesCuenta.isEmpty()){
							Direccion_Cuenta__c direcCuenta = listaDireccionesCuenta.get(0);
							caso.CAS_TXT_Direccion__c = direcCuenta.DCU_TXT_Direccion__c;
							caso.CAS_TXT_DirRiesgo_Poblacion__c = direcCuenta.DCU_TXT_Poblacion__c;
							caso.CAS_TXT_DirRiesgo_CP__c = direcCuenta.DCU_TXT_Codigo_Postal__c;
							caso.CAS_TXT_DirRiesgo_Pais__c = direcCuenta.DCU_SEL_Pais__c;
							caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = direcCuenta.DCU_SEL_Provincia__c;
						}
						else {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
						}
					}
					List<Procedencia__c> listaProcedencias = Util_Procedencia.getProcedenciaByAccountTiposCaso(new Set<Id>{cuenta.CUE_LKP_Cuenta_principal__c},Label.PROCEDENCIA_SERVICIO_B2C).values();
					//List<Procedencia__c> listaProcedencias = Util_Procedencia.getProcedenciaByAccountTiposCaso(new Set<Id>{cuenta.CUE_LKP_Cuenta_principal__c},Label.PROCEDENCIA_SERVICIO_B2C).values();
					//List<Procedencia__c> listaProcedencias = Util_Procedencia.queryProcedenciaPorCuenta(cuenta.CUE_LKP_Cuenta_principal__c,Label.PROCEDENCIA_SERVICIO_B2C);
					/*List<Procedencia__c> listaProcedencias  = new List<Procedencia__c>(
							[SELECT Id, PROC_SEL_Gremios_Disp__c FROM Procedencia__c
							 WHERE PROC_SEL_Tipos_Caso__c includes (:Label.PROCEDENCIA_SERVICIO_B2C) AND
							 PROC_LKP_Cuenta__c = :cuenta.CUE_LKP_Cuenta_principal__c]);*/
					if(!listaProcedencias.isEmpty()){
						procedencia = listaProcedencias.get(0);
					}
					else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_PROCEDENCIA));
					}
					system.debug('>>>>>>>>>>>>Procedencia B2C: ' + procedencia);
					esB2C = true;
				}
				else {
					caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
					caso.Type = Label.B2B_TIPO_CORRECTIVO;
					List<Procedencia__c> listaProcedencias = Util_Procedencia.getProcedenciaByAccountTiposCaso(new Set<Id>{cuenta.CUE_LKP_Cuenta_principal__c},Label.PROCEDENCIA_SERVICIO_B2B_B2B2C).values();
					//List<Procedencia__c> listaProcedencias = Util_Procedencia.getProcedenciaByAccountTiposCaso(new Set<Id>{cuenta.CUE_LKP_Cuenta_principal__c},Label.PROCEDENCIA_SERVICIO_B2B_B2B2C).values();
					//List<Procedencia__c> listaProcedencias  = Util_Procedencia.queryProcedenciaPorCuenta(cuenta.CUE_LKP_Cuenta_principal__c,Label.PROCEDENCIA_SERVICIO_B2B_B2B2C);
					/*List<Procedencia__c> listaProcedencias  = new List<Procedencia__c>(
							[SELECT Id, PROC_SEL_Gremios_Disp__c FROM Procedencia__c
							 WHERE PROC_SEL_Tipos_Caso__c includes (:Label.PROCEDENCIA_SERVICIO_B2B_B2B2C) AND
							 PROC_LKP_Cuenta__c = :cuenta.CUE_LKP_Cuenta_principal__c]);*/
					if(!listaProcedencias.isEmpty()){
						procedencia = listaProcedencias.get(0);
					}
					else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_PROCEDENCIA));
					}
					system.debug('>>>>>>>>>>>>Procedencia B2B: ' + procedencia);
					esB2C = false;
				}
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
		}

		if(paginaActual.getParameters().containsKey('solicitudExistente')){
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}

		String gremiosDisp = ''; 
		if(procedencia != null){
			gremiosDisp = ';' + procedencia.PROC_SEL_Gremios_Disp__c + ';';
		}
		system.debug('>>>>>ContinuaLaEjecucion');
		listaGremios = new List<SelectOption>();
		listaGremios.add(new SelectOption('', '--Ninguno--'));
		DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Case').getDescribe();
		DescribeFieldResult campoGremio = obj.fields.getMap().get('CAS_SEL_Sondeo_Gremios__c').getDescribe();
		List<Schema.PicklistEntry> listaPicklistGremios = campoGremio.getPicklistValues();
		String gremioValor = '';
		String gremioEtiqueta = '';		   
		for(Schema.PicklistEntry valorCampoGremio : listaPicklistGremios){
			gremioValor = valorCampoGremio.getValue();
			gremioEtiqueta = valorCampoGremio.getLabel();
			if(gremiosDisp.contains(';'  + gremioValor + ';')){
				listaGremios.add(new SelectOption(gremioValor, gremioEtiqueta));
			}
		}

		//Cargamos los metadatos de la cong general
		Configuracion_General__mdt confGeneral = Util_Metadatos.CONFIG_GENERAL.get('GremiosUrgentes');
		if(confGeneral != null && confGeneral.CF_TXT_Valor__c != null){
			gremioConf = ';' + confGeneral.CF_TXT_Valor__c + ';';
		}
		tipoServicio = Util_mapasTiposDeRegistro.RTNAMEBYID.get(caso.RecordTypeId);

		if(caso.CAS_LKP_Orden_Trabajo_Principal__c == null && caso.CAS_SEL_Gremio_Principal__c != null){
			gremio = caso.CAS_SEL_Gremio_Principal__c;
			buscarTiposTrabajo(); 
		}

		// Si el caso sigue asociado a una cola lo vinculamos al usuario actual
		if(caso.ownerID != null && ((String)caso.ownerID).startsWith('00G')){
			caso.ownerID = UserInfo.getUserId();
		}
	}

	/**
     * Método para cargar los Tipos de Trabajo en función del Gremio seleccionado
     */
	public void buscarTiposTrabajo(){
		listaResultados = new List<Resultado>();
		if(gremio != null){
			List<WorkType> listaTiposTrabajo = new List<WorkType>();
			if(procedencia != null){
				listaTiposTrabajo = Util_TipoTrabajo.getWorkTypeByProcedenciaAndGremioAndCategoria(new Set<Id>{procedencia.Id},new Set<String>{gremio},'02').values();
				//listaTiposTrabajo = Util_TipoTrabajo.queryTipoTrabajo('02',gremio,procedencia.Id);
				/*listaTiposTrabajo = new List<WorkType>(
						[SELECT Name
						 FROM WorkType
						 WHERE TDT_SEL_Categoria__c INCLUDES ('02')
						 AND TDT_SEL_Gremio__c = :gremio
						 AND Id IN (SELECT PRTT_LKP_TipoTrabajo__c 
								 FROM Procedencia_TipoTrabajo__c 
								 WHERE PRTT_LKP_Procedencia__c = :procedencia.Id)]);*/
			}
			if(listaTiposTrabajo.isEmpty()){
				listaTiposTrabajo = Util_TipoTrabajo.getWorkTypeByGremioAndCategoria(new Set<String>{gremio},'02').values();
				//listaTiposTrabajo = Util_TipoTrabajo.queryTipoTrabajo('02',gremio);
				/*listaTiposTrabajo = new List<WorkType>(
						[SELECT Name
						 FROM WorkType
						 WHERE TDT_SEL_Categoria__c INCLUDES ('02')
						 AND TDT_SEL_Gremio__c = :gremio]);*/
			}

			for(WorkType tipoTrabajo : listaTiposTrabajo){
				listaResultados.add(new Resultado(false, tipoTrabajo));
			}
		}
	}


	/**
     * Método para crear la Orden de Trabajo a partir del Gremio y del Tipo de Trabajo
     * 
     * 
     * @return true si ha sido creado e insertado correctamente
     */ 
	private Boolean crearODT(){
		Boolean creado = false;
		String labelGremio = gremio;
		WorkType tipoTrabajo;
		Id idTipoTrabajo = null;
		if(listaResultados != null){
			for(Resultado resultado : listaResultados){
				if(resultado.seleccionado){
					tipoTrabajo = resultado.tipoTrabajo;
					idTipoTrabajo = tipoTrabajo.Id;
					break;
				}
			}
		}
		if(idTipoTrabajo == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_SELEC_TIPO_TRABAJO));
		}
		else {
			ordenTrabajo = Util_Orden_Trabajo.crearOrdenDeTrabajo(caso, null, labelGremio, idTipoTrabajo, null, booleanUrgente);
			// Vincular automáticamente la Línea de Contrato Correctiva correspondiente
			// si el caso es un Servicio B2B/B2B2C Correctivo
			if(!esB2C && caso.Type == Label.B2B_TIPO_CORRECTIVO){
				List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaDirLCauto = Util_Direcciones_B2B_B2B2C_Lineas.getLCsCorrectDisponiblesPorSeleccionAutoAndPorSaldo(new Set<Id>{caso.AccountId},true,new Set<String>{Label.RT_LIN_CON_CORRECTIVO},new Set<String>{ordenTrabajo.OTR_SEL_Gremio__c},true,0).values();
				//List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaDirLCauto = Util_B2B.getLCsCorrectDisponibles(ordenTrabajo, caso.AccountId, true, false, true);
				if(!listaDirLCauto.isEmpty()){
					ordenTrabajo.OTR_LKP_Linea_Contrato__c = listaDirLCauto.get(0).DLC_LKP_Linea_de_Contrato__c;
				}
			}
			insert ordenTrabajo;
			// Si no existe Orden de Trabajo principal: la vinculamos y establecemos el gremio como principal
			if(caso.CAS_LKP_Orden_Trabajo_Principal__c == null){
				caso.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajo.Id;
				caso.CAS_SEL_Gremio_Principal__c = labelGremio;
				caso.CAS_LKP_Tipo_Trabajo__c = idTipoTrabajo;
				Baipas.establecerVariableControl();
				update caso;
				Baipas.deshabilitarVariableControl();
			}
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
		Case casoAux = caso.clone(true, true);
		PageReference paginaRedireccion = null;
		if(gremio == null || nuevoComentario.COT_TXT_Comentario__c == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
		}
		else if(validarCheckUrgente()){
			try {
				upsert caso;
				List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{caso.Id}).values();
				//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{caso.Id}).values();
				//List<Case> listaCasos = Util_B2B.queryCaso(caso.Id);
				if(!listaCasos.isEmpty()){
					caso = listaCasos.get(0);
				}
				if(crearODT()){
					insertarComentario(); 
					paginaRedireccion = continuar();
				}
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				caso = casoAux;
				system.debug('***** EXCEPTION e :' + e.getStackTraceString());
				//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			 	//}
	 		}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('***** ANTES ROLLBACK CASO : ' + caso);
				system.debug('***** ANTES ROLLBACK CASO  - CASOAUX: ' + casoAux);
				caso = casoAux;
				system.debug('***** DESPUES ROLLBACK CASO : ' + caso);
				system.debug('***** DESPUES ROLLBACK CASO  - CASOAUX: ' + casoAux);
				system.debug('***** EXCEPTION e :' + e.getStackTraceString());
				if(!e.getMessage().contains('[COT_TXT_Comentario__c]')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				}
			}
		}
		return paginaRedireccion;
	}//FIN guardar()

	/**
	 * Continua el proceso actual en la página
	 * 
	 * @return página a navegar tras continuar
	 */
	public PageReference continuar(){
		PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_REPARABLE);
		paginaRedireccion.getParameters().put('id', caso.Id);
		paginaRedireccion.getParameters().put('fase', fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
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
		if(gremioConf == null){
			gremioConf = '';
		}
		//Si se ha marcado el check de urgente de la visual
		if(booleanUrgente){
			//Compruebo si el gremio permite urgente
			if(gremio != null && gremioConf.contains(';'  + gremio + ';')){
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
	public class Resultado{
		public Boolean seleccionado {get; set;}
		public WorkType tipoTrabajo {get; set;}
		public Resultado(Boolean seleccionado, WorkType tipoTrabajo){
			this.seleccionado = seleccionado;
			this.tipoTrabajo = tipoTrabajo;
		}
	}

	/**
	 * Cancela el proceso de alta/modificación del cliente
	 * 
	 * @return paágina a la que navegar tras cancelar
	 */ 
	public PageReference cancelar(){
		// Por defecto regresamos a la Gestión de Gremios
		PageReference paginaRedireccion = continuar();
		// Si estamos abriendo un nuevo Servicio y no hemos seleccionado el gremio principal
		if(fase == Label.SINI_FASE_APERTURA && caso.CAS_LKP_Orden_Trabajo_Principal__c == null){
			// Si partimos de una solicitud previa
			if(solicitudExistente == 'Y'){
				// Regresamos al detalle de la solicitud
				paginaRedireccion = new PageReference('/' + caso.Id);
			}
			// Si no partimos de una solicitud previa
			else {
				// Eliminamos el caso generado
				if(caso.Id != null){
					delete caso;
				}
				// Navegamos al detalle de la cuenta
				paginaRedireccion = new PageReference('/' + cuenta.Id);
			}
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}
	
	public PageReference reabrirReclamacion(){
		if(String.isBlank(caso.CAS_SEL_Motivo_Reapertura__c)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MOTIVO_REAPERTURA));
		} else {
			caso.Status = Label.CAS_ESTADO_REAPERTURADO;
			caso.CAS_TXT_Gestor_Cierra_Reclamacion__c = '';
			update caso;
		}
		return null;
	}
}