public with sharing class Util_Click2Call {
    
    public static Callout_ClickToCall.Resultado solicitarLlamadaClick2Call(String devNameCustomMetadata, String dato1, String telefono){
		
		Callout_ClickToCall_RQ aux = new Callout_ClickToCall_RQ();
		System.debug(devNameCustomMetadata);
		List<Configuracion_VDN__mdt> conf = Util_Metadatos.getConfVDNMetadataByDevName(new Set<String>{devNameCustomMetadata}).values();
		System.debug(conf);
        if(!conf.isEmpty()){
			aux.idCarga = Integer.valueOf(conf[0].LoadId__c);
			aux.idServicio = Integer.valueOf(conf[0].ServiceId__c);
			aux.dato1 = dato1;
			aux.telefono = telefono;
		}
		System.debug(aux);
		Callout_ClickToCall.Resultado res = Callout_ClickToCall.sendDatos(aux);		
        System.debug('res: '+res);
		//res =  Callout_ClickToCall.sendDatos(aux);	
		return res;

	}

}