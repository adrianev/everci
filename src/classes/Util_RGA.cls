/*
 * Clase encargada del setteo de los datos de los Callouts de RGA;
 *
 * @author EVERIS
 */
public without sharing class Util_RGA {
	
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada a Callout_RGA_Siniestro
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static String construirPeticionPratus(Id idCaso, Integer tipoAccion){
		/*Pendiente: realizar las queries para obtener las listas, saber qué Listas recibo desde los triggers,
		pendiente lógica de CRM*/
		
		Case caso = [select CreatedDate, CAS_TXT_texto_observaciones_RGA__c, CAS_SEL_Perito_de_RGA__c, CAS_CAS_Tercero_Causante__c, CAS_SEL_Grupo_Causa__c, toLabel(CAS_SEL_Grupo_Causa__c) etiquetaCausa, CAS_CAS_Danos_Perjudicado__c  from Case where id=:idCaso];
		
		Perjudicado_Siniestro__c perjudicado = new Perjudicado_Siniestro__c();
		if(caso.CAS_CAS_Danos_Perjudicado__c) 
			perjudicado= [SELECT Id, Name, PRJ_TFN_Telefono_1__c FROM Perjudicado_Siniestro__c WHERE PRJ_LKP_Siniestro__c = :idCaso LIMIT 1];
		
		Contacto_telefonico__c contactoTLF = [SELECT id, CTF_FOR_Telefono__c FROM Contacto_telefonico__c where CTF_LKP_Caso__c=:idCaso LIMIT 1];
		
		Callout_RGAPratusAsistenciaApertura_RQ peticion = new Callout_RGAPratusAsistenciaApertura_RQ();
		
		List<WorkOrder> listOrdenesTrabajo = Util_Orden_Trabajo.queryMapOTByCase(new Set<Id>{caso.Id}).values();
		//List<WorkOrder> listOrdenesTrabajo = Util_Orden_Trabajo.queryOT(null, caso.Id, null);
		
		DateTime ahora = System.now();
		
		peticion.refSiniestroAsis = Integer.valueof(caso.CAS_TXT_Num_Caso_HS__c); 
		peticion.fechaRegistroAsis = caso.CreatedDate.format('dd-MM-yyyy');
	    peticion.horaRegistroAsis = caso.CreatedDate.format('kk:mm:ss');
		peticion.tipoAccion = tipoAccion;
		peticion.fechaAccion = system.now().format('dd-MM-yyyy');
		//peticion.nombreReparador = '';   ????
		peticion.textoObservaciones = caso.CAS_TXT_texto_observaciones_RGA__c;
		//peticion.origenObservacion = '';
		//peticion.codigoSeguimientoAsis = '';
		peticion.identificadorPerito = Integer.valueOf(caso.CAS_SEL_Perito_de_RGA__c);
		//peticion.codigoMotivoRechazo = '';
		//peticion.indicadorGestora = '';
		peticion.causanteAveria = Integer.valueOf(caso.CAS_SEL_Perito_de_RGA__c);
		//peticion.codigoOperadoraAsis = '';
		peticion.codigoCausaAsis = Integer.valueOf(caso.CAS_SEL_Grupo_Causa__c);
		//peticion.descrCausaAsis = caso.etiquetaCausa;
		if(caso.CAS_CAS_Danos_Perjudicado__c) peticion.indicadorPerjudicado = 'S';
		else peticion.indicadorPerjudicado = 'N';				
		peticion.nombrePerjudicado = perjudicado.Name;
		peticion.telefonoPerjudicado = perjudicado.PRJ_TFN_Telefono_1__c;
		peticion.telefonoAsegurado = contactoTLF.CTF_FOR_Telefono__c;
		
		String body = JSON.serialize(peticion);
		
		return body;
	}
	
	/**
	* Se buscan las bitácoras que no se hayan podido recibir por estar Pratus apagado (Bitácoras en estado 'en espera' con ese idCaso)
	*
	*
	*/
	private void recogeBitacora(Id idCaso, Integer tipoAccion, String body, Id idContacto){
		List<INT_Bitacora__c> listaBitacoras = new List<INT_Bitacora__c>([SELECT Id, BIT_NUM_Orden_RGA__c FROM INT_Bitacora__c WHERE BIT_SEL_Estado__c =: Label.BIT_ESTADO_EN_ESPERA AND BIT_LKP_Id_Registro_caso__c =: idCaso order by BIT_NUM_Orden_RGA__c desc]);
		Integer orden;
		String cuerpo = construirPeticionPratus(idCaso,tipoAccion);
		if(listaBitacoras.isEmpty()){
			orden=0;
		}else{
			orden=listaBitacoras[0].BIT_NUM_Orden_RGA__c.intValue() + 1;
		}
		
		Util_Llamada_Externa.insertarBitacora('RGA Pratus','','01','02','SRV-PSV-095',body,'homeserve/rga/asistenciaApertura',
						idCaso,idContacto,'','','','',orden,'',0,Label.Callout_PUT);
	}
}