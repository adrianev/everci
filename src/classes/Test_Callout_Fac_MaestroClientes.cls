@isTest
public without sharing class Test_Callout_Fac_MaestroClientes {

	@isTest
	public static void Testing(){
		Callout_Fac_MaestroClientes_RQ datos = new Callout_Fac_MaestroClientes_RQ();
		datos.origenDeDatos = 'Cliente';
		datos.accion = 'AbrirCaso';
		datos.nombreDelClienteProcedencia = 'Ocaso';
		datos.tipoCliente = 'Asegurado';
		datos.identificadorCompania = '12jYHlds13';
		datos.identificadorUnicoCliente = '2JsER83J9ld';
		datos.tipoDocumento = 'Reclamacion';
		datos.tomadorNumeroDocumentoCliente = 'HldsER83';
		datos.numeroPoliza = '12873a92137bdy';
		datos.numeroClienteRelacionado = '3a92137bdsE';
		datos.nombreContacto = 'Ángel';
		datos.mailContacto = 'angel.prueba@seguros.com';
		//datos.direccion = '';
		datos.telefonoCuenta = '+34 678 873 253';
		datos.direccionRiesgoDomicilio = 'Plaza de España';
		datos.direccionRiesgoCp = '25849';
		datos.direccionRiesgoProvincia = 'C/Obispo, 13, 2A';
		datos.paisCliente = 'España';
		datos.condicionPago = 'Desconocido';
		datos.metodoPago = 'Tarjeta';
		datos.codigoEntidadBanco = '8719';
		datos.codigoSucursal = '4567';
		datos.digitosControl = '2342';
		datos.numeroCuenta = '7686';
		datos.numeroIBAN = '8719 4567 2342 7686';
		datos.paisCuentaBancaria = 'España';
		datos.procedencia = '1341512';
		datos.direccionRiesgoDomicilio = 'C/Madrilejos 7';
		datos.direccionRiesgoProvincia = 'Albacete';
		datos.paisCliente = 'España';
		datos.direccionRiesgoPoblacion = 'Albacete';
		datos.shippingStreet = 'C/Juan Prim, 82';
		datos.shippingCity = 'Badajoz';
		datos.shippingState = 'Badajoz';
		datos.shippingPostalCode = '06008';
		datos.shippingCountry = 'Espala';

		datos.shippingStreetPadre = 'Calle principal 16';
		datos.shippingStatePadre = 'Texas';
		datos.shippingCityPadre = 'Texas';
		datos.shippingPostalCodePadre = '';
		datos.shippingCountryPadre = 'Estados Unidos';
		datos.RecordTypePadre = 'recordtype';
		datos.idDirecPadre = '234092djd023u';       

		String datosSerializados = JSON.serialize(datos);

		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		String idBitacora = bitacora.Id;

		Id id;
		test.startTest();
		String body = Callout_Fac_MaestroClientes.construirJsonClientes(datos);
		Callout_Fac_MaestroClientes.updateDatos(body, '',idBitacora,'','');
		//Callout_Fac_MaestroClientes.updateDatosAsync(datosSerializados);
		test.stopTest();
	}

}