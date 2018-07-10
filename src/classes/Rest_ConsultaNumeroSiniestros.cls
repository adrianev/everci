/**
 * Todo: Clase que se utilizará para contabilizar el número de siniestros de Previsora y SegurCaixa
 * @author everis
 * @version 1.0
 */
@RestResource(urlMapping='/facturador/siniestro/*')
global without sharing class Rest_ConsultaNumeroSiniestros {

	/**
	 * Método que contabiliza el número de siniestros de Previsora y SegurCaixa
	 *
	 * @param identificadorCompania: identificador de la compañia
	 * @param fechaInicio: fecha de inicio (solo utilizada en SegurCaixa)
	 * @param fechaFin: fecha de fin (solo utilizada en SegurCaixa)
	 * @param codigoConsulta: código de consulta (1: previsora, 2: segurcaixa)
	 *
	 * @return información correspondiente al número de siniestros
	 *
	 */
	@HttpGet
	global static Rest_ConsultaNumeroSiniestros_RP consultaNumSiniestros(){

		Rest_ConsultaNumeroSiniestros_RP respuesta = new Rest_ConsultaNumeroSiniestros_RP();
		Integer contador = 0;
		Integer contadorHogar = 0;
		Integer contadorMantenimiento = 0;
		Integer contadorPremium = 0;
		Integer contadorSegmentado = 0;
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String identificador = RestContext.request.params.get('identificadorCompania');
		String fechaInicio = RestContext.request.params.get('fechaInicio');
		String fechaFin = RestContext.request.params.get('fechaFin');
		String codigoConsulta = RestContext.request.params.get('codigoConsulta');
		system.debug('identificador '+identificador);
		system.debug('codigoConsulta '+codigoConsulta);
		system.debug('fechaIni '+fechaInicio);
		system.debug('fechaFin '+fechaFin);
		if(codigoConsulta == '1' && identificador == Label.IDE_PREVISORA_BILBAINA){
			Set<Id> listaCasos = new Set<Id>();
			for(WorkOrder aux2:[SELECT CaseId FROM WorkOrder WHERE OTR_CAS_Orden_Trabajo_Facturada__c = True AND Case.Account.CUE_TXT_Identificador__c =:Label.IDE_PREVISORA_BILBAINA
								AND RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)]){
				listaCasos.add(aux2.CaseId);
			}
			contador = 0;
			contador = [SELECT count() FROM Case WHERE Account.CUE_TXT_Identificador__c =: identificador AND Status = '003' AND Id IN: listaCasos AND(Type = '1' OR Type = '2' OR Type = '3')];
			respuesta.code = '001';
			respuesta.siniestrosHogar = '';
			respuesta.siniestrosMantenimiento = '';
			respuesta.siniestrosPremium = '';
			respuesta.siniestrosSegmentado = '';
			respuesta.siniestrosDeclarados = '' + contador;
			respuesta.message = 'Validación Correcta';


		}else if(codigoConsulta == '2' && identificador == Label.IDE_SEGURCAIXA){

			Date dInit = date.parse(fechaInicio);
			DateTime dtInit = datetime.newInstance(dInit.year(), dInit.month(),dInit.day());
			Date dEnd = date.parse(fechaFin);
			Datetime dtEnd = datetime.newInstance(dEnd.year(), dEnd.month(),dEnd.day());
			List<Case> listaCasos = new List<Case>([SELECT AccountId,CAS_LKP_PolizaContrato__c,Id FROM Case WHERE CAS_LKP_Compania__r.CUE_TXT_Identificador__c = :identificador AND createdDate >= :dtInit AND createdDate <= :dtEnd]);
			if(listaCasos.size() >0){
				//MapidCasoIdPoliza
				Map<String, String> mapListaCasos = new Map<String, String>();
				for (Case lis : listaCasos){
					mapListaCasos.put(lis.Id,lis.CAS_LKP_PolizaContrato__c);
				}

				//MapPolizaCaso
				Map<String, String> mapListaPolizas = new Map<String, String>();
				for(ServiceContract lis:[SELECT POL_LKP_Producto_Cia__c, Id FROM ServiceContract WHERE Id IN: mapListaCasos.values()]){
					mapListaPolizas.put(lis.Id,lis.POL_LKP_Producto_Cia__c);
					
				}
				//Ahora hacemos un nuevo mapa recorriendo mapListaCasos y mapListaPolizas, de tal modo que obtengamos un maping con id caso e id producto cia
				//Map<String, String> mapIdCas_IdProd = new Map<String, String>();
				List<String> listaProductoCia = new List<String>();
				for(String idCaso : mapListaCasos.keySet()){	
					String valorCaso = mapListaCasos.get(idCaso);
					for(String idPoliza: mapListaPolizas.keySet()){
						if(valorCaso == idPoliza){
							String idProducto = mapListaPolizas.get(idPoliza);
							if(idProducto != null)
								listaProductoCia.add(idProducto);
						}

					}
				}

				List<String> listaProCIA = new List<String>();
				List<Producto_CIA__c> listaProducto = new List<Producto_CIA__c>([SELECT Id, PRD_LKP_Tipo_Producto_CIA__c FROM Producto_CIA__c WHERE Id IN :listaProductoCia]);
				for(String aux:listaProductoCia){
					for(Producto_CIA__c listProd:listaProducto){
						if(listProd.Id == aux){
							listaProCIA.add(listProd.PRD_LKP_Tipo_Producto_CIA__c);
						}
					}
				}

				List<Tipo_Producto_CIA__c> listaTipoProducto = new List<Tipo_Producto_CIA__c>([SELECT Id, TPR_SEL_Tipo_Producto__c FROM Tipo_Producto_CIA__c WHERE Id IN:listaProCIA]);
				List<String> listaProdCiaTotal = new List<String>();
				for(String listaProdCia:listaProCIA){
					for(Tipo_Producto_CIA__c tipoProducto:listaTipoProducto){
						if(listaProdCia == tipoProducto.Id){
							listaProdCiaTotal.add(tipoProducto.TPR_SEL_Tipo_Producto__c);
						}
					}
				}
				
				/*
				*
				* Se miran de que tipo es cada Siniestro para sumarlo al contador correspondiente
				*
				*/
				for(String lista : listaProdCiaTotal){
					if (lista == '01'){
						contadorHogar = contadorHogar +1;
					}
					if (lista == '06'){
						contadorMantenimiento = contadorMantenimiento +1;
					}
					if (lista == '07'){
						contadorPremium = contadorPremium +1;
					}
					if (lista == '08'){
						contadorSegmentado = contadorSegmentado +1;
					}				
				}

				respuesta.code = '001';
				respuesta.siniestrosDeclarados = ' ';
				respuesta.siniestrosHogar = String.valueOf(contadorHogar);
				respuesta.siniestrosMantenimiento = String.valueOf(contadorMantenimiento);
				respuesta.siniestrosPremium = String.valueOf(contadorPremium);
				respuesta.siniestrosSegmentado = String.valueOf(contadorSegmentado);
				respuesta.message = 'Validación correcta';


			}else {
				respuesta.code = '002';
				respuesta.siniestrosDeclarados = ' ';
				respuesta.siniestrosHogar = '';
				respuesta.siniestrosMantenimiento ='';
				respuesta.siniestrosPremium = '';
				respuesta.siniestrosSegmentado ='';
				respuesta.message = 'Error al consultar número de siniestros';	
			}
		}else{
			respuesta.code = '002';
			respuesta.siniestrosDeclarados = ' ';
			respuesta.siniestrosHogar = '';
			respuesta.siniestrosMantenimiento ='';
			respuesta.siniestrosPremium = '';
			respuesta.siniestrosSegmentado ='';
			respuesta.message = 'Error al consultar numero de siniestros';	
		}
		return respuesta;
	} 
}