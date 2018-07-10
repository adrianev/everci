global without sharing class SCHED_Reprogramacion_Citas implements Schedulable {

	private Integer minutosQuery;
	public SCHED_Reprogramacion_Citas(Integer minutos){
		minutosQuery = minutos;
	}


	global void execute(SchedulableContext sc) {
		database.executebatch(new BATCH_Reprogramacion_Citas(minutosQuery), 1);
	}
}