/**
  *
  * Clase controladora del Componente "ActivityList" encargado de la mostrar 
  *	el historial de actividades de trabajo de los casos
  * 
  */ 
public without sharing class ActivityListController {
    @AuraEnabled
    public static List<Task> getListTasks(String idRelatedTo, String filter){
        List<Task> taskList=new List<Task>();
        String query='Select Subject, Status, CreatedDate, LastModifiedDate from Task where WhatId=\''+String.escapeSingleQuotes(idRelatedTo)+'\'';
        if(filter != ''){
            query=query + ' and TaskSubtype = \'' + String.escapeSingleQuotes(filter) + '\'';
        }
        System.debug(query);
       	
        try{
       		taskList = Database.query(query); 
        }
        catch(Exception e){
             throw new AuraHandledException(e.getMessage()+',query='+query);
        }    
            
       return taskList;
    }
    
    @AuraEnabled
    public static List<sObject> getListActivities(String idRelatedTo, String filter){
       List<Case> caseList=new List<Case>();
       caseList=[Select (Select Subject, Status, TAR_DAT_Inicio_Llamada__c, TAR_DAT_Fin_Llamada__c from OpenActivities) from Case where id=:idRelatedTo]; 
        
        return caseList;
    }
}