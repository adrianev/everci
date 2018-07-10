/**
Author:      everis
Company:        everis España
Description:    Clase que se ejecutará cada X minutos, para mandar la información a las tablas de HomeServe

Para ejecutar cada X minutos, lanzaremos los siguientes comandos
System.schedule('Ejecutamos 5 mins después de la hora en punto','0 05 * * * ? *',new Callout_IntegracionIR());
System.schedule('Ejecutamos 10 mins después de la hora en punto','0 10 * * * ? *',new Callout_IntegracionIR());
System.schedule('Ejecutamos 15 mins después de la hora en punto','0 15 * * * ? *',new Callout_IntegracionIR());

History:  <DESCRIPCIÓN DEL CAMBIO, REQUISITO, INCIDENCIA, CORRECTIVO O MEJORA QUE HIZO ACTUALIZAR/CREAR LA CLASE>

<Date>                    everis                       <Change Description>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
global without sharing class Callout_IntegracionIR implements Schedulable{

    private static HttpResponse resultMock;
    private static String valores;
    private static Integer contParametros;

    /**
     * Clase de respuesta.
     *
     */
    public class Resultado{
        public String resultado = 'OK';
        public String codigo_error = '';
        public String mensaje_error = '';
    }

    /*
     * Método que implementa la lógica del callout (composición de RQ, envío y recoger la respuesta)
     *
     */
    @future(callout=true)
    public static void updateDatos(){
        Resultado res = new Resultado();
        Http http = new Http();
        Integer cont = 0;
        HttpRequest request = new HttpRequest();
        List<Movimiento_IR__c> listQuery = new List<Movimiento_IR__c>();
        listQuery = [SELECT Id,MIR_TXT_CLIENTE_VALOR__c,MIR_TXT_CONF_PENDIENTE__c,MIR_TXT_DNI__c,MIR_TXT_GESTOR_RECLAMA__c,MIR_TXT_GESTOR_SINIESTRO__c,
                     MIR_TXT_ID_CASO__c,MIR_TXT_ID_PROCEDENCIA__c,MIR_TXT_NUM_SERVICIO__c,MIR_TXT_NUM_SINIESTRO__c,MIR_TXT_RECLA_NO_CERRADA__c,
                     MIR_TXT_SERV_INDEMNI__c,MIR_TXT_SINI_NO_CERRADO__c,MIR_TXT_TELEFONO__c, MIR_TXT_OPERACION__c,MIR_TXT_APELLIDOS__c,MIR_TXT_NOMBRE__c, MIR_DAT_fechaCierre__c FROM Movimiento_IR__c WHERE MIR_CAS_ENVIADO__c = False LIMIT 5000];

        WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_IntegracionIR'][0];
        List<Movimiento_IR__c> listEnviados = new List<Movimiento_IR__c>();
        if (!test.isRunningTest()) {
            String returnToken = new GetTokenPSI().getToken();
            if(returnToken != '')
                request.setHeader('Authorization',returnToken);
        }
        for(Movimiento_IR__c query:listQuery){
            if(cont <50){
                cont++;
                valores ='';
                contParametros = 0;
                concatenarParametro(query.MIR_TXT_CLIENTE_VALOR__c);
                concatenarParametro(query.MIR_TXT_DNI__c);
                concatenarParametro(query.MIR_TXT_RECLA_NO_CERRADA__c);             
                concatenarParametro(query.MIR_TXT_GESTOR_RECLAMA__c);
                concatenarParametro(query.MIR_TXT_SINI_NO_CERRADO__c);
                concatenarParametro(query.MIR_TXT_GESTOR_SINIESTRO__c);
                concatenarParametro(query.MIR_TXT_SERV_INDEMNI__c);
                concatenarParametro(query.MIR_TXT_NUM_SERVICIO__c);                                                                     
                concatenarParametro(query.MIR_TXT_CONF_PENDIENTE__c);
                concatenarParametro(query.MIR_TXT_NUM_SINIESTRO__c);
                concatenarParametro(query.MIR_TXT_ID_PROCEDENCIA__c);
                //concatenarParametroTel(query.MIR_TXT_TELEFONO__c);
                
                if(query.MIR_TXT_TELEFONO__c != null && !query.MIR_TXT_TELEFONO__c.isNumeric()){
                	query.MIR_TXT_TELEFONO__c = '\'' + query.MIR_TXT_TELEFONO__c + '\'';
                	concatenarParametroTel(query.MIR_TXT_TELEFONO__c);
                } else {
                	concatenarParametroTel(query.MIR_TXT_TELEFONO__c);
                }

                if(query.MIR_TXT_NOMBRE__c != null && query.MIR_TXT_NOMBRE__c != ''){
					String nombre = '' + query.MIR_TXT_NOMBRE__c;
					if(nombre.contains('"') && nombre.contains('\'')){
						nombre = nombre.replaceAll('"','');
						nombre = nombre.replaceAll('\'','');
						nombre = '\'' + nombre + '\'';					
					} else if (nombre.contains('"')){
						nombre = nombre.replaceAll('"','');
					} else if(nombre.contains('\'')){
						nombre = nombre.replaceAll('\'','');
						nombre = '\'' + nombre + '\'';
					}
					query.MIR_TXT_NOMBRE__c = nombre;
					concatenarParametro(query.MIR_TXT_NOMBRE__c);
                } else {
					concatenarParametro(query.MIR_TXT_NOMBRE__c);
                }
                
                concatenarParametro(query.MIR_TXT_APELLIDOS__c);
                concatenarParametro(query.MIR_DAT_fechaCierre__c);
                String body = '{'+
                        '"procedure" : "'+query.MIR_TXT_OPERACION__c+'",' +
                        '"values" : ["'+valores+'"]}'; 
                request.setBody(body);
                HttpResponse response;
                system.debug('body: '+body);
                if (!test.isRunningTest()) {
                    request.setEndPoint(ws_CASV.EndPoint__c);
                    request.setHeader('content-type',ws_CASV.Content_Type__c);
                    request.setMethod(ws_CASV.Method__c);
                    request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
    
                    response = http.send(request);
                }else{
                    setResponseMock();
                    response = resultMock;  
                }
                system.debug('res: '+response.getBody());
                JSONParser parser = JSON.createParser(response.getBody());
                res = analizarRespuesta(parser, query);
                if(res.codigo_error == '0'){
                    query.MIR_CAS_ENVIADO__c = true;
                    listEnviados.add(query);
                }
                system.debug('res: '+res);
            }   
        }
        update listEnviados;
    }

    /* 
     *  Método encargado de analizar la respuesta del sistema tercero y transformarla en un objeto Resultado;
     *  que encapsula el body de la response.
     *      @param response: instancia de JSON parser inicializada con la response en forma de String
     *   
     */
    private static Resultado analizarRespuesta(JSONParser response, Movimiento_IR__c query){
        Resultado res = new Resultado();
        while(response.nextToken() != null){
            if('code'.equals(response.getText())){
                response.nextToken();
                res.codigo_error = response.getText();
            }
            if('message'.equals(response.getText())){
                response.nextToken();
                res.mensaje_error = response.getText();
            }
        }

        return res;
    }

    /*
     * Método encargado de simular el mensaje de respuesta en los test; se simula 
     * el mensaje a recibir mediente la inicialización de un valor que se provee al constructor
     *
     */
    private static void setResponseMock(){
        String body = '{' +
                '"code": "0",' +
                '"message": " "}';

        resultMock = new HttpResponse();
        resultMock.setBody(body);
    }

    /*
     * Métodos auxiliares para formatear como JSON una String
     *
     * @parameter nombreParametro: Nombre del parámetro a insertar en el body de la request
     * @parameter valorParametro: valor del campo a pasar a incluir en la request
     *
     */

    private static void concatenarParametro(String valorParametro)
    {
        if (contParametros > 0) {valores += ',';}
        if (valorParametro != null){
            contParametros++;
            valores +=  valorParametro;
        }else if(valorParametro != ''){
            contParametros++;
            valores +=  '\'\'';         
        }else{
            contParametros++;
            valores += ' ';
        }
    }   
    private static void concatenarParametrotel(String valorParametro)
    {
        if (contParametros > 0) {valores += ',';}
        if (valorParametro != null){
            contParametros++;
            valores +=  valorParametro;
        }else if(valorParametro != ''){
            contParametros++;
            valores +=  ''+0;           
        }else{
            contParametros++;
            valores += ''+0;
        }
    }   
    private static void concatenarParametro(DateTime valorParametro)
    {
        if (contParametros > 0) {valores += ',';}
        if (valorParametro != null){
            contParametros++;
            valores +=  '\''+Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss')+'\'';     
        }else{
            contParametros++;
            valores += null;
        }
    }   
    global void execute(SchedulableContext ctx) {
        updateDatos();
        system.debug('prueba');

    }
}