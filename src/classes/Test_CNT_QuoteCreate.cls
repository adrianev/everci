@isTest
public class Test_CNT_QuoteCreate {
@isTest
    public static void prueba(){
    PageReference pageRef = Page.QuoteCopy;
	Test.setCurrentPage(pageRef); 
	pageRef.getParameters().put('id', 'id');
    pageRef.getParameters().put('retorno', 'google.es');
    pageRef.getParameters().put('solicitudExistente', 'google.es');
    pageRef.getParameters().put('fase', 'google.es');
    CNT_QuoteCreate cnt = new CNT_QuoteCreate();
    cnt.volver();
        
    }
}