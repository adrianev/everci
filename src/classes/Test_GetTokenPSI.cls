/**
 * Clase de Test de la Clase GetTokenPSI
 *
 **/
@isTest
public without sharing class Test_GetTokenPSI {

    @isTest
    public static void testOK(){
        test.startTest();

        GetTokenPSI aux = new GetTokenPSI();
        String resultado = aux.getToken();

        test.stopTest();
    }
}