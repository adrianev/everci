/**
 * Clase de funciones auxiliares relativas a siniestros indemnizables.
 * 
 * @author EVERIS
 * 
 */
 public class Util_Indemnizables {

    /**
     *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
     *  @param Set<Id> setIdDocs        - Set de Ids de los documentos indemnizables a buscar
     *  
     *  @return Mapa con los documentos indemnizables resultantes de la Query
     **/
    public static Map<Id, Indemnizable_Documento__c> queryMapDocs(Set<Id> setIdDocs){
        Map<Id, Indemnizable_Documento__c> mapa = new Map<Id, Indemnizable_Documento__c>();
        if(setIdDocs != null && !setIdDocs.isEmpty()){
            mapa = new Map<Id, Indemnizable_Documento__c>(
                [SELECT Id,
                        Name,
                        IND_CAS_Opcional__c,
                        IND_LKP_Caso__c,
                        IND_RES_Importe_Total__c,
                        IND_SEL_Estado__c,
                        IND_SEL_Tipo_Documento__c,
                        IND_TXT_Descripcion__c
                 FROM Indemnizable_Documento__c
                 WHERE Id IN :setIdDocs]);
        }
        return mapa;
    }
    
    /**
     *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
     *  @param Set<Id> setIdCaso        - Set de Ids de los Casos de los documuentos indemnizables a buscar
     *  
     *  @return Mapa con los documentos indemnizables resultantes de la Query
     **/
    public static Map<Id, Indemnizable_Documento__c> queryMapDocByCase(Set<Id> setIdCaso){
        Map<Id, Indemnizable_Documento__c> mapa = new Map<Id, Indemnizable_Documento__c>();
        if(setIdCaso != null && !setIdCaso.isEmpty()){
            mapa = new Map<Id, Indemnizable_Documento__c>(
                [SELECT Id,
                        Name,
                        IND_CAS_Opcional__c,
                        IND_LKP_Caso__c,
                        IND_RES_Importe_Total__c,
                        IND_SEL_Estado__c,
                        IND_SEL_Tipo_Documento__c,
                        IND_TXT_Descripcion__c
                 FROM Indemnizable_Documento__c
                 WHERE IND_LKP_Caso__c IN :setIdCaso]);
        }
        return mapa;
    }
    
    /**
     *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
     *  @param Set<Id> setIdPars        - Set de Ids de las partidas indemnizables a buscar
     *  
     *  @return Mapa con las partidas indemnizables resultantes de la Query
     **/
    public static Map<Id, Indemnizable_Partida__c> queryMapPartidas(Set<Id> setIdPars){
        Map<Id, Indemnizable_Partida__c> mapa = new Map<Id, Indemnizable_Partida__c>();
        if(setIdPars != null && !setIdPars.isEmpty()){
            mapa = new Map<Id, Indemnizable_Partida__c>(
                [SELECT Id,
                        Name,
                        INDP_DIV_Importe__c,
                        INDP_LKP_Documento_Indemnizable__c,
                        INDP_SEL_Estado__c,
                        INDP_TXT_Descripcion__c
                 FROM Indemnizable_Partida__c
                 WHERE Id IN :setIdPars]);
        }
        return mapa;
    }
    
    /**
     *  Devuelve un mapa con los resultados de la query construida en funcion del parámetro
     *  @param Set<Id> setIdDocs        - Set de Ids de los documentos indemnizables a buscar
     *  
     *  @return Mapa con las partidas indemnizables resultantes de la Query
     **/
    public static Map<Id, Indemnizable_Partida__c> queryMapPartidasByDoc(Set<Id> setIdDocs){
        Map<Id, Indemnizable_Partida__c> mapa = new Map<Id, Indemnizable_Partida__c>();
        if(setIdDocs != null && !setIdDocs.isEmpty()){
            mapa = new Map<Id, Indemnizable_Partida__c>(
                [SELECT Id,
                        Name,
                        INDP_DIV_Importe__c,
                        INDP_LKP_Documento_Indemnizable__c,
                        INDP_SEL_Estado__c,
                        INDP_TXT_Descripcion__c
                 FROM Indemnizable_Partida__c
                 WHERE INDP_LKP_Documento_Indemnizable__c IN :setIdDocs]);
        }
        return mapa;
    }
    
    /*
     * Crea un objeto documento indemnizable a partir de los datos recibidos.
     *   
     *  @param caso: Siniestro asociado con parte indemnizable
     *  @param tipo: Tipo de documento
     *  @param opcional: Check que indica si es opcional
     * 
     *  @return documento indemnizable
     */
    private static Indemnizable_Documento__c crearDocumentoIndemnizable(Case caso, String tipo, Boolean opcional){
        Indemnizable_Documento__c docu_indem =  new Indemnizable_Documento__c();
        docu_indem.IND_LKP_Caso__c = caso.Id;
        docu_indem.IND_CAS_Opcional__c = opcional;
        
        if(tipo==null){
            docu_indem.IND_SEL_Tipo_Documento__c = '02'; //Prueba
        }else{
            docu_indem.IND_SEL_Tipo_Documento__c = tipo;
        }
        
        // 
        docu_indem.IND_TXT_Descripcion__c = 'Descripcion de prueba';
        
        return docu_indem;
    }


    public static List<Indemnizable_Documento__c> generarDocsIndemnizables(List<Case> listaCasos){
        // 2.3. Generar las Órdenes de Trabajo Indemnizables (aplica a APERTURA y a CONFIRMACION) y las Órdenes de Trabajo Reparables (solo aplica a CONFIRMACION)
        List<Indemnizable_Documento__c> listaDocumentosInd = new List<Indemnizable_Documento__c>();
        if(Util_variablesGlobales.faseVueltaSondeo != null){
            for(Case caso : listaCasos){
                system.debug('**************** Util_variablesGlobales.faseVueltaSondeo: ' + Util_variablesGlobales.faseVueltaSondeo);
                system.debug('**************** caso.Type: ' + caso.Type);
                system.debug('**************** caso.CAS_SEL_Sondeo_DocsIndemnizable__c: ' + caso.CAS_SEL_Sondeo_DocsIndemnizable__c);
                system.debug('**************** caso.CAS_SEL_Sondeo_Gremios__c: ' + caso.CAS_SEL_Sondeo_Gremios__c);
                system.debug('**************** caso.CAS_CAS_Siniestro_Grave__c: ' + caso.CAS_CAS_Siniestro_Grave__c);
    
                // 2.2.1. Generar Órdenes de Trabajo reparables a partir de los gremios devueltos en el sondeo (solo aplica en CONFIRMACION si el siniestro no es grave)
                if(Util_variablesGlobales.faseVueltaSondeo == Label.SINI_FASE_CONFIRMACION 
                        && caso.CAS_SEL_Sondeo_Gremios__c != null 
                        && (caso.Type == Label.CAS_TIPO_REPARABLE 
                        || caso.Type == Label.CAS_TIPO_MIXTO) 
                        && !caso.CAS_CAS_Siniestro_Grave__c
                        && (Util_variablesGlobales.estadoVueltaSondeo == Label.SINI_ESTADO_CUBIERTO
                        || caso.Status == Label.SINI_ESTADO_PDTE_DOC_INI)){
                    for(String gremio : caso.CAS_SEL_Sondeo_Gremios__c.split(';')){
                        if(gremio != caso.CAS_SEL_Gremio_Principal__c){
                            listaDocumentosInd.add(crearDocumentoIndemnizable(caso, null, true));
                        }
                    }
                }
    
                // 2.2.2. Generar Órdenes de Trabajo indemnizables a partir de los documentos devueltos en el sondeo
                else if(caso.Type == Label.CAS_TIPO_INDEMNIZABLE 
                        && caso.CAS_SEL_Sondeo_DocsIndemnizable__c != null){
                    system.debug('>>>>listaDocs ' + caso.CAS_SEL_Sondeo_DocsIndemnizable__c.split(';'));
                    for(String documento : caso.CAS_SEL_Sondeo_DocsIndemnizable__c.split(';')){
                        Indemnizable_Documento__c ordenTrabajoIndem = crearDocumentoIndemnizable(caso, documento, false);
                        listaDocumentosInd.add(ordenTrabajoIndem);
                    }
                }
            }//FIN FOR
        }//FIN IF
        return listaDocumentosInd;
    }
}