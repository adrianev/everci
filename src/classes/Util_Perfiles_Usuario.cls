/**
 * Clase de funciones auxiliares relativas a Perfiles de Usuario.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Perfiles_Usuario {
	public final static Map<Id, Profile> PROFILEBYID = getProfileById();

	/** 
	 * getProfileById: Devuelve un mapa <Id, Profile> con todos los perfiles que existen
	 * 
	 * @return mapa 
	 */
	
	private static Map<Id, Profile> getProfileById() {
		Map<Id, Profile> mapa = new Map<Id, Profile>();
		for (Profile registro : [SELECT Id, Name FROM Profile]) {
			mapa.put(registro.Id, registro);
		}
		return mapa;
	}
	

	/**
	 * getMapNamePerfilesUsuario: Devuelve un mapa con todos los IDs de los perfiles de usuario usando el Name como clave.
	 *
	 * @return mapa que contiene los IDs de los perfiles de usuario usando el Name como clave
	 */
	public static Map<String,Id> getMapNamePerfilesUsuario(){
		Map<String,Id> mapa = new Map<String,Id>();
		for(Profile perfil:[SELECT Id,Name FROM Profile]){
			mapa.put(perfil.Name,perfil.Id);
		}
		return mapa;
	}

	/**
	 * getMapPermissionSet: Devuelve un mapa con todos los IDs de los PermissionSet usando la Label como clave.
	 *
	 * @return mapa que contiene los IDs de los PermissionSet encontrados usando la Label como clave
	 */
	public static Map<String,Id> getMapPermissionSet(){
		Map<String,Id> mapa = new Map<String,Id>();
		for(PermissionSet ps:[SELECT Id,Label FROM PermissionSet]){
			mapa.put(ps.Label,ps.Id);
		}
		return mapa;
	}

	/**
	 * getPermissionSetAssigment: Devuelve los PermissionSetAssigment a partir de una lista de Labels de permisos.
	 *
	 * @param idUsuario: ID del usuario
	 * @param mapPermissionSet: mapa que relaciona las Labels de los PermissionSet con sus IDs
	 * @param listaLabelsPermisos: lista de Labels de permisos a introducir en los PermissionSetAssigment
	 *
	 * @return lista de PermissionSetAssigment's
	 */
	public static List<PermissionSetAssignment> getPermissionSetAssigment(Id idUsuario, Map<String,Id> mapPermissionSet, List<String> listaLabelsPermisos){
		List<PermissionSetAssignment> listaPSA = new List<PermissionSetAssignment>();
		if(idUsuario != null && mapPermissionSet != null && !mapPermissionSet.isEmpty() && listaLabelsPermisos != null && !listaLabelsPermisos.isEmpty()){
			for(String labelPermiso : listaLabelsPermisos){
				PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId=idUsuario,PermissionSetId=mapPermissionSet.get(labelPermiso));
				listaPSA.add(psa);
			}
		}
		return listaPSA;
	}

	/**
	 * getPermissionSetAssigmentProfesional: Devuelve los PermissionSetAssigment del Perfil profesional.
	 *
	 * @param idUsuario: ID del usuario
	 * @param mapPermissionSet: mapa que relaciona las Labels de los PermissionSet con sus IDs
	 *
	 * @return lista de PermissionSetAssigment's del perfil Profesional
	 */
	public static List<PermissionSetAssignment> getPermissionSetAssigmentProfesional(Id idUsuario, Map<String,Id> mapPermissionSet){
		List<String> listaLabelsPermisos = new List<String>{Label.PS_FIELD_SERVICE_MOBILE,
															Label.PS_FIELD_SERVICE_SCHEDULING,
															Label.PS_FIELD_SERVICE_STANDARD,
															Label.PS_FSL_MOBILE_LICENSE,
															Label.PS_FSL_MOBILE_PERMISSIONS,
															Label.PS_FSL_RESOURCE_LICENSE,
															Label.PS_FSL_RESOURCE_PERMISSIONS};
		return getPermissionSetAssigment(idUsuario,mapPermissionSet,listaLabelsPermisos);
	}

	/**
	 * getPermissionSetAssigmentGestoresSupervisores: Devuelve los PermissionSetAssigment de los perfiles Gestores y Supervisores.
	 *
	 * @param idUsuario: ID del usuario
	 * @param mapPermissionSet: mapa que relaciona las Labels de los PermissionSet con sus IDs
	 *
	 * @return lista de PermissionSetAssigment's de los perfiles Gestores y Supervisores
	 */
	public static List<PermissionSetAssignment> getPermissionSetAssigmentGestoresSupervisores(Id idUsuario, Map<String,Id> mapPermissionSet){
		List<String> listaLabelsPermisos = new List<String>{Label.PS_FIELD_SERVICE_STANDARD,
															Label.PS_FSL_AGENT_LICENSE,
															Label.PS_FSL_AGENT_PERMISSIONS};
		return getPermissionSetAssigment(idUsuario,mapPermissionSet,listaLabelsPermisos);
	}
	
	/**
	 * getPermissionSetAssigmentAdministrador: Devuelve los PermissionSetAssigment del Perfil Administrador.
	 *
	 * @param idUsuario: ID del usuario
	 * @param mapPermissionSet: mapa que relaciona las Labels de los PermissionSet con sus IDs
	 *
	 * @return lista de PermissionSetAssigment's del perfil Administrador
	 */
	public static List<PermissionSetAssignment> getPermissionSetAssigmentAdministrador(Id idUsuario, Map<String,Id> mapPermissionSet){
		List<String> listaLabelsPermisos = new List<String>{Label.PS_FIELD_SERVICE_STANDARD,
															Label.PS_FSL_ADMIN_LICENSE,
															Label.PS_FSL_ADMIN_PERMISSIONS};
		return getPermissionSetAssigment(idUsuario,mapPermissionSet,listaLabelsPermisos);
	}

	/**
	 * isGestorOrSupervisorActive: Devuelve si el Profile de un Usuario dado es un Gestor o un Supervisor y está activo.
	 *
	 * @param usuario: Usuario a comprobar su perfil
	 * @param mapaPerfiles: mapa con todos los perfiles
	 *
	 * @return true si es un Gestor o un Supervisor y está activo, false en otro caso
	 */
	public static Boolean isGestorOrSupervisorActive(User usuario,Map<String,Id> mapaPerfiles){
		return ((usuario.profileId == mapaPerfiles.get(Label.PERFIL_GESTOR_FRONT_TRAMITACION)
					|| (usuario.profileId == mapaPerfiles.get(Label.PERFIL_GESTOR_RECLAMACIONES))
					|| (usuario.profileId == mapaPerfiles.get(Label.PERFIL_GESTOR_AUDITORIA_GESTION))
					|| (usuario.profileId == mapaPerfiles.get(Label.PERFIL_SUPERVISOR_FRONT_TRAMITACION))
					|| (usuario.profileId == mapaPerfiles.get(Label.PERFIL_SUPERVISOR_RECLAMACIONES))
					|| (usuario.profileId == mapaPerfiles.get(Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION))
					|| (usuario.profileId == mapaPerfiles.get(Label.PERFIL_GESTOR_RED))) && usuario.IsActive);
	}

	/**
	 * esRecursoPrincipal: Devuelve true si el recurso obtenido es principal y false en caso contrario
	 *
	 * @param setIds: Id de usuario
	 *
	 * @return boolean true si el recurso es principal para el ID de usuario proporcionado
	 */
	public static Boolean esRecursoPrincipal(Id idUsuario){
		Boolean esRecursoPrincipal = false;
		if(idUsuario != null){
			/*List<ServiceResource> listaRecursos = new List<ServiceResource>(
				[SELECT RSE_FOR_Recurso_Servicio_Principal__c
				 FROM ServiceResource
				 WHERE RelatedRecord.Id = :idUsuario]);*/
			List<ServiceResource> listaRecursos = Util_Service_Resource.getMapaRecursoRelatedId(new Set<Id>{idUsuario}).values();
			if(!listaRecursos.isEmpty()){
				esRecursoPrincipal = listaRecursos.get(0).RSE_FOR_Recurso_Servicio_Principal__c;
			}
		}
		return esRecursoPrincipal;
	}



	/**
	 * esProfesional: Devuelve true si el usuario obtenido con el id proporcionado es PROFESIONAL y false en caso contrario
	 *
	 * @param setIds: Id de usuario
	 *
	 * @return boolean true si el usuario es profesional para el ID de usuario proporcionado
	 */
	public static Boolean esProfesional(Id idPerfilUsuario){
		return (idPerfilUsuario != null && PROFILEBYID.get(idPerfilUsuario) != null &&
			    PROFILEBYID.get(idPerfilUsuario).Name == Label.PERFIL_PROFESIONAL);
	}

	/**
	 * esAdministrador: Devuelve true si el usuario obtenido con el id proporcionado es ADMINISTRADOR DEL SISTEMA y false en caso contrario
	 *
	 * @param setIds: Id de usuario
	 *
	 * @return boolean true si el usuario es administrador para el ID de usuario proporcionado
	 */
	public static Boolean esAdministrador(Id idPerfilUsuario){
		return (idPerfilUsuario != null && PROFILEBYID.get(idPerfilUsuario) != null &&
			    PROFILEBYID.get(idPerfilUsuario).Name == Label.PERFIL_ADMINISTRADOR);
	}

	/**
	 * esGestor: Devuelve true si el usuario obtenido con el id proporcionado es GESTOR y false en caso contrario
	 *
	 * @param setIds: Id de usuario
	 *
	 * @return boolean true si el usuario es gestor para el ID de usuario proporcionado
	 */
	public static Boolean esGestor(Id idPerfilUsuario){
		return (idPerfilUsuario != null && PROFILEBYID.get(idPerfilUsuario) != null &&
			    PROFILEBYID.get(idPerfilUsuario).Name == Label.PS_FIELD_SERVICE_MOBILE);
	}

	/**
	 * esGestorFrontTramitacion: Devuelve true si el usuario obtenido con el id proporcionado es Gestor Front/Tramitación y false en caso contrario
	 *
	 * @param setIds: Id de usuario
	 *
	 * @return boolean true si el usuario es gestor front/tramitación para el ID de usuario proporcionado
	 */
	public static Boolean esGestorFrontTramitacion(Id idPerfilUsuario){
		return (idPerfilUsuario != null && PROFILEBYID.get(idPerfilUsuario) != null &&
			    PROFILEBYID.get(idPerfilUsuario).Name == Label.PERFIL_GESTOR_FRONT_TRAMITACION);
	}

	/**
	 * esAuditoriaGestion: Devuelve true si el usuario obtenido con el id proporcionado es de tipo Auditoria de Gestion y false en caso contrario
	 *
	 * @param setIds: Id de usuario
	 *
	 * @return boolean true si el usuario es de tipo Auditoria de Gestion para el ID de usuario proporcionado
	 */
	public static Boolean esAuditoriaGestion(Id idPerfilUsuario){
		return (idPerfilUsuario != null && PROFILEBYID.get(idPerfilUsuario) != null &&
			    (PROFILEBYID.get(idPerfilUsuario).Name == 'Gestor Auditoria de Gestion' ||
			    PROFILEBYID.get(idPerfilUsuario).Name == 'Supervisor Auditoria de Gestion'));
	}

	/**
	* Método para consultar usuarios por Id.
	*/
	public static Map<Id,User> queryMapUsuario(Set<Id> setIdUsu){
		Map<Id,User> mapa = new Map<Id,User>();
		if(setIdUsu != null && !setIdUsu.isEmpty()){
			for(List<User> lista :[SELECT id,Name,UserRoleId,UserRole.ParentRoleId,ProfileId,Address,IsActive,USR_SEL_Motivo_de_desactivacion__c,email,username,USR_TXT_Presence_Login__c,usertype,communitynickname,timezonesidkey,languagelocalekey,firstname,lastname,phone,title,street,city,country,postalcode,state,localesidkey,mobilephone,extension,fax,contact.email
									FROM User
									WHERE Id IN :setIdUsu]){
				mapa.putAll(lista);
			}
		}
		return mapa; 
	}
	
	/**
	* Método para consultar usuarios por role
	* @param Set<Id> roleID: conjunto de ids del rol
	* @return mapa con los usuarios como resultado
	*/
	public static Map<Id,User> getUsuarioByRole(Set<Id> roleID){
		Map<Id,User> mapa = new Map<Id,User>();
		if(roleID != null && !roleID.isEmpty()){
			for(List<User> lista :[SELECT id,UserRoleID
									FROM User
									WHERE UserRoleId IN:roleID]){
				mapa.putAll(lista);
			}
		}
		return mapa; 
	}
	/**
	* Cargar mapa de usuarios activos o inactivos
	*
	* activo: booleano que indica si quieres buscar los usuarios activos o inactivos
	*
	* @return mapa que contiene los usuarios activos o no
	*/
	public static Map<Id,User> getUsuAct (Boolean activo){
		Map<Id,User> mapa = new Map<Id,User>();
		if(activo != null){
			for(List<User> lista:[SELECT Id,UserRoleId FROM User WHERE isActive = :activo ORDER BY UserRoleId ASC]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	* Cargar mapa de usuarios con 0 caso en curso asignaos
	*
	* setIds: Ids de usuarios
	*
	* @return mapa que contiene los usuarios activos
	*/
	public static Map<Id,User> getUsuSinAsig (set<Id> setIds){
		Map<Id,User> mapa = new Map<Id,User>();
		if(setIds != null && !setIds.isEmpty()){
			for(List<User> lista:[SELECT Id
						 FROM User
						 WHERE Id IN :setIds
						 AND Id NOT IN (SELECT OwnerId
										FROM Case
						 				WHERE Status != :Label.CAS_ESTADO_INACTIVO
						 				AND isClosed = false)]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * queryProfileById: Devuelve los perfiles filtrados por los IDs (sObject: Profile)
	 *
	 * @param setIds: conjunto de IDs de perfiles
	 *
	 * @return mapa que contiene los perfiles encontrados
	 */
	public static Map<Id,Profile> queryProfileById(Set<Id> setIds){
		Map<Id,Profile> mapa = new Map<Id,Profile>();
		if(setIds != null && !setIds.isEmpty()){
			for(List<Profile> lista:[SELECT Id,Name FROM Profile WHERE Id IN :setIds]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	* queryMapUsuariosActivos: Método para consultar usuarios activos por Id. 
	*
	* @param setIdUsu - Ids de usuarios a consultar
	*
	* @return mapa de usuarios activos
	*/
	public static Map<Id,User> queryMapUsuariosActivos(Set<Id> setIdUsu){
		Map<Id,User> mapa = new Map<Id,User>();
		if(setIdUsu != null && !setIdUsu.isEmpty()){
			for(List<User> lista :[SELECT id,Name,Address,email,username,usertype,communitynickname,timezonesidkey,languagelocalekey,firstname,lastname,phone,title,street,city,country,postalcode,state,localesidkey,mobilephone,extension,fax,contact.email FROM User WHERE Id IN :setIdUsu AND IsActive = true]){
				mapa.putAll(lista);
			}
		}
		return mapa; 
	}
	
	/**
	 * getGroups: Devuelve todos los Grupos (sObject Group)
	 *
	 * @return mapa que contiene todos los grupos
	 */
	public static Map<Id,Group> getGroups(){
		Map<Id,Group> mapa = new Map<Id,Group>();
			for(List<Group> lista:[SELECT Id, Name, Type, RelatedId FROM Group]){
				mapa.putAll(lista);
			}
		return mapa;
	}
	
	/**
	 * getRolesPortAccNull: Devuelve todos los Roles de Usarios que PortalAccountId sea nulo (sObject UserRole)
	 *
	 * @return mapa que contiene Roles de Usuarios
	 */
	public static Map<Id,UserRole> getRolesPortAccNull(){
		Map<Id,UserRole> mapa = new Map<Id,UserRole>();
			for(List<UserRole> lista:[SELECT Id, ParentRoleId FROM UserRole WHERE PortalAccountId = null ORDER BY ParentRoleId ASC]){
				mapa.putAll(lista);
			}
		return mapa;
	}
}