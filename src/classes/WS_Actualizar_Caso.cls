public without sharing class WS_Actualizar_Caso {
	private Case caso {get; set;}
	public without sharing class Resultado{
		public String resultado = 'OK';
		public String codigo_error = '';
		public String mensaje_error = '';
	}
	/* public casoVesta(Integer actuacion, Integer casoActualizacion, Date fechaCambio,String descripcionNoAbierto, String gremio, String numSiniestroHS, String numSiniestroCIA ){
            this.actuacion = actuacion;
            this.casoActualizacion = casoActualizacion;
            this.fechaCambio = fechaCambio;
            this.descripcionNoAbierto = descripcionNoAbierto;
            this.gremio = gremio;
            this.numSiniestroHS = numSiniestroHS;
            this.numSiniestroCIA = numSiniestroCIA;
        }*/
	public WS_Actualizar_Caso(ApexPages.StandardController stdCtr){
		// 1. Recoger parametros del Caso
		List<String> fields = new List<String> {
			'CAS_NUM_Id_Actuacion_SondeoExt',
			'CAS_SEL_Motivo_No_Apertura__c',
			'CAS_SEL_Gremio_Principal__c',
			'CAS_TXT_Num_Caso_HS__c',
			'CAS_TXT_Num_Caso_CIA__c',
		'Type'};
		if (!Test.isRunningTest()){
			stdCtr.addFields(fields);
		}
		caso = (Case) stdCtr.getRecord();
		List<Case> listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
		//List<Case> listaCasosQuery = Util_Caso.queryMapSiniCaso(new Set<Id>{stdCtr.getRecord().Id},null,1).values();
		//List<Case> listaCasosQuery = Util_Siniestro.queryCaso(stdCtr.getRecord().Id, null, 1);
		if(listaCasosQuery.size() > 0){
			caso = listaCasosQuery.get(0);
		}
	}
	public void actualizarSiniestroVesta(){
		/*Callout_ActualizaSiniestroVesta_RQ request = new Callout_ActualizaSiniestroVesta_RQ();
        request.actuacion = Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c);
        //request.fechaCambio = '';
        //request.operadorCambio = '';
        request.descripcionNoAbierto = '';
        request.tipoSiniestro = '';
        request.tipoSituacion = '';
        request.gremio = '';
        request.tipoSituacionReparacion='';

        request.numeroSiniestroHS = '';
        request.numeroSiniestroCIA = '';
        request.casoActualizacion = 1;
        if (request.casoActualizacion ==1){
            request.numeroSiniestroHS = caso.CAS_TXT_Num_Caso_HS__c;
            request.numeroSiniestroCIA = caso.CAS_TXT_Num_Caso_CIA__c;
        }*/

		Callout_ActualizaSiniestroVesta_RQ request = new Callout_ActualizaSiniestroVesta_RQ(Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c), 1,
				'', '', '', '', caso.CAS_TXT_Num_Caso_HS__c, caso.CAS_TXT_Num_Caso_CIA__c, '', '');

		Callout_ActualizaSiniestroVesta.updateDatos(request);
	}   
}