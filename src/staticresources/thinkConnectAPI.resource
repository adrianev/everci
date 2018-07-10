(function (scope, sforce) {
    'use strict';

    /**
     * Librería API para thinkConnect
     **
     * @version: 0.2
     * @author: xferrer
     * @changes: amartinez
     * @description: Librería preparada para interactuar mediante sendCTIMessage de la consola de Salesforce con thinkConnect
     **/

    // Definimos el objeto thinkConnectAPI en la scope
    scope.thinkConnectAPI = {};

    // Definimos las funciones que van a ser accesibles y su nombre de función en la API
    var actionDefinitions = {
        // blindTransferTo('9001')
        blindTransferTo: {
            name: 'blindTransferCall',
            args: [{ transferTo: '{!0}' }]
        },
        // consultationCallTo('9001')
        consultationCallTo: {
            name: 'consultationCall',
            args: [{ calledDevice: '{!0}' }]
        },
        // transfer()
        transfer: {
            name: 'transferCall'
        },
        // addCallResult('Finalizada con éxito'); addCallResult({'root': 108})
        addCallResult: {
            name: 'setCallResult'
        },
        // saveCallResult()
        saveCallResult: {
            name: 'endCallLog'
        },
        // endCallResult()
        endCallResult: {
            name: 'updateTask'
        }
    }

    // Definimos una funcion para formatear teniendo una plantilla como objeto y los argumentos
    // Sustituirá todas las ocurrencias de {!i} por el argumento número i
    function formatArgs(template, args) {
        var formattedArgs = JSON.parse(JSON.stringify(template));
        for (var i = 0; i < args.length; i++) {
            formattedArgs = JSON.parse(JSON.stringify(formattedArgs).replace(new RegExp('{!'+ i + '}', 'g'), args[i]));
        }
        return formattedArgs;
    }

    // API al curry
    function invokeAPIMethod(name, argsTemplate) {
        return function() { // (param1, param2, ... , callback)
            if (arguments.length === 0) { console.log('Every API method must implement at least the callback parameter'); return; }
            if (Object.prototype.toString.call(arguments[arguments.length-1]) !== '[object Function]') { console.log('Last argument must be a callback function'); return; }
            sendCTIMessage({
                name: name,
                args: argsTemplate? formatArgs(argsTemplate, Array.from(arguments).slice(0, -1)): Array.from(arguments).slice(0, -1)
            }, arguments[arguments.length-1]);
        }
    }

    // Añadimos al objeto thinkConnectAPI funciones con todas las definiciones que hemos hecho disponibles
    for (var def in actionDefinitions) {
        scope.thinkConnectAPI[def] = invokeAPIMethod(actionDefinitions[def].name, actionDefinitions[def].args);
    }

    // Función auxiliar para enviar un mensaje con sendCTIMessage o a través del iframe hacia arriba
    function sendCTIMessage(data, callback, forcePostMessage) {
        var message = JSON.stringify(data);
        if (sforce) {
            sforce.console.cti.sendCTIMessage(message, callback);
        } else {
            window.parent.postMessage(message, '*');
            if (callback) {
                callback({success: true});
            }
        }
    }

    // Añadimos un listener y si no estamos en Salesforce, reenviamos el mensaje hacia arriba
    window.addEventListener("message",  function(event) {
        if (!sforce) {
            sendCTIMessage(event.data);
        }
    }, false);
    
})(window, window.sforce);