/**
 * Clase controladora de la Visualforce "SiniRetornoSondeoExtremoController" encargada de realizar
 * la navegación correspondiente cuando se regresa del sistema de Sondeo Externo de Siniestros.
 * 
 * @author EVERIS
 */
public without sharing class SiniRetornoSondeoExternoController {
    public Case caso {get; set;}
    public String errorUsuario {get; set;}
    public PageReference paginaRedireccion {get; set;} 
    private String errorCode;
    private String errorMsg;
    private String idTabBusqClientes;
    private String codigoVDN;

    /**
     * Constructor de la clase.
     * 
     * @param objeto Case principal del controlador
     */
    public SiniRetornoSondeoExternoController(ApexPages.standardController stdCtr)
    {
        system.debug('Entra en Sini_RetornoSondeoExterno');
        // Metemos en una lista los campos del caso que vamos a utilizar posteriormente en las condiciones
        PageReference paginaActual = ApexPages.currentPage();
        List<String> fields = new List<String> {'Status','Type','CAS_LKP_Cliente_Contable__c','CAS_LKP_Compania__c','CAS_CAS_Requiere_Perito__c','CAS_LKP_Compania__r.CUE_CAS_No_Permite_Servicio_B2C__c', 'CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c','CAS_CAS_Siniestro_Grave__c', 'CAS_SEL_DirRiesgo_Estado_Provincia__c'};
        if (!Test.isRunningTest()) stdCtr.addFields(fields);
        /*for(Case casoAux: Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values()) {
            caso=casoAux;
        }*/
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>caso: '+ caso);
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>paginaActual.getParameters(): ' + paginaActual.getParameters());
        if (paginaActual.getParameters().containsKey('idTabBusqClientes'))
        {
            idTabBusqClientes = paginaActual.getParameters().get('idTabBusqClientes');
        }
        if (paginaActual.getParameters().containsKey('VDN'))
        {
            codigoVDN = paginaActual.getParameters().get('VDN');
        }
        if(paginaActual.getParameters().containsKey('id')) {
            for(Case aux:Util_Caso.getCaseById(new Set<Id>{paginaActual.getParameters().get('id')}).values()) {
                caso=aux;
            }
        }

  

        errorUsuario = null;

        if (!paginaActual.getParameters().containsKey('id') ||
                (paginaActual.getParameters().containsKey('errorCode') &&
                        paginaActual.getParameters().get('errorCode') != null &&
                        paginaActual.getParameters().get('errorCode') != '000' &&
                        paginaActual.getParameters().get('errorCode') != '') ||
                (paginaActual.getParameters().containsKey('errorMessage') &&
                        paginaActual.getParameters().get('errorMessage') != null &&
                        paginaActual.getParameters().get('errorMessage') != ''))
        {
            //Configuracion del error que se va a mostrar si el id no viene en la URL o si viene el errorCode
            errorUsuario = label.SINI_ERROR_USUARIO;
            errorCode = paginaActual.getParameters().get('errorCode');
            if (errorCode != null)
                errorUsuario += ' [' + errorCode + '] ';
            errorMsg = paginaActual.getParameters().get('errorMessage');
            if (errorMsg != null)
                errorUsuario += errorMsg;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorUsuario));
        }
        else if (caso.Status == Label.SINI_ESTADO_PDTESONDEO)
        {
            errorUsuario = Label.SINI_ERROR_USUARIO;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorUsuario));            
        }
        else
        {
            String tipoIndemnizable = caso.CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c;
            paginaRedireccion = null;
            // Por defecto navegamos al detalle del Siniestro y creamos la orden de trabajo para Siniestros Indemnizables
            paginaRedireccion = new PageReference('/' + caso.Id);
            // Si el estado es 'En Curso' y el tipo es 'Indemnizable': navegamos a la pantalla de partidas indemnizables
            if (( tipoIndemnizable == Label.SINI_REGISTRA_DOC_INDEMNIZABLES || tipoIndemnizable == Label.SINI_GESTIONAINDEMNIZABLES) && caso.Type == Label.CAS_TIPO_INDEMNIZABLE)
            {
                paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_INDEMN_DOCUMENTOS);
                paginaRedireccion.getParameters().put('id', caso.Id);
                paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_APERTURA);
                if (idTabBusqClientes != null)
                {
                    paginaRedireccion.getParameters().put('idTabBusqClientes', idTabBusqClientes);
                }
                if (codigoVDN != null)
                {
                    paginaRedireccion.getParameters().put('VDN', codigoVDN);
                }
                paginaRedireccion.getParameters().put('inline', '1');
            }
            // Si el estado es 'Cubierto' y el tipo es 'Reparable' o 'Mixto': navegamos al alta de gremios
            else if (caso.Status == Label.SINI_ESTADO_CUBIERTO 
                    && (caso.Type == Label.CAS_TIPO_REPARABLE 
                    || caso.Type == Label.CAS_TIPO_MIXTO 
                    || caso.Type == Label.CAS_TIPO_ASISTENCIA_COBERTURA
                    || caso.Type == Label.CAS_TIPO_MANITAS
                    || caso.Type == Label.CAS_TIPO_SERVICIO_ESPECIAL_REP))
            {
                if(caso.CAS_CAS_Siniestro_Grave__c)
                {
                    paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_REPARABLE);
                }
                else
                {
                    paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_GREMIOS);
                }
                paginaRedireccion.getParameters().put('id', caso.Id);
                paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_APERTURA);
                if (idTabBusqClientes != null)
                {
                    paginaRedireccion.getParameters().put('idTabBusqClientes', idTabBusqClientes);
                }
                if (codigoVDN != null)
                {
                    paginaRedireccion.getParameters().put('VDN', codigoVDN);
                }
                paginaRedireccion.getParameters().put('inline', '1');
            } else if (caso.Type == Label.CAS_TIPO_RECHAZO_EN_APERTURA) {
                if (caso.CAS_LKP_Compania__r.CUE_CAS_No_Permite_Servicio_B2C__c) {
                    paginaRedireccion.getParameters().put('id',caso.Id);
                }else {
					paginaRedireccion = new PageReference('/apex/' + Label.VF_B2C_ARGUMENTARIO);
					paginaRedireccion.getParameters().put('id',caso.Id);
                }
                String retorno = '/apex/' + Label.VF_SINI_RETSONDEOEXT+'?idTabBusqClientes='+idTabBusqClientes +'&fase='+Label.SINI_FASE_APERTURA + '&id='+caso.Id;
                paginaRedireccion.getParameters().put('retURL',retorno);
            }
        }
        system.debug('SiniRetornoSondeoExternoController : Constructor : paginaRedireccion : '+paginaRedireccion);
        system.debug('SiniRetornoSondeoExternoController : Constructor : paginaRedireccion.getUrl() : '+paginaRedireccion.getUrl());
    }
    public PageReference navegarSiniGremios() {
        System.debug('SiniRetornoSondeoExternoController: navegarSiniGremios: paginaRedireccion: '+paginaRedireccion);
        System.debug('SiniRetornoSondeoExternoController: navegarSiniGremios: paginaRedireccion.getUrl(): '+paginaRedireccion.getUrl());
        return paginaRedireccion; 
    }
}