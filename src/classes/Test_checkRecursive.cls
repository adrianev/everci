@isTest
public without sharing class Test_checkRecursive {
    @isTest
    public static void runOnceIR(){
        Test.startTest();
        CheckRecursive.runOnceIR();
        CheckRecursive.runOnceIR();
        Test.stopTest();
    }
    
    @isTest
    public static void runOnceWO(){
        Test.startTest();
        CheckRecursive.runOnceWO();
        CheckRecursive.runOnceWO();
        Test.stopTest();
    }
}