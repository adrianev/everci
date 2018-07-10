@isTest
public without sharing class Test_TRG_Handler_MiembroTS {

    private static Account cuentaProfesional {get; set;}
    private static User usuario1 {get; set;}
    private static User usuario2 {get; set;}
    private static ServiceResource recursoServicio1 {get; set;}
    private static ServiceResource recursoServicio2 {get; set;}
    private static OperatingHours horaFuncionamiento {get; set;}
    private static ServiceTerritory territorioServicio {get; set;}
    private static ServiceTerritoryMember miembroTerritorioServicio {get; set;}
    private static ResourceAbsence absentismo {get; set;}
    
    @isTest static void test(){
        inicializarVariables();
        Test.startTest();
        miembroTerritorioServicio.ServiceResourceId = recursoServicio2.Id;
        miembroTerritorioServicio.PostalCode = '28002';
        update miembroTerritorioServicio;
        miembroTerritorioServicio.PostalCode = '28001';
        update miembroTerritorioServicio;
        Test.stopTest();        
    }
    
    private static void inicializarVariables() {
        Account compania = Util_tests.crearCuentaCompania('Segur', '1018', 'X1234567X');
        Insert compania;
        // Crear Profesional Contrato
        cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR123456','PR123456','E1234567E',null);
        cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = compania.Id;
        cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
        insert cuentaProfesional;
        cuentaProfesional.CUE_SEL_Estado__c = '02';
        update cuentaProfesional;
        // Crear Usuario FSL Mobile 1
        Profile fslMobile = [SELECT Id FROM Profile where Name = :Label.PERFIL_PROFESIONAL].get(0);
        usuario1 = Util_Tests.nuevoUsuario('PR123456_01_1', '00000001', 'PR123456_01_1@prueba.es', 'PR123456_01_1', 'PR123456_01_1', fslMobile);
        insert usuario1;
        // Crear Recurso de Servicio 1
        recursoServicio1 = Util_Tests.crearRecursoServicio(usuario1.LastName, usuario1.LastName, cuentaProfesional.Id, usuario1);
        insert recursoServicio1;
        // Crear Usuario FSL Mobile 2
        usuario2 = Util_Tests.nuevoUsuario('PR123456_01_2', '00000002', 'PR123456_01_2@prueba.es', 'PR123456_01_2', 'PR123456_01_2', fslMobile);
        insert usuario2;
        // Crear Recurso de Servicio 2
        recursoServicio2 = Util_Tests.crearRecursoServicio(usuario2.LastName, usuario2.LastName, cuentaProfesional.Id, usuario2);
        insert recursoServicio2;
        // Crear Hora de Funcionamiento
        horaFuncionamiento = Util_Tests.crearHoraFuncionamiento('Horario','Europe/Paris');
        insert horaFuncionamiento;
        // Crear Territorio de Servicio
        territorioServicio = Util_Tests.crearTerritorioServicio('28001 MADRID',horaFuncionamiento.Id,'28001');
        territorioServicio.isActive = true;
        insert territorioServicio;
        // Crear Miembro de Territorio de Servicio
        miembroTerritorioServicio = Util_Tests.crearMiembroTerritorioServicio(recursoServicio1 ,territorioServicio ,'P',Datetime.newInstance(2015,01,01));
        miembroTerritorioServicio.PostalCode = '28001';
        insert miembroTerritorioServicio;
        // Crear Absentismo
        absentismo = new ResourceAbsence(ResourceId=recursoServicio2.Id,Type='02',Start=Datetime.newInstance(2019,01,01),End=Datetime.newInstance(2019,01,02));
        insert absentismo;
    }
}