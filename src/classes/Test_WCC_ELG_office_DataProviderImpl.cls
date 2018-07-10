@isTest
public class Test_WCC_ELG_office_DataProviderImpl {  
       
    @isTest
    static public void testIsUserSelectable(){
        boolean isUserSelect = WCC_ELG_office_DataProviderImpl.isUserSelectable();
        System.assertEquals(true, isUserSelect);
    }
    
    @isTest
    static public void testGetActions(){
		WCC_ELG_office_DataProviderImpl dataProviderImpl = new WCC_ELG_office_DataProviderImpl();
        List<sortablegrid.SDGAction> listActions= dataProviderImpl.GetActions();
        System.assertNotEquals(0, listActions.size());
    }
    
    @isTest
    static public void testGetFields(){
		WCC_ELG_office_DataProviderImpl dataProviderImpl = new WCC_ELG_office_DataProviderImpl();
        List<sortablegrid.SDGField> listFields= dataProviderImpl.GetFields();
        System.assertNotEquals(0, listFields.size());
    }
    
    
     @isTest
    static public void testFilterDateTime(){
        List<String> filters = new List<String> ();
        filters = WCC_ELG_office_DataProviderImpl.filterDateTime(filters,'=', '2018-01-01 00:00:00.000', 'fieldName', true);
        System.assertEquals(2, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterDateTime(filters,'GT', '2018-01-01 00:00:00.000','fieldName', true);
        System.assertEquals(3, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterDateTime(filters,'LT', '2018-01-01 00:00:00.000', 'fieldName', true);
        System.assertEquals(4, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterDateTime(filters,'TOMORROW', null, 'fieldName', true);
        System.assertEquals(5, filters.size());
    }
       
    
    @isTest
    static public void testFilterString(){
		//WCC_ELG_office_DataProviderImpl dataProviderImpl = new WCC_ELG_office_DataProviderImpl();
        List<String> filters = new List<String> ();
        filters = WCC_ELG_office_DataProviderImpl.filterString(filters,'=', 'fielName','fieldValue', true);
        System.assertEquals(1, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterString(filters,'NOT=', 'fielName','fieldValue', true);
        System.assertEquals(2, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterString(filters,'CONTAINS', 'fielName','fieldValue', true);
        System.assertEquals(3, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterString(filters,'STARTS', 'fielName','fieldValue', true);
        System.assertEquals(4, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterString(filters,'ENDS', 'fielName','fieldValue', true);
        System.assertEquals(5, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterString(filters,'NOTCONTAINS', 'fielName','fieldValue', true);
        System.assertEquals(6, filters.size());
    }
    
    @isTest
    static public void testFilterSwitch(){
		//WCC_ELG_office_DataProviderImpl dataProviderImpl = new WCC_ELG_office_DataProviderImpl();
        List<String> filters = new List<String> ();
        filters = WCC_ELG_office_DataProviderImpl.filterSwitch(filters,'3','=', '2018-01-01 00:00:00.000');
        System.assertEquals(2, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterSwitch(filters,'2','NOT=', 'fieldValue');
        System.assertEquals(3, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterSwitch(filters,'1','CONTAINS', 'fieldValue');
        System.assertEquals(4, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterSwitch(filters,'4','STARTS', 'fieldValue');
        System.assertEquals(5, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterSwitch(filters,'5','ENDS', 'fieldValue');
        System.assertEquals(6, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterSwitch(filters,'6','NOTCONTAINS', 'fieldValue');
        System.assertEquals(7, filters.size());
        filters = WCC_ELG_office_DataProviderImpl.filterSwitch(filters,'7','NOTCONTAINS', 'fieldValue');
        System.assertEquals(8, filters.size());
      
    }
    
    @isTest
    static public void testOrderClause(){
		//WCC_ELG_office_DataProviderImpl dataProviderImpl = new WCC_ELG_office_DataProviderImpl();
        String clause = '';
        clause = WCC_ELG_office_DataProviderImpl.orderClause('1','A');
        System.assertEquals(' ORDER BY Case.CAS_TXT_Num_Caso_HS__c ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('2','A');
        System.assertEquals(' ORDER BY Status ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('3','A');
        System.assertEquals(' ORDER BY Case.CAS_DAT_Fecha_Apertura__c ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('4','A');
        System.assertEquals(' ORDER BY OTR_TXT_Num_OrdenTrabajo_HS__c ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('5','A');
        System.assertEquals(' ORDER BY OTR_SEL_Gremio__c ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('6','A');
        System.assertEquals(' ORDER BY Case.Account.CUE_TXT_Numero_Documento__c ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('7','A');
        System.assertEquals(' ORDER BY Case.CAS_TXT_Direccion__c ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('8','A');
        System.assertEquals(' ORDER BY OTR_FOR_Importe_total_siniestro__c ASC NULLS FIRST', clause);
        clause = WCC_ELG_office_DataProviderImpl.orderClause('8','D');
        System.assertEquals(' ORDER BY OTR_FOR_Importe_total_siniestro__c DESC NULLS LAST', clause);
    }
    
    @isTest
    static void testLoadSDG(){
        WCC_ELG_office_DataProviderImpl dataProvider = new WCC_ELG_office_DataProviderImpl();
        sortablegrid.SDG sdg = dataProvider.LoadSDG('SDGTag','ParentId');
        System.assert(sdg!=null);
    }
     @isTest
    static void testIforAccountUser(){
       	User infoUser = new User();
        infoUser = WCC_ELG_office_DataProviderImpl.inforAccountUser();
        System.assertEquals(infoUser, null);   
    }
    
    @testSetup 
    static void  setUp(){

		WorkOrder WorkOrder = new WorkOrder(Status='Nuevo', OTR_TXT_Num_OrdenTrabajo_HS__c='101010');
        insert WorkOrder;
    }
    @isTest
    static void testGetDataSDG(){
      	
        List<sortablegrid.SDGFilter> listFilter = new List<sortablegrid.SDGFilter>();
		sortablegrid.SDGFilter filter = new sortablegrid.SDGFilter();
        filter.FilterOperator = '=';
        filter.FilterValue ='101010';
        filter.SDGFieldID = '4';
        listFilter.Add(filter);
 
        sortablegrid.SDGRequest request = new sortablegrid.SDGRequest();
        request.filters=listFilter;
        request.PageSize = 10;
             
        sortablegrid.SDG coreSDG;  

		sortablegrid.SDGResult result =  WCC_ELG_office_DataProviderImpl.getData(coreSDG, request);        
        System.AssertEquals(result.pagecount, result.FullQueryCount/request.PageSize);
        System.AssertEquals(result.isError, false);
        System.AssertEquals(result.ErrorMessage, result.FullQueryCount+ ' : ' + request.PageSize);
  
    }
    

    @isTest
    static void  testGetDataSdgException(){
        try{
			sortablegrid.SDGResult result =  WCC_ELG_office_DataProviderImpl.getData(null, null);
        }
        catch(Exception e)
        {
         	Boolean expectedExceptionThrown =  (e.getMessage().contains('My Error Message')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
    }
    
    
}