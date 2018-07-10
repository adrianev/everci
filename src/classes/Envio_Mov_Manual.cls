public without sharing class Envio_Mov_Manual {
	ApexPages.StandardSetController setCon{get; set;}
	PageReference pageNext;
	List<INT_Movimiento_CIA__c> movList;
	List<INT_Movimiento_CIA__c> movListToUpdate = new List<INT_Movimiento_CIA__c>();
	Map<Id,List<Id>> mapaIdFicheroListIdBit; //Mapa que contiene lista de bitácoras para cada fichero
	Map<Id,Id> mapaIdOldBitIdNewBit;//Mapa Id bitácora delos movimientos seleccionados, bitácoras creadas
	List<INT_Bitacora__c> listaBitEnviar;//Bitácoras que se enviarán al proceso Batch
	List<String> hijo1 = new List<String>{'INT_Comentarios__c','Integraciones_Comentarios__r','ICC_LKP_Movimiento_CIA__c'};
	List<String> hijo2 = new List<String>{'INT_Garantias_Siniestros__c','Integraciones_Garantias_Siniestros__r','IGS_LKP_Movimiento_CIA__c'};
	List<String> hijo3 = new List<String>{'INT_Orden_Trabajo__c','Integraciones_Ordenes_Trabajo__r','IOT_LKP_Movimiento_CIA__c'};
	List<String> hijo4 = new List<String>{'INT_Contactos_Telefonicos__c','Integraciones_Contactos_Telefonicos__r','ICT_LKP_Movimiento_CIA__c'};
	List<String> hijo5 = new List<String>{'INT_Perjudicados__c','Integraciones_Perjudicados__r','IPE_LKP_Movimiento_CIA__c'};
	//List<String> hijo6 = new List<String>{'INT_Envio_Programado_CIA__c','MOV_LKP_Bitacora__r','BIT_LKP_Envio_Programado_CIA__c'};
	
	List<List<String>> HIJOS = new List<List<String>>{hijo1,hijo2,hijo3,hijo4,hijo5};

	//Map <Id,INT_Envio_Programado__c> mapaMov_Envio_Prog;

	public Boolean hayDatos{get; set;}

	public Envio_Mov_Manual (Apexpages.StandardSetController cont){
		setCon = cont;
		movList = (List<INT_Movimiento_CIA__c>) setCon.getSelected();
		hayDatos = factible();
	}
	/**
	 * Método que se ejecuta al pulsar el botón de la VF
	 */
	public PageReference enviaMovs(){
		if(mapaIdFicheroListIdBit==null){
			getmapaIdFicheroListIdBit();
		}
		movListToUpdate=(List<INT_Movimiento_CIA__c>) selectAll(movList,'INT_Movimiento_CIA__c', HIJOS);
		listaBitEnviar = buscaEnvios();
		clonador();
		Batch_Envio_Mov myBatchObject = new Batch_Envio_Mov(null,listaBitEnviar);
		Id batchId = Database.executeBatch(myBatchObject);
		pageNext = new PageReference('/'+INT_Movimiento_CIA__c.sObjectType.getDescribe().getKeyPrefix());
		return pageNext;
	}
	/**
	 * Comprueba si se puede enviar manualmente. Debe tener bitácora y un estado de 'Enviado'.
	 *
	 * @return Si es enviable
	 */
	private Boolean factible(){
		return((!movList.isEmpty()) && (getMapaIdFicheroListIdBit()));
	}

	/**
	 * Crea una bitácora por cada tipo de fichero que se creará
	 * 
	 * @return	Lista de bitácoras creadas
	 */
	private List<INT_Bitacora__c> buscaEnvios(){
		//LLM
		Callout_Centinela_Generacion callout = new Callout_Centinela_Generacion();
		//FLLM
		mapaIdOldBitIdNewBit = new Map<Id,Id>();//Mapa con bitácora nueva y lista de Ids de las bitácoras de envíos anteriores seleccionados
		List<INT_Bitacora__c> bitList = new List<INT_Bitacora__c>();
		Map<Id,INT_Envio_Programado__c> envProgMap = new Map<Id,INT_Envio_Programado__c>();
		Id rtId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_BIT_FICHERO);
		List<INT_Envio_Programado__c> listaEnviosProgramados = Util_Movimientos.queryEnvioProgramado(mapaIdFicheroListIdBit.keySet()).values();
		for(INT_Envio_Programado__c envProg : listaEnviosProgramados/*[SELECT Id,ENV_LKP_Fichero__c, ENV_SEL_Hora__c,ENV_NUM_Contador_Lote__c, 
		                              ENV_LKP_Fichero__r.FIC_LKP_Compania__r.Id, ENV_LKP_Fichero__r.Name, ENV_LKP_Fichero__r.FIC_TXT_Query__c
		                              FROM INT_Envio_Programado__c WHERE ENV_LKP_Fichero__c IN : mapaIdFicheroListIdBit.keySet()]*/){
			//LLM
			if(callout.updateDatos(envProg.ENV_LKP_Fichero__r.Name)){
			//FLLM
				if(!envProgMap.containsKey(envProg.Id)){//Comprueba si ya se ha creado una bitácora para ese envío programado
					INT_Bitacora__c bitacora = new INT_Bitacora__c();
					bitacora.RecordTypeId = rtId;
					bitacora.BIT_LKP_Compania__c = envProg.ENV_LKP_Fichero__r.FIC_LKP_Compania__r.Id;
					bitacora.BIT_SEL_Estado__c = Label.BIT_ESTADO_NO_ENVIADO;
					bitacora.BIT_NUM_Lote__c = envProg.ENV_NUM_Contador_Lote__c;
					bitacora.BIT_TXT_Nombre_Fichero__c = envProg.ENV_LKP_Fichero__r.Name;
					bitacora.BIT_SEL_Tipo_Integracion__c = label.BIT_TIPO_ENVIO_FICHERO;
					bitacora.BIT_LKP_Envio_Programado_CIA__c = envProg.Id;
					bitacora.BIT_LKP_Compania__c = envProg.ENV_LKP_Fichero__r.FIC_LKP_Compania__c;
					bitacora.BIT_LKP_Envio_Programado_CIA__r = envProg;
					bitacora.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__c = envProg.ENV_LKP_Fichero__c;
					bitList.add(bitacora);
					envProg.ENV_NUM_Contador_Lote__c++;
					envProgMap.put(envProg.Id,envProg);
				}
			//LLM	
			}
			//FLLM
		}
		insert bitList;
		for(INT_Bitacora__c bit : bitList){
			for(Id idBitOld:mapaIdFicheroListIdBit.get(bit.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__c)){
				mapaIdOldBitIdNewBit.put(idBitOld,bit.Id);
			}
		}
		update envProgMap.values();
		return bitList;
	}

	/**
	 * Devuelve true si la lista seleccionada cumple los criterios para reenviarse, es decir, que ya haya sido enviado con anterioridad
	 *
	 */
	private Boolean getMapaIdFicheroListIdBit(){
		Boolean retorno = true;
		mapaIdFicheroListIdBit = new Map<Id,List<Id>>();
		for(INT_Movimiento_CIA__c mov:movList){
			if(mov.MOV_LKP_Bitacora__c == null || mov.MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__c==null|| mov.MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__c==null||(mov.MOV_SEL_Estado_Movimiento__c!=Label.BIT_ESTADO_ENVIADO && mov.MOV_SEL_Estado_Movimiento__c!=Label.BIT_ESTADO_ERROR)){
				retorno=false;
			}else{
				if(!mapaIdFicheroListIdBit.containsKey(mov.MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__c)){
					mapaIdFicheroListIdBit.put(mov.MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__c,new List<Id>{mov.MOV_LKP_Bitacora__c});
				}else{
					mapaIdFicheroListIdBit.get(mov.MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__c).add(mov.MOV_LKP_Bitacora__c);
				}
			}
		}
		return retorno;
	}

	/**
	 * Inserta un clon de la lista de movimientos para enviar así como sus tablas hijas
	 *
	 */
	private void clonador(){
		List<INT_Movimiento_CIA__c> movListCopy = new List<INT_Movimiento_CIA__c>();
		List<INT_Comentarios__c> iccListCopy = new List<INT_Comentarios__c>();
		List<INT_Garantias_Siniestros__c> garanListCopy = new List<INT_Garantias_Siniestros__c>();
		List<INT_Orden_Trabajo__c> woListCopy = new List<INT_Orden_Trabajo__c>();
		List<INT_Contactos_Telefonicos__c> ctListCopy = new List<INT_Contactos_Telefonicos__c>();
		List<INT_Perjudicados__c> perjListCopy = new List<INT_Perjudicados__c>();
		INT_Movimiento_CIA__c movCopy;
		for(INT_Movimiento_CIA__c mov:movListToUpdate){
			movCopy = new INT_Movimiento_CIA__c();
			movCopy = mov.clone(false,true,false,false);
			movCopy.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_NO_ENVIADO;
			movCopy.MOV_LKP_Bitacora__c=mapaIdOldBitIdNewBit.get(movCopy.MOV_LKP_Bitacora__c);
			movCopy.MOV_TXT_Desc_Error__c = null;
			movListCopy.add(movCopy);
		}
		insert movListCopy;
		
		for(INT_Movimiento_CIA__c mov:movListCopy){
			for(INT_Comentarios__c elemento:mov.getSObjects('Integraciones_Comentarios__r')){
				elemento=elemento.clone(false,true,false,false);
				elemento.ICC_LKP_Movimiento_CIA__c=mov.Id;
				iccListCopy.add(elemento);
			}
			for(INT_Garantias_Siniestros__c elemento:mov.getSObjects('Integraciones_Garantias_Siniestros__r')){
				elemento=elemento.clone(false,true,false,false);
				elemento.IGS_LKP_Movimiento_CIA__c=mov.Id;
				elemento.id=null;
				garanListCopy.add(elemento);
			}
			for(INT_Orden_Trabajo__c elemento:mov.getSObjects('Integraciones_Ordenes_Trabajo__r')){
				elemento=elemento.clone(false,true,false,false);
				elemento.IOT_LKP_Movimiento_CIA__c=mov.Id;
				elemento.id=null;    
				woListCopy.add(elemento);
                }
			for(INT_Contactos_Telefonicos__c elemento:mov.getSObjects('Integraciones_Contactos_Telefonicos__r')){
				elemento=elemento.clone(false,true,false,false);
				elemento.ICT_LKP_Movimiento_CIA__c=mov.Id;
				elemento.id=null;
				ctListCopy.add(elemento);
			}
			for(INT_Perjudicados__c elemento:mov.getSObjects('Integraciones_Perjudicados__r')){
				elemento=elemento.clone(false,true,false,false);
				elemento.IPE_LKP_Movimiento_CIA__c=mov.Id;
				elemento.id=null;
				perjListCopy.add(elemento);
			}
		}
		insert iccListCopy;
		insert garanListCopy;
		insert woListCopy;
		insert ctListCopy;
		insert perjListCopy;
		
	}

	/**
	 * Se realiza una query sobre todos los campos de un objeto así como de sus tablas hijas.
	 *
	 * @param    lista   Lista de objetos para hacer la query
	 * @param    tabla   Nombre del sObject
	 * @param    hijos   Lista con los parámetros Nombre de sObject, Nombre para Subqueries y Nombre de LookUp de las tablas hijas
	 *
	 * @return   Lista de objetos resultado de la query
	 */
	private List<sObject> selectAll(List<sObject> lista, String tabla,List<List<String>> hijos){
		String query_string = 'SELECT ';
		List<String> table_list = new List<String>();
		table_list.add(tabla);

		Set<String> table_rows = schema.describeSObjects(table_list)[0].fields.getMap().keyset();
		for(String row : table_rows){
			query_string += row + ',';
		}

		//query_string +='MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__c ,MOV_LKP_Bitacora__r.BIT_LKP_Envio_Programado_CIA__r.ENV_LKP_Fichero__c,';
		for(List<String> hijo:hijos){
			query_string += selectAllChildren(lista,hijo);
		}

		query_string = query_string.removeEnd(','); //remove trailing comma
		query_string += ' FROM ' + tabla + ' WHERE Id IN: lista';
		return Database.query(query_string);
	}
	/**
	 * Se realiza una query sobre todos los campos de un objeto hijo.
	 *
	 * @param    lista   Lista de objetos padre para hacer la query
	 * @param    tabla   Lista con los parámetros Nombre de sObject, Nombre para Subqueries y Nombre de LookUp a la tabla padre.
	 *
	 * @return   query_string    String con la query para el objeto hijo.
	 */
	private String selectAllChildren(List<sObject> lista, List<String> tabla){
		String query_string = '(SELECT ';
		List<String> table_list = new List<String>();
		table_list.add(tabla.get(0));

		Set<String> table_rows = schema.describeSObjects(table_list)[0].fields.getMap().keyset();
		for(String row : table_rows){
			query_string += row + ',';
		}
		query_string = query_string.removeEnd(',');
		query_string += ' FROM ' + tabla.get(1) + ' WHERE ' + tabla.get(2) + ' IN: lista),';
		return query_string;
	}
}