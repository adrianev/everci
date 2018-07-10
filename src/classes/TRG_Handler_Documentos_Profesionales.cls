/**
  * Handler del Trigger TRG_Documentos_Profesionales_Contrato.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Documentos_Profesionales {
	
	/**	
	 *	Esta funcion ejecuta los metodos necesarios para el tratamiento del before
	 *	@param Map<Id,Account> triggerNewMap		- Mapa con los datos del Trigger.newMap
	 *	@param List<Account> triggerNew			- Lista con las cuentas del trigger.new
	 *	@param Map<Id,Account> triggerOldMap		- Mapa con los datos del Trigger.oldMap
	 *	@param List<Account> triggerOld			- Lista con las cuentas del trigger.old
	 */
	public static void tratamientoBefore(Map<Id,Documentos_Profesionales_Contrato__c> triggerNewMap, List<Documentos_Profesionales_Contrato__c> triggerNew, 
			Map<Id,Documentos_Profesionales_Contrato__c> triggerOldMap, List<Documentos_Profesionales_Contrato__c>triggerOld){

		if(trigger.isInsert || trigger.isUpdate){
			//Creamos un Set de Ids para los profesionales y otro para los tipos de documentos de los documentos del trigger
			Set<Id> setProfesionales = new Set<Id>();
			Set<Id> setTiposDocumento = new Set<Id>();
			for(Documentos_Profesionales_Contrato__c doc: triggerNew){
				setProfesionales.add(doc.DPC_LKP_Profesional_Contrato__c);
				setTiposDocumento.add(doc.DPC_LKP_Tipo_de_Documento__c);
			}
			//Nos traemos todos los profesionales cuyos Ids se encuentran en el setProfesionales
			Map <Id, Account> profesionales = Util_Service_Resource.queryMapProfesionales(setProfesionales);
			//Nos traemos un mapa con todos los registros de tipo de documento (Objeto Tipo_de_documento__c) cuyos Ids se encuentran en el setTiposDocumento
			Map<Id, Tipo_de_documento__c> tiposDocumento = Util_Service_Resource.queryMapDocumentos(setTiposDocumento);
			//Nos traemos un mapa con todos los documentos de todos los profesionales y todos los tipos de documento del trigger
			List<Documentos_Profesionales_Contrato__c> documentos = Util_Service_Resource.getDocProfesionalByProfesionalAndTipoDocumento(setProfesionales, setTiposDocumento).values();
			//Rellenamos un mapa de doble clave para conocer cuantos documentos existen por profesional y tipo 
			Map<String,Integer> mapaNumDocumentos = new Map<String,Integer>();
			Integer contador;
			for(Documentos_Profesionales_Contrato__c doc: documentos){
				if(doc.DPC_LKP_Profesional_Contrato__r.Name != null && doc.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c != null){
					if(mapaNumDocumentos.get(doc.DPC_LKP_Profesional_Contrato__r.Name + doc.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c) == null){
						contador = 1;
						mapaNumDocumentos.put(doc.DPC_LKP_Profesional_Contrato__r.Name + doc.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c, contador);
					}
					else{
						contador = mapaNumDocumentos.get(profesionales.get(doc.DPC_LKP_Profesional_Contrato__c).Name + doc.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c) + 1;
						mapaNumDocumentos.put(doc.DPC_LKP_Profesional_Contrato__r.Name + doc.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c, contador);
					}			
				}
			}
			//Rellenamos el identificador del documento por profesional + tipo + número
			//Rellenamos el campo fecha de baja para los documentos que tengan fecha de expiracion
			for(Documentos_Profesionales_Contrato__c doc: triggerNew){
				if(profesionales.get(doc.DPC_LKP_Profesional_Contrato__c) != null && tiposDocumento.get(doc.DPC_LKP_Tipo_de_Documento__c) != null){
					if(mapaNumDocumentos.get(profesionales.get(doc.DPC_LKP_Profesional_Contrato__c).Name + tiposDocumento.get(doc.DPC_LKP_Tipo_de_Documento__c).DOC_TXT_Identificador__c) != null){
						doc.DPC_TXT_Identificador__c = profesionales.get(doc.DPC_LKP_Profesional_Contrato__c).Name + '_' + tiposDocumento.get(doc.DPC_LKP_Tipo_de_Documento__c).DOC_TXT_Identificador__c + '_' + String.ValueOf(mapaNumDocumentos.get(profesionales.get(doc.DPC_LKP_Profesional_Contrato__c).Name + tiposDocumento.get(doc.DPC_LKP_Tipo_de_Documento__c).DOC_TXT_Identificador__c) + 1);
					}
					if(doc.DPC_DAT_Fecha_Expiracion__c != null){
						if(tiposDocumento.get(doc.DPC_LKP_Tipo_de_Documento__c).DOC_NUM_Dias_para_Baja__c != null){
							doc.DPC_DAT_Fecha_Baja__c = doc.DPC_DAT_Fecha_Expiracion__c.addDays(Integer.valueOf(tiposDocumento.get(doc.DPC_LKP_Tipo_de_Documento__c).DOC_NUM_Dias_para_Baja__c)+1);
						}
						else{
							doc.DPC_DAT_Fecha_Baja__c = doc.DPC_DAT_Fecha_Expiracion__c.addDays(1);
						}
					}
				}
			}		
		}
	}

     /** 
     *  Esta funcion ejecuta los metodos necesarios para el tratamiento del after
     *  @param Map<Id,Account> triggerNewMap        - Mapa con los datos del Trigger.newMap
     *  @param List<Account> triggerNew         - Lista con los documentos del trigger.new
     *  @param Map<Id,Account> triggerOldMap        - Mapa con los datos del Trigger.oldMap
     *  @param List<Account> triggerOld         - Lista con los documentos del trigger.old
     */
    public static void tratamientoAfter(Map<Id,Documentos_Profesionales_Contrato__c> triggerNewMap, List<Documentos_Profesionales_Contrato__c> triggerNew, Map<Id,Documentos_Profesionales_Contrato__c> triggerOldMap, List<Documentos_Profesionales_Contrato__c> triggerOld){
		//Creamos Set de Ids de profesionales con algún documento modificado
		//Además, creamos Set de Ids del tipo de documento (Objeto Tipo_de_documento__c) correspondiente a cada uno de los documentos modificados
		Set<Id> setProfesionales = new Set<Id>();
		Set<Id> setTiposDocumento = new Set<Id>();
		if(trigger.isInsert || trigger.isUpdate){
			for(Documentos_Profesionales_Contrato__c doc: triggerNew){
				if(doc.DPC_LKP_Profesional_Contrato__c != null){
					setProfesionales.add(doc.DPC_LKP_Profesional_Contrato__c);
				}
				if(doc.DPC_LKP_Tipo_de_Documento__c != null){
					setTiposDocumento.add(doc.DPC_LKP_Tipo_de_Documento__c);
				}				
			}
		}
		//Else que se utiliza por si se está haciendo un delete, para el que se necesitan también estos sets, pero en el que no existe el triggerNew
		else{
			for(Documentos_Profesionales_Contrato__c doc: triggerOld){
				if(doc.DPC_LKP_Profesional_Contrato__c != null){
					setProfesionales.add(doc.DPC_LKP_Profesional_Contrato__c);
				}
				if(doc.DPC_LKP_Tipo_de_Documento__c != null){
					setTiposDocumento.add(doc.DPC_LKP_Tipo_de_Documento__c);
				}				
			}
		}		
		//Nos traemos todos los profesionales cuyos Ids se encuentran en el setProfesionales
		Map <Id, Account> profesionales = Util_Service_Resource.queryMapProfesionales(setProfesionales);
		//Creamos un mapa de cuentas para subir a la DB que se vaya rellenando con los profesionales cuyo estado vaya a cambiar
		Map <Id, Account> profesionalesActualizar = new Map <Id, Account>();
		//Nos traemos un mapa con todos los contactos de las cuentas cuyos Ids se encuentran en el setProfesionales
		Map <Id, Contact> contactos = Util_Contacto.getContactByCuenta(setProfesionales);
		//Nos traemos un mapa con todos los recursos de servicio de todos los profesionales traidos anteriormente 
		Map<Id, ServiceResource> recursosServicioMap = Util_Service_Resource.queryMapRecursosServicio(setProfesionales);		
		//Nos traemos un mapa con todos los recursos de servicio de cada uno de los profesionales traidos anteriormente (ordenados por profesional)
		Map<Id, List<ServiceResource>> recursosServicioPorProf = Util_Service_Resource.getMapaRecursosServicio(setProfesionales);
		//Nos traemos un mapa con todos los registros de tipo de documento (Objeto Tipo_de_documento__c) cuyos Ids se encuentran en el setTiposDocumento
		Map<Id, Tipo_de_documento__c> tiposDocumento = Util_Service_Resource.queryMapDocumentos(setTiposDocumento);
    	
    	if(trigger.isInsert || trigger.isUpdate){
	    	//Recorremos los docuementos traidos por el Trigger para comprobar en cuales se ha superado la fecha de expiración y poner en baja temporal a sus profesionales correspondientes 
	    	for(Documentos_Profesionales_Contrato__c doc: triggerNew){
	    		if(doc.DPC_LKP_Profesional_Contrato__c != null && doc.DPC_LKP_Tipo_de_Documento__c != null){
	    			Boolean cuentaCambiada = false;
	    			Tipo_de_documento__c tipoDocumento = tiposDocumento.get(doc.DPC_LKP_Tipo_de_Documento__c);
		    		Account ProfesionalUpdate = Profesionales.get(doc.DPC_LKP_Profesional_Contrato__c);
		    		Contact contactoPrincipal = null;
		    		if(ProfesionalUpdate.CUE_LKP_contacto_principal__c != null){
		    			contactoPrincipal = contactos.get(ProfesionalUpdate.CUE_LKP_contacto_principal__c);
		    		}
		    		if(tipoDocumento.DOC_CAS_Estado_Documento__c && tipoDocumento.DOC_DAT_Fecha_Inicio_Vigencia__c <= Date.today() && tipoDocumento.DOC_CAS_Validez__c && ProfesionalUpdate.CUE_SEL_Estado__c == Label.CUE_ESTADO_ACTIVADO){
		    			if(doc.DPC_DAT_Fecha_Expiracion__c.addDays(-30) == Date.today()){
		    				if (contactoPrincipal != null){
			    				String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
			    				List<String> correoDestinatario = new List<String>();
			    				correoDestinatario.add(contactoPrincipal.Email);
			    				String asunto ='AVISO CADUCIDAD ' + tipoDocumento.Name.toUpperCase();
			    				String cuerpo = '';
			    				if(tipoDocumento.DOC_TXT_Texto_Email__c != null){
			    					cuerpo = tipoDocumento.DOC_TXT_Texto_Email__c;
			    				}
	                			Util_Correo_Electronico.enviarSingleEmailSinPlantilla(ProfesionalUpdate.Id,asunto,cuerpo,'HTML',contactoPrincipal.Id,correoDestinatario,null,correoRemitente,null);
		    				}
		    			}
		    			if(doc.DPC_DAT_Fecha_Expiracion__c.addDays(Integer.valueOf(tipoDocumento.DOC_NUM_Dias_para_Baja__c)) <= Date.today()){
		    				ProfesionalUpdate.CUE_SEL_Estado__c = Label.CUE_ESTADO_BAJA_TEMPORAL;
		    				ProfesionalUpdate.CUE_SEL_Motivo_Baja_Temp__c = Label.CUE_MOTIVO_BAJA_DOCUMENTACION;
		    				ProfesionalUpdate.CUE_TXT_Observaciones_BajaTemp__c = 'Ha expirado el documento ' + tipoDocumento.Name;
		    				cuentaCambiada = true;
		    				if (contactoPrincipal != null){
			    				String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
			    				List<String> correoDestinatario = new List<String>();
			    				correoDestinatario.add(contactoPrincipal.Email);
			    				String asunto ='AVISO BAJA DE PROFESIONAL \'' + ProfesionalUpdate.Name + '\' POR CADUCIDAD DEL DOCUMENTO \'' + tipoDocumento.Name.toUpperCase() + '\'';
			    				String cuerpo = '';
			    				if(tipoDocumento.DOC_TXT_Texto_Email_Baja__c != null){
			    					cuerpo = tipoDocumento.DOC_TXT_Texto_Email_Baja__c;
			    				}
	                			Util_Correo_Electronico.enviarSingleEmailSinPlantilla(ProfesionalUpdate.Id,asunto,cuerpo,'HTML',contactoPrincipal.Id,correoDestinatario,null,correoRemitente,null);
		    				}
		    			}   			
		    		}
		    		if(tipoDocumento.DOC_TXT_Identificador__c == Label.DOC_TIPO_CONTRATISTAS){
		    			ProfesionalUpdate.CUE_DAT_Vencimiento_Certificado__c = doc.DPC_DAT_Fecha_Expiracion__c;
		    			cuentaCambiada = true;
		    		}
		    		else if(tipoDocumento.DOC_TXT_Identificador__c == Label.DOC_TIPO_SEGURO_RC){
		    			ProfesionalUpdate.CUE_DAT_RC_Vencimiento_Poliza__c = doc.DPC_DAT_Fecha_Expiracion__c;
		    			cuentaCambiada = true;
		    		}else if(tipoDocumento.DOC_TXT_Identificador__c == Label.DOC_TIPO_TGSS){
		    			ProfesionalUpdate.CUE_DAT_Fecha_Vto_Seg_Social__c = doc.DPC_DAT_Fecha_Expiracion__c;
		    			cuentaCambiada = true;
		    		}
		    		if(cuentaCambiada == true){
		    			ProfesionalesActualizar.put(doc.DPC_LKP_Profesional_Contrato__c,ProfesionalUpdate);
		    		}
	    		}
	    	}
    	}    	
    	//Nos traemos de la DB todos los documentos de los profesionales con algún documento modificado
    	Map <Id, List<Documentos_Profesionales_Contrato__c>> docsByProfesional = Util_Service_Resource.getMapaDocumentosPR(setProfesionales);   	
    	//Recorremos todos los recursos de servicio para rellenar un set con los ids de los usuarios asignados a cada uno de ellos
    	Set<Id> setUsuarios = new Set<Id>();
    	for(ServiceResource sr: recursosServicioMap.values()){
    		if(sr.RelatedRecordId != null){
    			setUsuarios.add(sr.RelatedRecordId);
    		}
    	}
    	//Nos traemos un mapa con todos los usuarios cuyo Id se encuentr en el set anterior
    	Map<Id, User> usuarios = Util_Perfiles_Usuario.queryMapUsuario(setUsuarios);
    	//Map<Id, User> usuarios = Util_Service_Resource.queryMapUsuarios(setUsuarios);
    	
    	//Recorremos todos los profesionales para rellenar un set con los tipos de profesionales para traer los tipos de documentos requeridos para cada tipo de profesional
    	Set<String> setTiposProfesionales = new Set<String>();
    	for (Account Pr: profesionales.values()){
    		if(Pr.CUE_SEL_Tipo_de_Profesional__c != null){
    			setTiposProfesionales.add(Pr.CUE_SEL_Tipo_de_Profesional__c);
    		}
    	}    	
    	//Nos traemos un mapa con todos los documentos requeridos para cada tipo de profesional
    	Map <String, List<Tipo_de_documento__c>> docsReqPorTipoProf = Util_Service_Resource.getMapaDocumentosPorTipoProfesional(setTiposProfesionales);    	
    	//Recorremos todos los documentos de todos los profesionales y activamos los profesionales que tengan todos los documentos requeridos cargados y no caducados
    	for (Account Pr: profesionales.values()){
    		Boolean todosDocsNivelPR = false;
    		Boolean requiereDocsNivelSR = false;
    		Boolean todosDocsNivelSR = true;
    		String gremioAux;
    		String tipoDocAux;
    		List <Tipo_de_documento__c> tipoDocRequeridos = new List <Tipo_de_documento__c>();
    		List <Tipo_de_documento__c> tipoDocRequeridosConGremio = new List <Tipo_de_documento__c>();
    		List <Tipo_de_documento__c> tipoDocRequeridosSinGremio = new List <Tipo_de_documento__c>();
    		List<Documentos_Profesionales_Contrato__c> documentosProfesional = new List <Documentos_Profesionales_Contrato__c>();
    		List<String> codDocProfNivelPr = new List<String>();
    		Set<String> setCodDocProfNivelPr = new Set<String>();
			List<Documentos_Profesionales_Contrato__c> documentosProfesionalNivelSR = new List <Documentos_Profesionales_Contrato__c>();
    		//Separamos los tipos de documento requeridos para el profesional en dos listas dependiendo si son de nivel profesional o de nivel SR. 
    		if(docsReqPorTipoProf.get(Pr.CUE_SEL_Tipo_de_Profesional__c) != null && !docsReqPorTipoProf.get(Pr.CUE_SEL_Tipo_de_Profesional__c).isEmpty()){
    			tipoDocRequeridos = docsReqPorTipoProf.get(Pr.CUE_SEL_Tipo_de_Profesional__c);
    			for (Tipo_de_documento__c doc: tipoDocRequeridos){
    				if(doc.DOC_SEL_Gremio__c == null){
    					tipoDocRequeridosSinGremio.add(doc);
    				}
    				else
    				{
    					tipoDocRequeridosConGremio.add(doc);
    				}
    			}
    			//Ponemos a true el booleano "requiereDocsNivelSR" si la lista "tipoDocRequeridosConGremio" esta rellena, es decir, se requieren documentos a nivel SR
    			if (tipoDocRequeridosConGremio != null && !tipoDocRequeridosConGremio.isEmpty()){
    				requiereDocsNivelSR = true;
    			}
    		}
    		//Separamos los documentos de profesional contrato que tiene entregados el profesional dependiendo si son de nivel profesional o de nivel SR. 
    		//En el caso de que sean a nivel profesional, metemos el identificador del tipo en un set ya que es necesario disponer mínimo de uno de cada tipo.
    		if(docsByProfesional.get(Pr.Id) != null && !docsByProfesional.get(Pr.Id).isEmpty()){
    			documentosProfesional = docsByProfesional.get(Pr.Id);
    			for (Documentos_Profesionales_Contrato__c docPr: documentosProfesional){
    				DateTime nuevaFechaBaja = null;
    				if(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_NUM_Dias_para_Baja__c != null && docPr.DPC_DAT_Fecha_Expiracion__c != null){
    					nuevaFechaBaja = docPr.DPC_DAT_Fecha_Expiracion__c.addDays(Integer.valueOf(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_NUM_Dias_para_Baja__c));
    				}    				
    				if (nuevaFechaBaja > Date.today() || docPr.DPC_DAT_Fecha_Expiracion__c == null){
	    				if(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_SEL_Gremio__c == null){
	    					setCodDocProfNivelPr.add(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c);
	    				}
	    				else
	    				{
	    					documentosProfesionalNivelSR.add(docPr);
	    				}
    				}
    			}
    			if(setCodDocProfNivelPr != null && !setCodDocProfNivelPr.isEmpty()){
    				codDocProfNivelPr.addAll(setCodDocProfNivelPr);
    			}
    		} 
    		//Si existen tipo de documentos requeridos a nivel profesional  y el profesional tiene documentos entregados a nivel profesional, se comprueba que ha entregado todos los tipos de documentos requeridos para su tipo 		
    		if(setCodDocProfNivelPr != null && !setCodDocProfNivelPr.isEmpty() && tipoDocRequeridosSinGremio != null && !tipoDocRequeridosSinGremio.isEmpty()){
    			if(codDocProfNivelPr.size() == tipoDocRequeridosSinGremio.size()){
    				todosDocsNivelPR = true;
    			//Este else se utiliza en el caso de que un documento requerido se elimine de la base de datos por equivocación o por algún motivo
    			//En este caso, el profesional se pondría en baja y se setearían las observaciones indicando el documento que se ha eliminado y que tiene que volver a cargarse para activar el profesional
    			} else {
    				if(trigger.isDelete){
	    				if(Pr.CUE_SEL_Estado__c == Label.CUE_ESTADO_ACTIVADO){
	    					for(Tipo_de_documento__c doc: tipoDocRequeridosSinGremio){
	    						if (!setCodDocProfNivelPr.contains(doc.DOC_TXT_Identificador__c)){
	    							Pr.CUE_SEL_Estado__c = Label.CUE_ESTADO_BAJA_TEMPORAL;
		    						Pr.CUE_SEL_Motivo_Baja_Temp__c = Label.CUE_MOTIVO_BAJA_DOCUMENTACION;
		    						Pr.CUE_TXT_Observaciones_BajaTemp__c = 'Ha sido eliminado el documento: ' + doc.Name + '. Por favor, cárguelo de nuevo.';
		    						ProfesionalesActualizar.put(Pr.Id,Pr);	
	    						}
	    					}
	    				}
    				}
    			}
    		}    		
    		//Lógica a ejecutar si el tipo de profesional requiere documentos a nivel de recurso de servicio
    		if (requiereDocsNivelSR){
    			//Rellenamos un set de gremios con todos los gremios que requieren documentacion
    			//Y un mapa de gremio, lista de documentos (mediante un set de sus identificadores) para ver los documentos que requiere cada gremio
    			Set<String> setGremios = new Set<String>();
    			Map<String, Set<String>> mapaDocumentosPorGremio = new Map<String, Set<String>>();
    			Map<String, String> mapaDocumentoIdName = new Map<String, String>();
    			Set<String> docsAux;
				if(tipoDocRequeridosConGremio != null && !tipoDocRequeridosConGremio.isEmpty()){
					for(Tipo_de_documento__c docConGremio: tipoDocRequeridosConGremio){
						setGremios.add(docConGremio.DOC_SEL_Gremio__c);
						mapaDocumentoIdName.put(docConGremio.DOC_TXT_Identificador__c,docConGremio.Name);
						if(mapaDocumentosPorGremio.get(docConGremio.DOC_SEL_Gremio__c) == null){
							docsAux = new Set<String>();
							docsAux.add(docConGremio.DOC_TXT_Identificador__c);
							mapaDocumentosPorGremio.put(docConGremio.DOC_SEL_Gremio__c,docsAux);
						}
						else {
							mapaDocumentosPorGremio.get(docConGremio.DOC_SEL_Gremio__c).add(docConGremio.DOC_TXT_Identificador__c);
						}
					}
				}
				//Rellenamos una mapa de gremio, set de Ids de SR con los recursos de servicio del porfesional por cada gremio, pero solo para los gremios que requieren documentación
				//También se comprueba que se cojan solo los sr activos o inactivos por falta de documentación
				Map<String, Set<Id>> mapaSRPorGremio = new Map <String, Set<Id>>();
				Set<Id> srAux;
				if(recursosServicioPorProf.get(Pr.Id) != null && !recursosServicioPorProf.get(Pr.Id).isEmpty()){
					List<ServiceResource> recursosServicio = recursosServicioPorProf.get(Pr.Id);
					for(ServiceResource sr: recursosServicio){
						if(setGremios.contains(sr.RSE_SEL_Gremio__c)){
							if(usuarios.get(sr.RelatedRecordId) != null){
								if(Pr.CUE_SEL_Estado__c == Label.CUE_ESTADO_PREACTIVADO || (usuarios.get(sr.RelatedRecordId).isActive || usuarios.get(sr.RelatedRecordId).USR_SEL_Motivo_de_desactivacion__c == Label.USR_MOTIVO_DESACT_DOCUMENTACION)){
									if(mapaSRPorGremio.get(sr.RSE_SEL_Gremio__c) == null){
										srAux = new Set<Id>();
										srAux.add(sr.Id);
										mapaSRPorGremio.put(sr.RSE_SEL_Gremio__c, srAux);
									}
									else{
										mapaSRPorGremio.get(sr.RSE_SEL_Gremio__c).add(sr.Id);
									}
								}
							}							
						}
					}
				}
				//Rellenamos un mapa de doble clave para ver de cuantos documentos el profesional por gremio y por tipo
				Map<String,Integer> mapaNumDocumentos = new Map<String,Integer>();
				Integer contador;
				if(documentosProfesionalNivelSR != null && !documentosProfesionalNivelSR.isEmpty()){
					for(Documentos_Profesionales_Contrato__c docPr : documentosProfesionalNivelSR){
						if(mapaNumDocumentos.get(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_SEL_Gremio__c + docPr.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c) == null){
							contador = 1;
							mapaNumDocumentos.put(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_SEL_Gremio__c + docPr.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c, contador);
						}
						else{
							contador = mapaNumDocumentos.get(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_SEL_Gremio__c + docPr.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c) + 1;
							mapaNumDocumentos.put(docPr.DPC_LKP_Tipo_de_Documento__r.DOC_SEL_Gremio__c + docPr.DPC_LKP_Tipo_de_Documento__r.DOC_TXT_Identificador__c, contador);
						}						
					}
				}
				//Recorremos el mapa anterior para comprobar si tenemos todos los documentos requeridos por tipo y gremio
				for(String gremio: setGremios){
					Set<String> tiposDocumentos = mapaDocumentosPorGremio.get(gremio);
					for(String tipoDoc: tiposDocumentos){
						if(mapaSRPorGremio.get(gremio) != null && !mapaSRPorGremio.get(gremio).isEmpty()){
							if(mapaNumDocumentos.get(gremio + tipoDoc) != null){							
									if(mapaNumDocumentos.get(gremio + tipoDoc) < mapaSRPorGremio.get(gremio).size()){
										todosDocsNivelSR = false;
										Map<String, String> mapaGremio = Util_Listas_Seleccion.getLabelDesdeAPI('Tipo_de_documento__c', 'DOC_SEL_Gremio__c');
										gremioAux = mapaGremio.get(gremio);
										if(mapaDocumentoIdName.get(tipoDoc) != null){
											tipoDocAux = mapaDocumentoIdName.get(tipoDoc);
										} 
										else{
											tipoDocAux = tipoDoc;
										}
									}
							}
							else{
								todosDocsNivelSR = false;
							}
						}
					}
				}  			
    		}
    		//Activamos los profesionales que esten en estado preactivado o baja temporal y cumplan los siguientes requisitos:
    		//1-Ha entregado al menos un documento de cada tipo de los requeridos a nivel profesional para el tipo de profesional en cuestión
    		//2-Si tiene recursos de servicio con un gremio para el cual se requieren uno/varios tipo de documento específicos, 
    		//ha entregado un documento de cada tipo de los requeridos para un gremio por cada recurso de servicio de dicho gremio que tenga el profesional    		
			if (todosDocsNivelPR){
				if(!requiereDocsNivelSR || (requiereDocsNivelSR && todosDocsNivelSR)){
					if(Pr.CUE_SEL_Estado__c == Label.CUE_ESTADO_PREACTIVADO){
	    				Pr.CUE_SEL_Estado__c = Label.CUE_ESTADO_ACTIVADO;
		    			ProfesionalesActualizar.put(Pr.Id,Pr);
					}
					else if (Pr.CUE_SEL_Estado__c == Label.CUE_ESTADO_BAJA_TEMPORAL){
						if(Pr.CUE_SEL_Motivo_Baja_Temp__c == Label.CUE_MOTIVO_BAJA_DOCUMENTACION){
							Pr.CUE_SEL_Estado__c = Label.CUE_ESTADO_ACTIVADO;
							Pr.CUE_SEL_Motivo_Baja_Temp__c = null;
    						Pr.CUE_TXT_Observaciones_BajaTemp__c = null;
    						ProfesionalesActualizar.put(Pr.Id,Pr);
						}
					}
				}
				//Este else se utiliza en el caso de que un documento requerido se elimine de la base de datos por equivocación o por algún motivo o si se añade a posteriori un SR que requiere algún documento
    			//En este caso, el profesional se pondría en baja y se setearían las observaciones indicando el documento que se ha eliminado (o es necesario para un hipotético nuevo SR y que tiene que volver a cargarse para activar el profesional
				else if(requiereDocsNivelSR && !todosDocsNivelSR){
					if(trigger.isDelete || trigger.isUpdate){
	    				if(Pr.CUE_SEL_Estado__c == Label.CUE_ESTADO_ACTIVADO){
							Pr.CUE_SEL_Estado__c = Label.CUE_ESTADO_BAJA_TEMPORAL;
    						Pr.CUE_SEL_Motivo_Baja_Temp__c = Label.CUE_MOTIVO_BAJA_DOCUMENTACION;
    						if(trigger.isDelete){
    							Pr.CUE_TXT_Observaciones_BajaTemp__c = 'Ha sido eliminado un documento de tipo "' + tipoDocAux + '", necesario para Recurso de Servicio de Gremio "' + gremioAux + '". Por favor, cárguelo de nuevo.';
    						}
    						else{
    							Pr.CUE_TXT_Observaciones_BajaTemp__c = 'Ha sido agregado un nuevo Recurso de Servicio de Gremio "' + gremioAux + '". Es necesario que se cargue al profesional un documento de tipo  "' + tipoDocAux + '". Mientras tanto, el profesional se mantendrá dado de baja.';
    						}
    						ProfesionalesActualizar.put(Pr.Id,Pr);	
	    				}
    				}
				}
			}	
    	}

		update ProfesionalesActualizar.values();       
    }
}