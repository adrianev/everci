/****************************************************************************
-Clase de Extensión del Controlador de Encuesta_Realizadas
--Visualización de una Encuesta Realizada desde el botón "Visualizar", en el Page Layout de dicha Encuesta


 ****************************************************************************/
public without sharing class EncuestaController {
	public Boolean flagRespuesta2{get;set;}//Flag para que si la respuesta 2 es != 7 no visualice la respuesta 3 ante detetminados motivos
	public List<Rest_RecepcionEncuestas_RQ> ListaRE;
	public Boolean mostrar {get;set;}
	//public List<List<SelectOption>> motivosPregunta {get;set;}
	public Map<Integer,List<SelectOption>> motivosPregunta {get;set;}
	public Boolean preg1 {get;set;}
	public Boolean preg1_1 {get;set;}
	public Boolean preg1_2 {get;set;}
	public Boolean preg1_3 {get;set;}
	public Boolean catalan {get;set;}
	public Boolean preguntas {get;set;}
	public List<Boolean> listaGremiosPreg3 {get;set;}
	public Map<String,String> mapaTrad {get;set;}
	public List<ENC_Pregunta__c> listaPreguntasEsp {get;set;}
	public String respuestaTxt {get;set;}
	public String motivoTxt {get;set;}
	public String comentarioTxt {get;set;}
	public String gremioTxt {get;set;}
	public String fechaTxt {get;set;}
	public String valoracionTxt {get;set;}
	public String motivosTxt {get;set;}
	/*public List<aTableRow> tablaPreg2 {get;set;}
	public List<aTableRow2> tablaPreg3 {get;set;}*/
	public String idEncuesta {get;set;}
	public List<ENC_Pregunta__c> listaPreguntas {get;set;}
	public List<ENC_Respuesta__c> listaRespuestas {get;set;}
	public List<ENC_Respuesta__c> listaRespuestasPrincipales {get;set;}
//	public List<List<ENC_Respuesta__c>> listaRespuestasPorPreguntas {get;set;}
	public List<ENC_Encuesta_Tipo__c> listaEncuestaTipo {get;set;}
	public String idEncuestaTipo {get;set;}
	public String idCaso {get;set;}
	public List<Case> listaCasos {get;set;}
	public List<WorkOrder> listaOrdenes {get;set;}
	public List<SelectOption> listaItemsSN{get;set;}
	public List<SelectOption> listaItemsSNNP{get;set;}
	public List<SelectOption> listaItemsSS{get;set;}
	public List<SelectOption> listaItemsGremios{get;set;}
	public List<SelectOption> listaItemsCitaGremios{get;set;}
	public List<SelectOption> listaItemsValoracion{get;set;}
	public List<SelectOption> listaMotivos1 {get;set;}
    public List<SelectOption> listaMotivos2 {get;set;}
    public List<SelectOption> listaMotivos3 {get;set;}
    public List<SelectOption> listaMotivos4 {get;set;}
    public List<SelectOption> listaMotivos5 {get;set;}
    public List<SelectOption> listaMotivos6 {get;set;}
    public List<SelectOption> listaMotivos7 {get;set;}
    public List<SelectOption> listaMotivos8 {get;set;}
    public List<SelectOption> listaMotivos9 {get;set;}
    public List<SelectOption> listaMotivos10 {get;set;}
    public List<SelectOption> listaMotivos11 {get;set;}
    public List<SelectOption> listaMotivos12 {get;set;}
    public List<SelectOption> listaMotivos13 {get;set;}
    public List<SelectOption> listaMotivos14 {get;set;}
    public List<SelectOption> listaMotivos15 {get;set;}
    public List<SelectOption> listaMotivos16 {get;set;}
   // public List<Boolean> listaMostrar {get;set;}
	public RespuestaPregunta respPreg1 {get;set;}
	/*public aTableRow respPreg2 {get;set;}
	public aTableRow2 respPreg3 {get;set;}
	public respuestasPregunta4 respPreg4 {get;set;}
	public respuestasPregunta4AS respPreg4AS {get;set;}
	public respuestasPregunta5 respPreg5 {get;set;}
	public respuestasPregunta5AS respPreg5AS {get;set;}
	public respuestasPregunta6 respPreg6 {get;set;}
	public respuestasPregunta6AS respPreg6AS {get;set;}
	public respuestasPregunta1CA respPreg1CA {get;set;}
	public respuestasPregunta2CA respPreg2CA {get;set;}
	public respuestasPregunta3CA respPreg3CA {get;set;}
	public respuestasPregunta6MA respPreg6MA {get;set;}
	public respuestasPregunta2NN respPreg2NN {get;set;}
	public respuestasPregunta3NN respPreg3NN {get;set;}
	public respuestasPregunta5NN respPreg5NN {get;set;}
	public respuestasPregunta6NIN respPreg6NIN {get;set;}
	public respuestasPregunta6NN respPreg6NN {get;set;}
	public respuestasPregunta7 respPreg7 {get;set;}
	public respuestasPregunta7AS respPreg7AS {get;set;}
	public respuestasPregunta8 respPreg8 {get;set;}
	public respuestasPregunta7MA respPreg7MA {get;set;}*/
	
	public Map<Integer,List<SelectOption>> mapaMotivos {get;set;}
	public List<ENC_Respuesta__c> respuestasP {get;set;}
	public List<ENC_Respuesta__c> respuestasP2 {get;set;}
	public List<ENC_Respuesta__c> respuestasP3 {get;set;}
	public Boolean respRen1 {get;set;}
	public Boolean respRen2 {get;set;}
	public Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> mapaRespuestas {get;set;}
	public ObjetoRespuesta adicional {get;set;}
	public Boolean respRen3 {get;set;}
	public Boolean respRen4 {get;set;}
	public ENC_Encuesta__c encNueva {get;set;}
	
	public Integer i=0;
	public String respuesta{
		get{
			respuesta=listaRespuestas[i].ENR_TXT_Respuesta__c;
			i++;
			return respuesta;
		}
		set;}

/*	public String getRespuestaPrincipal{
		get{
			respuestaPrincipal=listaRespuestasPrincipales[i].ENR_TXT_Respuesta__c;
			i++;
			return respuestaPrincipal;
		}
		set;}*/
	/*public without sharing class ObjetoRespuesta{
		public String respuesta {get;set;}
		public Boolean mostrar {get;set;}
		public ObjetoRespuesta(String respuesta, Boolean mostrar){
			this.respuesta=respuesta;
			this.mostrar=mostrar;
		}
	}*/
	
	public without sharing class ObjetoRespuesta{
		public String motivo {get;set;}
		public String comentario {get;set;}
		public ObjetoRespuesta(String mot, String com){
			motivo=mot;
			comentario=com;
		}
		public ObjetoRespuesta(){
			
		}
	}
	
	public without sharing class RespuestaPregunta{
		public String respPrinc {get;set;}
		public List<ObjetoRespuesta> listaResp {get;set;}
		public WorkOrder ordenes {get;set;}
		public String gremio {get;set;}
		public String respNo {get;set;}
		public List<SelectOption> motivos {get;set;}
		public List<Boolean> renderizar {get;set;}
		public ObjetoRespuesta pregAdic {get;set;}
		public RespuestaPregunta(String princ,List<ObjetoRespuesta> respuestas,WorkOrder w,String grem,String no,List<SelectOption> mot,List<Boolean> rend,ObjetoRespuesta adic){
			respPrinc=princ;
			listaResp = respuestas;
			ordenes = w;
			gremio=grem;
			respNo=no;
			motivos=mot;
			renderizar=rend;
			pregAdic=adic;
		}
	}
	
	/*public without sharing class RespuestaPregunta{
		public WorkOrder ordenes { get; set; }
		public List<Boolean> mostrar { get; set; }
		public List<ObjetoRespuesta> listaObjResp { get; set; }
		public String gremio {get;set;}
		
		public RespuestaPregunta(List<ObjetoRespuesta> listaObjResp, List<Boolean> mostrar, Workorder ordenes, String gremio){
			this.listaObjResp=listaObjResp; 
			this.mostrar=mostrar;
			this.ordenes=ordenes;
			this.gremio=gremio;
		}
	}*/

	public EncuestaController(){
		respuestasP= new List<ENC_Respuesta__c>();
		respuestasP2= new List<ENC_Respuesta__c>();
		respuestasP3= new List<ENC_Respuesta__c>();
		catalan = false;
		mapaMotivos=getMotivos();
		system.debug('Mapa motivos: ' + mapaMotivos);
		system.debug('GET 13' + mapaMotivos.get(13));
		Boolean p2=false;
		Boolean p3=false;
		
		encNueva = new ENC_Encuesta__c();
        system.debug('>>>>>verCurrentPage: ' + System.currentPageReference().getParameters());
        
        encNueva.ENC_LKP_Encuesta_Tipo__c=ApexPages.currentPage().getParameters().get('tipo');
        idEncuestaTipo=encNueva.ENC_LKP_Encuesta_Tipo__c;
        encNueva.ENC_LKP_Caso__c=ApexPages.currentPage().getParameters().get('caso');
        idCaso=encNueva.ENC_LKP_Caso__c;
		System.debug('Id Encuesta recogido desde el boton');
		System.debug(idEncuesta);
		listaCasos=getCasos();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA CASOS CONTROLADOR' +listaCasos);
		idCaso=listaCasos[0].Id;
//		listaEncuestaTipo=getTipoEncuesta();

		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TIPO ENCUESTA CONTROLADOR' +idEncuestaTipo);
		listaPreguntas=getPreguntas();
		mapaRespuestas=getRespuestas();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA PREGUNTAS CONTROLADOR' +listaPreguntas);
		System.debug('>>Mapa respuestas ' +mapaRespuestas);

		for(ENC_Respuesta__c rp : mapaRespuestas.keySet()){
			system.debug(rp.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c);
			system.debug(respuestasP);
			if(rp.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c.contains('P2')){
				
				respuestasP2.add(rp);
				if(!p2)
				respuestasP.add(new ENC_Respuesta__c());
				p2=true;
			}else if(rp.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c.contains('P3')){
				
				respuestasP3.add(rp);
				if(!p3)
				respuestasP.add(new ENC_Respuesta__c());
				p3=true;
			}else{
				respuestasP.add(rp);
			}
		}
        
        
     /*   motivosPregunta = new List<List<SelectOption>>();
        for(Integer i=0;i<listaPreguntas.size();i++){
        	motivosPregunta.add(listaMotivos1);
        }

		listaOrdenes=getOrdenes();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA ORDENES CONTROLADOR' +listaOrdenes);
		listaItemsSN=getItemsSN();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA ITEMSSN CONTROLADOR' +listaItemsSN);
		listaItemsSNNP=getItemsSNNP();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA ITEMSSNNP CONTROLADOR' +listaItemsSNNP);
		listaItemsSS=getItemsSS();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA listaItemsSS CONTROLADOR' +listaItemsSS);
		listaItemsGremios=getItemsCitaGremios();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA listaItemsGremios CONTROLADOR' +listaItemsGremios);
		listaItemsCitaGremios=getItemsCitaGremios();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA listaItemsCitaGremios CONTROLADOR' +listaItemsCitaGremios);
		listaItemsValoracion=getItemsValoracion();
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LISTA listaItemsValoracion CONTROLADOR' +listaItemsValoracion);
		preguntas=true;*/
		if(catalan){
			respuestaTxt='Resposta';
			motivoTxt ='Motiu';
			comentarioTxt ='Comentari';
			gremioTxt ='Gremi';
			fechaTxt ='Data de creació';
			valoracionTxt ='Valoració';
			motivosTxt='Motius'; 
		}else{
			respuestaTxt='Respuesta';
			motivoTxt ='Motivo';
			comentarioTxt ='Comentario';
			gremioTxt ='Gremio';
			fechaTxt ='Fecha de creación';
			valoracionTxt ='Valoración';
			motivosTxt='Motivos'; 
		}
		/*for(Integer i=0;i<5;i++){
			listaMostrar.add(false);
		}*/
		ListaRE = new List<Rest_RecepcionEncuestas_RQ>();
		//respPreg1 = new RespuestaPregunta(new List<ObjetoRespuesta>{new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false)}, null,null,null);
		/*respPreg2 = new aTableRow(listaMostrar,listaOrdenes[0],new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),'',new objetoRespuesta('',false));
		respPreg3 = new aTableRow2(listaMostrar,listaOrdenes[0],new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),'',new objetoRespuesta('',false));
		respPreg4 = new respuestasPregunta4(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg4AS = new respuestasPregunta4AS(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg5 = new respuestasPregunta5(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg5AS = new respuestasPregunta5AS(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg6 = new respuestasPregunta6(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg6AS = new respuestasPregunta6AS(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg1CA = new respuestasPregunta1CA(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg2CA = new respuestasPregunta2CA(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg3CA = new respuestasPregunta3CA(new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg6MA = new respuestasPregunta6MA(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg2NN = new respuestasPregunta2NN(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg3NN = new respuestasPregunta3NN(new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg5NN = new respuestasPregunta5NN(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg6NIN = new respuestasPregunta6NIN(new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg6NN = new respuestasPregunta6NN(new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg7 = new respuestasPregunta7(new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg7AS = new respuestasPregunta7AS(new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg8 = new respuestasPregunta8(new objetoRespuesta('',false),new objetoRespuesta('',false));
		respPreg7MA = new respuestasPregunta7MA(new objetoRespuesta('',false),new objetoRespuesta('',false));
		tablaPreg2 = new List<aTableRow>();
		for(WorkOrder w : listaOrdenes){
			tablaPreg2.add(respPreg2);
		}
		tablaPreg3 = new List<aTableRow2>();
		for(WorkOrder w : listaOrdenes){
			tablaPreg3.add(respPreg3);
		}*/
	}
/*	public void constrObj(){
        
        system.debug('<<<<<<<<<<<< CONSTRUIMOS LA PREGUNTA 1');
        
   //LLM     system.debug(respPreg1.theRespPrinc.TheRespuesta);
        
   //LLM     if(respPreg1.theRespPrinc.TheRespuesta.equals('1')){
            system.debug('>>>>>>>>>>>>>>>>> entro en el si');
            preg1=false;
            preg1_1=false;
            preg1_2=false;
            preg1_3=false;
            preguntas=true;
    //LLM    }else{
    //LLM        if(respPreg1.theRespPrinc.TheRespuesta.equals('0')){
                system.debug('>>>>>>>>>>>>>>>>> entro en el No');
                preg1=true;
                preg1_1=true;
                preg1_2=false;
                preg1_3=false;
                preguntas=false;
                if(listaEncuestaTipo[0].Name.contains('RGA')||listaEncuestaTipo[0].Name.contains('END')){
                	motivosPregunta[0]=listaMotivos13;
                }else{
                	motivosPregunta[0]=listaMotivos1;
                }
      //LLM      }else{
                system.debug('>>>>>>>>>>>>>>>>> entro en el No procede');
                preg1=true;
                preg1_1=false;
                preg1_2=true;
                preg1_3=false;
                preguntas=false;
                if(listaEncuestaTipo[0].Name.contains('END')){
                	motivosPregunta[0]=listaMotivos15;
                }else{
                	motivosPregunta[0]=listaMotivos12;
                }
                
               
          //LLM  }
            
       // }
 //       system.debug(listaRespuestasPrincipales);
    //     system.debug('motivosPregunta1 ' +motivosPregunta[0]);
    }*/
    
    /**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 1
	* 
	* @return RespuestaPregunta
	*/ 
	public RespuestaPregunta getRespuestas1(){
		List<ObjetoRespuesta> listaPreg1;
		List<Boolean> listaRend = new List<Boolean>();
		String respComentario;
		if(respuestasP[0].ENR_TXT_Respuesta__c.equals('0')){
			preguntas=false;
			respRen2=true;
			if(listaEncuestaTipo[0].Name.contains('RGA')||listaEncuestaTipo[0].Name.contains('END')){
				motivosPregunta.put(1,mapaMotivos.get(13));
			}else if(listaEncuestaTipo[0].Name.contains('NN_Indemnizables')){
				motivosPregunta.put(1,mapaMotivos.get(9));
			}else if(listaEncuestaTipo[0].Name.contains('NN_Cob')){
				motivosPregunta.put(1,mapaMotivos.get(7));
			}else{
				motivosPregunta.put(1,mapaMotivos.get(1));
			}
			listaPreg1=creacionRespuestas(motivosPregunta.get(1),mapaRespuestas.get(respuestasP[0]),1);
		}else if(respuestasP[0].ENR_TXT_Respuesta__c.equals('-1')){
				preguntas=false;
				respRen2=true;
				if(listaEncuestaTipo[0].Name.contains('END')){
				   motivosPregunta.put(1,mapaMotivos.get(15));
				}else{
					motivosPregunta.put(1,mapaMotivos.get(12));
				}
				listaPreg1=creacionRespuestas(motivosPregunta.get(1),mapaRespuestas.get(respuestasP[0]),1);
		}else if(respuestasP[0].ENR_TXT_Respuesta__c.equals('1')){
				preguntas=true;
				respRen2=false;
		}
		listaRend.add(respRen1);
		listaRend.add(respRen2);
		Map<String,String> codigoMotivos = new Map<String,String>();
			if(motivosPregunta.get(1) != null){
				for(SelectOption s :motivosPregunta.get(1)){
					codigoMotivos.put(s.getLabel(),s.getValue());
				}
//				listaPreg1[0].motivo=codigoMotivos.get(listaPreg1[0].motivo);
			}
		respPreg1= new RespuestaPregunta(respuestasP[0].ENR_TXT_Respuesta__c,listaPreg1,null,null,respComentario,motivosPregunta.get(1),listaRend,null);
		return respPreg1;
		
	}
    
/*    public void recogerRespuestaPrimeraPregunta(List<respuestasPregunta1> listaRespuesta){
    	
		for(respuestasPregunta1 respuesta:listaRespuesta){
			
			Rest_RecepcionEncuestas_RQ obj1 = new Rest_RecepcionEncuestas_RQ();
			Rest_RecepcionEncuestas_RQ obj2 = new Rest_RecepcionEncuestas_RQ();
			Rest_RecepcionEncuestas_RQ obj3 = new Rest_RecepcionEncuestas_RQ();
			
			if(respuesta.theRespPrinc != null){
				if(respuesta.theRespPrinc.theRespuesta == '0'){
					obj1.numOrdenTrabajo = '';
					obj1.pregunta = 'P1_5610_AS';
					obj1.respuesta = respuesta.theRespPrinc.theRespuesta;
					listaRE.add(obj1);
					
					if(respuesta.theRespMot.theRespuesta != null && respuesta.theRespMot.theRespuesta != ''){
						obj2.numOrdenTrabajo = '';
						obj2.pregunta = 'P1_1_5610_AS';
						obj2.respuesta = respuesta.theRespMot.theRespuesta;
						listaRE.add(obj2);
					
						if(respuesta.theRespCom.theRespuesta != null && respuesta.theRespCom.theRespuesta != ''){
							obj3.numOrdenTrabajo = '';
							obj3.pregunta = 'P1_2_5610_AS';
							obj3.respuesta = respuesta.theRespMot.theRespuesta;
							listaRE.add(obj3);
						}
					}	
				}
			}else if (respuesta.theRespPrinc.theRespuesta == '-1'){
				obj1.numOrdenTrabajo = '';
				obj1.pregunta = 'P1_5610_AS';
				obj1.respuesta = respuesta.theRespMot.theRespuesta;
				listaRE.add(obj1);
				
				if(respuesta.theNoProc.theRespuesta != null && respuesta.theNoProc.theRespuesta != ''){
					obj2.numOrdenTrabajo = '';
					obj2.pregunta = 'P1_3_5610_AS';
					obj2.respuesta = respuesta.theRespMot.theRespuesta;
					listaRE.add(obj2);
					
					if(respuesta.theProCom.theRespuesta != null && respuesta.theProCom.theRespuesta != ''){
						obj3.numOrdenTrabajo = '';
						obj3.pregunta = 'P1_4_5610_AS';
						obj3.respuesta = respuesta.theRespMot.theRespuesta;
						listaRE.add(obj3);
					}
				}
			}
		}
    }*/
    
    /**
	* Busca y devuelve un Mapa con el número perteneciente a un grupo de motivos y la lista de dicho grupo de motivos.
	* 
	* Se hace una busqueda en los metadatos para sacar todos los motivos, dependiendo solo del idioma de la encuesta.
	*
	* @return Map<Integer,List<SelectOption>>
	*/ 
	public Map<Integer,List<SelectOption>> getMotivos(){
		List<Motivos_Encuesta__mdt> motivo;
		String aux='\'%CAT%\'';
		if(catalan){
			//motivo = [SELECT Id,Label,Codigo_Motivo__c,Texto_Motivo__c FROM Motivos_Encuesta__mdt WHERE Label LIKE :aux ORDER BY Label];
			motivo = Database.query('SELECT Id,Label,Codigo_Motivo__c,Texto_Motivo__c FROM Motivos_Encuesta__mdt WHERE Label LIKE \'%CAT%\' ORDER BY Label');
		}else{
			motivo = [SELECT Id,Label,Codigo_Motivo__c,Texto_Motivo__c FROM Motivos_Encuesta__mdt WHERE NOT Label LIKE :aux ORDER BY Label];
			
		}
		Map<Integer,List<SelectOption>> mapaMot = new  Map<Integer,List<SelectOption>>();
		for(Motivos_Encuesta__mdt m : motivo){
			if(mapaMot.containsKey(Integer.valueOf(m.Codigo_Motivo__c.substring(1,3)))){
				mapaMot.get(Integer.valueOf(m.Codigo_Motivo__c.substring(1,3))).add(new SelectOption(m.Codigo_Motivo__c,m.Texto_Motivo__c));
			}else{
				mapaMot.put(Integer.valueOf(m.Codigo_Motivo__c.substring(1,3)),new List<SelectOption>());
				mapaMot.get(Integer.valueOf(m.Codigo_Motivo__c.substring(1,3))).add(new SelectOption(m.Codigo_Motivo__c,m.Texto_Motivo__c));
			}
		}
	return mapaMot;
	}
	
	/**
	* Busca y devuelve una lista de objetos Pregunta.
	* Se generan además 2 listas más: lista de Preguntas Principales y otra con unas Preguntas en concreto
	* 
	* @return List<ENC_Pregunta__c>
	*/ 
	public List<ENC_Pregunta__c> getPreguntas(){
		system.debug('idEncuestaTipo: '+ idEncuestaTipo);
		List<ENC_Pregunta__c> pregunta = Database.query(
				'SELECT Id,Name,ENP_LKP_Encuesta_Tipo__c, ENP_SEL_Tipo_Respuesta__c, ENP_TXT_Identificador__c, ENP_TXT_Pregunta__c,ENP_LKP_Pregunta__c  FROM ENC_Pregunta__c WHERE ENP_LKP_Encuesta_Tipo__c = :idEncuestaTipo ORDER BY Name'
				);
		List<ENC_Pregunta__c> preguntasPrincipales = new List<ENC_Pregunta__c>();
		for(ENC_Pregunta__c p : pregunta){
			if(p.ENP_LKP_Pregunta__c == null){
				preguntasPrincipales.add(p);
			}
		}
		List<ENC_Pregunta__c> preguntaCorregida = editarPregunta(preguntasPrincipales);
		listaPreguntasEsp = new List<ENC_Pregunta__c>();
		for(ENC_Pregunta__c p : pregunta){
			if(p.ENP_TXT_Identificador__c.contains('P2_4')||p.ENP_TXT_Identificador__c.contains('P3_4')){
				listaPreguntasEsp.add(p);
			}
		}
		return preguntaCorregida;
	}
	
	/**
	* Crea y devuelve una lista de objetos Pregunta.
	* Recorre la lista de preguntas en busca de unas variables para cambiarlo por otros valores
	* 
	* @return List<ENC_Pregunta__c>
	*/ 
	public List<ENC_Pregunta__c> editarPregunta(List<ENC_Pregunta__c> listaPreguntasEdita){
		String causa = listaCasos[0].CAS_SEL_Causa_Averia__c;
		String fecha = String.valueOf(listaCasos[0].CreatedDate);
		String compania = listaCasos[0].CAS_TXT_WF_Compania__c;
		for(ENC_Pregunta__c preg : listaPreguntasEdita){
			String aux = preg.ENP_TXT_Pregunta__c;
			String causaFinal=causa;
			if (aux != null){
				if(causa!= null&&!listaEncuestaTipo[0].Name.contains('END')){
					if(catalan){
						mapaTrad = Util_Metadatos.getMapaTraduccion(new Set<String>{'Case'});
						causaFinal=mapaTrad.get('1'+'0000'+'CAS_SEL_Causa_Averia__c'+causa);	
					}
					aux = aux.replace('#CAUSA#', causaFinal);
				} 
				aux = aux.replace('#FECHA#', fecha);
				aux = aux.replace('#COMPANIA#', 'ENDESA');
				preg.ENP_TXT_Pregunta__c=aux;
			}
		}
		return listaPreguntasEdita;
	}
	
	/**
 	  * Crea y devuelve una lista de ObjetoRespuesta formados de los motivos y las respuestas.
	  * 
 	  * @param motPregunta: Lista de motivos pertenecientes a la pregunta en concreto.
	  * @param respuestasH: Lista de respuestas a la pregunta en concreto.
	  * @param pregunta: Numero de la pregunta en concreto.
 	  * 
	  * @return lista de ObjetoRespuestas
 	  */ 
	public List<ObjetoRespuesta> creacionRespuestas(List<SelectOption> motPregunta,List<ENC_Respuesta__c> respuestasH,Integer pregunta){
		List<ObjetoRespuesta> listaPreg = new List<ObjetoRespuesta>();
		List<String> motivosNegPreg3 = new List<String>{'M02_ESP_01','M02_ESP_02','M02_CAT_01','M02_CAT_02'};
		List<String> motivosPosPreg3 = new List<String>{'M03_ESP_01','M03_CAT_01'};
		List<String> motivosPreg21 = new List<String>{'M02_ESP_06','M02_ESP_07','M02_CAT_06','M02_CAT_07'};
		Map<String,String> codigoMotivos = new Map<String,String>();
		if(motPregunta != null){
			for(SelectOption s :motPregunta){
				codigoMotivos.put(s.getValue(),s.getLabel());
			}
		}
		List<String> listaMotivos = new List<String>(codigoMotivos.keySet());
		
		for(Integer i=0;i<respuestasH.size();i++){
			system.debug(respuestasH[i]);
			if(listaMotivos.contains(respuestasH[i].ENR_TXT_Respuesta__c) && listaMotivos!=null){
				ObjetoRespuesta aux = new ObjetoRespuesta();
				aux.motivo=codigoMotivos.get(respuestasH[i].ENR_TXT_Respuesta__c);
				listaPreg.add(aux);
				if(motivosNegPreg3.contains(respuestasH[i].ENR_TXT_Respuesta__c)){
					flagRespuesta2=false;
				}
				if(motivosPosPreg3.contains(respuestasH[i].ENR_TXT_Respuesta__c)){
					flagRespuesta2=false;
				}
				if(motivosPreg21.contains(respuestasH[i].ENR_TXT_Respuesta__c)){
					respRen3=true;
				}
			}else{
				ObjetoRespuesta aux1 = new ObjetoRespuesta();
				if(respuestasH[i].ENR_LKP_Resp_Pregunta__r.Name.contains('P2_4_')){
					adicional= new ObjetoRespuesta('','');
					adicional.motivo=respuestasH[i].ENR_TXT_Respuesta__c;
				}else if(respuestasH[i].ENR_LKP_Resp_Pregunta__r.Name.contains('P2_8_')){
					adicional.comentario=respuestasH[i].ENR_TXT_Respuesta__c;
					respRen4=true;
				}else if(respuestasH[i].ENR_LKP_Resp_Pregunta__r.Name.contains('P2_5_')){
					aux1.comentario=respuestasH[i].ENR_TXT_Respuesta__c;
					listaPreg.add(aux1);
				}else if(respuestasH[i].ENR_LKP_Resp_Pregunta__r.Name.contains('P3_4_')){
					adicional= new ObjetoRespuesta('','');
					adicional.comentario=respuestasH[i].ENR_TXT_Respuesta__c;
				}else if(listaPreg.size()<1){
					aux1.comentario=respuestasH[i].ENR_TXT_Respuesta__c;
					listaPreg.add(aux1);
				}else{
					listaPreg[listaPreg.size()-1].comentario=respuestasH[i].ENR_TXT_Respuesta__c;
				}
			}
			system.debug(listaPreg);
		}
		system.debug(listaPreg);
		return listaPreg;
	}
	
	
	/**
	* Busca y devuelve un Mapa de objeto Respuesta Padre y lista de objetos Respuesta Hijas.
	* 
	* 
	* @return Map<ENC_Respuesta__c,List<ENC_Respuesta__c>>
	*/ 
/*	public Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> getRespuestas(){
		List<ENC_Respuesta__c> respuesta = Database.query(
				'SELECT Id,ENR_LKP_Encuesta_Realizada__c,Name, ENR_LKP_Resp_Pregunta__r.ENP_TXT_Pregunta__c,ENR_TXT_Respuesta__c,ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c,ENR_LKP_Resp_Pregunta__c,ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c,ENR_LKP_Resp_Pregunta__r.Name,ENR_LKP_WorkOrder__c  FROM ENC_Respuesta__c WHERE ENR_LKP_Encuesta_Realizada__r.ENC_LKP_Encuesta_Tipo__c = :idEncuestaTipo ORDER BY Name '
				);
		Map<String,ENC_Respuesta__c> mapaFin = new Map<String,ENC_Respuesta__c>();
		for(ENC_Respuesta__c resp : respuesta){
			String var =String.valueOf(resp.ENR_LKP_Resp_Pregunta__c);
			mapaFin.put(var,resp);
			system.debug(resp.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c);
			system.debug(resp.ENR_LKP_Resp_Pregunta__c);
			system.debug(resp.ENR_LKP_WorkOrder__c);
		}
		system.debug(mapaFin);
		Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> mapaPeH = new Map<ENC_Respuesta__c,List<ENC_Respuesta__c>>();
		for(ENC_Respuesta__c r : respuesta){
			if(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c == null){
				system.debug('soy una respuesta Padre' + r);
				mapaPeH.put(r,new List<ENC_Respuesta__c>());
				system.debug(mapaPeH.keySet());
				system.debug('mapaPeH 1: ' + mapaPeH);
				system.debug('OJOO: ' + mapaPeH.get(r));
			}else{
				system.debug(r.ENR_TXT_Respuesta__c);
				system.debug('soy una respuesta Hija ' + r);
				//system.debug(String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c)+ ' r.ENR_LKP_WorkOrder__c: ' + String.valueOf(r.ENR_LKP_WorkOrder__c));
				//system.debug(mapaPeH.get(mapaFin.get(String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c)+String.valueOf(r.ENR_LKP_WorkOrder__c))));
				system.debug('MapaFin: '+ mapaFin);
				system.debug('va a coger el elemento: '+String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c));
				ENC_Respuesta__c respu = mapaFin.get(String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c));
				system.debug('MAPA FIN.get: '+ respu);
				system.debug('mapaPeH 2: ' + mapaPeH);
				system.debug('OJOOOo 2: ' + mapaPeH.get(respu));
				mapaPeH.get(respu).add(r);
			}
		}
		return mapaPeH;
	}*/
	
	public Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> getRespuestas(){
		List<ENC_Respuesta__c> respuesta = Database.query(
				'SELECT Id,ENR_LKP_Encuesta_Realizada__c,Name, ENR_LKP_Resp_Pregunta__r.ENP_TXT_Pregunta__c,ENR_TXT_Respuesta__c,ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c,ENR_LKP_Resp_Pregunta__c,ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c,ENR_LKP_Resp_Pregunta__r.Name,ENR_LKP_WorkOrder__c  FROM ENC_Respuesta__c WHERE ENR_LKP_Encuesta_Realizada__c = :idEncuesta ORDER BY Name '
				);
		Map<String,ENC_Respuesta__c> mapaFin = new Map<String,ENC_Respuesta__c>();
		for(ENC_Respuesta__c resp : respuesta){
			String var =String.valueOf(resp.ENR_LKP_Resp_Pregunta__c)+String.valueOf(resp.ENR_LKP_WorkOrder__c);
			mapaFin.put(var,resp);
			system.debug(resp.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c);
			system.debug(resp.ENR_LKP_Resp_Pregunta__c);
			system.debug(resp.ENR_LKP_WorkOrder__c);
		}
		system.debug(mapaFin);
		Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> mapaPeH = new Map<ENC_Respuesta__c,List<ENC_Respuesta__c>>();
		for(ENC_Respuesta__c r : respuesta){
			if(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c == null){
				system.debug('soy una respuesta Padre');
				mapaPeH.put(r,new List<ENC_Respuesta__c>());
				system.debug(mapaPeH.keySet());
				system.debug(mapaPeH.get(r));
			}else{
				system.debug(r.ENR_TXT_Respuesta__c);
				system.debug('soy una respuesta Hija');
				system.debug(String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c)+String.valueOf(r.ENR_LKP_WorkOrder__c));
				system.debug(mapaPeH.get(mapaFin.get(String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c)+String.valueOf(r.ENR_LKP_WorkOrder__c))));
				mapaPeH.get(mapaFin.get(String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c)+String.valueOf(r.ENR_LKP_WorkOrder__c))).add(r);
				
			}
		}
		return mapaPeH;
	}
	
	/**
	* Busca y devuelve una lista de objetos Caso.
	* 
	* @return List<Case>
	*/ 
	public List<Case> getCasos() {
		List<Case> lista = Util_Caso.getCaseById(new Set<Id>{idCaso}).values();
		//List<Case> lista = Util_Caso.getMapaCasos(new Set<Id>{idCaso}).values();
        /*List<Case> lista = Database.query(
            'SELECT Id, CreatedDate, CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,CAS_SEL_Grupo_Causa__c,CAS_SEL_Causa_Averia__c,CAS_TXT_WF_Compania__c ' +
            'FROM Case WHERE Id= :idCaso' 
        );*/
        return lista;
    } 
}