public with sharing class PDF_DeclaracionResponsable {
    
    public DatosDeclaracion datos {get;set;}
    public WorkOrder ordenTrabajo {get;set;}
    public Attachment firma {get;set;}
    public String fecha {get; set;}
    
    
    public PDF_DeclaracionResponsable(){
    	
    	firma = null;
    	fecha = '';
    	PageReference paginaActual = ApexPages.currentPage();
		
		Id woId = paginaActual.getParameters().get('id');
		
		if(woId != null){
			List<Workorder> lAux = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).values();
			if(!lAux.isEmpty()){
				ordenTrabajo = lAux.get(0);
			}
		}
		
		String datosSerializados = paginaActual.getParameters().get('datos');
		
		system.debug('-----args: ' + datosSerializados);
		
		if(datosSerializados != null){
			datos = (DatosDeclaracion)JSON.deserialize(datosSerializados, DatosDeclaracion.class);	
			if(datos.fecha != null){
				fecha = String.valueOf(datos.fecha.Day()).leftPad(2,'0') + '-' 
					+ String.valueOf(datos.fecha.Month()).leftPad(2,'0') + '-'
					+ datos.fecha.Year();
			}
		}
		
		String attName = ordenTrabajo.WorkorderNumber +'_firma_declaracionResponsable.png';
		
		List<Attachment> firmasProf = [Select Id from Attachment where ParentId = :ordenTrabajo.Id and Name = :attName];
		
		if(!firmasProf.isEmpty()){
			firma = firmasProf[0];
		}
		
    }
    
    
    public without sharing class DatosDeclaracion{
		//Datos empresa
		public String razonSocial {get;set;}
		public String titularidadJuridica {get;set;}
		public String NIFCIF {get;set;}
		public String direccionEmailOrg {get;set;}
		public String telefono {get;set;}
		public String calle {get;set;}
		public String noCalle {get;set;}
		public String pais {get;set;}
		public String cPostal {get;set;}
		public String poblacion {get;set;}
		public String provincia {get;set;}
		
		//Datos apoderado
		public String nombreApellidos {get;set;}
		public String telefonoApod {get;set;}
		public String nifcifApod {get;set;}
		public String cargoApod {get;set;}
		
		//Datos trabajo
		public Date fecha {get;set;}
		public String sociedadContratante {get;set;}
		public String centroTrabajoCliente {get;set;}
		public String descripcionTrabajo {get;set;}
	}
}