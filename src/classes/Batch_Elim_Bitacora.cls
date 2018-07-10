/** 
*   Clase que implementa un proceso batch que encargado de eliminar borrado de bitácoras que será ejecutado el el primer día de cada mes:
*   Una entrada de bitácora se eliminará en caso de que esta tenga una antigüedad mayor a X MESES (BATCH_BORRADO_BITACORA_MESES) y su estado sea '06' ; es decir, que ya se envió la información al sistema tercero.
*   @author everis
*   @version 1.0
*
 */
global without sharing class Batch_Elim_Bitacora implements Schedulable {

    global String status;
    global date fechaLimite ;
    global String tipo ;
    global String query;

    global Batch_Elim_Bitacora() {

        RecordType rt = Util_mapasTiposDeRegistro.getRTByName(new Set<String>{'Servicio Web'}).values()[0];
        //RecordType rt =[SELECT Id,Name FROM RecordType WHERE Name = 'Servicio Web'][0] ;
        this.tipo = rt.Id;
        this.status = '06' ;
        date hoy = date.today();
        this.fechaLimite = hoy.addMonths(-integer.valueOf(Label.BATCH_BORRADO_BITACORA_MESES));
        
    }

    global void execute(SchedulableContext ctx) {
        system.debug(tipo);
        List<INT_Bitacora__c > bitacora_a_eliminar = Util_Bitacora.queryBitacoraByFechaRecordTypeAndEstado(new Set<Date>{this.fechaLimite}, new Set<Id>{this.tipo}, new Set<String>{this.status}).values();
        //List<INT_Bitacora__c > bitacora_a_eliminar = [SELECT Id FROM INT_Bitacora__c WHERE LastModifiedDate <: this.fechaLimite AND RecordTypeId  =: tipo AND BIT_SEL_Estado__c =: this.status];
         for (INT_Bitacora__c b : bitacora_a_eliminar) {
            delete b;
         }
    }

}