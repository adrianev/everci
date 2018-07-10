global without sharing class CNT_QuoteEdit{
	Public String bsId{get; set;}
	Public String woId{get; set;}
	Public WorkOrder wo{get; set;}
	Public Case caso{get; set;}
	Public Account cuenta{get; set;}
	Public String paginaRetorno;
	Public String solicitudExistente;
	Public String fase {get; set;}
	Public String casoRet{get; set;}
	public Integer tipoCaso {get; set;}
    Public BigMachines__Configuration_Record__c CPQSite {get; set;}
    Public Boolean woRevision {get;set;}
    Public Boolean cambioPartidas {get;set;}
    Public Boolean aplicaFranquiciado {get;set;}

	public CNT_QuoteEdit(){
		system.debug('apexpages.currentpage().getparameters() ' + apexpages.currentpage());
		PageReference paginaActual = ApexPages.currentPage();
        String dominio = Label.DOMINIO_CPQ;
		if (paginaActual.getParameters().containsKey('id'))
		{
			casoRet = paginaActual.getParameters().get('id');
		} 
		if (paginaActual.getParameters().containsKey('retorno'))
		{
			paginaRetorno = paginaActual.getParameters().get('retorno');
		} 
		if (paginaActual.getParameters().containsKey('solicitudExistente'))
		{
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}
		if (paginaActual.getParameters().containsKey('fase'))
		{
			fase = paginaActual.getParameters().get('fase');
		}
		if (paginaActual.getParameters().containsKey('enRevision'))
		{
			if(paginaActual.getParameters().get('enRevision') == 'Y')
				woRevision = true;
			
			cambioPartidas = false;
		}
        
        List<BigMachines__Configuration_Record__c> listCPQSites = Util_CPQ.getBigMachRecBySite(new Set<String>{dominio}).values();
																/*[SELECT Id, BigMachines__bm_site__c, BigMachines__process_id__c,
																BigMachines__action_id_open__c, BigMachines__document_id__c, BigMachines__process__c
																FROM BigMachines__Configuration_Record__c 
																WHERE BigMachines__bm_site__c = :dominio];*/
        if(!listCPQSites.isEmpty()){
            CPQSite = listCPQSites.get(0);
        }
        system.debug('RPM CPQ SITE: ' + CPQSite);
		woId =null;bsId =null;
		List<BigMachines__Quote__c>  listBMQ = Util_CPQ.getBigMachQuoByWo(new Set<Id>{apexpages.currentpage().getparameters().get('idWorkO').substring(0,15)}).values();
		//[SELECT BigMachines__Transaction_Id__c , OQU_LKP_Work_Order__c, BigMachines__Is_Primary__c  FROM BigMachines__Quote__c WHERE OQU_LKP_Work_Order__c=:apexpages.currentpage().getparameters().get('idWorkO').substring(0,15)];
		if(!listBMQ.isEmpty()){
			for(BigMachines__Quote__c q : listBMQ ){
				if(q.BigMachines__Is_Primary__c){
					woId = q.OQU_LKP_Work_Order__c  ;
					bsId = q.BigMachines__Transaction_Id__c ;
					break;
				}
			}
			if(woId ==null && listBMQ.size()>0){
				woId = listBMQ [0].OQU_LKP_Work_Order__c  ;
				bsId = listBMQ [0].BigMachines__Transaction_Id__c ;
			}
		}else{
			if (paginaActual.getParameters().containsKey('idWorkO'))
			{
				woId = paginaActual.getParameters().get('idWorkO');
			}
		}
		wo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).get(woId);
		//wo = Util_Orden_Trabajo.queryOT(woId, null, null).get(0);
		if(wo.CaseId != null){
			cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{wo.Case.AccountId}).get(wo.Case.AccountId);
			//cuenta = Util_Cuentas.queryCuenta(wo.Case.AccountId).get(0);
		}else{
			cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{wo.ParentWorkOrder.Case.AccountId}).get(wo.ParentWorkOrder.Case.AccountId);
			//cuenta = Util_Cuentas.queryCuenta(wo.ParentWorkOrder.Case.AccountId).get(0);
		}


		List<Case> listaCasosQuery = new List<Case>();
		if (Util_Siniestro.esSiniestro(caso))
		{
			tipoCaso = 1;
			listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{wo.CaseId}).values();
			//listaCasosQuery = Util_Caso.queryMapSiniCaso(new Set<Id>{wo.CaseId},null,1).values();
			//listaCasosQuery = Util_Siniestro.queryCaso(wo.CaseId, null, 1);
		}
		else
		{
			tipoCaso = 2;
			if(wo.CaseId != null){
				listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{wo.CaseId}).values();
				//listaCasosQuery = Util_B2B.queryCaso(wo.CaseId);
			}else{
				listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{wo.ParentWorkOrder.CaseId}).values();
				//listaCasosQuery = Util_B2B.queryCaso(wo.ParentWorkOrder.CaseId);
			}

		}
		caso = listaCasosQuery.get(0);

	}


	webService static Integer getSumQuotes(String woId) {
		system.debug('RPM getSumQuotes: ' + woId);
		List<BigMachines__Quote__c>  ListBMQ = Util_CPQ.getBigMachQuoByWo(new Set<Id>{woid}).values();
		//[SELECT Id  FROM BigMachines__Quote__c WHERE OQU_LKP_Work_Order__c  =: woid];
		return ListBMQ.size();
	}

	public PageReference volver()
	{
		// Navegar al alta de gremios
		PageReference paginaRedireccion = new PageReference(paginaRetorno);
		paginaRedireccion.getParameters().put('id', casoRet);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		system.debug('>>>>paginaRedireccion ' + paginaRedireccion);
		return paginaRedireccion;
	}//FIN volver() 
	
	public PageReference volverDialogo()
    {
    	Workorder woAct = wo;
    	if(wo.Id != null)
    		//woAct = [Select id,OTR_RES_Liquidar_prof_AI__c, ParentWorkorder.OTR_RES_Liquidar_prof_AI__c,OTR_SEL_Categoria_del_profesional__c from workorder where id = :wo.Id limit 1];
    		woAct = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).get(wo.Id);
    	//if(woAct.OTR_RES_Liquidar_prof_AI__c != woAct.ParentWorkorder.OTR_RES_Liquidar_prof_AI__c){
    	if(woAct.OTR_RES_Liquidar_prof_AI__c.setScale(2) != wo.OTR_RES_Liquidar_prof_AI__c.setScale(2)){
    		
    		//if(woAct.OTR_SEL_Categoria_del_profesional__c == 'Franquiciado'){
    		if(woAct.OTR_CAS_Confianza_en_la_red__c){
    			//woAct.OTR_CAS_AplicaRevision__c = true;
    			woAct.OTR_CAS_AplicaRevision__c = aplicaFranquiciado;
    			update woAct;	
    		}
    			
    		
    		
	        // Navegar a la página de rectificacion de albaranes
	        PageReference paginaRedireccion;
	        paginaRedireccion = new PageReference('/apex/Rectificacion_Albaranes');//TODO: Aquí visual dialogo LABEL
	        paginaRedireccion.getParameters().put('id', wo.Id);
	        paginaRedireccion.getParameters().put('retorno', '/'+wo.ParentWorkorderId);
	        paginaRedireccion.setRedirect(true);
	        return paginaRedireccion;
    	} else {
    		return volver();
    	}
    }//FIN volverDialogo() 
    
    public void checkCambioPartidas(){
    	
    	system.debug('----------wo: '+wo);
    	Workorder woAct = wo;
    	if(wo.Id != null)
    		//woAct = [Select id,OTR_RES_Liquidar_prof_AI__c, ParentWorkorder.OTR_RES_Liquidar_prof_AI__c from workorder where id = :wo.Id limit 1];
    		woAct = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).get(wo.Id);
    	system.debug('----------woAct: '+woAct);	
    	if(woAct.OTR_RES_Liquidar_prof_AI__c != wo.OTR_RES_Liquidar_prof_AI__c){
    		cambioPartidas = true;
    	} else {
    		cambioPartidas = false;
    	}
    	
    }

}