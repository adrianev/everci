/**
 * Clase controladora de la Visualforce "HistoricoEstadosOT" encargada mostrar
 * el historial de cambios de estado de una Orden de Trabajo.
 * 
 * @author EVERIS
 * 
 */
public without sharing class HistoricoEstadosOT {
	public List<EntradaHistoricoEstado> listaHistorico {get; set;}
	public String NOMBRE_OBJETO = 'WorkOrder';
	public String NOMBRE_CAMPO_ESTADO = 'Status';

	public HistoricoEstadosOT(ApexPages.StandardController stdc){
		List<String> fields = new List<String> {
			'CreatedBy.Name',
			'CreatedBy.Profile.Name',
			'CreatedDate'
		};
		if (!Test.isRunningTest()){
			stdc.addFields(fields);
		}
		WorkOrder ot = (WorkOrder) stdc.getRecord();
		
		Map<String, String> mapaLabel = Util_Listas_Seleccion.getLabelDesdeAPI(NOMBRE_OBJETO, NOMBRE_CAMPO_ESTADO);
		
		listaHistorico = new List<EntradaHistoricoEstado>();
		
		List<WorkOrderHistory> listaCambios = Util_Historico.getHistoricoCampoOT(new Set<Id>{ot.Id},new Set<String>{NOMBRE_CAMPO_ESTADO}).values();

		DateTime fechaFin = null;
		WorkOrderHistory cambioMasAntiguo = null;
		for(WorkOrderHistory cambio : listaCambios){
			String estadoAPI = String.valueOf(cambio.NewValue);
			listaHistorico.add(new EntradaHistoricoEstado(
								mapaLabel.get(estadoAPI), estadoAPI,
								cambio.CreatedDate, fechaFin,
								cambio.CreatedBy.Name, cambio.CreatedBy.Profile.Name));
			fechaFin = cambio.CreatedDate;
			cambioMasAntiguo = cambio;
		}
		if(cambioMasAntiguo != null){
			String estadoAPI = String.valueOf(cambioMasAntiguo.OldValue);
			listaHistorico.add(new EntradaHistoricoEstado(
								mapaLabel.get(estadoAPI), estadoAPI,
								ot.CreatedDate, cambioMasAntiguo.CreatedDate,
								ot.CreatedBy.Name, ot.CreatedBy.Profile.Name));
		}

	}
	
	public without sharing class EntradaHistoricoEstado {
		public String estado {get; set;}
		public String estadoAPI {get; set;}
		public DateTime fechaInicio {get; set;}
		public DateTime fechaFin {get; set;}
		public String usuarioInicio {get; set;}
		public String perfilUsuarioInicio {get; set;}

		public EntradaHistoricoEstado(String estado, String estadoAPI,
								DateTime fechaInicio, DateTime fechaFin,
								String usuarioInicio, String perfilUsuarioInicio){
			this.estado = estado;
			this.estadoAPI = estadoAPI;
			this.fechaInicio = fechaInicio;
			this.fechaFin = fechaFin;
			this.usuarioInicio = usuarioInicio;
			this.perfilUsuarioInicio = perfilUsuarioInicio;
		}
	}
}