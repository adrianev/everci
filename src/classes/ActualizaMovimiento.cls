/*
 * Actualiza Movimiento
 * Servicio para actualizar el objeto Movimientos según el fichero de recepción de NN
 * 20/11/2017
 * @author everis
 *
 */

global without sharing class ActualizaMovimiento {
	
	webservice static ActualizaMovimiento_RP actualizarMovimiento (ActualizaMovimiento_RQ actualizaMovimiento) {
		
		Map<String,ActualizaMovimiento_RQ> mapaSiniSC;//Mapa de registros de siniestros de Segurcaixa separados por bloques
		List<String> listaFicheros;
		ActualizaMovimiento_RP res = new ActualizaMovimiento_RP();
		res.resultado='"OK"';
		res.errorCode='""';
		res.errorMessage='""';
		System.debug('Entra en ActualizaMovimiento ' + actualizaMovimiento);
		//try{
			ActualizaMovimiento_Aux a;
			if(actualizaMovimiento.tipoFichero=='siniSC'){//Si es el fichero de SegurCaixa lo separa primero y lo ejecuta una vez por cada parte del fichero
				mapaSiniSC=actualizaMovimiento.trataSiniSegurCaixa();
				listaFicheros = new List<String>(mapaSiniSC.keySet());
				if(!listaFicheros.isEmpty() && mapaSiniSC.get(listaFicheros.get(0)).done == 'true'){//Si es el último registro recibido se cambiarán los flags de los psudoregistros generados para que sólo el último sea = 'true'
					for(Integer i = 0; i<listaFicheros.Size()-1;i++){
						mapaSiniSC.get(listaFicheros.get(i)).done = 'false';
					}
				}
				for(String tipoFicheroSc : listaFicheros){
					a = new ActualizaMovimiento_Aux(mapaSiniSC.get(tipoFicheroSc));
					a.ubicaFichero();
				}
			} else{
				a = new ActualizaMovimiento_Aux(actualizaMovimiento);
				a.ubicaFichero();
			}
			
		//} catch(Exception e){
			
			/*res.resultado='"KO"';
			res.errorCode = '"ErrorPorDefinir"';
			res.errorCode = '"ErrorPorDefinir"';*/
			//system.debug('Fallo en webService ActualizaMovimiento' + res + ' '+e);
		//}
		
		return res;
		
	}
	
	
}