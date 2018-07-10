@isTest
public without sharing class Test_B2B_ConsultaClientesBasica_RP {
    
    @isTest static void test(){
        
        B2B_ConsultaClientesBasica_RP consulta = new B2B_ConsultaClientesBasica_RP();
        consulta.ShippingStreet = 'Murcia';
        consulta.ShippingCountry = 'Murcia';
        consulta.ShippingPostalCode = '30360';
        consulta.ShippingState = 'Murcia';
        consulta.ShippingCity = 'Murcia';
        consulta.CUE_CAS_Activado = false;
        consulta.Id = '012345';
        consulta.Name = 'Murcia';
        consulta.CUE_TXT_Numero_Documento = '01234';
        consulta.CUE_SEL_Gremios_Disp = '01';
        consulta.Email='test@test.com';
        consulta.MobilePhone='012345678';
        consulta.Phone='876543210';
        consulta.CUE_CAS_Dada_de_Baja=true;
        consulta.CON_CAS_Contacto_principal=true;
        consulta.Code='1234';
        consulta.Message='Hola';
    }

}