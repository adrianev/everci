@isTest
public without sharing class Test_Callout_Fac_PreFactura {

	@isTest
	public static void Testing(){
		Callout_Fac_PreFactura_RQ datos = new Callout_Fac_PreFactura_RQ();
		datos.origenDatos = 'Reparación';
		datos.identificadorCompania = 'Reparalia';
		datos.unidadNegocio = 'Taller de mecánica';
		datos.lineaDeNegocio = 'Talleres/Locales';
		datos.segmento = 'Automoción';
		datos.numCaso = '302as84ik2039';
		datos.identificadorUnicoCaso = '90u1hdap8';
		datos.estado = 'Reparado';
		datos.vetadoOrdenDeTrabajo = true;
		datos.tipoCaso = 'Tubería Rota';
		datos.lineaOrdenTrabajo = 'Averias';
		datos.estadoCierreOrdenTrabajo = 'Pendiente';
		datos.nombre = 'Paloma';
		datos.apellido1 = 'Rodriguez';
		datos.apellido2 = 'Diaz';
		datos.identificadorUnicoCuenta = '29j8y92y93';
		datos.precioUnitarioVenta = 302.34;
		datos.unidadesDeMedida = 'Alto/Ancho';
		datos.identificadorUnicoProfesional = '98h98ad789a';
		datos.cantidadGastos = 78.15;
		datos.unidadMedidadGastos = 'Desconocido';
		datos.actividad = 'Mantenimiento';
		datos.tipoIntervencion = 'Reparación';
		datos.grupoCausa = 'Prueba';
		datos.importeTotal = 47.89;
		datos.impuestoIva = 10.23;
		datos.impuestoIpsi = 1.92;
		datos.impuestoIgic = 3.97;
		datos.descuento = 78.35;
		datos.codigoBaremo = '19jd981o91ois9';
		datos.ancho = 4;
		datos.alto = 10;
		datos.porcentajeProf = 9.92;
		datos.porcentajeCli = 3.97;
		datos.daniosDel = 'DañosDel';
		datos.descripcionBaremo = 'Alto';   
		//datos.cargarACompania = 608.22;   
		datos.numeroExpediente = 'aj1IAAqo1031al';
		datos.porcentajeMateriales = 72.50;
		datos.direccionRealizacionTrabajo = 'C/Avenida pequeña';
		datos.localidadRealizacionTrabajo = 'Béjar';
		datos.provinciaRealizacionTrabajo = 'Salamanca';

		String datosSerializados = JSON.serialize(datos);

		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		insert bitacora;
		String idBitacora = bitacora.Id;

		test.startTest();
		String body = Callout_Fac_PreFactura.construirBody(datos);
		Callout_Fac_PreFactura.updateDatos(body, '',idBitacora,'');
		test.stopTest();
	}

}