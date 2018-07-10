/**
 * Clase de funciones auxiliares relativas a los Identificadores.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Identificadores{
	//Llamamos al metodo que devuelve el nombre de los Tipos de Registro
	private final static Id recordTypeReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
	private final static Id recordTypeIdSini = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
	private final static Id recordTypeIdSolicitudSini = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_SINIESTRO);
	private final static Id recordTypeIdServB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C);
	private final static Id recordTypeIdServB2B = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
	private final static Id recordTypeReparable = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA);
	private final static Id recordTypeIdSolB2B_B2B2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
	private final static Id recordTypeIdSolicitudB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);


	/**
	 * Genera el Numero de Intervencion HomeServe de Caso para sus diferentes RecordType
	 * 
	 * @param caso Caso para el que se va a generar el Numero de Intervención
	 *
	 * @return numHS Numero de Intervencion HomeServe de Caso generado
	 */
	public static String generarNumeroHS(Case caso, WorkOrder ordenTrabajo, Procedencia__c procedencia){
		String numHS = null;
		if (caso != null || ordenTrabajo != null){

			// GENERAR Nº DE CASO HOMESERVE
			if (caso != null) {

				// Generar Nº de Caso HomeServe para Siniestros
				if (caso.RecordTypeId == recordTypeIdSolicitudSini || caso.RecordTypeId == recordTypeIdSini){
					if (caso.Type != null && caso.CAS_LKP_Compania__c != null && procedencia != null){
						Account compania = Util_Compania.CIA_BY_IDSF.get(caso.CAS_LKP_Compania__c);
						if (caso.Type.equals(Label.CAS_TIPO_RECHAZADO) && compania.CUE_TXT_Identificador__c != null && procedencia.PROC_NUM_Contador_Rechazos__c != null && 
								compania.CUE_TXT_Identificador__c != Label.IDE_ALMUDENA && compania.CUE_TXT_Identificador__c != Label.IDE_BERKLEY){
							if(procedencia.PROC_NUM_Contador_Rechazos__c == null){
								procedencia.PROC_NUM_Contador_Rechazos__c = 0;
							}
							procedencia.PROC_NUM_Contador_Rechazos__c++;
							numHS = '9' + String.valueOf(procedencia.PROC_NUM_Contador_Rechazos__c);
							//numHS = '9' + Integer.valueOf(procedencia.PROC_NUM_Contador_Rechazos__c);
							system.debug('>>>>generarNumeroHS.numHS RECHAZO: ' + numHS);
						}
						//Se comenta hasta que trabajemos con santa lucia
						else if (procedencia.PROC_NUM_Contador__c != null && (/*caso.CAS_LKP_Compania__c != Label.IDE_SANTA_LUCIA ||(*/ !caso.CAS_FOR_OT_Principal_Urgente__c)){
							if(procedencia.PROC_NUM_Contador__c == null){
								procedencia.PROC_NUM_Contador__c = 0;
							}
							procedencia.PROC_NUM_Contador__c++;
							String contadorGlobal = '000000' + String.valueOf(Integer.valueOf(procedencia.PROC_NUM_Contador__c));
							system.debug('>>>>generarNumeroHS.contadorGlobal: ' + contadorGlobal);
							String anyoCIA = String.valueOf(Date.today().year());
							contadorGlobal = contadorGlobal.right(6);
							numHS = anyoCIA + contadorGlobal;
							system.debug('>>>>generarNumeroHS.numHS SINI: ' + numHS);
						}
					}
				}

				// Generar Nº de Caso HomeServe para Servicios B2B/B2B2C y B2C
				else if (caso.RecordTypeId == recordTypeIdServB2B || caso.RecordTypeId == recordTypeIdServB2C
						|| caso.RecordTypeId == recordTypeIdSolB2B_B2B2C || caso.RecordTypeId == recordTypeIdSolicitudB2C) {
					// SOLUCIÓN PARCIAL PORQUE DA DUPLICADOS
					numHS = 'B' + String.valueOf(System.now().getTime());
					system.debug('>>>>generarNumeroHS.numHS B2B: ' + numHS);
				}

				// Generar Nº de Caso HomeServe para Reclamaciones
				else if (caso.RecordTypeId == recordTypeReclamacion) {
					system.debug('entrada 5');
					// SOLUCIÓN PARCIAL PORQUE DA DUPLICADOS
					numHS = 'R' + String.valueOf(System.now().getTime());
					system.debug('>>>>generarNumeroHS.numHS RECL: ' + numHS);
				}
			}

			// GENERAR Nº DE ORDEN DE TRABAJO HOMESERVE
			else {
				numHS = String.valueOf(System.now().getTime());
			}
		}
		return numHS;
	}


	/**
	 * Genera el Numero de Identificacion unico de un Caso para sus diferentes RecordType
	 * 
	 * @param caso Caso para el que se va a generar el Numero de Identificacion unico
	 * @param numHS Numero de Intervencion HomeServe de Orden de Trabajo generado
	 *
	 * @return idExterno Numero de Identificacion unico de un Caso generado
	 */
	public static String generarIdExternoCaso(Id recordTypeId, String codigoCia, String numHS){
		String idExterno;
		// Generar Id Externo único para Siniestro 
		if (recordTypeId == recordTypeIdSini){
			idExterno = codigoCia + '_' + numHS;
		}
		// Generar Id Externo único Servicios B2B/B2B2C y B2C y Reclamaciones
		else if (recordTypeId == recordTypeReclamacion || 
				recordTypeId == recordTypeIdServB2B ||
				recordTypeId == recordTypeIdServB2C ||
				recordtypeId == recordTypeIdSolB2B_B2B2C ||
				recordtypeId == recordTypeIdSolicitudB2C){
			idExterno = numHS;
		}
		return idExterno;
	}


	/**
	 * Genera el Nº de Siniestro identificador para una Compañía.
	 * 
	 * @param numHS Número de intervención HS
	 * @return numCIA identificador de Siniestro generado
	 */
	public static String generarNumIntervencionCIA(Case caso, Procedencia__c procedencia) {
		String anyoCIA;
		String numCIA;
		if (caso.Type != null && caso.CAS_LKP_Compania__c != null && caso.CAS_LKP_Procedencia__c != null) {
			Account compania = Util_Compania.CIA_BY_IDSF.get(caso.CAS_LKP_Compania__c);
			//Se crea el número de siniestro CIA
			if(compania.CUE_TXT_Identificador__c != null && compania.CUE_TXT_Identificador__c == Label.IDE_ALMUDENA) {
				String contadorSiniestros = '000000' + procedencia.PROC_NUM_Contador__c;
				contadorSiniestros = contadorSiniestros.right(6);
				anyoCIA = String.valueOf(Date.today().year()).right(2); 
				numCIA = anyoCIA + contadorSiniestros;
				system.debug('>>>>>>>>>>>>>>>>generarNumIntervencionCIA.numCIA: ' + numCIA);
			}
			else if(compania.CUE_TXT_Identificador__c != null && compania.CUE_TXT_Identificador__c == Label.IDE_SEGURCAIXA) {
				Integer numHS = Integer.valueOf(caso.CAS_TXT_Num_Caso_HS__c);
				String firstDigit = String.valueOf(Date.today().year()+20).substring(2,3);
				anyoCIA = String.valueOf(Date.today().year()).right(1);
				String ideEE = '03';
				numCIA = firstDigit+anyoCIA+ideEE+String.valueOf(numHS).right(6);
				system.debug('>>>>>>>>>>>>>>>>generarNumIntervencionCIA.numCIA: ' + numCIA);
			}
		}
		return numCIA;
	} // FIN generarNumIntervencionCIA  
}