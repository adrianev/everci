/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:             everis
Company:        everis España
Description:    -Clase de Extensión del Controlador de Encuesta_Realizadas. Visualización de una Encuesta Realizada desde el botón "Visualizar", en el Page Layout de dicha Encuesta
				
History:  Optimización de clase.
 
<Date> 18/04/2018            everis                   nombrado Mayusc/Minusc, elimincación de debugs, eliminación de código comentado, elses vacíos
<Date> 03/05/2018            everis                   constructores refactorizados, métodos comentados, refactorización de las selects, nombres de variables en español
													  optimizacion métodos para generar las Respuestas
<Date> 04/05/2018            everis                   correción de las últimas funcionalidades para Endesa
<Date> 14/05/2018            everis                   correción de las últimas funcionalidades para todas las Compañías
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public without sharing class EncuestaRealizadaController {

	public Boolean flagRespuesta2{get;set;}//Flag para que si la respuesta 2 es != 7 no visualice la respuesta 3 ante detetminados motivos
	public Boolean mostrar {get;set;}
	public Map<Integer,List<SelectOption>> motivosPregunta {get;set;}
	public Boolean respRen1 {get;set;}
	public Boolean respRen2 {get;set;}
	public Boolean respRen3 {get;set;}
	public Boolean respRen4 {get;set;}
	public Boolean respRen0 {get;set;}
	public Boolean hayP3 {get;set;}
	public Boolean catalan {get;set;}
	public Boolean preguntas {get;set;}
	public Map<String,String> mapaTrad {get;set;}
	public List<ENC_Pregunta__c> listaPreguntasEsp {get;set;}
	public String respuestaTxt {get;set;}
	public String motivoTxt {get;set;}
	public String comentarioTxt {get;set;}
	public String gremioTxt {get;set;}
	public String fechaTxt {get;set;}
	public String valoracionTxt {get;set;}
	public String motivosTxt {get;set;}
	public String idReclamacionTxt{get;set;}
	public  List<List<SelectOption>> listaMotivos {get;set;}
	public String idEncuesta {get;set;}
	public List<ENC_Pregunta__c> listaPreguntas {get;set;}
	public Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> mapaRespuestas {get;set;}
	public List<ENC_Respuesta__c> respuestasP {get;set;}
	public List<ENC_Respuesta__c> respuestasP2 {get;set;}
	public List<ENC_Respuesta__c> respuestasP3 {get;set;}
	public List<ENC_Encuesta_Tipo__c> listaEncuestaTipo {get;set;}
	public String idEncuestaTipo {get;set;}
	public String idCaso {get;set;}
	public List<Case> listaCasos {get;set;}
	public List<WorkOrder> listaOrdenes {get;set;}
	public List<SelectOption> listaMotsSN1{get;set;}
	public List<SelectOption> listaMotsSN{get;set;}
	public List<SelectOption> listaMotsValoracion{get;set;}
	public RespuestaPregunta respPreg1 {get;set;}
	public RespuestaPregunta respPreg2 {get;set;}
	public RespuestaPregunta respPreg3 {get;set;}
	public RespuestaPregunta respPreg4 {get;set;}
	public RespuestaPregunta respPreg5 {get;set;}
	public RespuestaPregunta respPreg6 {get;set;}
	public RespuestaPregunta respPreg7 {get;set;}
	public RespuestaPregunta respPreg8 {get;set;}
	public RespuestaPregunta respPreg9 {get;set;}
	public Map<Integer,List<SelectOption>> mapaMotivos;
	public Map<String,Boolean> flagWork {get;set;}
	public Map<String,Boolean> flagPreg {get;set;}
	public Integer contPreg {get;set;}
	public ObjetoRespuesta adicional {get;set;}
	//Clase para formar cada respuesta 
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
	//Clase para formar el objeto con el que formaremos cada pregunta
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
	
	public EncuestaRealizadaController(){
		idEncuesta = System.currentPageReference().getParameters().get('aId');
		listaCasos=getCasos();
		idCaso=listaCasos[0].Id;
		listaEncuestaTipo=getTipoEncuesta();
		hayP3=false;
		listaPreguntas=getPreguntas();
		mapaRespuestas=getRespuestas();
		respuestasP2= new List<ENC_Respuesta__c>();
		respuestasP3= new List<ENC_Respuesta__c>();
		respuestasP= new List<ENC_Respuesta__c>();
		Boolean p2=false;
		Boolean p3=false;
		//Genero la lista de respuestas para la Pregunta 2 y 3 según la pregunta esta referida a un/os gremio/s o no
		for(ENC_Respuesta__c rp : mapaRespuestas.keySet()){
			if(rp.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c.contains('P2')&&!listaEncuestaTipo[0].Name.contains('NN_Indemnizables')&&!listaEncuestaTipo[0].Name.contains('NN_Cob Adicionales')&&!listaEncuestaTipo[0].Name.contains('SC_Mantenimiento')){
				respuestasP2.add(rp);
				if(!p2)
				respuestasP.add(new ENC_Respuesta__c());
				p2=true;
			}else if(rp.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c.contains('P3')&&!listaEncuestaTipo[0].Name.contains('NN_Indemnizables')&&!listaEncuestaTipo[0].Name.contains('NN_Cob Adicionales')&&!listaEncuestaTipo[0].Name.contains('SC_Mantenimiento')){
				respuestasP3.add(rp);
				if(!p3)
				respuestasP.add(new ENC_Respuesta__c());
				p3=true;
			}else{
				respuestasP.add(rp);
			}
		}
		//método que añade a la lista de Respuestas Principales una respuesta vacía
		//para el caso en el que no nos viene una respuesta para la pregunta 3
		//para el caso en el que no nos viene ni la pregunta 2 ni la 3 añade 2 objetos respuesta vacios
		Integer difPreg =listaPreguntas.size()-respuestasP.size();
		if(difPreg==1&&respuestasP[0].ENR_TXT_Respuesta__c=='1'){
			respuestasP.add(2,new ENC_Respuesta__c());
			respRen0=true;
		}else if(difPreg==2){
			respuestasP.add(1,new ENC_Respuesta__c());
			respuestasP.add(1,new ENC_Respuesta__c());
			respRen0=false;
			flagRespuesta2=false;
		}else{
			respRen0=true;
			flagRespuesta2=true;
		}
		
		mapaMotivos=getMotivos();
		motivosPregunta = new Map<Integer,List<SelectOption>>();
		respRen1=false;
		respRen2=false;
		respRen3=false;
		respRen4=false;
		flagWork = new Map<String,Boolean>();
		flagPreg = new Map<String,Boolean>();
		contPreg=0;
		listaOrdenes=getOrdenes();
		listaMotsSN1=getMotSN(1);
		listaMotsSN=getMotSN(2);
		listaMotsValoracion=getMotValoracion();
		preguntas=true;
		//Estoy hay que llamarlo desde Salesforce (Traducción), a la espera de completar el Metadato de Traducciones
		if(catalan){
			respuestaTxt='Resposta';
			motivoTxt ='Motiu';
			comentarioTxt ='Comentari';
			gremioTxt ='Gremi';
			fechaTxt ='Data de creació';
			valoracionTxt ='Valoració';
			motivosTxt='Motius';
			idReclamacionTxt = 'Id de reclamació';
		}else{
			respuestaTxt='Respuesta';
			motivoTxt ='Motivo';
			comentarioTxt ='Comentario';
			gremioTxt ='Gremio';
			fechaTxt ='Fecha de creación';
			valoracionTxt ='Valoración';
			motivosTxt='Motivos';
			idReclamacionTxt = 'Id de reclamación';
		}
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
		respRen4=false;
		for(Integer i=0;i<respuestasH.size();i++){
			if(listaMotivos.contains(respuestasH[i].ENR_TXT_Respuesta__c) && listaMotivos!=null){
				ObjetoRespuesta aux = new ObjetoRespuesta();
				aux.motivo=codigoMotivos.get(respuestasH[i].ENR_TXT_Respuesta__c);
				listaPreg.add(aux);
				if(motivosNegPreg3.contains(respuestasH[i].ENR_TXT_Respuesta__c)){
					flagWork.put(respuestasH[i].ENR_LKP_WorkOrder__c,false);
				}
				if(motivosPosPreg3.contains(respuestasH[i].ENR_TXT_Respuesta__c)){
					flagWork.put(respuestasH[i].ENR_LKP_WorkOrder__c,false);
				}
				if(motivosPreg21.contains(respuestasH[i].ENR_TXT_Respuesta__c)){
					flagPreg.put(respuestasH[i].ENR_LKP_WorkOrder__c,true);
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
		}
		if(flagWork.size()==listaOrdenes.size()){
			flagRespuesta2=false;
		}
		return listaPreg;
	}
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
				} else if(listaEncuestaTipo[0].Name.contains('NN_Cob')){
					respComentario=mapaRespuestas.get(respuestasP[0])[0].ENR_TXT_Respuesta__c;
					respRen1=true;
					respRen2=false;
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
				listaPreg1[0].motivo=codigoMotivos.get(listaPreg1[0].motivo);
			}
		respPreg1= new RespuestaPregunta(respuestasP[0].ENR_TXT_Respuesta__c,listaPreg1,null,null,respComentario,motivosPregunta.get(1),listaRend,null);
		return respPreg1;
		
	}
	/**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 2
	* 
	* @return RespuestaPregunta
	*/ 
	public List<RespuestaPregunta> getRespuestas2(){
		String gremio;
		List<ObjetoRespuesta> listaPreg2=new List<ObjetoRespuesta>();
		
		String respComentario;
		List<RespuestaPregunta> respPreg2 = new List<RespuestaPregunta>();
		if(listaEncuestaTipo[0].Name.contains('NN_Indemnizables')){
			List<Boolean> listaRend = new List<Boolean>();
			if(respuestasP[1].ENR_TXT_Respuesta__c=='0'){
					motivosPregunta.put(2, mapaMotivos.get(6));
					respRen1=true;
					respRen2=false;
					
			}else if(respuestasP[1].ENR_TXT_Respuesta__c=='-1'){
				respComentario = mapaRespuestas.get(respuestasP[1])[0].ENR_TXT_Respuesta__c;
				respRen1=false;
				respRen2=true;
			}else if(respuestasP[1].ENR_TXT_Respuesta__c=='1'){
				respRen1=false;
				respRen2=false;
			}
			listaPreg2=creacionRespuestas(motivosPregunta.get(2),mapaRespuestas.get(respuestasP[1]),2);
			listaRend.add(respRen1);
			listaRend.add(respRen2);
			Map<String,String> codigoMotivos = new Map<String,String>();
			if(motivosPregunta.get(2) != null){
				for(SelectOption s :motivosPregunta.get(2)){
					codigoMotivos.put(s.getLabel(),s.getValue());
				}
				listaPreg2[0].motivo=codigoMotivos.get(listaPreg2[0].motivo);
			}
			respPreg2.add(new RespuestaPregunta(respuestasP[1].ENR_TXT_Respuesta__c,listaPreg2,null,gremio,respComentario,motivosPregunta.get(2),listaRend,adicional));
		}else if(listaEncuestaTipo[0].Name.contains('NN_Cob Adicionales')){
			List<Boolean> listaRend = new List<Boolean>();
			if(Integer.valueOf(respuestasP[1].ENR_TXT_Respuesta__c)<7){
				motivosPregunta.put(2, mapaMotivos.get(11));
				respRen1=true;
				respRen2=false;
			}else{
				respRen1=false;
				respRen2=false;
			}
			listaPreg2=creacionRespuestas(motivosPregunta.get(2),mapaRespuestas.get(respuestasP[1]),2);
			listaRend.add(respRen1);
			listaRend.add(respRen2);
			respPreg2.add(new RespuestaPregunta(respuestasP[1].ENR_TXT_Respuesta__c,listaPreg2,null,null,respComentario,motivosPregunta.get(2),listaRend,adicional));
		}else if(listaEncuestaTipo[0].Name.contains('SC_Mantenimiento')){
			respPreg2.add(new RespuestaPregunta(respuestasP[1].ENR_TXT_Respuesta__c,null,null,null,null,null,null,null));
		}else{
			String pr;
			for(WorkOrder w :listaOrdenes){
				List<Boolean> listaRend = new List<Boolean>();
				List<ENC_Respuesta__c> preg2 = new List<ENC_Respuesta__c>();
				for(Integer i=0;i<respuestasP2.size();i++){	
					if(respuestasP2[i].ENR_LKP_WorkOrder__c == w.Id&&pr!=respuestasP2[i].Id){
					preg2.add(respuestasP2[i]);
					pr=respuestasP2[i].Id;
					}
				}
				if(preg2[0].ENR_TXT_Respuesta__c.equals('-1')){
					respComentario = mapaRespuestas.get(preg2[0])[0].ENR_TXT_Respuesta__c;
					respRen1=false;
					respRen2=true;
					respRen3=false;
				}else if(preg2[0].ENR_TXT_Respuesta__c.equals('7')){
						respComentario = mapaRespuestas.get(preg2[0])[0].ENR_TXT_Respuesta__c;
						respRen1=false;
						respRen2=true;
						respRen3=false;
				}else if(Integer.valueOf(preg2[0].ENR_TXT_Respuesta__c)<7){
						motivosPregunta.put(2, mapaMotivos.get(2));
						listaPreg2=creacionRespuestas(motivosPregunta.get(2),mapaRespuestas.get(preg2[0]),2);
						respRen1=true;
						respRen2=false;
						respRen3=flagPreg.get(w.Id);
						if(respRen3==null)
						respRen3=false;
				}else if(Integer.valueOf(preg2[0].ENR_TXT_Respuesta__c)>7){
						motivosPregunta.put(2, mapaMotivos.get(3));
						respRen1=true;
						respRen2=false;
						listaPreg2=creacionRespuestas(motivosPregunta.get(2),mapaRespuestas.get(preg2[0]),2);
				}
				
				if(catalan){
					mapaTrad = Util_Metadatos.getMapaTraduccion(new Set<String>{'WorkOrder'});
					gremio=mapaTrad.get('1'+'0000'+'OTR_SEL_Gremio__c'+w.OTR_SEL_Gremio__c);
				}else{
					Map<String, String> mapaEsp =Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder','OTR_SEL_Gremio__c');
					gremio=mapaEsp.get(w.OTR_SEL_Gremio__c);
				}
				
				listaRend.add(respRen1);
				listaRend.add(respRen2);
				listaRend.add(respRen3);
				listaRend.add(respRen4);
				respPreg2.add(new RespuestaPregunta(preg2[0].ENR_TXT_Respuesta__c,listaPreg2,w,gremio,respComentario,motivosPregunta.get(2),listaRend,adicional));
			}
		}
		return respPreg2;
	}
	/**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 3
	* 
	* @return RespuestaPregunta
	*/ 
	public List<RespuestaPregunta> getRespuestas3(){
		String gremio;
		List<RespuestaPregunta> respPreg3 = new List<RespuestaPregunta>();
		List<objetoRespuesta> listaPreg3 = new List<objetoRespuesta>();
		
		String respComentario;
		
		if(listaEncuestaTipo[0].Name.contains('NN_Indemnizables')){
			List<Boolean> listaRend = new List<Boolean>();
			if(respuestasP[2].ENR_TXT_Respuesta__c.equals('-1')){
				respComentario=mapaRespuestas.get(respuestasP[2])[0].ENR_TXT_Respuesta__c;
				respRen1=true;
			}else{
				respRen1=false;
			}
			listaRend.add(respRen1);	
			respPreg3.add(new RespuestaPregunta(respuestasP[2].ENR_TXT_Respuesta__c,null,null,gremio,respComentario,motivosPregunta.get(3),listaRend,adicional));
		}else if(listaEncuestaTipo[0].Name.contains('NN_Cob')){
			List<Boolean> listaRend = new List<Boolean>();
				respComentario=mapaRespuestas.get(respuestasP[2])[0].ENR_TXT_Respuesta__c;
				respRen1=true;
			listaRend.add(respRen1);	
			respPreg3.add(new RespuestaPregunta(respuestasP[2].ENR_TXT_Respuesta__c,null,null,gremio,respComentario,motivosPregunta.get(3),listaRend,adicional));
		}else{
			String pr;
			for(WorkOrder w :listaOrdenes){
				List<Boolean> listaRend = new List<Boolean>();
				if(!flagWork.containsKey(w.Id)){
					List<ENC_Respuesta__c> preg3 = new List<ENC_Respuesta__c>();
					for(Integer i=0;i<respuestasP3.size();i++){	
						if(respuestasP3[i].ENR_LKP_WorkOrder__c == w.Id&&pr!=respuestasP3[i].Id){
						preg3.add(respuestasP3[i]);
						pr=respuestasP3[i].Id;
						}
					}	
					if(preg3[0].ENR_TXT_Respuesta__c.equals('0')){
						respRen1=true;
						respRen2=false;
						respRen3=false;
						motivosPregunta.put(3,mapaMotivos.get(4));
						listaPreg3=creacionRespuestas(motivosPregunta.get(3),mapaRespuestas.get(preg3[0]),3);
					}else if(preg3[0].ENR_TXT_Respuesta__c.equals('-1')){
							respRen1=false;
							respRen2=true;
							respRen3=false;
							respComentario=mapaRespuestas.get(preg3[0])[0].ENR_TXT_Respuesta__c;
							listaPreg3=creacionRespuestas(motivosPregunta.get(3),mapaRespuestas.get(preg3[0]),3);
					}else if(preg3[0].ENR_TXT_Respuesta__c.equals('1')){
							respRen1=false;
							respRen2=false;
							respRen3=true;
							if(listaEncuestaTipo[0].Name.contains('NN_Reparables'))
							listaPreg3=creacionRespuestas(null,mapaRespuestas.get(preg3[0]),3);
					}
					if(catalan){
						mapaTrad = Util_Metadatos.getMapaTraduccion(new Set<String>{'WorkOrder'});
						gremio=mapaTrad.get('1'+'0000'+'OTR_SEL_Gremio__c'+w.OTR_SEL_Gremio__c);
					}else{
						Map<String, String> mapaEsp =Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder','OTR_SEL_Gremio__c');
						gremio=mapaEsp.get(w.OTR_SEL_Gremio__c);
					}
					listaRend.add(respRen1);
					listaRend.add(respRen2);
					listaRend.add(respRen3);
					respPreg3.add(new RespuestaPregunta(preg3[0].ENR_TXT_Respuesta__c,listaPreg3,w,gremio,respComentario,motivosPregunta.get(3),listaRend,adicional));
				}
			}
		}
		return respPreg3;
	}
	/**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 4
	* 
	* @return RespuestaPregunta
	*/ 
	public RespuestaPregunta getRespuestas4(){
		List<ObjetoRespuesta> listaPreg4;
		List<Boolean> listaRend = new List<Boolean>();
		String respComentario;
		if(respuestasP[3].ENR_TXT_Respuesta__c.equals('0')){
			respRen1=true;
			respRen2=false;
			if(listaEncuestaTipo[0].Name.contains('END')){
				motivosPregunta.put(4,mapaMotivos.get(6));
			}else if(listaEncuestaTipo[0].Name.contains('NN_Indemnizables')||listaEncuestaTipo[0].Name.contains('NN_Reparables')){
				respRen1=false;
				respRen2=false;
				listaPreg4=null;
			}else{
				motivosPregunta.put(4,mapaMotivos.get(5));
			}
			listaPreg4=creacionRespuestas(motivosPregunta.get(4),mapaRespuestas.get(respuestasP[3]),4);
		}else if(respuestasP[3].ENR_TXT_Respuesta__c.equals('-1')){
			if(listaEncuestaTipo[0].Name.contains('NN_Indemnizables')||listaEncuestaTipo[0].Name.contains('NN_Reparables')){
				respRen1=false;
				respRen2=false;
				listaPreg4=null;
			}else{
				respRen1=false;
				respRen2=true;
				respComentario=mapaRespuestas.get(respuestasP[3])[0].ENR_TXT_Respuesta__c;
				listaPreg4=creacionRespuestas(motivosPregunta.get(4),mapaRespuestas.get(respuestasP[3]),4);
			}
		}else if(respuestasP[3].ENR_TXT_Respuesta__c.equals('1')){
			preguntas=true;
			respRen1=false;
			respRen2=false;
		}
		listaRend.add(respRen1);
		listaRend.add(respRen2);
		Map<String,String> codigoMotivos = new Map<String,String>();
		if(motivosPregunta.get(4) != null){
			for(SelectOption s :motivosPregunta.get(4)){
				codigoMotivos.put(s.getLabel(),s.getValue());
			}
			listaPreg4[0].motivo=codigoMotivos.get(listaPreg4[0].motivo);
		}
		
		respPreg4= new RespuestaPregunta(respuestasP[3].ENR_TXT_Respuesta__c,listaPreg4,null,null,respComentario,motivosPregunta.get(4),listaRend,null);
		return respPreg4;
	}
	/**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 5
	* 
	* @return RespuestaPregunta
	*/ 
	public RespuestaPregunta getRespuestas5(){
		List<ObjetoRespuesta> listaPreg5;
		List<Boolean> listaRend = new List<Boolean>();
		String respComentario;
		if(listaEncuestaTipo[0].Name.contains('NN_Indemnizables')){
			if(Integer.valueOf(respuestasP[4].ENR_TXT_Respuesta__c)<7){
				motivosPregunta.put(5,mapaMotivos.get(10));
				respRen1=true;
				respRen2=false;
				listaPreg5=creacionRespuestas(motivosPregunta.get(5),mapaRespuestas.get(respuestasP[4]),5);
			}else if(respuestasP[4].ENR_TXT_Respuesta__c.equals('-1')){
				respRen1=false;
				respRen2=true;
				respComentario=mapaRespuestas.get(respuestasP[4])[0].ENR_TXT_Respuesta__c;
				listaPreg5=null;
			}else{
				respRen1=false;
				respRen2=false;
			}
		}else{
			if(respuestasP[4].ENR_TXT_Respuesta__c.equals('0')){
				respRen1=true;
				respRen2=false;
				if(listaEncuestaTipo[0].Name.contains('END')){
					motivosPregunta.put(5,mapaMotivos.get(7));
				}else{
					motivosPregunta.put(5,mapaMotivos.get(6));
				}
				listaPreg5=creacionRespuestas(motivosPregunta.get(5),mapaRespuestas.get(respuestasP[4]),5);
			}else if(respuestasP[4].ENR_TXT_Respuesta__c.equals('-1')){
					respRen1=false;
					respRen2=true;
					respComentario=mapaRespuestas.get(respuestasP[4])[0].ENR_TXT_Respuesta__c;
					listaPreg5=creacionRespuestas(motivosPregunta.get(5),mapaRespuestas.get(respuestasP[4]),5);
			}else if(respuestasP[4].ENR_TXT_Respuesta__c.equals('1')){
				preguntas=true;
				respRen1=false;
				respRen2=false;
			}
			
		
		Map<String,String> codigoMotivos = new Map<String,String>();
		if(motivosPregunta.get(5) != null){
			for(SelectOption s :motivosPregunta.get(5)){
				codigoMotivos.put(s.getLabel(),s.getValue());
			}
			listaPreg5[0].motivo=codigoMotivos.get(listaPreg5[0].motivo);
		}
		}
		listaRend.add(respRen1);
		listaRend.add(respRen2);
		respPreg5= new RespuestaPregunta(respuestasP[4].ENR_TXT_Respuesta__c,listaPreg5,null,null,respComentario,motivosPregunta.get(5),listaRend,null);
		return respPreg5;
	}
	/**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 6
	* 
	* @return RespuestaPregunta
	*/ 
	public RespuestaPregunta getRespuestas6(){
		List<ObjetoRespuesta> listaPreg6;
		List<Boolean> listaRend = new List<Boolean>();
		String respComentario;
		if(listaEncuestaTipo[0].Name.contains('END')){
			if(Integer.valueOf(respuestasP[5].ENR_TXT_Respuesta__c)<7){
				respRen1=true;
				respRen2=false;
				motivosPregunta.put(6,mapaMotivos.get(16));
			}else {//Hay que terminar esta funcionalidad para las demas encuestas
				respRen1=false;
				respRen2=false;
			}
			listaPreg6=creacionRespuestas(motivosPregunta.get(6),mapaRespuestas.get(respuestasP[5]),6);
		}else if(listaEncuestaTipo[0].Name.contains('NN_Manitas')){
			motivosPregunta.put(6,mapaMotivos.get(8));
			respRen1=true;
			listaPreg6=creacionRespuestas(motivosPregunta.get(6),mapaRespuestas.get(respuestasP[5]),6);
		}else if(listaEncuestaTipo[0].Name.contains('NN_Reparables')){
			if(respuestasP[5].ENR_TXT_Respuesta__c.equals('-1')){
				respComentario=mapaRespuestas.get(respuestasP[5])[0].ENR_TXT_Respuesta__c;
				respRen1=true;
			}else{
				respRen1=false;
			}	
			listaPreg6=creacionRespuestas(motivosPregunta.get(6),mapaRespuestas.get(respuestasP[5]),6);
		}else if(listaEncuestaTipo[0].Name.contains('NN_Indemnizables')){
			respRen1=true;
			respComentario=mapaRespuestas.get(respuestasP[5])[0].ENR_TXT_Respuesta__c;
			listaPreg6=null;
		}else{
			if(respuestasP[5].ENR_TXT_Respuesta__c.equals('-1')){
				respRen1=false;
				respRen2=true;
				respComentario=mapaRespuestas.get(respuestasP[5])[0].ENR_TXT_Respuesta__c;
				listaPreg6=creacionRespuestas(motivosPregunta.get(6),mapaRespuestas.get(respuestasP[5]),6);
			}else if(respuestasP[5].ENR_TXT_Respuesta__c.equals('0')){
				respRen1=true;
				respRen2=false;
				motivosPregunta.put(6,mapaMotivos.get(7));
				listaPreg6=creacionRespuestas(motivosPregunta.get(6),mapaRespuestas.get(respuestasP[5]),6);
				Map<String,String> codigoMotivos = new Map<String,String>();
				if(motivosPregunta.get(6) != null){
					for(SelectOption s :motivosPregunta.get(6)){
						codigoMotivos.put(s.getLabel(),s.getValue());
					}
					listaPreg6[0].motivo=codigoMotivos.get(listaPreg6[0].motivo);
				}
			}else{
				respRen1=false;
				respRen2=false;
			}
			
		}
		
		listaRend.add(respRen1);
		listaRend.add(respRen2);
		respPreg6= new RespuestaPregunta(respuestasP[5].ENR_TXT_Respuesta__c,listaPreg6,null,null,respComentario,motivosPregunta.get(6),listaRend,null);
		return respPreg6;
	}
	/**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 7
	* 
	* @return RespuestaPregunta
	*/ 
	public RespuestaPregunta getRespuestas7(){
		List<ObjetoRespuesta> listaPreg7;
		List<Boolean> listaRend = new List<Boolean>();
		String respComentario;
		if(listaEncuestaTipo[0].Name.contains('END')){
			respComentario=mapaRespuestas.get(respuestasP[6])[0].ENR_TXT_Respuesta__c;
		}else if(listaEncuestaTipo[0].Name.contains('NN_Manitas')){
			respRen1=false;
			respRen2=true;
			respComentario=mapaRespuestas.get(respuestasP[6])[0].ENR_TXT_Respuesta__c;
			listaPreg7=null;
		}else{
			if(Integer.valueOf(respuestasP[6].ENR_TXT_Respuesta__c)<7){
				respRen1=true;
				respRen2=false;
				if(listaEncuestaTipo[0].Name.contains('RGA')){
					motivosPregunta.put(7,mapaMotivos.get(14));
				}else{
					motivosPregunta.put(7,mapaMotivos.get(8));
				}
			}else {//Hay que terminar esta funcionalidad para las demas encuestas
				if(listaEncuestaTipo[0].Name.contains('RGA')||listaEncuestaTipo[0].Name.contains('RS_Siniestros')){
					respComentario=mapaRespuestas.get(respuestasP[6])[0].ENR_TXT_Respuesta__c;
					respRen1=false;
					respRen2=true;
				}else{
					respRen1=false;
					respRen2=false;
				}
			}
			listaPreg7=creacionRespuestas(motivosPregunta.get(7),mapaRespuestas.get(respuestasP[6]),7);
		}
		listaRend.add(respRen1);
		listaRend.add(respRen2);
		respPreg7= new RespuestaPregunta(respuestasP[6].ENR_TXT_Respuesta__c,listaPreg7,null,null,respComentario,motivosPregunta.get(7),listaRend,null);
		return respPreg7;
	}
	/**
	* Crea y devuelve un objeto RespuestaPregunta.
	* Método para la generación de la Pregunta 8
	* 
	* @return RespuestaPregunta
	*/ 
	public RespuestaPregunta getRespuestas8(){
		List<Boolean> listaRend = new List<Boolean>();
		String respComentario;
		if(mapaRespuestas.get(respuestasP[7]).size()<1){
			respRen1=false;
		}else{
			respRen1=true;
			respComentario=mapaRespuestas.get(respuestasP[7])[0].ENR_TXT_Respuesta__c;
		}
		listaRend.add(respRen1);
		respPreg8=new RespuestaPregunta(respuestasP[7].ENR_TXT_Respuesta__c,null,null,null,respComentario,null,listaRend,null);
		return respPreg8;
	}
	public  without sharing class PreguntaWorkOrder {
		public String pregId;
		public String workId;
		public PreguntaWorkOrder(String pId,String wId){
			pregId=pId;
			workId=wId;
		}
	}
	/**
	* Busca y devuelve un Mapa de objeto Respuesta Padre y lista de objetos Respuesta Hijas.
	* 
	* 
	* @return Map<ENC_Respuesta__c,List<ENC_Respuesta__c>>
	*/ 
	public Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> getRespuestas(){
		List<ENC_Respuesta__c> respuesta = Database.query(
				'SELECT Id,ENR_LKP_Encuesta_Realizada__c,Name, ENR_LKP_Resp_Pregunta__r.ENP_TXT_Pregunta__c,ENR_TXT_Respuesta__c,ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c,ENR_LKP_Resp_Pregunta__c,ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c,ENR_LKP_Resp_Pregunta__r.Name,ENR_LKP_WorkOrder__c  FROM ENC_Respuesta__c WHERE ENR_LKP_Encuesta_Realizada__c = :idEncuesta ORDER BY Name '
				);
		Map<String,ENC_Respuesta__c> mapaFin = new Map<String,ENC_Respuesta__c>();
		for(ENC_Respuesta__c resp : respuesta){
			String var =String.valueOf(resp.ENR_LKP_Resp_Pregunta__c)+String.valueOf(resp.ENR_LKP_WorkOrder__c);
			mapaFin.put(var,resp);
		}
		Map<ENC_Respuesta__c,List<ENC_Respuesta__c>> mapaPeH = new Map<ENC_Respuesta__c,List<ENC_Respuesta__c>>();
		for(ENC_Respuesta__c r : respuesta){
			if(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c == null){
				mapaPeH.put(r,new List<ENC_Respuesta__c>());
			}else{
				mapaPeH.get(mapaFin.get(String.valueOf(r.ENR_LKP_Resp_Pregunta__r.ENP_LKP_Pregunta__c)+String.valueOf(r.ENR_LKP_WorkOrder__c))).add(r);
				
			}
		}
		return mapaPeH;
	}
	/**
	* Busca y devuelve una lista de objetos Pregunta.
	* Se generan además 2 listas más: lista de Preguntas Principales y otra con unas Preguntas en concreto
	* 
	* @return List<ENC_Pregunta__c>
	*/ 
	public List<ENC_Pregunta__c> getPreguntas(){
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
				aux = aux.replace('#COMPANIA#', compania);
				preg.ENP_TXT_Pregunta__c=aux;
			}
		}
		return listaPreguntasEdita;
	}
	/**
	* Busca y devuelve una lista de objetos de Tipo de Encuesta.
	* Se comprueba que idioma tiene dicho tipo de encuesta
	* 
	* @return List<ENC_Encuesta_Tipo__c>
	*/ 
	public List<ENC_Encuesta_Tipo__c> getTipoEncuesta(){
		List<ENC_Encuesta_Tipo__c> tiposEnc = Database.query('SELECT Id,ENT_TXT_Identificador__c,Name FROM ENC_Encuesta_Tipo__c WHERE Id IN (SELECT ENC_LKP_Encuesta_Tipo__c  FROM ENC_Encuesta__c WHERE Id= :idEncuesta)');
		idEncuestaTipo = tiposEnc[0].Id;
		if(tiposEnc[0].ENT_TXT_Identificador__c.contains('CAT')){
			catalan=true;
		}else{
			catalan=false;
		}
		return tiposEnc;
	} 

	/**
	* Busca y devuelve una lista de objetos Caso.
	* 
	* @return List<Case>
	*/ 
	public List<Case> getCasos() {
		List<Case> casos = Database.query(
				'SELECT Id, CreatedDate, CAS_LKP_Orden_Trabajo_Principal__r.OTR_SEL_Gremio__c,CAS_SEL_Grupo_Causa__c,CAS_SEL_Causa_Averia__c,CAS_TXT_WF_Compania__c FROM Case WHERE Id IN (SELECT ENC_LKP_Caso__c  FROM ENC_Encuesta__c WHERE Id= :idEncuesta)' 
				);
		return casos;
	}
	/**
	* Busca y devuelve una lista de objetos Orden de Trabajo.
	* 
	* @return List<Case>
	*/ 
	public List<WorkOrder> getOrdenes() {
		String aux = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
		List<WorkOrder> lista = Database.query(
				'SELECT Id, OTR_SEL_Gremio__c,OTR_TXT_Num_OrdenTrabajo_HS__c,CreatedDate  ' +
				'FROM WorkOrder WHERE caseId= :idCaso AND RecordTypeId !=: aux  ORDER BY OTR_SEL_Gremio__c'
				);
		return lista;
	}
	/**
	* Crea y devuelve una lista de opciones de seleccion determinada.
	* 
	* 
	* @return List<SelectOption>
	*/ 
	public List<SelectOption> getMotSN(Integer n) {
		List<SelectOption> listaItems = new List<SelectOption>(); 
		if(n==1){
			listaItems.add(new SelectOption('1','Si')); 
			listaItems.add(new SelectOption('0','No')); 
			if(catalan){
				listaItems.add(new SelectOption('-1','No procedeix'));
			}else{
				listaItems.add(new SelectOption('-1','No procede'));
			}	
		}else{
			listaItems.add(new SelectOption('1','Si')); 
			listaItems.add(new SelectOption('0','No')); 
			listaItems.add(new SelectOption('-1','Ns/Nc'));
		}
		return listaItems; 
	}
	/**
	* Crea y devuelve una lista de opciones de seleccion determinada.
	* 
	* 
	* @return List<SelectOption>
	*/ 
	public List<SelectOption> getMotValoracion() {
		List<SelectOption> listaItems = new List<SelectOption>();
		for (Integer i = 0; i <= 10; i++){
			listaItems.add(new SelectOption(String.valueOf(i),String.valueOf(i))); 
		}
		listaItems.add(new SelectOption('-1','Ns/Nc'));
		return listaItems; 
	}
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
}