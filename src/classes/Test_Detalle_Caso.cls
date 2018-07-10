@isTest
public without sharing class Test_Detalle_Caso {

    @isTest static void Test_Detalle_Caso(){
        DetalleCasoController detalle = new DetalleCasoController(); 
        detalle.caso = new Case();
        detalle.tipoActuacion = 'serafin';
    }
}