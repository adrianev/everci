/**
 * Clase controladora de la Visualforce "AnulacionReclamaciones" encargada de gestionar la anulación de reclamaciones
 * 
 * @author EVERIS
 */
public without sharing class AnulacionReclamaciones {
	
	public Case reclamacion;
	public Case reclCampos;
	public List <WorkOrder> serviciosAsociados = new List <WorkOrder>();
	public ApexPages.standardController controlador;	
	public Boolean todoCorrecto {get;set;}

    /**
    * 
    * Constructor de la clase
    * 
    */  
    public AnulacionReclamaciones(ApexPages.standardController stdCtr){
		todoCorrecto = true;
		PageReference paginaActual = ApexPages.currentPage();
		if (!paginaActual.getParameters().containsKey('id')){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
			todoCorrecto = false;
		} else {

			Id idReclamacion = stdCtr.getRecord().Id;
			
			List<Case> recAux = Util_Caso.getCaseById(new Set<Id>{idReclamacion}).values();
			//List<Case> recAux = Util_Caso.getMapaCasos(new Set<Id>{idReclamacion}).values();
			//List<Case> recAux = [Select Id, Status, CaseNumber, CAS_SEL_Motivo_anulacion_reclamacion__c, CAS_NUM_Contador_Analisis__c, CAS_DAT_Fecha_Modificacion_Estado__c FROM Case WHERE Id = :idReclamacion];
			
			if(!recAux.isEmpty()){
				
				reclCampos = recAux.get(0);
				reclamacion = (Case)stdCtr.getRecord();
				serviciosAsociados = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordType(new Set<Id>{idReclamacion},new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)}).values();
				//serviciosAsociados = Util_Orden_Trabajo.queryOT(null,idReclamacion,'RecordTypeId = \''+Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)+'\'');
				//serviciosAsociados = [Select Id, Status FROM WorkOrder WHERE RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA) AND CaseId = :idReclamacion];
					
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
				todoCorrecto = false;
			}
			
			controlador = stdCtr;
		}    
    }
    
	public List<SelectOption> getOpcionesAnulacion(){
		List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('','--Ninguno--'));
		options.add(new SelectOption(Label.CAS_MOTIVO_DE_ANULACION_RECLAMACION2,'Abierta por error del gestor se debe gestionar por el siniestro'));
		options.add(new SelectOption(Label.CAS_MOTIVO_DE_ANULACION_RECLAMACION3,'Abierta por error hay otra reclamación en curso por este motivo'));
		options.add(new SelectOption(Label.CAS_MOTIVO_DE_ANULACION_RECLAMACION4,'Abierta por error no es una solicitud del asegurado'));
		
		return options;
	}
	
	public PageReference guardar(){
		
		PageReference paginaRedireccion = null;
		Boolean servicioNoAnulado = false;
		String mensajeError = '';
		
		system.debug('------CAS_SEL_Motivo_anulacion_reclamacion__c: '+reclamacion.CAS_SEL_Motivo_anulacion_reclamacion__c);
		
		if(!serviciosAsociados.isEmpty()){
			for (WorkOrder wo: serviciosAsociados){
				if(wo.Status != Label.OTR_ESTADO_ANULADO && wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO && wo.Status != Label.OTR_ESTADO_ANULADO_POR_PROF){
					servicioNoAnulado = true;
					if(wo.Status == Label.OTR_ESTADO_CERRADO || wo.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO || wo.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN){
						mensajeError = 'No es posible anular esta reclamación ya que uno de los servicios asociados a ella se encuentra en estado "Cerrado".';
						break;
					} else {
						mensajeError = 'Para poder anular esta reclamación, todos los servicios asociados a ella deben estar en estado anulado. Por favor, revise el estado de los servicios citados.';
					}
				}
			}
		}
		
		if(String.isBlank(reclamacion.CAS_SEL_Motivo_anulacion_reclamacion__c)){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Debe seleccionar un motivo de anulación.'));
			return null;
			
		} else {
			if(servicioNoAnulado == true){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, mensajeError));
				return null;	
			} else {
				system.debug('------------------------Se puede anular el caso');		
				reclamacion.Status = Label.CAS_ESTADO_ANULADO;
				system.debug('------------------------reclamacion.Status: ' + reclamacion.Status);					
				paginaRedireccion = controlador.save();
			}
		}
				
		return paginaRedireccion;
	}
}