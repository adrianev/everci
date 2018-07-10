@isTest
public without sharing class Test_Util_Telef_TransferCIA {

    static testMethod void util_Telef_TransferCIA(){
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1234567X');
		insert compania;
        List<SelectOption> opList = Util_Telef_TransferCIA.buscarTelefonos(compania.Id);
    }
}