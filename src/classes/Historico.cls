/**
 * Clase controladora de la Visualforce "Historico" encargada mostrar el historial de acciones durante una llamada.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Historico {
	public List<EntradaHistorico> listaHistoricos {get; set;}

	/**
	  * Constructor de la clase.
	  * 
	  * @param stdc: [PENDIENTE]
	  */	
	public Historico(ApexPages.StandardController stdc){
		List<String> fields = new List<String> {
			'OwnerId',
			'WhatId',
			'WhoId',
			'TAR_DAT_Inicio_Llamada__c',
			'TAR_DAT_Fin_Llamada__c',
			'CallDurationInSeconds',
			'TAR_TXT_Id_Sesion__c',
			'Subject',
			'Status'
		};
		if (!Test.isRunningTest()){
			stdc.addFields(fields);
		}
		Task tarea = (Task) stdc.getRecord();
		system.debug('>>>>tarea ' + tarea);
		listaHistoricos = new List<EntradaHistorico>();
		rellenarHistoricoCuenta(tarea);
		rellenarHistoricoContacto(tarea);
		rellenarHistoricoDireccionCuenta(tarea);
		rellenarHistoricoCaso(tarea);
		rellenarHistoricoComentarioCaso(tarea);
		rellenarHistoricoContactosTLF(tarea);
		rellenarHistoricoPerjudicado(tarea);
		rellenarHistoricoPresupuestos(tarea);
		rellenarHistoricoOT(tarea);
		rellenarHistoricoComentarioOT(tarea);
		rellenarHistoricoHabilidadesRequeridas(tarea);
		rellenarHistoricoPartidasOrdenTrabajo(tarea);
		rellenarHistoricoCitasServicio(tarea);
		ordenar();
	}

	private void rellenarHistoricoCuenta(Task tarea){
		List<AccountHistory> listaCambios = Util_Historico.getHistoricoCuenta(new Set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
        system.debug(listaCambios + ' Lista de Cambios');
		for(AccountHistory cambio : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Account', cambio.Account.Name, cambio.AccountId, cambio.CreatedDate, cambio.Field,
				cambio.isDeleted, String.valueOf(cambio.NewValue), String.valueOf(cambio.OldValue)));
		}
	}

	/**	
	 * Esta funcion rellena el histórico de cambios en Casos.
	 *
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoCaso(Task tarea){
		List<CaseHistory> listaCambios = Util_Historico.getMapaHistoricoCaso(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(CaseHistory cHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Case', cHis.Case.CaseNumber, cHis.CaseId, cHis.CreatedDate, cHis.Field,
				cHis.isDeleted, String.valueOf(cHis.NewValue), String.valueOf(cHis.OldValue)));
		}
	}

	/**	
	 * Esta funcion rellena el histórico de cambios en Órdenes de Trabajo.
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */ 
	private void rellenarHistoricoOT(Task tarea){
		List<WorkOrderHistory> listaCambios = Util_Historico.getHistoricoOT(new Set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(WorkOrderHistory otHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('WorkOrder', otHis.WorkOrder.WorkOrderNumber, otHis.WorkOrderId, otHis.CreatedDate, otHis.Field, 
				otHis.isDeleted, String.valueOf(otHis.NewValue), String.valueOf(otHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en Comentarios de Casos
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoComentarioCaso(Task tarea){
		List<Comentario_caso__History> listaCambios = Util_Historico.getHistoricoComentarioCaso(new Set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(Comentario_caso__History comHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Comentario_caso__c', comHis.Parent.Name, comHis.Id, comHis.CreatedDate, comHis.Field, 
				comHis.isDeleted, String.valueOf(comHis.NewValue), String.valueOf(comHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en Comentarios de Órdenes de Trabajo
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoComentarioOT(Task tarea){
		List<Comentario_Orden_de_Trabajo__History> listaCambios = Util_Historico.getHistoricoComentarioOT(new Set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(Comentario_Orden_de_Trabajo__History comOTHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Comentario_Orden_de_Trabajo__c', comOTHis.Parent.Name, comOTHis.Id, comOTHis.CreatedDate, comOTHis.Field, 
				comOTHis.isDeleted, String.valueOf(comOTHis.NewValue), String.valueOf(comOTHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en Contactos
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoContacto(Task tarea){
		List<ContactHistory> listaCambios = Util_Historico.getMapaHistoricoContacto(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(ContactHistory cntcHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Contact', cntcHis.Contact.CON_TXT_Identificador__c, cntcHis.Id, cntcHis.CreatedDate, cntcHis.Field, 
				cntcHis.isDeleted, String.valueOf(cntcHis.NewValue), String.valueOf(cntcHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en Contactos Telefónicos
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoContactosTLF(Task tarea){
		List<Contacto_Telefonico__History> listaCambios = Util_Historico.getHistoricoContactoTelefonico(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(Contacto_Telefonico__History cTlfHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Contacto_Telefonico__c', cTlfHis.Parent.Name, cTlfHis.Id, cTlfHis.CreatedDate, cTlfHis.Field, 
				cTlfHis.isDeleted, String.valueOf(cTlfHis.NewValue), String.valueOf(cTlfHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en Contactos Telefónicos
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoPerjudicado(Task tarea){
		List<Perjudicado_Siniestro__History> listaCambios = Util_Historico.getHistoricoPerjudicado(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(Perjudicado_Siniestro__History sinHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Perjudicado_Siniestro__c', sinHis.Parent.Name, sinHis.Id, sinHis.CreatedDate, sinHis.Field, 
				sinHis.isDeleted, String.valueOf(sinHis.NewValue), String.valueOf(sinHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en habilidades requeridas.
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoHabilidadesRequeridas(Task tarea){
		List<SkillRequirementHistory> listaCambios = Util_Historico.getHistoricoHabilidadRequerida(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(SkillRequirementHistory srHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('SkillRequirement', srHis.SkillRequirement.SkillNumber, srHis.Id, srHis.CreatedDate, srHis.Field, 
				srHis.isDeleted, String.valueOf(srHis.NewValue), String.valueOf(srHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en partidas de órdenes de trabajo.
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoPartidasOrdenTrabajo(Task tarea){
		List<WorkOrderLineItemHistory> listaCambios = Util_Historico.getHistoricoPartidaServicio(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(WorkOrderLineItemHistory woliHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('WorkOrderLineItem', woliHis.WorkOrderLineItem.LineItemNumber, woliHis.Id, woliHis.CreatedDate, woliHis.Field, 
				woliHis.isDeleted, String.valueOf(woliHis.NewValue), String.valueOf(woliHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en partidas de citas de servicio.
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoCitasServicio(Task tarea){
		List<ServiceAppointmentHistory> listaCambios = Util_Historico.getHistoricoCitaServicio(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(ServiceAppointmentHistory saHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('ServiceAppointment', saHis.ServiceAppointment.AppointmentNumber, saHis.Id, saHis.CreatedDate, saHis.Field, 
				saHis.isDeleted, String.valueOf(saHis.NewValue), String.valueOf(saHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en presupuestos.
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoPresupuestos(Task tarea){
		List<Presupuesto__History> listaCambios = Util_Historico.getHistoricoPresupuesto(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(Presupuesto__History preHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Presupuesto__c', preHis.Parent.Name, preHis.Id, preHis.CreatedDate, preHis.Field, 
				preHis.isDeleted, String.valueOf(preHis.NewValue), String.valueOf(preHis.OldValue)));
		}
	}

	/*	
	 *	Esta funcion rellena el histórico de cambios en direcciones de cuentas.
	 * @param Task Tarea		- tarea en la que se realizan los cambios
	 *
	 */
	private void rellenarHistoricoDireccionCuenta(Task tarea){
		List<Direccion_Cuenta__History> listaCambios = Util_Historico.getHistoricoDireccionCuenta(new set<Id>{tarea.OwnerId},tarea.TAR_DAT_Inicio_Llamada__c,tarea.TAR_DAT_Fin_Llamada__c).values();
		for(Direccion_Cuenta__History dcHis : listaCambios){
			listaHistoricos.add(new EntradaHistorico('Direccion_Cuenta__c', dcHis.Parent.Name, dcHis.Id, dcHis.CreatedDate, dcHis.Field, 
				dcHis.isDeleted, String.valueOf(dcHis.NewValue), String.valueOf(dcHis.OldValue)));
		}
	}

	/**
	  * Método que ordena la lista de históricos.
	  * 
	  */   
	public void ordenar(){
		EntradaHistorico aux;
		for(Integer i = 0; i < listaHistoricos.size();i++){
			for(Integer j = i+1; j< listaHistoricos.size();j++){
				if (listaHistoricos.get(i).fecha > listaHistoricos.get(j).fecha){
					aux = listaHistoricos.get(i);
					listaHistoricos.set(i,listaHistoricos.get(j));
					listaHistoricos.set(j,aux);
				}
			}
		}	
	}

	/**
	  * [PENDIENTE]
	  * 
	  */
	public without sharing class EntradaHistorico {
		public String objeto {get; set;}
		public String nombreRegistro {get; set;}
		public Id idRegistro {get; set;}
		public DateTime fecha {get; set;}
		public String campo {get; set;}
		public String borrado {get; set;}
		public String valorNuevo {get; set;}
		public String valorAntiguo {get; set;}

		/**
		  * [PENDIENTE]
		  * 
		  * @param objeto: [PENDIENTE]
		  * @param nombreRegistro: [PENDIENTE]
		  * @param idRegistro: [PENDIENTE]
		  * @param fecha: [PENDIENTE]
		  * @param campo: [PENDIENTE]
		  * @param borrado: [PENDIENTE]
		  * @param valorNuevo: [PENDIENTE]
		  * @param valorAntiguo: [PENDIENTE]
		  */   
		public EntradaHistorico(String objeto, String nombreRegistro, Id idRegistro, DateTime fecha, String campo,
				Boolean borrado, String valorNuevo, String valorAntiguo){
			this.objeto = Schema.getGlobalDescribe().get(objeto).getDescribe().getLabel();
			this.nombreRegistro = nombreRegistro;
			this.idRegistro = idRegistro;
			this.fecha = fecha;
			this.campo = etiquetaCampo(objeto, campo);
			this.borrado = booleanToString(borrado);
			this.valorNuevo = valorNuevo;
			this.valorAntiguo = valorAntiguo;
		}

		/**
		  * [PENDIENTE]
		  * 
		  * @param nombreObjeto: [PENDIENTE]
		  * @param nombreCampo: [PENDIENTE]
		  * 
		  * @return [PENDIENTE]
		  */
		private String etiquetaCampo(String nombreObjeto, String nombreCampo){
			String etiqueta;
			if(nombreObjeto != null
					&& nombreCampo != null){
				system.debug('>>>>nombreObjeto ' + nombreObjeto);
				system.debug('>>>>nombreCampo ' + nombreCampo);
				Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
				Map <String, Schema.SObjectField> fieldMap = schemaMap.get(nombreObjeto).getDescribe().fields.getMap();
				if(fieldMap.get(nombreCampo) != null){
					etiqueta = fieldMap.get(nombreCampo).getDescribe().getLabel();
				}else{
					etiqueta = nombreCampo;
				}
			}
			return etiqueta;
		}

		/**
		  * [PENDIENTE]
		  * 
		  * @param bool: [PENDIENTE]
		  * 
		  * @return [PENDIENTE]
		  */
		private String booleanToString(Boolean bool){
			String etiqueta;
			if(bool != null){
				if(bool){
					etiqueta = 'Sí';
				}else{
					etiqueta = 'No';
				}
			}
			return etiqueta;
		}
	}
}