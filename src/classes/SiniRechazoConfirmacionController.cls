public class SiniRechazoConfirmacionController {
    public Confirmacion__c confirmacion{get;set;}
    public Boolean exitoAlGuardar{get;set;}

    public SiniRechazoConfirmacionController(ApexPages.StandardController stdCtr) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Se ha obtenido un rechazo en Confirmación. En breves momentos le llamará un Gestor.'));
        confirmacion=new Confirmacion__c(Id=stdCtr.getRecord().Id);
        for(Confirmacion__c confirmacionAux:Util_Siniestro.queryConfirmacionesPorId(new Set<Id>{stdCtr.getRecord().Id}).values()) {
            confirmacion=confirmacionAux;
        }
        exitoAlGuardar=false;
    }

    public void finalizarRechazoConfirmacion() {
        if(String.isEmpty(confirmacion.CNF_TFN_Telefono_1__c)) {
            ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.ERROR, 'Por favor, introduce un número de teléfono de contacto'));
        } else {
            try {
                
                exitoAlGuardar=true;
                system.debug('<<<<<<<<< llamada click2call 1 ' + Label.RECHAZO_EN_CONFIRMACION);
                system.debug('<<<<<<<<< llamada click2call 2 ' + confirmacion.CNF_LKP_ParentId__c);
                 system.debug('<<<<<<<<< llamada click2call 3 ' + confirmacion.CNF_TFN_Telefono_1__c);
                Callout_ClickToCall.Resultado res =  Util_Click2Call.solicitarLlamadaClick2Call(Label.RECHAZO_EN_CONFIRMACION_PROF, confirmacion.CNF_LKP_ParentId__c, confirmacion.CNF_TFN_Telefono_1__c);
                confirmacion.CNF_SEL_Estado_Confirmacion__c = Label.CNF_ESTADO_PENDIENTE_CONTACTAR_PROF;
                Database.upsert(confirmacion);
            } catch(Exception e) {
                ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.ERROR, 'Ha ocurrido un error, por favor, inténtelo de nuevo'));
            }
        }
    }

    public PageReference navegarDetalleCaso() {
        PageReference paginaDestino=new PageReference('/'+confirmacion.CNF_LKP_ParentId__c);
        system.debug('paginaDestino: ' + paginaDestino.getUrl());
        return paginaDestino;
    }

}