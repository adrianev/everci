/**
  * Clase con función auxiliar para crear tareas de registro de llamadas
  * 
  * @author EVERIS
  *
  */  
public without sharing class Registro_Llamada {

	/**
 	  * Crea y devuelve una tarea con el registro de una llamada relativa a un caso
	  * 
 	  * @param idPropietario: Id del propietario de la nueva tarea.
	  * @param idCaso: Id del caso relativo a la llamada.
	  * @param idContacto: Id del contacto con el que se realizó la llamada.
	  * @param inicio: Momento de inicio de la llamada
	  * @param finalizacion: Momento de finalización de la llamada.
	  * @param segDuracion: Duración de la llamada en segundos.
	  * @param idSesion: Id de la sesión relativa a la llamada.
	  * @param insercion: boolean que indica si se debe insertar la tarea o no.
 	  * 
	  * @return task creada con los datos de la llamada.
 	  */  	
	public static Task crearTareaLlamada(Id idPropietario, Id idCaso, Id idContacto, DateTime inicio, DateTime finalizacion,
			Integer segDuracion, String idSesion, Boolean insercion){
		Task tarea;
		system.debug('idPropietario '+ idPropietario+ ' idCaso ' + idCaso+' idContacto ' + idContacto + ' inicio '+ idContacto + ' finalizacion ' + finalizacion +  ' segDuracion ' + segDuracion+  ' idSesion ' + idSesion +  ' insercion ' + insercion);
		if(idPropietario != null && idContacto != null &&
			segDuracion != null && idSesion != null){
			try {
				tarea = new Task(OwnerId = idPropietario, WhatId = idCaso, WhoId = idContacto, 
						TAR_DAT_Inicio_Llamada__c = inicio, TAR_DAT_Fin_Llamada__c = finalizacion,
						CallDurationInSeconds = segDuracion, TAR_TXT_Id_Sesion__c = idSesion,
						Subject = 'Llamada', Status = 'Completed',
						RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('Task:TAR_Registro_Llamada'));
				if(insercion){
					insert tarea;
				}
			}
			catch(Exception e){
				system.debug('>>>>Error al crear tarea ' + e.getMessage());
			}
		}
		return tarea;
	}
}