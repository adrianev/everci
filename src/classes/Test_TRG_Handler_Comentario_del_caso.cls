@isTest
public without sharing class Test_TRG_Handler_Comentario_del_caso extends TestSetup{

    public static Comentario_caso__c comentarioCaso {get; set;}  
    public static Comentario_caso__c comentarioCaso2 {get; set;}
    private static Account cuentaCompania {get; set;}
    private static Account cuentaB2BPrincipal {get; set;}
    private static Account cuentaAsegurado {get; set;}
    private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
    private static Producto_CIA__c productoCIA {get; set;}
    private static ServiceContract poliza {get; set;}
    private static Case casoSini {get; set;}

    static void inicializarVariables(boolean changeType){
        List<Account> listaCuentas = new List<Account>();

        cuentaB2BPrincipal = Util_Tests.crearCuentaB2BPpal('B2BPrincipal','1018','X1234567X');
        insert cuentaB2BPrincipal;

        cuentaCompania = Util_Tests.crearCuentaCompania('SegurCaixa','1019','X1134567X');
        cuentaAsegurado = Util_Tests.crearCuentaAsegurado('Asegurado','1021','email@gmail.es','03629033R','nombre','apellido1','apellido2');
        cuentaAsegurado.CUE_LKP_Cuenta_Principal__c = cuentaB2BPrincipal.id;
        listaCuentas.add(cuentaCompania);
        listaCuentas.add(cuentaAsegurado);
        insert listaCuentas;

        tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',cuentaCompania.Id);
        insert tipoProductoCIA;

        productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
        insert productoCIA;

        poliza = Util_Tests.crearPolizaContrato('2277393',cuentaCompania.Id,cuentaAsegurado.Id,productoCIA.Id);
        insert poliza;

        casoSini = Util_Tests.crearCasoSini(poliza.Id,cuentaAsegurado.Id,cuentaB2BPrincipal.Id);
        if(changeType)
            casoSini.Type = '1'; //CAS_TIPO_REPARABLE
            else
            casoSini.Type = '3'; //CAS_TIPO_INDEMNIZABLE
            insert casoSini;
        }

        @isTest static void crearComentarioCasoSiniTipoReparable(){
            inicializarVariables(true);

            comentarioCaso = Util_Tests.crearComentarioCaso('Comentario de prueba para el caso generado', casoSini.Id);
            insert comentarioCaso;
        }
        @isTest static void crearComentarioCasoSiniTipoIndemnizable(){
            inicializarVariables(false);

            comentarioCaso = Util_Tests.crearComentarioCaso('Comentario de prueba para el caso generado', casoSini.Id);
            insert comentarioCaso;
        }



    }