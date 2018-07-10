public class SiniConfirmacionFinalizadaController {
    public Case intervencion{get;set;}
    public SiniConfirmacionFinalizadaController(ApexPages.standardController standarController) {
        intervencion=new Case();        
        String idIntervencion;
        String mensaje = '';
        Boolean esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
        Integer contador=0;
        Map<String, String> mapParameters=ApexPages.currentPage().getParameters();
        for(String parameterAux:mapParameters.keySet()){
            if('Id'.equalsIgnoreCase(parameterAux)){
				idIntervencion=mapParameters.get(parameterAux);
                intervencion=new Case(Id=idIntervencion);
			}
            System.debug('SiniConfirmacionFinalizadaController: constructor: contador: '+contador);
            System.debug('SiniConfirmacionFinalizadaController: constructor: parameterAux: '+parameterAux);
            if(String.valueOf(contador).equalsIgnoreCase(parameterAux)){
            	if(contador == 0){
            		mensaje += mapParameters.get(parameterAux);
            	}
            	else{
            		mensaje += '<br/>' + mapParameters.get(parameterAux);
            	}										
			}
            contador++;
        }
        if(esProfesional){
        	if(mapParameters.get('0') == 'La confirmación se ha realizado con éxito.'){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.CNF_MENSAJE_EXITO));
        	}
        	else {
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.CNF_MENSAJE_BLOQUEADO));
        	}
        }
        else{
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, mensaje));
        }
    }
    
    public PageReference navegarDetalleCaso() {
    	Callout_ClickToCall.Resultado res = new Callout_ClickToCall.Resultado();
    	Confirmacion__c confir = [SELECT CNF_SEL_Tipo__c, CNF_TFN_Telefono_1__c FROM Confirmacion__c WHERE CNF_LKP_ParentId__c = :intervencion.Id];
        if(confir.CNF_SEL_Tipo__c == Label.CNF_TIPO_RECHAZO_TOTAL){
        	res =  Util_Click2Call.solicitarLlamadaClick2Call(Label.NOTIFICACION_RECHAZO_CLIENTE, intervencion.Id, confir.CNF_TFN_Telefono_1__c);
        }
		PageReference paginaNavegar = new PageReference('/' + intervencion.Id);
		paginaNavegar.setRedirect(true);
		return paginaNavegar;
    }
}