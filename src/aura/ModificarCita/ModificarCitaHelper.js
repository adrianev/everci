({
    comprobarCitaAnulada: function (component, event) {
        var action = component.get("c.estaCitaAnulada");
        action.setParams({
            recordId: component.get("v.recordId"),
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.esModificable", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);

                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Error",
                            "message": errors[0].message
                        });
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },
    modificarCita: function (component, event) {
        console.debug(component.get("v.recordId"));

        var timestamp = Date.now().toString().substr(0, 10);
        var urlAct = window.location.href;

        var action = component.get("c.getURLModificacionCita");
        action.setParams({
            recordId: component.get("v.recordId"),
            timestamp: timestamp,
            urlBack: urlAct
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var urlFormated = response.getReturnValue();
                console.log(urlFormated);

                /*var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": urlFormated
                });
                urlEvent.fire();*/
                window.location.href=urlFormated;
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Error",
                            "message": errors[0].message
                        });
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    anularCitaServicio: function (component, event) {
        console.debug(component.get("v.recordId"));

        var action = component.get("c.anularCita");
        action.setParams({
            recordId: component.get("v.recordId"),
        });

        //Mostramos spinner para indicar que se está procesando la anulación de la cita
        var modal = component.find("modalProcessing");
        $A.util.removeClass(modal, 'hideDiv');
        action.setCallback(this, function (response) {
            //Quitamos el spinner
            $A.util.addClass(modal, 'hideDiv');

            var state = response.getState();
            if (state === "SUCCESS") {
                //Mostramos mensaje y refrescamos la página
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "Cita anulada",
                    "message": "Se ha anulado la cita de forma correcta",
                    closeCallback: function () {
                        $A.get('e.force:refreshView').fire();
                    }
                });

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Error",
                            "message": "Se ha producido un error al anular la cita. Por favor, inténtelo de nuevo más tarde."
                        });
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})