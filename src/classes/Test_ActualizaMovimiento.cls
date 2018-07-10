@isTest
public without sharing class Test_ActualizaMovimiento {
	private static Account compania;
	private static Account cuentaPrincipal;
	private static Account cuenta;
	private static Tipo_Producto_CIA__c tipoProductoCIA;
	private static Producto_CIA__c productoCIA;
	private static ServiceContract poliza;
	private static Case caso;
	private static WorkType tipoTrabajo;
	private static WorkOrder ordenTrabajo;
	
	@testSetup 
    static void setup() {
		Baipas.establecerVariableControl();
		compania = Util_Tests.crearCuentaCompania('SegurCaixa','1018','X1234567X');
		insert compania;
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1245678','X1134567X');
		insert cuentaPrincipal;
		cuenta = Util_Tests.crearCuentaB2BSec('Asegurado','19783886E',cuentaPrincipal.Id,'X1114567X');
		insert cuenta;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		system.debug('@@@@@@@@@@@ '+tipoProductoCIA);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuenta.Id,productoCIA.Id);
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuenta.Id, compania.Id);
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('18210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = '1516201877423';
		ordenTrabajo.AccountId = cuenta.Id;
		insert ordenTrabajo;
		Baipas.deshabilitarVariableControl();
    }
	
    static testmethod void testNN006() {
		
		test.startTest();
		ActualizaMovimiento_RP resultado = new ActualizaMovimiento_RP();
		List<ActualizaMovimiento_RQ.Registro> listMov = new List<ActualizaMovimiento_RQ.Registro>();
		ActualizaMovimiento_RQ.Registro registros = new ActualizaMovimiento_RQ.Registro();
		registros.error='';
		registros.numSiniestro='12345678';
		registros.registro='000189950003273820171361410712132726422223   VP18-410559201712052100290PH2   01MOB08000000000420720000000034770                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ';
		system.debug('registros: '+ registros);
		listMov.add(registros);
		system.debug('listMov: '+ listMov);
		ActualizaMovimiento_RQ registro1 = new ActualizaMovimiento_RQ('false','NN-006','1',listMov);

		system.debug('Registro: ' + registro1);
        
        resultado = ActualizaMovimiento.actualizarMovimiento(registro1);
        
        test.stopTest();
        List<INT_Movimiento_CIA__c> listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id,MOV_TXT_Num_Poliza__c FROM INT_Movimiento_CIA__c]);
        System.debug('Movimientos: '+ listMovimientos);
		List<INT_Perjudicados__c> listPerjudicados = new List<INT_Perjudicados__c>([SELECT Id,IPE_TXT_Tipo_Perjudicado__c, IPE_LKP_Movimiento_CIA__c FROM INT_Perjudicados__c]);
		System.debug('Perjudicados: '+ listPerjudicados);
		List<INT_Comentarios__c> listComentarios = new List<INT_Comentarios__c>([SELECT Id,ICC_TXT_Comentario_Sin_Rep__c,ICC_TXT_Comentario_Sin_Indem__c, ICC_LKP_Movimiento_CIA__c FROM INT_Comentarios__c]);
		System.debug('Comentarios: '+ listComentarios);
		List<INT_Contactos_Telefonicos__c> listContactos = new List<INT_Contactos_Telefonicos__c>([SELECT Id,ICT_TFN_Telefono__c, ICT_LKP_Movimiento_CIA__c FROM INT_Contactos_Telefonicos__c]);
		System.debug('Teléfonos: '+ listContactos);
		List<INT_Garantias_Siniestros__c> listGarantiasInsertar = new List<INT_Garantias_Siniestros__c>([SELECT Id,IGS_TXT_Codigo_Garantia__c, IGS_LKP_Movimiento_CIA__c FROM INT_Garantias_Siniestros__c]);
    	System.debug('Garantias: '+ listGarantiasInsertar);
    }
    
    /*static testmethod void testStiga() {
		//Pendiente de meter un movimiento de SC real
		test.startTest();
		ActualizaMovimiento_RP resultado = new ActualizaMovimiento_RP();
		List<ActualizaMovimiento_RQ.Registro> listMov = new List<ActualizaMovimiento_RQ.Registro>();
		ActualizaMovimiento_RQ.Registro registros = new ActualizaMovimiento_RQ.Registro();
        
        
		registros.error='';
		registros.numSiniestro='';
		registros.registro='900001#asp2401671|Canal Digital|900001|Canal Digital |RP4316357|14/02/2017|72051799K|Javier|FERNANDEZ MENDIOLEA|C/ ZURBANO 98 7 Derecha |28003|MADRID|javier.fernandezm@iese.net|650424010||||07/11/2017|||0SARIASG|asp2401671|0SGARCIAG|No|1516201877423|Carpintero madera|07/11/2017|10/11/2017|Anulado|PR9|A4|0|NO';
		listMov.add(registros);
		ActualizaMovimiento_RQ registro1 = new ActualizaMovimiento_RQ('false','Stiga','1',listMov);
        
        resultado = ActualizaMovimiento.actualizarMovimiento(registro1);
        
        test.stopTest();
        List<INT_Movimiento_CIA__c> listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id,MOV_TXT_Num_Poliza__c FROM INT_Movimiento_CIA__c]);
        System.debug('Movimientos: '+ listMovimientos);
		List<INT_Perjudicados__c> listPerjudicados = new List<INT_Perjudicados__c>([SELECT Id,IPE_TXT_Tipo_Perjudicado__c, IPE_LKP_Movimiento_CIA__c FROM INT_Perjudicados__c]);
		System.debug('Perjudicados: '+ listPerjudicados);
		List<INT_Comentarios__c> listComentarios = new List<INT_Comentarios__c>([SELECT Id,ICC_TXT_Comentario_Sin_Rep__c,ICC_TXT_Comentario_Sin_Indem__c, ICC_LKP_Movimiento_CIA__c FROM INT_Comentarios__c]);
		System.debug('Comentarios: '+ listComentarios);
		List<INT_Contactos_Telefonicos__c> listContactos = new List<INT_Contactos_Telefonicos__c>([SELECT Id,ICT_TFN_Telefono__c, ICT_LKP_Movimiento_CIA__c FROM INT_Contactos_Telefonicos__c]);
		System.debug('Teléfonos: '+ listContactos);
		List<INT_Garantias_Siniestros__c> listGarantiasInsertar = new List<INT_Garantias_Siniestros__c>([SELECT Id,IGS_TXT_Codigo_Garantia__c, IGS_LKP_Movimiento_CIA__c FROM INT_Garantias_Siniestros__c]);
    	System.debug('Garantias: '+ listGarantiasInsertar);
    }*/

    static testmethod void testsiniSC() {
		//Pendiente de meter un movimiento de SC real
		test.startTest();
		ActualizaMovimiento_RP resultado = new ActualizaMovimiento_RP();
		List<ActualizaMovimiento_RQ.Registro> listMov = new List<ActualizaMovimiento_RQ.Registro>();
		ActualizaMovimiento_RQ.Registro registros = new ActualizaMovimiento_RQ.Registro();
		registros.error='';
		registros.numSiniestro='';
		registros.registro='100001#asp2401671|Canal Digital|900001|Canal Digital |RP4316357|14/02/2017|72051799K|Javier|FERNANDEZ MENDIOLEA|C/ ZURBANO 98 7 Derecha |28003|MADRID|javier.fernandezm@iese.net|650424010||||07/11/2017|||0SARIASG|asp2401671|0SGARCIAG|No|1516201877423|Carpintero madera|07/11/2017|10/11/2017|Anulado|PR9|A4|0|NO';
		listMov.add(registros);
		ActualizaMovimiento_RQ registro1 = new ActualizaMovimiento_RQ('false','siniSC','1',listMov);
        
        //resultado = ActualizaMovimiento.actualizarMovimiento(registro1);
        
        test.stopTest();
        List<INT_Movimiento_CIA__c> listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id,MOV_TXT_Num_Poliza__c FROM INT_Movimiento_CIA__c]);
        System.debug('Movimientos: '+ listMovimientos);
		List<INT_Perjudicados__c> listPerjudicados = new List<INT_Perjudicados__c>([SELECT Id,IPE_TXT_Tipo_Perjudicado__c, IPE_LKP_Movimiento_CIA__c FROM INT_Perjudicados__c]);
		System.debug('Perjudicados: '+ listPerjudicados);
		List<INT_Comentarios__c> listComentarios = new List<INT_Comentarios__c>([SELECT Id,ICC_TXT_Comentario_Sin_Rep__c,ICC_TXT_Comentario_Sin_Indem__c, ICC_LKP_Movimiento_CIA__c FROM INT_Comentarios__c]);
		System.debug('Comentarios: '+ listComentarios);
		List<INT_Contactos_Telefonicos__c> listContactos = new List<INT_Contactos_Telefonicos__c>([SELECT Id,ICT_TFN_Telefono__c, ICT_LKP_Movimiento_CIA__c FROM INT_Contactos_Telefonicos__c]);
		System.debug('Teléfonos: '+ listContactos);
		List<INT_Garantias_Siniestros__c> listGarantiasInsertar = new List<INT_Garantias_Siniestros__c>([SELECT Id,IGS_TXT_Codigo_Garantia__c, IGS_LKP_Movimiento_CIA__c FROM INT_Garantias_Siniestros__c]);
    	System.debug('Garantias: '+ listGarantiasInsertar);
    }
    
    
    
    /////////////////////////////////////////////////////////////////////////NUEVOOOOOOOOOOOOO ALBERTO ///////////////////
    //
    //
    //
    //
     static testmethod void testNN005() {
		
		test.startTest();
		ActualizaMovimiento_RP resultado = new ActualizaMovimiento_RP();
		List<ActualizaMovimiento_RQ.Registro> listMov = new List<ActualizaMovimiento_RQ.Registro>();
		ActualizaMovimiento_RQ.Registro registros = new ActualizaMovimiento_RQ.Registro();
		registros.error='';
		registros.numSiniestro='12345678';
		registros.registro='000189950003273820171361410712132726422223   VP18-410559201712052100290PH2   01MOB08000000000420720000000034770                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ';
		system.debug('registros: '+ registros);
		listMov.add(registros);
		system.debug('listMov: '+ listMov);
		ActualizaMovimiento_RQ registro1 = new ActualizaMovimiento_RQ('true','NN-006','1',listMov);

		system.debug('Registro: ' + registro1);
        
        resultado = ActualizaMovimiento.actualizarMovimiento(registro1);
        
        test.stopTest();
        List<INT_Movimiento_CIA__c> listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id,MOV_TXT_Num_Poliza__c FROM INT_Movimiento_CIA__c]);
        System.debug('Movimientos: '+ listMovimientos);
		List<INT_Perjudicados__c> listPerjudicados = new List<INT_Perjudicados__c>([SELECT Id,IPE_TXT_Tipo_Perjudicado__c, IPE_LKP_Movimiento_CIA__c FROM INT_Perjudicados__c]);
		System.debug('Perjudicados: '+ listPerjudicados);
		List<INT_Comentarios__c> listComentarios = new List<INT_Comentarios__c>([SELECT Id,ICC_TXT_Comentario_Sin_Rep__c,ICC_TXT_Comentario_Sin_Indem__c, ICC_LKP_Movimiento_CIA__c FROM INT_Comentarios__c]);
		System.debug('Comentarios: '+ listComentarios);
		List<INT_Contactos_Telefonicos__c> listContactos = new List<INT_Contactos_Telefonicos__c>([SELECT Id,ICT_TFN_Telefono__c, ICT_LKP_Movimiento_CIA__c FROM INT_Contactos_Telefonicos__c]);
		System.debug('Teléfonos: '+ listContactos);
		List<INT_Garantias_Siniestros__c> listGarantiasInsertar = new List<INT_Garantias_Siniestros__c>([SELECT Id,IGS_TXT_Codigo_Garantia__c, IGS_LKP_Movimiento_CIA__c FROM INT_Garantias_Siniestros__c]);
    	System.debug('Garantias: '+ listGarantiasInsertar);
    }
    
        
    static testmethod void testNN007Error() {
	
		test.startTest();
		ActualizaMovimiento_RP resultado = new ActualizaMovimiento_RP();
		List<ActualizaMovimiento_RQ.Registro> listMov = new List<ActualizaMovimiento_RQ.Registro>();
		ActualizaMovimiento_RQ.Registro registros = new ActualizaMovimiento_RQ.Registro();
		registros.error='';
		registros.numSiniestro='12345678';
		registros.registro='000189950003273820171361410712132726422223   VP18-410559201712052100290PH2   01MOB08000000000420720000000034770                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ';
		system.debug('registros: '+ registros);
		listMov.add(registros);
		system.debug('listMov: '+ listMov);
		ActualizaMovimiento_RQ registro1 = new ActualizaMovimiento_RQ('error','NN-007','1',listMov);

		system.debug('Registro: ' + registro1);
        
        resultado = ActualizaMovimiento.actualizarMovimiento(registro1);
        
        test.stopTest();
        List<INT_Movimiento_CIA__c> listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id,MOV_TXT_Num_Poliza__c FROM INT_Movimiento_CIA__c]);
        System.debug('Movimientos: '+ listMovimientos);
		List<INT_Perjudicados__c> listPerjudicados = new List<INT_Perjudicados__c>([SELECT Id,IPE_TXT_Tipo_Perjudicado__c, IPE_LKP_Movimiento_CIA__c FROM INT_Perjudicados__c]);
		System.debug('Perjudicados: '+ listPerjudicados);
		List<INT_Comentarios__c> listComentarios = new List<INT_Comentarios__c>([SELECT Id,ICC_TXT_Comentario_Sin_Rep__c,ICC_TXT_Comentario_Sin_Indem__c, ICC_LKP_Movimiento_CIA__c FROM INT_Comentarios__c]);
		System.debug('Comentarios: '+ listComentarios);
		List<INT_Contactos_Telefonicos__c> listContactos = new List<INT_Contactos_Telefonicos__c>([SELECT Id,ICT_TFN_Telefono__c, ICT_LKP_Movimiento_CIA__c FROM INT_Contactos_Telefonicos__c]);
		System.debug('Teléfonos: '+ listContactos);
		List<INT_Garantias_Siniestros__c> listGarantiasInsertar = new List<INT_Garantias_Siniestros__c>([SELECT Id,IGS_TXT_Codigo_Garantia__c, IGS_LKP_Movimiento_CIA__c FROM INT_Garantias_Siniestros__c]);
    	System.debug('Garantias: '+ listGarantiasInsertar);
    }
    

    
        
    static testmethod void testTipoDeRegistro() {
	
		test.startTest();
		ActualizaMovimiento_RP resultado = new ActualizaMovimiento_RP();
		List<ActualizaMovimiento_RQ.Registro> listMov = new List<ActualizaMovimiento_RQ.Registro>();
		ActualizaMovimiento_RQ.Registro registros = new ActualizaMovimiento_RQ.Registro();
		registros.error='';
		registros.numSiniestro='12345678';
		registros.registro='000189950003273820171361410712132726422223   VP18-410559201712052100290PH2   01MOB08000000000420720000000034770                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ';
		system.debug('registros: '+ registros);
		listMov.add(registros);
		system.debug('listMov: '+ listMov);
		ActualizaMovimiento_RQ registro1 = new ActualizaMovimiento_RQ('false','siniSC','4',listMov);

		system.debug('Registro: ' + registro1);
        
        resultado = ActualizaMovimiento.actualizarMovimiento(registro1);
        
        test.stopTest();
        List<INT_Movimiento_CIA__c> listMovimientos = new List<INT_Movimiento_CIA__c>([SELECT Id,MOV_TXT_Num_Poliza__c FROM INT_Movimiento_CIA__c]);
        System.debug('Movimientos: '+ listMovimientos);
		List<INT_Perjudicados__c> listPerjudicados = new List<INT_Perjudicados__c>([SELECT Id,IPE_TXT_Tipo_Perjudicado__c, IPE_LKP_Movimiento_CIA__c FROM INT_Perjudicados__c]);
		System.debug('Perjudicados: '+ listPerjudicados);
		List<INT_Comentarios__c> listComentarios = new List<INT_Comentarios__c>([SELECT Id,ICC_TXT_Comentario_Sin_Rep__c,ICC_TXT_Comentario_Sin_Indem__c, ICC_LKP_Movimiento_CIA__c FROM INT_Comentarios__c]);
		System.debug('Comentarios: '+ listComentarios);
		List<INT_Contactos_Telefonicos__c> listContactos = new List<INT_Contactos_Telefonicos__c>([SELECT Id,ICT_TFN_Telefono__c, ICT_LKP_Movimiento_CIA__c FROM INT_Contactos_Telefonicos__c]);
		System.debug('Teléfonos: '+ listContactos);
		List<INT_Garantias_Siniestros__c> listGarantiasInsertar = new List<INT_Garantias_Siniestros__c>([SELECT Id,IGS_TXT_Codigo_Garantia__c, IGS_LKP_Movimiento_CIA__c FROM INT_Garantias_Siniestros__c]);
    	System.debug('Garantias: '+ listGarantiasInsertar);
    }
    
   
    
}