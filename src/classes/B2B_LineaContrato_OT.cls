/**
 * Clase controladora de la Visualforce "B2B_LineaContrato_OT" encargada de seleccionar Líneas de Contrato para una de la Orden de Trabajo.
 * 
 * @author EVERIS
 */
public without sharing class B2B_LineaContrato_OT {
	public Case caso {get; set;}
	public Boolean esB2C {get; set;}
	private String solicitudExistente;
	public String fase {get; set;}
	private String paginaRetorno;
	public WorkOrder ordenTrabajo {get; set;}
	public String gremio {get; set;}
	public Integer tipoCaso {get; set;}//Almacena 1 si es un caso y un 2 si es un servicio B2B/B2B2C
	public Account cuenta {get; set;}
	public List<ResultadoLC> listaResultadoLC {get; set;}
	private Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC;
	private Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLCInicial;

	/**
	 * Constructor de la clase.
	 * 
	 * @param stdCtr: Controlador estándar de la visual
	 */ 
	public B2B_LineaContrato_OT(ApexPages.standardController stdCtr){
		PageReference paginaActual = ApexPages.currentPage();
		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}
		if(paginaActual.getParameters().containsKey('solicitudExistente')){
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}
		if(paginaActual.getParameters().containsKey('retorno')){
			paginaRetorno = paginaActual.getParameters().get('retorno');
		}		
		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{stdCtr.getRecord().Id}).values();
			if(listaCasos.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
			else {
				caso = listaCasos.get(0);
				esB2C = caso.CAS_FOR_EsB2C__c;
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
				List<WorkOrder> listaOT = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{paginaActual.getParameters().get('idOrdenTrabajo')}).values();
				if(listaOT.isEmpty()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				}
				else {
					ordenTrabajo = listaOT.get(0);
					gremio = ordenTrabajo.OTR_SEL_Gremio__c;
					buscarLineasDeContrato();
				}

				for(ResultadoLC result : listaResultadoLC){
					if(result.seleccionado){
						dirLCInicial = result.dirLineaContrato;
					}
				}
			}
		}
	}//FIN CONSTRUCTOR	

	/**
      * Busca Lineas de Contrato del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c.
	 *
      */ 
	public void buscarLineasDeContrato(){
		listaResultadoLC = new List<ResultadoLC>();
		system.debug('***** gremio: ' + gremio);
		if(gremio != null){
			List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaDirLC = Util_Direcciones_B2B_B2B2C_Lineas.getLCsCorrectDisponiblesPorUrgente(new Set<Id>{caso.AccountId},new Set<String>{Label.RT_LIN_CON_CORRECTIVO},new Set<String>{ordenTrabajo.OTR_SEL_Gremio__c},true).values();
			//List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaDirLC = Util_B2B.getLCsCorrectDisponibles(ordenTrabajo, caso.AccountId, false, true, false);
			if(!listaDirLC.isEmpty()){
				for(Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLC : listaDirLC){
					if(dirLC.DLC_LKP_Linea_de_Contrato__c == ordenTrabajo.OTR_LKP_Linea_Contrato__c){
						listaResultadoLC.add(new ResultadoLC(true, dirLC));
					}
					else if(dirLC.DLC_NUM_Servicios_restantes__c == null || dirLC.DLC_NUM_Servicios_restantes__c > 0){
						listaResultadoLC.add(new ResultadoLC(false, dirLC));
					}
				}

				system.debug('***** listaResultadoLC : ' + listaResultadoLC);
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_NO_LINEAS_CONTRATO_GREMIO));
			}
		}
	}

	/**
      * Guarda el proceso actual en la página B2B_LineaContrato_OT.
	 *
      * @return página a navegar tras guardar
      */ 
	public PageReference guardar(){
		Boolean cambioRealizado = false;
		system.Savepoint puntoGuardado = Database.setSavepoint();
		PageReference paginaRedireccion = null;
		Id idLinConSelec = null;
		Integer limiteServLCSelec = 0;
		Boolean ilimitado = false;
		for(ResultadoLC result : listaResultadoLC){
			if(result.seleccionado){
				if(result.dirLineaContrato.DLC_NUM_Servicios_restantes__c != null){
					limiteServLCSelec = Integer.valueOf(result.dirLineaContrato.DLC_NUM_Servicios_restantes__c);					
				}
				else {
					ilimitado = true;
				}
				idLinConSelec = result.dirLineaContrato.DLC_LKP_Linea_de_Contrato__c;
				dirLC = result.dirLineaContrato;
				break;
			}
		}
		try {
			system.debug('***** dirLC : ' + dirLC);
			if(idLinConSelec == null){
				ordenTrabajo.OTR_LKP_Linea_Contrato__c = idLinConSelec;
				update ordenTrabajo;
				cambioRealizado = true;
			}
			else {
				if(ilimitado || limiteServLCSelec > 0){
					ordenTrabajo.OTR_LKP_Linea_Contrato__c = idLinConSelec;
					update ordenTrabajo;
					cambioRealizado = true;
				}
				else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_SALDO_SERV_AGOTADO));	
				}
			}
			if(cambioRealizado){
				paginaRedireccion = volver();
			}
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
		}
		return paginaRedireccion;
	}

	/**
      * Vuelve del proceso actual en la página B2B_LineaContrato_OT.
      * 
      * @return página a navegar tras volver
      */ 
	public PageReference volver(){
		PageReference paginaRedireccion = new PageReference(paginaRetorno);
		paginaRedireccion.getParameters().put('id', caso.Id);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver()

	/**
      * [PENDIENTE]
      * 
      */
	public class ResultadoLC {
		public Boolean seleccionado {get; set;}
		//public Linea_Contrato__c lineaContrato {get; set;}
		public String gremioLC {get; set;}
		public Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLineaContrato {get; set;}
		public ResultadoLC(Boolean seleccionado, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLineaContrato){
			this.seleccionado = seleccionado;
			this.dirLineaContrato = dirLineaContrato;
			this.gremioLC = Util_Listas_Seleccion.getLabelDesdeAPI('Linea_Contrato__c', 'LDC_SEL_Gremio__c').get(dirLineaContrato.DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c); 
		}
	}
}