global without sharing class SCHED_Guardias implements Schedulable {

    global void execute(SchedulableContext sc) {
    	database.executebatch(new BATCH_Guardias());
    }
}