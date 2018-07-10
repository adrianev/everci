@isTest
public without sharing class Test_Util_Indemnizables {

    @isTest static void test_Util_Indemnizables_1(){
    
        //Test unitario de implementaciones de Util_Indemnizables
        
        
        Account compania = Util_Tests.crearCuentaCompania('compania', Label.IDE_MEMBERSHIP,'X1254567X');
        insert compania;
        Account compania2 = Util_Tests.crearCuentaCompania('compania', '1018','X2345671X');
        insert compania2;
        Account cuenta = Util_Tests.crearCuentaAsegurado('alejandro','2018', 'miguel@gmail.es', '73661110E','asdad', 'Apellido', 'Apellido2');
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
        insert cuenta;
        
        Tipo_Producto_CIA__c tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
        insert tipoProducto;
        system.debug('ARL TIPO PRODUCTO CREADO'+tipoProducto );
        
        Producto_CIA__c producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
        insert producto;
        system.debug('ARL PRODUCTO CREADO: '+producto );
        
        Procedencia__c procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Siniestro;CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        insert procedencia;
        system.debug('ARL PROCEDENCIA CREADA: '+procedencia );
        
		ServiceContract sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        insert sv;
        system.debug('ARL Service Contract CREADO: '+sv );
        
        
        Test.startTest();
        
        
        
        //Creamos tres casos Indemnizables
        Case caso = new Case();
        caso = Util_Tests.crearCasoSini(sv.Id, cuenta.Id, compania.Id);
        //Set del campo tipo para que sea indemnizable.
        caso.Type = label.CAS_TIPO_INDEMNIZABLE;
        caso.CAS_LKP_Compania__c = compania.Id;
        caso.CAS_SEL_Sondeo_DocsIndemnizable__c ='02;03;04;05';
        caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso.CAS_LKP_Procedencia__c = procedencia.Id;
        caso.CreatedDate = system.now();
        caso.Status = '993';
        caso.OwnerId = system.UserInfo.getUserId();
        caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso;
        
        Case caso2 = new Case();
        caso2 = Util_Tests.crearCasoSini(sv.Id, cuenta.Id, compania.Id);
        caso2.Type = label.CAS_TIPO_INDEMNIZABLE;
        caso2.CAS_LKP_Compania__c = compania.Id;
        caso2.CAS_SEL_Sondeo_DocsIndemnizable__c ='02;03;04;05';
        caso2.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso2.CAS_LKP_Procedencia__c = procedencia.Id;
        caso2.CreatedDate = system.now();
        caso2.Status = '993';
        caso2.OwnerId = system.UserInfo.getUserId();
        caso2.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso2;
        
        Case caso3= new Case();
        caso3 = Util_Tests.crearCasoSini(sv.Id, cuenta.Id, compania.Id);
        caso3.Type = label.CAS_TIPO_INDEMNIZABLE;
        caso3.CAS_LKP_Compania__c = compania.Id;
        caso3.CAS_SEL_Sondeo_DocsIndemnizable__c ='02;03;04;05';
        caso3.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';        
        caso3.CAS_LKP_Procedencia__c = procedencia.Id;
        caso3.CreatedDate = system.now();
        caso3.Status = '993';
        caso3.OwnerId = system.UserInfo.getUserId();
        caso3.CAS_SEL_DirRiesgo_Estado_Provincia__c = '43';
        insert caso3;
       
        Util_variablesGlobales.faseVueltaSondeo = 'valor';
        
        List <Case> listaNuevosCasos = new List <Case>{caso,caso2,caso3};
        system.debug('ARL LISTA CASOS (TRAS CREACION):'+listaNuevosCasos);
        
        //1.Comprobamos la creación de documentos indemnizables 
        List <Indemnizable_Documento__c> docsIndem = new List<Indemnizable_Documento__c>();
        docsIndem=Util_Indemnizables.generarDocsIndemnizables(listaNuevosCasos);
        insert docsIndem;
        
        system.debug('ARL DOCUMENTOS INDEMNIZABLES (TRAS CREACION):'+docsIndem);
        
         if(!docsIndem.isEmpty()){
        
        //Búsqueda de documentos por id
        Map <Id,Indemnizable_Documento__c> mapaDocumentos = Util_Indemnizables.queryMapDocs(new Set<Id> {docsIndem[0].Id, docsIndem[1].Id,docsIndem[2].Id}) ;
       
       system.debug('ARL (TRAS QUERY BY ID):'+mapaDocumentos);
       
      
         Map <Id,Indemnizable_Documento__c> mapaDocumentos2 = Util_Indemnizables.queryMapDocByCase(new Set<Id>{ caso.Id, caso2.Id, caso3.Id});
         system.debug('ARL (TRAS QUERY BY CASE):'+mapaDocumentos);
        //Util_Indemnizables.queryMapPartidas();
        //Util_IndemnizablesqueryMapPartidasByDoc();
        
        //Util_Indemnizables.crearDocumentoIndemnizable();
         }
       
        
        
        
        Test.stopTest();
        
        
        
        
        
    }
}