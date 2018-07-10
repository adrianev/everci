public class SiniSondeoConfirmacionController {
    public Confirmacion__c confirmacionEditable{get;set;}
    public Confirmacion__c confirmacionGestor{get;set;}
    public Confirmacion__c confirmacionProfesional{get;set;}
    public Confirmacion__c confirmacionCopiaOriginal{get;set;}
    private List<Confirmacion__c> listaConfirmacionesToUpsert{get;set;}
	private List<Confirmacion__c> listConfirmacionesToDelete{get;set;}
    public Case intervencion{get;set;}
    private Set<String> setGarantiasPoliza{get;set;}
    //Grupos de Causa. 
    public List<SelectOption> listaGrupoCausas{get;set;}
    public String grupoCausas {get; set;}
    public String grupoCausasLabel {get; set;}
    //Tipo de Avería.
    public List<SelectOption> listaTipoAveria{get;set;}
    public String tipoAveria {get; set;}
    private Set<Id> setIdsArbolDecisionLineaTipoAveria;
    //Detalle Avería.
    
    public String detalleAveria {get; set;}
    public List<SelectOption> listaDetalleAveria {get; set;}
    
    private Set<Id> setIdsArbolDecisionLineaDetalleAveria;
    //Causas de la avería.
    public String causaAveria {get; set;}
    public List<SelectOption> listaCausaAveria {get; set;}
    
    //Perjudicado.
    public Boolean existenDanosPerjudicado{get;set;}
    public Boolean creacionPerjudicado{get;set;}
    public Boolean edicionPerjudicado{get;set;}
    private Set<Id> setIdsArbolDecisionLineaDanosPerjudicado;
    public Perjudicado_Siniestro__c nuevoPerjudicado {get; set;}
    public String situacionDanosPerjudicado {get; set;}
	public List<SelectOption> listaSituacionDanosPerjudicado {get; set;}
    public String otrosDanosPerjudicado {get; set;}
    public List<SelectOption> listaOtrosDanosPerjudicado{get;set;}
    public Integer indiceListaPerjudicados {get; set;}
    public List<Perjudicado_Siniestro__c> listaPerjudicados {get; set;}
    //Danos Propios
    public Boolean existenDanosPropios{get;set;}
    public String situacionDanosPropios {get; set;}
	public List<SelectOption> listaSituacionDanosPropios {get; set;}
    public String otrosDanosPropios {get; set;}
	public List<SelectOption> listaOtrosDanosPropios {get; set;}
    private Set<Id> setIdsArbolDecisionLineaDanosPropios;
    //Tercero causante.
    public Boolean terceroCausante {get; set;}
    
    //Ver Secciones   
    public Boolean verSeccionAveria{get;set;}
    //Árbol decisión de Líneas
    public Arbol_Decision_Lineas__c arbolDecisionLineasAuxiliar {get; set;}
    private Set<Id> setIdsArbolDecisionLineasGeneral{get;set;}
    private Set<Id> setIdsArbolDecisionLineasGrupoCausas{get;set;}
    private Set<Id> setIdsArbolDecisionLineasTipoAveria{get;set;}
    public Arbol_Decision_Lineas__c lineaSalida {get; set;}
    //Ayudas.
    public String textoAyuda {get; set;}
    public String textoAyudaGrupoCausa {get; set;}
	public String textoAyudaTipoAveria {get; set;}
	public String textoAyudaDetalleAveria {get; set;}
	public String textoAyudaCausaAveria {get; set;}
	public String textoAyudaDanosPropios {get; set;}
	public String textoAyudaDanosPerjudicados {get; set;}
    //Poblaciones 
    public List<SelectOption> listaPoblacionesCausante {get; set;}
	public List<SelectOption> listaPoblacionesPerjudicado {get; set;}
    public String poblacionPerjudicado {get; set;}
	public String poblacionCausante {get; set;}
    //Salida tipo de Actuación.
    public List<SelectOption> salidaTipoActuacion {get; set;}
    public Boolean tipoActuacionMultiple {get; set;}
    //Mensaje Error.
    private String apexMessageError;
    private String mensajeInicial;
	private String mensajeErrorSalida;
    private PageReference paginaNavegarContinuar;
	private Boolean errorMostradoMensajeSalidaMostrado;
	private Map<String,RecordType> mapRecordTypes{get;set;}
	// 
	public Map<String,Boolean> mapSeleccionDanosPropios{get;set;}
	public Map<String, boolean> mapSeleccionOtrosDanos{get;set;}
	//ver Secciones
	public Boolean verTipoAveria{get;set;}
	public Boolean verDetalleAveria{get;set;}
	public Boolean verCausaAveria{get;set;}
	public Boolean verSeccionDanos{get;set;}
	public Boolean verSeccionDanosPropios{get;set;}
	public Boolean verSeccionDanosPerjudicado{get;set;}
	public Boolean verSeccionTerceroCausante{get;set;}

	public Integer numeroDeColumnas{get;set;}

	private Integer numeroGremiosSalida;
	public List<SelectOption> listaSalidasObtenidas{get;set;}
	public String salidaSeleccionada{get;set;}
	public Boolean verSeccionSalidasObtenidas{get;set;}
	public List<WorkOrder> listaWorkOderToUpsert{get;set;}
	public List<Garantia__c> listaGarantiasObtenidasLinea{get;set;}

      public SiniSondeoConfirmacionController(ApexPages.StandardController standarController) {
        //1º Iniciar variables.
        iniciarVariables();

        //2ª recupero la intervención completa.
        for(Case casoAux: Util_Caso.getCaseById(new Set<Id>{standarController.getRecord().Id}).values()) {
            intervencion=casoAux;
        }

		Confirmacion__c confirmacionApertura=new Confirmacion__c();
		//Si el siniestro está confirmado, no permito hacer nada. 
		if(intervencion.CAS_CAS_Confirmado__c) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Este siniestro ya ha sido confirmado'));	
		} else {
			//3º Crear/Actualizar la lista de confirmaciones, en función del perfil.
			listaConfirmacionesToUpsert=queryConfirmacionesExistentes();
			if(listaConfirmacionesToUpsert.isEmpty()) {
														   
																		
				listaConfirmacionesToUpsert=createConfirmacionesCopia();
			} else {
				//Existen Confirmaciones, si existe solo una, es el caso de que el gestor ha recuperado la confirmacion con RT_Copia original.
				//Tiene que crear su copia.
				if(listaConfirmacionesToUpsert.size()==1) {
					listaConfirmacionesToUpsert.add(newConfirmacion('',mapRecordTypes.get(Label.RT_CNF_Gestor).Id, Label.CNF_ESTADO_EN_CURSO_GESTOR)); 
				} else if(listaConfirmacionesToUpsert.size()==2) {
					//Confirmacion__c confAux=new Confirmacion__c();
					Confirmacion__c confAux=null;
					for(Confirmacion__c confirmacionAux:listaConfirmacionesToUpsert) {
						if(mapRecordTypes.get(Label.RT_CNF_Profesional).Id==confirmacionAux.recordTypeId) {
							confAux=newConfirmacion('',mapRecordTypes.get(Label.RT_CNF_Gestor).Id, Label.CNF_ESTADO_EN_CURSO_GESTOR);
							confAux.CNF_CAS_Danos_Perjudicado__c=confirmacionAux.CNF_CAS_Danos_Perjudicado__c;
							confAux.CNF_SEL_Grupo_Causa__c=confirmacionAux.CNF_SEL_Grupo_Causa__c;
							confAux.CNF_SEL_Tipo_Averia__c=confirmacionAux.CNF_SEL_Tipo_Averia__c;
							confAux.CNF_SEL_Detalle_averia__c=confirmacionAux.CNF_SEL_Detalle_averia__c;
							confAux.CNF_SEL_Causa_Averia__c=confirmacionAux.CNF_SEL_Causa_Averia__c;
							confAux.CNF_SEL_Otros_Danos__c=confirmacionAux.CNF_SEL_Otros_Danos__c;
							confAux.CNF_CAS_Danos_Perjudicado__c=confirmacionAux.CNF_CAS_Danos_Perjudicado__c;
							confAux.CNF_SEL_Situacion_Danos_Propios__c=confirmacionAux.CNF_SEL_Situacion_Danos_Propios__c;
							confAux.CNF_CAS_Danos_Propios__c=confirmacionAux.CNF_CAS_Danos_Propios__c;
							confAux.CNF_CAS_Tercero_Causante__c=confirmacionAux.CNF_CAS_Tercero_Causante__c;
							confAux.CNF_SEL_Tipo__c=confirmacionAux.CNF_SEL_Tipo__c;
							confAux.CNF_SEL_Causante_Responsable__c=confirmacionAux.CNF_SEL_Causante_Responsable__c;
							confAux.CNF_TXT_Nombre__c = confirmacionAux.CNF_TXT_Nombre__c;
							confAux.CNF_TXT_Apellidos__c = confirmacionAux.CNF_TXT_Apellidos__c;
							confAux.CNF_TXT_Apellidos2__c = confirmacionAux.CNF_TXT_Apellidos2__c;
							confAux.CNF_SEL_Causante_Tipo_Documento__c = confirmacionAux.CNF_SEL_Causante_Tipo_Documento__c;
							confAux.CNF_TXT_Causante_N_Documento__c = confirmacionAux.CNF_TXT_Causante_N_Documento__c;
							confAux.CNF_TXT_Causante_Direccion__c = confirmacionAux.CNF_TXT_Causante_Direccion__c;
							confAux.CNF_TXT_Codigo_Postal__c = confirmacionAux.CNF_TXT_Codigo_Postal__c;
							confAux.CNF_TXT_Causante_Poblacion__c = confirmacionAux.CNF_TXT_Causante_Poblacion__c;
							confAux.CNF_SEL_Causante_Provincia__c = confirmacionAux.CNF_SEL_Causante_Provincia__c;
							confAux.CNF_TFN_Telefono_1__c = confirmacionAux.CNF_TFN_Telefono_1__c;
							confAux.CNF_TFN_Telefono_2__c = confirmacionAux.CNF_TFN_Telefono_2__c;
							confAux.CNF_EMA_Email__c = confirmacionAux.CNF_EMA_Email__c;
							confAux.CNF_SEL_Causante_Compania__c = confirmacionAux.CNF_SEL_Causante_Compania__c;
							confAux.CNF_TXT_Causante_Poliza_R_C__c = confirmacionAux.CNF_TXT_Causante_Poliza_R_C__c;
							confAux.CNF_TXT_Causante_N_exp_Stro__c = confirmacionAux.CNF_TXT_Causante_N_exp_Stro__c;
							confAux.CNF_LKP_Gestor_Apertura__c = confirmacionAux.CNF_LKP_Gestor_Apertura__c;
							confAux.CNF_DAT_Fecha_Apertura__c = confirmacionAux.CNF_DAT_Fecha_Apertura__c;
						}
					}

					//Si existen 2, y soy gestor, creo la suya.
					if(confAux != null)
						listaConfirmacionesToUpsert.add(confAux);
					//listaConfirmacionesToUpsert.add(newConfirmacion('',mapRecordTypes.get(Label.RT_CNF_Gestor).Id, Label.CNF_ESTADO_EN_CURSO_GESTOR)); 
				}
			}
		
		//4º Inicializamos la confirmación.
		numeroDeColumnas=listaConfirmacionesToUpsert.size();
		for(Confirmacion__c confirmacionAux:listaConfirmacionesToUpsert) {
			if(mapRecordTypes.get(Label.RT_CNF_Profesional).Id==confirmacionAux.recordTypeId) {
				confirmacionProfesional=confirmacionAux;
			} else if(mapRecordTypes.get(Label.RT_CNF_Gestor).Id==confirmacionAux.RecordTypeId) {
				confirmacionGestor=confirmacionAux;
			} else if(mapRecordTypes.get(Label.RT_CNF_Apertura_Finalizada).Id==confirmacionAux.RecordTypeId) {
				confirmacionCopiaOriginal=confirmacionAux;
			}
			//Inicializo el Editable, que son los inputFields de la VF.
			System.debug('SiniSondeoConfirmacionController: constructor: confirmacionAux: '+confirmacionAux);
			System.debug('SiniSondeoConfirmacionController: constructor: confirmacionAux.recordTypeId: '+confirmacionAux.recordTypeId);
			System.debug('SiniSondeoConfirmacionController: constructor: listaConfirmacionesToUpsert.size(): '+listaConfirmacionesToUpsert.size());
			if(mapRecordTypes.get(Label.RT_CNF_Profesional).Id==confirmacionAux.recordTypeId && listaConfirmacionesToUpsert.size()==2) {
				confirmacionEditable=confirmacionAux;
			} else if(mapRecordTypes.get(Label.RT_CNF_Gestor).Id==confirmacionAux.RecordTypeId) {
				confirmacionEditable=confirmacionAux;
			}
		}
		System.debug('SiniSondeoConfirmacionController: constructor: confirmacionEditable: '+confirmacionEditable);
		//Confirmacion__c confirmacionAnterior=new Confirmacion__c();

		//5º  Obtener los perjudicados asociados al caso
			
													 
		if (intervencion.CAS_CAS_Danos_Perjudicado__c){
			listaPerjudicados = Util_Siniestro.queryPerjudicadosSini(new Set<Id>{intervencion.Id}).values();
		}

		//6ª Definir condición para filtrar las líneas incluidas en árboles de decisión activos del productoCIA actual
		String filtroQuery = ' ADL_LKP_Arbol_Decision__r.ADC_SEL_Estado__c = \'Activo\'';
		if (!String.isEmpty(intervencion.CAS_LKP_PolizaContrato__c) && !String.isEmpty(intervencion.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c)) {
			filtroQuery += ' AND ADL_LKP_Arbol_Decision__r.ADC_LKP_Producto_CIA__c = \'' + intervencion.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c + '\'';
		}
		if (intervencion.CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c != null){
			filtroQuery += ' AND ADL_SEL_E_Tipo_Riesgo__c INCLUDES (\'' + intervencion.CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c + '\')';
		}

		// 7º. Obtener listado de Grupos de Causa para mostrar en el desplegable
		Map<Id, Arbol_Decision_Lineas__c> mapaADL = inicializarNuevaSeccion('ADL_SEL_E_Grupo_Causa__c', true, 'ADL_LKP_Ay_Grupo_Causa__r.AYU_TXT_Descripcion__c', null, filtroQuery, setIdsArbolDecisionLineasGeneral, listaGrupoCausas, true);

		//9º  Obtener resto de niveles en función de los valores actuales del Caso
		//9.1. Si el Grupo de Causa del Caso está en alguna de las líneas actuales
		//Cambiar Confirmacion Anterior. ¿Em eñ casp ìede cambiar la Versión de la póliza?
		if (!setIdsArbolDecisionLineasGeneral.isEmpty() && intervencion.CAS_SEL_Grupo_Causa__c != null){
			String gCausa = devolverValorLista('CNF_SEL_Grupo_Causa__c', intervencion.CAS_SEL_Grupo_Causa__c, listaGrupoCausas);
            if(!String.isEmpty(gCausa)) {
                //9.1.1. Seleccionar el valor actual en el desplegable
                grupoCausas = gCausa;
                grupoCausasLabel = Util_Listas_Seleccion.getLabelDesdeAPI('Confirmacion__c', 'CNF_SEL_Grupo_Causa__c').get(grupoCausas);
                //9.1.2. obtener listado de Tipos de Avería para mostrar en el desplegable
                cambioGrCausas();

                //9.2. Si el Tipo de Avería del Caso está en alguna de las líneas actuales
				//Cambiar Confirmacion Anterior. 
				if (confirmacionEditable.CNF_SEL_Tipo_Averia__c != null){
                        String tipoAveriaAux = devolverValorLista('CNF_SEL_Tipo_Averia__c', confirmacionEditable.CNF_SEL_Tipo_Averia__c, listaTipoAveria);
                        if(!String.isEmpty(tipoAveriaAux)) {
                            //9.2.1. Seleccionar el valor actual en el desplegable
                            tipoAveria = tipoAveriaAux;
                            //9.2.2. Obtener listado de Detalles de Avería para mostrar en el desplegable
                            cambioTipoAveria();
                            system.debug('<<<<detalle averia '+confirmacionEditable.CNF_SEL_Detalle_Averia__c);
                            //9.3. Si el Detalle de Avería del Caso está en alguna de las líneas actuales
                            if (confirmacionEditable.CNF_SEL_Detalle_Averia__c != null){
								System.debug('>>>>>>>>>> confirmacion.CNF_SEL_Detalle_Averia__c 2: '+confirmacionEditable.CNF_SEL_Detalle_Averia__c);
                                String detalleAveriaAux = devolverValorLista('CNF_SEL_Detalle_Averia__c', confirmacionEditable.CNF_SEL_Detalle_Averia__c, listaDetalleAveria);
                                if(detalleAveriaAux != null){
                                    //9.3.1. Seleccionar el valor en el desplegable
                                    detalleAveria = detalleAveriaAux;
									System.debug('>>>>>>>>>> confirmacion.CNF_SEL_Detalle_Averia__c 3: '+detalleAveria);
									System.debug('>>>>>>>>>> confirmacion.CNF_SEL_Detalle_Averia__c 3: '+confirmacionEditable.CNF_SEL_Detalle_Averia__c);

                                    //9.3.2. Obtener listado de Causas de Avería para mostrar en el desplegable
                                    cambioDetalleAveria();

                                    //9.4. Si la Causa de Avería del Caso está en alguna de las líneas actuales
                                    if (confirmacionEditable.CNF_SEL_Causa_Averia__c != null){
                                        system.debug('<<<<causa averia' + confirmacionEditable.CNF_SEL_Causa_Averia__c);
                                        system.debug('<<<<listaCausaAveria' + listaCausaAveria);
                                        String causaAveriaAux = devolverValorLista('CNF_SEL_Causa_Averia__c', confirmacionEditable.CNF_SEL_Causa_Averia__c, listaCausaAveria);
                                        if(causaAveriaAux != null){
                                            //9.4.1. Seleccionar el valor en el desplegable
                                            causaAveria = causaAveriaAux;
                                            //cambioCausaAveria();
                                        }
                                    }
                                }
                            }

                            //9.5. Si hay Daños Propios //Cambiar Confirmacion Anterior. 
                            if (confirmacionEditable.CNF_CAS_Danos_Propios__c){
                                // 5.5.1. Marcar el check.
                                existenDanosPropios = confirmacionEditable.CNF_CAS_Danos_Propios__c;
                                // 5.5.2. Obtener listado de Situación de Daños Propios
                                cambioDanosPropios();
								// 5. 5. 3. Rellenar la lista de Daños Propios.
                            	mapSeleccionDanosPropios=new Map<String,Boolean>();
								for(SelectOption opcion: listaSituacionDanosPropios) {
									mapSeleccionDanosPropios.put(opcion.getLabel(),false);
								}

								// 5. 5. 4. Marcar los Daños de la Confirmación Anterior.
								if(!String.isEmpty(confirmacionApertura.CNF_SEL_Situacion_Danos_Propios__c)) {
									for(String opcionSeleccionada:String.valueOf(confirmacionApertura.CNF_SEL_Situacion_Danos_Propios__c).split(';')) {
										if(mapSeleccionDanosPropios.containsKey(opcionSeleccionada.toUpperCase())) {
											mapSeleccionDanosPropios.put(opcionSeleccionada.toUpperCase(),true);
										} 
									}
								}
		 
								// 5.5 .5 Rellanar la lista de Otros Daños
								mapSeleccionOtrosDanos=new Map<String,Boolean>();
								for(SelectOption opcion: listaOtrosDanosPropios) {
									mapSeleccionOtrosDanos.put(opcion.getLabel(),false);
								}
								// 5.5 .5 Marcar los check de la lista de Otros Daños
								if(!String.isEmpty(confirmacionApertura.CNF_SEL_Otros_Danos__c)) {
									for(String opcionSeleccionada:String.valueOf(confirmacionApertura.CNF_SEL_Otros_Danos__c).split(';')) {
										if(mapSeleccionOtrosDanos.containsKey(opcionSeleccionada.toUpperCase())) {
											mapSeleccionOtrosDanos.put(opcionSeleccionada.toUpperCase(),true);
										} 
									}
								}

									
                                situacionDanosPropios = recogerValoresDisponibles('CNF_SEL_Situacion_Danos_Propios__c', confirmacionEditable.CNF_SEL_Situacion_Danos_Propios__c, listaSituacionDanosPropios);
                                arbolDecisionLineasAuxiliar.ADL_SEL_E_Situacion_Danos_Propios__c = situacionDanosPropios;
                                
							
								otrosDanosPropios = recogerValoresDisponibles('CNF_SEL_Otros_Danos__c', confirmacionEditable.CNF_SEL_Otros_Danos__c, listaOtrosDanosPropios);
                                arbolDecisionLineasAuxiliar.ADL_SEL_E_Otros_Danos_Propios__c = otrosDanosPropios;
                                // 5.5 .5Confirmarción Anterior
								if (confirmacionEditable.CNF_CAS_Tercero_Causante__c){
                                    terceroCausante = confirmacionEditable.CNF_CAS_Tercero_Causante__c;
                                    if(confirmacionEditable.CNF_TXT_Codigo_Postal__c != null){
                                        cargarListaPoblacionPorCPCausante();
                                    }
                                }
                            } 

                            // 5.6. Si hay Daños de Perjudicado. Confirmación anterior.
                            if(confirmacionEditable.CNF_CAS_Danos_Perjudicado__c){
                                existenDanosPerjudicado = confirmacionEditable.CNF_CAS_Danos_Perjudicado__c;
                                cambioDanosPerjudicados();
                            }
                        }
                    }
                }
    		}

                //Igualo los valores de la Apertura a los valores de la Confirmación del profesional.
                confirmacionEditable.CNF_SEL_Grupo_Causa__c=confirmacionApertura.CNF_SEL_Grupo_Causa__c;
                confirmacionEditable.CNF_SEL_Tipo_Averia__c=confirmacionApertura.CNF_SEL_Tipo_Averia__c;
                confirmacionEditable.CNF_SEL_Detalle_averia__c=confirmacionApertura.CNF_SEL_Detalle_averia__c;
                confirmacionEditable.CNF_SEL_Causa_Averia__c=confirmacionApertura.CNF_SEL_Causa_Averia__c;
                confirmacionEditable.CNF_SEL_Otros_Danos__c=confirmacionApertura.CNF_SEL_Otros_Danos__c;
                confirmacionEditable.CNF_CAS_Danos_Perjudicado__c=confirmacionApertura.CNF_CAS_Danos_Perjudicado__c;
    	}
	}
    

    private List<Confirmacion__c> createConfirmacionesCopia() {
        List<Confirmacion__c> listaConfirmacion=new List<Confirmacion__c>();
		listaConfirmacion.add(newConfirmacion('',mapRecordTypes.get(Label.RT_CNF_Apertura_Finalizada).Id, Label.CNF_ESTADO_APERTURA));
		if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == LABEL.PERFIL_PROFESIONAL)
        	listaConfirmacion.add(newConfirmacion('',mapRecordTypes.get(Label.RT_CNF_Profesional).Id, Label.CNF_ESTADO_EN_CURSO_PROF));
        else
        	listaConfirmacion.add(newConfirmacion('',mapRecordTypes.get(Label.RT_CNF_Gestor).Id, Label.CNF_ESTADO_EN_CURSO_GESTOR));
         return listaConfirmacion;
    }
 
   
    //Inicializo las variables. 
    private void iniciarVariables() {
		listaGarantiasObtenidasLinea=new List<Garantia__c>();
		numeroDeColumnas=0;
		listaWorkOderToUpsert= new List<WorkOrder>();
		verSeccionSalidasObtenidas=false;
		listaSalidasObtenidas=new List<SelectOption>();
		numeroGremiosSalida=0;
		errorMostradoMensajeSalidaMostrado=false;
        mensajeInicial='';
		mensajeErrorSalida='';
        intervencion=new Case();
        confirmacionEditable=new Confirmacion__c();
        setGarantiasPoliza=new Set<String>();
        listaPerjudicados=new List<Perjudicado_Siniestro__c>();
        listaGrupoCausas = new List<SelectOption>();
        grupoCausas='';
        grupoCausasLabel='';
        listaTipoAveria=new List<SelectOption>();
        tipoAveria='';
        listaDetalleAveria=new List<SelectOption>();
        detalleAveria='';
        listaCausaAveria=new List<SelectOption>();
        causaAveria='';
        creacionPerjudicado = false;
        edicionPerjudicado = false;
     	verTipoAveria=false;
        verDetalleAveria=false;
        verCausaAveria=false;
        verSeccionDanos=false;
		verSeccionDanosPropios=false;
		verSeccionDanosPerjudicado=false;
		verSeccionTerceroCausante=false;
        existenDanosPropios = intervencion.CAS_CAS_Danos_Propios__c;
        existenDanosPerjudicado=intervencion.CAS_CAS_Danos_Perjudicado__c;
        setIdsArbolDecisionLineasGeneral=new Set<Id>();
        arbolDecisionLineasAuxiliar=new Arbol_Decision_Lineas__c();
        tipoActuacionMultiple=false;
		listConfirmacionesToDelete=new List<Confirmacion__c>();
        terceroCausante=false;
		mapRecordTypes=new Map<String, RecordType>();

		Set<String> setRecordTypes=new Set<String>{Label.RT_CNF_Apertura_Finalizada,Label.RT_CNF_Gestor,Label.RT_CNF_Profesional};
		for(RecordType rt:[SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN :setRecordTypes]) {
			mapRecordTypes.put(rt.DeveloperName, rt);
		}
   }
    // Crear el objeto copia para realizar la confirmación
    private List<Confirmacion__c> queryConfirmacionesExistentes() {
        List<Confirmacion__c> listaConfirmacionesToUpsert=new List<Confirmacion__c>();
        for(Confirmacion__c confirmacionAux:Util_Siniestro.queryConfirmacionesPorCasoPadre(new set<Id>{intervencion.Id}).values()) {
            listaConfirmacionesToUpsert.add(confirmacionAux);
        }
        return listaConfirmacionesToUpsert;
    }

    //Crear nueva Confirmación.
    private Confirmacion__c newConfirmacion(String idConfirmacion, String recordTypeDeveloperName, String estadoConfirmacion) {
        String idConfirmacionAux; 
        if(!String.isEmpty(idConfirmacion)) {
            idConfirmacionAux=idConfirmacion;
        } 
		
        Confirmacion__c newConfirmacion =new Confirmacion__c(
            Id=idConfirmacionAux,
            CNF_LKP_ParentId__c=intervencion.Id,
            CNF_SEL_Causa_Averia__c = intervencion.CAS_SEL_Causa_Averia__c,
            CNF_SEL_Situacion_Danos_Propios__c = intervencion.CAS_SEL_Situacion_Danos_Propios__c,
            CNF_SEL_Detalle_averia__c = intervencion.CAS_SEL_Detalle_Averia__c,
            CNF_SEL_Grupo_Causa__c = intervencion.CAS_SEL_Grupo_Causa__c,
            CNF_SEL_Otros_Danos__c = intervencion.CAS_SEL_Otros_Danos__c,
            CNF_CAS_Tercero_Causante__c = intervencion.CAS_CAS_Tercero_Causante__c,
            CNF_SEL_Tipo_Averia__c = intervencion.CAS_SEL_Tipo_Averia__c,
            CNF_SEL_Tipo__c = intervencion.Type,
            RecordTypeId = recordTypeDeveloperName,
            CNF_SEL_Estado_Confirmacion__c= estadoConfirmacion,
            CNF_SEL_Causante_Responsable__c = intervencion.CAS_SEL_Causante_Responsable__c,
            CNF_TXT_Nombre__c = intervencion.CAS_TXT_Nombre__c,
            CNF_TXT_Apellidos__c = intervencion.CAS_TXT_Apellidos__c,
            CNF_TXT_Apellidos2__c = intervencion.CAS_TXT_Apellidos_2__c,
            CNF_SEL_Causante_Tipo_Documento__c = intervencion.CAS_SEL_Causante_Tipo_Documento__c,
            CNF_TXT_Causante_N_Documento__c = intervencion.CAS_TXT_Causante_N_Documento__c,
            CNF_TXT_Causante_Direccion__c = intervencion.CAS_TXT_Causante_Direccion__c,
            CNF_TXT_Codigo_Postal__c = intervencion.CAS_TXT_Codigo_Postal__c,
            CNF_TXT_Causante_Poblacion__c = intervencion.CAS_TXT_Causante_Poblacion__c,
            CNF_SEL_Causante_Provincia__c = intervencion.CAS_SEL_Causante_Provincia__c,
            CNF_TFN_Telefono_1__c = intervencion.CAS_TFN_Telefono_1__c,
            CNF_TFN_Telefono_2__c = intervencion.CAS_TFN_Telefono_2__c,
            CNF_EMA_Email__c = intervencion.CAS_EMA_Email__c,
            CNF_SEL_Causante_Compania__c = intervencion.CAS_SEL_Causante_Compania__c,
            CNF_TXT_Causante_Poliza_R_C__c = intervencion.CAS_TXT_Causante_Poliza_R_C__c,
            CNF_TXT_Causante_N_exp_Stro__c = intervencion.CAS_TXT_Causante_N_exp_Stro__c,
            CNF_CAS_Danos_Propios__c = intervencion.CAS_CAS_Danos_Propios__c,
            CNF_CAS_Danos_Perjudicado__c = intervencion.CAS_CAS_Danos_Perjudicado__c,
            CNF_LKP_Gestor_Apertura__c = intervencion.CAS_LKP_Gestor_Apertura__c,
            CNF_DAT_Fecha_Apertura__c = intervencion.CAS_DAT_Fecha_Apertura__c,
			CNF_TXT_Comentario__c='');
        return newConfirmacion;
    }
	
    //Metodo que se encarga de hacer la query al objeto Arbol_Decision_Lineas para recoger los valores necesarios en cada uno de los niveles
    public Map<Id, Arbol_Decision_Lineas__c> inicializarNuevaSeccion(String campoQuery, Boolean picklist, String campoAyuda, Set<Id> idsADL, String filtro, Set<Id> idsADLNuevo, List<SelectOption> listaSeleccion, Boolean opcionNinguno){
	    String query = 'SELECT ' + campoQuery;
        if(picklist){
            query += ', toLabel(' + campoQuery + ') LABEL';
        }
        if(campoAyuda != null){
            query += ', ' + campoAyuda;
        }
        query += ' FROM Arbol_Decision_Lineas__c WHERE ';
        if(setIdsArbolDecisionLineasGeneral != null && (!setIdsArbolDecisionLineasGeneral.isEmpty())){
            query += 'Id IN ' + setToString(setIdsArbolDecisionLineasGeneral) + ' AND ';
        }
        query += filtro;
        Map<Id, Arbol_Decision_Lineas__c> mapaADL = new Map<Id, Arbol_Decision_Lineas__c>((List<Arbol_Decision_Lineas__c>) Database.query(query));
        idsADLNuevo.addAll(mapaADL.keySet());
        if(opcionNinguno){
            listaSeleccion.add(new SelectOption('', '--Ninguno--'));
        }
        Set<String> setListaSeleccion = new Set<String>();
        for(Arbol_Decision_Lineas__c adLinea : mapaADL.values()){
            String valorCampo = (String) adLinea.get(campoQuery);
            String etiquetaCampo = valorCampo;
            if(picklist){
                etiquetaCampo = (String) adLinea.get('LABEL');
            }   
            if(valorCampo != null){ 
                if(valorCampo.contains(';')){
                    List<String> listaValoresCampo = valorCampo.split(';');
                    List<String> listaEtiquetasCampo = etiquetaCampo.split(';');
                    Integer i = 0;
                    for(String valorCampoAux : listaValoresCampo){
                        if(!setListaSeleccion.contains(valorCampoAux.toUpperCase())){
                            setListaSeleccion.add(valorCampoAux.toUpperCase());
                            listaSeleccion.add(new SelectOption(valorCampoAux.toUpperCase(), listaEtiquetasCampo.get(i).toUpperCase()));
                        }
                        i++;
                    }
                }else{
                    if(!setListaSeleccion.contains(valorCampo.toUpperCase())){
                        setListaSeleccion.add(valorCampo.toUpperCase());
                        listaSeleccion.add(new SelectOption(valorCampo.toUpperCase(), etiquetaCampo.toUpperCase()));
                    }
                }
            }
        }
        return mapaADL;
    }

    /*
    * Método que convierte un set a String.
    */
    private String setToString(Set<Id> idsADL){
        String cadenaRetorno;
        cadenaRetorno = '(';
        for(Id idADL : idsADL){
            cadenaRetorno += '\'' + idADL + '\',';
        }
        cadenaRetorno = cadenaRetorno.removeEnd(',');
        cadenaRetorno += ')';
        return cadenaRetorno;
    }

    /*
    * Método que devuelve el valor seleccionado de una picklist.
    */
    private String devolverValorLista(String nombreCampo, String valor, List<SelectOption> listaValores){
        String valorRetorno;
        String labelValorApi = Util_Listas_Seleccion.getLabelDesdeAPI('Confirmacion__c', nombreCampo).get(valor);
        if(valorEnLista(labelValorApi, listaValores)){
            valorRetorno = labelValorApi;
        }
        else if(valorEnLista(valor, listaValores)){
            valorRetorno = valor;
        }
        return valorRetorno;
    }
    //Método que indica, si el valor existe en la lista o no.
    public Boolean valorEnLista(String valor, List<SelectOption> lista){
        Boolean encontrado = false;
        for(SelectOption opcion : lista){
            if(valor == opcion.getValue()){
                encontrado = true;
                break;
            }
        }
        return encontrado;
    }

    //Metodos que se encargan de mostrar las diferentes secciones/campos de la pagina
    public void cambioGrCausas(){
		textoAyudaDanosPropios=null;
		textoAyudaDanosPerjudicados=null;

		existenDanosPropios=false;
		existenDanosPerjudicado=false;
		terceroCausante=false;

		verTipoAveria=false;
		verDetalleAveria=false;
		verCausaAveria=false;
		verSeccionDanos = false;
		verSeccionDanosPropios=false;
		verSeccionDanosPerjudicado=false;
		verSeccionTerceroCausante=false;

        inicializarTipoAveria();
        inicializarDetalleAveria();
        inicializarCausaAveria();
        
        if(grupoCausas != null){
            String filtroQuery = 'ADL_SEL_E_Grupo_Causa__c = \'' + grupoCausas + '\'';
            filtroQuery += ' AND ADL_SEL_E_Tipo_Averia__c != null';
            setIdsArbolDecisionLineasGrupoCausas = new Set<Id>();
            listaTipoAveria = new List<SelectOption>();
            Map<Id, Arbol_Decision_Lineas__c> mapaADL = inicializarNuevaSeccion('ADL_SEL_E_Tipo_Averia__c', true, 'ADL_LKP_Ay_Grupo_Causa__r.AYU_TXT_Descripcion__c', setIdsArbolDecisionLineasGeneral, filtroQuery, setIdsArbolDecisionLineasGrupoCausas, listaTipoAveria, true);
            if(!mapaADL.isEmpty()){
                textoAyudaGrupoCausa = mapaADL.values().get(0).ADL_LKP_Ay_Grupo_Causa__r.AYU_TXT_Descripcion__c;
            }else{
                textoAyudaGrupoCausa = null;
            }
            textoAyuda = textoAyudaGrupoCausa;
            verTipoAveria = true;
            
            Date fLimite = System.today().addDays(-30);
            List<Case> yaExistentes = Util_Caso.queryCasosYaExistentes(grupocausas, fLimite, new Set<Id>{confirmacionEditable.CNF_LKP_ParentId__r.CAS_LKP_PolizaContrato__c},
                                            new Set<Id>{confirmacionEditable.CNF_LKP_ParentId__c}).values();
            
            if(!yaExistentes.isEmpty()){
				
                //mensajeInicial=Label.WARNING_SINIESTROS_POLIZA;
              //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_SINIESTROS_POLIZA));
            }
            
            
        }else{
            textoAyuda = null;
        }
    }

    //Método para cambiar el tipo de Avería.
    public void cambioTipoAveria(){
		textoAyudaDanosPropios=null;
		textoAyudaDanosPerjudicados=null;

		existenDanosPropios=false;
		existenDanosPerjudicado=false;
		terceroCausante=false;
		
		verDetalleAveria=false;
		verCausaAveria=false;
		verSeccionDanos = false;
		verSeccionDanosPropios=false;
		verSeccionDanosPerjudicado=false;
		verSeccionTerceroCausante=false;


        inicializarDetalleAveria();
        inicializarCausaAveria();
        if(tipoAveria != null){
            String filtroQuery = 'ADL_SEL_E_Tipo_Averia__c = \'' + tipoAveria + '\'';
            filtroQuery += ' AND ADL_SEL_E_Detalle_Averia__c != null';
            setIdsArbolDecisionLineasTipoAveria = new Set<Id>();
            listaDetalleAveria = new List<SelectOption>();
            Map<Id, Arbol_Decision_Lineas__c> mapaADL = inicializarNuevaSeccion('ADL_SEL_E_Detalle_Averia__c', true, 'ADL_LKP_Ay_Tipo_Averia__r.AYU_TXT_Descripcion__c', setIdsArbolDecisionLineasGrupoCausas, filtroQuery, setIdsArbolDecisionLineasTipoAveria, listaDetalleAveria, true);
            if(!mapaADL.isEmpty()){
                textoAyudaTipoAveria = mapaADL.values().get(0).ADL_LKP_Ay_Tipo_Averia__r.AYU_TXT_Descripcion__c;
            }else{
                textoAyudaTipoAveria = null;
            }
            textoAyuda = textoAyudaTipoAveria;
            verDetalleAveria = true;
            //La seccion de detalle de la averia se puede dejar en blanco
            if(listaDetalleAveria.isEmpty() || listaDetalleAveria.size()==1){
                verSeccionDanos = true;
				//checks a false.
				existenDanosPropios=false;
				existenDanosPerjudicado=false;
				terceroCausante=false;
            }
        }
    }

    private void inicializarDetalleAveria(){
		textoAyudaDetalleAveria=null;
        verDetalleAveria = false;
        detalleAveria = null;
    }
    
    private void inicializarCausaAveria(){
        textoAyudaCausaAveria=null;
        verCausaAveria = false;
        causaAveria = null;
    }

    //Metodos para inicializar secciones
    private void inicializarTipoAveria(){
        textoAyudaTipoAveria=null;
        verTipoAveria = false;
        tipoAveria = null;
    }

    //CAmbiar detalle de la avería.
    public void cambioDetalleAveria(){
		textoAyudaDanosPropios=null;
		textoAyudaDanosPerjudicados=null;

		existenDanosPropios=false;
		existenDanosPerjudicado=false;
		terceroCausante=false;

		verCausaAveria=false;
		verSeccionDanos = false;
		verSeccionDanosPropios=false;
		verSeccionDanosPerjudicado=false;
		verSeccionTerceroCausante=false;

        inicializarCausaAveria();
        if(detalleAveria != null){
            String filtroQuery = 'ADL_SEL_E_Detalle_Averia__c = \'' + detalleAveria + '\'';
            setIdsArbolDecisionLineaDetalleAveria = new Set<Id>();
            listaCausaAveria = new List<SelectOption>();
            Map<Id, Arbol_Decision_Lineas__c> mapaADL = inicializarNuevaSeccion('ADL_SEL_E_Causa_Averia__c', true, 'ADL_LKP_Ay_Detalle_Averia__r.AYU_TXT_Descripcion__c', setIdsArbolDecisionLineasTipoAveria, filtroQuery, setIdsArbolDecisionLineaDetalleAveria, listaCausaAveria, true);
            if(!mapaADL.isEmpty()){
                textoAyudaDetalleAveria = mapaADL.values().get(0).ADL_LKP_Ay_Detalle_Averia__r.AYU_TXT_Descripcion__c;
            }else{
                textoAyudaDetalleAveria = null;
            }
            textoAyuda = textoAyudaDetalleAveria;
            verCausaAveria = true;
			if(listaCausaAveria.isEmpty() || listaCausaAveria.size()==1) {
				verSeccionDanos=true;
				//checks a false.
				existenDanosPropios=false;
				existenDanosPerjudicado=false;
				terceroCausante=false;
			}
        }
    }

    public void cambioDanosPropios(){
		verSeccionDanos=true;
		textoAyudaDanosPropios=null;
		if(existenDanosPropios) {
			verSeccionDanosPropios=true;
			situacionDanosPropios = null;
			arbolDecisionLineasAuxiliar.ADL_SEL_E_Situacion_Danos_Propios__c = null;
			otrosDanosPropios = null;
			arbolDecisionLineasAuxiliar.ADL_SEL_E_Otros_Danos_Propios__c = null;
			String filtroQuery;
			if(detalleAveria != null){
				filtroQuery = 'ADL_SEL_E_Detalle_Averia__c = \'' + detalleAveria + '\'';
			}else{
				filtroQuery = 'ADL_SEL_E_Detalle_Averia__c = ' + detalleAveria;
			}
			if(causaAveria != null){
				filtroQuery = 'ADL_SEL_E_Causa_Averia__c = \'' + causaAveria + '\'';
			}else{
				filtroQuery = 'ADL_SEL_E_Causa_Averia__c = ' + causaAveria;
			}
			filtroQuery += ' AND ADL_SEL_E_Danos_Propios__c = \'SI\'';
			String filtroQueryDanosPropios = ' AND ADL_SEL_E_Situacion_Danos_Propios__c != null';
			setIdsArbolDecisionLineaDanosPropios = new Set<Id>();
			listaSituacionDanosPropios = new List<SelectOption>();
			Map<Id, Arbol_Decision_Lineas__c> mapaADL = inicializarNuevaSeccion('ADL_SEL_E_Situacion_Danos_Propios__c', true, 'ADL_LKP_Ay_Danos_Propios__r.AYU_TXT_Descripcion__c', setIdsArbolDecisionLineaTipoAveria, filtroQuery + filtroQueryDanosPropios, setIdsArbolDecisionLineaDanosPropios, listaSituacionDanosPropios, false);
			// Rellenar la lista de Daños Propios.
			mapSeleccionDanosPropios=new Map<String,Boolean>();
			for(SelectOption opcion: listaSituacionDanosPropios) {
				mapSeleccionDanosPropios.put(opcion.getLabel().toUpperCase(),false);
			}
		
			if(!mapaADL.isEmpty()){
				textoAyudaDanosPropios = mapaADL.values().get(0).ADL_LKP_Ay_Danos_Propios__r.AYU_TXT_Descripcion__c;
			}else{
				textoAyudaDanosPropios = null;
			}
			textoAyuda = textoAyudaDanosPropios;
			listaOtrosDanosPropios = new List<SelectOption>();
			String filtroQueryOtrosDanosPropios = ' AND ADL_SEL_E_Otros_Danos_Propios__c != null';
			inicializarNuevaSeccion('ADL_SEL_E_Otros_Danos_Propios__c', true, null, setIdsArbolDecisionLineaDetalleAveria, filtroQuery + filtroQueryOtrosDanosPropios, setIdsArbolDecisionLineaDanosPropios, listaOtrosDanosPropios, false);
			//Rellanar la lista de Otros Daños
			mapSeleccionOtrosDanos=new Map<String,Boolean>();
			for(SelectOption opcion: listaOtrosDanosPropios) {
				mapSeleccionOtrosDanos.put(opcion.getLabel().toUpperCase(),false);
			}
		} else {
			verSeccionDanosPropios=false;
			verSeccionTerceroCausante=false;
		}
	}

	public void cambioDanosPerjudicados(){
		verSeccionDanosPerjudicado=false;
		textoAyudaDanosPerjudicados=null;
		if(existenDanosPerjudicado && !terceroCausante){
			//Consulo los perjudicados.
			listaPerjudicados = Util_Siniestro.queryPerjudicadosSini(new Set<Id>{intervencion.Id}).values();																					   
			verSeccionDanosPerjudicado=true;
			nuevoPerjudicado =new Perjudicado_Siniestro__c();
			situacionDanosPerjudicado = null;
			otrosDanosPerjudicado = null;
			String filtroQuery;
			if(causaAveria != null){
				filtroQuery = 'ADL_SEL_E_Causa_Averia__c = \'' + causaAveria + '\'';
			}else{
				filtroQuery = 'ADL_SEL_E_Causa_Averia__c = ' + causaAveria;
			}
			filtroQuery += ' AND ADL_SEL_E_Danos_Perjudicados__c = \'SI\'';
			String filtroQueryDanosPropiosPerj = ' AND ADL_SEL_E_Situacion_Danos_Perjud__c != null';
			setIdsArbolDecisionLineaDanosPerjudicado = new Set<Id>();
			listaSituacionDanosPerjudicado = new List<SelectOption>();
			Map<Id, Arbol_Decision_Lineas__c> mapaADL = inicializarNuevaSeccion('ADL_SEL_E_Situacion_Danos_Perjud__c', true, 'ADL_LKP_Ay_Danos_Perjudicados__r.AYU_TXT_Descripcion__c', setIdsArbolDecisionLineaDetalleAveria, filtroQuery + filtroQueryDanosPropiosPerj, setIdsArbolDecisionLineaDanosPerjudicado, listaSituacionDanosPerjudicado, false);
			if(!mapaADL.isEmpty()){
				textoAyudaDanosPerjudicados = mapaADL.values().get(0).ADL_LKP_Ay_Danos_Perjudicados__r.AYU_TXT_Descripcion__c;
			}else{
				textoAyudaDanosPerjudicados = null;
			}
			textoAyuda = textoAyudaDanosPerjudicados;
			listaOtrosDanosPerjudicado = new List<SelectOption>();
			String filtroQueryOtrosDanosPropiosPerj = ' AND ADL_SEL_E_Otros_Danos_Perjudicados__c != null';
			inicializarNuevaSeccion('ADL_SEL_E_Otros_Danos_Perjudicados__c', true, null, setIdsArbolDecisionLineaDetalleAveria, filtroQuery + filtroQueryOtrosDanosPropiosPerj, setIdsArbolDecisionLineaDanosPerjudicado, listaOtrosDanosPerjudicado, false);
		} else {
			if(terceroCausante) {
				ApexPages.addMessage(new ApexPages.MEssage(ApexPages.Severity.ERROR, 'No puede haber un perjudicado, si existe un tercero causante.'));
			}
			//vacío la lista de Perjudicados.
			listaPerjudicados=new List<Perjudicado_Siniestro__c>();											  
			existenDanosPerjudicado=false;
		}
	}

    public void cambioCausaAveria(){
		textoAyudaDanosPropios=null;
		textoAyudaDanosPerjudicados=null;
		//pongo los check a false
		existenDanosPropios=false;
		existenDanosPerjudicado=false;
		terceroCausante=false;
		//renderizo el siguiente bloque.
		verSeccionDanos=true;
	}

    public void cargarListaPoblacionPorCPCausante(){
		System.debug('SiniSondeoConfirmacionController: cargarListaPoblacionPorCPCausante');
		verSeccionTerceroCausante=false;
		if(terceroCausante && existenDanosPropios && !existenDanosPerjudicado) {
			verSeccionTerceroCausante=true;
			if(!String.isEmpty(confirmacionEditable.CNF_TXT_Codigo_Postal__c)) {
				listaPoblacionesCausante = Util_TerritorioServicio.cargarListaPoblacionPorCP(confirmacionEditable.CNF_TXT_Codigo_Postal__c);
				poblacionCausante = listaPoblacionesCausante.get(0).getValue(); //CódigoProvincia#NombrePoblación
				confirmacionEditable.CNF_SEL_Causante_Provincia__c = null;
				if(listaPoblacionesCausante.size() > 1){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
				}else if(listaPoblacionesCausante.get(0).getValue() == ''){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
				}else{
					cargarProvinciaPoblacionCausante();
				}
			}
		} else {
			if(existenDanosPerjudicado) {
				ApexPages.addMessage(new ApexPages.MEssage(ApexPages.Severity.ERROR, 'No puede haber un tercero Causante, si existe un Perjudicado.'));
			}
			terceroCausante=false;
		}
	}

    	public void cargarProvinciaPoblacionCausante(){
		//HACER SELECT PARA VINCULAR AL CAUSANTE EL ID DEL OBJETO POBLACION QUE TIENE ESA POBLACION
		confirmacionEditable.CNF_SEL_Causante_Provincia__c = Util_TerritorioServicio.obtenerProvinciaSel(poblacionCausante);
	}

    //Crea un perjudicado
	public void crearPerjudicado(){
		situacionDanosPerjudicado = null;
		otrosDanosPerjudicado = null;
		creacionPerjudicado = true;
		if(edicionPerjudicado){
			nuevoPerjudicado = listaPerjudicados.get(indiceListaPerjudicados).clone(false, true);
		}else{
			nuevoPerjudicado = new Perjudicado_Siniestro__c();
			nuevoPerjudicado.PRJ_LKP_Siniestro__c = intervencion.Id; 
		}
	}

	//Se cancela la creacion del perjudicado
	public void cancelarCreacionPerjudicado(){
		nuevoPerjudicado = new Perjudicado_Siniestro__c();
		creacionPerjudicado = false;
		edicionPerjudicado = false;
	}

    public void cargarListaPoblacionPorCPPerjudicado(){
		listaPoblacionesPerjudicado = Util_TerritorioServicio.cargarListaPoblacionPorCP(nuevoPerjudicado.PRJ_TXT_Codigo_Postal__c);
		poblacionPerjudicado = listaPoblacionesPerjudicado.get(0).getValue(); //CódigoProvincia#NombrePoblación
		nuevoPerjudicado.PRJ_SEL_Provincia__c = null;
		if(listaPoblacionesPerjudicado.size() > 1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
		}else if(listaPoblacionesPerjudicado.get(0).getValue() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
		}else{
			cargarProvinciaPoblacionPerj();
		}
	}
    
	public void cargarProvinciaPoblacionPerj(){
		//HACER SELECT PARA VINCULAR AL PERJUDICADO EL ID DEL OBJETO POBLACION QUE TIENE ESA POBLACION
		//nuevoPerjudicado.PRJ_LKP_Poblacion__c = Util_TerritorioServicio.obtenerPoblacionSel(poblacionPerjudicado);
		nuevoPerjudicado.PRJ_SEL_Provincia__c = Util_TerritorioServicio.obtenerProvinciaSel(poblacionPerjudicado);
	}

    //Almacena en la lista de perjudicados al nuevo perjudicado
	public void guardarPerjudicado(){
		Perjudicado_Siniestro__c perjudicadoAInsertar;
		if(edicionPerjudicado){
			perjudicadoAInsertar=nuevoPerjudicado;
		}else{
			perjudicadoAInsertar=new Perjudicado_Siniestro__c(
				PRJ_SEL_Tipo_Perjudicado__c=nuevoPerjudicado.PRJ_SEL_Tipo_Perjudicado__c,
				PRJ_TXT_Nombre__c=nuevoPerjudicado.PRJ_TXT_Nombre__c,
				PRJ_TXT_Direccion__c=nuevoPerjudicado.PRJ_TXT_Direccion__c,
				PRJ_TXT_Codigo_Postal__c=nuevoPerjudicado.PRJ_TXT_Codigo_Postal__c,
				PRJ_TXT_Poblacion__c=nuevoPerjudicado.PRJ_TXT_Poblacion__c,
				PRJ_SEL_Provincia__c=nuevoPerjudicado.PRJ_SEL_Provincia__c,
				PRJ_TXT_Perjudicado_N_Documento__c=nuevoPerjudicado.PRJ_TXT_Perjudicado_N_Documento__c,
				PRJ_TFN_Telefono_1__c=nuevoPerjudicado.PRJ_TFN_Telefono_1__c,
				PRJ_SEL_Situacion_Danos__c=nuevoPerjudicado.PRJ_SEL_Situacion_Danos__c,
				PRJ_TFN_Movil__c=nuevoPerjudicado.PRJ_TFN_Movil__c,
				PRJ_SEL_Otros_Danos__c=nuevoPerjudicado.PRJ_SEL_Otros_Danos__c,
				PRJ_TFN_Telefono_Adicional__c=nuevoPerjudicado.PRJ_TFN_Telefono_Adicional__c,
				PRJ_LKP_Siniestro__c=intervencion.Id
			); 
			listaPerjudicados.add(perjudicadoAInsertar);
		}
	   try {
			Database.upsert(perjudicadoAInsertar);
			nuevoPerjudicado=new Perjudicado_Siniestro__c();
			creacionPerjudicado = false;
			edicionPerjudicado = false;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error. Inténtelo de nuevo'));
		}																												  
	}
  

	public void eliminarPerjudicado() {
		Integer indice=Integer.valueOf(Apexpages.currentPage().getParameters().get('indiceResultado'));
																						
																													 
		Perjudicado_Siniestro__c perjudicadoToDelete=listaPerjudicados.get(indice -1);
		delete perjudicadoToDelete;
		listaPerjudicados.remove(indice-1);
	}

	public void seleccionarResultado() {
		Integer indice=Integer.valueOf(Apexpages.currentPage().getParameters().get('indiceResultado'));
		Perjudicado_Siniestro__c perjudicadoToDelete=listaPerjudicados.get(indice);
		nuevoPerjudicado=perjudicadoToDelete;
		edicionPerjudicado=true;
	}

	public void borrarConfirmacionesAntiguas() {
		if(!listConfirmacionesToDelete.isEmpty()) {
			Database.delete(listConfirmacionesToDelete);
		}
	}
	
	private  boolean validarTelefono(String tfno) {
		Boolean existenErrores=false;
		if(tfno !=null && tfno != '' ){
			Pattern patternFijos = Pattern.compile('^(\\+34|0034|34)?[89]\\d{8}$');
			Pattern patternMoviles = Pattern.compile('^(\\+34|0034|34)?[67]\\d{8}$');
			Matcher macheaFijo = patternFijos.matcher(tfno);
			Matcher macheaMovil = patternMoviles.matcher(tfno);
			if(!macheaFijo.matches() && !macheaMovil.matches()) {
				existenErrores=true;
			}
		}
		
		return existenErrores;
	}
	   
	public void obtenerSalida() {
																				 
		if(confirmacionEditable.CNF_TXT_Comentario__c==null || String.valueOf(confirmacionEditable.CNF_TXT_Comentario__c).length()<15) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El comentario debe tener al menos, 14 caractéres.'));
		} else if(validarDanosPropios()) {//validar Daños propios.
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Si marcas la casilla de Daños propios, debes seleccionar al menos uno.'));
		} else if(existenDanosPerjudicado && listaPerjudicados.isEmpty()) {//Validar Perjudicados.
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Si marcas la casilla de Perjudicado, debe existir al menos uno.'));
		} else if(validarTerceroCausante()) {//Validar tercero Causante.
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Faltan campos obligatorios del tercero causante, o los datos introduidos son incorrectos.'));
		}  else {
			String situacionDanosPropios = '';
			String otrosDanosPropios = '';
			if(!existenDanosPropios) {
				mapSeleccionDanosPropios = new Map<String,Boolean>();
				mapSeleccionOtrosDanos = new Map<String,Boolean>();
			}
			else {
				for(String danosAux: mapSeleccionDanosPropios.keySet()){
					if(mapSeleccionDanosPropios.get(danosAux)){
						situacionDanosPropios += danosAux + ';'; 
					}
				}
				for(String otrosDanosAux: mapSeleccionOtrosDanos.keySet()){
					if(mapSeleccionOtrosDanos.get(otrosDanosAux)){
						otrosDanosPropios += otrosDanosAux + ';'; 
					}
				}
			}
			situacionDanosPropios = situacionDanosPropios.removeEnd(';');
			otrosDanosPropios = otrosDanosPropios.removeEnd(';');
		
		List<Arbol_Decision_Lineas__c> lineasSalida = obtenerPosiblesLineasSalida(situacionDanosPropios,otrosDanosPropios);
		lineaSalida=new Arbol_Decision_Lineas__c();
		for(Arbol_Decision_Lineas__c lineaAux:lineasSalida) {
			System.debug('SiniSondeoProfesionalController: obtenerSalida: lineaAux: '+lineaAux);
		}
		//Cargo la Lista de Selección.
		if(!lineasSalida.isEmpty()) {
				lineaSalida = lineaSalidaFinal(lineasSalida);
				System.debug('SiniSondeoProfesionalController: obtenerSalida: lineaSalida: '+lineaSalida);
				//Rellenamos un set con los gremios.
				Set<String> setGremiosDelArbol=new Set<String>();
				if(!String.isEmpty(lineaSalida.ADL_SEL_S_Gremios__c)) {
					for(String contadorGremios:lineaSalida.ADL_SEL_S_Gremios__c.split(';')) {
							  
						setGremiosDelArbol.add(contadorGremios);
					} 
				}
				//Consulta de los gremios, que tiene el caso con los del árbol.
																																								  
				List<WorkOrder> listaGremiosDelCaso=[SELECT ID,OTR_SEL_Gremio__c FROM WorkOrder WHERE CaseId=:intervencion.Id];

				//Rellenamos los gremios a insertar en el caso. 
				System.debug('SiniSondeoProfesionalController: obtenerSalida: listaWorkOderToUpsert: '+listaWorkOderToUpsert);
				System.debug('SiniSondeoProfesionalController: obtenerSalida: intervencion:  '+intervencion.Id);
				System.debug('SiniSondeoProfesionalController: obtenerSalida: setGremiosDelArbol: '+setGremiosDelArbol); 
				System.debug('SiniSondeoProfesionalController: obtenerSalida: lineaSalida.ADL_SEL_S_Gremios__c: '+lineaSalida.ADL_SEL_S_Gremios__c);
				Set<String> setGremiosDelCaso=new Set<String>();
				for(WorkOrder ordenAux:listaGremiosDelCaso) {
					setGremiosDelCaso.add(ordenAux.OTR_SEL_Gremio__c);
				}
				//El número de gremios, es los que tiene el caso, y luego añado los que de la línea.
				numeroGremiosSalida=setGremiosDelCaso.size();
																											  
				if(!setGremiosDelCaso.containsAll(setGremiosDelArbol)) {
					for(String gremio:setGremiosDelArbol) {
						if(!setGremiosDelCaso.contains(gremio)) {
							numeroGremiosSalida++;
																												 
							listaWorkOderToUpsert.add(new WorkOrder(OTR_SEL_Gremio__c=gremio, Status='997', CaseId=intervencion.Id));
						}
					}
				} 
																											  
				System.debug('SiniSondeoProfesionalController: obtenerSalida: listaWorkOderToUpsert: '+listaWorkOderToUpsert);
				
				/* if(listaGremiosDelCaso.size()<setGremiosDelArbol.size()) {
					for(String nombreGremios:setGremiosDelArbol) {
						if(listaGremiosDelCaso.isEmpty()) {
							listaWorkOderToUpsert.add(new WorkOrder(OTR_SEL_Gremio__c=nombreGremios, Status='997', CaseId=intervencion.Id));
						} else {
							for(WorkOrder woAux:listaGremiosDelCaso) {
								System.debug('SiniSondeoProfesionalController: obtenerSalida: woAux: '+woAux);
								if(!woAux.OTR_SEL_Gremio__c.contains(nombreGremios)) {
									listaWorkOderToUpsert.add(new WorkOrder(OTR_SEL_Gremio__c=nombreGremios, Status='997', CaseId=intervencion.Id));
								}
							}
						}
					}
				} */

				//Rellenamos las garantías de la confirmación obtenida en el árbol. 
				Set<String> setGarantiasObtenidasLinea=new Set<String>();
				if(!String.isEmpty(lineaSalida.ADL_TXT_S_Garantias__c)) {
					for(String garantia:lineaSalida.ADL_TXT_S_Garantias__c.split(';')) {
						setGarantiasObtenidasLinea.add(garantia);
					}
				}


				if(!setGarantiasObtenidasLinea.isEmpty()) {
					listaGarantiasObtenidasLinea=Util_Siniestro.queryGarantiasSini(setGarantiasObtenidasLinea).values(); 
				}

				System.debug('SiniSondeoProfesionalController: obtenerSalida: listaWorkOderToUpsert: '+listaWorkOderToUpsert);
				System.debug('SiniSondeoProfesionalController: obtenerSalida: lineaSalida.ADL_SEL_S_Tipo_Actuacion_Mult__c: '+lineaSalida.ADL_SEL_S_Tipo_Actuacion_Mult__c);
				if(!String.isEmpty(lineaSalida.ADL_SEL_S_Tipo_Actuacion_Mult__c)) {
					for(String salidaMultiple:lineaSalida.ADL_SEL_S_Tipo_Actuacion_Mult__c.split(';')) {
						String labelAux=Util_Listas_Seleccion.getLabelDesdeAPI('Arbol_Decision_Lineas__c', 'ADL_SEL_S_Tipo_Actuacion_Mult__c').get(salidaMultiple);
						verSeccionSalidasObtenidas=true;
						listaSalidasObtenidas.add(new SelectOption(salidaMultiple, labelAux));
					}
				} else {
					//SI es un rechazo, se mira el tipo de Actuación.
					if(!String.isEmpty(lineaSalida.ADL_SEL_S_Tipo_Actuacion__c)) {
						for(String salida:lineaSalida.ADL_SEL_S_Tipo_Actuacion__c.split(';')) {
							String labelAux=Util_Listas_Seleccion.getLabelDesdeAPI('Arbol_Decision_Lineas__c', 'ADL_SEL_S_Tipo_Actuacion__c').get(salida);
							verSeccionSalidasObtenidas=true;
							listaSalidasObtenidas.add(new SelectOption(salida, labelAux));
						}
					}
				}
				System.debug('SiniSondeoProfesionalController: obtenerSalida: verSeccionSalidasObtenidas: ' + verSeccionSalidasObtenidas);
				System.debug('SiniSondeoProfesionalController: obtenerSalida: lineaSalida: '+lineaSalida);
				System.debug('SiniSondeoProfesionalController: obtenerSalida: lineaSalida.ADL_SEL_S_Tipo_Actuacion__c: '+lineaSalida.ADL_SEL_S_Tipo_Actuacion__c);

				if(lineaSalida.ADL_SEL_S_Tipo_Actuacion__c == Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL) {
					lineaSalida.ADL_SEL_S_Tipo_Actuacion__c = Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL;
					lineaSalida.ADL_SEL_S_Motivo_Rechazo__c = '999';
					//SI es 5. Lo trato como un reparable.
				} else if('9'.equalsIgnoreCase(lineaSalida.ADL_SEL_S_Tipo_Actuacion__c) || '1'.equalsIgnoreCase(lineaSalida.ADL_SEL_S_Tipo_Actuacion__c) || '5'.equalsIgnoreCase(lineaSalida.ADL_SEL_S_Tipo_Actuacion__c)) {
					mensajeErrorSalida='';
					errorMostradoMensajeSalidaMostrado=false; 
					confirmacionEditable.CNF_SEL_Estado__c='001';
					confirmacionEditable.CNF_SEL_Estado_Confirmacion__c='05';
					confirmacionEditable.CNF_SEL_Tipo__c=lineaSalida.ADL_SEL_S_Tipo_Actuacion__c;
				} else {
					lineaSalida.ADL_SEL_S_Tipo_Actuacion__c = Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL;
					mensajeErrorSalida='No es posible recuperar una salida';
					//DE MOMENTO, HASTA QUE TENGAMOS EL RESTO DE SALIDAS.
					
				}
			} else {
				lineaSalida.ADL_SEL_S_Tipo_Actuacion__c = Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL;
			}
			
			
			if(lineaSalida.ADL_SEL_S_Tipo_Actuacion__c == Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL) {
				intervencion.Status=Label.CAS_ESTADO_RECHAZADO;
				intervencion.CAS_CAS_Confirmado__c=true;
				intervencion.Type=Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL;
				intervencion.CAS_LKP_Argumentario_Rechazo__c=lineaSalida.ADL_LKP_Ay_Argumentario_Rechazo__c;
				confirmacionEditable.CNF_SEL_Estado__c=Label.CAS_ESTADO_ESPERA_GESTOR_CONFIRMACION;
				confirmacionEditable.CNF_SEL_EStado_Confirmacion__c=Label.CNF_ESTADO_BLOQUEADA_PROF;
				confirmacionEditable.CNF_SEL_Tipo__c=Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL;
			}


			//Actualizo los registros de la confirmación Editable. salidaSeleccionada
			confirmacionEditable.CNF_SEL_Grupo_Causa__c=grupoCausas;
			confirmacionEditable.CNF_SEL_Tipo_Averia__c=tipoAveria;
			confirmacionEditable.CNF_SEL_Detalle_averia__c=detalleAveria;
			confirmacionEditable.CNF_SEL_Causa_Averia__c=causaAveria;
			confirmacionEditable.CNF_CAS_Danos_Perjudicado__c=existenDanosPerjudicado;
			confirmacionEditable.CNF_CAS_Danos_Propios__c=existenDanosPropios;
			confirmacionEditable.CNF_SEL_Situacion_Danos_Propios__c=situacionDanosPropios;
			confirmacionEditable.CNF_SEL_Otros_Danos__c=otrosDanosPropios;
			//Fin lista de Selección.
			
			if(!verSeccionSalidasObtenidas) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se pudo obtener una salida.'));
			}
		  
																																
		}
	}


    public String recogerValoresDisponibles(String nombreCampo, String valoresCaso, List<SelectOption> valoresDisponibles){
		String valoresRetorno;
		if(valoresCaso != null){
			for(String valCaso : valoresCaso.split(';')){
				String labelValorApi = Util_Listas_Seleccion.getLabelDesdeAPI('Confirmacion__c', nombreCampo).get(valCaso);
				for(SelectOption valDisponible : valoresDisponibles){
					String val = valDisponible.getValue();
					if(valCaso == val){
						if(valoresRetorno == null){
							valoresRetorno = valCaso;
						}else{
							valoresRetorno += ';' + valCaso;
						}
						break;
					}else if(labelValorApi == val){
						if(valoresRetorno == null){
							valoresRetorno = labelValorApi;
						}else{
							valoresRetorno += ';' + labelValorApi;
						}
						break;
					}
				}
			}
		}
		//system.debug('>>>>valoresRetorno ' + valoresRetorno);
		return valoresRetorno;
	}


    /**
	 * Recoge las lineas de salida que cumplen los filtros especificados en la visualforce
	 *
	 * @return       Lista de pobiles lineas de salida
	 * @see      List, Arbol_Decision_Lineas__c
	 */
	public List<Arbol_Decision_Lineas__c> obtenerPosiblesLineasSalida(String situacionDanosPropios, String otrosDanosPropios){
		List<Arbol_Decision_Lineas__c> listaLineasDecisionObtenidas=new List<Arbol_Decision_Lineas__c>();
		//OJO, SI setGarantiasPoliza ES NULO FALLARÍA LA QUERY. 
		// 1º. Obtener las garantias de la poliza asociada al caso
		if (!String.isEmpty(intervencion.CAS_LKP_PolizaContrato__c)) {
			List<Garantia_Poliza__c> listaGarantiasPoliza = Util_Poliza_Contrato.queryGarantiasPolizaByPoliza(new Set<Id>{intervencion.CAS_LKP_PolizaContrato__c}).values();
			setGarantiasPoliza = new Set<String>(); 
			System.debug('SiniSondeoProfesionalController: obtenerPosiblesLineasSalida: poliza: '+intervencion.CAS_LKP_PolizaContrato__c);
			for(Garantia_Poliza__c garPol : listaGarantiasPoliza){
				if(!setGarantiasPoliza.contains(garPol.GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c)){
					System.debug('SiniSondeoProfesionalController: obtenerPosiblesLineasSalida: garPol.GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c: '+garPol.GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c);
					setGarantiasPoliza.add(garPol.GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c);
				}   
			}
		}  
		
		Set<Id> idsInvolucrados;
		String query;
		//situacionDanosPropios = arbolDecisionLineasAuxiliar.ADL_SEL_E_Situacion_Danos_Propios__c;
		//otrosDanosPropios = arbolDecisionLineasAuxiliar.ADL_SEL_E_Otros_Danos_Propios__c;
		query = 'SELECT ADL_TXT_S_Com_Auto_Lim_Cobertura__c, ADL_TXT_S_Garantias__c, ADL_TXT_S_Garantias_Enviar_CIA__c, ';
		query += 'ADL_SEL_S_Gremios__c, ADL_SEL_S_Motivo_Rechazo__c, ADL_SEL_S_Motivo_Perito__c, ADL_SEL_S_Tipo_Actuacion_Mult__c, ';
		query += 'ADL_SEL_S_Tipo_Actuacion__c, ADL_LKP_Ay_Argumentario_Rechazo__c, ADL_SEL_S_DocsIndemnizable__c,ADL_SEL_S_DocsIndemnizableSugeridos__c, ';
		query += 'ADL_DIV_S_Franquicia_Fija__c, ADL_POR_S_Franquicia__c, ADL_TXT_S_Garantias_Piden_Perito__c, ADL_SEL_S_Tipo_Carta__c ';
		query += 'FROM Arbol_Decision_Lineas__c WHERE ';
		//1º garantías.!setGarantiasPoliza.isEmpty() && 
			if(!String.isEmpty(grupoCausas)) {
				System.debug(intervencion.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c	);
				query += ' ADL_LKP_Arbol_Decision__r.ADC_LKP_Producto_CIA__c = \''+intervencion.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c+'\' AND ADL_LKP_Arbol_Decision__r.ADC_SEL_Estado__c = \'Activo\' '; 
				query += ' AND  ADL_SEL_E_Grupo_Causa__c = \''+grupoCausas+'\' ';  
				if(!String.isEmpty(tipoAveria)) {
					query += ' AND ADL_SEL_E_Tipo_Averia__c = \''+tipoAveria+'\' ';
				}
				if(!String.isEmpty(detalleAveria)) {
					query += ' AND ADL_SEL_E_Detalle_Averia__c = \''+detalleAveria+'\'';
				}
				if(!String.isEmpty(causaAveria)) {
					query += ' AND ADL_SEL_E_Causa_Averia__c = \''+causaAveria+'\'';
				}
				if(existenDanosPropios) {
					query += ' AND ADL_SEL_E_Danos_Propios__c = \'SI\' AND ADL_SEL_E_Situacion_Danos_Propios__c INCLUDES (\''+situacionDanosPropios+'\') ';
				} else {
					query += ' AND ADL_SEL_E_Danos_Propios__c != \'SI\'';
				}
				System.debug('SiniSondeoProfesionalController: obtenerSalida: otrosDanosPropios: '+otrosDanosPropios);
				if(!String.isEmpty(otrosDanosPropios)) {
					query +=' AND ADL_SEL_E_Otros_Danos_Propios__c INCLUDES (\''+otrosDanosPropios+'\') ';
				}
				if(existenDanosPerjudicado) {
					query += ' AND  ADL_SEL_E_Danos_Perjudicados__c= \'SI\'';
				} else {
					query += ' AND ADL_SEL_E_Danos_Perjudicados__c != \'SI\'';
				}
					query += ' ORDER BY ADL_TXT_S_Garantias__c DESC NULLS LAST';
				listaLineasDecisionObtenidas= (List<Arbol_Decision_Lineas__c>) Database.query(query);
		}
		System.debug('SiniSondeoProfesionalController: obtenerPosiblesLineasSalida: query: '+query);
		System.debug('SiniSondeoProfesionalController: obtenerPosiblesLineasSalida: listaLineasDecisionObtenidas: '+listaLineasDecisionObtenidas);
		return listaLineasDecisionObtenidas;
	}


	/**
	 * Recoge la linea del arbol de decision que tiene mas coincidencias de garantias con las de la poliza
	 *
	 * @param    List<Arbol_Decision_Lineas__c>  lineasSalida
	 * @return       Lineas de salida final.
	 * @see      Arbol_Decision_Lineas__c.
	 */
	public Arbol_Decision_Lineas__c lineaSalidaFinal(List<Arbol_Decision_Lineas__c> lineasSalida){
		Arbol_Decision_Lineas__c lineaRetornoObtenida=new Arbol_Decision_Lineas__c();
		Boolean contieneTodasGarantias;
		Boolean lineaObtenida=false;
		for(Arbol_Decision_Lineas__c lineaAux:lineasSalida) {
			System.debug('SiniSondeoProfesionalController: lineaSalidaFinal: lineaAux: :' + lineaAux.ADL_TXT_S_Garantias__c);
			if(String.isEmpty(lineaAux.ADL_TXT_S_Garantias__c)) {
				lineaRetornoObtenida=lineaAux;
			} else {
				List<String> listaGarantiasDeLinea=new List<String>();
				for(String garantiaDeLinea:lineaAux.ADL_TXT_S_Garantias__c.split(';')) {
					listaGarantiasDeLinea.add(garantiaDeLinea);
				}
				System.debug(listaGarantiasDeLinea);
				System.debug(setGarantiasPoliza.containsAll(listaGarantiasDeLinea));
				
				if(setGarantiasPoliza.containsAll(listaGarantiasDeLinea)) {
					System.debug('Entro');
					lineaRetornoObtenida=lineaAux;
					break; 
				}
			}
		}
		for(String garantiaDePoliza:setGarantiasPoliza) {
			System.debug('SiniSondeoProfesionalController: lineaSalidaFinal: setGarantías: Garantías: '+garantiaDePoliza);
		}
		System.debug('SiniSondeoProfesionalController: lineaSalidaFinal: lineaRetornoObtenida: Garantías: '+lineaRetornoObtenida);
		return lineaRetornoObtenida;
		/*Arbol_Decision_Lineas__c lineaRetorno=null;
		
		//Coger la linea del arbol de decision que tiene mas coincidencias de garantias con las de la poliza
		//Se insertan en un set todos los ids de las lineas de salida
		Set<Id> idsADLSalida = new Set<Id>();
		for(Arbol_Decision_Lineas__c adl : lineasSalida){
			idsADLSalida.add(adl.Id);
		}  
		System.debug('SiniSondeoProfesionalController: lineaSalidaFinal: idsADLSalida: '+idsADLSalida);
		System.debug('SiniSondeoProfesionalController: lineaSalidaFinal: setGarantiasPoliza: '+setGarantiasPoliza);
		if (setGarantiasPoliza != null && !setGarantiasPoliza.isEmpty()){
			//Se recogen las garantias de las lineas de salida.
			Map<Id, Set<String>> mapaAdlGarantiasCoincidentes = garantiasCoincidentesAdl(lineasSalida);
			System.debug('SiniSondeoProfesionalController: lineaSalidaFinal: mapaAdlGarantiasCoincidentes: '+mapaAdlGarantiasCoincidentes);
			//Se recorre la lista de posibles lineas de salida en busca de la salida con mas garantias coincidentes con las de la poliza
			for(Arbol_Decision_Lineas__c adlSalida : lineasSalida){
				if(mapaAdlGarantiasCoincidentes.get(adlSalida.Id) != null){
					if(lineaRetorno == null){
						lineaRetorno = adlSalida;
					}else{
						Integer tamAdlGarCoinc = mapaAdlGarantiasCoincidentes.get(adlSalida.Id).size();
						Integer tamAdlGarCoincSalida = mapaAdlGarantiasCoincidentes.get(lineaRetorno.Id).size();
						
						if(tamAdlGarCoinc > tamAdlGarCoincSalida){
							lineaRetorno = adlSalida;
						}
						//ERROR DE PARAMETRIZACION
						//Si las adl tienen el mismo numero de garantias coincidentes se coge la primera
					}
				}
			}
		}
		System.debug(lineaRetorno);
		return lineaRetorno; */
	}

    private Map<Id, Set<String>> garantiasCoincidentesAdl(List<Arbol_Decision_Lineas__c> lineasSalida){
		Map<Id, Set<String>> mapaRetorno = new Map<Id, Set<String>>();
		if(lineasSalida != null){
			Set<Id> adlNoValidas = new Set<Id>();
			for(Arbol_Decision_Lineas__c adl : lineasSalida){
				// Recorrer todas las garantias de la linea
				if(adl.ADL_TXT_S_Garantias__c != null){
					for(String gar : adl.ADL_TXT_S_Garantias__c.split(';')){
						// Se comprueba si la garantia coincide con alguna de la poliza, ya que todas las garantias de la linea tienen que estar en
						// el conjunto de garantias de la poliza
						if(setGarantiasPoliza.contains(gar)
								&& !adlNoValidas.contains(adl.Id)){
							Set<String> setGarantias;
							if(mapaRetorno.containsKey(adl.Id)){							
								if(!mapaRetorno.get(adl.Id).contains(gar)){
									setGarantias = mapaRetorno.get(adl.Id);
									setGarantias.add(gar);
								}
							}else{
								setGarantias = new Set<String>();
								setGarantias.add(gar);
							}
							if(setGarantias != null){
								// Se insertan en un mapa las garantias coincidentes de cada una de las adl
								mapaRetorno.put(adl.Id, setGarantias);
							}
						}else{
							// Se controlan las garantias no validas para no insertarlas en el mapa de retorno
							if(!adlNoValidas.contains(adl.Id)){
								adlNoValidas.add(adl.Id);
							}
							// Si la linea no es valida, se elimina del mapa
							if(mapaRetorno.containsKey(adl.Id)){
								mapaRetorno.remove(adl.Id);
							}
						}
					}
				}
			}
			// Si el mapa devuelto esta vacio es porque todas las lineas de salida eran invalidas
			if(mapaRetorno.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ninguna de las posibles lineas de salida presenta garantias validas'));
			}
		}
		return mapaRetorno;
	}


    /**
	 * Junta todos los danos de los perjudicados
	 *
	 * @return       Lista con los danos propios y otros danos de los perjudicados
	 * @see      String, Array
	 */
	public String[] recogerDanosPerjudicados(){
		String[] danosPerjudicados = new String[2];
		if(!listaPerjudicados.isEmpty()){
			for(Perjudicado_Siniestro__c perj : listaPerjudicados){
				if(perj.PRJ_SEL_Situacion_Danos__c != null){
					if(danosPerjudicados[0] == null){
						danosPerjudicados[0] = perj.PRJ_SEL_Situacion_Danos__c;
					}else{
						danosPerjudicados[0] += ';' + perj.PRJ_SEL_Situacion_Danos__c;
					}
				}
				if(perj.PRJ_SEL_Otros_Danos__c != null){
					if(danosPerjudicados[1] == null){
						danosPerjudicados[1] = perj.PRJ_SEL_Otros_Danos__c;
					}else{
						danosPerjudicados[1] += ';' + perj.PRJ_SEL_Otros_Danos__c;
					}
				}
			}
		}
		return danosPerjudicados;
	}

    private List<Comentario_caso__c> generarComentariosAutomaticos(){
		//Generar comentarios adjuntos al siniestro
		List<Comentario_caso__c> listaComentarios = new List<Comentario_caso__c>();
		Comentario_caso__c descConfirmacion = new Comentario_caso__c(CMC_LKP_Caso__c = confirmacionEditable.CNF_LKP_ParentId__c, 
				CMC_TXT_Comentario__c = 'Se ha confirmado el siniestro con las siguientes características:\n' + 
				'Grupo de Causa: ' + devolverEtiquetaValor('Confirmacion__c', 'CNF_SEL_Grupo_Causa__c', confirmacionEditable.CNF_SEL_Grupo_Causa__c) + '\n' +
				'Tipo de Avería: ' + devolverEtiquetaValor('Confirmacion__c', 'CNF_SEL_Tipo_Averia__c', confirmacionEditable.CNF_SEL_Tipo_Averia__c) + '\n' +
				'Detalle de la Avería: ' + devolverEtiquetaValor('Confirmacion__c', 'CNF_SEL_Detalle_Averia__c', confirmacionEditable.CNF_SEL_Detalle_Averia__c));
		listaComentarios.add(descConfirmacion);
		if(lineaSalida.ADL_TXT_S_Com_Auto_Lim_Cobertura__c != null){
			Comentario_caso__c limCobertura = new Comentario_caso__c(CMC_LKP_Caso__c = confirmacionEditable.CNF_LKP_ParentId__c, CMC_TXT_Comentario__c = lineaSalida.ADL_TXT_S_Com_Auto_Lim_Cobertura__c);
			listaComentarios.add(limCobertura);
		}
		if(lineaSalida.ADL_DIV_S_Franquicia_Fija__c != null){
			Comentario_caso__c franqFija = new Comentario_caso__c(CMC_LKP_Caso__c = confirmacionEditable.CNF_LKP_ParentId__c, 
					CMC_TXT_Comentario__c = 'El Cliente debe abonar una franquicia fija de ' + lineaSalida.ADL_DIV_S_Franquicia_Fija__c + ', el resto es abonado por la Compañía');
			listaComentarios.add(franqFija);
		}
		if(lineaSalida.ADL_POR_S_Franquicia__c != null){
			Comentario_caso__c porcFranq = new Comentario_caso__c(CMC_LKP_Caso__c = confirmacionEditable.CNF_LKP_ParentId__c, 
					CMC_TXT_Comentario__c = 'El Cliente debe abonar una franquicia con un porcentaje del ' + lineaSalida.ADL_POR_S_Franquicia__c 
					+ ' respecto al total del importe del siniestro, el resto es abonado por la Compañía');
			listaComentarios.add(porcFranq);
		}
		return listaComentarios;
	}

    	public String devolverEtiquetaValor(String objeto, String nombreCampo, String valorCampo){
		String etiquetaRetorno;
		if(objeto != null
				&& nombreCampo != null
				&& valorCampo != null){
			String etiquetaRecogida = Util_Listas_Seleccion.getLabelDesdeAPI(objeto, nombreCampo).get(valorCampo);
			if(etiquetaRecogida != null){
				etiquetaRetorno = etiquetaRecogida;
			}else{
				etiquetaRetorno = valorCampo;
			}
		}
		return etiquetaRetorno;
	}


    	/**
	 * Se introducen movimientos:  
	 * -si es siniestro y cambia a tipo Rechazo en confirmación parcial o total(Acción 2) 
	 * -si es siniestro y cambia tipo(Acción 7)
	 * -si se modifica la causa(Acción 8)
	 * -si se modifican las garantías(Acción 9)
	 * -si se modifica la fecha de confirmación(Acción 19)
	 * -si se modifica el grupo de causa(Acción 45)
	 */
	private void generaMovimientos(){
		List<Case> casoAux = Util_Caso.getCaseById(new Set<Id>{confirmacionEditable.CNF_LKP_ParentId__c}).values();
		//List<Case> casoAux = Util_Caso.queryMapSiniCaso(new Set<Id>{confirmacion.CNF_LKP_ParentId__c},null,1).values();
		//List<Case> casoAux = Util_Siniestro.queryCaso(confirmacion.CNF_LKP_ParentId__c, null, 1);
		if (Util_Siniestro.esSiniestro(casoAux.get(0))){
			/*
            COMENTADO ILS: Esto pasa a SINI_REPARABLE.
            if(tipoCaso != confirmacionEditable.CNF_SEL_Tipo__c){
				Util_Movimientos.compruebaEnviable(confirmacion.CNF_LKP_ParentId__c,confirmacionEditable.CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'7');
				if(confirmacionEditable.CNF_SEL_Tipo__c == label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL || confirmacionEditable.CNF_SEL_Tipo__c == label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_PARCIAL){
					Util_Movimientos.compruebaEnviable(confirmacionEditable.CNF_LKP_ParentId__c,confirmacionEditable.CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'2');
				}	
			} 
			if(causa != confirmacionEditable.CNF_TXT_Sondeo_Causa__c){
				Util_Movimientos.compruebaEnviable(confirmacionEditable.CNF_LKP_ParentId__c,confirmacionEditable.CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'8');
			}
			if(cambioGarantias == true){
				Util_Movimientos.compruebaEnviable(confirmacionEditable.CNF_LKP_ParentId__c,confirmacionEditable.CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'9');
				Util_Movimientos.compruebaEnviable(confirmacionEditable.CNF_LKP_ParentId__c,confirmacionEditable.CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'19');
			}
			if(grupoCausa != confirmacionEditable.CNF_SEL_Grupo_Causa__c){
				Util_Movimientos.compruebaEnviable(confirmacionEditable.CNF_LKP_ParentId__c,confirmacionEditable.CNF_LKP_ParentId__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'45');
			} */
		}
	}


    public PageReference continuar_paso2(){
		PageReference paginaDestino;
		if(errorMostradoMensajeSalidaMostrado) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, mensajeErrorSalida));
		} else {
			try
			{
				System.debug('Salida: '+lineaSalida.ADL_SEL_S_Tipo_Actuacion__c);
				if(lineaSalida.ADL_SEL_S_Tipo_Actuacion__c == '9' || lineaSalida.ADL_SEL_S_Tipo_Actuacion__c=='1'  || lineaSalida.ADL_SEL_S_Tipo_Actuacion__c=='5') {
					paginaDestino=Page.SiniReparableConfirmacion;
					paginaDestino.getParameters().put('Id',confirmacionEditable.CNF_LKP_ParentId__c);															 
					paginaDestino.getParameters().put('numeroGremiosArbolSalida', String.valueOf(numeroGremiosSalida));
					paginaDestino.getParameters().put('idConfirmacion',confirmacionEditable.Id);
					paginaDestino.getParameters().put('fase','CONFIRMACION');
				} else {
					paginaDestino= new PageReference('/'+confirmacionEditable.CNF_LKP_ParentId__c);
					//Click to Call. Se cogería el AccountID del caso. para que llame al cliente.
					Callout_ClickToCall.Resultado res =  Util_Click2Call.solicitarLlamadaClick2Call(Label.RECHAZO_EN_CONFIRMACION, intervencion.Id, Label.Provicional_Telefono_Cliente);
				}
				//Para que navege, quitar al subir. 
				/*paginaDestino=Page.SiniReparableConfirmacion;
				paginaDestino.getParameters().put('Id',confirmacionEditable.CNF_LKP_ParentId__c);
				paginaDestino.getParameters().put('fase','CONFIRMACION'); */
				//paginaDestino.setRedirect(true);
			} catch(DmlException e){
																		   
				system.debug(e.getStackTraceString());
	      	  	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				}
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
     		}
			catch(Exception e)
			{
																		   
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
				system.debug(e.getStackTraceString());
			}
		}
		paginaDestino.setRedirect(true);
		System.debug(paginaDestino);
		return paginaDestino;
	}


	public void continuar_paso1() {
		System.Savepoint guardado;
		try {
			guardado = Database.setSavepoint();
			List<Garantia_Siniestro__c> listaGarantiasCaso=Util_Siniestro.queryGarantiasExistentes(new set<Id>{intervencion.Id}).values();
			List<Garantia_Siniestro__c> listaGarantiasConfirmacionApertura=new List<Garantia_Siniestro__c>();
			List<Garantia_Siniestro__c> listaGarantiasConfirmacionProfesional=new List<Garantia_Siniestro__c>();
			Confirmacion__c confirmacionApertura=new Confirmacion__c(); 
			 
			if(!listaConfirmacionesToUpsert.isEmpty()) {
				Database.upsert(listaConfirmacionesToUpsert);
			}
			System.debug('SiniSondeoProfesionalController: continuar_paso1: listaWorkOderToUpsert: '+listaWorkOderToUpsert);
			if(!listaWorkOderToUpsert.isempty()) {
				Database.upsert(listaWorkOderToUpsert);
			}
			System.debug('SiniSondeoProfesionalController: continuar_paso1: confirmacionEditalbe: '+confirmacionEditable);
			System.debug('SiniSondeoProfesionalController: continuar_paso1: salidaSeleccionada: '+salidaSeleccionada);
			confirmacionEditable.CNF_SEL_Tipo__c=salidaSeleccionada;
			upsert confirmacionEditable;
			upsert intervencion;
			if(!listaPerjudicados.isEmpty()){
				delete listaPerjudicados;
			}	

			//Recupero las Confirmaciones correspondientes.
			for(Confirmacion__c confirmacionAux:listaConfirmacionesToUpsert) {
				if(mapRecordTypes.get(Label.RT_CNF_Apertura_Finalizada).Id==confirmacionAux.RecordTypeId) {
					confirmacionApertura=confirmacionAux;
				}
			}
			//Relleno las garantías de la Apertura.	
			for(Garantia_Siniestro__c garantia: listaGarantiasCaso){
				listaGarantiasConfirmacionApertura.add(new Garantia_Siniestro__c(GSIN_LKP_Garantia__c = garantia.GSIN_LKP_Garantia__c, GSIN_LKP_Confirmacion__c = confirmacionApertura.Id));
			}
			//Inserto las garantías de las Apertura.
			if(!listaGarantiasConfirmacionApertura.isEmpty()) {
				Database.upsert(listaGarantiasConfirmacionApertura);
			}

			//Relleno la garantía Editable
			for(Garantia__c garantia:listaGarantiasObtenidasLinea) {
				listaGarantiasConfirmacionProfesional.add(new Garantia_Siniestro__c(GSIN_LKP_Garantia__c = garantia.Id, GSIN_LKP_Confirmacion__c = confirmacionEditable.Id));
			}

			//Inserto las garantías de la copia del Profesional.
			if(!listaGarantiasConfirmacionProfesional.isEmpty()) {
				Database.upsert(listaGarantiasConfirmacionProfesional);
			}		
		} catch (Exception e) {						  
			Database.rollback(guardado);
			mensajeErrorSalida=e.getMessage();
			errorMostradoMensajeSalidaMostrado=true;
		} 
	}

	private Boolean validarDanosPropios() {
		String resultado='';
		if(existenDanosPropios) {
			for(String danosAux: mapSeleccionDanosPropios.keySet()){
				if(mapSeleccionDanosPropios.get(danosAux)){
					resultado += resultado + ';'; 
				}
			}
			for(String otrosDanosAux: mapSeleccionOtrosDanos.keySet()){
				if(mapSeleccionOtrosDanos.get(otrosDanosAux)){
					resultado += resultado + ';'; 
				}
			}
		}
		return String.isEmpty(resultado);
	}

	private Boolean validarTerceroCausante() {
		Boolean existenErrores=false;
		//validar Tercero Causante.
		List<String> datosOblNoRellenosTercero = new List<String>();
		if(terceroCausante){
			if(String.isEmpty(confirmacionEditable.CNF_TXT_Nombre__c)){
				existenErrores = true;
			} else if(String.isEmpty(confirmacionEditable.CNF_TXT_Codigo_Postal__c)){
				existenErrores = true;
			}
			if(String.isEmpty(confirmacionEditable.CNF_TFN_Telefono_1__c) || validarTelefono(confirmacionEditable.CNF_TFN_Telefono_1__c)){
				existenErrores = true;
			}		
		}
		return existenErrores;
	}
}