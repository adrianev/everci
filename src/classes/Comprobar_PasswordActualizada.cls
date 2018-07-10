public without sharing class Comprobar_PasswordActualizada {

    public static void comprobarPass (){
        
        
        Datetime fecha = Datetime.now();
        String fechaString = fecha.format('yyyy-MM-dd');
        
        List<Case> casos = [SELECT Id, CAS_TXT_Password_Clic_Hogar__c, CreatedDate FROM Case LIMIT 1];
        
        system.debug('Casos: '+casos);
        DateTime aux;
        Map<Case,DateTime> aux2 = new Map<Case,DateTime>();
        
        system.debug(casos.size());
        
        //Sumar 3 días a la fecha de creacion
        for(Integer i=0;i<casos.size();i++){
            aux = casos[i].CreatedDate.addDays(3);
            system.debug('fecha anterior' + casos[i].CreatedDate + 'fecha mas 3' + aux);
            aux2.put(casos[i],aux);
            system.debug('Fecha añadida');
        }
        
        system.debug('Fechas sumadas');

        for (Case caso:casos){

            String fechaCaso = caso.CreatedDate.format('yyyy-MM-dd');
            
            system.debug(fechaCaso);
            
            if(caso.CAS_TXT_Password_Clic_Hogar__c == caso.Id){
                //Break
            }else {
                for(Integer i = 0; i<=aux2.size(); i++){
                    system.debug(aux2);
                }
            }
        }
    }
    
    
}