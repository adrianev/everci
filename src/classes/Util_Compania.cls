/**
 * Clase de funciones auxiliares relativas a las Compañías.
 * 
 * @author EVERIS
 */
public without sharing class Util_Compania
{
    // Mapa de Compañías cuya clave es el Id de Salesforce
    public final static Map<Id, Account> CIA_BY_IDSF = getCIAByIdSF();
    // Mapa de Compañías cuya clave es el Código de CIA
    public final static Map<String, Account> CIA_BY_IDHS = getCIAByIdHS();

    /**
     * Carga el mapa de Compañías cuya clave es el Id de Salesforce.
     * 
     * @return mapa de Compañías cuya clave es el Id de Salesforce
     */
    private static Map<Id, Account> getCIAByIdSF()
    {
        Map<Id, Account> mapaCIA = null;
        if (CIA_BY_IDSF == null)
        {
            mapaCIA = Util_Cuentas.queryMapCuentaByRT(new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA),Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1)});
            /*mapaCIA = new Map<Id, Account>(
                    [SELECT Id,
                     Name,
                     CUE_CAS_No_Permite_Servicio_B2C__c,
                     CUE_DIV_Limite_Actuacion__c,
                     CUE_DIV_Limite_Graves__c,
                     CUE_SEL_GestionIndemnizable__c,
                     CUE_TXT_Ayuda_Busqueda__c,
                     CUE_TXT_Identificador__c,
                     CUE_TXT_Numero_Documento__c,
                     CUE_TXT_Presentacion__c 
                     FROM Account
                     WHERE RecordTypeId = :Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA) OR RecordTypeId = :Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1)]);*/
        }
        return mapaCIA;
    }

    /**
     * Carga el mapa de Compañías cuya clave es el Código de CIA.
     * 
     * @return mapa de Compañías cuya clave es el Código de CIA
     */
    private static Map<String, Account> getCIAByIdHS()
    {
        Map<String, Account> mapaCIA = new Map<String, Account>();
        for (Account cia : CIA_BY_IDSF.values())
        {
            mapaCIA.put(cia.CUE_TXT_Identificador__c, cia);
        }
        return mapaCIA;
    }

    /**
     * Reemplaza los tokens correspondientes en el texto de Presentación de una Compañía.
     * 
     * @param presentacion Texto de presentación.
     * @return texto de presentación actualizado
     */
    public static String reemplazarTokensPresentacion(String presentacion)
    {
        String aux = presentacion;
        if (aux != null)
        {
            aux = aux.replace('#USUARIO#', '"' + UserInfo.getName() + '"');
            aux = aux.replace('#SALUDO#', generarSaludo());
        }
        return aux;
    }

    /**
     * Genera el texto de saludo en función de la hora actual.
     * 
     * @return texto de saludo en función de la hora actual
     */
    public static String generarSaludo()
    {
        String saludoRetorno;
        Datetime fechaActual = System.now();
        Integer hora = fechaActual.hour();
        if(hora >= 6 && hora < 12){
            saludoRetorno = 'Buenos días';
        }else if (hora >= 12 && hora < 19) {
            saludoRetorno = 'Buenas tardes';
        }else {
            saludoRetorno = 'Buenas noches';
        }
        return saludoRetorno;
    }

    public static void comprobacionCiaTramita(Case caso, Map<Id, Account> mapaCuentas){
        /*Si el Type del siniestro es indemnizable y:
        >>La Compañía tiene en el campo CUE_SEL_GestionIndemnizable__c = No Gestiona Indemnizables --> 
                El siniestro navega al detalle del caso 
                El estado cambia a Cerrado
                Se marca el check de transferido
                Mediante un process builder, se envía un email de salida a la cia
        >>La Compañía tiene en el campo CUE_SEL_GestionIndemnizable__c = Registra Documentación Indemnizable --> 
                El siniestro navega a Sini_Indemn_Documentos
                Se registran los documentos solicitados
                Se navega al detalle del siniestro
                El estado cambia a Cerrado
        >>La Compañía tiene en el campo CUE_SEL_GestionIndemnizable__c = Gestiona Indemnizables  --> 
                El siniestro navega a Sini_Indemn_Documentos
                Se registran los documentos solicitados
                Se navega al detalle del siniestro
                El estado cambia a SINI_ESTADO_PDTE_DOC_INI
         */
        Account compania = mapaCuentas.get(caso.CAS_LKP_Compania__c);
        system.debug('>>>>Si la CIA es Almudena Seguros y es indemnizable, se cierra y se marca el check de transferido ');
        system.debug('>>>>caso.Type: ' + caso.Type);
        if (caso.Status != Label.CAS_ESTADO_CERRADO 
                && caso.Type == Label.CAS_TIPO_INDEMNIZABLE 
                && compania != null)
        {
            //La Compañía tiene en el campo CUE_SEL_GestionIndemnizable__c = SINI_NO_GESTIONAINDEMNIZABLES -->
            if(compania.CUE_SEL_GestionIndemnizable__c == Label.SINI_NO_GESTIONAINDEMNIZABLES)
            {
                caso.Status = Label.CAS_ESTADO_CERRADO;
                caso.CAS_CAS_Transferido__c = true;
            }
            //La Compañía tiene en el campo CUE_SEL_GestionIndemnizable__c = SINI_REGISTRA_DOC_INDEMNIZABLES -->
            else if(compania.CUE_SEL_GestionIndemnizable__c == Label.SINI_REGISTRA_DOC_INDEMNIZABLES)   
            {
                caso.Status = Label.CAS_ESTADO_CERRADO;
            }
            //La Compañía tiene en el campo CUE_SEL_GestionIndemnizable__c = SINI_GESTIONAINDEMNIZABLES -->
            else if(compania.CUE_SEL_GestionIndemnizable__c == Label.SINI_GESTIONAINDEMNIZABLES)
            {
                caso.Status = Label.SINI_ESTADO_PDTE_DOC_INI;
            }
        }
    }

    public static Map<String, Account> queryAccountById(Set<String> setIdCuentas) {
        Map<String, Account> mapCuentas=new Map<String, Account>();
        if(!setIdCuentas.isEmpty()) {
            for(List<Account> listaCuentasAux:[SELECT Id,
														Name,
														CUE_LKP_VDN_principal__r.Name,
														CUE_CAS_Permite_Apertura_Sin_Poliza__c,
														CUE_EMA_Email__c,
														CUE_SEL_Tipo_Documento__c,
														CUE_TXT_Numero_Documento__c,
														CUE_TXT_Identificador__c
            									FROM Account
            									WHERE Id IN:setIdCuentas]) {
                mapCuentas.putAll(listaCuentasAux);
            }
        }
        return mapCuentas;
    }
    
    /*		queryAllCompanias: Obtiene un mapa de todas las Compañías que tienen un acuerdo con Homeserve que hay en el sistema
   	 *		@return mapa de Cuentas de compañías en el sistema
    */
    public static Map<Id, Account> queryAllCompanias() {
        Map<Id, Account> mapCuentas=new Map<Id, Account>();
       
            for(List<Account> listaCuentasAux:[SELECT Id,
														Name,
														CUE_LKP_VDN_principal__r.Name,
														CUE_CAS_Permite_Apertura_Sin_Poliza__c,
														CUE_EMA_Email__c,
														CUE_SEL_Tipo_Documento__c,
														CUE_TXT_Numero_Documento__c,
														CUE_TXT_Identificador__c
            									FROM Account
            									WHERE RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA) ]) {
                mapCuentas.putAll(listaCuentasAux);
            }
        return mapCuentas;
    }
    /*		queryAllTipoDeProductosCIA: Obtiene un mapa de todas los tipos de producto de compañías 
   	 *		@return mapa de Tipo_Producto_CIA__c del sistema
    */
      public static Map<Id, Tipo_Producto_CIA__c> queryAllTipoDeProductosCIA() {
        Map<Id, Tipo_Producto_CIA__c> mapTipoProductos=new Map<Id, Tipo_Producto_CIA__c>();
            for(List<Tipo_Producto_CIA__c> listaTipoProductos: [SELECT Id, Name FROM Tipo_Producto_CIA__c] ) {
                mapTipoProductos.putAll(listaTipoProductos);
            }
        return mapTipoProductos;
    }
    
     public static Map<Id, Tipo_Producto_CIA__c> queryTipoDeProductosCIAByCIA(Set<String> namesCompania) {
     	Map<Id, Tipo_Producto_CIA__c> mapTipoProductos=new Map<Id, Tipo_Producto_CIA__c>();
     	if(!namesCompania.isEmpty() && namesCompania!=null){
     		String[] nameFilters ;
     		for(String str : namesCompania){
     			 nameFilters.add('%'+str+'%');
     		}
            for(List<Tipo_Producto_CIA__c> listaTipoProductos: [SELECT Id, Name FROM Tipo_Producto_CIA__c WHERE Name LIKE :nameFilters] ) {
                mapTipoProductos.putAll(listaTipoProductos);
            }
     }
        return mapTipoProductos;
    }
    
      public static Map<Id, Tipo_Producto_CIA__c> queryTipoDeProductosCIAByCIAId(Set<Id> idCompanias) {
     	Map<Id, Tipo_Producto_CIA__c> mapTipoProductos=new Map<Id, Tipo_Producto_CIA__c>();
     	if(!idCompanias.isEmpty() && idCompanias!=null){
            for(List<Tipo_Producto_CIA__c> listaTipoProductos: [SELECT Id, Name FROM Tipo_Producto_CIA__c WHERE 
            TPR_LKP_Compania__c In :idCompanias] ) {
                mapTipoProductos.putAll(listaTipoProductos);
            }
     }
        return mapTipoProductos;
    }
    
    
}