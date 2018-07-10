/**
 * Clase controladora de las Visualforce "PDF_Albaran_XXXXXX" encargadas de generar un Albaran en PDF.
 * 
 * @author EVERIS
 */
public without sharing class PDF_Albaran {
	public Case caso {get; set;}
	public Account cuenta {get; set;}
	public Account HomeServe {get; set;}
	public ServiceAppointment cita {get; set;}
	public WorkOrder ordenTrabajo {get; set;}
	public Contact contacto {get; set;}
	public List<WorkOrderLineItem> listaPartidas {get; set;}
	public String idioma {get; set;}
	public List<List<String>> lineasPrimeraPagina {get; set;}
	public List<List<List<String>>> lineasSiguientesPaginas {get; set;}
	public Attachment imgFirmaCli {get; set;}
	public Attachment imgFirmaProf {get; set;}
	public Decimal impuesto {get; set;}
	public String fechaServicio {get; set;}
	public String fechaCita {get; set;}
	public String horaInicio {get; set;}
	public String horaFin {get; set;}
	public String nombreContacto {get; set;}
	public String anio {get; set;}
	public String mes {get; set;}
	public String dia {get; set;}
	public String fechaOcurrencia{get; set;}
	public String resultadoVisita {get; set;}
	private static Map<String, String> mapaTraduccionCuenta;
	private static Map<String, String> mapaTraduccionWO;
	private static Map<String, String> mapaTraduccionWOLI;

	public PDF_Albaran(ApexPages.standardController stdCtr) {
		PageReference paginaActual = ApexPages.currentPage();
		System.debug('*********paginaActual.getParameters(): ' + paginaActual.getParameters());
		idioma = paginaActual.getParameters().get('idioma');
		anio = String.valueOf(DateTime.Now().year());
		mes = String.valueOf(DateTime.Now().month());
		dia = String.valueOf(DateTime.Now().day());
		mapaTraduccionCuenta = Util_Metadatos.getMapaTraduccion(new Set<String>{'Account'});
		mapaTraduccionWO = Util_Metadatos.getMapaTraduccion(new Set<String>{'WorkOrder'});
		mapaTraduccionWOLI = Util_Metadatos.getMapaTraduccion(new Set<String>{'WorkOrderLineItem'});

		if (!paginaActual.getParameters().containsKey('id')) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			//Recojo la cita de servicio
			cita = Util_Cita_Servicio.getMapCitasById(new Set<Id>{paginaActual.getParameters().get('id')}).get(paginaActual.getParameters().get('id'));
			if(cita != null) {
				if(cita.ActualStartTime != null) {
					fechaCita = formatoFecha(cita.ActualStartTime);
					horaInicio = formatoHora(cita.ActualStartTime);
				}
				horaFin = formatoHora(DateTime.Now());
				system.debug('[AMC] cita de servicio' + cita);
				String firmaCliente = cita.AppointmentNumber + Label.IMG_SUFIJO_FIRMA_CLIENTE;
				String firmaProfesional = cita.AppointmentNumber + Label.IMG_SUFIJO_FIRMA_PROFESIONAL;
				List <Attachment> firmasCliente = Util_Attachment.queryMapAttachment(new set<String>{firmaCliente,firmaProfesional}).values();
				if(!firmasCliente.isEmpty() && firmasCliente.size() > 1){
					imgFirmaCli = firmasCliente.get(0);
					imgFirmaProf = firmasCliente.get(1);
				}
				//recoge la orden de trabajo para sacar la cita de servicio
				List<WorkOrder> ordenesTrabajo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{cita.ParentRecordId}).values();
				//List<WorkOrder> ordenesTrabajo = Util_Orden_Trabajo.queryOT(cita.ParentRecordId,null, null);
				if(ordenesTrabajo.isEmpty()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				}
				else {
					ordenTrabajo = ordenesTrabajo.get(0);

					List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{ordenTrabajo.CaseId}).values();
					//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{ordenTrabajo.CaseId}).values();
					//List<Case> listaCasos = Util_B2B.queryCaso(ordenTrabajo.CaseId);
					if (!listaCasos.isEmpty()) {
						caso = listaCasos.get(0);
						if(caso.CAS_DAT_Fecha_Ocurrencia__c != null) {
							fechaOcurrencia = formatoFecha(caso.CAS_DAT_Fecha_Ocurrencia__c);
						}
						nombreContacto = caso.CAS_TXT_Nombre__c + ' ' + caso.CAS_TXT_Apellidos__c;
						resultadoVisita = Util_Listas_seleccion.getLabelDesdeAPI('WorkOrder','Status').get(ordenTrabajo.Status);
						if(mapaTraduccionWO.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'Status' + ordenTrabajo.Status) != null){
							resultadoVisita = mapaTraduccionWO.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'Status' + ordenTrabajo.Status);
						}
						else if(mapaTraduccionWO.get(idioma + Label.IDE_HOMESERVE + 'Status' + ordenTrabajo.Status) != null){
							resultadoVisita = mapaTraduccionWO.get(idioma + Label.IDE_HOMESERVE + 'Status' + ordenTrabajo.Status);
						}
						String codigoProvincia = caso.CAS_SEL_DirRiesgo_Estado_Provincia__c;
						Map<String,String> provinciaLabel = Util_Listas_Seleccion.getLabelDesdeAPI('Case','CAS_SEL_DirRiesgo_Estado_Provincia__c');
						caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = provinciaLabel.get(caso.CAS_SEL_DirRiesgo_Estado_Provincia__c);
						System.debug('PDF_Albaran(): para la provincia ' + caso.CAS_SEL_DirRiesgo_Estado_Provincia__c + ', su nombre de API es ' + codigoProvincia);
						if (mapaTraduccionCuenta.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'CUE_SEL_Provincia__c' + codigoProvincia) != null){
							caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = mapaTraduccionCuenta.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'CUE_SEL_Provincia__c' + codigoProvincia);
						}
						else {
							caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = mapaTraduccionCuenta.get(idioma + Label.IDE_HOMESERVE + 'CUE_SEL_Provincia__c' + codigoProvincia);
						}
						cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
					}
					fechaServicio = ordenTrabajo.CreatedDate.day()+'-'+ordenTrabajo.CreatedDate.month()+'-'+ordenTrabajo.CreatedDate.year();
					listaPartidas = Util_Orden_Trabajo.getListaPartidasOT(ordenTrabajo.Id, true);
					if(!listaPartidas.isEmpty()) {
						impuesto = listaPartidas.get(0).PAR_POR_Porcentaje_Imp_Cia_Cliente__c;
					}
					//Lógica para ordenar las partidas
					lineasPrimeraPagina = new List<List<String>>();
					lineasSiguientesPaginas = new List<List<List<String>>>();

					Integer countLineas = listaPartidas.size();
					Integer countlineasPDF = 0;
					Integer sublistaPDF = 0;
					for (Integer i=0; i<2; i++) {
						if(countLineas>i) {
							List<String>partidasTexto = new List<String>();
							if(listaPartidas.get(i).PAR_TXT_Baremo_Codigo__c != null){
								partidasTexto.add(String.valueOf(listaPartidas.get(i).PAR_TXT_Baremo_Codigo__c));	
							} else {
								partidasTexto.add('');
							}
							if(listaPartidas.get(i).Description != null){
								partidasTexto.add(String.valueOf(listaPartidas.get(i).Description));	
							} else {
								partidasTexto.add('');
							}
							if(listaPartidas.get(i).PAR_NUM_Unidades__c != null){
								partidasTexto.add(String.valueOf(listaPartidas.get(i).PAR_NUM_Unidades__c));	
							} else {
								partidasTexto.add('');
							}
							if(listaPartidas.get(i).PAR_FOR_Precio_Unitario_Venta_Cli__c != null){
								partidasTexto.add(String.valueOf(listaPartidas.get(i).PAR_FOR_Precio_Unitario_Venta_Cli__c));	
							} else {
								partidasTexto.add('');
							}
							if(listaPartidas.get(i).PAR_DIV_Cargar_Cliente_AI__c != null){
								partidasTexto.add(String.valueOf(listaPartidas.get(i).PAR_DIV_Cargar_Cliente_AI__c));	
							} else {
								partidasTexto.add('');
							}
							lineasPrimeraPagina.add(partidasTexto);
						} else {
							lineasPrimeraPagina.add(new List<String>{'','','','','',''}) ;
						}
						countlineasPDF++;
					}
					while(countLineasPDF < countLineas) {
						lineasSiguientesPaginas.add(new List<List<String>>{});
						for (Integer i=0; i<13; i++) {
							if (countlineasPDF<countLineas) {
								List<string> partidasTexto = new List<String>();	
								
								if(listaPartidas.get(i+2+sublistaPDF*13).PAR_TXT_Baremo_Codigo__c != null){
									partidasTexto.add(listaPartidas.get(i+2+sublistaPDF*13).PAR_TXT_Baremo_Codigo__c);	
								} else {
									partidasTexto.add('');
								}
								if(listaPartidas.get(i+2+sublistaPDF*13).Description != null){
									partidasTexto.add(listaPartidas.get(i+2+sublistaPDF*13).Description);	
								} else {
									partidasTexto.add('');
								}
								if(listaPartidas.get(i+2+sublistaPDF*13).PAR_NUM_Unidades__c != null){
									partidasTexto.add(String.valueOf(listaPartidas.get(i+2+sublistaPDF*13).PAR_NUM_Unidades__c));	
								} else {
									partidasTexto.add('');
								}
								if(listaPartidas.get(i+2+sublistaPDF*13).PAR_FOR_Precio_Unitario_Venta_Cli__c != null){
									partidasTexto.add(String.valueOf(listaPartidas.get(i+2+sublistaPDF*13).PAR_FOR_Precio_Unitario_Venta_Cli__c));	
								} else {
									partidasTexto.add('');
								}
								if(listaPartidas.get(i+2+sublistaPDF*13).PAR_DIV_Cargar_Cliente_AI__c != null){
									partidasTexto.add(String.valueOf(listaPartidas.get(i+2+sublistaPDF*13).PAR_DIV_Cargar_Cliente_AI__c));	
								} else {
									partidasTexto.add('');
								}
								lineasSiguientesPaginas[sublistaPDF].add(partidasTexto);
							} else {
								lineasSiguientesPaginas[sublistaPDF].add(new List<String>{'','','','','',''});
							}
							countlineasPDF++;
						}
						sublistaPDF++;
					}
				}
			}
		}
	}//FIN CONSTRUCTOR PDF_Albaran
	
	public String formatoFecha(DateTime fecha) {
		String fechaFormato = fecha.day() + '-' + fecha.month() + '-' + fecha.year();
		return fechaFormato;
	}
	
	public String formatoHora (DateTime fecha) {
		String retorno;
		
		if(fecha.hour() < 10 && fecha.minute()<10){
			retorno = '0' + fecha.hour() + ':0' + fecha.minute();
		}else if (fecha.hour() < 10){
			retorno = '0' + fecha.hour() + ':' + fecha.minute();	
		}else if(fecha.minute()<10) {
			retorno = fecha.hour() + ':0' + fecha.minute();
		}else {
			retorno = fecha.hour() + ':' + fecha.minute();
		}
		return retorno;
	}
}