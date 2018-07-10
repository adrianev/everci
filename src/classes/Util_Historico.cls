/**
 * Clase de funciones auxiliares relativas al histórico.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Historico {
	
	/**METODO ES IGUAL QUE TODOS LOS MÉTODOS DE LA CLASE SOLO CAMBIA EL OBJETO PRINCIPAL SOBRE EL QUE SE HACE LA QUERY
	 * Devuelve el histórico del objeto Contact a partir de una tarea.
	 *
	 * @param tarea: tarea a partir de la cual buscamos el histórico
	 * @return lista de registros históricos del objeto Contact
	 */
	/*public static List<ContactHistory> metodoAntiguo(Task tarea){
		List<ContactHistory> historico = new List<ContactHistory>();
		if(tarea != null){
			historico = [SELECT Contact.CON_TXT_Identificador__c, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
						 FROM ContactHistory
						 WHERE CreatedById = :tarea.OwnerId
						 AND CreatedDate >= :tarea.TAR_DAT_Inicio_Llamada__c
						 AND CreatedDate <= :tarea.TAR_DAT_Fin_Llamada__c
						 ORDER BY CreatedDate DESC];
		}
		return historico;
	}*/
	
	
	
	/**
	 * Devuelve el histórico del objeto Account a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Account
	 */
	public static Map<Id,AccountHistory> getHistoricoCuenta(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,AccountHistory> mapa = new Map<Id,AccountHistory>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<AccountHistory> historico: [SELECT Account.Name, AccountId, Field, isDeleted, NewValue, OldValue, CreatedDate
													FROM AccountHistory
													WHERE CreatedById IN :setIdHis
													 AND CreatedDate >= :fechaPrimera
													 AND CreatedDate <= :fechaSegunda
													 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Case a partir de un Id y 2 fechas.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Case
	 */
	public static Map<Id,CaseHistory> getMapaHistoricoCaso(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,CaseHistory> mapa = new Map<Id,CaseHistory>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<CaseHistory> historico : [SELECT Case.CaseNumber, CaseId, Field, isDeleted, NewValue, OldValue, CreatedDate, CreatedById, Id
												FROM CaseHistory
												WHERE CreatedById IN :setIdHis
												AND CreatedDate >= :fechaPrimera
												AND CreatedDate <= :fechaSegunda
												ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto WorkOrder a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto WorkOrder
	 */
	public static Map<Id,WorkOrderHistory> getHistoricoOT(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,WorkOrderHistory> mapa = new Map<Id,WorkOrderHistory>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<WorkOrderHistory> historico : [SELECT WorkOrder.WorkOrderNumber, WorkOrderId, Field, isDeleted, NewValue, OldValue, CreatedDate
													 FROM WorkOrderHistory
													 WHERE CreatedById IN :setIdHis
													 AND CreatedDate >= :fechaPrimera
													 AND CreatedDate <= :fechaSegunda
													 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Comentario_caso__c a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Comentario_caso__c
	 */
	public static Map<Id,Comentario_caso__History> getHistoricoComentarioCaso(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,Comentario_caso__History> mapa = new Map<Id,Comentario_caso__History>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<Comentario_caso__History> historico : [SELECT Parent.Name, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
															 FROM Comentario_caso__History
															 WHERE CreatedById IN :setIdHis
															 AND CreatedDate >= :fechaPrimera
															 AND CreatedDate <= :fechaSegunda
															 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Comentario_Orden_de_Trabajo__c a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Comentario_Orden_de_Trabajo__c
	 */
	public static Map<Id,Comentario_Orden_de_Trabajo__History> getHistoricoComentarioOT(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,Comentario_Orden_de_Trabajo__History> mapa = new Map<Id,Comentario_Orden_de_Trabajo__History>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<Comentario_Orden_de_Trabajo__History> historico : [SELECT Parent.Name, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
																		 FROM Comentario_Orden_de_Trabajo__History
																		 WHERE CreatedById IN :setIdHis
																		 AND CreatedDate >= :fechaPrimera
																		 AND CreatedDate <= :fechaSegunda
																		 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Contact a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Contact
	 */
	public static Map<Id,ContactHistory> getMapaHistoricoContacto(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,ContactHistory> mapa = new Map<Id,ContactHistory>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<ContactHistory> historico : [SELECT Contact.CON_TXT_Identificador__c, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
													 FROM ContactHistory
													 WHERE CreatedById IN :setIdHis
													 AND CreatedDate >= :fechaPrimera
													 AND CreatedDate <= :fechaSegunda
													 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Contacto_Telefonico__c a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Contacto_Telefonico__c
	 */
	public static Map<Id,Contacto_Telefonico__History> getHistoricoContactoTelefonico(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,Contacto_Telefonico__History> mapa = new Map<Id,Contacto_Telefonico__History>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<Contacto_Telefonico__History> historico : [SELECT Parent.Name, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
																 FROM Contacto_Telefonico__History
																 WHERE CreatedById IN :setIdHis
																 AND CreatedDate >= :fechaPrimera
																 AND CreatedDate <= :fechaSegunda
																 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Perjudicado_Siniestro__c a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Perjudicado_Siniestro__c
	 */
	public static Map<Id,Perjudicado_Siniestro__History> getHistoricoPerjudicado(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,Perjudicado_Siniestro__History> mapa = new Map<Id,Perjudicado_Siniestro__History>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<Perjudicado_Siniestro__History> historico : [SELECT Parent.Name, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
																 FROM Perjudicado_Siniestro__History
																 WHERE CreatedById IN :setIdHis
																 AND CreatedDate >= :fechaPrimera
																 AND CreatedDate <= :fechaSegunda
																 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto SkillRequirement a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto SkillRequirement
	 */
	public static Map<Id,SkillRequirementHistory> getHistoricoHabilidadRequerida(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,SkillRequirementHistory> mapa = new Map<Id,SkillRequirementHistory>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<SkillRequirementHistory> historico : [SELECT SkillRequirement.SkillNumber, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
															 FROM SkillRequirementHistory
															 WHERE CreatedById IN :setIdHis
															 AND CreatedDate >= :fechaPrimera
															 AND CreatedDate <= :fechaSegunda
															 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto WorkOrderLineItem a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto WorkOrderLineItem
	 */
	public static Map<Id,WorkOrderLineItemHistory> getHistoricoPartidaServicio(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,WorkOrderLineItemHistory> mapa = new Map<Id,WorkOrderLineItemHistory>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<WorkOrderLineItemHistory> historico : [SELECT WorkOrderLineItem.LineItemNumber, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
															FROM WorkOrderLineItemHistory
															WHERE CreatedById IN :setIdHis
															AND CreatedDate >= :fechaPrimera
															AND CreatedDate <= :fechaSegunda
															ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto ServiceAppointment a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto ServiceAppointment
	 */
	public static Map<Id,ServiceAppointmentHistory> getHistoricoCitaServicio(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,ServiceAppointmentHistory> mapa = new Map<Id,ServiceAppointmentHistory>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<ServiceAppointmentHistory> historico : [SELECT ServiceAppointment.AppointmentNumber, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
																FROM ServiceAppointmentHistory
																WHERE CreatedById IN :setIdHis
																AND CreatedDate >= :fechaPrimera
																AND CreatedDate <= :fechaSegunda
																ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Presupuesto__c a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Presupuesto__c
	 */
	public static Map<Id,Presupuesto__History> getHistoricoPresupuesto(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,Presupuesto__History> mapa = new Map<Id,Presupuesto__History>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<Presupuesto__History> historico : [SELECT Parent.Name, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
														 FROM Presupuesto__History
														 WHERE CreatedById IN :setIdHis
														 AND CreatedDate >= :fechaPrimera
														 AND CreatedDate <= :fechaSegunda
														 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico del objeto Direccion_Cuenta__c a partir de una tarea.
	 *
	 * @param setIdHis: Id a partir de la cual buscamos el histórico
	 * @param fechaPrimera: primera fecha del rango a partir de la cual buscamos el histórico
	 * @param fechaSegunda: segunda fecha del rango a partir de la cual buscamos el histórico
	 *
	 * @return mapa de registros históricos del objeto Direccion_Cuenta__c
	 */
	public static Map<Id,Direccion_Cuenta__History> getHistoricoDireccionCuenta(Set<Id> setIdHis,Datetime fechaPrimera, Datetime fechaSegunda){
		Map<Id,Direccion_Cuenta__History> mapa = new Map<Id,Direccion_Cuenta__History>();
		if(setIdHis != null && !setIdHis.isEmpty() && fechaPrimera != null && fechaSegunda != null){
			for(List<Direccion_Cuenta__History> historico : [SELECT Parent.Name, Id, Field, isDeleted, NewValue, OldValue, CreatedDate
															 FROM Direccion_Cuenta__History
															 WHERE CreatedById IN :setIdHis
															 AND CreatedDate >= :fechaPrimera
															 AND CreatedDate <= :fechaSegunda
															 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve el histórico de un campo especificado de una WorkOrder.
	 *
	 * @param idOT: ID de la WorkOrder a consultar el histórico de su campo
	 * @param campo: nombre del campo a consultar su histórico
	 *
	 * @return mapa de registros históricos del objeto WorkOrderHistory
	 */
	public static Map<Id,WorkOrderHistory> getHistoricoCampoOT(Set<Id> idOT, Set<String> campo){
		Map<Id,WorkOrderHistory> mapa = new Map<Id,WorkOrderHistory>();
		if(idOT != null && !idOT.isEmpty() && campo != null && !campo.isEmpty()){
			for(List<WorkOrderHistory> historico : [SELECT NewValue, OldValue, CreatedDate, CreatedBy.Name, CreatedBy.Profile.Name
													 FROM WorkOrderHistory
													 WHERE WorkOrderId IN :idOT
													 AND Field IN :campo
													 ORDER BY CreatedDate DESC]){
				mapa.putAll(historico);
			}
		}
		return mapa;
	}
}