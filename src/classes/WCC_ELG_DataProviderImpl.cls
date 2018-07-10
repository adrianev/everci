//public class WCC_ELG_DataProviderImpl {


global with sharing class WCC_ELG_DataProviderImpl implements sortablegrid.sdgIDataProvider {
    
    //Whether to show this class in the AppBuilder.
    //Usually set to true.  Set to false if you intend to inherit this class and you don't want this class to be visible.
    
    global static Boolean isUserSelectable(){
        return true;
    }
    
    //Method to retrieve data:
    
    //SDG object - which is usually irrelevant in the case of custom Apex data providers
    //SDGRequest - provides the details of what's being requested:
    //  String ParentRecordID: recordId of the page
    //  Integer Pagesize: how many records the client is requesting 	
    //  Integer PageId: Number of the page of data (note this is 1 based)
    //  String SortColumn:  Id of column that's being searched for (Id from the SDGField created in LoadSDG)
    //  String SortOrder: A or D
    //  List<sortablegrid.SDGFilter> Filters: list of filters
    //      String FilterValue: value provided in UI for filtering
    //      String FilterOperator: value provided as operator ie GT greater than, = equals, etc
    //Note there are other fields available in the request, but they're for routing to other data providers - in this case, you can ignore them.
    //
    
    global static sortablegrid.SDGResult getData(sortablegrid.SDG coreSDG,  sortablegrid.SDGRequest request){
        
        sortablegrid.SDGResult result = new sortablegrid.SDGResult();
        try{
            
            integer dataoffset = (request.pageid-1) * request.pagesize;
            integer datalimit = request.PageSize;        
            List<String> filters = new List<String>();
            System.debug('request ' + request);
            //FILTER - not complete!
            if (request.Filters!=null){
                
                for(sortablegrid.SDGFilter filter: request.filters){
                    
                    String fo = filter.FilterOperator;
                    String fv = String.escapeSingleQuotes(filter.FilterValue.trim());
                   	String fid = filter.SDGFieldID;
                    filters = filterSwitch (filters, fid, fo, fv);
                   /* if(fid.equals('3')){
                        System.debug('fid y filtervalue ' + fid +' '+ filter.FilterValue);
                        Datetime fv =  DateTime.parse(filter.FilterValue.replace('-', '/')  +' 00:00:00+0000');
                        System.debug('Datetime en filter '+ fv);
                        filters = filterSwitch (filters, fid, fo, fv);
                    }
                    else{ 
                    	String fv = String.escapeSingleQuotes(filter.FilterValue.trim());                        
                    	filters = filterSwitch (filters, fid, fo, fv, null);
                 	}*/

                }
            }
            String filterstring = String.join(filters, ' AND ');
            String aux = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
            if (!String.isblank(filterstring)){
                filterstring = 'WHERE ' + filterstring + ' AND Case.RecordType.developerName!=\'CAS_Reclamacion\'' + ' AND RecordTypeId !=: aux ';
            }
            else{
                filterstring = 'WHERE Case.RecordType.developerName!=\'CAS_Reclamacion\'' + ' AND RecordTypeId !=: aux ';
            }

            //Revisar si el usuario tiene asociado una cuenta hija de WORTEN, en dicho caso hay que filtrar por aquellas WO que pertenezcan a la cuenta hija
            User infoUser=inforAccountUser();
            String filterAccount='';
            
            if(infoUser != null){
                 System.debug('infoUser.contact.account.Id='+infoUser.contact.account.Id);
                filterstring += ' AND case.account.Id = \''+ infoUser.contact.account.Id +'\'';     
            }
            
            String sSortClause = orderClause(request.SortColumn, request.sortOrder);
            
            
            string query = 'select Case.CAS_TXT_Num_Caso_HS__c, toLabel(Status), Case.CAS_DAT_Fecha_Apertura__c, OTR_TXT_Num_OrdenTrabajo_HS__c, toLabel(OTR_SEL_Gremio__c), Case.Account.CUE_TXT_Numero_Documento__c, Case.CAS_LKP_Punto_de_venta__r.Name,  OTR_FOR_Importe_total_siniestro__c from WorkOrder '  + filterstring + ' ' + sSortClause + ' limit :datalimit offset :dataoffset';
            
            System.debug('Consulta ' + query);

            string sQueryCount = 'select count() from WorkOrder ' + filterstring;
            integer count= database.countQuery(sQueryCount);
            result.data = database.query(query);      
            result.query=query; //Only used for the debug log
            System.debug('Query: ' + query);
            result.FullQueryCount = 0;
            if (result.data!=null){
                System.debug('Size: ' + result.data.size());
                result.FullQueryCount = count;
            }
            result.pagecount = result.FullQueryCount/request.PageSize;
            result.isError = false;
            result.ErrorMessage = result.FullQueryCount+ ' : ' + request.PageSize;
        }
        
        catch (Exception ex){
            result.isError = true;
            result.ErrorMessage = ex.getMessage();
        }
        return result;
    }
    
    //Entry point to get the configuration.
    //Implement this to return a full SDG of fields and actions
    
    global   sortablegrid.SDG LoadSDG(String SDGTag, String ParentRecordId){
        
        system.debug('CustomDataProviderExample:LoadSDG');
        sortablegrid.SDG CoreSDG = new sortablegrid.SDG( 'CustomDataProviderExample' );    
        CoreSDG.SDGActions = getActions();
        CoreSDG.SDGFields = getFields();
        return CoreSDG;
    }
    
    //Specify the actions available on the grid:
    //String Id: unique identifier
    //String Label: for the link
    //String Event: Lightning Event to raise
    //String Type: Render as a 'List Button', 'Row Button', 'Row', 'List', 'Multi List'
    //String Payload: payload for the event - can be parameterised with #delimited# values
    //String Icon: Icon to render
    //Integer actionorder: Order of buttons/menuitems
    @TestVisible
    private List<sortablegrid.SDGAction> GetActions(){
        
        List<sortablegrid.SDGAction> actions = new List<sortablegrid.SDGAction>();
        actions.add(new sortablegrid.SDGAction('1', 'Detalle', 'e.force:navigateToSObject', 'Row Button', '{"recordId":"#Id#"}','', 1));
        
        return actions;
    }
    
    
    /**
     * inforAccountUser Devuelve la información de la cuenta asociada al usuario siempre que no sea AGC
     * @return   return Usuario que no pertenece a AGC
     */
    private static User inforAccountUser(){
        User userInf;

        List<User> lUserInf = [select id, contact.account.CUE_LKP_Cuenta_principal__r.Id , contact.account.Id  from User
                    where contact.account.CUE_LKP_Cuenta_principal__r.Name != null and Id = : UserInfo.getUserId()
                    //Cuando se configura worten descomentar
                    and (contact.account.Name != 'AGC' AND contact.account.CUE_LKP_Cuenta_principal__r.Name != 'AGC')];

        if(!lUserInf.isEmpty()){
            userInf=lUserInf.get(0);
        }

        return userInf;
    }
    
    
    //Specify the behaviour of the grid - ie which fields to display on the page:
    //String ID - used to key filters back to the request
    //String Label: Column Header text
    //String ColumnName: Name within the SOQL - used by the LC to retrieve the value from the query results
    //String FieldType: STRING, NUMBER, DATE etc - determines rendering
    //String FieldStyle: Custom Renderer options:  Summarize:Total, Age etc
    //Boolean canSort: Make the columns click to sort (does not actually perform sorting)
    //Boolean canFilter: Renders a filter component (does not actually perform filtering)
    //Boolean isHTMLFormatted: Do you want to render the output as raw unescaped html.  Usually false.
    //List<sortablegrid.AuraSelectOption> options: List of piclist options for dropdowns for filters
    //Integer FieldOrder: order on the page
    /*WorkOrders - Servicios
    Intervención - SI
    Estado - SI
    Fecha de Apertura - SI
    Número de Servicio - SI
    Gremio - SI
    CIF (Case)
    Dirección Completa (Case)
    Importe  - Si
    */
    @TestVisible
    private List<sortablegrid.SDGField> GetFields(){
        
        List<sortablegrid.SDGField> fields = new List<sortablegrid.SDGField>();
        List<sortablegrid.AuraSelectOption> gremioOptions = new List<sortablegrid.AuraSelectOption>();
        sortablegrid.AuraSelectOption optionGremio1 = new sortablegrid.AuraSelectOption('','',false);
        sortablegrid.AuraSelectOption optionGremio2 = new sortablegrid.AuraSelectOption('21','AIRE ACONDICIONADO',false);
        sortablegrid.AuraSelectOption optionGremio3 = new sortablegrid.AuraSelectOption('31','ALARMAS',false);

        gremioOptions.add(optionGremio1);
        gremioOptions.add(optionGremio2);
        gremioOptions.add(optionGremio3);
        

        fields.add( new sortablegrid.SDGField('1', 'Intervención', 'Case.CAS_TXT_Num_Caso_HS__c', 'STRING', '', true, true, false, null, 1));
        fields.add( new sortablegrid.SDGField('2', 'Estado', 'Status', 'STRING', '', true, true, false, null, 2));
        fields.add( new sortablegrid.SDGField('3', 'Fecha de Apertura', 'Case.CAS_DAT_Fecha_Apertura__c', 'DATE', '', true, true, false, null, 3));
      	fields.add( new sortablegrid.SDGField('4', 'Número de Servicio', 'OTR_TXT_Num_OrdenTrabajo_HS__c', 'STRING', '', true, true, false, null, 4));
        fields.add( new sortablegrid.SDGField('5', 'Gremio', 'OTR_SEL_Gremio__c', 'STRING', null, true, true, false, null, 5));
        fields.add( new sortablegrid.SDGField('6', 'CIF', 'Case.Account.CUE_TXT_Numero_Documento__c', 'STRING', '', true, true, false, null, 6));
        fields.add( new sortablegrid.SDGField('7', 'Punto de venta', 'Case.CAS_LKP_Punto_de_venta__r.Name', 'STRING', '', true, true, false, null, 7));
        //fields.add( new sortablegrid.SDGField('8', 'Importe', 'OTR_FOR_Importe_total_siniestro__c', 'STRING', '', true, true, false, null, 8));

        return fields;
    }

    @TestVisible
    private static List<String> filterString (List<String> filters, String fo, String fv, String fieldName, Boolean isPickList){
        String sFieldName = fieldName;

        if (isPickList) {
            sFieldName = 'toLabel(' + sFieldName + ')'; 
        }
        if  (String.isNotBlank(fv)){          
            if (fo.equals('=')){
                filters.add(sFieldName + ' = \'' + fv + '\'');
            }

            if (fo == 'NOT='){
                filters.add(sFieldName + ' != \'' + fv + '\'');
            }
            
            if(fo=='CONTAINS'){
                System.debug('Entro en cont');
                filters.add(sFieldName + ' like \'%' + fv + '%\'');
            }
            
            if (fo=='STARTS'){
                filters.add(sFieldName + ' like \'' + fv + '%\'');
            }
            
            if (fo=='ENDS'){
                filters.add(sFieldName + ' like \'%' + fv + '\'' );
            }
            if (fo=='NOTCONTAINS'){
                filters.add('NOT ' + sFieldName + ' like \'%' + fv + '%\'');
            }              
        }
        return filters;
    }

    @TestVisible
 	private static List<String> filterDateTime(List<String> filters, String fo, String fv, String fieldName, Boolean isPickList){
		//String sFieldName = fieldName;
        /*.replace('-','/');
		DateTime testDate = DateTime.parse(testDateString);*/
 	   /* System.debug('Formato de datetime ' + fv.replace('-', '/'));
        
        Date newDate = Date.parse(fv.replace('-', '/'));
        System.debug('newDate '+ newDate);*/
		//Datetime dt = Datetime.newInstanceGMT(newDate.year(), newDate.month(),newDate.day(),0,0,0);
      	/*List<string> slist = new string[]{fv.replace('-', '/')};
        String[] myDateOnly = fv.split(' ');
        String[] strDate = myDateOnly[0].split('/');
        Integer myIntYear = integer.valueOf(strDate[0]);
        Integer myIntMonth = integer.valueOf(strDate[1]);
        Integer myIntDate = integer.valueOf(strDate[2]);
        Date dt = Date.newInstance(myIntYear, myIntMonth, myIntDate);
		
        //Datetime dt = DateTime.valueOf(fv.replace('-', '/'));
        //String dt = fv + 'T00:00:00+0000';
        System.debug('Formato de datetime dt ' + dt);
        System.debug('Formato de fieldName ' + fieldName);
  		*/
        Datetime dt = null;
        String formattedDt = null;
        
        if (fv  != null && fv !=''){
            String[] myDateOnly = fv.split(' ');
            String[] strDate = myDateOnly[0].split('-');
            Integer myIntYear = integer.valueOf(strDate[0]);
            Integer myIntMonth = integer.valueOf(strDate[1]);
            Integer myIntDate = integer.valueOf(strDate[2]);
                //datetime myDate = datetime.newInstance(2008, 12, 1)
            dt = Datetime.newInstanceGMT(myIntYear, myIntMonth, myIntDate);           
            System.debug('dt yy mm dd'+ dt + ' '+ myIntYear + ' ' + myIntMonth);
            
            formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');   
            System.debug('formattedDt'+ formattedDt);
        }

        
        if  (dt!=null && fo!=null){        
            if (fo.equals('=')){ 
                filters.add(fieldName + ' > ' + formattedDt );
                dt = dt.addDays(1);
                formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');   
                filters.add(fieldName + ' < ' + formattedDt );
                System.debug('Después de = ' + filters[0]);
            }
            if (fo.equals('GT')){
                filters.add(fieldName + ' > ' + formattedDt );
            }
            if (fo.equals('LT')){
                filters.add(fieldName + ' < ' + formattedDt );
            }
        }
        else{
            if  (fo!=null){
                filters.add(fieldName + ' = ' + fo);
                /* =, GT, LT, TOMORROW, TODAY, YESTERDAY, NEXT_WEEK, THIS_WEEK, LAST_WEEK, NEXT_MONTH, 
LAST_MONTH, THIS_MONTH, NEXT_QUARTER, LAST_QUARTER, THIS_QUARTER, NEXT_YEAR, 
LAST_YEAR, THIS_YEAR*/
            }   
        }

        return filters;   
    }
     
    @TestVisible
    private static List<String> filterSwitch (List<String> filters, String fid, String fo, String fv){
        //('1', 'Case.CAS_TXT_Num_Caso_HS__c'
        //('2', 'Status'
        //('3', Case.CAS_DAT_Fecha_Apertura__c', 'DATETIME'
        //('4', 'OTR_TXT_Num_OrdenTrabajo_HS__c'
        //('5', 'Gremio', 'OTR_SEL_Gremio__c', 'STRING',
        //('6', 'Case.Account.CUE_TXT_Numero_Documento__c'
        //('7', 'Case.CAS_FOR_Direccion_Riesgo__c'
        //('8', 'OTR_FOR_Importe_total_siniestro__c'
        if (fid == '1'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterString(filters, fo, fv, 'Case.CAS_TXT_Num_Caso_HS__c',false);
        }
        if (fid == '2'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterString(filters, fo, fv, 'Status',true);
        }
     	if (fid == '3'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterDateTime(filters, fo, fv, 'Case.CAS_DAT_Fecha_Apertura__c',true);
        }
        if (fid == '4'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterString(filters, fo, fv, 'OTR_TXT_Num_OrdenTrabajo_HS__c',false);
        }
        if (fid == '5'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterString(filters, fo, fv, 'OTR_SEL_Gremio__c',true);
        }
        if (fid == '6'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterString(filters, fo, fv, 'Case.Account.CUE_TXT_Numero_Documento__c',false);
        }
        if (fid == '7'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterString(filters, fo, fv, 'Case.CAS_LKP_Punto_de_venta__r.Name',false);
        }
        /*if (fid == '8'){ //this maps to the SDGField with ID=1 => field is 'direccion'{
            filters = filterString(filters, fo, fv, 'OTR_FOR_Importe_total_siniestro__c',false);
        }*/

        return filters;
    }

    @TestVisible
    private static String orderClause (String sortColumn, String sortOrder){
        String sSortClause = '';
        String sField = '';
        /*if (sortColumn.equals('Status') || sortColumn.equals('OTR_SEL_Gremio__c')){
            sField = 'toLabel(' + sortColumn + ')';
        }*/
        if (sortColumn == '1'){
            sField = 'Case.CAS_TXT_Num_Caso_HS__c';
        }
        if (sortColumn == '2'){
            sField = 'Status';
        }
        //Date
         if (sortColumn == '3' || sortColumn == ''){ 
            sField = 'Case.CAS_DAT_Fecha_Apertura__c';
            //sField = 'OTR_DAT_Fecha_Primera_Cita__c';
        }
        
        if (sortColumn == '4'){
            sField = 'OTR_TXT_Num_OrdenTrabajo_HS__c';
        }
        if (sortColumn == '5'){
            sField = 'OTR_SEL_Gremio__c';
        }
        if (sortColumn == '6'){
            sField = 'Case.Account.CUE_TXT_Numero_Documento__c';
        }
        if (sortColumn == '7'){
            sField = 'Case.CAS_LKP_Punto_de_venta__r.Name';
        }
        if (sortColumn == '8'){
            sField = 'OTR_FOR_Importe_total_siniestro__c';
        }
        if (String.isNotBlank(sField)){      
            if (sortOrder == 'A')
                sSortClause = ' ORDER BY ' + sField + ' ASC NULLS FIRST';
            else
                sSortClause = ' ORDER BY ' + sField + ' DESC NULLS LAST';
        }

        return sSortClause;
    }

}