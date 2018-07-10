@isTest
public without sharing class Test_SCHED_Reprogramacion_Citas {

	@isTest static void Festivos_Profesional(){
		SCHED_Reprogramacion_Citas citas = new SCHED_Reprogramacion_Citas(120);
		citas.execute(null);
	}
}