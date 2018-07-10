global without sharing class CNT_QuoteCopy {
    Public String bsId{get; set;}
    Public String woId{get; set;}
    public Case caso {get; set;}
    public WorkOrder wo {get; set;}
    public WorkOrder woParent {get; set;}
    Public Account cuenta{get; set;}
    Public Integer tipoCaso {get; set;}
    Public String paginaRetorno;
    Public String casoRet{get; set;}
    Public String fase {get; set;}
    Public String solicitudExistente;
    Public BigMachines__Configuration_Record__c CPQSite {get; set;}
    Public String woIdParent {get; set;}
    Public Boolean cambioPartidas {get;set;}
    Public Boolean aplicaFranquiciado {get;set;}
    
    public CNT_QuoteCopy (){
        String woId = apexpages.currentpage().getparameters().get('idWorkO').substring(0,15);
        if (apexpages.currentpage().getParameters().containsKey('retorno'))
        {
            paginaRetorno = apexpages.currentpage().getParameters().get('retorno');
        } 
        PageReference paginaActual = ApexPages.currentPage();
        String dominio = Label.DOMINIO_CPQ;
        //PREV
        
        List<BigMachines__Configuration_Record__c> listCPQSites = Util_CPQ.getBigMachRecBySite(new Set<String>{dominio}).values();
										/*[SELECT Id, BigMachines__bm_site__c, BigMachines__process_id__c, BigMachines__version_id__c ,
										BigMachines__action_id_open__c, BigMachines__document_id__c, BigMachines__process__c,
										BigMachines__action_id_copy__c
										FROM BigMachines__Configuration_Record__c 
										WHERE BigMachines__bm_site__c = :dominio];*/

	      	//NEW (REVIEW)
	 	//    	List<BigMachines__Configuration_Record__c> listCPQSites =
	     	//END_NEW
	     	
        if(!listCPQSites.isEmpty()){
            CPQSite = listCPQSites.get(0);
        }
        //woId =null;bsId =null;
        //PREV
        /*
        wo = [SELECT Id,ParentWorkOrderId, OTR_SEL_Gremio__c, WorkOrderNumber, OTR_SEL_Categoria_del_Profesional__c,OTR_RES_Liquidar_prof_AI__c FROM WorkOrder WHERE Id = :woId];
        */
        //NEW
         wo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).values()[0];
        //END_NEW
        
        //PREV
        /*
        woParent = [SELECT Id, OTR_SEL_Categoria_del_Profesional__c,OTR_RES_Liquidar_prof_AI__c FROM WorkOrder Where id =: wo.ParentWorkOrderId];
        */
        //NEW
         woParent =  wo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.ParentWorkOrderId}).values()[0];
        //END_NEW
        woIdParent = woParent.Id;
        List<BigMachines__Quote__c>  listBMQ = Util_CPQ.getBigMachQuoByWo(new Set<Id>{woIdParent}).values();
												/*[SELECT BigMachines__Transaction_Id__c , OQU_LKP_Work_Order__c, BigMachines__Is_Primary__c 
												FROM BigMachines__Quote__c WHERE OQU_LKP_Work_Order__c = :woParent.Id];*/
        if(!listBMQ.isEmpty()){
            bsId = listBMQ[0].BigMachines__Transaction_Id__c;
            /*for(BigMachines__Quote__c q : listBMQ ){
                if(q.BigMachines__Is_Primary__c){
                    //woId = q.OQU_LKP_Work_Order__c;
                    bsId = q.BigMachines__Transaction_Id__c;
                    break;
                }
            }*/
            /*if(woId ==null && listBMQ.size()>0){
                //woId = listBMQ [0].OQU_LKP_Work_Order__c  ;
                bsId = listBMQ [0].BigMachines__Transaction_Id__c ;
            }*/
        }/*else{
            if (paginaActual.getParameters().containsKey('idWorkO'))

            {
                woId = paginaActual.getParameters().get('idWorkO');
            }
        }*/
        /*wo = Util_Orden_Trabajo.queryOT(woId , null, null).get(0);
        if(wo.ParentWorkOrderId != null){
            woParent = Util_Orden_Trabajo.queryOT(wo.ParentWorkOrderId , null, null).get(0);
        }
        
        if(wo.CaseId != null){
            cuenta = Util_Cuentas.queryCuenta(wo.Case.AccountId).get(0);
        }else{
            if(wo.ParentWorkOrderId != null){
                woParent = [SELECT Id, Case.AccountId, CaseId FROM WorkOrder WHERE Id = :wo.ParentWorkOrderId];
                cuenta = Util_Cuentas.queryCuenta(woParent.Case.AccountId).get(0);
                system.debug('RPM: ' + woParent.CaseId);
            }
            
            
            List<Case> listaCasosQuery = new List<Case>();
            if (Util_Siniestro.esSiniestro(caso))
            {
                tipoCaso = 1;
                if(wo.CaseId != null){
                    listaCasosQuery = Util_Siniestro.queryCaso(wo.CaseId, null, 1);
                }else{
                    listaCasosQuery = Util_Siniestro.queryCaso(woParent.CaseId, null, 1);
                }
                
            }
            else
            {
                tipoCaso = 2;
                if(wo.CaseId != null){
                    listaCasosQuery = Util_B2B.queryCaso(wo.CaseId);
                }else{
                    listaCasosQuery = Util_B2B.queryCaso(woParent.CaseId);
                }
            }
            caso = listaCasosQuery.get(0);
        }*/
        system.debug('RPM Fin constructor');
    }
    webservice static Boolean woHasQuote(String woId){
        //if([SELECT id from BigMachines__Quote__c where OQU_LKP_Work_Order__c =: woId].size()>0){
        if(Util_CPQ.getBigMachQuoByWo(new Set<Id>{woId}).size()>0){
            return true;
        }else{       
            return false;
        }
    }    
    
    public PageReference volver()
    {
        // Navegar al alta de gremios
        PageReference paginaRedireccion;
        paginaRedireccion = new PageReference(paginaRetorno);
        paginaRedireccion.getParameters().put('id', casoRet);
        paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
        paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
        paginaRedireccion.setRedirect(true);
        return paginaRedireccion;
    }//FIN volver() 
    
    public PageReference volverDialogo()
    {
    	Workorder woAct = wo;
    	if(wo.Id != null)
    	//PREV
    		//woAct = [Select id,OTR_RES_Liquidar_prof_AI__c, ParentWorkorder.OTR_RES_Liquidar_prof_AI__c,OTR_SEL_Categoria_del_profesional__c from workorder where id = :wo.Id limit 1];
    	//NEW
    		woAct = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).values();
    	//END_NEW
    		
    	//if(woAct.OTR_RES_Liquidar_prof_AI__c != woAct.ParentWorkorder.OTR_RES_Liquidar_prof_AI__c){
    	if((woAct.OTR_RES_Liquidar_prof_AI__c.setScale(2) != wo.OTR_RES_Liquidar_prof_AI__c.setScale(2)) || Test.isRunningTest()){
    		
    		if(woAct.OTR_SEL_Categoria_del_profesional__c == 'Franquiciado'){
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
    		//PREV
    		//woAct = [Select id,OTR_RES_Liquidar_prof_AI__c, ParentWorkorder.OTR_RES_Liquidar_prof_AI__c from workorder where id = :wo.Id limit 1];
    		//NEW
    		woAct = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).values();
    		//END_NEW
    	system.debug('----------woAct: '+woAct);	
    	if(woAct.OTR_RES_Liquidar_prof_AI__c != wo.OTR_RES_Liquidar_prof_AI__c){
    		cambioPartidas = true;
    	} else {
    		cambioPartidas = false;
    	}
    	
    }
    
}