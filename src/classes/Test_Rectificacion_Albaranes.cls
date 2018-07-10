@isTest
private class Test_Rectificacion_Albaranes {

	public static Boolean variableControl;
	public static Account compania;
	public static Account cuentaAsegurado;
	public static Tipo_Producto_CIA__c tipoProductoCia;
	public static Producto_CIA__c productoCia;
	public static ServiceContract poliza;
	public static Case caso;
	public static WorkType  tipoTrabajo;
	public static WorkOrder wO;
    public static WorkOrder wO2;

	 private static void inicialize(){
        
        variableControl = Baipas.establecerVariableControl();

			//CREAMOS LA ASEGURADORA
			compania = Util_Tests.crearCuentaCompania('companiaPrueba_Batch_Albaranes','1996','X1234567X');
			
			insert compania ;
			system.debug('INSERT 1: '+ compania);
			
			//CREAMOS UNA CUENTA DEL USUARIO QUE VA A ESTAR ASEGURADO
			cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Alejandro','04626393N','coredamnwork@gmail.com',
				'04626393N','Alejandro', 'Rey', 'Lopez');
			cuentaAsegurado.CUE_LKP_Cuenta_principal__c=compania.Id;
			insert cuentaAsegurado ;
			system.debug('INSERT 2: '+ cuentaAsegurado);
			
			//CREAMOS UN TIPO DE PRODUCTO		(Representa el tipo de seguro)
			tipoProductoCia = Util_Tests.crearTipoProductoCIA('HOGAR', '01', compania.Id);
				
			insert tipoProductoCia ;
			system.debug('INSERT 3: '+tipoProductoCia);
			
			//CREAMOS UN PRODUCTO CIA (un seguro concreto, de un tipo concreto.)
			productoCia = Util_Tests.crearProductoCIA('TODO RIESGO','2020202',tipoProductoCia.Id)	;
				
			insert productoCia;
			system.debug('INSERT 4'+ productoCia );
			
			//CREAMOS UNA POLIZA COMO TAL, ASOCIADA A cuentaAsegurado y compania
			poliza = Util_Tests.crearPolizaContrato('Poliza_Batch_Albaranes', compania.Id, cuentaAsegurado.Id,productoCia.Id);
			
			insert poliza;			
			//CREAMOS UN CASO
			caso = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,compania.Id);
			
			insert caso;	
			system.debug('INSERT 6: '+caso);
			
			tipoTrabajo = Util_Tests.crearTipoTrabajo('Siniestro', '21', 2.5);
			
			insert tipoTrabajo;	
			system.debug('INSERT 7: '+ tipoTrabajo);
			
			wO = Util_Tests.crearOrdenTrabajo('0WO9E0000003T9t', '21', tipoTrabajo.Id,caso.Id);
			
			//OTR_ESTADO_CERRADO_PDTE_ALBARAN a OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO
			wO.Status = Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN;
			
			
			insert wO;
         
         	wO2 = Util_Tests.crearOrdenTrabajo('0WO9E0000003T9h', '21', tipoTrabajo.Id,caso.Id);
         	wO2.Status = Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN;
         	wO2.ParentWorkOrderId = wO.Id;
			
         	insert wO2;
         
         	
        
       
        
    }

   @istest static void testMethod1() {
   	inicialize();
   	ApexPages.StandardController sc = new ApexPages.StandardController(wO2);
   	Rectificacion_Albaranes rectificacion = new Rectificacion_Albaranes(sc);

        
    }

     @istest static void testMethod2() {
   	inicialize();
   	ApexPages.currentPage().getParameters().put('id',wO2.Id);
   	ApexPages.StandardController sc = new ApexPages.StandardController(wO2);
   	Rectificacion_Albaranes rectificacion = new Rectificacion_Albaranes(sc);
   	rectificacion.volver();
   	rectificacion.aceptar();

        
    }

    @istest static void testMethod3() {
   	inicialize();
   	ApexPages.currentPage().getParameters().put('id',wO2.Id);
   	ApexPages.StandardController sc = new ApexPages.StandardController(wO2);
   	Rectificacion_Albaranes rectificacion = new Rectificacion_Albaranes(sc);
   	rectificacion.penalizacion = '40,00€';
   	rectificacion.motivo = 'No aceptado por perito/compañía';
   	rectificacion.comentario = 'kfgjñsldfkgj';
   	rectificacion.volver();
   	rectificacion.aceptar();

        
    }
}