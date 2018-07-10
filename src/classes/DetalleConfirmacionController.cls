/**
* 
* Clase controladora del Componente "Detalle_Confirmacion" encargado de la cabecera de las VisualForce
* que muestra el detalle de la confirmacion actual.
* 
*/ 
public without sharing class DetalleConfirmacionController {
	public Confirmacion__c confirmacion {get; set;}
	public Case caso {get;
					  set{
						  caso = value;
						  if(caso != null){
							  tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
							  
						  }
					  }
					 }
	public String tipoActuacion {get; set;}
	public DetalleConfirmacionController(){

	}
}