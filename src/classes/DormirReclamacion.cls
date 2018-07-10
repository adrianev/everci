public with sharing class DormirReclamacion {
    
    public Case reclamacion;
	public ApexPages.standardController controlador;
	public Comentario_caso__c comentario {get;set;}
    
    public DormirReclamacion(ApexPages.standardController stdCtr){
    	
    	reclamacion = (Case)stdCtr.getRecord();
    	controlador = stdCtr;
    	
    	PageReference paginaActual = ApexPages.currentPage();
    	
    	if (paginaActual.getParameters().containsKey('id') && !String.isBlank(paginaActual.getParameters().get('id'))){
			reclamacion.Id = paginaActual.getParameters().get('id');
			
			comentario = new Comentario_caso__c(CMC_LKP_Caso__c=reclamacion.Id);
			
			
		} else {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No se ha encontrado Id'));
		}	
    }
    
    
    public PageReference guardar(){
    	if(reclamacion.CAS_DAT_Fecha_Despertar__c==null){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'La fecha es obigatoria'));
    		return null;
    	} else if(String.isBlank(comentario.CMC_TXT_Comentario__c)){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El comentario es obligatorio'));
    		return null;
    	} else {
    		SavePoint sp = Database.setSavePoint();
    		try{
    			reclamacion.Status = Label.CAS_ESTADO_RECLAMACION_DORMIDA;
				insert comentario;
	    		return controlador.Save();
    		}catch(DmlException e){
				Database.rollback(sp);
				system.debug('***** EXCEPTION e :' + e.getStackTraceString());
            	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                	if(!e.getMessage().contains('[COT_TXT_Comentario__c]')){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
					}
             	}
             	return null;
     		}
			catch(Exception e){
				Database.rollback(sp);
				if(!e.getMessage().contains('[COT_TXT_Comentario__c]')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				}
				return null;
    		}
    	}
    }
    
}