/**
 * Clase de respuesta de la clase 'Rest_ClicHogar_ConsultaCaso', en la que se devuelven campos de caso y un listado de órdenes de trabajo
 * Utilizado en la clase: 'Rest_ClicHogar_ConsultaCaso'
 *
 * @author EVERIS
 * 
 */

global without sharing class Rest_ClicHogar_ConsultaCaso_RP {
	public String code{get;set;}
	public String message{get;set;}
	public String CAS_LKP_PolizaContrato{get;set;}
	public String CAS_TXT_Num_Caso_HS{get;set;}
	public String Type{get;set;}
	public List<Rest_Idioma> literalTipo{get;set;}
	public String CAS_SEL_Grupo_Causa{get;set;}
	public List<Rest_Idioma> literalGrupoCausa{get;set;}
	public List<Rest_Idioma> causaAveria{get;set;}
	public String GSIN_FOR_Descripcion_Garantia{get;set;}
	public String CAS_FOR_Rango_Cita_Reservada{get;set;}
	public String CAS_FOR_Fecha_Cita_Reservada{get;set;}
	public String siniestroAceptado {get;set;}
	public String averiaCubierta {get;set;}
	public String CAS_CAS_Requiere_Perito {get;set;}
	public String PRD_TXT_Identificador {get;set;}
	public String Status{get;set;}
	public Boolean CAS_CAS_Siniestro_Encuestado {get;set;}
	public String POL_SEL_Idioma{get;set;}
	public List<Rest_VDN> datosTelefonia{get;set;}
	public List<ListWO_ClicHogar> listadoOrdenesTrabajo{get;set;}
	
	public without sharing class Rest_Idioma {
		public String ES;
		public String CT;
	}
	
	public without sharing class Rest_VDN {
		public String VDN_TLF_Telefono;
		public String VDN_SEL_Idioma;
		public List<Rest_VDNmdt> datosLlamadaEntrante;
	}
	
	public without sharing class Rest_VDNmdt {
		public String ServiceId;
		public String LoadId;
	}
	
}