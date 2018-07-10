/**
 * Clase que nos devuelve el número de pólizas activas de una determinada compañía
 *
 * @author everis
 * @version 1.0
 */
@RestResource(urlMapping='/facturador/poliza/*')  
global without sharing class Rest_PolizasActivasCompania {
	global class Resultado{
		public String code = '';
		public String message = '';
		public String resultado = '';
	}
	/**
	 * Devuelve el número de pólizas activas.
	 *
	 * @param CUE_TXT_Identificador : Identificador de la compañía de la que se buscan las pólizas
	 *
	 * @return número de pólizas activas.
	 *
	 */
	@HttpGet
	global static Resultado doGet() {

		RestRequest req = RestContext.request;
		String numPolizasActivas;
		String compania;
		String infoFee;

		/*if (test.isRunningTest()) {
			compania = 	'1042';
			infoFee = 'true';
			/*numPolizasActivas = Fachada.consultaPolizaActivas(compania);
		}else{*/
			compania = RestContext.request.params.get('identificadorCompania');
			//infoFee = RestContext.request.params.get('infoFee');
			//system.debug('infoFee'+infoFee+'CUE_TXT_Identificador:'+compania);
			// if(infoFee == 'True'){
			system.debug('>>>>>IdentificadorCompania: ' + compania);
			numPolizasActivas = Fachada.consultaPolizaActivas(compania);
			//}

		//}
		system.debug('numPolizasActivas: '+numPolizasActivas);
		Resultado response = new Resultado();
		if(numPolizasActivas == ''){
			response.code = '002';
			response.message = 'Compañía no encontrada';
			response.resultado = '';
		}else if(numPolizasActivas == null){
			response.code = '002';
			response.message = 'Error de conexión';
			response.resultado = '';
		}else{
			response.code = '001';
			response.message = 'Ok';
			response.resultado = numPolizasActivas;        	
		}
		return response;
	}
}