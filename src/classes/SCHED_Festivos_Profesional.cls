global without sharing class SCHED_Festivos_Profesional implements Schedulable {

    global void execute(SchedulableContext sc) {
    	database.executebatch(new BATCH_Festivos('Profesional'));
    }
}