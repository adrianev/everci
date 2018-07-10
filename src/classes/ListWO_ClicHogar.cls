global without sharing class ListWO_ClicHogar {
	public Boolean OTR_CAS_Servicio_Encuestado{get;set;}
	public String OTR_SEL_Gremio{get;set;}
	public List<Rest_ClicHogar_ConsultaCaso_RP.Rest_Idioma> literalGremio{get;set;}
	public String CreatedDate{get;set;}
	public String Status{get;set;}
	public List<Rest_ClicHogar_ConsultaCaso_RP.Rest_Idioma> literalEstado{get;set;}
	public String fechaProximaAccion{get;set;}
	public String fechaTerminacion{get;set;}
	public List<ListHistEstados_ClicHogar> listadoHistoricoEstados{get;set;}
	public List<ListPartidas_ClicHogar> listadoPartidas{get;set;}
}