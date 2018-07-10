/**
 * Clase controladora del Componente "Detalle_Caso" encargado de la cabecera de las VisualForce
 * que muestra el detalle del caso actual.
 * 
 * @author EVERIS
 */
public without sharing class DetalleCasoController {
	public Case caso {get; 
		set{
			caso = value;
			if (caso != null){
				tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
			}
		}
	}
	public String tipoActuacion {get; set;}
	public Boolean esProfesional {get; set;}
	public DetalleCasoController(){
		esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
	}
}