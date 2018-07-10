@isTest
public without sharing class Test_Detalle_B2B_B2B2C {

    @isTest static void test_Detalle_B2B_B2B2C(){
        Detalle_B2B_B2B2C detalle = new Detalle_B2B_B2B2C();
        detalle.caso = new Case();
        detalle.cuenta = new Account();
        detalle.esB2C = true;
    }
}