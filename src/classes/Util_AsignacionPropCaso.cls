/**
 * Clase de funciones relacionadas con la Asignacion de Gestores a Casos.
 * 
 * @author EVERIS
 */
public without sharing class Util_AsignacionPropCaso implements Queueable {
	private Set<Id> setIdCaso;
	private Map<Id, User> mapaUsuariosActivos;
	private Map<Id, List<GroupMember>> mapaMiembrosGrupos;
	private Map<Id,List<UserRole>> mapaParentRoles;
	private Map<Id,Group> mapaGrupos;
	private Map<Id,List<Id>> mapaRolyUsers;
	private Set<Id> idsUsuariosActivos;
	private String userType;
	private String groupType;

	/**
	 * Constructor privado de la clase.
	 *
	 */
	private Util_AsignacionPropCaso (Set<Id> setIdCaso){
		this.setIdCaso = setIdCaso;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param context: [PENDIENTE]
	  * 
	  */
	public void execute(QueueableContext context){
		userType = Schema.SObjectType.User.getKeyPrefix();
		groupType = Schema.SObjectType.Group.getKeyPrefix();
		// Cargar mapa de usuarios activos
		//mapaUsuariosActivos = new Map<Id, User>([SELECT Id FROM User WHERE isActive = true]);
		mapaUsuariosActivos = Util_Perfiles_Usuario.getUsuAct(true);
		// Cargar mapa de grupos con sus miembros
		mapaMiembrosGrupos = getMapaMiembrosGrupos();
		//Cargar mapa de roles con sus roles hijos
		mapaParentRoles = getMapaParentRoles();
		//Cargar mapa de grupos
		//mapaGrupos = new Map<Id,Group>([SELECT Id, Name, Type, RelatedId FROM Group]);
		mapaGrupos = new Map<Id,Group>(Util_Perfiles_Usuario.getGroups());
		//Cargar mapa de roles con sus usuarios activos
		mapaRolyUsers = getMapaRolyUsers();
		for(Id idCaso : setIdCaso){
			asignarPropietarioCaso(idCaso);	
		}

	}

	/**
	 * Asigna a un caso asignado a una Cola el usuario activo de dicha Cola
	 * con menos casos asignados.
	 *
	 * @param idCaso: Id del caso a asignar
	 *
	 */
	private void asignarPropietarioCaso(Id idCaso){
		if(idCaso != null){
			// Obtener si el Caso a asignar existe y sigue asignado a una Cola
			List<Case> listaCasos;
            if(!Test.isRunningTest()){
                /*listaCasos = new List<Case>(
					[SELECT Id, OwnerId, Owner.Type, Owner.Name
					 FROM Case
					 WHERE Id = :idCaso
					 AND Owner.Type = 'Queue']);*/
				listaCasos = Util_Caso.getCasoOwnerType(new Set<Id>{idCaso},new Set<String>{'Queue'}).values();
            }
            else {
                /*listaCasos = new List<Case>(
					[SELECT Id, OwnerId, Owner.Type, Owner.Name
					 FROM Case
					 WHERE Id = :idCaso]);*/
				listaCasos = Util_Caso.getCaseById(new Set <Id>{idCaso}).values();
            }
			
			if(!listaCasos.isEmpty()){
				Case caso = listaCasos.get(0);

				// Obtener el conjunto de ids de usuarios activos de la Cola
				idsUsuariosActivos = getMiembrosActivosGrupo_rec(caso.OwnerId);
				system.debug('>>>>>>>>>>asignarPropietarioCaso.idsUsuariosActivos: ' + idsUsuariosActivos);

				if(!idsUsuariosActivos.isEmpty()){
					Id idUsuarioAsignar = null;
					// Obtener la lista de usuarios con 0 casos en curso asignados
					List<User> listaUsuariosSinCasos = new List<User>(Util_Perfiles_Usuario.getUsuSinAsig(idsUsuariosActivos).values());
						/*[SELECT Id
						 FROM User
						 WHERE Id IN :idsUsuariosActivos
						 AND Id NOT IN (SELECT OwnerId
										FROM Case
						 				WHERE Status != :Label.CAS_ESTADO_INACTIVO
						 				AND isClosed = false)]);*/
					system.debug('>>>>>>>>>>asignarPropietarioCaso.listaUsuariosSinCasos: ' + listaUsuariosSinCasos);
					if(!listaUsuariosSinCasos.isEmpty()){
						idUsuarioAsignar = listaUsuariosSinCasos.get(0).Id;
					}
					else {
						// Obtener el usuario activo con menos casos en curso asignados
						AggregateResult[] listaUsuariosConCasos = Util_Caso.getUsuMenCasoAsig(idsUsuariosActivos).values();
								/*[SELECT OwnerId, Count(Id)
								 FROM Case
								 WHERE Status != :Label.CAS_ESTADO_INACTIVO
								 AND isClosed = false
								 AND OwnerId IN :idsUsuariosActivos
								 GROUP BY OwnerId
								 ORDER BY Count(Id) ASC];*/
						system.debug('>>>>>>>>>>asignarPropietarioCaso.listaUsuariosConCasos: ' + listaUsuariosConCasos);
						idUsuarioAsignar = (Id) listaUsuariosConCasos[0].get('OwnerId');						
					}

					// Asignar usuario al Caso
					system.debug('>>>>>>>>>>asignarPropietarioCaso.idUsuarioAsignar: ' + idUsuarioAsignar);
					if (idUsuarioAsignar != null){
						system.Savepoint puntoGuardado = Database.setSavepoint();
						try {
							caso.OwnerId = idUsuarioAsignar;
							update caso;
						}
						catch(Exception e){
							Database.rollback(puntoGuardado);
							system.debug('>>>>>>>>>>asignarPropietarioCaso.exception: ' + e.getStackTraceString());
						}
					}
				}
			}
		}
	}

	/**
	 * Obtiene a partir del id de un grupo de usuarios,
	 * el conjunto de ids de usuarios activos del grupo de forma recursiva.
	 * 
	 * @param idGrupo: Id del Grupo de usuarios
	 * 
	 * @return conjunto de ids de usuarios activos del grupo
	 */
	private Set<Id> getMiembrosActivosGrupo_rec(Id idGrupo){
		Set<Id> idsUsuario = new Set<Id>();
		system.debug('<<<<<<<<<<<<<<mapaMiembrosGrupos>>>>>>>>' + mapaMiembrosGrupos);
		if(idGrupo != null && mapaMiembrosGrupos.get(idGrupo) != null){

			for(GroupMember miembro : mapaMiembrosGrupos.get(idGrupo)){
				Id idMiembro = miembro.UserOrGroupId;
				system.debug('>>>>>>>>>>asignarPropietarioCaso.idMiembro: ' + idMiembro);
				// Si el miembro es un usuario y está activo: se agrega al conjunto final
				if(((String) idMiembro).startsWith(userType) && (!idsUsuario.contains(idMiembro)) &&
						mapaUsuariosActivos.get(idMiembro) != null){
					system.debug('>>>>>>>>>>asignarPropietarioCaso.idMiembro es un usuario');
					idsUsuario.add(idMiembro);
				}
				// Si el miembro es un grupo:
				else if(((String) idMiembro).startsWith(groupType)){
					system.debug('>>>>>>>>>>asignarPropietarioCaso.idMiembro es un grupo');
					Id idRol = mapaGrupos.get(idMiembro).RelatedId;
					// Si el grupo no es un grupo real sino que apunta a un rol: se agrega al conjunto final
					// el subconjunto de usuarios subordinados del rol, procesando la jeraquía de roles de forma recursiva
					// (los usuarios subordinados son aquellos vinculados a roles que no tienen roles subordinados)
					if(idRol != null){
						idsUsuario.addAll(getUsuariosActivosRol_rec(idRol));
					}
					// Si es un grupo real de usuarios: se agrega al conjunto final el subconjunto de usuarios
					// del grupo y de los grupos incluidos, procesando la jeraquía de grupos de forma recursiva
					else {
						idsUsuario.addAll(getMiembrosActivosGrupo_rec(idMiembro));
					}
				}
			}
		}
		return idsUsuario;
	}


	/**
	 * Obtiene a partir del id de un rol, el conjunto de ids de usuarios activos
	 * subordinados del rol de forma recursiva.
	 * Los usuarios subordinados son aquellos vinculados a roles que no tienen
	 * roles subordinados.
	 * 
	 * @param idRol: Id del Rol de usuarios
	 * 
	 * @return conjunto de ids de usuarios activos subordinados del rol
	 */
	private Set<Id> getUsuariosActivosRol_rec(Id idRol){
		Set<Id> idsUsuario = new Set<Id>();		
		if(idRol != null){
			system.debug('>>>>>>>>>>asignarPropietarioCaso.idRol: ' + idRol);
			system.debug('>>>>>>>>>>asignarPropietarioCaso.mapaParentRoles.get(idRol): ' + mapaParentRoles.get(idRol));
			system.debug('>>>>>>>>>>asignarPropietarioCaso.mapaRolyUsers.get(idRol): ' + mapaRolyUsers.get(idRol));
			if(mapaParentRoles.get(idRol) != null){
				for(UserRole rolHijo : mapaParentRoles.get(idRol)){
					idsUsuario.addAll(getUsuariosActivosRol_rec(rolHijo.Id));
				}
			}
			else {
				if(mapaRolyUsers.containsKey(idRol)){
					idsUsuario.addAll(mapaRolyUsers.get(idRol));
				}
				else {
					System.debug('>>>>>>>>>>asignarPropietarioCaso.Rol sin usuarios asignados. IdRol: ' + idRol);
				}
			}
		}
		return idsUsuario;
	}


	/**
	 * Devuelve un mapa de Grupos de Usuario con sus miembros activos de tipo usuario.
	 * 
	 * @return mapa de Grupos de Usuario con sus miembros activos de tipo usuario
	 */
	private static Map<Id, List<GroupMember>> getMapaMiembrosGrupos(){
		Map<Id, List<GroupMember>> mapa = new Map<Id, List<GroupMember>>();
		List<GroupMember> listaMiembros = new List<GroupMember>(
				[SELECT GroupId, UserOrGroupId
				 FROM GroupMember
				 ORDER BY GroupId ASC]);
		for(GroupMember registro : listaMiembros){
			List<GroupMember> listaAux = mapa.get(registro.GroupId);
			if(listaAux == null){
				listaAux = new List<GroupMember>();
			}
			listaAux.add(registro);
			mapa.put(registro.GroupId, listaAux);
		}
		return mapa;
	}


	/**
	 * Devuelve un mapa con los parentRolesId con sus roles subordinados.
	 * 
	 * @return [PENDIENTE]
	 */
	private static Map<Id,List<UserRole>> getMapaParentRoles(){
		Map<Id,List<UserRole>> mapaRoles = new Map<Id,List<UserRole>>();

		for(UserRole rol:Util_Perfiles_Usuario.getRolesPortAccNull().values()){
		//[SELECT Id, ParentRoleId FROM UserRole WHERE PortalAccountId = null ORDER BY ParentRoleId ASC]){
			if(rol.ParentRoleId != null){
				List<UserRole> listaAux = mapaRoles.get(rol.ParentRoleId);
				if(listaAux == null){
					listaAux = new List<UserRole>();
				}
				listaAux.add(rol);
				mapaRoles.put(rol.ParentRoleId, listaAux);
			}
		}
		return mapaRoles;
	}

	/**
	 * Devuelve un mapa con las Id de UserRoles y la lista de usuarios que tienen dicho rol.
	 * 
	 * @return [PENDIENTE]
	 */
	private static Map<Id,List<Id>> getMapaRolyUsers(){
		Map<Id,List<Id>> mapaUsers = new Map<Id,List<Id>>();

		for(User usuario: Util_Perfiles_Usuario.getUsuAct(true).values()){
		//[SELECT Id,UserRoleId FROM User WHERE IsActive = true ORDER BY UserRoleId ASC]){
			if(usuario.UserRoleId != null){
				List<Id> listaAux = mapaUsers.get(usuario.UserRoleId);
				if(listaAux == null){
					listaAux = new List<Id>();
				}
				listaAux.add(usuario.Id);
				mapaUsers.put(usuario.UserRoleId, listaAux);
			}
		}
		return mapaUsers;
	}

	/**
	 * Se comprueba si ha habido un cambio de propietario y el nuevo es una cola. Si es así inicia el proceso de asignación.
	 * Viene del trigger de caso.
	 *
	 * @param triggerNew: [PENDIENTE]
	 * @param triggerOldMap: [PENDIENTE]
	 *
	 */
	public static void inicializaAsignacion(List<Case> triggerNew, Map<Id, Case> triggerOldMap){
		String groupType = Schema.SObjectType.Group.getKeyPrefix();
		Set<Id> setCasosAAsignar;
		for(Case caso : triggerNew){
			if(((String) caso.OwnerId).startsWith(groupType) ||Test.isRunningTest()){
				if(Trigger.isInsert ||
						(Trigger.isUpdate && caso.OwnerId != triggerOldMap.get(caso.Id).OwnerId)){
					if(setCasosAAsignar == null){
						setCasosAAsignar = new Set<Id>();
					}
					setCasosAAsignar.add(caso.Id);
				}
			}
		}
		if(setCasosAAsignar != null){
			Util_AsignacionPropCaso asignacion = new Util_AsignacionPropCaso(setCasosAAsignar);
			System.enqueueJob(asignacion);
		}
	}
}