/**
 * Clase controladora de la Visualforce "ControlAccionesEdit" y "ControlAccionesDelete" encargadas de controlar las acciones de modificación y eliminación
 * de las listas de relaciones.
 * 
 * @author EVERIS
 */
public without sharing class ControlAccionesController {

	public SObject objeto {get; set;}
	public Id idObjeto {get; set;}
	public Id idObjetoPadre {get; set;}
	public Id idPerfil {get; set;}
	public String visualForceName {get; set;}

	/**
	 * Constructor de la clase.
	 */
	public ControlAccionesController(ApexPages.StandardController stdController){
		objeto = stdController.getRecord();
		idObjeto = objeto.Id;
		idObjetoPadre = Id.valueOf(ApexPages.currentPage().getParameters().get('retURL').substring(1));
		idPerfil = UserInfo.getProfileId();
		visualForceName = getVisualForceName(ApexPages.currentPage().getUrl());

		system.debug('ControlAccionesController : Constructor : objeto : '+objeto);
		system.debug('ControlAccionesController : Constructor : idObjeto : '+idObjeto);
		system.debug('ControlAccionesController : Constructor : idObjetoPadre : '+idObjetoPadre);
		system.debug('ControlAccionesController : Constructor : idPerfil : '+idPerfil);
		system.debug('ControlAccionesController : Constructor : visualForceName : '+visualForceName);
	}

	// NOTA: Este Método se comenta para navegar al detalle del objeto siempre. Descomentar si se quiere navegar al detalle SOLO cuando el perfil NO es Administrador:
	/**
	 * Navega al detalle del objeto en el que estemos si no tenemos perfil Administrador, en otro caso navega a la edición del objeto o lo elimina según la Visual
	 * que esté manejando el controlador.
	 *
	 * @return página de detalle a navegar
	 */
	/*public PageReference navegacionControlAccion(){
		PageReference paginaNavegar;

		// Si tiene perfil Administrador navega a la edición del objeto o lo elimina (según la Visual de origen), sino, navega al detalle del objeto padre:
		if(Util_Perfiles_Usuario.esAdministrador(idPerfil)){
			if(visualForceName == 'ControlAccionesEdit'){
				paginaNavegar = new PageReference(('/'+idObjeto).left(4)+'/e');
			}
			else if(visualForceName == 'ControlAccionesDelete'){
				try{
					delete objeto;
					paginaNavegar = new PageReference('/'+idObjetoPadre);
				}
				catch(Exception e){
					system.debug('ControlAccionesController : navegacionControlAccion : Desde la Visualforce \'ControlAccionesDelete\' : e.getMessage() : '+e.getMessage());
				}
			}
		}
		else{
			paginaNavegar = new PageReference('/'+idObjetoPadre);
		}

		system.debug('ControlAccionesController : navegacionControlAccion : paginaNavegar : '+paginaNavegar);
		return paginaNavegar;
	}*/

	// NOTA: Sustituir este método por el de arriba si se quiere que el control sea relaalizado en función del perfil:
	/**
	 * Navega al detalle del objeto en el que estemos.
	 *
	 * @return página de detalle a navegar
	 */
	public PageReference navegacionControlAccion(){
		PageReference paginaNavegar = new PageReference('/'+idObjetoPadre);
		system.debug('ControlAccionesController : navegacionControlAccion : paginaNavegar : '+paginaNavegar);
		return paginaNavegar;
	}

	/**
	 * Obtiene el nombre de la VisualForce a partir de la URL.
	 *
	 * @param url: URL de la página actual
	 *
	 * @return nombre de la VisualForce actual
	 */
	private static String getVisualForceName(String url){
		String visualForceName = '';
		system.debug('ControlAccionesController : getVisualForceName : url : '+url);

		// Recogemos la posición del tercer elemento de la URL delimitando por '/' y '?'
		if(url != null && (url.contains('/') || url.contains('?'))){
			String[] partesURL = url.split('[\\/\\?]');
			system.debug('ControlAccionesController : getVisualForceName : partesURL : '+partesURL);

			if(partesURL.size() >= 3){
				visualForceName = partesURL[2];
			}
		}

		system.debug('ControlAccionesController : getVisualForceName : visualForceName : '+visualForceName);
		return visualForceName;
	}
}