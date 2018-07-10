/*
 * Clase que extiende el controlador estándar de Caso para las Visualforce PDF_ComprobanteServicio...
 *
 * @author everis
 */
public without sharing class PDF_ComprobanteServicioControllerExt {

	private Case casoActual {get;set;}
	public String gremio {get;set;}
	public String titulo {get;set;}
	public Date fechaCita {get;set;}
	public String rangoCita {get;set;}

	public List<String> baremosInc_string {get;set;}
	public List<String> baremosEx_string {get;set;}
	public List<String> baremosRec_string {get;set;}
	
	public List<String> baremosInc_subdivisiones{get;set;}
	public List<String> baremosEx_subdivisiones {get;set;}
	public List<String> baremosRec_subdivisiones {get;set;}
	
	public PDF_ComprobanteServicioControllerExt(ApexPages.StandardController stdController) {
		
		PageReference paginaActual = ApexPages.currentPage();
		// 1. Obtener datos del Caso
		Id idCaso = Id.valueOf(paginaActual.getParameters().get('id'));
		casoActual = Util_Caso.getCaseById(new Set<Id>{idCaso}).get(idCaso);
		//casoActual = Util_Caso.getMapaCasos(new Set<Id>{idCaso}).get(idCaso);
		/*casoActual = [SELECT Id,
							 Account.Name,
							 Account.CUE_FOR_DireccionEnvio__c,
							 Account.CUE_EMA_Email__c,
							 Account.Phone,
							 CaseNumber,
							 CAS_DAT_Primera_Cita__c,
							 CAS_EMA_Solicitud_Email__c,
							 CAS_FOR_Descripcion_Baremo__c,
							 CAS_FOR_Fecha_Cita_Reservada__c,
							 CAS_FOR_Rango_Cita_Reservada__c,
							 CAS_LKP_Baremo__c,
							 CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c,
							 CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c,
							 CAS_LKP_Baremo__r.BAR_TXT_Descripcion_Corta__c,
							 CAS_LKP_Orden_Trabajo_Principal__c,
							 CAS_SEL_Gremio_Principal__c,
							 CAS_SEL_Rango_Cita__c,
							 CAS_TFN_Solicitud_Telefono__c
					 FROM Case
					 WHERE Id = :paginaActual.getParameters().get('id') LIMIT 1];*/

		fechaCita = casoActual.CAS_FOR_Fecha_Cita_Reservada__c;
		if(paginaActual.getParameters().containsKey('FechaCita')){
			fechaCita = Date.valueOf(paginaActual.getParameters().get('FechaCita'));
		}
		rangoCita = casoActual.CAS_FOR_Rango_Cita_Reservada__c;
		if(paginaActual.getParameters().containsKey('RangoCita')){
			rangoCita = paginaActual.getParameters().get('RangoCita');
		}

		gremio = Util_Listas_Seleccion.getLabelDesdeAPI('Case','CAS_SEL_Gremio_Principal__c').get(casoActual.CAS_SEL_Gremio_Principal__c);

		// 2. Obtener datos del Baremo
		Id idBaremo = casoActual.CAS_LKP_Baremo__c;
		titulo = casoActual.CAS_FOR_Descripcion_Baremo__c;
		if(casoActual.CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c != null){
			idBaremo = casoActual.CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c;
			titulo = casoActual.CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__r.BAR_TXT_Descripcion_Corta__c;
		}

		// 3. Obtener datos de las condiciones del Baremo
		if(idBaremo != null){
			baremosInc_string = new List<String>();
			baremosEx_string = new List<String>();
			baremosRec_string = new List<String>();		
			baremosInc_subdivisiones = new List<String>();
			baremosEx_subdivisiones= new List<String>();
			baremosRec_subdivisiones = new List<String>();

			List <Baremo_IEC__c> lista_obj_BaremosIncExlRec = Util_Documentacion.queryMapBaremoIEC(new Set<Id>{idBaremo}).values();
			//List <Baremo_IEC__c> lista_obj_BaremosIncExlRec = Util_Documentacion.queryBaremoIEC(idBaremo);
			/*List <Baremo_IEC__c> lista_obj_BaremosIncExlRec = [SELECT Id, 
																	  BAR_IEC_TXT_Texto__c, 
																	  BAR_IEC_SEL_Tipo__c, Name
															   	FROM Baremo_IEC__c
															   	WHERE BAR_IEC_LKP_Baremo__c = :idBaremo
															   	ORDER BY BAR_IEC_NUM_Ordenacion__c];*/
			for(Baremo_IEC__c c : lista_obj_BaremosIncExlRec){
				if(c.BAR_IEC_SEL_Tipo__c == 'Inclusión'){
					baremosInc_string.add(c.BAR_IEC_TXT_Texto__c);
					baremosInc_subdivisiones.add(c.Name);
				}	
				else if(c.BAR_IEC_SEL_Tipo__c == 'Exclusión'){
					baremosEx_string.add(c.BAR_IEC_TXT_Texto__c);
					baremosEx_subdivisiones.add(c.Name);
				}
				else if(c.BAR_IEC_SEL_Tipo__c == 'Condición'){
					baremosRec_string.add(c.BAR_IEC_TXT_Texto__c);
					baremosRec_subdivisiones.add(c.Name);
				}
			}
		}
	}
}