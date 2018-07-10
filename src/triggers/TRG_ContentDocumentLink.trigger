trigger TRG_ContentDocumentLink on ContentDocumentLink (before insert) {
    if(!Baipas.isMigrationUser()) {
        TRG_Handler_ContentDocumentLink.actualizarVisibility(trigger.new);
    }
}