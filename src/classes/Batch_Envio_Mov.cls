/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:             everis
Company:        everis España
Description:    <Comprueba si hay algún INT_Config_Fichero_CIA__c que enviar buscando en la tabla <INT_Envio_Programado__c> y
				envía la query a realizar>

History:  <DESCRIPCIÓN DEL CAMBIO, REQUISITO, INCIDENCIA, CORRECTIVO O MEJORA QUE HIZO ACTUALIZAR/CREAR LA CLASE>

<27/11/2017>                      everis                       <Inicio de clase>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
global without sharing class Batch_Envio_Mov implements Database.Batchable<INT_Bitacora__c>,Database.AllowsCallouts{
	global List<INT_Envio_Programado__c> listaEnvioProg;
	global List<INT_Bitacora__c> listaBit;
	global Batch_Envio_Mov(List<INT_Envio_Programado__c> listaEnvioProg, List<INT_Bitacora__c> listaBit){
		this.listaEnvioProg = listaEnvioProg;
		this.listaBit = listaBit;
	}
	global Iterable<INT_Bitacora__c> start(Database.BatchableContext bc) {
		if(listaBit==null){
			return Batch_Envio_Mov_Aux.listaMovDia(listaEnvioProg);
		} else{
			return listaBit;
		}
	}

	global void execute(Database.BatchableContext bc, List<INT_Bitacora__c> listaFich){
		Batch_Envio_Mov_Aux.invocarCallout(Batch_Envio_Mov_Aux.montarPeticion(listaFich));
	}

	global void finish(Database.BatchableContext bc){

	}

}