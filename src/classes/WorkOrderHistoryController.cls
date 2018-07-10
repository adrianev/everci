/**
  *
  * Clase controladora del Componente "WorkOrderHistory" encargado de la mostrar 
  *	el historial de órdernes de trabajo de los casos
  * 
  */
public without sharing  class WorkOrderHistoryController {
    @AuraEnabled
    public static List<WorkOrderHistory> getWoHistories(String idRelatedTo){
        List<WorkOrderHistory> qWohList=new List<WorkOrderHistory>();
        List<WorkOrderHistory> wohList = new List<WorkOrderHistory>();
        
        System.debug('idRelatedTo: '+idRelatedTo);
        String fl = 'toLabel(Field)';
        String nv = 'toLabel(NewValue)';
        String ov = 'toLabel(OldValue)';
        String query='Select CreatedDate,'+ fl +', '+ nv +' , '+ ov +' from  WorkOrderHistory ' + 
            ' where workorderid=\''+String.escapeSingleQuotes(idRelatedTo)+
            '\' order by CreatedDate desc';
              
        try{
            System.debug(query);
            qWohList = Database.query(query);
            
            for(WorkOrderHistory woh : qWohList){
                String newval=String.valueOf(woh.NewValue);
                String oldval=String.valueOf(woh.OldValue);
                //Descartamos los campos ID
                if(isValidId(newval)==false && isValidId(oldval)==false) {
					wohList.add(woh);
                }
            }
        }
        catch(Exception e){
            e.getStackTraceString();
            throw new AuraHandledException(e.getMessage());
        }    
        system.debug(wohList);  
       return wohList;
    }
    
    @TestVisible 
    static private Boolean isValidId(String strId) {
    	Boolean isValid = (strId InstanceOf ID) ? true : false ;
    	return isValid ;
	}
}