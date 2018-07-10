/**
  * Clase controladora del Componente "Detalle_B2B_B2B2C" encargado de la cabecera de las VisualForce
  * que muestra el detalle del servicio actual B2B/B2B2C o B2C.
  * 
  */
public without sharing class Detalle_B2B_B2B2C {
	public Case caso {get; 
	set {
		caso = value;
		if(caso != null){
			tipoCaso = Util_mapasTiposDeRegistro.RTNAMEBYID.get(caso.RecordTypeId);
		}
	}
	}	
	public Account cuenta {get; set;}
	public Boolean esB2C {get; set;}
	public String tipoCaso {get; set;}
	public Boolean esProfesional {get; set;}
	public Boolean esProfesionalSec {get; set;}
	public Detalle_B2B_B2B2C(){	
		esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
		esProfesionalSec = (esProfesional && (!Util_Perfiles_Usuario.esRecursoPrincipal(UserInfo.getUserId())));
	}
}