/**
 * Clase que es la respuesta del servicio "Rest_ClicHogar_DevolucionMens"
 *
 * @author EVERIS
 * 
 */

global without sharing class Rest_ClicHogar_DevolucionMens_RP {


	public String message{get;set;}
	public String code{get;set;}
	public List<mensajes> listadoMensajes{get;set;}

	/**
	 * Clase para devolver los campos necesarios para cada mensaje
	 *
	 */
	public without sharing class mensajes {
		public String Id;
		public String MCH_TXT_asunto;
		public String MCH_TXT_consulta;
		public Datetime MCH_DAT_fecha_alta_consulta;
		public Datetime MCH_DAT_fecha_respuesta;
		public Boolean MCH_CAS_estado;
		public String MCH_TXT_respuesta;
	}


}