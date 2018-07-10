/**
 * Clase controladora de la Visualforce "CaptureSignature" encargada de guardar firmas.
 * 
 * @author EVERIS
 */
global without sharing class CaptureSignature {
	
	public ServiceAppointment cita {get; set;}
	public WorkOrder ordenTrabajo {get; set;}
	public String tipoFirma {get; set;}
	private PageReference paginaRedireccion;
	
	public CaptureSignature(){
		PageReference paginaActual = ApexPages.currentPage();
		System.debug('*********paginaActual.getParameters(): ' + paginaActual.getParameters());
		cita = Util_Cita_Servicio.getMapCitasById(new Set<Id>{paginaActual.getParameters().get('idCita')}).get(paginaActual.getParameters().get('idCita'));
		if(cita != null) {
			//cita = listaCitasAux.get(0);
			system.debug('[AMC] cita de servicio' + cita);
		}
		List<WorkOrder> listaWorkOrderAux = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{paginaActual.getParameters().get('idOrdenTrabajo')}).values();
		//List<WorkOrder> listaWorkOrderAux = Util_Orden_Trabajo.queryOT(new Set<Id>{paginaActual.getParameters().get('idOrdenTrabajo')});
		/*List<WorkOrder> listaWorkOrderAux = new List<WorkOrder>(
				[SELECT Id
				 FROM WorkOrder 
				 WHERE Id = :paginaActual.getParameters().get('idOrdenTrabajo')]);*/
		if(!listaWorkOrderAux.isEmpty()) {
			ordenTrabajo = listaWorkOrderAux.get(0);
			system.debug('[AMC] orden de trabajo' + ordenTrabajo);
		}
		tipoFirma = paginaActual.getParameters().get('tipoFirma');
	}
	
	@RemoteAction
	global static String saveSignature(String signatureBody, Id parentId, String fileName) {
		if(signatureBody != ''){
			try {
				system.debug('Record Id == ' + parentId);
				system.debug(signatureBody);
				Attachment a = new Attachment();
				a.ParentId = parentId;
				a.Body = EncodingUtil.base64Decode(signatureBody);
				a.ContentType = 'image/png';
				a.Name = fileName + '.png';
				List <Attachment> adjuntos = Util_Attachment.queryMapAttachment(new set<String>{a.Name}).values();
				if(!adjuntos.isEmpty()){
					a.Id = adjuntos.get(0).Id;
				}
				upsert a;
				return 'true';
			} catch(Exception e) {
				if(!Test.isRunningTest()){
					System.debug(JSON.serialize(e));
				}
				return 'false';
			}
		}
		else{
			return 'false';
		}
		
	}
	
	@RemoteAction
	global static String cancelar() {
		return 'true';
	}
}