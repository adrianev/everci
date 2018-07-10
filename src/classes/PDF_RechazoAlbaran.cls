public without sharing class PDF_RechazoAlbaran {
    
    
    public List<RechazoAlbaran.Resultado> resultados {get;set;}
    public WorkOrder wo {get;set;}
    public String prof {get; set;}
    public String nombreCuenta {get; set;}
    public String dirEnvio {get; set;}
    /**
    * 
 	* Constructor de la clase
 	* 
 	*/  
	public PDF_RechazoAlbaran(){
		
		resultados = new List<RechazoAlbaran.Resultado>();
		
		PageReference paginaActual = ApexPages.currentPage();
		
		Id woId = paginaActual.getParameters().get('id');
		
		if(woId != null){
			List<Workorder> lAux = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).values();
			/*List<Workorder> lAux = [Select Id, 	OTR_LKP_Recurso_Servicio__r.Name, WorkOrderNumber,
			OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name,OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress from WorkOrder where id = :woId];*/
			if(!lAux.isEmpty()){
				wo = lAux.get(0);
				prof = wo.OTR_LKP_Recurso_Servicio__r.Name;
				nombreCuenta = wo.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.name;
				System.Address direccion = wo.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress;
				//dirEnvio = String.valueOf(wo.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__r.ShippingAddress);
				if(direccion != null){
					dirEnvio = direccion.Street+'<BR/>'+direccion.getPostalCode()+ ' ' + direccion.getCity() + ' ' + direccion.getState() ;
				}
			}
		}
		
		String resultadosSerializados = paginaActual.getParameters().get('resultados');
		
		if(resultadosSerializados != null){
			resultados = (List<RechazoAlbaran.Resultado>)JSON.deserialize(resultadosSerializados, List<RechazoAlbaran.Resultado>.class);
		}
	}
}