@isTest
public without sharing class Test_Fachada {
    @isTest
    public static void Testing(){
        test.startTest();

        String identificadorCompania = 'identificadorPrueba';
        String consultaPoliza;
        consultaPoliza = Fachada.consultaPolizaActivas(identificadorCompania);


        Integer actuacion = 01;
        Integer casoActualizacion = 01;
        String fechaCambio = system.today()+'';
        String descripcionNoAbierto = 'SinDescripcion';
        String tipoSiniestro = 'Indemnizable';
        String gremio = 'Encofrador';
        String numeroSiniestroHS = '01a73';
        String numeroSiniestroCia = '02b74';
        String tipoSituacion = 'En curso';
        String tipoSituacionReparacion = 'Desconocido';
        /*Callout_ActualizaSiniestroVesta.Resultado actSinies = new Callout_ActualizaSiniestroVesta.Resultado();
        actSinies = Fachada.actualizaSiniestroVesta(actuacion, casoActualizacion, fechaCambio, descripcionNoAbierto, tipoSiniestro, 
                gremio, numeroSiniestroHS, numeroSiniestroCia, tipoSituacion, tipoSituacionReparacion);*/

        String generarID = '5009E000006hCdpQAE';
        Id idCompania = generarID;
        String localizador = 'localizado';
        List<Callout_ConsultaPolizaVesta_RP> listaPrueba = new List<Callout_ConsultaPolizaVesta_RP>();
        listaPrueba = Fachada.consultaPolizaVestaSimple(idCompania, localizador);

        String numeroPoliza = '23v0128vv';
        String numeroDocumento = '128v13vJj';
        String nombre = 'Marta';
        String apellido1 = 'Valero';
        String apellido2 = 'García';
        String direccionRiesgoDomicilio = 'Calle de la plaza grande, 71';
        String direccionRiesgoCp = 'Calle de la fuente, 2';
        String poblacion = 'Córdoba';
        String provincia = 'Córdoba';

        List<Callout_ConsultaPolizaVesta_RP> nuevaLista = new List<Callout_ConsultaPolizaVesta_RP>();
        nuevaLista = Fachada.consultaPolizaVestaAdvance(idCompania, numeroPoliza, numeroDocumento,
                numeroSiniestroHS, numeroSiniestroCIA, nombre, apellido1, apellido2, 
                direccionRiesgoDomicilio, direccionRiesgoCp, poblacion, provincia);
        test.stopTest();
    }
}