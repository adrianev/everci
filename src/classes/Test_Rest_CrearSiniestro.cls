/**
 * Clase de Test de la Clase Rest_CrearSiniestro
 *
 **/
@isTest
public without sharing class Test_Rest_CrearSiniestro extends TestSetup {

	private static Account compania;
	private static Rest_CrearSiniestro.DatosCaso datosCaso;
	private static List<Rest_CrearSiniestro.ListadoAyuda> listadoAyuda;
	private static List<Rest_CrearSiniestro.ListadoComentarios> listadoComentarios;
	private static List<Rest_CrearSiniestro.ListadoGarantiasPoliza> listadoGarantiasPoliza;
	private static List<Rest_CrearSiniestro.ListadoPerjudicado> listadoPerjudicado;
	private static List<Rest_CrearSiniestro.ListadoGarantiasSiniestro> listadoGarantiasSiniestro;

	/**
	 * Este metodo se encarga de realizar la carga de datos de static resources
	 * 
	 *
	@testSetup
	public static void test(){
		TestSetup loadData = new Test_Rest_CrearSiniestro();
		//loadData.setTestData();

    	compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1134567X');
		insert compania;

		Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel','2018','miguel@gmail.es', '79106916A','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
		insert asegurado;
		Date startDate = Date.newInstance(2016, 12, 31);
		ServiceContract poliza = Util_Tests.crearPolizaContrato('9729187', compania.Id, asegurado.Id, true, '79146070', '28001', 'PISO', startDate, 'Madrid', null, '2');
		insert poliza;

		Case c=Util_Tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
		insert c;
	}

	@isTest static void testOK1() {

		Account compania2=Util_Tests.crearCuentaCompania('Name', '112233', 'X7654321X');
		insert compania2;

				//Crear Datos Caso 
		List<Case> listCasos = [SELECT Id,
		                        CAS_NUM_Id_Actuacion_SondeoExt__c,
		                        CAS_SEL_Sondeo_Fase__c,
		                        Status,
		                        CAS_CAS_Apertura_Parcial__c,
		                        Type,
		                        CAS_SEL_Motivo_Rechazo__c,
		                        CAS_SEL_Motivo_No_Apertura__c,
		                        CAS_DAT_Fecha_Ocurrencia__c,
		                        CAS_SEL_Grupo_Causa__c,
		                        CAS_SEL_Tipo_Averia__c,
		                        CAS_SEL_Detalle_Averia__c,
		                        CAS_SEL_Causa_Averia__c,
		                        CAS_CAS_Siniestro_Grave__c,
		                        CAS_CAS_Siniestro_Consorciable__c,
		                        CAS_CAS_Danos_Propios__c,
		                        CAS_SEL_Situacion_Danos_Propios__c,
		                        CAS_SEL_Otros_Danos__c,
		                        CAS_CAS_Danos_Perjudicado__c,
		                        CAS_CAS_Tercero_Causante__c,
		                        CAS_SEL_Causante_Responsable__c,
		                        CAS_TXT_Nombre__c,
		                        CAS_TXT_Apellidos__c,
		                        CAS_TXT_Apellidos_2__c,
		                        CAS_SEL_Causante_Tipo_Documento__c,
		                        CAS_TXT_Causante_N_Documento__c,
		                        CAS_TXT_Causante_Direccion__c,
		                        CAS_TXT_Codigo_Postal__c,
		                        CAS_TFN_Telefono_1__c,
		                        CAS_TFN_Telefono_2__c,
		                        CAS_EMA_Email__c,
		                        CAS_TXT_Causante_Poliza_R_C__c,
		                        CAS_SEL_Causante_Compania__c,
		                        CAS_TXT_Causante_N_exp_Stro__c,
		                        CAS_SEL_Sondeo_Gremios__c,
		                        CAS_TXT_Sondeo_Tipo_de_Carta__c,
		                        //CAS_DIV_Sondeo_Limite_Actuacion__c, // NO EXISTE?
		                        		CAS_SEL_Motivo_Peticion_Perito__c,
		                        		CAS_TXT_Submotivo_Perito__c,
		                        		CAS_SEL_Sondeo_DocsIndemnizable__c,
		                        		CAS_SEL_Sondeo_DocIndemSug__c,
		                        		CAS_SEL_Tipo_Llamada__c,
		                        		CAS_TXT_Motivo_Llamada__c,
		                        		CAS_LKP_Ayuda_Indemnizable__c,
		                        		//AYU_TXT_Identificador__c, ??? 
		                        		CAS_TXT_Identificador__c,
		                        		CAS_TXT_Sondeo_Grupo_Causa__c,
		                        		CAS_TXT_Sondeo_Causa__c,
		                        		CAS_TXT_Ayuda_Ind_Apertura__c
		                        		FROM Case];

		system.debug(listCasos);                      

		datosCaso = new Rest_CrearSiniestro.DatosCaso();

		datosCaso.Id = listCasos[0].Id;
		datosCaso.CAS_NUM_Id_Actuacion_SondeoExt = listCasos[0].CAS_NUM_Id_Actuacion_SondeoExt__c;
		datosCaso.CAS_SEL_Sondeo_Fase = listCasos[0].CAS_SEL_Sondeo_Fase__c;
		datosCaso.Status = listCasos[0].Status;
		datosCaso.CAS_CAS_Apertura_Parcial = listCasos[0].CAS_CAS_Apertura_Parcial__c;
		datosCaso.Type = listCasos[0].Type;
		datosCaso.CAS_SEL_Motivo_Rechazo = listCasos[0].CAS_SEL_Motivo_Rechazo__c;
		datosCaso.CAS_SEL_Motivo_No_Apertura = listCasos[0].CAS_SEL_Motivo_No_Apertura__c;
		datosCaso.CAS_DAT_Fecha_Ocurrencia = listCasos[0].CAS_DAT_Fecha_Ocurrencia__c;
		datosCaso.CAS_SEL_Grupo_Causa = listCasos[0].CAS_SEL_Grupo_Causa__c;
		datosCaso.CAS_SEL_Tipo_Averia = listCasos[0].CAS_SEL_Tipo_Averia__c;
		datosCaso.CAS_SEL_Detalle_Averia = listCasos[0].CAS_SEL_Detalle_Averia__c;
		datosCaso.CAS_SEL_Causa_Averia = listCasos[0].CAS_SEL_Causa_Averia__c;
		datosCaso.CAS_CAS_Siniestro_Grave = listCasos[0].CAS_CAS_Siniestro_Grave__c;
		datosCaso.CAS_CAS_Siniestro_Consorciable = listCasos[0].CAS_CAS_Siniestro_Consorciable__c;
		datosCaso.CAS_CAS_Danos_Propios = listCasos[0].CAS_CAS_Danos_Propios__c;
		datosCaso.CAS_SEL_Situacion_Danos_Propios = listCasos[0].CAS_SEL_Situacion_Danos_Propios__c;
		datosCaso.CAS_SEL_Otros_Danos = listCasos[0].CAS_SEL_Otros_Danos__c;
		datosCaso.CAS_CAS_Danos_Perjudicado = listCasos[0].CAS_CAS_Danos_Perjudicado__c;
		datosCaso.CAS_CAS_Tercero_Causante = listCasos[0].CAS_CAS_Tercero_Causante__c;
		datosCaso.CAS_SEL_Causante_Responsable = listCasos[0].CAS_SEL_Causante_Responsable__c;
		datosCaso.CAS_TXT_Nombre = listCasos[0].CAS_TXT_Nombre__c;
		datosCaso.CAS_TXT_Apellidos = listCasos[0].CAS_TXT_Apellidos__c;
		datosCaso.CAS_TXT_Apellidos_2 = listCasos[0].CAS_TXT_Apellidos_2__c;
		datosCaso.CAS_SEL_Causante_Tipo_Documento = listCasos[0].CAS_SEL_Causante_Tipo_Documento__c;
		datosCaso.CAS_TXT_Causante_N_Documento = listCasos[0].CAS_TXT_Causante_N_Documento__c;
		datosCaso.CAS_TXT_Causante_Direccion = listCasos[0].CAS_TXT_Causante_Direccion__c;
		datosCaso.CAS_TXT_Codigo_Postal = listCasos[0].CAS_TXT_Codigo_Postal__c;
		datosCaso.CAS_TFN_Telefono_1 = listCasos[0].CAS_TFN_Telefono_1__c;
		datosCaso.CAS_TFN_Telefono_2 = listCasos[0].CAS_TFN_Telefono_2__c;
		datosCaso.CAS_EMA_Email = listCasos[0].CAS_EMA_Email__c;
		datosCaso.CAS_TXT_Causante_Poliza_R_C = listCasos[0].CAS_TXT_Causante_Poliza_R_C__c;
		datosCaso.CAS_SEL_Causante_Compania = listCasos[0].CAS_SEL_Causante_Compania__c;
		datosCaso.CAS_TXT_Causante_N_exp_Stro = listCasos[0].CAS_TXT_Causante_N_exp_Stro__c;
		datosCaso.CAS_SEL_Sondeo_Gremios = listCasos[0].CAS_SEL_Sondeo_Gremios__c;
		datosCaso.CAS_TXT_Sondeo_Tipo_de_Carta = listCasos[0].CAS_TXT_Sondeo_Tipo_de_Carta__c;
		datosCaso.CAS_SEL_Motivo_Peticion_Perito = listCasos[0].CAS_SEL_Motivo_Peticion_Perito__c;
		datosCaso.CAS_TXT_Submotivo_Perito = listCasos[0].CAS_TXT_Submotivo_Perito__c;
		datosCaso.CAS_SEL_Sondeo_DocsIndemnizable = listCasos[0].CAS_SEL_Sondeo_DocsIndemnizable__c;
		datosCaso.CAS_SEL_Sondeo_DocIndemSug = listCasos[0].CAS_SEL_Sondeo_DocIndemSug__c;
		datosCaso.CAS_SEL_Tipo_Llamada = listCasos[0].CAS_SEL_Tipo_Llamada__c;
		datosCaso.CAS_TXT_Motivo_Llamada = listCasos[0].CAS_TXT_Motivo_Llamada__c;
		datosCaso.CAS_TXT_Sondeo_Grupo_Causa = listCasos[0].CAS_TXT_Sondeo_Grupo_Causa__c;
		datosCaso.CAS_TXT_Sondeo_Causa = listCasos[0].CAS_TXT_Sondeo_Causa__c;
		datosCaso.CAS_TXT_Ayuda_Ind_Apertura = listCasos[0].CAS_TXT_Ayuda_Ind_Apertura__c;
		
		listCasos[0].CAS_LKP_Compania__c=compania2.Id;
		update listCasos[0];

		// Crear listado Ayuda
		List<Ayuda__c> listAyuda = [SELECT AYU_TXT_Identificador__c, AYU_SEL_Tipo__c FROM Ayuda__c];

		listadoAyuda = new List<Rest_CrearSiniestro.ListadoAyuda>();

		for(Ayuda__c ayuda:listAyuda){
			Rest_CrearSiniestro.ListadoAyuda ayudaSiniestro = new Rest_CrearSiniestro.ListadoAyuda();
			ayudaSiniestro.AYU_TXT_Identificador = ayuda.AYU_TXT_Identificador__c;
			ayudaSiniestro.AYU_SEL_Tipo = ayuda.AYU_SEL_Tipo__c;
			listadoAyuda.add(ayudaSiniestro);
		}

		// Crear listado Comentarios

		Comentario_caso__c cc=new Comentario_caso__c();
		cc.CMC_TXT_Comentario__c='Esto es una prueba de un comentario.';
		cc.CMC_LKP_Caso__c=listCasos[0].Id;
		insert cc;
		List<Comentario_caso__c> listComentarios = [SELECT CMC_LKP_Caso__c, CMC_TXT_Comentario__c, CMC_SEL_Tipo__c FROM Comentario_caso__c];

		listadoComentarios = new List<Rest_CrearSiniestro.ListadoComentarios>();

		for(Comentario_caso__c comentario:listComentarios){
			Rest_CrearSiniestro.ListadoComentarios comentarioCaso = new Rest_CrearSiniestro.ListadoComentarios();
			comentarioCaso.CMC_LKP_Caso = comentario.CMC_LKP_Caso__c;
			comentarioCaso.CMC_TXT_Comentario = comentario.CMC_TXT_Comentario__c;
			comentarioCaso.CMC_SEL_Tipo = comentario.CMC_SEL_Tipo__c;
			listadoComentarios.add(comentarioCaso);
		}

		// Crear listado Garantais Polizas
		List<Garantia_Poliza__c> listGarantias = [SELECT GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c,
		                                          GPOL_LKP_Garantia__c,
		                                          GPOL_DIV_Franquicia__c,
		                                          GPOL_DIV_Capital_Asegurado__c
		                                          FROM Garantia_Poliza__c];

		List<Rest_CrearSiniestro.ListadoGarantiasPoliza> listadoGarantiasPoliza = new List<Rest_CrearSiniestro.ListadoGarantiasPoliza>();

		for(Garantia_Poliza__c garantia:listGarantias){
			Rest_CrearSiniestro.ListadoGarantiasPoliza garantiaPoliza = new Rest_CrearSiniestro.ListadoGarantiasPoliza();
			garantiaPoliza.GPOL_LKP_Garantia = garantia.GPOL_LKP_Garantia__c;
			garantiaPoliza.POL_TXT_Id_Version_Poliza = garantia.GPOL_LKP_PolizaContrato__r.POL_TXT_Id_Version_Poliza__c;
			garantiaPoliza.GPOL_DIV_Franquicia = garantia.GPOL_DIV_Franquicia__c;
			garantiaPoliza.GPOL_DIV_Capital_Asegurado = garantia.GPOL_DIV_Capital_Asegurado__c;
			listadoGarantiasPoliza.add(garantiaPoliza);
		}

		Perjudicado_Siniestro__c ps=new Perjudicado_Siniestro__c();
		insert ps;

		// Crear listado Perjudicado
		List<Perjudicado_Siniestro__c> listPerjudicados = [SELECT PRJ_LKP_Siniestro__c,
		                                                   PRJ_SEL_Tipo_Perjudicado__c,
		                                                   PRJ_SEL_Situacion_Danos__c,
		                                                   PRJ_SEL_Otros_Danos__c,
		                                                   PRJ_TXT_Nombre__c,
		                                                   PRJ_TXT_Direccion__c,
		                                                   PRJ_TFN_Telefono_1__c,
		                                                   PRJ_TFN_Telefono_Adicional__c,
		                                                   PRJ_TFN_Movil__c,
		                                                   PRJ_EMA_Email__c
		                                                   FROM Perjudicado_Siniestro__c];

		listadoPerjudicado = new List<Rest_CrearSiniestro.ListadoPerjudicado>();

		for(Perjudicado_Siniestro__c perjudicado:listPerjudicados){
			Rest_CrearSiniestro.ListadoPerjudicado perjudicadoSiniestro = new Rest_CrearSiniestro.ListadoPerjudicado();
			perjudicadoSiniestro.PRJ_LKP_Siniestro = perjudicado.PRJ_LKP_Siniestro__c;
			perjudicadoSiniestro.PRJ_SEL_Tipo_Perjudicado = perjudicado.PRJ_SEL_Tipo_Perjudicado__c;
			perjudicadoSiniestro.PRJ_SEL_Situacion_Danos = perjudicado.PRJ_SEL_Situacion_Danos__c;
			perjudicadoSiniestro.PRJ_SEL_Otros_Danos = perjudicado.PRJ_SEL_Otros_Danos__c;
			perjudicadoSiniestro.PRJ_TXT_Nombre = perjudicado.PRJ_TXT_Nombre__c;
			perjudicadoSiniestro.PRJ_TXT_Direccion = perjudicado.PRJ_TXT_Direccion__c;
			perjudicadoSiniestro.PRJ_TFN_Telefono_1 = perjudicado.PRJ_TFN_Telefono_1__c;
			perjudicadoSiniestro.PRJ_TFN_Telefono_Adicional = perjudicado.PRJ_TFN_Telefono_Adicional__c;
			perjudicadoSiniestro.PRJ_TFN_Movil = perjudicado.PRJ_TFN_Movil__c;
			perjudicadoSiniestro.PRJ_EMA_Email = perjudicado.PRJ_EMA_Email__c;
			listadoPerjudicado.add(perjudicadoSiniestro);
		}

		// Crear listado Garantias Siniestro
		Garantia__c gr = new Garantia__c();
		gr.GAR_LKP_Compania__c = [SELECT Id FROM Account WHERE CUE_TXT_Numero_Documento__c = 'X1134567X' LIMIT 1].get(0).Id;
		gr.GAR_TXT_Descripcion__c = 'CRISTALES MARMOLES LOZA VITROCERAMICAS - CTE';
		insert gr;

		Garantia__c gr2=new Garantia__c();
		gr2.GAR_LKP_Compania__c=compania2.Id;
		gr2.GAR_TXT_Descripcion__c = 'CRISTALES MARMOLES LOZA VITROCERAMICAS - CTE';
		insert gr2;
		gr2.GAR_TXT_Codigo_Garantia__c=gr2.Id;
		update gr2;

		Garantia_Siniestro__c gs=new Garantia_Siniestro__c();
		gs.GSIN_LKP_Caso__c=listCasos[0].Id;
		gs.GSIN_LKP_Garantia__c=gr.Id;
		insert gs;

		Garantia_Siniestro__c gs2=gs.clone();
		gs2.Id=null;
		insert gs2;

		Garantia_Siniestro__c gs3=new Garantia_Siniestro__c();
		gs3.GSIN_LKP_Caso__c=listCasos[0].Id;
		gs3.GSIN_LKP_Garantia__c=gr2.Id;
		insert gs3;


		List<Garantia_Siniestro__c> listGarantiasSiniestro = [SELECT GSIN_LKP_Caso__c, GSIN_LKP_Garantia__c FROM Garantia_Siniestro__c];

		listadoGarantiasSiniestro = new List<Rest_CrearSiniestro.ListadoGarantiasSiniestro>();

		for(Garantia_Siniestro__c garantia:listGarantiasSiniestro){
			Rest_CrearSiniestro.ListadoGarantiasSiniestro garantiaSiniestro = new Rest_CrearSiniestro.ListadoGarantiasSiniestro();
			garantiaSiniestro.GSIN_LKP_Caso = garantia.GSIN_LKP_Caso__c;
			garantiaSiniestro.GSIN_LKP_GarantiaSiniestro = garantia.GSIN_LKP_Garantia__c;
			listadoGarantiasSiniestro.add(garantiaSiniestro);
		}
		Rest_CrearSiniestro.doPost(datosCaso, listadoAyuda, listadoComentarios, listadoGarantiasPoliza, listadoPerjudicado, listadoGarantiasSiniestro);

	}
*/
}