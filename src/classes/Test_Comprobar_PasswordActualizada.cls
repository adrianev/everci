@isTest
public without sharing class Test_Comprobar_PasswordActualizada {

    @isTest static void comprobar_PasswordActualizada(){
        //CREAMOS LA ASEGURADORA
			Account compania = Util_Tests.crearCuentaCompania('companiaPrueba_Batch_Albaranes','1996','X1234567X');
			
			insert compania ;
			system.debug('INSERT 1: '+ compania);
			
			//CREAMOS UNA CUENTA DEL USUARIO QUE VA A ESTAR ASEGURADO
			Account cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Alejandro','04626393N','coredamnwork@gmail.com',
				'04626393N','Alejandro', 'Rey', 'Lopez');
			cuentaAsegurado.CUE_LKP_Cuenta_Principal__c = compania.Id;	
			insert cuentaAsegurado ;
			system.debug('INSERT 2: '+ cuentaAsegurado);
			
			//CREAMOS UN TIPO DE PRODUCTO		(Representa el tipo de seguro)
			Tipo_Producto_CIA__c tipoProductoCia = Util_Tests.crearTipoProductoCIA('HOGAR', '01', compania.Id);
				
			insert tipoProductoCia ;
			system.debug('INSERT 3: '+tipoProductoCia);
			
			//CREAMOS UN PRODUCTO CIA (un seguro concreto, de un tipo concreto.)
			Producto_CIA__c productoCia = Util_Tests.crearProductoCIA('TODO RIESGO','2020202',tipoProductoCia.Id)	;
				
			insert productoCia;
			system.debug('INSERT 4'+ productoCia );
			
			//CREAMOS UNA POLIZA COMO TAL, ASOCIADA A cuentaAsegurado y compania
				
        	ServiceContract poliza = Util_Tests.crearPolizaContrato('Alberto', cuentaAsegurado.Id, compania.Id, productoCia.Id);
        	insert poliza;
        	
			//CREAMOS UN CASO
			Case caso = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,compania.Id);
			
			insert caso;
  		Comprobar_PasswordActualizada.comprobarPass();      
    }
}