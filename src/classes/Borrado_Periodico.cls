/** 
Clase para borrar periódicamente elementos. Consulta de la tabla de metadatos Borrado_Periodico__mdt
la query a borrar y la ejecuta con la condición de que el elemento se haya creado hace dos días o más

    @author everis
    @version 1.0

 */
global without sharing class Borrado_Periodico implements Schedulable {
	global void execute(SchedulableContext ctx) {
		Map<Schema.SObjectType,Set<sObject>> mapBorrado = new Map<Schema.SObjectType,Set<sObject>>();
		Integer nDias;
		Datetime fecha;
		for(Borrado_Periodico__mdt bp : Util_Metadatos.getBorradoPeriodicoMetadataByActivo(true).values()){
			nDias=(bp.Dias_desde_creacion__c!=null)?bp.Dias_desde_creacion__c.intValue():0;
			fecha = Datetime.now().addHours(-2).addDays(-nDias);
			List<sObject> lista = Database.query(bp.Query__c + ' AND CreatedDate <' + fecha.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
			if(!lista.isEmpty()){
				if(mapBorrado.containsKey(lista.get(0).getSObjectType())){
					mapBorrado.get(lista.get(0).getSObjectType()).addAll(lista);
				}else{
					mapBorrado.put(lista.get(0).getSObjectType(),new Set<sObject>(lista));
				}
			}
		}
		for(Set<sObject> setObjeto : mapBorrado.values()){
			delete new List<sObject>(setObjeto);
		}
	}

}