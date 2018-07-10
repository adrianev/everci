public without sharing class checkRecursive{
    private static boolean runIR = true;
    private static boolean runWO = true;
    public static boolean runOnceIR(){
           if(runIR){
            runIR=false;
               system.debug(runIr + ' runIr');
            return true;
              
           }else{
               return runIR;
           }
    }
    
    public static boolean runOnceWO(){
           if(runWO){
            runWO=false;
            return true;
           }else{
               return runWO;
           }
    }    
}