global without sharing class Batch_Envio_Mov_Desencadenador implements Schedulable {
	global void execute(SchedulableContext ctx) {
		Batch_Envio_Mov myBatchObject = new Batch_Envio_Mov(null,null); 
		Id batchId = Database.executeBatch(myBatchObject);
	}
}