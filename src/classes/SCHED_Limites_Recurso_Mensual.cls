global without sharing class SCHED_Limites_Recurso_Mensual implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new BATCH_Limites_Recurso_Mensual());
   }
}