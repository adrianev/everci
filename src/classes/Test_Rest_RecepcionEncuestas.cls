@isTest
public without sharing class Test_Rest_RecepcionEncuestas {
	
	private static Account compania;
	private static Account cuentaPrincipal;
	private static Account cuenta;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCIA;
	private static ServiceContract poliza;
	private static Case caso;
	private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo1;
	private static WorkOrder ordenTrabajo2;
	private static WorkOrder ordenTrabajo3;
	private static WorkOrder ordenTrabajo4;
	private static WorkOrder ordenTrabajo5;
	private static WorkOrder ordenTrabajo6;
	
	private static ENC_Encuesta_Tipo__c encuestaTipo;
	private static Map<String,String> mapatipoRespuestas;
	private static List<ENC_Pregunta__c> listaPreguntas;
	
	private static String codMovimiento {get;set;}
	private static String motivoRetirada {get;set;}
	private static Integer duracion {get;set;}
	private static Datetime dt {get;set;}
	private static String gestor {get;set;}
	private static String tipoEncuesta {get;set;}
	
    @isTest static void inicializarVariables(){
    	List<WorkOrder> woList = new List<WorkOrder>();
    	Baipas.establecerVariableControl();
    	compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1114567X');
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		tipoTrabajo.TDT_TXT_Identificador__c='100';
		insert tipoTrabajo;
		ordenTrabajo1 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		ordenTrabajo1.AccountId = cuenta.Id;
		woList.add(ordenTrabajo1);
		ordenTrabajo2 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877422';
		ordenTrabajo2.AccountId = cuenta.Id;
		woList.add(ordenTrabajo2);
		
		ordenTrabajo3 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877421';
		ordenTrabajo3.AccountId = cuenta.Id;
		woList.add(ordenTrabajo3);
		ordenTrabajo4 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877420';
		ordenTrabajo4.AccountId = cuenta.Id;
		woList.add(ordenTrabajo4);
		ordenTrabajo5 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877419';
		ordenTrabajo5.AccountId = cuenta.Id;
		woList.add(ordenTrabajo5);
		ordenTrabajo6 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877418';
		ordenTrabajo6.AccountId = cuenta.Id;
		woList.add(ordenTrabajo6);
		insert woList;
		
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T3_1018_RM', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id);
		insert encuestaTipo;
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id);
		insert listaPreguntas;
    	Baipas.deshabilitarVariableControl();
    }
    
    @isTest static void TestGremios(){
		inicializarVariables();
		tipoEncuesta = 'T3_1018_RM';
		codMovimiento = '2';
		inicializarEncuesta(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id,tipoEncuesta,codMovimiento);
		
		Test.startTest();
		
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID FROM ENC_Encuesta_Tipo__c];
		List<ENC_Respuesta__c> listRespuestas = [SELECT ID, ENR_LKP_Resp_Pregunta__r.Name FROM ENC_Respuesta__c];
		List<ENC_Pregunta__c> listPreguntas = [SELECT ID FROM ENC_Pregunta__c];
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		System.debug('@@@@@Encuesta: '+ listEncuesta);
		System.debug('@@@@@listPreguntas: '+ listPreguntas);
		System.debug('@@@@@listRespuestas: '+ listRespuestas);
		System.debug('@@@@@listTipoEncuesta: '+ listTipoEncuesta);
		
		Test.stopTest();
    }
    
    @isTest static void TestNoRealizada(){
		inicializarVariables();
		tipoEncuesta = 'T3_1018_RM';
		codMovimiento = '1';
		inicializarEncuesta(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id,tipoEncuesta,codMovimiento);
		
		Test.startTest();
		
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID FROM ENC_Encuesta_Tipo__c];
		List<ENC_Respuesta__c> listRespuestas = [SELECT ID, ENR_LKP_Resp_Pregunta__r.Name FROM ENC_Respuesta__c];
		List<ENC_Pregunta__c> listPreguntas = [SELECT ID FROM ENC_Pregunta__c];
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		System.debug('@@@@@Encuesta: '+ listEncuesta);
		System.debug('@@@@@listPreguntas: '+ listPreguntas);
		System.debug('@@@@@listRespuestas: '+ listRespuestas);
		System.debug('@@@@@listTipoEncuesta: '+ listTipoEncuesta);
		
		Test.stopTest();
    }
    
    @isTest static void TestNoCodMovimientos(){
		inicializarVariables();
		tipoEncuesta = 'T3_1018_RM';
		codMovimiento = '';
		inicializarEncuesta(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id,tipoEncuesta,codMovimiento);
		
		Test.startTest();
		
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID FROM ENC_Encuesta_Tipo__c];
		List<ENC_Respuesta__c> listRespuestas = [SELECT ID, ENR_LKP_Resp_Pregunta__r.Name FROM ENC_Respuesta__c];
		List<ENC_Pregunta__c> listPreguntas = [SELECT ID FROM ENC_Pregunta__c];
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		System.debug('@@@@@Encuesta: '+ listEncuesta);
		System.debug('@@@@@listPreguntas: '+ listPreguntas);
		System.debug('@@@@@listRespuestas: '+ listRespuestas);
		System.debug('@@@@@listTipoEncuesta: '+ listTipoEncuesta);
		
		Test.stopTest();
    }
    
    @isTest static void TestNoCaso(){
		inicializarVariables();
		tipoEncuesta = 'T3_1018_RM';
		codMovimiento = '2';
		
		caso.Id = '5009E000007J84eQAB';
		
		inicializarEncuesta(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id,tipoEncuesta,codMovimiento);
		
		Test.startTest();
		
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID FROM ENC_Encuesta_Tipo__c];
		List<ENC_Respuesta__c> listRespuestas = [SELECT ID, ENR_LKP_Resp_Pregunta__r.Name FROM ENC_Respuesta__c];
		List<ENC_Pregunta__c> listPreguntas = [SELECT ID FROM ENC_Pregunta__c];
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		System.debug('@@@@@Encuesta: '+ listEncuesta);
		System.debug('@@@@@listPreguntas: '+ listPreguntas);
		System.debug('@@@@@listRespuestas: '+ listRespuestas);
		System.debug('@@@@@listTipoEncuesta: '+ listTipoEncuesta);
		
		Test.stopTest();
    }
    
    @isTest static void TestNoEncuesta(){
		inicializarVariables();
		tipoEncuesta = 'T3_1018_RM4';
		codMovimiento = '2';
		
		inicializarEncuesta(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id,tipoEncuesta,codMovimiento);
		
		Test.startTest();
		
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID FROM ENC_Encuesta_Tipo__c];
		List<ENC_Respuesta__c> listRespuestas = [SELECT ID, ENR_LKP_Resp_Pregunta__r.Name FROM ENC_Respuesta__c];
		List<ENC_Pregunta__c> listPreguntas = [SELECT ID FROM ENC_Pregunta__c];
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		System.debug('@@@@@Encuesta: '+ listEncuesta);
		System.debug('@@@@@listPreguntas: '+ listPreguntas);
		System.debug('@@@@@listRespuestas: '+ listRespuestas);
		System.debug('@@@@@listTipoEncuesta: '+ listTipoEncuesta);
		
		Test.stopTest();
    }
    
    @isTest static void TestNoPregunta(){
		inicializarVariables();
		tipoEncuesta = 'T3_1018_RM';
		codMovimiento = '2';
		
		inicializarEncuestaNoPregunta(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id,tipoEncuesta,codMovimiento);
		
		Test.startTest();
		
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID FROM ENC_Encuesta_Tipo__c];
		List<ENC_Respuesta__c> listRespuestas = [SELECT ID, ENR_LKP_Resp_Pregunta__r.Name FROM ENC_Respuesta__c];
		List<ENC_Pregunta__c> listPreguntas = [SELECT ID FROM ENC_Pregunta__c];
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		System.debug('@@@@@Encuesta: '+ listEncuesta);
		System.debug('@@@@@listPreguntas: '+ listPreguntas);
		System.debug('@@@@@listRespuestas: '+ listRespuestas);
		System.debug('@@@@@listTipoEncuesta: '+ listTipoEncuesta);
		
		Test.stopTest();
    }
    
    @isTest static void inicializarEncuestaNoWO(){
		inicializarVariables();
		tipoEncuesta = 'T3_1018_RM';
		codMovimiento = '2';
		
		inicializarEncuesta('1234',ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id,tipoEncuesta,codMovimiento);
		
		Test.startTest();
		
		List<ENC_Encuesta_Tipo__c> listTipoEncuesta = [SELECT ID FROM ENC_Encuesta_Tipo__c];
		List<ENC_Respuesta__c> listRespuestas = [SELECT ID, ENR_LKP_Resp_Pregunta__r.Name FROM ENC_Respuesta__c];
		List<ENC_Pregunta__c> listPreguntas = [SELECT ID FROM ENC_Pregunta__c];
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		System.debug('@@@@@Encuesta: '+ listEncuesta);
		System.debug('@@@@@listPreguntas: '+ listPreguntas);
		System.debug('@@@@@listRespuestas: '+ listRespuestas);
		System.debug('@@@@@listTipoEncuesta: '+ listTipoEncuesta);
		
		Test.stopTest();
    }
    
    private static void inicializarEncuesta(String WoNumber1,String WoNumber2,String WoNumber3,String WoNumber4,String WoNumber5,String WoNumber6,Id idCaso,String tipoEncuesta, String codMovimiento){
    	motivoRetirada = '0';
    	duracion = 500;
    	dt = DateTime.now();
    	gestor = 'Gestor';
    	String chorro = '[{"numOrdenTrabajo": "","pregunta": "P1_1018_RM","respuesta": "0"},{"numOrdenTrabajo": "","pregunta": "P1_1_1018_RM","respuesta": "M01_ESP_03"},{"numOrdenTrabajo": "","pregunta": "P1_2_1018_RM","respuesta": "Cuadro de Texto Motivos Pregunta1"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio1 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio1 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_1018_RM","respuesta": "4"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_06"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio2 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_05"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio2 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_4_1018_RM","respuesta": "1"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio3 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio3 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio4 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio4 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio5 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio5 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio6 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio6 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P3_1018_RM","respuesta": "-1"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P3_3_1018_RM","respuesta": "Comentario en Cuadro de Texto NS/NC Gremio 2 Pregunta 3"},{"numOrdenTrabajo": "","pregunta": "P4_1018_RM","respuesta": "-1"},{"numOrdenTrabajo": "","pregunta": "P4_3_1018_RM","respuesta": "Comentario en Cuadro de texto NS/NC Pregunta 4"},{"numOrdenTrabajo": "","pregunta": "P5_1018_RM","respuesta": "0"},{"numOrdenTrabajo": "","pregunta": "P5_1_1018_RM","respuesta": "M06_ESP_02"},{"numOrdenTrabajo": "","pregunta": "P5_2_1018_RM","respuesta": "Comentario en Cuadro de texto Tono Empleado Pregunta 5"},{"numOrdenTrabajo": "","pregunta": "P6_1018_RM","respuesta": "1"},{"numOrdenTrabajo": "","pregunta": "P7_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "","pregunta": "P7_1_1018_RM","respuesta": "M08_ESP_01"},{"numOrdenTrabajo": "","pregunta": "P7_2_1018_RM","respuesta": "Comentario en Cuadro de texto Atencion Telefonica Pregunta 7 1"},{"numOrdenTrabajo": "","pregunta": "P7_1_1018_RM","respuesta": "M08_ESP_02"},{"numOrdenTrabajo": "","pregunta": "P7_2_1018_RM","respuesta": "Comentario en Cuadro de texto Cobertura Siniestro Pregunta 7 2"},{"numOrdenTrabajo": "","pregunta": "P8_1018_RM","respuesta": "8"},{"numOrdenTrabajo": "","pregunta": "P8_1_1018_RM","respuesta": "Comentario en Cuadro de texto opcional"}]';
    	chorro=chorro.replace('WorkOrder1', WoNumber1);
    	chorro=chorro.replace('WorkOrder2', WoNumber2);
    	chorro=chorro.replace('WorkOrder3', WoNumber3);
    	chorro=chorro.replace('WorkOrder4', WoNumber4);
    	chorro=chorro.replace('WorkOrder5', WoNumber5);
    	chorro=chorro.replace('WorkOrder6', WoNumber6);
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor);
    }
    
    private static void inicializarEncuestaNoPregunta(String WoNumber1,String WoNumber2,String WoNumber3,String WoNumber4,String WoNumber5,String WoNumber6,Id idCaso,String tipoEncuesta, String codMovimiento){
    	motivoRetirada = '0';
    	duracion = 500;
    	dt = DateTime.now();
    	gestor = 'Gestor';
    	String chorro = '[{"numOrdenTrabajo": "","pregunta": "123P1_1018_RM","respuesta": "0"},{"numOrdenTrabajo": "","pregunta": "P1_1_1018_RM","respuesta": "M01_ESP_03"},{"numOrdenTrabajo": "","pregunta": "P1_2_1018_RM","respuesta": "Cuadro de Texto Motivos Pregunta1"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio1 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder1","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio1 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_1018_RM","respuesta": "4"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_06"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio2 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_05"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio2 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P2_4_1018_RM","respuesta": "1"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio3 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder3","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio3 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio4 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder4","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio4 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio5 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder5","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio5 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_01"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio6 Pregunta 2 1"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_2_1018_RM","respuesta": "M02_ESP_04"},{"numOrdenTrabajo": "WorkOrder6","pregunta": "P2_3_1018_RM","respuesta": "Comentario en Cuadro de texto Gremio6 Pregunta 2 2"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P3_1018_RM","respuesta": "-1"},{"numOrdenTrabajo": "WorkOrder2","pregunta": "P3_3_1018_RM","respuesta": "Comentario en Cuadro de Texto NS/NC Gremio 2 Pregunta 3"},{"numOrdenTrabajo": "","pregunta": "P4_1018_RM","respuesta": "-1"},{"numOrdenTrabajo": "","pregunta": "P4_3_1018_RM","respuesta": "Comentario en Cuadro de texto NS/NC Pregunta 4"},{"numOrdenTrabajo": "","pregunta": "P5_1018_RM","respuesta": "0"},{"numOrdenTrabajo": "","pregunta": "P5_1_1018_RM","respuesta": "M06_ESP_02"},{"numOrdenTrabajo": "","pregunta": "P5_2_1018_RM","respuesta": "Comentario en Cuadro de texto Tono Empleado Pregunta 5"},{"numOrdenTrabajo": "","pregunta": "P6_1018_RM","respuesta": "1"},{"numOrdenTrabajo": "","pregunta": "P7_1018_RM","respuesta": "2"},{"numOrdenTrabajo": "","pregunta": "P7_1_1018_RM","respuesta": "M08_ESP_01"},{"numOrdenTrabajo": "","pregunta": "P7_2_1018_RM","respuesta": "Comentario en Cuadro de texto Atencion Telefonica Pregunta 7 1"},{"numOrdenTrabajo": "","pregunta": "P7_1_1018_RM","respuesta": "M08_ESP_02"},{"numOrdenTrabajo": "","pregunta": "P7_2_1018_RM","respuesta": "Comentario en Cuadro de texto Cobertura Siniestro Pregunta 7 2"},{"numOrdenTrabajo": "","pregunta": "P8_1018_RM","respuesta": "8"},{"numOrdenTrabajo": "","pregunta": "P8_1_1018_RM","respuesta": "Comentario en Cuadro de texto opcional"}]';
    	chorro=chorro.replace('WorkOrder1', WoNumber1);
    	chorro=chorro.replace('WorkOrder2', WoNumber2);
    	chorro=chorro.replace('WorkOrder3', WoNumber3);
    	chorro=chorro.replace('WorkOrder4', WoNumber4);
    	chorro=chorro.replace('WorkOrder5', WoNumber5);
    	chorro=chorro.replace('WorkOrder6', WoNumber6);
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor);
    }
    
    private static List<ENC_Pregunta__c> creaPreguntasEncuesta(Id encuestaTipoId){
    	List<ENC_Pregunta__c> listaPreguntas = new List<ENC_Pregunta__c>();
    	cargarMapa();
    	ENC_Pregunta__c pregunta;
    	for(String identificador : mapatipoRespuestas.keySet()){
    		pregunta = new ENC_Pregunta__c();
    		pregunta.ENP_TXT_Identificador__c = identificador;
    		pregunta.ENP_SEL_Tipo_Respuesta__c = mapatipoRespuestas.get(identificador);
    		pregunta.ENP_LKP_Encuesta_Tipo__c = encuestaTipoId;
    		listaPreguntas.add(pregunta);
    	}
    	return listaPreguntas;
    }
    
    private static void cargarMapa(){
    	mapatipoRespuestas = new Map<String,String>();
    	mapatipoRespuestas.put('P1_1018_RM','Sí/No');
    	mapatipoRespuestas.put('P2_1018_RM','Número');
    	mapatipoRespuestas.put('P3_1018_RM','Sí/No');
    	mapatipoRespuestas.put('P4_1018_RM','Sí/No');
    	mapatipoRespuestas.put('P5_1018_RM','Sí/No');
    	mapatipoRespuestas.put('P6_1018_RM','Sí/No');
    	mapatipoRespuestas.put('P7_1018_RM','Número');
    	mapatipoRespuestas.put('P8_1018_RM','Número');
    	mapatipoRespuestas.put('P1_1_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P1_2_1018_RM','Texto');
    	mapatipoRespuestas.put('P1_3_1018_RM','Texto');
    	mapatipoRespuestas.put('P2_1_1018_RM','Texto');
    	mapatipoRespuestas.put('P2_2_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P2_3_1018_RM','Sí/No');
    	mapatipoRespuestas.put('P2_4_1018_RM','Texto');
    	mapatipoRespuestas.put('P2_5_1018_RM','Texto');
    	mapatipoRespuestas.put('P2_6_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P2_7_1018_RM','Texto');
    	mapatipoRespuestas.put('P3_1_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P3_2_1018_RM','Texto');
    	mapatipoRespuestas.put('P3_3_1018_RM','Texto');
    	mapatipoRespuestas.put('P4_1_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P4_2_1018_RM','Texto');
    	mapatipoRespuestas.put('P4_3_1018_RM','Texto');
    	mapatipoRespuestas.put('P5_1_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P5_2_1018_RM','Texto');
    	mapatipoRespuestas.put('P5_3_1018_RM','Texto');
    	mapatipoRespuestas.put('P6_1_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P6_2_1018_RM','Texto');
    	mapatipoRespuestas.put('P6_3_1018_RM','Texto');
    	mapatipoRespuestas.put('P7_1_1018_RM','Lista de Opciones');
    	mapatipoRespuestas.put('P7_2_1018_RM','Texto');
    	mapatipoRespuestas.put('P8_1_1018_RM','Texto');
    	mapatipoRespuestas.put('P2_8_1018_RM','Texto');
    	mapatipoRespuestas.put('P1_4_1018_RM','Lista de Opciones');
    }
	
}