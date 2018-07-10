@RestResource(urlMapping='/crearcaso/*')
global without sharing class Rest_CrearSiniestro {
	global without sharing class Resultado{
		public String resultado,errorCode,caseId;
		public List<PerjudicadoId> listPerjudicadosId; 
		public List<ComentarioId> listComentariosId;
		public List<GarantiaPolizaId> listGarantiaPolizaId;
		public List<GarantiaId> listGarantiasId;
	}   

	global without sharing class PerjudicadoId{
		public String perjudicadosId;
		public PerjudicadoId(String perjudicadosId){
			this.perjudicadosId = perjudicadosId;
		}
	}

	global without sharing class GarantiaPolizaId{
		public String garantiasPolizaId;
		public GarantiaPolizaId(String garantiasPolizaId){
			this.garantiasPolizaId = garantiasPolizaId;
		}
	}

	global without sharing class GarantiaId{
		public String garantiasId;
		public GarantiaId(String garantiasId){
			this.garantiasId = garantiasId;
		}
	}

	global without sharing class ComentarioId{
		public String comentariosId;
		public ComentarioId(String comentariosId){
			this.comentariosId = comentariosId;
		}
	}

	global without sharing class ListadoPerjudicado{
		public String PRJ_LKP_Siniestro, PRJ_SEL_Tipo_Perjudicado, PRJ_SEL_Situacion_Danos, PRJ_SEL_Otros_Danos, PRJ_TXT_Nombre, 
		PRJ_TXT_Direccion, PRJ_TFN_Telefono_1, PRJ_TFN_Telefono_Adicional, PRJ_TFN_Movil, PRJ_EMA_Email;
		public Perjudicado_Siniestro__c getPerjudicado(){
			return new Perjudicado_Siniestro__c(
					PRJ_LKP_Siniestro__c = this.PRJ_LKP_Siniestro,
					PRJ_SEL_Tipo_Perjudicado__c = this.PRJ_SEL_Tipo_Perjudicado,
					PRJ_SEL_Situacion_Danos__c = this.PRJ_SEL_Situacion_Danos,
					PRJ_SEL_Otros_Danos__c = this.PRJ_SEL_Otros_Danos,
					PRJ_TXT_Nombre__c = this.PRJ_TXT_Nombre,
					PRJ_TXT_Direccion__c = this.PRJ_TXT_Direccion,
					PRJ_TFN_Telefono_1__c = this.PRJ_TFN_Telefono_1,
					PRJ_TFN_Telefono_Adicional__c = this.PRJ_TFN_Telefono_Adicional,
					PRJ_TFN_Movil__c = this.PRJ_TFN_Movil,
					PRJ_EMA_Email__c = this.PRJ_EMA_Email	   
					);  
		}
	}

	global without sharing class ListadoGarantiasSiniestro{
		public String GSIN_LKP_Caso, GSIN_LKP_GarantiaSiniestro;
		public Garantia_Siniestro__c getGarantiaSiniestro(){
			return new Garantia_Siniestro__c(
					GSIN_LKP_Caso__c = this.GSIN_LKP_Caso
					);  
		}
	}

	global without sharing class ListadoComentarios{
		public String CMC_LKP_Caso,CMC_TXT_Comentario, CMC_SEL_Tipo;
		public Comentario_caso__c getComentarioCaso(){
			return new Comentario_caso__c(
					CMC_LKP_Caso__c = this.CMC_LKP_Caso,
					CMC_TXT_Comentario__c = this.CMC_TXT_Comentario,
					CMC_SEL_Tipo__c = this.CMC_SEL_Tipo
					);	
		}	   
	}

	global without sharing class ListadoAyuda{
		public String AYU_TXT_Identificador, AYU_SEL_Tipo;
		public Ayuda__c getAyuda(){
			return new Ayuda__c(
					AYU_TXT_Identificador__c = this.AYU_TXT_Identificador
					);
		}	   
	}	

	global without sharing class ListadoGarantiasPoliza{
		public String GAR_TXT_Codigo_Garantia, GPOL_LKP_Garantia, POL_TXT_Id_Version_Poliza, GPOL_LKP_VersionPolizaContrato;
		public Decimal GPOL_DIV_Capital_Asegurado, GPOL_DIV_Franquicia;
		public Garantia_Poliza__c getGarantiaPoliza(){
			return new Garantia_Poliza__c(
					GPOL_LKP_Garantia__c = this.GPOL_LKP_Garantia,
					GPOL_LKP_VersionPolizaContrato__c = this.GPOL_LKP_VersionPolizaContrato,
					GPOL_DIV_Franquicia__c = this.GPOL_DIV_Franquicia,  
					GPOL_DIV_Capital_Asegurado__c = this.GPOL_DIV_Capital_Asegurado
					);
		}
	}

	global without sharing class DatosCaso{
		public Date CAS_DAT_Fecha_Ocurrencia = Date.newInstance(1960, 2, 17);
		public Decimal CAS_NUM_Id_Actuacion_SondeoExt = 0.0; 
		public Boolean CAS_CAS_Apertura_Parcial = false;
		public Boolean CAS_CAS_Siniestro_Grave = false;
		public Boolean CAS_CAS_Siniestro_Consorciable = false;
		public Boolean CAS_CAS_Danos_Propios = false;
		public Boolean CAS_CAS_Danos_Perjudicado = false;
		public Boolean CAS_CAS_Tercero_Causante = false;
		public String CAS_SEL_Sondeo_Fase = '',Status = '', Id = '', Type = '', CAS_SEL_Motivo_Rechazo = '', CAS_SEL_Motivo_No_Apertura = '', CAS_SEL_Grupo_Causa = '', CAS_SEL_Tipo_Averia = '', 
				CAS_SEL_Detalle_Averia = '', CAS_SEL_Causa_Averia = '', CAS_SEL_Situacion_Danos_Propios = '', CAS_SEL_Otros_Danos = '', CAS_SEL_Causante_Responsable = '', CAS_TXT_Nombre = '', 
				CAS_TXT_Apellidos = '', CAS_TXT_Apellidos_2 = '', CAS_SEL_Causante_Tipo_Documento = '', CAS_TXT_Causante_N_Documento = '', CAS_TXT_Causante_Direccion = '', CAS_TXT_Codigo_Postal = '', 
				CAS_TFN_Telefono_1 = '', CAS_TFN_Telefono_2 = '', CAS_EMA_Email = '', CAS_TXT_Causante_Poliza_R_C = '', CAS_SEL_Causante_Compania = '', CAS_TXT_Causante_N_exp_Stro = '', 
				CAS_SEL_Sondeo_Gremios = '', CAS_TXT_Sondeo_Tipo_de_Carta = '';
		// Este campo y no existe en Salesforce pero sí en el acuerdo
		// por lo que debe estar aquí definido
		public Decimal CAS_DIV_Sondeo_Limite_Actuacion = 0.0;
		public Boolean CAS_CAS_Sondeo_Peticion_Perito = false;
		public String CAS_SEL_Motivo_Peticion_Perito = '', CAS_TXT_Submotivo_Perito = '',CAS_SEL_Sondeo_DocsIndemnizable = '',CAS_SEL_Sondeo_DocIndemSug = '',CAS_SEL_Tipo_Llamada = ''
				,CAS_TXT_Motivo_Llamada = '',CAS_LKP_Ayuda_Indemnizable = '',CAS_TXT_Identificador = '',CAS_TXT_Sondeo_Grupo_Causa = '',CAS_TXT_Sondeo_Causa = '',CAS_TXT_Ayuda_Ind_Apertura = '';

		public Case getCase() {
			return new Case(
					Id = this.Id,
					CAS_NUM_Id_Actuacion_SondeoExt__c = this.CAS_NUM_Id_Actuacion_SondeoExt,
					CAS_SEL_Sondeo_Fase__c = this.CAS_SEL_Sondeo_Fase,
					Status = this.Status,
					CAS_CAS_Apertura_Parcial__c = this.CAS_CAS_Apertura_Parcial,
					Type = this.Type,
					CAS_SEL_Motivo_Rechazo__c = this.CAS_SEL_Motivo_Rechazo,
					CAS_SEL_Motivo_No_Apertura__c = this.CAS_SEL_Motivo_No_Apertura,
					CAS_DAT_Fecha_Ocurrencia__c = this.CAS_DAT_Fecha_Ocurrencia,
					CAS_SEL_Grupo_Causa__c = this.CAS_SEL_Grupo_Causa,
					CAS_SEL_Tipo_Averia__c = this.CAS_SEL_Tipo_Averia,
					CAS_SEL_Detalle_Averia__c = this.CAS_SEL_Detalle_Averia,
					CAS_SEL_Causa_Averia__c = this.CAS_SEL_Causa_Averia,
					CAS_CAS_Siniestro_Grave__c = this.CAS_CAS_Siniestro_Grave,
					CAS_CAS_Siniestro_Consorciable__c = this.CAS_CAS_Siniestro_Consorciable,
					CAS_CAS_Danos_Propios__c = this.CAS_CAS_Danos_Propios,
					CAS_SEL_Situacion_Danos_Propios__c = this.CAS_SEL_Situacion_Danos_Propios,
					CAS_SEL_Otros_Danos__c = this.CAS_SEL_Otros_Danos,
					CAS_CAS_Danos_Perjudicado__c = this.CAS_CAS_Danos_Perjudicado,
					CAS_CAS_Tercero_Causante__c = this.CAS_CAS_Tercero_Causante,
					CAS_SEL_Causante_Responsable__c = this.CAS_SEL_Causante_Responsable,
					CAS_TXT_Nombre__c = this.CAS_TXT_Nombre,
					CAS_TXT_Apellidos__c = this.CAS_TXT_Apellidos,
					CAS_TXT_Apellidos_2__c = this.CAS_TXT_Apellidos_2,
					CAS_SEL_Causante_Tipo_Documento__c = this.CAS_SEL_Causante_Tipo_Documento,
					CAS_TXT_Causante_N_Documento__c = this.CAS_TXT_Causante_N_Documento,
					CAS_TXT_Causante_Direccion__c = this.CAS_TXT_Causante_Direccion,
					CAS_TXT_Codigo_Postal__c = this.CAS_TXT_Codigo_Postal,
					CAS_TFN_Telefono_1__c = this.CAS_TFN_Telefono_1,
					CAS_TFN_Telefono_2__c = this.CAS_TFN_Telefono_2,
					CAS_EMA_Email__c = this.CAS_EMA_Email,
					CAS_TXT_Causante_Poliza_R_C__c = this.CAS_TXT_Causante_Poliza_R_C,
					CAS_SEL_Causante_Compania__c = this.CAS_SEL_Causante_Compania,
					CAS_TXT_Causante_N_exp_Stro__c = this.CAS_TXT_Causante_N_exp_Stro,
					CAS_SEL_Sondeo_Gremios__c = this.CAS_SEL_Sondeo_Gremios,
					CAS_TXT_Sondeo_Tipo_de_Carta__c = this.CAS_TXT_Sondeo_Tipo_de_Carta,
					//Se comenta porque se elimina este campo. Esta a nivel de Account Compañía
					//CAS_DIV_Sondeo_Limite_Actuacion__c = this.CAS_DIV_Sondeo_Limite_Actuacion,
					CAS_CAS_Requiere_Perito__c = this.CAS_CAS_Sondeo_Peticion_Perito,
					CAS_SEL_Motivo_Peticion_Perito__c = this.CAS_SEL_Motivo_Peticion_Perito,
					CAS_TXT_Submotivo_Perito__c = this.CAS_TXT_Submotivo_Perito,
					CAS_SEL_Sondeo_DocsIndemnizable__c = this.CAS_SEL_Sondeo_DocsIndemnizable,
					CAS_SEL_Sondeo_DocIndemSug__c = this.CAS_SEL_Sondeo_DocIndemSug,
					CAS_SEL_Tipo_Llamada__c = this.CAS_SEL_Tipo_Llamada,
					CAS_TXT_Motivo_Llamada__c = this.CAS_TXT_Motivo_Llamada,
					CAS_TXT_Sondeo_Grupo_Causa__c = this.CAS_TXT_Sondeo_Grupo_Causa,
					CAS_TXT_Sondeo_Causa__c = this.CAS_TXT_Sondeo_Causa,
					CAS_TXT_Ayuda_Ind_Apertura__c = this.CAS_TXT_Ayuda_Ind_Apertura
					);
		}   
	}


	@HttpPost
	global static Resultado doPost(DatosCaso datosCaso, List<ListadoAyuda> listadoAyuda, List<ListadoComentarios> listadoComentarios, 
			List<ListadoGarantiasPoliza> listadoGarantiasPoliza, List<ListadoPerjudicado> listadoPerjudicado, List<ListadoGarantiasSiniestro> listadoGarantiasSiniestro) {
		Resultado toRet = new Resultado();
		system.debug('>>>>Caso: '+ datosCaso);
		system.debug('>>>>ListadoComentarios: ' + listadoComentarios);
		system.debug('>>>>ListadoGarantiasPoliza: ' + listadoGarantiasPoliza);
		system.debug('>>>>ListadoPerjudicado: ' + listadoPerjudicado);
		system.debug('>>>>ListadoGarantiasSiniestro: ' + listadoGarantiasSiniestro);

		Case siniestro;
		String helpers = '';
		System.Savepoint puntoGuardado = Database.setSavepoint();
		try{
			if(datosCaso != null){
				List<ComentarioId> listComentarioId;
				List<GarantiaPolizaId> listGarantiaPolizaId;
				List<PerjudicadoId> listPerjudicadoId;
				List<garantiaId> listGarantiaId;

				// 1. Se recoge el siniestro y se actualiza el LKP a la ayuda de indemnizable
				siniestro = datosCaso.getCase();

				// Código para verificar que se establecen a false los check que vienen NULL
				if(siniestro.CAS_CAS_Siniestro_Consorciable__c == false){
					siniestro.CAS_CAS_Siniestro_Consorciable__c = false;
				}
				if(siniestro.CAS_CAS_Siniestro_Grave__c == false){
					siniestro.CAS_CAS_Siniestro_Grave__c = false;
				}
				if(siniestro.CAS_CAS_Danos_Perjudicado__c == false){
					siniestro.CAS_CAS_Danos_Perjudicado__c = false;
				}
				if(siniestro.CAS_CAS_Danos_Propios__c == false){
					siniestro.CAS_CAS_Danos_Propios__c = false;
				}
				if(siniestro.CAS_CAS_Fraude__c == false){
					siniestro.CAS_CAS_Fraude__c = false;
				}
				if(siniestro.CAS_CAS_Rechazo_Parcial__c == false){
					siniestro.CAS_CAS_Rechazo_Parcial__c = false;
				}
				if(siniestro.CAS_CAS_Requiere_Perito__c == false){
					siniestro.CAS_CAS_Requiere_Perito__c = false;
				}
				if(siniestro.CAS_CAS_Siniestro_Consorciable__c == false){
					siniestro.CAS_CAS_Siniestro_Consorciable__c = false;
				}
				if(siniestro.CAS_CAS_Siniestro_Grave__c == false){
					siniestro.CAS_CAS_Siniestro_Grave__c = false;
				}
				if(siniestro.CAS_CAS_Supera_Limite_Actuacion__c == false){
					siniestro.CAS_CAS_Supera_Limite_Actuacion__c = false;
				}
				if(siniestro.CAS_CAS_Tercero_Causante__c == false){
					siniestro.CAS_CAS_Tercero_Causante__c = false;
				}
				if(siniestro.CAS_CAS_Transferido__c == false){
					siniestro.CAS_CAS_Transferido__c = false;
				}
				if(siniestro.CAS_CAS_Apertura_Parcial__c == false){
					siniestro.CAS_CAS_Apertura_Parcial__c = false;
				}
				/*			  
				// 1.1. Se asocia el Id de la ayuda indemnizable al siniestro a actualizar
				if(listadoAyuda != null && (!listadoAyuda.isEmpty())){
					Ayuda__c ayuda = listadoAyuda.get(0).getAyuda();
					if(ayuda.AYU_TXT_Identificador__c != null && ayuda.AYU_TXT_Identificador__c != ''){
						List<Ayuda__c> listaAyudasSF = new List<Ayuda__c>([SELECT Id FROM Ayuda__c WHERE AYU_TXT_Identificador__c = :ayuda.AYU_TXT_Identificador__c]);
						if(!listaAyudasSF.isEmpty()){
							siniestro.CAS_LKP_Ayuda_Indemnizable__c = listaAyudasSF.get(0).Id;
						}
						else {
							// Si no existe el identificador de la ayuda se devuelve el error
							throw new CrearSiniestroException('No existe ninguna Ayuda con identificador: "' + ayuda.AYU_TXT_Identificador__c + '".');
						}
					}
				}
				 */
				// 1.2. Se actualiza el siniestro
				update siniestro;
				siniestro = (Util_Caso.getCaseById(new Set<Id>{siniestro.Id}).values()).get(0);
				//siniestro = (Util_Caso.queryMapSiniCaso(new Set<Id>{siniestro.Id},null,1).values()).get(0);
				//siniestro = (Util_Siniestro.queryCaso(siniestro.Id, null, 1)).get(0);
				Id idVersionPoliza = siniestro.CAS_LKP_VersionPolizaContrato__c;
				Id idCompania = siniestro.CAS_LKP_Compania__c;
				String codCompania = siniestro.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
				// 2. Se recogen los comentarios asociados al siniestro
				if(listadoComentarios != null && (!listadoComentarios.isEmpty())){
					// 2.1. Se insertan los comentarios
					List<Comentario_caso__c> listaComentInsert = new List<Comentario_caso__c>();
					for(ListadoComentarios comentInsert : listadoComentarios){
						comentInsert.CMC_LKP_Caso = siniestro.Id;
						listaComentInsert.add(comentInsert.getComentarioCaso());
					}
					insert listaComentInsert;
					// 2.2. Se devuelven los ids de los comentarios insertados
					listComentarioId = new List<ComentarioId>();
					for(Comentario_caso__c comentInsert : listaComentInsert){
						listComentarioId.add(new ComentarioId(comentInsert.Id));
					}
				}

				// 3. Se recogen los Perjudicados asociados al siniestro
				if(listadoPerjudicado != null && (!listadoPerjudicado.isEmpty())){
					// 3.1. Se insertan los perjudicados
					List<Perjudicado_Siniestro__c> listaPerjudicadoIns = new List<Perjudicado_Siniestro__c>();
					for(ListadoPerjudicado perjudicadoIns : listadoPerjudicado){
						perjudicadoIns.PRJ_LKP_Siniestro = siniestro.Id;
						listaPerjudicadoIns.add(perjudicadoIns.getPerjudicado());
					}
					insert listaPerjudicadoIns;
					// 3.2. Se devuelven los ids de los perjudicados insertados
					listPerjudicadoId = new List<PerjudicadoId>();
					for(Perjudicado_Siniestro__c perj : listaPerjudicadoIns){
						listPerjudicadoId.add(new PerjudicadoId(perj.Id));
					}
				}

				// 4. Se recogen las Garantias asociadas al siniestro
				if(listadoGarantiasSiniestro != null && (!listadoGarantiasSiniestro.isEmpty())){
					// 4.1. Se guardan los códigos de garantía a vincular con el siniestro
					Set<String> codigosGarantia = new Set<String>();
					Integer i = 0;
					while(i < listadoGarantiasSiniestro.size()){
						ListadoGarantiasSiniestro garSiniestro = listadoGarantiasSiniestro.get(i);
						if(garSiniestro.GSIN_LKP_GarantiaSiniestro != null &&
								(!codigosGarantia.contains(garSiniestro.GSIN_LKP_GarantiaSiniestro))){
							codigosGarantia.add(garSiniestro.GSIN_LKP_GarantiaSiniestro);
							i++;
						}
						else {
							// Si hay algún código duplicado lo eliminamos de la lista a procesar
							listadoGarantiasSiniestro.remove(i);
						}
					}

					system.debug('idCompania: '+idCompania);
					system.debug('codigosGarantia: '+codigosGarantia);

					// 4.2. Se obtienen las garantías de la CIA a vincular con el siniestro
					List<Garantia__c> listaGarantiasSF = new List<Garantia__c>(
						[SELECT GAR_TXT_Codigo_Garantia__c
						 FROM Garantia__c
						 WHERE GAR_LKP_Compania__c = :idCompania
						 AND GAR_TXT_Codigo_Garantia__c IN :codigosGarantia]);

					system.debug('Listado Garantias SF: '+listaGarantiasSF);

					// y se guardan en un mapa cuya clave es el código
					Map<String, Garantia__c> mapaGarantiasCIA = new Map<String, Garantia__c>();
					for(Garantia__c garantiaSF : listaGarantiasSF){
						mapaGarantiasCIA.put(garantiaSF.GAR_TXT_Codigo_Garantia__c, garantiaSF);
					}
					// 4.3. Se obtienen las garantías de la CIA vinculadas actualmente al siniestro
					List<Garantia_Siniestro__c> listaGarSinSF = new List<Garantia_Siniestro__c>(
						[SELECT GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c
						 FROM Garantia_Siniestro__c
						 WHERE GSIN_LKP_Caso__c = :siniestro.Id]);
					// y se guardan en un mapa cuya clave es el código
					Map<String, Garantia_Siniestro__c> mapaGarSinSF = new Map<String, Garantia_Siniestro__c>();
					for(Garantia_Siniestro__c garSinSF : listaGarSinSF){
						mapaGarSinSF.put(garSinSF.GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c, garSinSF);
					}
					system.debug('mapa:'+mapaGarSinSF);
					// 4.4. Se insertan las vinculaciones garantía-siniestro
					List<Garantia_Siniestro__c> listaGarantiaSinUps = new List<Garantia_Siniestro__c>();
					for(ListadoGarantiasSiniestro garSiniestro : listadoGarantiasSiniestro){
						Garantia__c garantiaSF = mapaGarantiasCIA.get(garSiniestro.GSIN_LKP_GarantiaSiniestro);
						if(garantiaSF != null){
							Garantia_Siniestro__c garSinSF = mapaGarSinSF.get(garSiniestro.GSIN_LKP_GarantiaSiniestro);
							Garantia_Siniestro__c garantiaSinIns = garSiniestro.getGarantiaSiniestro();
							// Si la garantía ya está vinculada al siniestro: se actualizan los campos
							if (garSinSF != null){
								listaGarantiaSinUps.add(garSinSF);
							}
							// Si la garantía no está vinculada al siniestro: se inserta la vinculación
							else {
								garantiaSinIns.GSIN_LKP_Garantia__c = garantiaSF.Id;
								garantiaSinIns.GSIN_LKP_Caso__c = siniestro.id;
								listaGarantiaSinUps.add(garantiaSinIns);
							}
						}
						else {
							// Si no existe el código de garantía para la CIA se devuelve el error
							throw new CrearSiniestroException('No existe ninguna Garantía con código: "' + garSiniestro.GSIN_LKP_GarantiaSiniestro + '" para la Compañía: "' + codCompania + '".');
						}
					}
					system.debug('Listado Garantias Upsert: '+listaGarantiaSinUps);

					upsert listaGarantiaSinUps;
					// 4.5. Se devuelven los ids de las vinculaciones garantía-siniestro insertadas
					listGarantiaId = new List<GarantiaId>();
					for(Garantia_Siniestro__c garantiaSinUps : listaGarantiaSinUps){
						listGarantiaId.add(new GarantiaId(garantiaSinUps.Id));
					}
				}


				// 5. Se recogen las garantías de la póliza asociada al caso
				if(listadoGarantiasPoliza != null && !listadoGarantiasPoliza.isEmpty()){
					// 5.1. Se guardan los códigos de garantía a vincular con la póliza del siniestro
					Set<String> codigosGarantia = new Set<String>();
					Integer i = 0;
					while(i < listadoGarantiasPoliza.size()){
						ListadoGarantiasPoliza garPoliza = listadoGarantiasPoliza.get(i);
						if(garPoliza.GAR_TXT_Codigo_Garantia != null &&
								(!codigosGarantia.contains(garPoliza.GAR_TXT_Codigo_Garantia))){
							codigosGarantia.add(garPoliza.GAR_TXT_Codigo_Garantia);
							i++;
						}
						else {
							// Si hay algún código duplicado lo eliminamos de la lista a procesar
							listadoGarantiasPoliza.remove(i);
						}
					}
					// 5.2. Se obtienen las garantías de la CIA a vincular con la póliza
					List<Garantia__c> listaGarantiasSF = new List<Garantia__c>(
						[SELECT GAR_TXT_Codigo_Garantia__c
						 FROM Garantia__c
						 WHERE GAR_LKP_Compania__c = :idCompania
						 AND GAR_TXT_Codigo_Garantia__c IN :codigosGarantia]);
					// y se guardan en un mapa cuya clave es el código
					Map<String, Garantia__c> mapaGarantiasCIA = new Map<String, Garantia__c>();
					for(Garantia__c garantiaSF : listaGarantiasSF){
						mapaGarantiasCIA.put(garantiaSF.GAR_TXT_Codigo_Garantia__c, garantiaSF);
					}
					// 5.3. Se obtienen las garantías de la CIA vinculadas actualmente a la póliza
					List<Garantia_Poliza__c> listaGarPolSF = new List<Garantia_Poliza__c>(
						[SELECT GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c
						 FROM Garantia_Poliza__c
						 WHERE GPOL_LKP_VersionPolizaContrato__c = :idVersionPoliza]);
					// y se guardan en un mapa cuya clave es el código
					Map<String, Garantia_Poliza__c> mapaGarPolSF = new Map<String, Garantia_Poliza__c>();
					for(Garantia_Poliza__c garPolSF : listaGarPolSF){
						mapaGarPolSF.put(garPolSF.GPOL_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c, garPolSF);
					}
					// 5.4. Se insertan/actualizan las vinculaciones garantía-póliza
					List<Garantia_Poliza__c> listaGarantiaPolUps = new List<Garantia_Poliza__c>();
					for(ListadoGarantiasPoliza garantiaPolUps : listadoGarantiasPoliza){
						Garantia__c garantiaSF = mapaGarantiasCIA.get(garantiaPolUps.GAR_TXT_Codigo_Garantia);
						if(garantiaSF != null){
							Garantia_Poliza__c garPolSF = mapaGarPolSF.get(garantiaPolUps.GAR_TXT_Codigo_Garantia);
							Garantia_Poliza__c garantiaPolIns = garantiaPolUps.getGarantiaPoliza();
							// Si la garantía ya está vinculada a la póliza: se actualizan los campos
							if (garPolSF != null){
								garPolSF.GPOL_DIV_Franquicia__c = garantiaPolIns.GPOL_DIV_Franquicia__c;
								garPolSF.GPOL_DIV_Capital_Asegurado__c = garantiaPolIns.GPOL_DIV_Capital_Asegurado__c;
								listaGarantiaPolUps.add(garPolSF);
							}
							// Si la garantía no está vinculada a la póliza: se inserta la vinculación
							else {
								garantiaPolIns.GPOL_LKP_Garantia__c = garantiaSF.Id;
								garantiaPolIns.GPOL_LKP_VersionPolizaContrato__c = idVersionPoliza;
								listaGarantiaPolUps.add(garantiaPolIns);
							}
						}
						else {
							// Si no existe el código de garantía para la CIA se devuelve el error
							throw new CrearSiniestroException('No existe ninguna Garantía con código: "' + garantiaPolUps.GAR_TXT_Codigo_Garantia + '" para la Compañía: "' + codCompania + '".');
						}
					}
					upsert listaGarantiaPolUps;
					// 5.5. Se devuelven los ids de las vinculaciones garantía-póliza insertadas/actualizadas
					listGarantiaPolizaId = new List<GarantiaPolizaId>();
					for(Garantia_Poliza__c garantiaPolUps : listaGarantiaPolUps){
						listGarantiaPolizaId.add(new GarantiaPolizaId(garantiaPolUps.Id));
					}
				}

				// Se devuelve el resultado con éxito
				toRet.resultado = 'OK';
				toRet.caseId = siniestro.Id;
				toRet.listPerjudicadosId = listPerjudicadoId;
				toRet.listComentariosId = listComentarioId;
				toRet.listGarantiaPolizaId = listGarantiaPolizaId;
				toRet.listGarantiasId = listGarantiaId;
				toRet.errorCode = '000';
			}
		}
		catch(Exception e){
			// Se realiza rollback completo y se devuelve el resultado con error
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>>Excepcion: ' + e.getStackTraceString());
			toRet = new Resultado();
			toRet.resultado = e.getMessage();
			toRet.errorCode = '999';
			return toRet;	  
		}
		system.debug('>>>>>>>>>>>>>>Resultado: ' + toRet);
		return toRet; 
	}

	private class CrearSiniestroException extends Exception {}
}