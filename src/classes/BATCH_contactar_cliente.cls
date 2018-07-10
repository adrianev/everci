global class BATCH_contactar_cliente implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    public List<Task> tareaList;
    public List<Callout_contactar_RQ> contactarList;
    public Map<Id, Confirmacion__c> mapConf;

    global BATCH_contactar_cliente() {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id, CNF_SEL_Estado__c, CNF_LKP_ParentId__c FROM Confirmacion__c WHERE CNF_SEL_Estado_Confirmacion__c = '
        +  Label.PTE_CONTACTAR_CLIENTE;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Confirmacion__c> scope) {
    
        for(Confirmacion__c confi: scope){
                mapConf.put(confi.CNF_LKP_ParentId__c, confi);
            } 

       Callout_contactar_RQ llamada = new Callout_contactar_RQ();
       List<Configuracion_VDN__mdt> conf = Util_Metadatos.getConfVDNMetadataByDevName(new Set<String>{Label.RECHAZO_EN_CONFIRMACION}).values();
       for(Confirmacion__c sc: scope){
            llamada = new Callout_contactar_RQ();
            llamada.idCarga = conf[0].LoadId__c;
            llamada.idRef = sc.CNF_LKP_ParentId__c;
            llamada.idServicio = conf[0].ServiceId__c;
            contactarList.add(llamada);
       }
       
    }

    global void finish(Database.BatchableContext BC) {

        Task tarea;
       tareaList = new List<Task>();
       Callout_contactar.ResultadoFinal res = Callout_contactar.sendDatos(contactarList);
       if(res.resultado.get(0).codigo == 'API001'){
            for(Callout_contactar.Completadas com: res.completadas){
                tarea = new Task();
                tarea.Subject = label.TAREA_INFORMAR_RECHAZO;
                tarea.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_TAR_REGISTRO_LLAMADA);
                tarea.TAR_LKP_Caso__c = com.customdata1;
                tarea.OwnerId = mapConf.get(com.customdata1).CNF_LKP_ParentId__r.OwnerId;
                tareaList.add(tarea);
            }
       }
       
        if(!tareaList.isEmpty()){
            insert tareaList;
       } 
    }
}