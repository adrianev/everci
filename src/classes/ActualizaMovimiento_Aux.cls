/*
 * Clase auxiliar para el webService ActualizaMovimiento para la recepción de ficheros de la CIA NN
 * 24/01/2018
 * @author everis
 *
 */
public without sharing class ActualizaMovimiento_Aux {
	private ActualizaMovimiento_RQ recep{get;set;}
	private List<INT_Movimiento_CIA__c> listMovimientos;
	private List<INT_Perjudicados__c> listPerjudicados;
	private List<INT_Comentarios__c> listComentarios;
	private List<INT_Orden_Trabajo__c> listWO;
	private List<INT_Garantias_Siniestros__c> listGarantiasInsertar;
	private List<INT_Contactos_Telefonicos__c> listContactos;
	private List<List<INT_Garantias_Siniestros__c>> listTotalGarantias;
	private List<INT_Garantias_Siniestros__c> listGarantias;
	private List<String> listaRegistro;
	private List<String> relacionCampos;
	private List<Integer> relacionTroceado;
	private String tipoCampo;
	private String tipoObjeto;
	private Map<String,sObject> mapaObj;
	private Set<String> setWONumHS;//Set con Nº de WO de HS para asociar cuenta y WO en encuestas
	private INT_Bitacora__c bit;
	private String identificadorCIA;
	private Static List<Relacion_Campos__mdt> listaCampos;
	private Static List<Relacion_Campos_Hijo__mdt> listaCamposHijos;
	private Static Map<String,Item> mapaItems;
	private Map<Integer,List<INT_Garantias_Siniestros__c>> mapaGarantias;
	private Map<Integer,List<INT_Perjudicados__c>> mapaPerjudicados;
	private Map<Integer,List<INT_Comentarios__c>> mapaComentarios;
	private Map<Integer,List<INT_Contactos_Telefonicos__c>> mapaContactos;
	private Map<Integer,List<INT_Orden_Trabajo__c>> mapaWO;

	public ActualizaMovimiento_Aux(ActualizaMovimiento_RQ recepcion){
		recep = new ActualizaMovimiento_RQ(recepcion);
		system.debug('recep1: '+recep);
	}

	/**
	* Método para seleccionar el tipo de fichero que recibe y en función de ello llamar al método de tratamiento adecuado
	* 
	*  @param recepcion  -  Lista de registros recibidos
	*
	*/
	public void ubicaFichero(){
		recogeBitacora();
		if(recep.done=='true'){
			bit.BIT_SEL_Estado__c = Label.BIT_ESTADO_RECIBIDO;
		}
		if(recep.done=='error'){
            
			//listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id FROM INT_Movimiento_CIA__c WHERE MOV_LKP_Bitacora__c =: bit.Id]);
            listMovimientos=Util_Movimientos.queryMovimientosByBitacora(new Set<String>{bit.id}).values(); 
			system.debug(listMovimientos + 'ListaaaaaaaaaaaaaaaMovimientos'); 
            system.debug(bit.id);
            
			if(!listMovimientos.isEmpty()){
				delete listMovimientos;
				delete bit;
			}
		}else{
			listaCampos = getListaCampos(recep.tipoFichero);
			listaCamposHijos = getListaCamposHijos(listaCampos.get(0).Id);
			inicializaItems(recep.tipoFichero);
			getRelacionTroceado();
			insertaMovimientos();
		}
	}

	/**
	* Método para guardar los registros recibidos en el objeto Integraciones Movimiento
	* 
	*  @param lista  -  Lista de registros recibidos
	*
	*/
	public void insertaMovimientos(){
		Set<String> setNumHS = new Set<String>();
		Integer contador = 0;
		listMovimientos = new List<INT_Movimiento_CIA__c>();
		mapaGarantias = new Map<Integer,List<INT_Garantias_Siniestros__c>>();
		mapaPerjudicados = new Map<Integer,List<INT_Perjudicados__c>>();
		mapaComentarios = new Map<Integer,List<INT_Comentarios__c>>();
		mapaContactos = new Map<Integer,List<INT_Contactos_Telefonicos__c>>();
		mapaWO = new Map<Integer,List<INT_Orden_Trabajo__c>>();
		setWONumHS = new Set<String>();
		for(ActualizaMovimiento_RQ.Registro linea : recep.listMov){
			system.debug('@@@@@@Inicio 1ª vuelta');
			listGarantias = new List<INT_Garantias_Siniestros__c>();
			listPerjudicados = new List<INT_Perjudicados__c>();
			listComentarios = new List<INT_Comentarios__c>();
			listContactos = new List<INT_Contactos_Telefonicos__c>();
			listWO = new List<INT_Orden_Trabajo__c>();
			
			listaRegistro = trataLinea(linea.registro);//Separo la linea del registro en los campos
			
			mapaObj =inicializaMapa();	
			mapaObj.get('MOV').put('MOV_LKP_Bitacora__c',bit.Id);//Asigno bitácora
			mapaObj.get('MOV').put('MOV_SEL_Estado_Movimiento__c',Label.BIT_ESTADO_RECIBIDO);
			
			//Hago la asignación para movimientos
			asignaCampo(mapaItems.get('MOV').listaMapaValores.get(0));
			System.debug('Después de asignación de campos: '+mapaObj.get('MOV'));
			//Hago la asignación para los objetos hijo
			for(Relacion_Campos_Hijo__mdt campo:listaCamposHijos){
				Integer iteraciones = buscaNumeroIteraciones(campo);
				String obj = campo.Campos_Hijo__c.Left(3);
				//for(Integer a = 0; a<iteraciones;a++){
					if(obj =='IGS'){
						for(Map<Integer,String> mapa : mapaItems.get(obj).listaMapaValores){
							mapaObj.put(obj,new INT_Garantias_Siniestros__c());
							asignaCampo(mapa);
							listGarantias.add((INT_Garantias_Siniestros__c)mapaObj.get(obj));
						}
					}else if(obj == 'IPE'){
						for(Map<Integer,String> mapa : mapaItems.get(obj).listaMapaValores){
							mapaObj.put(obj,new INT_Perjudicados__c());
							asignaCampo(mapa);
							listPerjudicados.add((INT_Perjudicados__c)mapaObj.get(obj));
						}
					}else if(obj == 'ICC'){
						for(Map<Integer,String> mapa : mapaItems.get(obj).listaMapaValores){
							mapaObj.put(obj,new INT_Comentarios__c());
							asignaCampo(mapa);
							listComentarios.add((INT_Comentarios__c)mapaObj.get(obj));
						}
					}else if(obj == 'ICT'){
						for(Map<Integer,String> mapa : mapaItems.get(obj).listaMapaValores){
							mapaObj.put(obj,new INT_Contactos_Telefonicos__c());
							asignaCampo(mapa);
							listContactos.add((INT_Contactos_Telefonicos__c)mapaObj.get(obj));
						}
					}else if(obj == 'IOT'){
						for(Map<Integer,String> mapa : mapaItems.get(obj).listaMapaValores){
							mapaObj.put(obj,new INT_Orden_Trabajo__c());
							asignaCampo(mapa);
							listWO.add((INT_Orden_Trabajo__c)mapaObj.get(obj));
						}
					}
				//}
			}

			if(linea.numSiniestro!= null && String.isNotBlank(linea.numSiniestro.trim())){
				mapaObj.get('MOV').put('MOV_TXT_Num_Caso_CIA__c',linea.numSiniestro.trim());
			} 
			if(linea.error!=null&&String.isNotBlank(linea.error.trim())){
				mapaObj.get('MOV').put('MOV_TXT_Error__c',linea.error);
				mapaObj.get('MOV').put('MOV_SEL_Estado_Movimiento__c',Label.BIT_ESTADO_ERROR);
			}
			System.debug('@@@@@@@ Mov antes del if de Nº HS: '+ mapaObj.get('MOV'));
			if(String.isNotBlank((String) mapaObj.get('MOV').get('MOV_TXT_Num_Caso_HS__c'))){
				System.debug('@@@@@@@ Mov después del if de Nº HS: '+ mapaObj.get('MOV').get('MOV_TXT_Num_Caso_HS__c'));
				setNumHs.add((String) mapaObj.get('MOV').get('MOV_TXT_Num_Caso_HS__c'));
			}
			if(String.isNotBlank((String)mapaObj.get('MOV').get('MOV_TXT_Num_OrdenTrabajo_HS__c'))){
				setWONumHS.add((String)mapaObj.get('MOV').get('MOV_TXT_Num_OrdenTrabajo_HS__c'));
			}

			listMovimientos.add((INT_Movimiento_CIA__c)mapaObj.get('MOV'));
			if(!listGarantias.isEmpty()){
				mapaGarantias.put(contador,listGarantias);
			}
			if(!listPerjudicados.isEmpty()){
				mapaPerjudicados.put(contador,listPerjudicados);
			}
			if(!listContactos.isEmpty()){
				mapaContactos.put(contador,listContactos);
			}
			if(!listComentarios.isEmpty()){
				mapaComentarios.put(contador,listComentarios);
			}
			if(!listWO.isEmpty()){
				mapaWO.put(contador,listWO);
			}
			
			system.debug('@@@@@@Fin vuelta ' + listMovimientos);
			system.debug('@@@@@@Fin vuelta ' + listMovimientos.size());
			contador++;
		}
		if(!setNumHS.isEmpty()){asociaCasos(setNumHS,identificadorCIA);
		}else if(!setWONumHS.isEmpty()){asociaWO(setWONumHS);}
			
		
		//Una vez conseguida la IdCIA relleno el lkp a CIA de bitácora
		bit.BIT_LKP_Compania__c=listMovimientos.get(0).MOV_LKP_Compania__c;
		update bit;
		insert listMovimientos;
		
		//Reinicializo las listas para la inserción
		listGarantias = new List<INT_Garantias_Siniestros__c>();
		listPerjudicados = new List<INT_Perjudicados__c>();
		listComentarios = new List<INT_Comentarios__c>();
		listContactos = new List<INT_Contactos_Telefonicos__c>();
		listWO = new List<INT_Orden_Trabajo__c>();

		//Quito elementos vacíos
		for(Integer i = listMovimientos.size()-1; i >=0;i--){
			Id ident = listMovimientos[i].Id;
			System.debug('@@@@@@@ActualizaMovAux: bucle: mapaGarantias '+mapaGarantias);
			System.debug('@@@@@@@ActualizaMovAux: bucle: listMovimientos[i] '+listMovimientos[i]);
			if(mapaGarantias.containsKey(i)){
				for(INT_Garantias_Siniestros__c a : mapaGarantias.get(i)){
					if(a!=new INT_Garantias_Siniestros__c()){
						a.IGS_LKP_Movimiento_CIA__c = ident;
						listGarantias.add(a);
					}
				}
			}
			
			if(mapaPerjudicados.containsKey(i)){
				for(INT_Perjudicados__c a : mapaPerjudicados.get(i)){
					if(a!=new INT_Perjudicados__c()){
						a.IPE_LKP_Movimiento_CIA__c = ident;
						listPerjudicados.add(a);
					}
				}
			}
			
			if(mapaComentarios.containsKey(i)){
				for(INT_Comentarios__c a : mapaComentarios.get(i)){
					if(a!=new INT_Comentarios__c()){
						a.ICC_LKP_Movimiento_CIA__c = ident;
						listComentarios.add(a);
					}
				}
			}
			
			if(mapaContactos.containsKey(i)){
				for(INT_Contactos_Telefonicos__c a : mapaContactos.get(i)){
					if(a!=new INT_Contactos_Telefonicos__c()){
						a.ICT_LKP_Movimiento_CIA__c = ident;
						listContactos.add(a);
					}
				}
			}
			
			if(mapaWO.containsKey(i)){
				for(INT_Orden_Trabajo__c a : mapaWO.get(i)){
					if(a!=new INT_Orden_Trabajo__c()){
						a.IOT_LKP_Movimiento_CIA__c = ident;
						listWO.add(a);
					}
				}
			}
		}
		//purgaListasVacias();
		insert listPerjudicados;
		insert listComentarios;
		insert listContactos;
		insert listGarantias;
		insert listWO;
	}

	/**
	* Método para introducir los LookUp de Caso y CIA en el registro Movimiento
	* 
	*  @param setNumHS  -  Set de números de Caso HomeServe
	*
	*/
	private void asociaCasos(Set<String> setNumHS,String identCIA){
		system.debug('setNumHS: '+ setNumHS);
		system.debug('identCIA: '+ identCIA);
		List<Case> lista = new List<Case>([SELECT Id, CAS_TXT_Num_Caso_HS__c,CAS_LKP_Compania__c  FROM Case WHERE CAS_TXT_Num_Caso_HS__c IN: setNumHS AND CAS_LKP_Compania__r.CUE_TXT_Identificador__c =: identCIA]);
		//List<Case> lista = Util_Caso.queryCaseByCompaniaYNumeroHs(new Set<String>{identCIA},setNumHS).values();
		Map<String,Case> mapa = new Map<String,Case>();
		for(Case cas : lista){
			if(cas.CAS_TXT_Num_Caso_HS__c!=null){
				mapa.put(cas.CAS_TXT_Num_Caso_HS__c, cas);
				System.debug('@@@@@En asociaCasos: Casp: ' + cas.CAS_TXT_Num_Caso_HS__c);
			}
		}
		
		for (Integer i = 0; i<listMovimientos.size(); i++){
			if (mapa.containsKey(listMovimientos.get(i).MOV_TXT_Num_Caso_HS__c)){
				listMovimientos.get(i).MOV_LKP_Caso__c = mapa.get(listMovimientos.get(i).MOV_TXT_Num_Caso_HS__c).Id;
				listMovimientos.get(i).MOV_LKP_Compania__c = mapa.get(listMovimientos.get(i).MOV_TXT_Num_Caso_HS__c).CAS_LKP_Compania__c;
			}
		}
	}
	
	/**
	* Método para introducir los LookUp de WO y CIA en el registro Movimiento en caso de ser encuesta
	* 
	*  @param setWONumHS  -  Set de números de WO HomeServe
	*
	*/
	private void asociaWO(Set<String> setWONumHS){
		//List<WorkOrder> listWO = new List<WorkOrder>([SELECT Id,AccountId,caseId,OTR_TXT_Num_OrdenTrabajo_HS__c FROM WorkOrder WHERE OTR_TXT_Num_OrdenTrabajo_HS__c IN :setWONumHS]);
		List<WorkOrder> listWO=Util_Orden_Trabajo.queryOrdenTrabajoByNumHs(setWONumHS).values();
		Map<String,WorkOrder> mapa = new Map<String,WorkOrder>();
		for(WorkOrder wo:listWO){//Para el caso de encuestas, recorro los movimientos para añadirles el LKP a WO y Cuenta
			mapa.put(wo.OTR_TXT_Num_OrdenTrabajo_HS__c,wo);
		}
		for (Integer i = 0; i<listMovimientos.size(); i++){
			if (mapa.containsKey(listMovimientos.get(i).MOV_TXT_Num_OrdenTrabajo_HS__c)){
				listMovimientos.get(i).MOV_LKP_Compania__c = mapa.get(listMovimientos.get(i).MOV_TXT_Num_OrdenTrabajo_HS__c).AccountId;
				listMovimientos.get(i).MOV_LKP_Caso__c = mapa.get(listMovimientos.get(i).MOV_TXT_Num_OrdenTrabajo_HS__c).CaseId;
				listMovimientos.get(i).MOV_LKP_Orden_de_Trabajo__c = mapa.get(listMovimientos.get(i).MOV_TXT_Num_OrdenTrabajo_HS__c).Id;
			}
		}
	}

	/**
	* Método para pasar de String a Date
	* 
	*  @param str  -  Palabra a castear
	*
	*/
	private static Date stringToDate(String str){
		Integer anho;
		Integer mes;
		Integer dia;
		List<String> fechaList;
		Date fecha;
		try{
			if(!String.isBlank(str)){
				fechaList = str.split('/');
				if(fechaList.size()==1){
					anho = Integer.valueOf(str.left(4));
					mes = Integer.valueOf(str.substring(4,6));
					dia = Integer.valueOf(str.right(2));
					fecha = Date.newInstance(anho, mes, dia);
				}else if (fechaList.get(2).length()==4){
					anho = Integer.valueOf(fechaList.get(2));
					mes = Integer.valueOf(fechaList.get(1));
					dia = Integer.valueOf(fechaList.get(0));
					fecha = Date.newInstance(anho, mes, dia);
				}
			}
		}catch(Exception e){
			System.debug('******************************Error al procesar la fecha ActualizaMovimientos');
			System.debug(e);
		}
		return fecha;
	}

	/**
	* Método para pasar de String a Decimal
	* 
	*  @param str  -  Palabra a castear
	*
	*/
	private static Decimal stringToDecimal(String str){
		Decimal retorno = 0.00;
		if(!String.isBlank(str)){
			try{
				retorno = decimal.valueOf(str);
				retorno = retorno/100;
			}catch(Exception e){
				System.debug('**************************Error al pasar a decimal ActualizaMovimiento');
				System.debug(e);
			}
		}
		return retorno;
	}

	/**
	* Método para dividir el registro recibido en campos del objeto Integraciones: Movimientos para su posterior guardado
	* 
	*  @param str  -  Palabra a castear
	*
	*/
	public List<String> trataLinea(String linea){
		List<Integer> longitudes;
		List<String> retorno = new List<String>();
		System.debug('relacionTroceado: ' + relacionTroceado);
		System.debug('relacionTroceado.size(): ' + relacionTroceado.size());
		if(!relacionTroceado.isEmpty()){//Si NO es encuesta
			for(Integer i = 1; i<relacionTroceado.size();i++){
				retorno.add((linea.substring(relacionTroceado[i-1],relacionTroceado[i])).trim());
			}
		}else{
			//retorno.addAll(linea.split('&#124;'));//Ver en pruebas de ficheros si se recibe así o '|'
			retorno.addAll(linea.split('\\|'));//Si relación de troceado viene vacía querrá decir que es una encuesta y tiene como separadores '|'
		}
		System.debug('retorno: ' + retorno);
		System.debug('retorno.size(): ' + retorno.size());
		return retorno;
	}

	/**
	* Método para obtener la relación de campos a asignar
	* 
	*  @param str  -  Código del fichero
	*  @return List<String> Campos a asignar
	*/
	private void getRelacionTroceado(){
		//List<Relacion_Campos__mdt> listaCampos = new List<Relacion_Campos__mdt>([SELECT Id,Campos__c, Longitudes__c FROM Relacion_Campos__mdt WHERE Identificador__c = : recep.tipoFichero]);
		//List<Relacion_Campos__mdt> listaCampos=Util_Metadatos.queryRelacionCamposByIdentificador(new Set<String>{recep.tipoFichero}).values(); 
		/*relacionCampos = new List<String>(); 
		system.debug(listaCampos);
		for (String s : listaCampos.get(0).Campos__c.Split(';')){
			system.debug(s);
			relacionCampos.add(s);
		}*/
		//relacionCampos = listaCampos.get(0).Campos__c.Split(';');
		relacionTroceado = new List<Integer>();
		system.debug(listaCampos.get(0).Longitudes__c);
		if(String.isNotBlank(listaCampos.get(0).Longitudes__c)){
			for(String s : listaCampos.get(0).Longitudes__c.Split(';')){
				System.debug('@@@@Troceado: ' + s);
				relacionTroceado.add(Integer.valueOf(s));
			}
		}
	}
	
	/**
	* Método para la asignación en bucle de campos 
	*
	*
	*/
	private void asignaCampo(Map<Integer,String> mapa){
		System.debug('ActualizaMovAux: aisgnaCampo: mapa: ' + mapa);
		for(Integer a : mapa.keySet()){
			if(mapa.get(a).split('_').size()>1){
				tipoCampo = mapa.get(a).split('_').get(1);
				tipoObjeto = mapa.get(a).split('_').get(0);
				System.debug('TipoCampo: ' + tipoCampo);
				System.debug('TipoObjeto: ' + tipoObjeto);
				if(String.isNotBlank(listaRegistro.get(a-1).trim())){
					if(tipoCampo == 'TXT' || tipoCampo == 'SEL' || tipoCampo == 'TFN' || tipoCampo == 'EMA'){
						mapaObj.get(tipoObjeto).put(mapa.get(a),listaRegistro.get(a-1));
					}else if(tipoCampo == 'DAT'){
						mapaObj.get(tipoObjeto).put(mapa.get(a),stringToDate(listaRegistro.get(a-1)));
					} else if(tipoCampo == 'DIV' || tipoCampo == 'NUM' ){
						mapaObj.get(tipoObjeto).put(mapa.get(a),stringToDecimal(listaRegistro.get(a-1)));
					}
				}
			}
		}
	}
	
	/**
	* Se busca si ya se ha recibido parte del fichero(Si ya existe una bitácora en estado 'recibiendo' con ese número de lote)
	*
	*
	*/
	private void recogeBitacora(){
		//List<INT_Bitacora__c> bitList = new List<INT_Bitacora__c>([SELECT Id,RecordTypeId, BIT_SEL_Tipo_Integracion__c FROM INT_Bitacora__c WHERE BIT_SEL_Estado__c =: Label.BIT_ESTADO_RECIBIENDO AND BIT_NUM_Lote__c =: stringToDecimal(recep.lote)*100]);
		List<INT_Bitacora__c> bitList=Util_Bitacora.queryBitacoraByEstadoYLote(new Set<String>{Label.BIT_ESTADO_RECIBIENDO}, new Set<Decimal>{stringToDecimal(recep.lote)*100}).values();
		if(bitList.isEmpty()){
			bit = new INT_Bitacora__c(BIT_SEL_Tipo_Integracion__c = Label.BIT_TIPO_ENVIO_FICHERO, BIT_SEL_Estado__c = Label.BIT_ESTADO_RECIBIENDO, BIT_NUM_Lote__c = (stringToDecimal(recep.lote)*100));
			bit.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO);
			insert bit;
		} else{
			bit = bitList.get(0);
		}
	}
	private Map<String,sObject> inicializaMapa(){
		Map<String,sObject> mapaRef = new Map<String,sObject>();
		mapaRef.put('MOV',new INT_Movimiento_CIA__c());
		mapaRef.put('IPE',new INT_Perjudicados__c());
		mapaRef.put('ICC',new INT_Comentarios__c());
		mapaRef.put('ICT',new INT_Contactos_Telefonicos__c());
		mapaRef.put('IOT',new INT_Orden_Trabajo__c());
		mapaRef.put('IGS',new INT_Garantias_Siniestros__c());
		return mapaRef;
	}

	private Integer buscaNumeroIteraciones(Relacion_Campos_Hijo__mdt campo){
		Integer retorno;
		if(campo.Iteraciones__c.isNumeric()){
			retorno = Integer.valueOf(campo.Iteraciones__c);
		}else{
			retorno = Integer.valueOf(mapaObj.get('MOV').get(campo.Iteraciones__c));
		}
		return retorno;
	}
	
	private without sharing class Item{
		public String tipoObjeto;
		public Integer iteraciones;
		public List<Map<Integer,String>> listaMapaValores;
		//Constructor para elementos hijo
		public Item(String campos,String posiciones,String iteraciones){
			Map<Integer,String> mapaValores;
			this.iteraciones = Integer.valueOf(iteraciones);
			tipoObjeto = campos.left(3);
			listaMapaValores = new List<Map<Integer,String>>();
			List<String> listaCampos = campos.split(';');
			List<String> listaposiciones = posiciones.split(';');
			for(Integer i = 0;i<this.iteraciones;i++){
				mapaValores = new Map<Integer,String>();
				for(Integer j = 0;j<listaCampos.size();j++){
					mapaValores.put(Integer.valueOf(listaposiciones.get(j)) + listaCampos.size()*i,listaCampos.get(j));
				}
				listaMapaValores.add(mapaValores);
			}
		}
	}
	
	private void inicializaItems(String tipoFichero){
		mapaItems = new Map<String,Item>();
		Item aux;
		System.debug('listaCampos.get(0).Campos__c ' + listaCampos.get(0).Campos__c);
		System.debug('listaCampos.get(0).Posiciones__c ' + listaCampos.get(0).Posiciones__c);
		aux = new Item(listaCampos.get(0).Campos__c,listaCampos.get(0).Posiciones__c,'1');
		identificadorCIA = listaCampos.get(0).Identificador_CIA__c;
		mapaItems.put(aux.tipoObjeto,aux);
		for(Relacion_Campos_Hijo__mdt hijo : listaCamposHijos){
			aux = new Item(hijo.Campos_Hijo__c,hijo.Posiciones__c,hijo.Iteraciones__c);
			mapaItems.put(aux.tipoObjeto,aux);
		}
		System.debug('@@@@@@@@ActualizaMovAux: Inicializa Items: mapaItems: '+ mapaItems);
	}
	
	private List<Relacion_Campos__mdt> getListaCampos(String tipoFichero){
		return new List<Relacion_Campos__mdt>([SELECT Id,Campos__c, Longitudes__c, Posiciones__c,Identificador_CIA__c FROM Relacion_Campos__mdt WHERE Identificador__c = : tipoFichero]);
	}
	
	private List<Relacion_Campos_Hijo__mdt> getListaCamposHijos(Id idPadre){
		return new List<Relacion_Campos_Hijo__mdt>([SELECT Campos_Hijo__c, Posiciones__c, Iteraciones__c FROM Relacion_Campos_Hijo__mdt WHERE LKP_Padre__c = : idPadre]);
	}
}