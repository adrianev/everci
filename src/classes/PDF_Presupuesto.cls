/**
 * Clase controladora de las Visualforce "PDF_Presupuesto_XXXXXX" encargadas de generar un presupuesto en PDF.
 * 
 * @author EVERIS
 */
public without sharing class PDF_Presupuesto {
	public Case caso {get; set;}
	public Account cuenta {get; set;}
	public Presupuesto__c presupuesto {get; set;}
	public List<Linea_Presupuesto__c> listaLineasPresu {get; set;}
	public String fechaEmision {get; set;}
	public String fechaAlta {get; set;}
	public Decimal baseImponible {get; set;}
	public Decimal importeTotal {get; set;}
	public Decimal impuesto {get; set;}
	public String tipoDestino {get; set;}
	public String idioma {get; set;}
	public String gremio {get; set;}
	public String estado {get; set;}
	public static Map<String, String> mapaTraduccionCuenta;
	public static Map<String, String> mapaTraduccionWO;
	public static Map<String, String> mapaTraduccionWOLI;

	// 1-feb torcuato
	public List<List<String>> lineasPrimeraPagina {get; set;}
	public List<List<List<String>>> lineasSiguientesPaginas {get; set;}

	public PDF_Presupuesto(ApexPages.standardController stdCtr) {
		PageReference paginaActual = ApexPages.currentPage();
		System.debug('*********paginaActual.getParameters(): ' + paginaActual.getParameters());
		tipoDestino = paginaActual.getParameters().get('tipoDestino');
		idioma = paginaActual.getParameters().get('idioma');
		mapaTraduccionCuenta = Util_Metadatos.getMapaTraduccion(new Set<String>{'Account'});
		mapaTraduccionWO = Util_Metadatos.getMapaTraduccion(new Set<String>{'WorkOrder'});
		mapaTraduccionWOLI = Util_Metadatos.getMapaTraduccion(new Set<String>{'WorkOrderLineItem'});
		baseImponible = 0;
		importeTotal = 0;

		if (!paginaActual.getParameters().containsKey('id')) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			System.debug('*********id');
		}
		else {
			//Recojo el caso que me pasan por parámetro
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_B2B.queryCaso(stdCtr.getRecord().Id);
			if (!listaCasos.isEmpty()) {

				caso = listaCasos.get(0);

				String codigoProvincia = caso.CAS_SEL_DirRiesgo_Estado_Provincia__c;
				Map<String,String> provinciaLabel = Util_Listas_Seleccion.getLabelDesdeAPI('Case','CAS_SEL_DirRiesgo_Estado_Provincia__c');
				caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = provinciaLabel.get(caso.CAS_SEL_DirRiesgo_Estado_Provincia__c);
				
				System.debug('PDF_Presupuesto(): para la provincia ' + caso.CAS_SEL_DirRiesgo_Estado_Provincia__c + ', su nombre de API es ' + codigoProvincia);
				if (mapaTraduccionCuenta.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'CUE_SEL_Provincia__c' + codigoProvincia) != null){
					caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = mapaTraduccionCuenta.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'CUE_SEL_Provincia__c' + codigoProvincia);
				} else {
					caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = mapaTraduccionCuenta.get(idioma + Label.IDE_HOMESERVE + 'CUE_SEL_Provincia__c' + codigoProvincia);
				}
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
				if (cuenta == null) {
					cuenta = new Account();
					cuenta.Name = caso.CAS_FOR_Nombre_Solicitud__c;
				}
				presupuesto = Util_Presupuesto.getPresupuestosActuales(new Set<Id>{caso.Id}).get(caso.Id);
				if(presupuesto != null) {
					if(tipoDestino == Label.TIPO_CONTACTO_DEST_CLIENTE){
						baseImponible = presupuesto.PRE_RES_Importe_Total_Cliente_AI__c;
						importeTotal = presupuesto.PRE_RES_Importe_Total_Cliente_DI__c;
					}
					else {
						baseImponible = presupuesto.PRE_RES_Importe_total__c;
						importeTotal = presupuesto.PRE_RES_Importe_Total_DI__c;
					}
					if(importeTotal != null){
						if(importeTotal != importeTotal.Round()){
							importeTotal = importeTotal.setscale(2);
						}
					}
					impuesto = presupuesto.PRE_RES_Porcentaje_Imp_Cia_Cliente__c;
					fechaEmision = String.valueOf(presupuesto.CreatedDate.Day()).leftPad(2,'0') + '-' 
						+ String.valueOf(presupuesto.CreatedDate.Month()).leftPad(2,'0') + '-'
						+ presupuesto.CreatedDate.Year();
					fechaAlta = '';
					if(caso.CAS_DAT_Fecha_Apertura__c != null){
						fechaAlta = String.valueOf(caso.CAS_DAT_Fecha_Apertura__c.Day()).leftPad(2,'0') + '-' 
							+ String.valueOf(caso.CAS_DAT_Fecha_Apertura__c.Month()).leftPad(2,'0') + '-'
							+ caso.CAS_DAT_Fecha_Apertura__c.Year();
					}
					listaLineasPresu = Util_Presupuesto.getLineaPresupuestoByPresupuesto(new Set<Id>{presupuesto.Id}).values();
					//listaLineasPresu = Util_Presupuesto.queryLineasPresupuesto(presupuesto.Id);

					/*
					 *  1-feb-2018  torcuato
					 *  Listas para paginar Presupuesto PDF
					 *  Lista con sublistas de elementos
					 *  1ª lista: 10 elementos
					 *  2ª -> nª: lista con n sublistas de 24 elementos cada una
					 */
					lineasPrimeraPagina = new List<List<String>>();
					lineasSiguientesPaginas = new List<List<List<String>>>();

					Integer countLineas = listaLineasPresu.size();
					Integer countlineasPDF = 0;
					Integer sublistaPDF = 0;

					//test
					//countLineas =30;

					for (Integer i=0; i<3; i++) {
						if (i<countLineas) {
							List<string> lineaPresupuesto = new List<String>();	
							System.debug('PDF_Presupuesto(): para el gremio ' + listaLineasPresu.get(i).PREL_TXT_Gremio__c + ', su nombre de API es ' + listaLineasPresu.get(i).PREL_TXT_Codigo_Gremio__c);
							if (mapaTraduccionWO.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'OTR_SEL_Gremio__c' + listaLineasPresu.get(i).PREL_TXT_Codigo_Gremio__c) != null){
								gremio = mapaTraduccionWO.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'OTR_SEL_Gremio__c' + listaLineasPresu.get(i).PREL_TXT_Codigo_Gremio__c);
							} else {
								gremio = mapaTraduccionWO.get(idioma + Label.IDE_HOMESERVE + 'OTR_SEL_Gremio__c' + listaLineasPresu.get(i).PREL_TXT_Codigo_Gremio__c);
							}
							if(gremio != null){
								lineaPresupuesto.add(gremio);	
							} else {
								lineaPresupuesto.add('');
							}
							if(listaLineasPresu.get(i).PREL_TXT_Descripcion__c != null){
								lineaPresupuesto.add(listaLineasPresu.get(i).PREL_TXT_Descripcion__c);	
							} else {
								lineaPresupuesto.add('');
							}
							if(listaLineasPresu.get(i).PREL_TXT_Detalle__c != null){
								lineaPresupuesto.add(listaLineasPresu.get(i).PREL_TXT_Detalle__c);	
							} else {
								lineaPresupuesto.add('');
							}
							if(listaLineasPresu.get(i).PREL_NUM_Unidades__c != null){
								lineaPresupuesto.add(String.valueOf(listaLineasPresu.get(i).PREL_NUM_Unidades__c));	
							} else {
								lineaPresupuesto.add('');
							}
							System.debug('PDF_Presupuesto(): para el estado ' + listaLineasPresu.get(i).PREL_TXT_Estado__c + ', su nombre de API es ' + listaLineasPresu.get(i).PREL_TXT_Codigo_Estado__c);	
							if (mapaTraduccionWOLI.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'Status' + listaLineasPresu.get(i).PREL_TXT_Codigo_Estado__c) != null){
								estado = mapaTraduccionWOLI.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'Status' + listaLineasPresu.get(i).PREL_TXT_Codigo_Estado__c);
							} else {
								estado = mapaTraduccionWOLI.get(idioma + Label.IDE_HOMESERVE + 'Status' + listaLineasPresu.get(i).PREL_TXT_Codigo_Estado__c);
							}
							if(estado != null){
								lineaPresupuesto.add(estado);	
							} else {
								lineaPresupuesto.add('');
							}
							if(tipoDestino == Label.TIPO_CONTACTO_DEST_CLIENTE){
								if(listaLineasPresu.get(i).PREL_DIV_Cargar_Cliente_AI__c != null){
									lineaPresupuesto.add(String.valueOf(listaLineasPresu.get(i).PREL_DIV_Cargar_Cliente_AI__c)+' €');	
								} else {
									lineaPresupuesto.add('');
								}
							} else { 
								if(listaLineasPresu.get(i).PREL_DIV_Facturacion_Total_AI__c != null){
									lineaPresupuesto.add(String.valueOf(listaLineasPresu.get(i).PREL_DIV_Facturacion_Total_AI__c)+' €');	
								} else {
									lineaPresupuesto.add('');
								}
							}																												
							lineasPrimeraPagina.add(lineaPresupuesto);
						} else {
							lineasPrimeraPagina.add(new List<String>{'','','','','',''}) ;
						}
						countlineasPDF++;
					}
					while(countLineasPDF < countLineas) {
						lineasSiguientesPaginas.add(new List<List<String>>{});
						for (Integer i=0; i<13; i++) {
							if (countlineasPDF<countLineas) {
								List<string> lineaPresupuesto = new List<String>();	
								System.debug('PDF_Presupuesto(): para el gremio ' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Gremio__c + ', su nombre de API es ' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Codigo_Gremio__c);
								if (mapaTraduccionWO.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'OTR_SEL_Gremio__c' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Codigo_Gremio__c) != null){
									gremio = mapaTraduccionWO.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'OTR_SEL_Gremio__c' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Codigo_Gremio__c);
								} else {
									gremio = mapaTraduccionWO.get(idioma + Label.IDE_HOMESERVE + 'OTR_SEL_Gremio__c' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Codigo_Gremio__c);
								}
								if(gremio != null){
									lineaPresupuesto.add(gremio);	
								} else {
									lineaPresupuesto.add('');
								}	
								if(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Descripcion__c != null){
									lineaPresupuesto.add(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Descripcion__c);	
								} else {
									lineaPresupuesto.add('');
								}
								if(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Detalle__c != null){
									lineaPresupuesto.add(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Detalle__c);	
								} else {
									lineaPresupuesto.add('');
								}
								if(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_NUM_Unidades__c != null){
									lineaPresupuesto.add(String.valueOf(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_NUM_Unidades__c));	
								} else {
									lineaPresupuesto.add('');
								}
								if (mapaTraduccionWOLI.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'Status' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Codigo_Estado__c) != null){
									estado = mapaTraduccionWOLI.get(idioma + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c + 'Status' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Codigo_Estado__c);
								} else {
									estado = mapaTraduccionWOLI.get(idioma + Label.IDE_HOMESERVE + 'Status' + listaLineasPresu.get(i+3+sublistaPDF*13).PREL_TXT_Codigo_Estado__c);
								}
								if(estado != null){
									lineaPresupuesto.add(estado);	
								} else {
									lineaPresupuesto.add('');
								}
								if(tipoDestino == Label.TIPO_CONTACTO_DEST_CLIENTE){
									if(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_DIV_Cargar_Cliente_AI__c != null){
										lineaPresupuesto.add(String.valueOf(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_DIV_Cargar_Cliente_AI__c)+' €');	
									} else {
										lineaPresupuesto.add('');
									}
								} else { 
									if(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_DIV_Facturacion_Total_AI__c != null){
										lineaPresupuesto.add(String.valueOf(listaLineasPresu.get(i+3+sublistaPDF*13).PREL_DIV_Facturacion_Total_AI__c)+' €');	
									} else {
										lineaPresupuesto.add('');
									}
								}								
								lineasSiguientesPaginas[sublistaPDF].add(lineaPresupuesto);
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
	}//FIN CONSTRUCTOR PDF_Presupuesto
}