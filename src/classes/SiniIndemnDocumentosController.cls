/**
 * Clase controladora de la Visualforce "SiniIndemnDocumentosController" encargada de gestionar los documentos de un Siniestro Indemnizable.
 * 
 * @author EVERIS
 */
public without sharing class SiniIndemnDocumentosController {

    public String fase {get; set;}
    private String idTabBusqClientes;
    private String codigoVDN;
    public Case caso {get; set;}
    public Case casoMixtoPadre {get; set;}
    public List<Comentario_caso__c> listaComentsCaso {get; set;}
    public Comentario_caso__c nuevoComentCaso {get; set;}
    public List<Indemnizable_Documento__c> listaItems {get; set;}
    public Indemnizable_Documento__c nuevoItem {get; set;}
    public Integer indiceListaItems {get; set;}
    public Id idDocIndemnizable {get; set;}
    public Boolean creacionItem {get; set;}
    public Boolean actualizacionItem {get;set;}
    public String tituloFormularioEdicion {get; set;}
    public String tipoActuacion {get; set;}
    public Boolean mensajePartidas {get; set;}
    public List<SelectOption> listaDocsSugeridos {get; set;}
    public String valorSeleccionado {get; set;}
    private Boolean comentarioInsertado;
    private Boolean convertidoAGrave;
    private String apexMessageError;
    private String apexMessageWarning;

    public SiniIndemnDocumentosController(ApexPages.standardController stdCtr){
        listaDocsSugeridos = new List<SelectOption>();
        mensajePartidas = false;
        convertidoAGrave = false;
        PageReference paginaActual = ApexPages.currentPage();
        if(paginaActual.getParameters().containsKey('fase')){
            fase = paginaActual.getParameters().get('fase');
        }
        if(paginaActual.getParameters().containsKey('VDN')){
            codigoVDN = paginaActual.getParameters().get('VDN');
        }
        if(paginaActual.getParameters().containsKey('idTabBusqClientes')){
            idTabBusqClientes = paginaActual.getParameters().get('idTabBusqClientes');
        }
        if(!paginaActual.getParameters().containsKey('id')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
        }
        else {
            listaComentsCaso = new List<Comentario_caso__c>();
            nuevoComentCaso = new Comentario_caso__c();

            //Cargamos campos necesarios del Caso
            List<Case> listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
            //List<Case> listaCasosQuery = Util_Caso.queryMapSiniCaso(new Set<Id>{stdCtr.getRecord().Id},null,1).values();
            //List<Case> listaCasosQuery = Util_Siniestro.queryCaso(stdCtr.getRecord().Id, null, 1);
            if(listaCasosQuery.size() > 0){
                caso = listaCasosQuery.get(0);
                recogerComentarios();
                tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
                system.debug('***************** caso : ' + caso);

                obtenerCasoMixtoPadre();

                //actualizarListaOTs();
                actualizarListaDocs();
                system.debug('**** caso.CAS_SEL_Sondeo_DocIndemSug__c : ' + caso.CAS_SEL_Sondeo_DocIndemSug__c);
                if(caso.CAS_SEL_Sondeo_DocIndemSug__c != null){
                    listaDocsSugeridos.add(new SelectOption('', '-- Ninguno --'));
                    List<String> listaDocSug = caso.CAS_SEL_Sondeo_DocIndemSug__c.split(';');
                    for(String docSug : listaDocSug){
                        listaDocsSugeridos.add(new SelectOption(docSug, Util_Listas_Seleccion.getLabelDesdeAPI('Case','CAS_SEL_Sondeo_DocIndemSug__c').get(docSug)));
                    }
                }
            }
        }
    }//FIN CONSTRUCTOR

    public void recogerComentarios(){
        listaComentsCaso = Util_Caso.getMapComentariosCaso(new set<Id>{caso.Id}).get(caso.Id);
    }

    public void crearItem(){
        actualizacionItem = false;
        creacionItem = true;
        //nuevoItem = new WorkOrder();
        nuevoItem = new Indemnizable_Documento__c();
        nuevoItem.IND_LKP_Caso__c = caso.Id;
        nuevoItem.IND_CAS_Opcional__c = true;
        tituloFormularioEdicion = 'Datos de nuevo documento';
    }//FIN crearItem()

    public void guardarItem(){
        if(!tipoDocExiste()){
            system.Savepoint puntoGuardado = Database.setSavepoint();
            try {
                if(nuevoItem.Id == null){
                    nuevoItem.IND_CAS_Opcional__c = true;
                }
                upsert nuevoItem;
                nuevoItem = (Util_Indemnizables.queryMapDocs(new Set<Id>{nuevoItem.Id})).get(nuevoItem.Id);
                listaItems.add(nuevoItem);
                creacionItem = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
                actualizarListaDocs();
            }
            catch(DmlException e){
                Database.rollback(puntoGuardado);
                system.debug(e.getStackTraceString());
                if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
                }
            }
            catch(Exception e){
                Database.rollback(puntoGuardado);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
                system.debug(e.getStackTraceString());
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se puede guardar el documento porque ya se ha insertado uno del mismo tipo previamente'));
        }
    }//Fin guardarItem

    public void cancelarCreacionItem()
    {
        nuevoItem = null;
        creacionItem = false;
        actualizacionItem = false;
    }//Fin cancelarCreacionItem

    public void seleccionarItem()
    { 
        actualizacionItem = true;
        creacionItem = true;
        nuevoItem = listaItems.get(indiceListaItems);
        tituloFormularioEdicion = 'Datos de actualización de documento';
    }// FIN seleccionarResultado

    public void actualizarItem() 
    {
        update nuevoItem;
        nuevoItem = null;
        actualizacionItem = false;
        creacionItem = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
    }//FIN actualizarItem

    public void eliminarItem()
    {   
        delete listaItems.get(indiceListaItems-1); 
        listaItems.remove(indiceListaItems-1);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
    }//FIN eliminarItem()

    public Boolean tipoDocExiste(){
        Boolean existe = false;
        for(Indemnizable_Documento__c documento : listaItems){
            if(documento.IND_SEL_Tipo_Documento__c == nuevoItem.IND_SEL_Tipo_Documento__c){
                existe = true;
                break;
            }
        }
        return existe;
    }

    public void insertarComentarioCaso(){
        if(nuevoComentCaso.CMC_TXT_Comentario__c != null && nuevoComentCaso.CMC_TXT_Comentario__c != ''){
            Comentario_caso__c comentarioCasoInsertar = Util_Caso.crearComentarioCaso(caso.Id, nuevoComentCaso.CMC_TXT_Comentario__c);
            if(comentarioCasoInsertar != null){
                system.Savepoint puntoGuardado = Database.setSavepoint();
                try {
                    insert comentarioCasoInsertar;
                    recogerComentarios();
                    comentarioInsertado = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
                }
                catch(DmlException e){
                    Database.rollback(puntoGuardado);
                    system.debug(e.getStackTraceString());
                    if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
                    }
                }
                catch(Exception e){
                    Database.rollback(puntoGuardado);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
                    system.debug(e.getStackTraceString());
                }
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_COMENTARIO_VACIO));
        }
    }

    private void obtenerCasoMixtoPadre(){
        if(caso.ParentId != null){
            system.debug('***** caso.ParentId : ' + caso.ParentId);

            List<Case> listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{caso.ParentId}).values();
            //List<Case> listaCasosQuery = Util_Caso.queryMapSiniCaso(null,new Set<Id>{caso.ParentId},3).values();
            //List<Case> listaCasosQuery = Util_Siniestro.queryCaso(null, caso.ParentId, 3);
            if(listaCasosQuery.size() > 0){
                casoMixtoPadre = listaCasosQuery.get(0);
            }
        }
        if(casoMixtoPadre != null){
            caso.CAS_LKP_Ayuda_Indemnizable__c = casoMixtoPadre.CAS_LKP_Ayuda_Indemnizable__c;
        }
    }
    
    public void actualizarListaDocs(){
        listaItems = Util_Indemnizables.queryMapDocByCase(new Set<Id>{caso.Id}).values();
    }

    public PageReference vincularContactos(){
        PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_CONTACTOS);
        paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_INDEMN_DOCUMENTOS);
        paginaRedireccion.setRedirect(true);
        return paginaRedireccion;
    }//FIN vincularContactos()

    public PageReference actualizarPartidas(){
        PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_INDEMN_PARTIDAS);
        paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_INDEMN_DOCUMENTOS);
        paginaRedireccion.getParameters().put('idDocIndemnizable', idDocIndemnizable);
        paginaRedireccion.setRedirect(true);
        return paginaRedireccion;
    }//FIN actualizarPartidas()

    private PageReference agregarParametrosURL(PageReference paginaRedireccion, Id idCaso, String retorno){
        paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
        if(idCaso != null){
            paginaRedireccion.getParameters().put('id', idCaso);
        }
        if(retorno != null){
            paginaRedireccion.getParameters().put('retorno', retorno);
        }
        if(idTabBusqClientes != null){
            paginaRedireccion.getParameters().put('idTabBusqClientes', idTabBusqClientes);
        }
        if(codigoVDN != null){
            paginaRedireccion.getParameters().put('VDN', codigoVDN);
        }
        return paginaRedireccion;
    }//FIN agregarParametrosURL()

    public void salir_paso1(){
        apexMessageError = null;
        Case casoAProcesar = caso;
        if(casoMixtoPadre != null){
            casoAProcesar = casoMixtoPadre;
        }
        // Si se cancela una vez iniciado el proceso de apertura: establecemos la Solicitud de Siniestro como "No Abierta"
        if(fase == Label.SINI_FASE_APERTURA){
            try {
                Util_Siniestro.cancelarAperturaSiniestro(casoAProcesar);
            }
            catch(DmlException e){
                system.debug(e.getStackTraceString());
                if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
                }
            }
            catch(Exception e){
                apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
                system.debug(e.getStackTraceString());
            }
        }
    }

    public PageReference salir_paso2(){
        PageReference paginaRedireccion = null;
        Callout_ActualizaSiniestroVesta.Resultado resultadoUpdVesta;
        if(apexMessageError != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, apexMessageError));
        }
        else {
            Case casoAProcesar = caso;
            if(casoMixtoPadre != null){
                casoAProcesar = casoMixtoPadre;
            }
            // Si se cancela una vez iniciado el proceso de apertura: establecemos la Solicitud de Siniestro como "No Abierta"
            if(fase == Label.SINI_FASE_APERTURA){
                try {
                    if(caso.CAS_NUM_Id_Actuacion_SondeoExt__c != null){
                        // CASO ACTUALIZACION 1 - Generacion n_siniestro hs y n_siniestro CIA
                        resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c), 7, null, Label.SINI_COMENTARIO_CANCELACION, null, null, null, null, null, null);
                        if(resultadoUpdVesta.resultado != 'OK'){
                            throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
                        }
                    }
                    paginaRedireccion = new PageReference('/' + casoAProcesar.CAS_LKP_PolizaContrato__c);
                    if(idTabBusqClientes!= null)
                    {
                        //Si hemos llegado desde la pantalla de Búsqueda: regresamos a la pantalla de Búsqueda
                        //Se pasa por URL lo necesario para ir a la busqueda de asegurados
                        paginaRedireccion = new PageReference('/apex/' + label.VF_BUSQ_CLIENTES);
                        paginaRedireccion.getParameters().put('sfdc.tabName', idTabBusqClientes);
                        paginaRedireccion.getParameters().put('VDN', codigoVDN);
                    }
                    paginaRedireccion.setRedirect(true);
                }
                catch(DmlException e){
                    system.debug(e.getStackTraceString());
                    if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
                    }
                }
                catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
                    system.debug(e.getStackTraceString());
                }
            }
            else {
                paginaRedireccion = new PageReference('/' + casoAProcesar.Id);
                paginaRedireccion.setRedirect(true);    
            }
        }
        return paginaRedireccion;
    }

    public void finalizarApertura_paso1(){
        apexMessageError = null;
        apexMessageWarning = null;
        if(listaComentsCaso.isEmpty()){
            apexMessageError = Label.ERROR_FALTA_CAMPO_COMENTARIO;
        }
        else {
            if(!mensajePartidas){
                mensajePartidas = true;
                apexMessageWarning = Label.WARNING_ACTUALIZAR_PARTIDAS;
            }
            else {
                Case casoAProcesar = caso;
                if(casoMixtoPadre != null){
                    casoAProcesar = casoMixtoPadre;
                }
                //Si no está marcado el check: comprobamos los límites
                if(!casoAProcesar.CAS_CAS_Siniestro_Grave__c){
                    //SE COMPRUEBA SI CUMPLE LAS CONDICIONES PARA SER GRAVE
                    if(Util_Siniestro.validarCondicionesSiniGrave(casoAProcesar)){
                        convertirAGrave(casoAProcesar);
                        convertidoAGrave = true;
                    }
                }
                //Si ya era grave o no se ha convertido: continuamos
                if(!convertidoAGrave){
                    try {
                        Util_Siniestro.finalizarAperturaSiniestro(casoAProcesar);
                    }
                    catch(DmlException e){
                        system.debug(e.getStackTraceString());
                        if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                            apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
                        }
                    }
                    catch(Exception e){
                        apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
                        system.debug(e.getStackTraceString());
                    }
                }
            }
        }
    }//FIN finalizarApertura_paso1

    public PageReference finalizarApertura_paso2(){
        system.debug('>>>>Fin ap. paso 2');
        PageReference paginaNavegar = null;
        Callout_ActualizaSiniestroVesta.Resultado resultadoUpdVesta;
        if(apexMessageError != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, apexMessageError));
        }
        else if(apexMessageWarning != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, apexMessageWarning));
        }
        else {
            Case casoAProcesar = caso;
            if(casoMixtoPadre != null){
                casoAProcesar = casoMixtoPadre;
            }
            try {
                if(convertidoAGrave){
                    paginaNavegar = new PageReference('/apex/' + Label.VF_SINI_REPARABLE);
                    paginaNavegar = agregarParametrosURL(paginaNavegar, casoAProcesar.Id, null);
                    paginaNavegar.getParameters().put('conversionAGrave', 'Y');
                    paginaNavegar.setRedirect(true);
                }
                else {
                    if(casoAProcesar.CAS_NUM_Id_Actuacion_SondeoExt__c != null){
                        // Conversion tipo caso membership
                        String tipoCasoReal = casoAProcesar.Type;
                        if(casoAProcesar.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP){
                            if(casoAProcesar.Type == Label.CAS_TIPO_MIXTO){
                                tipoCasoReal = Label.CAS_TIPO_INDEMNIZABLE;
                            }
                            else if(casoAProcesar.Type == Label.CAS_TIPO_INDEMNIZABLE){
                                tipoCasoReal = Label.CAS_TIPO_MIXTO;
                            }
                        }

                        // CASO ACTUALIZACION 1 - Generacion n_siniestro hs y n_siniestro CIA - ¿Correcto?
                        resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(casoAProcesar.CAS_NUM_Id_Actuacion_SondeoExt__c), 1, null, null, null, null, 
                                casoAProcesar.CAS_TXT_Num_Caso_HS__c, casoAProcesar.CAS_TXT_Num_Caso_CIA__c, null, null);
                        if(resultadoUpdVesta.resultado != 'OK'){
                            throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
                        }

                        // CASO ACTUALIZACION 3 - Cambio de situación en una reparación si es un Siniestro Reparable o Mixto - ¿Correcto?
                        if(tipoCasoReal == Label.CAS_TIPO_MIXTO){
                            resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(casoAProcesar.CAS_NUM_Id_Actuacion_SondeoExt__c), 3, null, null, tipoCasoReal, null, null, null, '1', null);
                            if(resultadoUpdVesta.resultado != 'OK'){
                                throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
                            }
                        }
                    }
                    paginaNavegar = navegarDetalleCaso(casoAProcesar);
                }
            }
            catch(DmlException e){
                system.debug(e.getStackTraceString());
                if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
                }
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
                system.debug(e.getStackTraceString());
            }
        }
        return paginaNavegar;
    }//FIN finalizarApertura_paso2

    public void finalizarConfirmacion_paso1(){
        apexMessageError = null;
        apexMessageWarning = null;
        if(!comentarioInsertado){
            apexMessageError = Label.ERROR_FALTA_CAMPO_COMENTARIO;
        }
        else {
            if(!mensajePartidas){
                mensajePartidas = true;
                apexMessageWarning = Label.WARNING_ACTUALIZAR_PARTIDAS;
            }
            else {
                Case casoAProcesar = caso;
                if(casoMixtoPadre != null){
                    casoAProcesar = casoMixtoPadre;
                }
                //Si no está marcado el check: comprobamos las condiciones
                if(!casoAProcesar.CAS_CAS_Siniestro_Grave__c){
                    if(Util_Siniestro.validarCondicionesSiniGrave(casoAProcesar)){
                        convertirAGrave(casoAProcesar);
                        convertidoAGrave = true;
                    }
                }
                //Si ya era grave o no se ha convertido: continuamos
                if(!convertidoAGrave){
                    try {
                        Util_Siniestro.finalizarConfirmacionSiniestro(casoAProcesar);
                    }
                    catch(DmlException e){
                        system.debug(e.getStackTraceString());
                        if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                            apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
                        }
                    }
                    catch(Exception e){
                        apexMessageError = Label.ERROR_GUARDAR + ' : ' + e.getMessage();
                        system.debug(e.getStackTraceString());
                    }
                }
            }
        }
    }//FIN finalizarConfirmacion_paso1

    public PageReference finalizarConfirmacion_paso2(){
        PageReference paginaNavegar = null;
        Callout_ActualizaSiniestroVesta.Resultado resultadoUpdVesta;
        if(apexMessageError != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, apexMessageError));
        }
        else if(apexMessageWarning != null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, apexMessageWarning));
        }
        else {
            Case casoAProcesar = caso;
            if(casoMixtoPadre != null){
                casoAProcesar = casoMixtoPadre;
            }
            try {
                if(convertidoAGrave){
                    paginaNavegar = new PageReference('/apex/' + Label.VF_SINI_REPARABLE);
                    paginaNavegar = agregarParametrosURL(paginaNavegar, casoAProcesar.Id, null);
                    paginaNavegar.getParameters().put('conversionAGrave', 'Y');
                    paginaNavegar.setRedirect(true);
                }
                else {
                    if(casoAProcesar.CAS_NUM_Id_Actuacion_SondeoExt__c != null){

                        // Conversion tipo caso membership
                        String tipoCasoReal = casoAProcesar.Type;
                        if(casoAProcesar.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP){
                            if(casoAProcesar.Type == Label.CAS_TIPO_MIXTO){
                                tipoCasoReal = Label.CAS_TIPO_INDEMNIZABLE;
                            }
                            else if(casoAProcesar.Type == Label.CAS_TIPO_INDEMNIZABLE){
                                tipoCasoReal = Label.CAS_TIPO_MIXTO;
                            }
                        }

                        //  CASO ACTUALIZACION 2 - Cambio de tipo de Siniestro en Confirmacion - ¿CORRECTO?
                        //  CASO ACTUALIZACION 3 - Cambio de situación en una reparación - ¿CORRECTO?
                        if(tipoCasoReal == Label.CAS_TIPO_MIXTO){
                            resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(casoAProcesar.CAS_NUM_Id_Actuacion_SondeoExt__c), 2, null, null, tipoCasoReal, null, null, null, null, null);
                            if(resultadoUpdVesta.resultado != 'OK'){
                                throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
                            }

                            resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(casoAProcesar.CAS_NUM_Id_Actuacion_SondeoExt__c), 3, null, null, tipoCasoReal, null, null, null, '1', null);
                            if(resultadoUpdVesta.resultado != 'OK'){
                                throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
                            }
                        }

                        //  CASO ACTUALIZACION 4 - Cambio de situación en un indemnizable - ¿CORRECTO?
                        if(tipoCasoReal == Label.CAS_TIPO_INDEMNIZABLE){
                            resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(casoAProcesar.CAS_NUM_Id_Actuacion_SondeoExt__c), 4, null, null, tipoCasoReal, null, null, null, '1', null);
                            if(resultadoUpdVesta.resultado != 'OK'){
                                throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
                            }
                        }
                    }
                    paginaNavegar = navegarDetalleCaso(casoAProcesar);
                }
            }
            catch(DmlException e){
                system.debug(e.getStackTraceString());
                if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
                }
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
                system.debug(e.getStackTraceString());
            }
        }
        return paginaNavegar;
    }//FIN finalizarConfirmacion_paso2

    public PageReference navegarDetalleCaso(Case cas){
        PageReference paginaNavegar = new PageReference('/' + cas.Id);
        paginaNavegar.setRedirect(true);
        return paginaNavegar;
    }

    private void convertirAGrave(Case casoAProcesar){
        system.Savepoint puntoGuardado = Database.setSavepoint();
        try {
            casoAProcesar.CAS_CAS_Siniestro_Grave__c = true;
            upsert casoAProcesar;
        }
        catch(DmlException e){
            Database.rollback(puntoGuardado);
            system.debug(e.getStackTraceString());
            if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
            }
        }
        catch(Exception e){
            Database.rollback(puntoGuardado);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
            system.debug(e.getStackTraceString());
        }
    }
}