public without sharing class ActivityListController {
	@AuraEnabled
    public static List<Task> getListTasks(String idRelatedTo){
       return [Select Subject, Status,CreatedDate, LastModifiedDate from Task where WhatId=:idRelatedTo]; 
    }
    
    @AuraEnabled
    public static Integer getTotalCount(String idRelatedTo){
        AggregateResult results = [select  count(Id) total  from Task where WhatId=:idRelatedTo ];
        Integer total =(Integer)results.get('total') ; 
        return total;
    } 
}