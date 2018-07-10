public without sharing class Util_Profesionales implements Queueable {
	
	public User usr;
	public Util_Profesionales(User usr){
		this.usr = usr;
	}
	
	public void crearUsuarioCPQ (){
		
		Callout_CPQ_Profesionales_RQ resultado = new Callout_CPQ_Profesionales_RQ();
		
		resultado.login = usr.Username.split('@').get(0);
		resultado.nombreProfesional = usr.LastName;
		resultado.apellidosProfesional = usr.LastName;
		resultado.emailProfesional = usr.Username;
		system.debug('---- SVV. Zona horaria: ' + usr.TimeZoneSidKey);
		if (usr.TimeZoneSidKey == 'Europe/Paris') {
			resultado.zonaHoraria = '(GMT+1:00 GMT+2:00) Amsterdam';
		}
		else {
			resultado.zonaHoraria = '(GMT+0:00 GMT+1:00) London';
		}
		resultado.partnerLogin = usr.Username;
		if (usr.IsActive == true) {
			resultado.estado = 'Active';
		}
		else {
			resultado.estado = 'Inactive';
		}
		
		String bodySend = JSON.Serialize(resultado);
		
		String idBitacora = Util_Llamada_Externa.insertarBitacora(Label.CPQ_Profesional,'','01','02',Label.CPQ_Profesional_Nombre,bodySend,'',
							'','','','','','',usr.id,0,'',0,Label.Callout_POST);
		system.debug('---- SVV. Se llama al callout ----');
		Callout_CPQ_Profesionales.updateDatos(bodySend, Label.CPQ_Profesional, idBitacora, usr.Id);
	}
	
	public void execute(QueueableContext context) {
		system.debug('va a crear usuarios');
		crearUsuarioCPQ();
	}
}