@isTest
public without sharing class Test_Callout_Fac_MaestroProfesionales {

	@isTest
	public static void Testing(){
		Callout_Fac_MaestroProfesionales_RQ datos = new Callout_Fac_MaestroProfesionales_RQ();
		datos.origenDatos = 'Siniestro';
		datos.accionRealizada = 'Reparado';
		datos.nombreProfesional = 'Lucas';
		datos.identificadorUnicoProfesional = '01h76134Htl1747';
		datos.numeroProfesional = 'h76134Ht023g743';
		datos.tipoDocumento = 'DNI';
		datos.tomadorNumeroDocumentoCliente = '003a';
		datos.nombreContacto = 'Ildefonso';
		datos.mailContacto = 'idelfonso.prueba@reparado.com';
		Address direccion = new Address();
		datos.direccionContacto = direccion;//'C/De la pampa 78';
		datos.telefonoContacto = '+92 632 432 129';
		datos.direccionDelProfesional = 'Avda. Principal, 9';
		datos.codigoPostalProfesional = '15443';
		datos.ciudadProfesional = 'Cordoba';
		datos.paisProfesional = 'España';
		datos.importeFianzaMaxima = 128;
		datos.condicionPago = 'Reparacion';
		datos.codigoRetencionFiscal = '782sd3891d';
		datos.profesionaFianza = true;
		datos.porcentajeFianza = 21;
		datos.importeTotalFianza = 450;
		datos.importeFianzadevuelta = 395;
		//datos.profesionalFranquicia = ';
		datos.importeFranquicia = 322;
		//datos.fechaFranquicia = 13112017;
		datos.tipoProfesional = '';
		datos.metodoPago = 'Prueba';
		datos.codigoEntidadBanco = '2345';
		datos.codigoSucursal = '7685';
		datos.profesionalRappel = true;
		datos.tipologiaRappel = 'Desconocido';
		datos.digitosControl = '3455';
		datos.numeroCuenta = '2207';
		datos.numeroIban = '2345707';
		datos.paisCuentaBancaria = 'Argentina';
		datos.embargado = false;
		datos.vetado = true;
		//datos.profesionalPerito = true;

		String datosSerializados = JSON.serialize(datos);
		
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		String idBitacora = bitacora.Id;
		
		test.startTest();
		String body = Callout_Fac_MaestroProfesionales.construirBody(datos);
		Callout_Fac_MaestroProfesionales.updateDatos(body, '',idBitacora,'','');
		test.stopTest();
	}
}