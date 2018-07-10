global without sharing class SCHED_Festivos_MiembrosTerritorio implements Schedulable {

    global void execute(SchedulableContext sc) {
    	database.executebatch(new BATCH_Festivos('MiembrosTerritorio'));
    }
}