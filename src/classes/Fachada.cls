/**---------------------------------------------------------------------------------------------------------------------------------------------------
Author:         everis
Company:        everis España
Description:    Clase Fachada que invocarán desde las Visuals para todas los callouts.

History:  <DESCRIPCIÓN DEL CAMBIO, REQUISITO, INCIDENCIA, CORRECTIVO O MEJORA QUE HIZO ACTUALIZAR/CREAR LA CLASE>

<Date>                      everis                       <Change Description>
------------------------------------------------------------------------------------------------------------------------------------------------------*/
public without sharing class Fachada {

	List<Contact> prueba = [SELECT CreatedDate FROM Contact];

	//DateTime dt = (DateTime) JSON.deserialize('"2016-03-03T01:09:36.933"', DateTime.class);
	public void a(){
		datetime dtEnd = dateTime.now();
		String extraWhereForQuery = (' AND CreatedDate <= ' + dtEnd.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
		system.debug(extraWhereForQuery);
	}

	public static List<Callout_ConsultaPolizaVesta_RP> consultaPolizaVestaSimple(Id idCompania, String localizador){
		String nombreCIA;
		if(idCompania != null){
			List<Account> listaCuentas = new List<Account>([SELECT Name,CUE_TXT_Identificador__c FROM Account WHERE Id = :idCompania]);
			if(!listaCuentas.isEmpty()){
				nombreCIA = listaCuentas.get(0).CUE_TXT_Identificador__c;
			}
		}
		String url = '?identificadorCompania='+nombreCIA+'&localizador='+localizador+'&infoFee=false';
		return Callout_ConsultaPolizaVesta.getDatos(url);
	}

	public static List<Callout_ConsultaPolizaVesta_RP> consultaPolizaVestaAdvance(Id idCompania,String numeroPoliza, String numeroDocumento,
			String numeroSiniestroHS, String numeroSiniestroCIA, String nombre, String apellido1, String apellido2, 
			String direccionRiesgoDomicilio, String direccionRiesgoCp, String poblacion, String provincia){
		String nombreCIA = '';
		String url = '?';
		if(idCompania != null){
			List<Account> listaCuentas = new List<Account>([SELECT Name,Account.CUE_CAS_Permite_Apertura_Sin_Poliza__c ,CUE_TXT_Identificador__c FROM Account WHERE Id = :idCompania]);
			if(!listaCuentas.isEmpty()){
				nombreCIA = listaCuentas.get(0).CUE_TXT_Identificador__c;
			}
		}
		if(nombreCIA != ''){
			url = url+ 'identificadorCompania='+nombreCIA;
		}
		if(numeroPoliza != ''){
			url =url+ '&numeroPoliza='+numeroPoliza;
		}
		if(numeroSiniestroHS != ''){
			url =url+ '&numeroSiniestroHS='+numeroSiniestroHS;
		}
		if(numeroSiniestroCIA != ''){
			url =url+ '&numeroSiniestroCIA='+numeroSiniestroCIA;
		}
		if(nombre != ''){
			url =url+ '&nombre='+nombre;
		}
		if(apellido1 != ''){
			url =url+ '&apellido1='+apellido1;
		}
		if(apellido2 != ''){
			url =url+ '&apellido2='+apellido2;
		}
		if(direccionRiesgoDomicilio != ''){
			url =url+ '&direccionRiesgoDomicilio='+direccionRiesgoDomicilio;
		}
		if(direccionRiesgoCp != ''){
			url =url+ '&direccionRiesgoCp='+direccionRiesgoCp;
		}
		if(poblacion != '' && poblacion != null){
			url =url+ '&poblacion='+poblacion;
		}
		if(provincia != '' && provincia != null){
			url =url+ '&provincia='+provincia;
		}
		url=url+ '&infoFee=false';


		//String url = '?identificadorCompania='+nombreCIA+'&numeroPoliza='+numeroPoliza+'&numeroDocumento='
		//			+numeroDocumento+'&numeroSiniestroHS='+numeroSiniestroHS+'&numeroSiniestroCIA='+numeroSiniestroCIA+'&nombre='+nombre+'&apellido1='
		//			+apellido1+'&apellido2='+apellido2+'&direccionRiesgoDomicilio='+direccionRiesgoDomicilio+'&direccionRiesgoCp='+direccionRiesgoCp+'&poblacion='+poblacion+
		//			'&provincia='+provincia+'&infoFee=false';
		//String url = '?identificadorCompania='+nombreCIA+'&nombre='+nombre+'&apellido1='+apellido1;
		System.debug(url);
		return Callout_ConsultaPolizaVesta.getDatos(url);
	}	

	public static Callout_ActualizaSiniestroVesta.Resultado actualizaSiniestroVesta(Integer actuacion, Integer casoActualizacion, String fechaCambio, String descripcionNoAbierto,
			String tipoSiniestro, String gremio, String numeroSiniestroHS, String numeroSiniestroCia, String tipoSituacion, String tipoSituacionReparacion){
		Callout_ActualizaSiniestroVesta_RQ datos = new Callout_ActualizaSiniestroVesta_RQ(actuacion, casoActualizacion, fechaCambio, descripcionNoAbierto,
				tipoSiniestro, gremio, numeroSiniestroHS, numeroSiniestroCia, tipoSituacion, tipoSituacionReparacion);
		return Callout_ActualizaSiniestroVesta.updateDatos(datos);
	}

	public static String consultaPolizaActivas(String identificadorCompania)
	{
		String url = '';
		String toRet;
		url = url+ '?identificadorCompania='+identificadorCompania+'&infoFee=true';
		List<Callout_ConsultaPolizaVesta_RP> response = Callout_ConsultaPolizaVesta.getDatos(url);
		system.debug('>>>>> consultaPolizafee - RESPONSE: ' + response);
		if(response.isEmpty()){
			toRet = '0';
		}else{
			toRet = response[0].numeroPolizasActivas;
		}
		return toRet;
	}	

}