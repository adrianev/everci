/**
 * Clase de Test de la Clase Callout_Fac_Eventos
 *
 */
@isTest 
public without sharing class Test_Callout_Fac_Eventos {
    private static INT_Bitacora__c bitacora {get; set;}
    private static Callout_Fac_EventosAbonos_RQ abono {get; set;}
    private static String body {get; set;}
    private static Callout_Fac_Eventos_RQ datos{get; set;}


	public static void testOK(Boolean tonalidad){
		datos = new Callout_Fac_Eventos_RQ();
		datos.origenDatos = 'prueba';
		datos.identificadorUnicoEvento = 'prueba1';
		datos.identificadorUnicoAbono = 'prueba2';
		datos.unidadNegocio = 'prueba3';
		datos.lineaDeNegocio = 'prueba4';
		datos.identificadorUnicoCaso = 'prueba5';
		datos.identificadorUnicoOrdenTrabajo = 'prueba6';
		datos.numOrdenTrabajo = 'prueba7';
		datos.lineaOrdenTrabajo = 'prueba8';
		datos.moneda = 'EUR';
		datos.tipoIntervencion = 'prueba10';
		datos.grupoCausa = 'prueba11';
		datos.facturaAbonar = 'prueba13';
		datos.impuesto = 'prueba14';
		datos.retencion = 'prueba15';
		datos.id_DireccionCliente = 'prueba16';
		datos.identificadorUnicoCuenta = 'prueba17';
		List<Callout_Fac_Eventos_RQ.listadoProf> listaAux= new List<Callout_Fac_Eventos_RQ.listadoProf>();
		Callout_Fac_Eventos_RQ.listadoProf aux = new Callout_Fac_Eventos_RQ.listadoProf();
		aux.identificadorUnicoProfesional = 'pruebaListaIden1';
		aux.importeEvento = 'pruebalistaEvento1';
		listaAux.add(aux);

		Callout_Fac_Eventos_RQ.listadoProf aux2= new Callout_Fac_Eventos_RQ.listadoProf();
		aux2.identificadorUnicoProfesional = 'pruebaLista1';
		aux2.importeEvento= 'pruebaLista2';
		listaAux.add(aux2);

		abono = new Callout_Fac_EventosAbonos_RQ();
		
		abono.origenDatos = 'Salesforce';
		abono.identificadorUnicoEvento = 'prueba';
		abono.identificadorUnicoAbono = 'prueba1';
		abono.unidadNegocio = 'prueba2';
		abono.lineaDeNegocio = 'prueba3';
		abono.identificadorUnicoCaso = 'prueba4';
		abono.identificadorUnicoOrdenTrabajo = 'prueba5';
		abono.numOrdenTrabajo = 'prueba6';
		abono.lineaOrdenTrabajo = 'prueba7';
		abono.descripcion = 'prueba8';
		abono.moneda = 'prueba9';
		abono.direccionTerritorial = 'prueba10';
		abono.tipoIntervencion = 'prueba11';
		abono.grupoCausa = 'prueba12';
		abono.tipoRegistroCaso = 'prueba13';
		abono.facturaAbonar = 'prueba14';
		abono.impuesto = 'prueba15';
		abono.retencion = 'prueba16';
		abono.id_DireccionCliente = 'prueba17';
		abono.identificadorUnicoProfesional = 'prueba18';
		abono.importe = 'prueba19';
		abono.identificadorUnicoCuenta = 'prueba20';
		abono.tipoEvento = 'prueba21';
        
        
        if(tonalidad){
		bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
        }else{
		bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
        bitacora.BIT_NUM_Reintentos__c = 2;
		insert bitacora;
            
        }
        
 
     
	}
    
    @isTest
    static void OK1(){ 
        testOK(true);
        test.startTest();
        body = Callout_Fac_Eventos.construirBodyEventos(datos);
		Callout_Fac_Eventos.updateDatos(body, 'SRV-PSI-097', ''+ bitacora.Id, '0WO9E0000003T4FWAU');
		Callout_Fac_Eventos.construirBodyAbonos(abono);
        test.stopTest();
        
    }
    
    @isTest
    static void OK2(){
    testOK(false);  
        test.startTest();
        body = Callout_Fac_Eventos.construirBodyEventos(datos);
		Callout_Fac_Eventos.updateDatos(body, 'SRV-PSI-097', ''+ bitacora.Id, '0WO9E0000003T4FWAU');
		Callout_Fac_Eventos.construirBodyAbonos(abono);
        test.stopTest();

    }
    
    
}