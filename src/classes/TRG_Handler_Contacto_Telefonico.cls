public without sharing class TRG_Handler_Contacto_Telefonico {

	/*
	 *  FUNCION QUE GENERA EL IDENTIFICADOR DEL Contacto_telefonico__c SIEMPRE Y CUANDO EL CAMPO CTF_TXT_Identificador SEA NULO
	 *
	 *
	 *
	 **/
	public static void generarIdentificadorContactoTelefono(List<Contacto_telefonico__c> listaConTelfNuevos, Map<Id, Contacto_telefonico__c> listaConTelVieja, Boolean insercion){

		Set<Id> idSetContactos = new Set<Id>();
		Set<Id> idSetPoliza = new Set<Id>();
		Set<Id> idSetCaso = new Set<Id>();
		for(Contacto_telefonico__c conT : listaConTelfNuevos){
			if(!idSetContactos.contains(conT.CTF_LKP_Contacto__c)){
				idSetContactos.add(conT.CTF_LKP_Contacto__c);
			}
			if(!idSetPoliza.contains(conT.CTF_LKP_Poliza_Contrato__c)){
				idSetPoliza.add(conT.CTF_LKP_Poliza_Contrato__c);
			}
			if(!idSetCaso.contains(conT.CTF_LKP_Caso__c)){
				idSetCaso.add(conT.CTF_LKP_Caso__c);
			}
		}
		system.debug('***** idSetContactos : ' + idSetContactos);
		system.debug('***** idSetPoliza : ' + idSetPoliza);
		system.debug('***** idSetCaso : ' + idSetCaso);

		Map<Id, Contact> mapaContactos = new Map<Id, Contact>(Util_Contacto.getContactById(idSetContactos));
				/*[ SELECT Id,
				  CON_TXT_Identificador__c
				  FROM Contact 
				  WHERE Id IN :idSetContactos]);*/

		Map<Id, ServiceContract> mapaPolizas = new Map<Id, ServiceContract>(Util_Poliza_Contrato.queryPolizaById(idSetPoliza));
				/*[ SELECT Id,
				  Name,
				  POL_LKP_Compania__r.CUE_TXT_Identificador__c
				  FROM ServiceContract 
				  WHERE Id IN :idSetPoliza]);*/

		Map<Id, Case> mapaCasos = new Map<Id, Case>(Util_Caso.getCaseById(idSetCaso));
				/*[ SELECT Id,
				  CaseNumber
				  FROM Case 
				  WHERE Id IN :idSetCaso]);*/
		system.debug('***** mapaContactos : ' + mapaContactos);
		system.debug('***** mapaPolizas : ' + mapaPolizas);
		system.debug('***** mapaCasos : ' + mapaCasos);
		for(Contacto_telefonico__c conTelf : listaConTelfNuevos){
			if(insercion && conTelf.CTF_TXT_Identificador__c == null && conTelf.CTF_LKP_Contacto__c != null){
                system.debug(Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CTF_CASO) + 'peeeeeeeeeeeeeeeeeeeeeeeeeee');
				if(conTelf.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CTF_POLIZA)){
					ServiceContract poliza = mapaPolizas.get(conTelf.CTF_LKP_Poliza_Contrato__c);
                    system.debug(poliza.POL_LKP_Compania__r.CUE_TXT_Identificador__c + '_' +poliza.Name + 'buenoooooooo');
                    system.debug(poliza.POL_LKP_Compania__r + '22222222');
                    system.debug(poliza + '444444');
                    conTelf.CTF_TXT_Identificador__c = mapaContactos.get(conTelf.CTF_LKP_Contacto__c).CON_TXT_Identificador__c + '_' + 
							poliza.POL_LKP_Compania__r.CUE_TXT_Identificador__c + '_' +poliza.Name;
				}else if(conTelf.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CTF_CASO)){
					conTelf.CTF_TXT_Identificador__c = mapaContactos.get(conTelf.CTF_LKP_Contacto__c).CON_TXT_Identificador__c + '_' + 
							mapaCasos.get(conTelf.CTF_LKP_Caso__c).CaseNumber;
				}
			}else if(!insercion && hayModificaciones(conTelf, listaConTelVieja, mapaContactos, mapaPolizas, mapaCasos)){
				conTelf.CTF_TXT_Identificador__c =  getIdentificador(conTelf, listaConTelVieja, mapaContactos, mapaPolizas, mapaCasos);
			}
		}//fin for
	}//FIN FUNCION

	 @testvisible private static Boolean hayModificaciones(Contacto_telefonico__c conTelf, Map<Id, Contacto_telefonico__c> listaConTelVieja, Map<Id, Contact> mapaContactos, Map<Id, ServiceContract> mapaPolizas, Map<Id, Case> mapaCasos){
		//Si los identificadores son distntos
		Contacto_telefonico__c conTelViejo = listaConTelVieja.get(conTelf.Id);
		ServiceContract poliza = mapaPolizas.get(conTelf.CTF_LKP_Poliza_Contrato__c);
		if (conTelViejo.CTF_TXT_Identificador__c != conTelf.CTF_TXT_Identificador__c
				|| conTelViejo.CTF_LKP_Contacto__r.CON_TXT_Identificador__c != mapaContactos.get(conTelf.CTF_LKP_Contacto__c).CON_TXT_Identificador__c
				|| conTelViejo.CTF_LKP_Poliza_Contrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c != poliza.POL_LKP_Compania__r.CUE_TXT_Identificador__c
				|| conTelViejo.CTF_LKP_Poliza_Contrato__r.Name != poliza.Name
				|| conTelViejo.CTF_LKP_Caso__r.CaseNumber != mapaCasos.get(conTelf.CTF_LKP_Caso__c).CaseNumber){
			return true;
		}else{
			return false;
		}
	}

	private static String getIdentificador(Contacto_telefonico__c conTelf, Map<Id, Contacto_telefonico__c> listaConTelVieja, Map<Id, Contact> mapaContactos, Map<Id, ServiceContract> mapaPolizas, Map<Id, Case> mapaCasos){

		String identificador;

		if (listaConTelVieja.get(conTelf.Id).CTF_TXT_Identificador__c != conTelf.CTF_TXT_Identificador__c){
			identificador = conTelf.CTF_TXT_Identificador__c;
		} else {
			if(conTelf.CTF_LKP_Poliza_Contrato__c != null){
				ServiceContract poliza = mapaPolizas.get(conTelf.CTF_LKP_Poliza_Contrato__c);
				identificador = mapaContactos.get(conTelf.CTF_LKP_Contacto__c).CON_TXT_Identificador__c + '_' + poliza.POL_LKP_Compania__r.CUE_TXT_Identificador__c + '_' + poliza.Name;
			}else if(conTelf.CTF_LKP_Caso__c != null){
				identificador = mapaContactos.get(conTelf.CTF_LKP_Contacto__c).CON_TXT_Identificador__c + '_' + mapaCasos.get(conTelf.CTF_LKP_Caso__c).CaseNumber;
			}
		}

		return identificador;   
	}

	private  static List<Contacto_telefonico__c> recogeLista(Map<Id, Contacto_telefonico__c> lista){
		List<Contacto_telefonico__c> listaContactosTelefonicos = new List<Contacto_telefonico__c>(Util_Contacto_Telefonico.queryMapCT(lista.keySet()).values());
				/*[SELECT CTF_LKP_Caso__c,
				 CTF_LKP_Caso__r.Type,
				 CTF_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, //campo necesario para movimientos
				 CTF_LKP_Caso__r.RecordTypeId, //campo necesario para movimientos
				 CTF_LKP_Contacto__r.Phone,
				 CTF_LKP_Caso__r.ParentId,
				 CTF_LKP_Contacto_Telefonico__c,
				 CTF_LKP_Contacto__c, 
				 CTF_CAS_Contacto_Poliza__c, 
				 CTF_FOR_Email__c, 
				 CTF_FOR_Apellidos__c, 
				 CTF_SEL_Hora_desde__c, 
				 RecordType.DeveloperName,
				 CTF_TXT_Identificador__c,
				 CTF_LKP_Contacto__r.CON_TXT_Identificador__c,
				 CTF_SEL_Hora_hasta__c, 
				 CTF_FOR_Nombre__c, 
				 CTF_TXT_Observaciones__c,
				 CTF_LKP_Poliza_Contrato__r.POL_LKP_Compania__r.CUE_TXT_Identificador__c,
				 CTF_LKP_Poliza_Contrato__r.Name,
				 CTF_FOR_Poliza_Contrato__c,
				 CTF_LKP_Poliza_Contrato__c, 
				 CTF_CAS_SMS__c, 
				 CTF_FOR_Telefono__c,
				 CTF_FOR_TelefonoAdicional__c,
				 CTF_FOR_TelefonoMovil__c,
				 CTF_SEL_Tipo_Relacion__c,
				 RecordTypeId,
				 CTF_LKP_Contacto__r.MobilePhone
				 FROM Contacto_telefonico__c
				 WHERE Id IN :lista.keySet()]);*/
		return listaContactosTelefonicos;
	}

	public static void tratamientoContactoTelefonicoAfterInsert(List<Contacto_telefonico__c> listaConTelfNuevos, Map<Id, Contacto_telefonico__c> listaConTelNueva){
		//Lista que contendrá los contactos que se van a actualizar
		List<Contacto_telefonico__c> listaConTelfDuplicados = new List<Contacto_telefonico__c>();
		//RECOJO LA LISTA DE LOS CONTACTOS TELEFONICOS QUE DESENCADENAN EL TRIGGER, RECOGIENDO TODOS SUS CAMPOS Y 
		//TAMBIEN EL CASO PRINCIPAL DEL CASO VINCULADO AL CONTACTO CASO
		List<Contacto_telefonico__c> listaContactosTelefonicos = recogeLista(listaConTelNueva);

		//SET CON LOS ID's DE LOS CASOS QUE TIENEN ASOCIADOS LOS CONTACTOS TELEFONICOS
		Set<Id> setIdCaso = new Set<Id>(); 
		//RECORRO EL Trigger.new y guardo en el set los ids de los casos de los contactos
		for(Contacto_telefonico__c conTelf : listaConTelfNuevos){
			if(conTelf.CTF_LKP_Caso__c != null){
				setIdCaso.add(conTelf.CTF_LKP_Caso__c);
			}
		}

		//Lista con los casos que tienen como caso padre el caso vinculado al contacto telefonico
		List<Case> listaCasosHijos = new List<Case>(Util_Caso.getMapaCasosHijosByParentId(setIdCaso).values());
				/*[SELECT ParentId
				 FROM Case
				 WHERE ParentId IN :setIdCaso]);*/

		//ESTE MAPA TIENE PRIMERO EL ID DEL CASO POR EL QUE SE BUSCA, Y EN SEGUNDO LUGAR EL CASO QUE TIENE COMO CASO PRINCIPAL EL ID DEL CASO BUSCADO
		//ID PADRE, ID HIJO
		Map<Id, Id> mapaIdCasosConHijos = new Map<Id,Id>();
		for(Case cas : listaCasosHijos){
			if(!mapaIdCasosConHijos.containsKey(cas.ParentId)){
				//Guardo en el mapa el Id del caso padre y el Id del caso Indemnizable (el hijo)
				mapaIdCasosConHijos.put(cas.ParentId, cas.Id);
			}
		}

		system.debug('*********** mapaIdCasosConHijos : ' + mapaIdCasosConHijos);
		system.debug('***************** ANTES FOR: listaContactosTelefonicos : ' + listaContactosTelefonicos);
		for(Contacto_telefonico__c conT : listaContactosTelefonicos){
            system.debug(conT.CTF_LKP_Caso__r);
			//SI EL CASO DEL CONTACTO TELEFÓNICO TIENE UN CASO PADRE
			if(conT.CTF_LKP_Caso__r.ParentId != null    //Si el caso vinculado al contacto telefonico tiene un padre
					&& conT.CTF_LKP_Contacto_Telefonico__c == null //y no tiene el LKP a contacto telefonico relleno
					&& mapaIdCasosConHijos.get(conT.CTF_LKP_Caso__c) == null){ //y el caso no tiene hijos
				//DUPLICO EL CONTACTO PONIENDO EL LKP DE CONTACTO TELEFONICO
				Contacto_telefonico__c conTNew = conT.clone(false, true);
				conTNew.CTF_LKP_Contacto_Telefonico__c = conT.Id;
				conTNew.RecordTypeId = conT.RecordTypeId;
				conTNew.CTF_LKP_Caso__c = conT.CTF_LKP_Caso__r.ParentId;
				listaConTelfDuplicados.add(conTNew);
			}else if(mapaIdCasosConHijos.get(conT.CTF_LKP_Caso__c) != null  ////SI EL MAPA CONTIENE EL CASO DE CONT  
					&& conT.CTF_LKP_Contacto_Telefonico__c == null //Y EL LKP A CONTACTO TELEFONICO NO ESTA RELLENO
					&& conT.CTF_LKP_Caso__r.ParentId == null){ //Y EL CASO NO TIENE PADRE
				//DUPLICO EL CONTACTO PONIENDO EL LKP DE CONTACTO TELEFONICO
				Contacto_telefonico__c conTNew = conT.clone(false, true);
				conTNew.CTF_LKP_Contacto_Telefonico__c = conT.Id;
				conTNew.RecordTypeId = conT.RecordTypeId;
				conTNew.CTF_LKP_Caso__c = mapaIdCasosConHijos.get(conT.CTF_LKP_Caso__c);
				listaConTelfDuplicados.add(conTNew);
			}
			generaMovimientos(new case(Id = conT.CTF_LKP_Caso__c,RecordTypeId = conT.CTF_LKP_Caso__r.RecordTypeId, CAS_TFN_Telefono_1__c = conT.CTF_FOR_Telefono__c,CAS_TFN_Telefono_2__c=conT.CTF_LKP_Contacto__r.MobilePhone), null, conT.CTF_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c);
		}
		system.debug('************** listaConTelfDuplicados : ' + listaConTelfDuplicados);
		if(!listaConTelfDuplicados.isEmpty()){
			insert listaConTelfDuplicados;
			system.debug('************* DESPUES UPSERT listaConTelfDuplicados :' + listaConTelfDuplicados);
		}
	}

	public static void tratamientoContactoTelefonicoBeforeDelete(List<Contacto_telefonico__c> listaConTelfViejos, Map<Id, Contacto_telefonico__c> mapaConTelVieja){
		if(!Util_variablesGlobales.borradoContactoMixto){
			Set<Id> idsContTelRelacionados = new Set<Id>();
			for(Contacto_telefonico__c ct : listaConTelfViejos){
				if(ct.CTF_LKP_Contacto_Telefonico__c != null && !idsContTelRelacionados.contains(ct.CTF_LKP_Contacto_Telefonico__c)){
					idsContTelRelacionados.add(ct.CTF_LKP_Contacto_Telefonico__c);
				}
			}

			//Se recogen los contactos telefonicos duplicados relacionados
			List<Contacto_telefonico__c> listaContTelRelacionados = new List<Contacto_telefonico__c>(Util_Contacto_Telefonico.getContTelAntyNueAsociados(idsContTelRelacionados,mapaConTelVieja.keySet()).values());
					/*[SELECT Id
					 FROM Contacto_telefonico__c
					 WHERE Id IN: idsContTelRelacionados
					 OR CTF_LKP_Contacto_Telefonico__c IN :mapaConTelVieja.keySet()]);*/

			system.debug('****************  listaConBorrar : ' + listaContTelRelacionados);
			if(!listaContTelRelacionados.isEmpty()){
				Util_variablesGlobales.borradoContactoMixto = true;
				delete listaContTelRelacionados;
			}
		}else{
			Util_variablesGlobales.borradoContactoMixto = false;
		}
	}

	public static void tratamientoContactoTelefonicoAfterUpdate(List<Contacto_telefonico__c> listaContactosNew,Map<Id, Contacto_telefonico__c> mapaContactosNew,
			List<Contacto_telefonico__c> listaContactosOld, Map<Id, Contacto_telefonico__c> mapaContactosOld){
		List<Contacto_telefonico__c> listaContactosTelefonicos = recogeLista(mapaContactosNew);
		system.debug('Contacto telefónico after update');
		for(Contacto_telefonico__c conT : listaContactosTelefonicos){
			system.debug('Dentro del for: ' + conT.CTF_LKP_Contacto__r.Phone + ' ' + mapaContactosOld.get(conT.Id).CTF_LKP_Contacto__r.Phone);
			generaMovimientos(new case(Id=conT.CTF_LKP_Caso__c, RecordTypeId = conT.CTF_LKP_Caso__r.RecordTypeId, CAS_TFN_Telefono_1__c = conT.CTF_LKP_Contacto__r.Phone,CAS_TFN_Telefono_2__c=conT.CTF_LKP_Contacto__r.MobilePhone), 
					new case(CAS_TFN_Telefono_1__c = mapaContactosOld.get(conT.Id).CTF_LKP_Contacto__r.Phone,CAS_TFN_Telefono_2__c=mapaContactosOld.get(conT.Id).CTF_LKP_Contacto__r.MobilePhone),conT.CTF_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c);
		}

	}

	/**
	 * Se introducen movimientos:  
	 * -si se añaden o se modifican los teléfonos de los contactos telefónicos vinculados a la cuenta de un siniestro(Acción 6)
	 */
	private static void generaMovimientos(case caso, case casoOld, String cia){
		if (Util_Siniestro.esSiniestro(caso)
				&& (caso.Status != Label.CAS_ESTADO_EN_CURSO || caso.Status != Label.CAS_ESTADO_CERRADO)){
			if((Trigger.isInsert && (caso.CAS_TFN_Telefono_1__c != null||caso.CAS_TFN_Telefono_2__c!=null) 
					|| (Trigger.isUpdate && (caso.CAS_TFN_Telefono_1__c != casoOld.CAS_TFN_Telefono_1__c||caso.CAS_TFN_Telefono_2__c!=casoOld.CAS_TFN_Telefono_2__c)))){
				Util_Movimientos.compruebaEnviable(caso.Id,cia,'6');
			}
		}
	}
}