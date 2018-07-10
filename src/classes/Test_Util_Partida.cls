@isTest
public without sharing class Test_Util_Partida {

    static testMethod void util_Partida(){
        Util_Partida.estadosValidos(Label.PAR_ESTADO_PDTE_CLIENTE);
        Util_Partida.estadosValidos(Label.PAR_ESTADO_ACEPTADA_CLIENTE);
        Util_Partida.estadosValidos(Label.PAR_ESTADO_ACEPTADA_GEST);
        Util_Partida.estadosValidos(Label.PAR_ESTADO_RECHAZADA_CIA);
        Util_Partida.estadosValidos(Label.PAR_ESTADO_RECHAZADA_CLIENTE);
    }
}