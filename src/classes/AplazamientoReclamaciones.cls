/**
 * Clase controladora de la Visualforce "AplazamientoReclamaciones" encargada de gestionar el aplazamiento de reclamaciones
 * 
 * @author EVERIS
 */
public without sharing class AplazamientoReclamaciones {
    
    public Case reclamacion;
    public Case reclCampos;
    public ApexPages.standardController controlador;    
    public Boolean todoCorrecto {get;set;}

    /**
    * 
    * Constructor de la clase
    * 
    */  
    public AplazamientoReclamaciones(ApexPages.standardController stdCtr){
        todoCorrecto = true;
        PageReference paginaActual = ApexPages.currentPage();
        if (!paginaActual.getParameters().containsKey('id')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
            todoCorrecto = false;
        } else {

            Id idReclamacion = stdCtr.getRecord().Id;
            
            List<Case> recAux = Util_Caso.getCaseById(new Set<Id>{idReclamacion}).values();
            //List<Case> recAux = Util_Caso.getMapaCasos(new Set<Id>{idReclamacion}).values();
            //List<Case> recAux = [Select Id, Status, CaseNumber, CAS_DAT_Fecha_de_Aplazamiento__c FROM Case WHERE Id = :idReclamacion];
            
            if(!recAux.isEmpty()){
                
                reclCampos = recAux.get(0);
                reclamacion = (Case)stdCtr.getRecord();
                    
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No hay objeto asociado'));
                todoCorrecto = false;
            }
            
            controlador = stdCtr;
        }    
    }
    
    public PageReference guardar(){
        
        PageReference paginaRedireccion = null;
        
        if(reclamacion.CAS_DAT_Fecha_de_Aplazamiento__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Debe seleccionar una fecha de aplazamiento.'));
            return null;            
        } else {                     
           	paginaRedireccion = controlador.save();
        }                
        return paginaRedireccion;
    }
}