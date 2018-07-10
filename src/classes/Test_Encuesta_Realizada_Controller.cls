@isTest//(SeeAllData=true)
public without sharing class Test_Encuesta_Realizada_Controller {
	private static Account compania;
	private static Account compania2;
	private static Account compania3;
	private static Account cuentaPrincipal;
	private static Account cuenta;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Tipo_Producto_CIA__c tipoProductoCIA2;
	private static Tipo_Producto_CIA__c tipoProductoCIA3;
	private static Producto_CIA__c productoCIA;
	private static ServiceContract poliza;
	private static Case caso;
	private static Case caso2;
	private static Case caso3;
	private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo1;
	private static WorkOrder ordenTrabajo1SC;
	private static WorkOrder ordenTrabajo2SC;
	private static WorkOrder ordenTrabajo1RGA;
	
	private static ENC_Encuesta_Tipo__c encuestaTipo;
	private static Map<String,String> mapatipoRespuestasPadres;
	private static Map<String,String> mapatipoRespuestasHijas;
	private static List<ENC_Pregunta__c> listaPreguntasPadres;
	private static List<ENC_Pregunta__c> listaPreguntasHijas;
	private static List<ENC_Pregunta__c> listaPreguntas;
	
    private static void inicializarVariables(){
    	List<WorkOrder> woList = new List<WorkOrder>();
    	Baipas.establecerVariableControl();
    	compania2 = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
    	compania = Util_Tests.crearCuentaCompania('ENDESA','5610','X1234567X');
    	compania3 = Util_Tests.crearCuentaCompania('RGA','1023','X1276567X');
		insert compania;
		insert compania2;
		insert compania3;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1114567X');
		insert cuenta;
		tipoProductoCIA2 = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania2.ID);
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('ENDESA - HOGAR','01',compania.ID);
		tipoProductoCIA3 = Util_Tests.crearTipoProductoCIA('RGA - HOGAR','01',compania3.ID);
		insert tipoProductoCIA;
		insert tipoProductoCIA2;
		insert tipoProductoCIA3;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_tests.crearPolizaContrato('10', compania.id, cuenta.id, productoCIA.id);
		insert poliza;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		caso2 = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania2.Id);
		insert caso2;
		caso3 = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania3.Id);
		insert caso3;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		tipoTrabajo.TDT_TXT_Identificador__c='100';
		insert tipoTrabajo;
		ordenTrabajo1 = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		ordenTrabajo1.AccountId = cuenta.Id;
		woList.add(ordenTrabajo1);
		
		ordenTrabajo1SC = Util_Tests.crearOrdenTrabajo('16210.0','21',tipoTrabajo.Id,caso2.Id);
		ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c = '10000981';
		ordenTrabajo1SC.AccountId = cuenta.Id;
		woList.add(ordenTrabajo1SC);
		
		ordenTrabajo2SC = Util_Tests.crearOrdenTrabajo('18510.0','21',tipoTrabajo.Id,caso2.Id);
		ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c = '10000982';
		ordenTrabajo2SC.AccountId = cuenta.Id;
		woList.add(ordenTrabajo2SC);
		
		ordenTrabajo1RGA = Util_Tests.crearOrdenTrabajo('18260.0','21',tipoTrabajo.Id,caso3.Id);
		ordenTrabajo1RGA.OTR_TXT_Num_OrdenTrabajo_HS__c = '0010000786';
		ordenTrabajo1RGA.AccountId = cuenta.Id;
		woList.add(ordenTrabajo1RGA);
		
		insert woList;
		
    	Baipas.deshabilitarVariableControl();
    }
 /*   
    @isTest static void testEncuesta_Realizada_Tipo_Largo(){
		inicializarVariables();
		
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T3_1018_RM', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id);
		insert encuestaTipo;
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		
		inicializarEncuesta(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo3.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo4.OTR_TXT_Num_OrdenTrabajo_HS__c,
				ordenTrabajo5.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo6.OTR_TXT_Num_OrdenTrabajo_HS__c, caso.Id);
		
		Test.startTest();
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		for(ENC_Pregunta__c p : listaPreg){
			system.debug('@@@@Pregunta p: '+ p);
		}
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		PageReference pageRef = Page.Encuesta_Realizada_Tipo_Largo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        a.getRespuestas1();
        //a.getRespuestas2();
        //a.getRespuestas3();
        //a.getRespuestas4();
        //a.getRespuestas5();
        //a.getRespuestas6();
        a.getRespuestas7();
        //a.getRespuestas8();
        /*a.getTableRows1();
        a.getTableRows2();
        a.getRespuestas6MA();
        a.getRespuestas7MA();
        a.getRespuestas2NN();
        a.getRespuestas3NN();
        a.getRespuestas5NN();
        a.getRespuestas6NN();
        a.getRespuestas6NIN();
        a.getRespuestas1CA();
        a.getRespuestas2CA();
        a.getRespuestas3CA();
        a.getRespuestas4AS();
        a.getRespuestas5AS();
        a.getRespuestas6AS();
        a.getRespuestas7AS();*----------/
		Test.stopTest();
    }
*/    
    @isTest static void testEncuesta_Realizada_Tipo_Largo_RGA(){
		inicializarVariables();
		
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T1_1023_MA', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id, Name='RGA_Manitas');
		insert encuestaTipo;
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		inicializarEncuestaRGA(ordenTrabajo1RGA.OTR_TXT_Num_OrdenTrabajo_HS__c,caso3.Id);
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		for(ENC_Pregunta__c p : listaPreg){
			system.debug('@@@@Pregunta p: '+ p);
		}
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		Test.startTest();
		PageReference pageRef = Page.Encuesta_Realizada_Tipo_Largo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        a.getRespuestas1();
        a.getRespuestas2();
        a.getRespuestas3();
        a.getRespuestas4();
        a.getRespuestas5();
        a.getRespuestas6();
        a.getRespuestas7();
        a.getRespuestas8();
		Test.stopTest();
    }
    
    
        @isTest static void testEncuesta_Realizada_NN_Indemnizables(){
		inicializarVariables();
		
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T1_1023_MA', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id, Name='NN_Indemnizables');
		insert encuestaTipo;
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		inicializarEncuestaRGA(ordenTrabajo1RGA.OTR_TXT_Num_OrdenTrabajo_HS__c,caso3.Id);
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		for(ENC_Pregunta__c p : listaPreg){
			system.debug('@@@@Pregunta p: '+ p);
		}
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		Test.startTest();
		PageReference pageRef = Page.Encuesta_Realizada_Tipo_Largo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        a.getRespuestas1();
        a.getRespuestas2();
        a.getRespuestas3();
        a.getRespuestas4();
        a.getRespuestas5();
       // a.getRespuestas6();
        //a.getRespuestas7();
        //a.getRespuestas8();
		Test.stopTest();
    }
    
    
    
    
 
   
    @isTest static void testEncuesta_SegurCaixa(){
    	inicializarVariables();
		
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T3_1018_RM', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id, Name='SegurCaixa');
		insert encuestaTipo;
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		inicializarEncuestaSC1(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		//inicializarEncuestaSC2(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		//inicializarEncuestaSC3(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		Test.startTest();
		PageReference pageRef = Page.Encuesta_Realizada_Tipo_Largo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        a.catalan=true;
        a.getRespuestas1();
		Test.stopTest();
    }
    @isTest static void testEncuesta_SegurCaixa2(){
    	inicializarVariables();
		
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T3_1018_RM', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id, Name='SegurCaixa');
		insert encuestaTipo;
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		//inicializarEncuestaSC1(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		inicializarEncuestaSC2(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		//inicializarEncuestaSC3(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		Test.startTest();
		PageReference pageRef = Page.Encuesta_Realizada_Tipo_Largo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        a.catalan=true;
        a.getRespuestas1();
        a.getRespuestas2();
        a.getRespuestas3();
        a.getRespuestas4();
        a.getRespuestas5();
        a.getRespuestas6();
        a.getRespuestas7();
        a.getRespuestas8();
		Test.stopTest();
    }
    @isTest static void testEncuesta_SegurCaixa3(){
    	inicializarVariables();
		
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T3_1018_RM', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id, Name='SegurCaixa');
		insert encuestaTipo;
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		//inicializarEncuestaSC1(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		//inicializarEncuestaSC2(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		inicializarEncuestaSC3(ordenTrabajo1SC.OTR_TXT_Num_OrdenTrabajo_HS__c,ordenTrabajo2SC.OTR_TXT_Num_OrdenTrabajo_HS__c, caso2.Id);
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		Test.startTest();
		PageReference pageRef = Page.Encuesta_Realizada_Tipo_Largo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        a.catalan=true;
        a.getRespuestas1();
        a.getRespuestas2();
        a.getRespuestas3();
        a.getRespuestas4();
        a.getRespuestas5();
        a.getRespuestas6();
        a.getRespuestas7();
        a.getRespuestas8();
		Test.stopTest();
    }
   
	@isTest static void testEncuesta_Endesa_Catalan(){
    	inicializarVariables();
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T1_5610_AS_CAT', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id, Name='END_Asistencia_CAT');
		insert encuestaTipo;
		System.debug('@@@@@@@tipo:EncuestaId: '+encuestaTipo.Id);
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		List<ENC_Pregunta__c> listaPreguntas2 = new List<ENC_Pregunta__c>([Select Id,ENP_TXT_Identificador__c,ENP_LKP_Encuesta_Tipo__r.ENT_TXT_Identificador__c FROM ENC_Pregunta__c]);
		for(ENC_Pregunta__c p:listaPreguntas2){
			System.debug('@@@@@@@tipo:Encuesta: '+p.ENP_TXT_Identificador__c);
		}
		inicializarEncuestaEndCat(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,caso.Id);
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		Test.startTest();
		PageReference pageRef = Page.Encuesta_Realizada_END_Asistencia;
		
		for(Integer i=0; i<9;i++){
		List<ENC_Respuesta__c> pregunta = Database.query(
				'SELECT Id,Name, ENR_LKP_Encuesta_Realizada__c,ENR_LKP_WorkOrder__c, ENR_TXT_Gremio__c,ENR_LKP_Resp_Pregunta__c,ENR_LKP_Resp_Pregunta__r.Name, ENR_TXT_Pregunta__c, ENR_TXT_Respuesta__c  FROM ENC_Respuesta__c WHERE ENR_LKP_Resp_Pregunta__r.Name LIKE \''+'P'+i+'%\' ORDER BY Name'
				);
		System.debug('@@@@@@Lista'+pregunta);
		}
		
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        //a.catalan=true;
        a.getRespuestas1();
        a.getRespuestas2();
        a.getRespuestas3();
        a.getRespuestas4();
        a.getRespuestas5();
        a.getRespuestas6();
        a.getRespuestas7();
		Test.stopTest();
    } 

    @isTest static void testEncuesta_Endesa(){
    	inicializarVariables();
		encuestaTipo = new ENC_Encuesta_Tipo__c(ENT_TXT_Identificador__c='T1_5610_AS', ENT_SEL_Long_Encuesta__c = '02',ENT_LKP_Cuenta__c=cuenta.Id, Name='END_Asistencia');
		insert encuestaTipo;
		System.debug('@@@@@@@tipo:EncuestaId: '+encuestaTipo.Id);
		listaPreguntas = creaPreguntasEncuesta(encuestaTipo.Id,encuestaTipo.ENT_TXT_Identificador__c);
		upsert listaPreguntas;
		List<ENC_Pregunta__c> listaPreguntas2 = new List<ENC_Pregunta__c>([Select Id,ENP_TXT_Identificador__c,ENP_LKP_Encuesta_Tipo__r.ENT_TXT_Identificador__c FROM ENC_Pregunta__c]);
		for(ENC_Pregunta__c p:listaPreguntas2){
			System.debug('@@@@@@@tipo:Encuesta: '+p.ENP_TXT_Identificador__c);
		}
		inicializarEncuestaEndEsp(ordenTrabajo1.OTR_TXT_Num_OrdenTrabajo_HS__c,caso.Id);
		List<ENC_Pregunta__c> listaPreg = new List<ENC_Pregunta__c>([Select ENP_TXT_Identificador__c,ENP_LKP_Pregunta__r.ENP_TXT_Identificador__c,ENP_SEL_Tipo_Respuesta__c,ENP_LKP_Encuesta_Tipo__r.Name FROM ENC_Pregunta__c]);
		List<ENC_Encuesta__c> listEncuesta = [SELECT ID FROM ENC_Encuesta__c];
		Test.startTest();
		PageReference pageRef = Page.Encuesta_Realizada_END_Asistencia;
		
		for(Integer i=0; i<9;i++){
		List<ENC_Respuesta__c> pregunta = Database.query(
				'SELECT Id,Name, ENR_LKP_Encuesta_Realizada__c,ENR_LKP_WorkOrder__c, ENR_TXT_Gremio__c,ENR_LKP_Resp_Pregunta__c,ENR_LKP_Resp_Pregunta__r.Name, ENR_TXT_Pregunta__c, ENR_TXT_Respuesta__c  FROM ENC_Respuesta__c WHERE ENR_LKP_Resp_Pregunta__r.Name LIKE \''+'P'+i+'%\' ORDER BY Name'
				);
		System.debug('@@@@@@Lista'+pregunta);
		}
		
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId',listEncuesta.get(0).Id);
        EncuestaRealizadaController a = new EncuestaRealizadaController();
        //a.catalan=true;
        a.getRespuestas1();
        a.getRespuestas2();
        a.getRespuestas3();
        a.getRespuestas4();
        a.getRespuestas5();
        a.getRespuestas6();
        a.getRespuestas7();
       
		Test.stopTest();
    }
    
    
    private static void inicializarEncuestaRGA(String WoNumber1,Id idCaso){
    	String tipoEncuesta = 'T1_1023_MA';
    	String codMovimiento = '2';
    	String motivoRetirada = '0';
    	Integer duracion = 500;
    	Datetime dt = DateTime.now();
    	String gestor = Label.PERFIL_GESTOR_FRONT_TRAMITACION;
    	String chorro = '[{  "pregunta": "P1_1023_MA",  "respuesta": "1"},{  "numOrdenTrabajo": "0010000786",  "pregunta": "P2_1023_MA",  "respuesta": "8"},{  "numOrdenTrabajo": "0010000786",  "pregunta": "P2_6_1023_MA",  "respuesta": "M03_ESP_01"},{  "numOrdenTrabajo": "0010000786",  "pregunta": "P2_7_1023_MA",  "respuesta": "obs 8 Motivo Puntuación 8 Puntualidad/Formalidad Valoración Gremio"},{  "numOrdenTrabajo": "10000982",  "pregunta": "P2_1023_MA",  "respuesta": "3"},{  "numOrdenTrabajo": "10000982",  "pregunta": "P2_2_1023_MA",  "respuesta": "M02_ESP_03"},{  "numOrdenTrabajo": "10000982",  "pregunta": "P2_3_1023_MA",  "respuesta": "obs 3 Motivo Puntuación 3 Actitud Valoración Gremio"},{  "numOrdenTrabajo": "10000982",  "pregunta": "P3_1023_MA",  "respuesta": "1"},{  "pregunta": "P4_1023_MA",  "respuesta": "1"},{  "pregunta": "P5_1023_MA",  "respuesta": "1"},{  "pregunta": "P6_1023_MA",  "respuesta": "1"},{  "pregunta": "P7_1023_MA",  "respuesta": "6"},{  "pregunta": "P7_1_1023_MA",  "respuesta": "M14_ESP_01"},{  "pregunta": "P7_2_1023_MA",  "respuesta": "1 - Motivos Atención telefónica Valoracion Global Negativa"},{  "pregunta": "P7_1_1023_MA",  "respuesta": "M14_ESP_03"},{  "pregunta": "P7_2_1023_MA",  "respuesta": "2 - Motivos Intervención de Profesional Valoracion Global Negativa"},{  "pregunta": "P7_1_1023_MA",  "respuesta": "M14_ESP_04"},{  "pregunta": "P7_2_1023_MA",  "respuesta": "3- Motivos Calidad de la reparación Valoracion Global Negativa"},{  "pregunta": "P7_1_1023_MA",  "respuesta": "M14_ESP_06"},{  "pregunta": "P7_2_1023_MA",  "respuesta": "4 - Motivos Otros Valoracion Global Negativa"},{  "pregunta": "P8_1023_MA",  "respuesta": "7"},{  "pregunta": "P8_1_1023_MA",  "respuesta": "obs 4 Pregunta Probabilidad Recomendación"}]';
    	chorro=chorro.replace('WorkOrder1', WoNumber1);//0010000786
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor);
		system.debug('-----------Encuesta inicializada');
    }
    
    private static void inicializarEncuestaSC1(String WoNumber1,String WoNumber2,Id idCaso){
    	String tipoEncuesta = 'T3_1018_RM';
    	String codMovimiento = '2';
    	String motivoRetirada = '0';
    	Integer duracion = 500;
    	Datetime dt = DateTime.now();
    	String gestor = Label.PERFIL_GESTOR_FRONT_TRAMITACION;
    	String chorro = '[{  "pregunta": "P1_1018_RM",  "respuesta": "0"},{  "pregunta": "P1_1_1018_RM",  "respuesta": "M01_ESP_03"},{  "pregunta": "P1_2_1018_RM",  "respuesta": "obs 0 Motivo Reparaciones Defectuosas"}]';
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor);
		system.debug('-----------Encuesta inicializada');
    }
    
    private static void inicializarEncuestaSC2(String WoNumber1,String WoNumber2,Id idCaso){
    	String tipoEncuesta = 'T3_1018_RM';
    	String codMovimiento = '2';
    	String motivoRetirada = '0';
    	Integer duracion = 500;
    	Datetime dt = DateTime.now();
    	String gestor = Label.PERFIL_GESTOR_FRONT_TRAMITACION;
    	String chorro = '[{  "pregunta": "P1_1018_RM",  "respuesta": "1"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_1018_RM",  "respuesta": "6"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_2_1018_RM",  "respuesta": "M02_ESP_06"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_3_1018_RM",  "respuesta": "obs 6 Motivo Puntuación 6 Mala Calidad Trabajos Valoración Gremio"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_4_1018_RM",  "respuesta": "1"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_1018_RM",  "respuesta": "2"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_2_1018_RM",  "respuesta": "M02_ESP_06"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_3_1018_RM",  "respuesta": "obs 2 Motivo Puntuación 2 Mala Calidad Trabajos Valoración Gremio"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_4_1018_RM",  "respuesta": "0"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_8_1018_RM",  "respuesta": "5241235121"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_1018_RM",  "respuesta": "-1"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_3_1018_RM",  "respuesta": "obs NS/NC - Pregunta 3"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P3_1018_RM",  "respuesta": "1"},{  "pregunta": "P4_1018_RM",  "respuesta": "-1"},{  "pregunta": "P4_3_1018_RM",  "respuesta": "obs NS/NC - Pregunta 4"},{  "pregunta": "P5_1018_RM",  "respuesta": "-1"},{  "pregunta": "P5_2_1018_RM",  "respuesta": "obs NS/NC - Pregunta 5"},{  "pregunta": "P6_1018_RM",  "respuesta": "-1"},{  "pregunta": "P6_2_1018_RM",  "respuesta": "obs NS/NC - Pregunta 6"},{  "pregunta": "P7_1018_RM",  "respuesta": "9"},{  "pregunta": "P8_1018_RM",  "respuesta": "4"},{  "pregunta": "P8_1_1018_RM",  "respuesta": "obs 4 Pregunta Probabilidad Recomendación"}]';
    	chorro=chorro.replace('WorkOrder1', WoNumber1);//10000981
    	chorro=chorro.replace('WorkOrder2', WoNumber2);//10000982
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor);
		system.debug('-----------Encuesta inicializada');
    }
    private static void inicializarEncuestaSC3(String WoNumber1,String WoNumber2,Id idCaso){
    	String tipoEncuesta = 'T3_1018_RM';
    	String codMovimiento = '2';
    	String motivoRetirada = '0';
    	Integer duracion = 500;
    	Datetime dt = DateTime.now();
    	String gestor = Label.PERFIL_GESTOR_FRONT_TRAMITACION;
    	String chorro = '[{  "pregunta": "P1_1018_RM",  "respuesta": "1"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_1018_RM",  "respuesta": "7"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_5_1018_RM",  "respuesta": "obs 7 Motivo Puntuación 7 Intervención Profesional Valoración Gremio"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_1018_RM",  "respuesta": "5"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_2_1018_RM",  "respuesta": "M02_ESP_01"},{  "numOrdenTrabajo": "WorkOrder2",  "pregunta": "P2_3_1018_RM",  "respuesta": "obs 5 Motivo Puntuación 5 Demora Valoración Gremio"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_1018_RM",  "respuesta": "0"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_1_1018_RM",  "respuesta": "M04_ESP_02"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_2_1018_RM",  "respuesta": "obs informalidad - Motivos NO Asistencia Profesional"},{  "pregunta": "P4_1018_RM",  "respuesta": "0"},{  "pregunta": "P4_1_1018_RM",  "respuesta": "M05_ESP_02"},{  "pregunta": "P4_2_1018_RM",  "respuesta": "obs Tiempor de espera - Motivos No - Facilidad contactar"},{  "pregunta": "P5_1018_RM",  "respuesta": "0"},{  "pregunta": "P5_1_1018_RM",  "respuesta": "M06_ESP_03"},{  "pregunta": "P5_2_1018_RM",  "respuesta": "obs otros - Motivos No Amables en Trato Telefonico InformacionFacilitadaUtil"},{  "pregunta": "P6_1018_RM",  "respuesta": "0"},{  "pregunta": "P6_1_1018_RM",  "respuesta": "M07_ESP_03"},{  "pregunta": "P6_2_1018_RM",  "respuesta": "obs explicación correcta - Motivos No InformacionFacilitadaUtil"},{  "pregunta": "P7_1018_RM",  "respuesta": "3"},{  "pregunta": "P7_1_1018_RM",  "respuesta": "M08_ESP_01"},{  "pregunta": "P7_2_1018_RM",  "respuesta": "1 - Motivos Atención telefónica Valoracion Global Negativa"},{  "pregunta": "P7_1_1018_RM",  "respuesta": "M08_ESP_03"},{  "pregunta": "P7_2_1018_RM",  "respuesta": "2 - Motivos Intervención Pericial Valoracion Global Negativa"},{  "pregunta": "P7_1_1018_RM",  "respuesta": "M08_ESP_04"},{  "pregunta": "P7_2_1018_RM",  "respuesta": "3- Motivos Intervención de profesionales Valoracion Global Negativa"},{  "pregunta": "P7_1_1018_RM",  "respuesta": "M08_ESP_07"},{  "pregunta": "P7_2_1018_RM",  "respuesta": "4 - Motivos Duración del Siniestro Valoracion Global Negativa"},{  "pregunta": "P8_1018_RM",  "respuesta": "4"},{  "pregunta": "P8_1_1018_RM",  "respuesta": "obs 4 Pregunta Probabilidad Recomendación"}]';
    	chorro=chorro.replace('WorkOrder1', WoNumber1);//10000981
    	chorro=chorro.replace('WorkOrder2', WoNumber2);//10000982
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor);
		system.debug('-----------Encuesta inicializada');
    }
 
 private static void inicializarEncuestaEndCat(String WoNumber1,Id idCaso){
    	String tipoEncuesta = 'T1_5610_AS_CAT';
    	String codMovimiento = '2';
    	String motivoRetirada = '0';
    	Integer duracion = 500;
    	Datetime dt = DateTime.now();
    	String gestor = Label.PERFIL_GESTOR_FRONT_TRAMITACION;
    	String chorro = '[{  "pregunta": "P1_5610_AS_CAT",  "respuesta": "1"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_5610_AS_CAT",  "respuesta": "9"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_6_5610_AS_CAT",  "respuesta": "M03_CAT_06"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_7_5610_AS_CAT",  "respuesta": "obs altres - motivo Puntuación 8-10 Inteverncion Profesional Valoración Gremio"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_5610_AS_CAT",  "respuesta": "0"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_1_5610_AS_CAT",  "respuesta": "M04_CAT_03"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_2_5610_AS_CAT",  "respuesta": "obs altres - Motivos NO Asistencia Profesional"},{  "pregunta": "P4_5610_AS_CAT",  "respuesta": "0"},{  "pregunta": "P4_1_5610_AS_CAT",  "respuesta": "M06_CAT_01"},{  "pregunta": "P4_2_5610_AS_CAT",  "respuesta": "obs no escoltar - Motivos No - Amables en Trato Telefonico"},{  "pregunta": "P5_5610_AS_CAT",  "respuesta": "0"},{  "pregunta": "P5_1_5610_AS_CAT",  "respuesta": "M07_CAT_03"},{  "pregunta": "P5_2_5610_AS_CAT",  "respuesta": "obs explicacio - Motivos No InformacionFacilitadaUtil"},{  "pregunta": "P6_5610_AS_CAT",  "respuesta": "5"},{  "pregunta": "P6_1_5610_AS_CAT",  "respuesta": "M16_CAT_05"},{  "pregunta": "P6_2_5610_AS_CAT",  "respuesta": "obs qualitat Motivos NO Valoracion Global Negativa_M16"},{  "pregunta": "P7_5610_AS_CAT",  "respuesta": "6"},{  "pregunta": "P7_1_5610_AS_CAT",  "respuesta": "obs 6 Pregunta Probabilidad Recomendación"}]';
    	chorro=chorro.replace('WorkOrder1', WoNumber1);
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		system.debug('listaRecepcion '+ listRespuestasEncuestas);
		for(Rest_RecepcionEncuestas_RQ rq : listRespuestasEncuestas){
			system.debug(rq);
		}
		system.debug('RP POST '+Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor));
		for(ENC_Respuesta__c r: [SELECT Id,Name,ENR_LKP_Encuesta_Realizada__c, ENR_LKP_Resp_Pregunta__c, ENR_LKP_WorkOrder__c, ENR_TXT_Gremio__c, ENR_TXT_Num_Orden_Trabajo__c,ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c, ENR_TXT_Pregunta__c, ENR_TXT_Respuesta__c FROM ENC_Respuesta__c]){
			system.debug(r.ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c);
			system.debug(r.ENR_TXT_Respuesta__c);
		}
		
		system.debug('-----------Encuesta inicializada');
    } 
 private static void inicializarEncuestaEndEsp(String WoNumber1,Id idCaso){
    	String tipoEncuesta = 'T1_5610_AS';
    	String codMovimiento = '2';
    	String motivoRetirada = '0';
    	Integer duracion = 500;
    	Datetime dt = DateTime.now();
    	String gestor = Label.PERFIL_GESTOR_FRONT_TRAMITACION;
    	String chorro = '[{  "pregunta": "P1_5610_AS",  "respuesta": "1"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_5610_AS",  "respuesta": "7"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P2_5_5610_AS",  "respuesta": "obs 7 Motivo Puntuación 7 Intervención Profesional Valoración Gremio"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_5610_AS",  "respuesta": "0"},{  "numOrdenTrabajo": "WorkOrder1",  "pregunta": "P3_1_5610_AS",  "respuesta": "M04_ESP_02"},{  "numOrdenTrabajo": "10029985",  "pregunta": "P3_2_5610_AS",  "respuesta": "obs informalidad - Motivos NO Asistencia Profesional"},{  "pregunta": "P4_5610_AS",  "respuesta": "0"},{  "pregunta": "P4_1_5610_AS",  "respuesta": "M06_ESP_01"},{  "pregunta": "P4_2_5610_AS",  "respuesta": "obs no esuchar - Motivos No - Amables en Trato Telefonico"},{  "pregunta": "P5_5610_AS",  "respuesta": "0"},{  "pregunta": "P5_1_5610_AS",  "respuesta": "M07_ESP_01"},{  "pregunta": "P5_2_5610_AS",  "respuesta": "obs ausencia - Motivos No InformacionFacilitadaUtil"},{  "pregunta": "P6_5610_AS",  "respuesta": "3"},{  "pregunta": "P6_1_5610_AS",  "respuesta": "M16_ESP_01"},{  "pregunta": "P6_2_5610_AS",  "respuesta": "1 - Motivos NO Valoracion Global Negativa_M16"},{  "pregunta": "P6_1_5610_AS",  "respuesta": "M16_ESP_02"},{  "pregunta": "P6_2_5610_AS",  "respuesta": "2 - Motivos NO Valoracion Global Negativa_M16"},{  "pregunta": "P6_1_5610_AS",  "respuesta": "M16_ESP_06"},{  "pregunta": "P6_2_5610_AS",  "respuesta": "3- Motivos NO Valoracion Global Negativa_M16"},{  "pregunta": "P6_1_5610_AS",  "respuesta": "M16_ESP_07"},{  "pregunta": "P6_2_5610_AS",  "respuesta": "4 - Motivos NO Valoracion Global Negativa_M16"},{  "pregunta": "P7_5610_AS",  "respuesta": "4"},{  "pregunta": "P7_1_5610_AS",  "respuesta": "obs 4 Pregunta Probabilidad Recomendación"}]';
    	chorro=chorro.replace('WorkOrder1', WoNumber1);
    	List<Rest_RecepcionEncuestas_RQ> listRespuestasEncuestas=(List<Rest_RecepcionEncuestas_RQ>)JSON.deserialize(chorro,List<Rest_RecepcionEncuestas_RQ>.class); 
		Rest_RecepcionEncuestas.doPost(listRespuestasEncuestas,idCaso, tipoEncuesta, codMovimiento, motivoRetirada, duracion, dt, gestor);
		List<ENC_Respuesta__c> respuestas =[SELECT Id,ENR_LKP_Resp_Pregunta__r.ENP_TXT_Identificador__c,ENR_TXT_Respuesta__c FROM ENC_Respuesta__c];
		system.debug('-----------Encuesta inicializada');
    }   
    private static List<ENC_Pregunta__c> creaPreguntasEncuesta(Id encuestaTipoId,String tipo){
    	List<ENC_Pregunta__c> listaPreguntas = new List<ENC_Pregunta__c>();
    	Map<String,Id> mapaPreguntasPadre = new Map<String,Id>();
    	cargarMapaPadres(tipo);
    	ENC_Pregunta__c pregunta;
    	for(String identificador : mapatipoRespuestasPadres.keySet()){
    		pregunta = new ENC_Pregunta__c();
    		pregunta.ENP_TXT_Identificador__c = identificador;
    		pregunta.Name= identificador;
    		pregunta.ENP_SEL_Tipo_Respuesta__c = mapatipoRespuestasPadres.get(identificador);
    		pregunta.ENP_LKP_Encuesta_Tipo__c = encuestaTipoId;
    		listaPreguntas.add(pregunta);
    	}
    	insert listaPreguntas;
    	for (ENC_Pregunta__c p:listaPreguntas){
    		mapaPreguntasPadre.put(p.ENP_TXT_Identificador__c,p.Id);
    	}
    	cargarMapaHijas(tipo);
    	for(String identificador : mapatipoRespuestasHijas.keySet()){
    		pregunta = new ENC_Pregunta__c();
    		pregunta.ENP_TXT_Identificador__c = identificador;
    		pregunta.Name= identificador;
    		pregunta.ENP_SEL_Tipo_Respuesta__c = mapatipoRespuestasHijas.get(identificador);
    		pregunta.ENP_LKP_Encuesta_Tipo__c = encuestaTipoId;
    		if(tipo.right(3)!='CAT'){
    			pregunta.ENP_LKP_Pregunta__c=mapaPreguntasPadre.get(identificador.left(3)+tipo.right(7));
    		}else{
    			pregunta.ENP_LKP_Pregunta__c=mapaPreguntasPadre.get(identificador.left(3)+tipo.right(11));
    		}
    		listaPreguntas.add(pregunta);
    	}
    	return listaPreguntas;
    }
    
    private static void cargarMapaPadres(String tipo){
    	mapatipoRespuestasPadres = new Map<String,String>();
    	if(tipo=='T3_1018_RM'){
	    	mapatipoRespuestasPadres.put('P1_1018_RM','Sí/No');
	    	mapatipoRespuestasPadres.put('P2_1018_RM','Número');
	    	mapatipoRespuestasPadres.put('P3_1018_RM','Sí/No');
	    	mapatipoRespuestasPadres.put('P4_1018_RM','Sí/No');
	    	mapatipoRespuestasPadres.put('P5_1018_RM','Sí/No');
	    	mapatipoRespuestasPadres.put('P6_1018_RM','Sí/No');
	    	mapatipoRespuestasPadres.put('P7_1018_RM','Número');
	    	mapatipoRespuestasPadres.put('P8_1018_RM','Número');
    	}else if(tipo == 'T1_1023_MA'){
    		mapatipoRespuestasPadres.put('P1_1023_MA','Sí/No');
	    	mapatipoRespuestasPadres.put('P2_1023_MA','Número');
	    	mapatipoRespuestasPadres.put('P3_1023_MA','Sí/No');
	    	mapatipoRespuestasPadres.put('P4_1023_MA','Sí/No');
	    	mapatipoRespuestasPadres.put('P5_1023_MA','Sí/No');
	    	mapatipoRespuestasPadres.put('P6_1023_MA','Sí/No');
	    	mapatipoRespuestasPadres.put('P7_1023_MA','Número');
	    	mapatipoRespuestasPadres.put('P8_1023_MA','Número');
    	}
    	else if(tipo == 'T1_5610_AS'){
    		mapatipoRespuestasPadres.put('P1_5610_AS','Sí/No');
	    	mapatipoRespuestasPadres.put('P2_5610_AS','Número');
	    	mapatipoRespuestasPadres.put('P3_5610_AS','Sí/No');
	    	mapatipoRespuestasPadres.put('P4_5610_AS','Sí/No');
	    	mapatipoRespuestasPadres.put('P5_5610_AS','Sí/No');
	    	mapatipoRespuestasPadres.put('P6_5610_AS','Número');
	    	mapatipoRespuestasPadres.put('P7_5610_AS','Número');
    	}
    	else if(tipo == 'T1_5610_AS_CAT'){
    		mapatipoRespuestasPadres.put('P1_5610_AS_CAT','Sí/No');
	    	mapatipoRespuestasPadres.put('P2_5610_AS_CAT','Número');
	    	mapatipoRespuestasPadres.put('P3_5610_AS_CAT','Sí/No');
	    	mapatipoRespuestasPadres.put('P4_5610_AS_CAT','Sí/No');
	    	mapatipoRespuestasPadres.put('P5_5610_AS_CAT','Sí/No');
	    	mapatipoRespuestasPadres.put('P6_5610_AS_CAT','Número');
	    	mapatipoRespuestasPadres.put('P7_5610_AS_CAT','Número');
    	}
    }
    private static void cargarMapaHijas(String tipo){
    	mapatipoRespuestasHijas = new Map<String,String>();
    	if(tipo=='T3_1018_RM'){
	    	mapatipoRespuestasHijas.put('P1_1_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P1_2_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P1_3_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P2_1_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P2_2_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_3_1018_RM','Sí/No');
	    	mapatipoRespuestasHijas.put('P2_4_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P2_5_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P2_6_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_7_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P3_1_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P3_2_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P3_3_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P4_1_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P4_2_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P4_3_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P5_1_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P5_2_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P5_3_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P6_1_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_2_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P6_3_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P7_1_1018_RM','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P7_2_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P7_3_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P8_1_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P2_8_1018_RM','Texto');
	    	mapatipoRespuestasHijas.put('P1_4_1018_RM','Lista de Opciones');
    	}else if(tipo=='T1_1023_MA'){
    		mapatipoRespuestasHijas.put('P1_1_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P1_2_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P1_3_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P1_4_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_1_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P2_2_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_3_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P2_4_1023_MA','Sí/No');
	    	mapatipoRespuestasHijas.put('P2_5_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P2_6_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_7_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P2_8_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P3_1_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P3_2_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P3_3_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P4_1_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P4_2_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P4_3_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P5_1_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P5_2_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P5_3_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P6_1_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_2_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P6_3_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P7_1_1023_MA','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P7_2_1023_MA','Texto');
	    	mapatipoRespuestasHijas.put('P8_1_1023_MA','Texto');
	    	
    	}else if(tipo=='T1_5610_AS'){
    		mapatipoRespuestasHijas.put('P1_1_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P1_2_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P1_3_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P1_4_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P1_5_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P1_6_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P1_7_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P1_8_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P2_1_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P2_2_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_3_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P2_4_5610_AS','Sí/No');
	    	mapatipoRespuestasHijas.put('P2_5_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P2_6_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_7_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P2_8_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P3_1_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P3_2_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P3_3_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P4_1_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P4_2_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P4_3_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P5_1_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P5_2_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P5_3_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P5_4_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P5_5_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P5_6_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P5_7_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P5_8_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P6_1_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_2_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P6_3_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_4_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P6_5_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_6_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P6_7_5610_AS','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_8_5610_AS','Texto');
	    	mapatipoRespuestasHijas.put('P7_1_5610_AS','Texto');
    	}else if(tipo=='T1_5610_AS_CAT'){
    		mapatipoRespuestasHijas.put('P1_1_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P1_2_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P1_3_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P1_4_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P1_5_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P1_6_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P1_7_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P1_8_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P2_1_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P2_2_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_3_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P2_4_5610_AS_CAT','Sí/No');
	    	mapatipoRespuestasHijas.put('P2_5_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P2_6_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P2_7_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P2_8_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P3_1_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P3_2_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P3_3_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P4_1_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P4_2_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P4_3_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P5_1_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P5_2_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P5_3_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P5_4_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P5_5_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P5_6_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P5_7_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P5_8_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P6_1_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_2_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P6_3_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_4_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P6_5_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_6_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P6_7_5610_AS_CAT','Lista de Opciones');
	    	mapatipoRespuestasHijas.put('P6_8_5610_AS_CAT','Texto');
	    	mapatipoRespuestasHijas.put('P7_1_5610_AS_CAT','Texto');
    	}
    }
}