({
    doInit: function(component, event, helper) {
        helper.comprobarCitaAnulada(component, event);
    },
    modificarCita : function(component, event, helper) {
        helper.modificarCita(component, event);
    },
    anularCitaServicio : function(component, event, helper) {
        helper.anularCitaServicio(component, event);
    },
})