/*
 * Clase encargada del setteo de los datos de los Callouts de Previsora;
 *
 * @author EVERIS
 */
public without sharing class Util_Previsora {
	
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada a Callout_Previsora_Siniestro
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void construirSiniestro(){
		/*Pendiente: realizar las queries para obtener las listas, saber qué Listas recibo desde los triggers,
		pendiente lógica de CRM*/
		
		Case casoSiniestro = new Case();
		Perjudicado_Siniestro__c perjudicado = new Perjudicado_Siniestro__c();
		Garantia__c garantia = new Garantia__c();
		Contacto_telefonico__c contactoTLF = new Contacto_telefonico__c();
		
		Callout_Previsora_Siniestro_RQ datos = new Callout_Previsora_Siniestro_RQ();
		
		for(Callout_Previsora_Siniestro_RQ.Garantias garantias : datos.listaGarantias){
			garantias.Codigo = Integer.valueOf(garantia.GAR_TXT_Identificador__c);
			garantias.ImporteBaseServicio = 0;//No está en el mapping
			garantias.PorcentajeIvaAplicadoServicio = 0;//No está en el mapping
		}
		
		datos.Descripcion = '';
		datos.IdSecuencia = '';
		datos.Apellido1Perjudicado = perjudicado.PRJ_TXT_Apellido_1__c;
		datos.Apellido1 = casoSiniestro.CAS_TXT_Apellidos__c;
		datos.Apellido2Perjudicado = perjudicado.PRJ_TXT_Apellido_2__c;
		datos.Apellido2 = casoSiniestro.CAS_TXT_Apellidos_2__c;
		datos.Calificacion = Integer.valueOf(casoSiniestro.Type); //REVISAR ESTE CAMPO
		datos.CodigoCausa = Integer.valueOf(casoSiniestro.CAS_TXT_Sondeo_Causa__c); //REVISAR ESTE CAMPO
		datos.CodigoGrupo = Integer.valueOf(casoSiniestro.CAS_TXT_Sondeo_Grupo_Causa__c); //REVISAR ESTE CAMPO
		datos.CodigoModificacion = 0;//Metadato???
		datos.CodigoPerjudicado = Integer.valueOf(casoSiniestro.CAS_CAS_Danos_Perjudicado__c); //REVISAR ESTE CAMPO
		datos.CodigoReapertura = Integer.valueOf(casoSiniestro.CAS_TXT_Motivo_Reapertura__c); //REVISAR ESTE CAMPO
		datos.CodigoRechazo = Integer.valueOf(casoSiniestro.CAS_SEL_Motivo_Rechazo__c); //REVISAR ESTE CAMPO
		datos.CodigoResponsable = Integer.valueOf(casoSiniestro.CAS_SEL_Causante_Responsable__c); //REVISAR ESTE CAMPO
		datos.ComentarioStrosIndemnizable = '';
		datos.ComentarioStrosReparable = '';
		datos.CompaniaTercero = casoSiniestro.CAS_SEL_Causante_Compania__c;
		datos.DNIPerjudicado = perjudicado.PRJ_TXT_Perjudicado_N_Documento__c;
		datos.DNITercero = casoSiniestro.CAS_TXT_Causante_N_Documento__c;
		datos.DireccionPerjudicado = perjudicado.PRJ_TXT_Direccion__c;
		datos.FechaHoraMovimiento = system.now(); //Mostrar en ms u hora con ms?????
		datos.FechaOcurrencia = casoSiniestro.CAS_DAT_Fecha_Ocurrencia__c;
		datos.IdPoliza = Integer.valueOf(casoSiniestro.CAS_LKP_PolizaContrato__r.Name); //REVISAR ESTE CAMPO
		datos.IdSiniestroReparalia = casoSiniestro.CAS_TXT_Num_Caso_HS__c;
		datos.ImporteReserva = 0;//No existe el campo CAS_DIV_Importe_Reserva_Garantias__c, valdría CAS_DIV_Importe_Reserva_Perito__c???
		datos.NombrePerjudicado = perjudicado.PRJ_TXT_Nombre__c;
		datos.NombreTercero = casoSiniestro.CAS_TXT_Nombre__c;
		datos.NumSiniestroReparalia = casoSiniestro.CAS_TXT_Num_Caso_HS__c;
		datos.Perjudicado = Integer.valueOf(perjudicado.PRJ_SEL_Tipo_Perjudicado__c); //REVISAR ESTE CAMPO
		datos.PolizaTercero = casoSiniestro.CAS_TXT_Causante_Poliza_R_C__c;
		datos.ResponsableDelSiniestro = Integer.valueOf(casoSiniestro.CAS_SEL_Causante_Responsable__c); //REVISAR ESTE CAMPO
		datos.Telefono1Asegurado = perjudicado.PRJ_TFN_Telefono_1__c;
		datos.Telefono1AseguradoHoraDesde = contactoTLF.CTF_SEL_Hora_desde__c;
		datos.Telefono1AseguradoHoraHasta = contactoTLF.CTF_SEL_Hora_hasta__c;
		datos.Telefono1AseguradoTipoTelefono = Integer.valueOf(contactoTLF.CTF_FOR_Telefono__c); //Revisar el acuerdo de interfaz
		datos.TelefonoPerjudicado = perjudicado.PRJ_TFN_Telefono_1__c;
		datos.TelefonoTercero = casoSiniestro.CAS_TFN_Telefono_1__c;
		datos.TipoMovimiento = 0;//Metadato???
		datos.CodGarantia = Integer.valueOf(garantia.GAR_TXT_Identificador__c);
		
		//List<Callout_Previsora_Siniestro_RQ.Garantias> lista = new List<Callout_Previsora_Siniestro_RQ.Garantias>();
		
		/*lista.Codigo = 0;
		lista.ImporteBaseServicio = 0;
		lista.PorcentajeIvaAplicadoServicio = 0;*/
		
		//Pendiente: engancharlo con el Callout de Previsora;
	}
	
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada a Callout_Previsora_Indemnizables
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void construirIndemnizables(){
		/*Pendiente: realizar las queries para obtener las listas, saber qué Listas recibo desde los triggers,
		pendiente lógica de CRM*/
		
		Account datosBenef = new Account();
		ServiceContract poliza = new ServiceContract();
		WorkOrder ordenTrabajo = new WorkOrder();
		Case caso = new Case();
		Perito__c perito = new Perito__c();
		Contact contacto = new Contact();
		Factura__c factura = new Factura__c();

		Callout_Previsora_Indemnizables_RQ datos = new Callout_Previsora_Indemnizables_RQ();
		datos.beneficiario = datosBenef.CUE_TXT_Identificador__c;
		datos.codigoPostalBenef = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Codigo_Postal__c;
		datos.conceptoPago = '';//No está en el mapping
		//datos.domicilioBenef = poliza.POL_FOR_Direccion__c;//RevisarCampo
		datos.estadoSiniestro = Integer.valueOf(ordenTrabajo.OTR_CAS_Urgente__c);//RevisarCampo
		datos.fechaCierre = 0;//No está en el mapping
		datos.fechaHoraMovimiento = system.now(); //Mostrar en ms u hora con ms?????
		datos.fechaRecepcionRepFacturaPerito =  system.today();// No existe la variable: CAS_DAT_Fecha_Recepcion_RepFacturaPerito__c;
		datos.idPagoIndemnizableReparalia = 0;//No está en el mapping
		datos.idPoliza = caso.CAS_LKP_PolizaContrato__r.Name;
		datos.importeBaseGastosPerito = 0; //No existe la variable CAS_DIV_Importe_Base_Gastos_Perito__c;
		datos.importeBaseHonorariosPerito = 0;//No existe la variable CAS_DIV_Importe_Base_Honorarios_Perito__c;
		datos.localidadBenef = poliza.POL_LKP_Version_Actual__r.POLV_TXT_Poblacion__c;
		datos.nifBenef = datosBenef.CUE_TXT_Numero_Documento__c;
		datos.nifPerito = perito.PER_TXT_Numero_Documento__c;
		datos.nombreApellidosBenef = '';//No está en el mapping
		datos.numFacturaPerito = '';//No está en el mapping
		datos.numPago = '';//No está en el mapping
		datos.numSiniestroPrevisora = caso.CAS_TXT_Num_Caso_CIA__c;
		datos.numSiniestroReparalia = caso.CAS_TXT_Num_Caso_HS__c;
		datos.personaFisicaJuridicaBenef = 0;//No está en el mapping
		datos.porcentajeIvaIgiPerito = 0;//casoIndem.CAS_POR_PorcentajeIvaIgiPerito__c;
		datos.telefonoFaxBenef = contacto.Phone;//TeléfonoFax ContactPhone???
		datos.tipoDocumentoBenef = 0;//No está en el mapping
		datos.tipoImpuestoPerito = 0;///No existe la variable CAS_SEL_Tipo_Impuesto_Perito__c;
		datos.tipoRegistro = factura.FAC_TXT_Tipo_Registro__c;
		datos.idSecuencia = '';//No está en el mapping
		
		//Pendiente: engancharlo con el Callout de Previsora;
	}
	
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada a Callout_Previsora_OrdenDeTrabajo
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void construirOT(){
		/*Pendiente: realizar las queries para obtener las listas, saber qué Listas recibo desde los triggers,
		pendiente lógica de CRM*/
		
		WorkOrder ordenTrabajo = new WorkOrder();
		Comentario_caso__c comentCaso = new Comentario_caso__c();
		Case caso = new Case();
		
		Callout_Previsora_OrdenDeTrabajo_RQ datos = new Callout_Previsora_OrdenDeTrabajo_RQ();
		datos.CodigoAnulacionReparacion = 0;//No está en el mapping
		datos.CodigoModificacion = 0;//Lógica en hoja excel "TablaCom"
		datos.CodigoProfesion = Integer.valueOf(ordenTrabajo.OTR_SEL_Gremio__c);//Revisar el AI, piden integer y es string
		datos.Comentarios = comentCaso.CMC_TXT_Comentario__c;
		datos.EstadoReparacion = Integer.valueOf(ordenTrabajo.Status);//Revisar el AI, piden integer y es string
		datos.FechaHoraApertura = caso.CAS_DAT_Fecha_Apertura__c;
		datos.FechaHoraMovimiento = system.now();//Mostrar en ms u hora con ms?????
		datos.IdPoliza = Integer.valueOf(caso.CAS_LKP_PolizaContrato__r.Name); //Revisar el AI, pide Integer cuando es String
		datos.IdReparacionReparalia = caso.CAS_TXT_Num_Caso_HS__c;
		datos.NumReparacion = ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c;
		datos.NumSiniestroReparalia = caso.CAS_TXT_Num_Caso_HS__c;//Repetido
		datos.ReparacionUrgente = caso.CAS_CAS_Solicitud_Urgente__c;
		datos.TipoMovimiento = '';//Lógica en hoja excel "TablaCom"
		datos.IdSecuencia = '';//No está en el mapping
		
		//Pendiente: engancharlo con el Callout de Previsora;
	}
	
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada a Callout_Previsora_Facturas
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void construirFacturas(){
		/*Pendiente: realizar las queries para obtener las listas, saber qué Listas recibo desde los triggers,
		pendiente lógica de CRM*/
		
		WorkOrder ordenTrabajo = new WorkOrder();
		Comentario_caso__c comentCaso = new Comentario_caso__c();
		Case caso = new Case();
		Factura__c factura = new Factura__c();
		Garantia__c garantia = new Garantia__c();
		
		Callout_Previsora_Facturas_RQ datos = new Callout_Previsora_Facturas_RQ();
		
		
		for(Callout_Previsora_Facturas_RQ.Garantia garantias : datos.listaGarantias){
			garantias.codGarantia = Integer.valueOf(garantia.GAR_TXT_Identificador__c);
			garantias.importeBaseServicio = 0;//No está en el mapping
			garantias.porcenIvaAplicadoServicio = 0;//No está en el mapping
		}
		
		datos.estadoSiniestro = Integer.valueOf(ordenTrabajo.OTR_CAS_Urgente__c);//RevisarCampo
		datos.fechaFacturaServicio = factura.FAC_DAT_FechaFactura__c;
		datos.idFacturaReparalia = 0;//No está en el mapping
		datos.idPoliza = Integer.valueOf(caso.CAS_LKP_PolizaContrato__r.Name);//Integer???? revisar Acuerdo de Interfaz
		datos.numFacturaServicio = factura.FAC_TXT_Numero_factura__c;
		datos.numReparacion = Integer.valueOf(ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c);//Integer? revisar Acuerdo de Interfaz
		datos.numSiniestroReparalia = Integer.valueOf(caso.CAS_TXT_Num_Caso_HS__c);//Integer? revisar Acuerdo de Interfaz
		datos.idSecuencia = '';//No está en el mapping
		datos.TotalServiciosSinIva = 0;//No está en el mapping
		datos.TotalServiciosConIva = 0;//No está en el mapping
		datos.FechaHoraMovimiento =  system.now();//Mostrar en ms u hora con ms?????
		
		//Pendiente: engancharlo con el Callout de Previsora;
	}
	
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada a Callout_Previsora_Facturas
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void construirFacturacionFee(){
		/*Pendiente: realizar las queries para obtener las listas, saber qué Listas recibo desde los triggers,
		pendiente lógica de CRM*/
		
		WorkOrder ordenTrabajo = new WorkOrder();
		Case caso = new Case();
		
		Callout_Previsora_FacturacionFee_RQ datos = new Callout_Previsora_FacturacionFee_RQ();
		datos.FechaFacturaGestion = '';//No está en el mapping
		datos.IdFacturaFeeReparalia = '';//No está en el mapping
		datos.IdPoliza =  Integer.valueOf(caso.CAS_LKP_PolizaContrato__r.Name);//Integer???? revisar Acuerdo de Interfaz
		datos.Importe = 0;//No está en el mapping
		datos.EstadoSiniestro = Integer.valueOf(ordenTrabajo.OTR_CAS_Urgente__c);//RevisarCampo
		datos.NumFacturaGestion = '';//No está en el mapping
		datos.NumSiniestroReparalia = caso.CAS_TXT_Num_Caso_HS__c;//En algunos casos es Integer, y en otros casos es String
		datos.PorcentajeIVA = 0;//No está en el mapping
		datos.IdSecuencia = '';//No está en el mapping
		datos.TotalServiciosSinIva = 0;//No está en el mapping
		datos.TotalServiciosConIva = 0;//No está en el mapping
		datos.FechaHoraMovimiento = system.now();//Mostrar en ms u hora con ms?????
		
		//Pendiente: engancharlo con el Callout de Previsora;
	}
	
	/*
	 * Método que obtiene todos los parametros para construir el body, y desde este método se hace la llamada a Callout_Previsora_Abono
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 */
	public static void construirAbono(){
		/*Pendiente: realizar las queries para obtener las listas, saber qué Listas recibo desde los triggers,
		pendiente lógica de CRM*/
		Case caso = new Case();
		WorkOrder ordenTrabajo = new WorkOrder();
		Garantia__c garantia = new Garantia__c();
		
		Callout_Previsora_Abono_RQ datos = new Callout_Previsora_Abono_RQ();
		
		for(Callout_Previsora_Abono_RQ.Garantias garantias : datos.listaGarantias){
			garantias.Codigo = Integer.valueOf(garantia.GAR_TXT_Identificador__c);
			garantias.importeBaseServicio = 0;//No está en el mapping
			garantias.PorcentajeIvaAplicadoServicio = 0;//No está en el mapping
		}
		
		datos.ConceptoPago = '';//No está en el mapping
		datos.FechaAbono = system.now();//No está en el mapping
		datos.FechaHoraMovimiento = system.now();
		datos.IdAbonoReparalia = '';//No está en el mapping
		datos.IdPoliza = Integer.valueOf(caso.CAS_LKP_PolizaContrato__r.Name);//Integer???? revisar Acuerdo de Interfaz;
		datos.NumFactura = '';//¿Cuál de los 3 numFactura?
		datos.NumReparacion = ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c;//Integer? revisar Acuerdo de Interfaz
		datos.NumSiniestroReparalia = caso.CAS_TXT_Num_Caso_HS__c;//En algunos casos es Integer, y en otros casos es String
		datos.IdSecuencia = '';//No está en el mapping
		datos.TotalServiciosSinIva = '';//No está en el mapping
		datos.TotalServiciosConIva = '';//No está en el mapping
		
		
		//Pendiente: engancharlo con el Callout de Previsora;
	}
}