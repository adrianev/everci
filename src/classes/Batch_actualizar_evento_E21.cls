/** 
    Clase que implementa un proceso batch configurable para la adición de 10 euros en el importe del evento E21 hasta que cambie de estado
    @author everis
    @version 1.0

 */
global without sharing class Batch_actualizar_evento_E21 implements Schedulable{

	global WorkOrder wo;
	global DateTime cambioSemaforo;

	global Batch_actualizar_evento_E21(WorkOrder wo, DateTime cambioSemaforo){
		this.wo = wo;
		this.cambioSemaforo = cambioSemaforo;
	}

	global void execute(SchedulableContext ctx) {
		String jobId = ctx.getTriggerId();
		
		List<Workorder> temp = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).values();
		//List<Workorder> temp = [Select id,OTR_TXT_Estado_Anterior__c,Status, OTR_LKP_Recurso_Servicio__c from workorder where id = :wo.Id];

		if(!temp.isEmpty()){

			Workorder woActualizada = temp.get(0);
	
			List<Propuesta_de_Evento__c> eventoE21List = Util_Abonos_Y_Eventos.getPropuestaEventoByWorkOrderAndDescripcion(new Set<Id>{wo.Id},new Set<String>{'E21'}).values();
			/*List<Propuesta_de_Evento__c> eventoE21List = new List<Propuesta_de_Evento__c>([
				SELECT Id, EV_AB_DIV_Importe_profesional__c FROM Propuesta_de_Evento__c WHERE EV_AB_LKP_Orden_de_Trabajo__c = :wo.Id
				AND EV_AB_SEL_Descripcion__c = 'E21']);*/
			Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
			Long dias;
			Double importe;
			//if(eventoE21List.isEmpty() && (wo.OTR_TXT_Estado_Anterior__c == null || wo.OTR_TXT_Estado_Anterior__c == wo.Status)){
			if(eventoE21List.isEmpty() && (woActualizada.Status == wo.Status)){
				evento.EV_AB_LKP_Imputar_a_profesional__c = wo.OTR_LKP_Recurso_Servicio__c;
				evento.EV_AB_DIV_Importe_profesional__c = decimal.valueOf(Label.IMPORTE_EVENTO_E21_INICIAL);
				evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
				evento.EV_AB_SEL_Descripcion__c = 'E21';
				evento.EV_AB_LKP_Orden_de_Trabajo__c = wo.Id;
				evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
				evento.EV_AB_SEL_Estado__c = '02';
				evento.EV_AB_LKP_Caso__c = wo.CaseId;
				evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
				evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;
	
				insert evento;
	
				/*evento.EV_AB_TXT_Identificador__c = evento.Name;
	
				update evento;*/
	
				/*wo.OTR_TXT_Estado_Anterior__c = wo.Status;
	
				update wo;*/
	
			//}else if(!eventoE21List.isEmpty() && wo.OTR_TXT_Estado_Anterior__c == wo.Status){
			}else if(!eventoE21List.isEmpty() && woActualizada.Status == wo.Status){
				evento = eventoE21List.get(0);
				//dias = system.now().Date().daysBetween(fechaSemaforo.Date());
				importe = evento.EV_AB_DIV_Importe_profesional__c + decimal.valueOf(Label.IMPORTE_EVENTO_E21_SUCESIVO);
				evento.EV_AB_DIV_Importe_profesional__c = importe;
	
				Update evento;
				
			}else{
				System.abortJob(jobId);
			}
		} else {
			System.abortJob(jobId);
		}
	}
}