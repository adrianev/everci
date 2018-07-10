trigger TRG_EmailMessage on EmailMessage (before insert,after insert) {
    if(Trigger.isBefore){
        TRG_Handler_EmailMessage.tratamientoBefore(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
    }
    else{
		TRG_Handler_EmailMessage.tratamientoAfter(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
    }
}