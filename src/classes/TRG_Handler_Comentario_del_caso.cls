/**
  * Handler del Trigger TRG_Comentario_del_caso.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Comentario_del_caso {
    public static List<Case> listaCasos;

    /**
      * Tratamiento para el caso after del trigger.
      * 
      * @param triggerNewMap: mapa de registros nuevos del objeto Comentario_caso__c a partir del Id
      * @param triggerNew: lista de registros nuevos del objeto Comentario_caso__c
      * @param triggerOldMap: mapa de registros antiguos del objeto Comentario_caso__c a partir del Id
      * @param triggerOld: lista de registros antiguos del objeto Comentario_caso__c
      */
    public static void tratamientoAfter(Map<Id, Comentario_caso__c> triggerNewMap, List<Comentario_caso__c> triggerNew, 
            Map<Id, Comentario_caso__c> triggerOldMap, List<Comentario_caso__c> triggerOld){
        if(trigger.isInsert){
            inicializarVariables(triggerNew);
            guardaMovimientosOnInsert();
        }
    }

    /**
      * Método que inicializa las variables.
      * 
      * @param comentarios: lista de objetos Comentario_caso__c
      */
    public static void inicializarVariables(List<Comentario_caso__c> comentarios){
        if(listaCasos == null){
            Set<Id> setIdsCasos = new Set<Id>();
            for(Comentario_caso__c comentario : comentarios){
                if (comentario.CMC_TXT_Comentario__c != null){
                    setIdsCasos.add(comentario.CMC_LKP_Caso__c);
                }
            }
            inicializarListaCasos(setIdsCasos);
        }
    }

    /**
      * Método que inicializa la lista de casos.
      * 
      * @param comentarios: conjunto de Ids de Caso
      */
    public static void inicializarListaCasos(Set<Id> setIdsCasos){
        if(!setIdsCasos.isEmpty()){
            listaCasos = Util_Caso.getCaseById(setIdsCasos).values();
        }
    }

    /**
      * [PENDIENTE]
      * 
      */
    public static void guardaMovimientosOnInsert(){
        for (Case caso : listaCasos){
            system.debug('Caso antes de comprobación: ' + caso);
            system.debug('caso.Status= ' + caso.Status);
            system.debug('es sineistro devuelve: ' + Util_Siniestro.esSiniestro(caso));
            if(Util_Siniestro.esSiniestro(caso) && caso.Status != Label.CAS_ESTADO_CERRADO){
            //&& (caso.Status != Label.SINI_ESTADO_CUBIERTO && caso.Status != Label.CAS_ESTADO_CERRADO)){
                //Registro movimiento para acción 14 y 15
                system.debug('LLM entra en 1 con tipo: ' + caso.Type);
                if(caso.Type==label.CAS_TIPO_REPARABLE){
                    system.debug('LLM entra en 14');
                    Util_Movimientos.compruebaEnviable(caso.Id,caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'14');
                } else if(caso.Type==label.CAS_TIPO_INDEMNIZABLE){
                    system.debug('LLM entra en 15');
                    Util_Movimientos.compruebaEnviable(caso.Id,caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'15');
                }
            }
        }
    }
}