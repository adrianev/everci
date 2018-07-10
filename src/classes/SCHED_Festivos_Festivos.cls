global without sharing class SCHED_Festivos_Festivos implements Schedulable {

    global void execute(SchedulableContext sc) {
    	database.executebatch(new BATCH_Festivos('Festivos'));
    }
}