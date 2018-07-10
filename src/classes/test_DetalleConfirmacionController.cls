@isTest
public class test_DetalleConfirmacionController {
    
@isTest static void Test_Confirmacion_Controller(){
        DetalleConfirmacionController detalle = new DetalleConfirmacionController(); 
        detalle.caso = new Case();
        detalle.tipoActuacion = 'serafin';
    	detalle.confirmacion = null;
    }
}