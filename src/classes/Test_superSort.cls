@isTest
public class Test_superSort {

    @isTest static void superSort(){
        Account compania = Util_Tests.crearCuentaCompania('SegurCaixa', '1018','X1134567X');
		insert compania;
        
        Account cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
		cuenta.Type = Label.CUE_TIPO_CONTABLE;
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
		insert cuenta;
        
        Account asegurado = Util_Tests.crearCuentaAsegurado('Miguel', '2018', 'miguel@gmail.es', '03629033R','Miguel', 'Sagrado', 'Velasco');
		asegurado.CUE_SEL_Tipo_Documento__c = 'N';
        asegurado.Type = '01';
        asegurado.CUE_LKP_Cuenta_Principal__c = compania.id;
        asegurado.CUE_LKP_Cliente_contable__c = cuenta.Id;
        insert asegurado;
        ServiceContract poliza = Util_Tests.crearPolizaContrato('9729187', compania.Id, asegurado.Id,null);
		insert poliza;
        Case caso = Util_tests.crearCasoB2B(poliza.Id,asegurado.Id,compania.Id);
        Insert caso; 
        List<Case> MyRecentCases = new List<Case>();
        MyRecentCases.add(caso);
        superSort.sortList(MyRecentCases, 'CaseNumber', 'desc');
        superSort.sortList(MyRecentCases, 'CAS_LKP_Compania__c', 'desc');
    }
}