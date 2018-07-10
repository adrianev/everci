/**
  *
  * Clase controladora del Componente "ModificarCita" encargado de la mostrar 
  *	la botonera dentro de la página de cita de servicio de la comunidad
  * 
  */ 
public without sharing class ModificarCitaController {
    /**
     * getURLModificacionCita Recupera la URL de acceso a la Landing
     * @param  recordId  Id del service appointment
     * @param  timestamp Timestamp de la operación
     * @param  urlBack   URL de vuelta una vez modificada la cita
     * @return           return URL de acceso a Landing
     */
    @AuraEnabled
    public static String getURLModificacionCita(String recordId, String timestamp, String urlBack) {
        String urlReturn='';
        String token='';
        String fechaEntrega='';

        //Recuperamos información de la Cita
        ServiceAppointment sApp=infoCitaServicioModificable(recordId);

        //Datetime dt = datetime.newInstance(dEntrega.year(), dEntrega.month(),dEntrega.day());
        //fechaEntrega=sApp.ArrivalWindowStartTime.format('YYYY-MM-DD');
        fechaEntrega=sApp.ArrivalWindowStartTime.year()+'-'+sApp.ArrivalWindowStartTime.month()+'-'+sApp.ArrivalWindowStartTime.day();

        //Recuperamos la procedencia del caso.
        WorkOrder wo=[select id, case.CAS_LKP_Procedencia__r.Name from workorder where id=:sApp.ParentRecordId];

        //Recuperamos la configuración de landing.
        //!!!Meter en un label.
        Communities_Secret_Word__mdt secretword = [Select Secret_Word__c, URL__c from Communities_Secret_Word__mdt where MasterLabel='Landing Secret Word'];

        //Generamos el token MD5(idCita+procedencia+fechaEntrega+secret+timestamp)
        Blob targetBlob = Blob.valueOf(sApp.AppointmentNumber+fechaEntrega+secretword.Secret_Word__c+timestamp);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        token=EncodingUtil.convertToHex(hash);
        
        urlBack=EncodingUtil.urlEncode(urlBack,'UTF-8');

        urlReturn=secretword.URL__c+'?procedencia='+wo.case.CAS_LKP_Procedencia__r.Name+'&urlback='+urlBack+'&token='+token+'&ts='+timestamp+
        '&codigoCita='+sApp.AppointmentNumber+'&fechaEntrega='+fechaEntrega;

        return urlReturn;
    }

    /**
     * anularCita Anula la cita pasada por parámetro
     * @param  recordId Id del service appointment
     */
    @AuraEnabled
    public static void anularCita(String recordId) { 
        Savepoint sp;
        //Recuperamos información de la Cita
        ServiceAppointment sApp=infoCitaServicioModificable(recordId);

        //Ponemos el estado de la cita a anulada
        sApp.Status=Label.CIT_ESTADO_ANULADA;
        try{
            sp = Database.setSavepoint();
            update sApp;
        }catch(Exception e){
            Database.rollback( sp );
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * estaCitaAnulada Verifica si la cita está anulada para deshabilitar los botones del componente
    * @param  recordId Id del service appointment
    * @return          return true si está anuladao en otro caso false
    */
    @AuraEnabled
    public static Boolean estaCitaAnulada(String recordId){
        Boolean estaAnulada=false;
        
        //Comprobamos si la cita está anulada, para deshabilitar o no los botones.
        List<ServiceAppointment> lApp= [Select Status from ServiceAppointment where id=:recordId and Status in (:Label.CIT_ESTADO_ANULADA,:Label.CIT_ESTADO_ANULADA_POR_CAMBIO)];
        
        //Si la lista devuelve resultado entonces la cita está anulada.
        if(!lApp.isEmpty()){
            estaAnulada=true;
        }

        return estaAnulada;
    }

    /**
     * infoCitaServicioModificable Devuelve la información de la cita de servicio. Si la cita no es modificable se devuelve un error
     * @param  recordId recordId Id del service appointment
     * @return          return Información de Cita de Servicio
     */
    private static ServiceAppointment infoCitaServicioModificable(String recordId){
        ServiceAppointment sApp;

        Id idCitaServicio= Id.valueOf(recordId);

        //Recuperamos información de la cita
        Set<Id> setIdCita= new Set<Id>();
        setIdCita.add(Id.valueOf(recordId));

        System.debug(setIdCita);

        Map<Id,ServiceAppointment> mApp= Util_Cita_Servicio.getMapCitasById(setIdCita);

        System.debug(mApp);
        
        for (Id key : mApp.keySet()) {
            sApp=mApp.get(key);
        }

        //Obtenemos la fecha de hoy
        Datetime hoy = system.now();
		
        if(sApp.ArrivalWindowStartTime != null){
            Long milisegundos = sApp.ArrivalWindowStartTime.getTime() - hoy.getTime();
            Long segundos = milisegundos / 1000;
            Long minutos = segundos / 60;
            Long horas = minutos / 60;
    
            //Si la fecha de entrega es menor que el número de horas configurado en el label. Levantamos excepción.
            if( horas < Integer.valueof(Label.CIT_HORAS_MOD_CITA) ){
                throw new AuraHandledException(Label.CIT_NO_MODIFICABLE);
            }
        }

        return sApp;
    }
}