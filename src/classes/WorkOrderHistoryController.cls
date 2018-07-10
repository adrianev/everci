public without sharing  class WorkOrderHistoryController {
    @AuraEnabled
    public static List<WorkOrderHistory> getWoHistories(String idRelatedTo){
        List<WorkOrderHistory> wohList=new List<WorkOrderHistory>();
        String fl = 'toLabel(Field)';
        String nv = 'toLabel(NewValue)';
        String ov = 'toLabel(OldValue)';
        String query='Select CreatedDate,'+ fl +', '+ nv +' , '+ ov +' from  WorkOrderHistory ' + 
            ' where workorderid=\''+String.escapeSingleQuotes(idRelatedTo)+'\'';
              
        try{
       		wohList = Database.query(query);
          	//wohList.sort();
        }
        catch(Exception e){
             throw new AuraHandledException(e.getMessage()+',query='+query);
        }    
            
       return wohList;
    }
}