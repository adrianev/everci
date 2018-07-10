global without sharing class Llamada_Cliente_Controller {
	
	public Llamada_Cliente_Controller(){
		
	}

	WebService static String llamarCliente(Account cuentaCliente){
		
		String telefono = cuentaCliente.Phone;


		return 'Ok';
	}
	
	
	
	
	
}