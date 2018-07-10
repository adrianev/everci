@isTest(SeeAllData=true)
public without sharing class Test_Panel_OTRedirec {

    private static testMethod void irOTencurso(){
        
        
        Panel_OTRedirec panel = new Panel_OTRedirec();
        panel.irOTencurso();
        panel.irOTcerrada();
        panel.irReclamaciones();
    }
}