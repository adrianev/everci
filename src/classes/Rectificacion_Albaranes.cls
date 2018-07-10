/**
 * Clase controladora de la Visualforce "Rectificacion_Albaranes" encargada de gestionar los gremios de un Servicio B2B/B2B2C.
 * 
 * @author EVERIS
 */
public without sharing class Rectificacion_Albaranes {

	public WorkOrder ot {get; set;}
	public List<SelectOption> listaMotivos {get; set;}
	public List<SelectOption> listaPenalizaciones {get; set;}
	public String motivo {get; set;}
	public String penalizacion {get; set;}
	public String comentario {get; set;}
	public String comentarioAuditoria {get; set;}
	
	public Rectificacion_Albaranes(ApexPages.standardController stdCtr){
		PageReference paginaActual = ApexPages.currentPage();
		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			List<WorkOrder> listaOts = new List<WorkOrder>(Util_Orden_Trabajo.queryMapOTById(new Set<Id>{stdCtr.getRecord().Id}).values());
			//List<WorkOrder> listaOts = new List<WorkOrder>(Util_Orden_Trabajo.queryOT(stdCtr.getRecord().Id,null,null));
			/*List<WorkOrder> listaOts = new List<WorkOrder>([SELECT Id,
			                                                	OTR_LKP_Recurso_Servicio__c,
			                                                	ParentWorkOrderId,
			                                                	CaseId,
			                                                	ParentWorkOrder.WorkOrderNumber, 
																ParentWorkOrder.OTR_FOR_DT__c,
																OTR_FOR_Codigo_Profesional__c,
																OTR_LKP_Recurso_Servicio__r.Name,
																ParentWorkOrder.OTR_RES_Liquidar_prof_AI__c,
																OTR_RES_Liquidar_prof_AI__c,
																OTR_SEL_Motivo_de_rectificacion__c,
																OTR_SEL_Penalizacion__c,
																OTR_TXT_rectificacion__c
																FROM WorkOrder
																WHERE id = :stdCtr.getRecord().Id]);*/
			if(!listaOts.isEmpty()){
				ot = listaOts.get(0);
                system.debug(ot + ' ot');
				listaMotivos = getPicklistData ('OTR_SEL_Motivo_de_rectificacion__c');
				listaPenalizaciones = getPicklistData('OTR_SEL_Penalizacion__c');
				motivo = ot.OTR_SEL_Motivo_de_rectificacion__c;
				penalizacion = ot.OTR_SEL_Penalizacion__c;
				comentario = ot.OTR_TXT_rectificacion__c;
				comentarioAuditoria = ot.OTR_TXT_Comentario_Auditoria__c;
				
				ot.OTR_DIV_Importe_nuevo__c = ot.OTR_RES_Liquidar_prof_AI__c;
				ot.OTR_DIV_Importe_original__c = ot.ParentWorkorder.OTR_RES_Liquidar_prof_AI__c;
				
				ot.OTR_DIV_Importe_diferencia__c =  ot.ParentWorkorder.OTR_RES_Liquidar_prof_AI__c -ot.OTR_RES_Liquidar_prof_AI__c; 
				
				if(ot.OTR_DIV_Importe_diferencia__c < 10){
					penalizacion = 'No procede';
				} else if(ot.OTR_DIV_Importe_diferencia__c < 30){
					penalizacion = '10,00€';
				} else if(ot.OTR_DIV_Importe_diferencia__c < 90){
					penalizacion = '40,00€';
				} else{
					penalizacion = '90,00€';
				}
				
			}
		}
	}
	
	/** 
	 * Metodo Para recuperar los valores de una pickList de WO
	 * @param nombreCampo:nombre API del campo
	 * @return devuelve una lista de tipo SelectOption que contiene los valores de la pickList
	 */
	public List<SelectOption> getPicklistData(String nombreCampo){
	  List<SelectOption> options = new List<SelectOption>();
	  options.add(new SelectOption('', '--Ninguno--'));
	  DescribeSObjectResult obj = Schema.getGlobalDescribe().get('WorkOrder').getDescribe();
	  DescribeFieldResult campo = obj.fields.getMap().get(nombreCampo).getDescribe();    
	  for(Schema.PicklistEntry valor : campo.getPicklistValues()){
		  options.add(new SelectOption(valor.getLabel(), valor.getValue()));
	  }
	  return options;
	}
	
	/** 
	 * Metodo para redirigir a la OT principal y actualizar los campos relacionados con la rectificación
	 * @return devuelve un PageReference para volver al padre
	 */
	public PageReference aceptar(){
		List<WorkOrder> actualizar = new List<WorkOrder>();
		PageReference redireccion = null;
		if(motivo == null || penalizacion == null || comentario == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
		}
		else {
			ot.OTR_SEL_Motivo_de_rectificacion__c = motivo;
			ot.OTR_SEL_Penalizacion__c = penalizacion;
			ot.OTR_TXT_rectificacion__c = comentario;
			ot.OTR_TXT_Comentario_Auditoria__c = comentarioAuditoria;
			actualizar.add(ot);
			if(!actualizar.isEmpty()) {
			//	Baipas.establecerVariableControl();
				update actualizar;
				//Baipas.deshabilitarVariableControl();
			}
			
			redireccion = new PageReference('/' +ot.Id);
			redireccion.setRedirect(true);
		}
		return redireccion;
	}
	
	/** 
	 * Metodo para volver a CPQ
	 * @return devuelve un PageReference para volver a CPQ
	 */
	public PageReference volver(){
		PageReference redireccion = new PageReference('/apex/'+Label.VF_QUOTE_COPY);
		redireccion.getParameters().put('idWorkO',ot.Id);
		redireccion.getParameters().put('id',ot.CaseId);
		redireccion.getParameters().put('retorno','/'+ot.Id);
		redireccion.getParameters().put('inline','1');
		redireccion.setRedirect(true);
		return redireccion;
	}
}