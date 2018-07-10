/**
 * Clase controladora de la Visualforce "CierreReclamaciones" encargada de gestionar la creación de reclamaciones
 * 
 * @author EVERIS
 */
public without sharing class CierreReclamaciones {
	
	public Case reclamacion;
	public Case reclCampos;
	public ApexPages.standardController controlador;
	
	public Boolean todoCorrecto {get;set;}
	public String comentario {get;set;}
	
	/**
    * 
 	* Constructor de la clase
 	* 
 	*/  
	public CierreReclamaciones(ApexPages.standardController stdCtr){

		todoCorrecto = true;
		PageReference paginaActual = ApexPages.currentPage();
		if (!paginaActual.getParameters().containsKey('id')){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
			todoCorrecto = false;
		} else {

			Id idReclamacion = stdCtr.getRecord().Id;

			List<Case> recAux = Util_Caso.getCaseById(new Set<Id>{idReclamacion}).values();
			//List<Case> recAux = Util_Caso.getMapaCasos(new Set<Id>{idReclamacion}).values();
			//List<Case> recAux = [Select id, Status, CAS_SEL_Padre_reclamacion__c, CAS_SEL_Reclamacion__c, CAS_SEL_Naturaleza__c,CAS_SEL_Motivo_de_Cierre__c,CAS_SEL_Comunicador_Recl__c from Case where Id = :idReclamacion];
			
			if(!recAux.isEmpty()){
				reclCampos = recAux.get(0);
				reclamacion = (Case)stdCtr.getRecord();
					
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
				todoCorrecto = false;
			}
			
			controlador = stdCtr;
		}

	}
	
	public List<SelectOption> getOpcionesEstado(){
		List<SelectOption> options = new List<SelectOption>();
		
		Set<String> validos = new Set<String>{Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR,Label.CAS_ESTADO_CERRADO_FACTURADO};
		
		Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();	
		for(Schema.PicklistEntry f : ple){
			if(validos.contains(f.getValue())){
				options.add(new SelectOption(f.getValue(),f.getLabel()));
			}
		}
		
		return options;
	}
	
	public List<SelectOption> getOpcionesCierre(){
		List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('','--Ninguno--'));
		
		if(reclCampos == null)
			return options;
			
		system.debug('-----------IN');
		
		//TODO: Coger los metadatos cuando estén
		//TODO: Cambiar los valores quien comunica para añadir el valor de analizado no procedente
		
		String tipologia = reclCampos.CAS_SEL_Padre_reclamacion__c;
		String fundada = reclCampos.CAS_SEL_Reclamacion__c;
		String naturaleza = reclCampos.CAS_SEL_Naturaleza__c;
		
		String clave = tipologia+fundada+naturaleza;
		
		
		system.debug('-------clave: '+ clave);
		
		List<Causa_de_la_reclamacion__mdt> opciones = Util_Metadatos.mapaCausaReclClave.get(clave);
		
		if(opciones != null && !opciones.isEmpty()){
			
			Set<String> validos = new Set<String>();
			
			for(Causa_de_la_reclamacion__mdt causa: opciones){
				validos.add(causa.MTD_CAUSA_TXT_Causa_de_la_reclamacion__c);
			}
				
			Schema.DescribeFieldResult fieldResult = Case.CAS_SEL_Motivo_de_Cierre__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

			for(Schema.PicklistEntry f : ple){
				if(validos.contains(f.getValue())){
					options.add(new SelectOption(f.getValue(),f.getLabel()));
				}
			}
			
		}
		
		
		if(reclCampos.CAS_SEL_Comunicador_Recl__c == '002' || reclCampos.CAS_SEL_Comunicador_Recl__c == '003'){
			options.add(new SelectOption(Label.CAS_MOTIVO_DE_CIERRE_RECLAMACION3,'Analizado no procedente, sin imputar'));
		}
		
		return options;
	}
	
	public PageReference guardar(){
		
		system.debug('------status: '+reclamacion.Status);
		system.debug('------Label.CAS_ESTADO_CERRADO_FACTURADO: '+Label.CAS_ESTADO_CERRADO_FACTURADO);
		system.debug('------CAS_SEL_Motivo_de_Cierre__c: '+reclamacion.CAS_SEL_Motivo_de_Cierre__c);
		
		if(reclamacion.Status == Label.CAS_ESTADO_CERRADO_FACTURADO && String.isBlank(reclamacion.CAS_SEL_Motivo_de_Cierre__c)){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Se debe rellenar la causa de la reclamación'));
			return null;	
		}
		
		List<WorkorderLineItem> partidas = Util_caso.getListaPartidasCaso(reclamacion.Id);
		Boolean partidasImputadas = true;
        system.debug(partidas + 'partidaaaaaaas');
		system.debug(reclamacion + ' reclamacion de clase antes de guardar1');
		if(!partidas.isEmpty()){
			for(WorkOrderLineItem woli : partidas){
				if((woli.PAR_DIV_Importe_a_Imputar_prof1__c == null || woli.PAR_DIV_Importe_a_Imputar_prof1__c == 0)
					&& (woli.PAR_DIV_Importe_a_Imputar_prof2__c == null || woli.PAR_DIV_Importe_a_Imputar_prof2__c == 0)
					&& (woli.PAR_DIV_Importe_a_Imputar_prof3__c == null || woli.PAR_DIV_Importe_a_Imputar_prof3__c == 0)
					&& (woli.PAR_DIV_Importe_a_Imputar_gestor1__c == null || woli.PAR_DIV_Importe_a_Imputar_gestor1__c == 0)
					&& (woli.PAR_DIV_Importe_a_Imputar_gestor2__c == null || woli.PAR_DIV_Importe_a_Imputar_gestor2__c == 0)
					&& (woli.PAR_DIV_Importe_a_Imputar_gestor3__c == null || woli.PAR_DIV_Importe_a_Imputar_gestor3__c == 0)
					&& woli.PAR_LKP_Imputar_a_prof1__c == null
					&& woli.PAR_LKP_Imputar_a_prof2__c == null
					&& woli.PAR_LKP_Imputar_a_prof3__c == null
					&& woli.PAR_LKP_Imputar_a_gestor1__c == null
					&& woli.PAR_LKP_Imputar_a_gestor2__c == null
					&& woli.PAR_LKP_Imputar_a_gestor3__c == null){
						
					partidasImputadas = false;
					break;
				}
			}
		} else {
			if(reclCampos.CAS_LKP_Responsable_Reclamacion__c == null && reclCampos.CAS_SEL_Reclamacion__c == Label.CAS_RECLAMACION_FUNDADA){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha seleccionado ningún responsable de la reclamación'));
				return null;
			}
		}
		
		
		if(!partidasImputadas){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Existen partidas para las que no se ha realizado imputación'));
			return null;
		}
		
		//PREV
		/*
		List<Propuesta_de_evento__c> eventos = [Select Id from Propuesta_de_evento__c where (EV_AB_LKP_Caso__c = :reclamacion.Id or EV_AB_LKP_Orden_de_Trabajo__r.CaseId = :reclamacion.Id) and EV_AB_LKP_Propuesta_de_Evento_Economico__c = null and EV_AB_LKP_Abono__c = null and EV_AB_SEL_Estado__c != :Label.EV_AB_ESTADO_APROBADO and EV_AB_SEL_Estado__c != :Label.EV_AB_ESTADO_RECHAZADO];
		List<Propuesta_de_abono__c> abonos = [Select id from Propuesta_de_abono__c where (AB_LKP_Caso__c = :reclamacion.Id or AB_LKP_Orden_de_Trabajo__r.CaseId = :reclamacion.Id) and AB_SEL_Estado__c != :Label.EV_AB_ESTADO_APROBADO and AB_SEL_Estado__c != :Label.EV_AB_ESTADO_RECHAZADO];
		*/
		//NEW
		Set<Id> setIdsReclamacion = new Set <Id>{reclamacion.Id};
		List<Propuesta_de_evento__c> eventos = Util_Propuesta_de_evento.queryMap_Propuesta_de_EventoBy_EV_AB_LKP_Caso_Or_Orden_de_Trabajo_r_CaseId_And_PropEvEconomico_null_And_LKPAbono_null_And_EstadoNoAprobado_And_EstadoNoRechazado(setIdsReclamacion).values();
		List<Propuesta_de_abono__c> abonos = Util_Propuesta_de_abono.queryMap_Propuesta_de_AbonoBy_EV_AB_LKP_Caso_Or_Orden_de_Trabajo_r_CaseId_And_PropEvEconomico_null_And_LKPAbono_null_And_EstadoNoAprobado_And_EstadoNoRechazado(setIdsReclamacion).values();
		//END_NEW
		
		
		Boolean enProceso = true;
		
		if(!eventos.isEmpty()){
			Map<Id,Boolean> eventosLocked = Approval.isLocked(eventos);
			
			for(Boolean isLocked: eventosLocked.values()){
				enProceso = enProceso && isLocked;
			}
		}
		
		if(!abonos.isEmpty()){
			Map<Id,Boolean> abonosLocked = Approval.isLocked(abonos);
			
			for(Boolean isLocked: abonosLocked.values()){
				enProceso = enProceso && isLocked;
			}
		}
		
		if(!enProceso){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Existen eventos o abonos para los que no se ha lanzado el proceso de aprobación'));
			return null;
		}
		system.debug(reclCampos.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + ' reclamacion de casos');
		if(String.isBlank(reclCampos.CAS_SEL_Conformidad_del_Cliente__c) 
		|| (reclCampos.CAS_SEL_Conformidad_del_Cliente__c == 'NO LOCALIZADO' 
		&& (String.isBlank(reclCampos.CAS_SEL_Conformidad_del_Cliente_2__c) || (reclCampos.CAS_SEL_Conformidad_del_Cliente_2__c == 'NO LOCALIZADO' && reclCampos.CAS_LKP_Compania__r.CUE_TXT_Identificador__c != Label.IDE_MEMBERSHIP))
		&& String.isBlank(reclCampos.CAS_SEL_Conformidad_del_Cliente_3__c))){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se puede cerrar la reclamación, no se ha confirmado con el cliente'));
			return null;
		} 
		
		if(String.isBlank(reclCampos.CAS_TXT_Gestor_Cierra_Reclamacion__c))
			reclamacion.CAS_TXT_Gestor_Cierra_Reclamacion__c = UserInfo.getName();
			
		PageReference paginaRedireccion = controlador.save();
		if(!String.isBlank(comentario)){
			Comentario_caso__c comentarioCasoInsertar = Util_Caso.crearComentarioCaso(reclamacion.Id, comentario);
			insert comentarioCasoInsertar;
		}
		
		return paginaRedireccion;
	}
    
}