/**
 * Clase de funciones relacionadas con los Movimientos que se informan a las 
 * Compañías Aseguradoras. 
 * 
 * @author EVERIS
 */
public without sharing class Util_Movimientos implements Queueable  {

	final String IDIOMA = 'null';
	private Id casoId;
	private String CIAId, accion,textoAccion;
	private Id WOId;
	private DateTime generacion;
	private static Map<String,String> mapaPicklistComentarios;
	private static Map<String,String> mapaPicklistCaso;
	private static Map<String,String> mapaPicklistOt;
	public static Map<String, String> mapaTraduccionCaso;
	public static Map<String, String> mapaTraduccionCuenta;
	public static Map<String, String> mapaTraduccionPerjudicado;
	public static Map<String, String> mapaTraduccionTipoProducto;
	public static Boolean insertaMovimiento = true;
	//public static Boolean movimientoEnError = false;
	
	private Util_Movimientos(Id casoId, String CIAId, String accion, Id WOId, DateTime generacion){
		this.casoId = casoId;
		this.CIAId = CIAId;
		this.accion = accion;
		this.WOId = WOId;
		this.generacion = generacion;
	}
	public class ParametrosPB {
		@InvocableVariable(required=true)
		public ID casoIdPB;
	
		@InvocableVariable(required=true)
		public String CIAIdPB;
	
		@InvocableVariable(required=true)
		public String accionPB;
	
		public ID WOIdPB;
	}
	/**
	 * Método para insertar en los objetos asociados a los Movimientos la información 
	 * de los campos que se enviarán a las aseguradoras. 
	 *
	 *  @param casoId  -  Id del caso que se cargará en el objeto Movimientos
	 *  @param accion  -  String del Tipo de Movimiento según Tabla COM
	 *  @param codigoModificacion  -  String del Código de Modificación según Tabla COM
	 *  
	 */
	private void generarMovimientos(){
		//Inicializo mapas
		mapaPicklistComentarios = Util_Listas_Seleccion.getLabelDesdeAPI('Comentario_caso__c','CMC_SEL_Tipo__c');
		mapaPicklistComentarios.put(null,'Manual');//Si la pickList
		mapaPicklistCaso = Util_Listas_Seleccion.getLabelDesdeAPI('Case','Type');
		mapaPicklistOt = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder','OTR_SEL_Gremio__c');
		mapaTraduccionCaso = Util_Metadatos.getMapaTraduccion(new Set<String>{'Case'});
		mapaTraduccionCuenta = Util_Metadatos.getMapaTraduccion(new Set<String>{'Account'});
		mapaTraduccionTipoProducto = Util_Metadatos.getMapaTraduccion(new Set<String>{'Tipo_Producto_CIA__c'});
		mapaTraduccionPerjudicado = Util_Metadatos.getMapaTraduccion(new Set<String>{'Perjudicado_Siniestro__c'});
		String tipoMovimiento;
		String codigoModificacion;
		List<String> aux = new List<String>();
		//Integracion_Movimiento_CIA__mdt metadatoMov = Util_Metadatos.getIntMovCIAMetadata(new Set<String>{CIAId},new Set<String>{accion}).values().get(0);
		Integracion_Movimiento_CIA__mdt metadatoMov = [SELECT MasterLabel,Identificador_CIA__c, Codigo_de_Movimiento__c, Codigo_de_Modificacion__c FROM Integracion_Movimiento_CIA__mdt 
													   WHERE (Identificador_CIA__c = :CIAId AND Accion__c = :accion) LIMIT 1];
		tipoMovimiento = metadatoMov.Codigo_de_Movimiento__c;
		codigoModificacion = metadatoMov.Codigo_de_Modificacion__c;
		textoAccion = metadatoMov.MasterLabel;
		
		//Definición de variables
		String claveTraduc;
		Case caso = new Case();

		//Datos asociados al caso
		List<Contacto_telefonico__c> listContactosTel = new List<Contacto_telefonico__c>();
		List<Comentario_caso__c> listComentarios = new List<Comentario_caso__c>();
		List<Perjudicado_Siniestro__c> listPerjudicados = new List<Perjudicado_Siniestro__c>();
		List<Garantia_Siniestro__c> listGarantias = new List<Garantia_Siniestro__c>();
		List<WorkOrder> listOrdenesTrabajo = new List<WorkOrder>();
		List<Factura__c> listFacturas = new  List<Factura__c>();
		Factura__c factura = new Factura__c();
		Factura__c facturaGestion = new Factura__c();

		//
		List<INT_Movimiento_CIA__c> movimientosInsertar = new List<INT_Movimiento_CIA__c>();

		//Datos asociados a los objetos de movimiento que se enviarán a la compañía.
		//Incluyen traducciones
		List<INT_Garantias_Siniestros__c> garantiasInsertar = new List<INT_Garantias_Siniestros__c>();
		List<INT_Perjudicados__c> perjudicadosInsertar = new List<INT_Perjudicados__c>();
		List<INT_Contactos_Telefonicos__c> contactosTelefonicosInsertar = new List<INT_Contactos_Telefonicos__c>();
		List<INT_Orden_Trabajo__c> ordenesTrabajoInsertar = new List<INT_Orden_Trabajo__c>();

		//Se obtiene la información del movimiento que será enviado
		caso = Util_Caso.getCaseById(new Set<Id>{casoId}).get(casoId);
		/*caso= [SELECT Id,AccountId,Account.CUE_SEL_Idioma__c,Account.CUE_SEL_Provincia__c,CAS_SEL_Causa_Averia__c,CAS_SEL_Motivo_Rechazo__c,CAS_SEL_Grupo_Causa__c, CAS_CAS_Tercero_Causante__c,
			   CAS_TXT_Apellidos__c,CAS_TXT_Apellidos_2__c,CAS_SEL_Causante_Compania__c,CAS_TXT_Causante_Direccion__c,CAS_SEL_Encuestador__c,CAS_TXT_Tipo_Encuesta__c,
			   CAS_TXT_Nombre__c,CAS_TXT_Causante_N_Documento__c,CAS_TXT_Causante_Poliza_R_C__c,CAS_TXT_Causante_Poblacion__c,
			   CAS_SEL_Causante_Provincia__c,CAS_SEL_Causante_Responsable__c,CAS_TFN_Telefono_1__c,CAS_SEL_Causante_Tipo_Documento__c,
			   CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c,CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
			   LastModifiedDate,CAS_EMA_Solicitud_Email__c,CreatedDate,CAS_DAT_Fecha_Ocurrencia__c,CAS_SEL_Gremio_Principal__c,
			   CAS_DIV_Importe_Total__c,CAS_SEL_Motivo_Peticion_Perito__c, CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c, CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c,
			   CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c, CAS_TXT_Num_Caso_CIA__c,CAS_TXT_Num_Caso_HS__c, CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c,
			   CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c,
			   CAS_CAS_Siniestro_Consorciable__c,CAS_TFN_Solicitud_Telefono__c,
			   CAS_TXT_Codigo_Apertura__c, CAS_SEL_Motivo_Reapertura__c, CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c , Status,
			   CAS_DAT_Fecha_Informe_Pericial__c,CAS_LKP_PolizaContrato__r.name, ClosedDate,CAS_DAT_Fecha_Pago_Minuta__c,
			   CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c, Type, RecordTypeId FROM Case WHERE Id=: casoId];*/
		
		
		if(Util_Siniestro.esSiniestro(caso)){//Si no es siniestro los contactos no estarán aquí
			//listContactosTel = Util_Contacto_Telefonico.queryMapCTByCaseAndTipoRelacion(new Set<Id>{caso.Id},new Set<String>{Label.SINI_TIPOCONTACT_ASEG}).values();
			listContactosTel= [SELECT Id, CTF_FOR_Nombre__c, CTF_FOR_Apellidos__c,
							   CTF_FOR_Email__c,CTF_FOR_Telefono__c, CTF_SEL_Hora_desde__c,CTF_SEL_Hora_hasta__c FROM Contacto_telefonico__c
							   WHERE CTF_LKP_Caso__c=: caso.Id AND CTF_SEL_Tipo_Relacion__c =: Label.SINI_TIPOCONTACT_ASEG];
		}else{
			//Si no es siniestro los datos de contacto se sacan de caso y contacto
			//List<Contact> contactoCaso = new List<Contact>{Util_Contacto.getContactByAccountId(new Set<Id>{caso.AccountId}).values().get(0)};
			List<Contact> contactoCaso = [SELECT Id,FirstName,LastName,Phone,HomePhone,MobilePhone,Email FROM Contact WHERE AccountId =: caso.AccountId LIMIT 1];
			if(!contactoCaso.isEmpty()){
				String nombre=(String.isNotBlank(caso.CAS_TXT_Nombre__c))?caso.CAS_TXT_Nombre__c:contactoCaso.get(0).FirstName;
				String apellidos = (String.isNotBlank(caso.CAS_TXT_Apellidos__c))?caso.CAS_TXT_Apellidos__c:contactoCaso.get(0).LastName;
				String mail = (String.isNotBlank(caso.CAS_EMA_Solicitud_Email__c))?caso.CAS_EMA_Solicitud_Email__c:contactoCaso.get(0).Email;
				String telf = (String.isNotBlank(caso.CAS_TFN_Solicitud_Telefono__c))?caso.CAS_TFN_Solicitud_Telefono__c:contactoCaso.get(0).Phone;
				if(accion=='95' && (telf.length()> 9 || String.isBlank(nombre) || String.isBlank(apellidos)) || String.isBlank(telf)){
					insertaMovimiento = false;
				}
				INT_Contactos_Telefonicos__c contacto = new INT_Contactos_Telefonicos__c();
				contacto.ICT_TXT_Nombre__c=nombre;
				contacto.ICT_TXT_Apellidos__c=apellidos;
				contacto.ICT_EMA_Correo_Electronico__c=mail;
				contacto.ICT_TFN_Telefono__c = telf;
				//contacto.ICT_LKP_Movimiento_CIA__c=mov.Id;
				if(!String.isBlank(contacto.ICT_TFN_Telefono__c)){
					contacto.ICT_TXT_Tipo_Telefono__c = (contacto.ICT_TFN_Telefono__c.right(9).left(1)=='9'||contacto.ICT_TFN_Telefono__c.right(9).left(1)=='8')?'1':'2';
				}
				contactosTelefonicosInsertar.add(contacto);
				if(contactoCaso.get(0).HomePhone!=null){
					contacto = new INT_Contactos_Telefonicos__c();
					contacto.ICT_TXT_Nombre__c=nombre;
					contacto.ICT_TXT_Apellidos__c=apellidos;
					contacto.ICT_EMA_Correo_Electronico__c=mail;
					contacto.ICT_TFN_Telefono__c = contactoCaso.get(0).HomePhone;
					//contacto.ICT_LKP_Movimiento_CIA__c=mov.Id;
					contacto.ICT_TXT_Tipo_Telefono__c = (contacto.ICT_TFN_Telefono__c.right(9).left(1)=='9'||contacto.ICT_TFN_Telefono__c.right(9).left(1)=='8')?'1':'2';
					contactosTelefonicosInsertar.add(contacto);
				}
				if(contactoCaso.get(0).MobilePhone!=null){
					contacto = new INT_Contactos_Telefonicos__c();
					contacto.ICT_TXT_Nombre__c=nombre;
					contacto.ICT_TXT_Apellidos__c=apellidos;
					contacto.ICT_EMA_Correo_Electronico__c=mail;
					contacto.ICT_TFN_Telefono__c = contactoCaso.get(0).MobilePhone;
					//contacto.ICT_LKP_Movimiento_CIA__c=mov.Id;
					contacto.ICT_TXT_Tipo_Telefono__c = (contacto.ICT_TFN_Telefono__c.right(9).left(1)=='9'||contacto.ICT_TFN_Telefono__c.right(9).left(1)=='8')?'1':'2';
					contactosTelefonicosInsertar.add(contacto);
				}
			}
		}
		//listComentarios = Util_Caso.getMapComentariosCaso(new Set<Id>{caso.Id}).get(caso.Id);
		listComentarios= [SELECT Id, CMC_TXT_Comentario__c,CMC_SEL_Tipo__c,CMC_LKP_Caso__r.Type FROM Comentario_caso__c 
						  WHERE CMC_LKP_Caso__c=: caso.Id Order By CreatedDate ASC];
		String ultimocomentario;
		if(!listComentarios.isEmpty()){
			ultimocomentario = listComentarios[listComentarios.size()-1].CMC_TXT_Comentario__c;
			if(accion == '14' && listComentarios[listComentarios.size() - 1].CMC_SEL_Tipo__c == '08')
				insertaMovimiento = false;
		}		  
	
		//listPerjudicados = Util_Siniestro.queryPerjudicadosSini(new Set<ID>{caso.Id}).values();
		listPerjudicados= [SELECT Id, PRJ_TXT_Nombre__c, PRJ_SEL_Perjudicado_Tipo_Documento__c,
						   PRJ_TXT_Perjudicado_N_Documento__c, PRJ_TFN_Telefono_1__c,PRJ_TXT_Codigo_Postal__c,
						   PRJ_TXT_Direccion__c,PRJ_TXT_Poblacion__c,PRJ_SEL_Provincia__c,PRJ_SEL_Tipo_Perjudicado__c,
						   PRJ_TXT_Apellido_1__c, PRJ_TXT_Apellido_2__c,PRJ_TXT_Cbanc_Codigo_Entidad__c,
						   PRJ_TXT_Cbanc_Digito_Control__c,PRJ_TXT_Cbanc_Numero__c,PRJ_TXT_Cbanc_Sucursal_Oficina__c,
						   PRJ_TXT_Pais__c,PRJ_TXT_Cbanc_Pais__c,PRJ_TXT_Cbanc_Digito_Control_IBAN__c,
						   PRJ_EMA_Email__c
						   FROM Perjudicado_Siniestro__c WHERE PRJ_LKP_Siniestro__c=: caso.Id];
		//listGarantias = Util_Siniestro.queryGarantiasExistentes(new Set<Id>{caso.Id}).values();
		listGarantias= [SELECT Id, GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c,GSIN_LKP_Garantia__r.GAR_DIV_Importe_Reserva_Media__c
						FROM Garantia_Siniestro__c WHERE GSIN_LKP_Caso__c=: caso.Id];
		if(WOId==null){
			//listOrdenesTrabajo = Util_Orden_Trabajo.queryMapOTByCase(new Set<Id>{caso.Id}).values();
			listOrdenesTrabajo = Util_Orden_Trabajo.queryOT(null, caso.Id, null);
		} else{
			//listOrdenesTrabajo = Util_Orden_Trabajo.queryMapOTById(new SEt<Id>{WOId}).values();
			listOrdenesTrabajo = Util_Orden_Trabajo.queryOT(WOId, null, null);
		}
		
		if(accion == '99' || accion == '98' || accion == '97'){
			
			system.debug('Entra en accion 99');
			//Si estamos en PH, deben existir dos facturas (gestión y ordinaria)
			listFacturas = Database.query(queryFactura());
			if(!listFacturas.isEmpty()){
				factura = listFacturas.get(0);
				facturaGestion = null;
				if (CIAId == Label.IDE_PATRIA_HISPANA && Math.mod(listFacturas.size(),2)==0){
					if(listFacturas.get(0).FAC_CAS_Factura_de_Gestion__c){
						factura = listFacturas.get(1);
						facturaGestion = listFacturas.get(0);
					}else{
						facturaGestion = listFacturas.get(1);
					}
				}
			}
		}
				/*if(accion=='97'){//Cojo el importe total de todas las facturas del caso para pagos estadísticos
					Decimal importe = 0;
					for(Factura__c f : listFacturas){
						importe += f.FAC_NUM_ImporteFinal__c;
						system.debug('@@@@@@@@@Factura: '+ importe);
					}
					factura.FAC_NUM_ImporteFinal__c = importe;
				}*/

		/**
		 * Insertar datos en los objetos de Movimientos  
		 */
		//Insertar campos en Objeto INT_Movimiento_CIA__c 

		INT_Movimiento_CIA__c movimiento = new INT_Movimiento_CIA__c();
		
		//Campos de Encuestas
		/*if(movimientoEnError){
			movimiento.MOV_SEL_Estado_Movimiento__c = Label.BIT_ESTADO_ERROR;
			movimiento.MOV_TXT_Desc_Error__c = 'El teléfono del contacto es demasiado largo';
		}*/
			
		movimiento.MOV_SEL_Encuestador__c=caso.CAS_SEL_Encuestador__c;
		if(movimiento.MOV_SEL_Encuestador__c == 'Servitelco'){
			CIAId = '9999';
		} else if(movimiento.MOV_SEL_Encuestador__c == 'Stiga'){
			CIAId = '9998';
		}
		movimiento.MOV_TXT_Tipo_Encuesta__c=caso.CAS_TXT_Tipo_Encuesta__c;
		
		movimiento.MOV_TXT_Idioma__c=mapaTraduccionCuenta.get(IDIOMA + CIAId + 'CUE_SEL_Idioma__c' + caso.Account.CUE_SEL_Idioma__c);
		movimiento.MOV_TXT_Contador_Gremios__c = String.valueOf(listOrdenesTrabajo.size());
		movimiento.MOV_TXT_Contador_Telefonos__c=(Util_Siniestro.esSiniestro(caso))?String.valueOf(listContactosTel.size()):String.valueOf(contactosTelefonicosInsertar.size());
		movimiento.MOV_TXT_Num_Garantias_Enviadas__c=String.valueOf(listGarantias.size());
		movimiento.MOV_TXT_Accion__c = textoAccion;
		if(Util_Siniestro.esSiniestro(caso)){
			movimiento.MOV_TXT_Grupo_Causa_Desc__c=caso.CAS_SEL_Causa_Averia__c;
		}else if (!listOrdenesTrabajo.isEmpty()){//MartaHS quiere que este gremio se repita en este campo para servitelco
			movimiento.MOV_TXT_Grupo_Causa_Desc__c=mapaPicklistOt.get(listOrdenesTrabajo.get(0).OTR_SEL_Gremio__c);
		}
		movimiento.MOV_TXT_Causa_Rechazo__c=caso.CAS_SEL_Motivo_Rechazo__c;
		//movimiento.MOV_TXT_Causa_Siniestro__c=caso.CAS_SEL_Grupo_Causa__c;
		String traduccion = mapaTraduccionCaso.get(IDIOMA + CIAId + 'CAS_SEL_Grupo_Causa__c' + caso.CAS_SEL_Grupo_Causa__c);
		movimiento.MOV_TXT_Causa_Siniestro__c = (traduccion != null ? traduccion : caso.CAS_SEL_Grupo_Causa__c );
		movimiento.MOV_TXT_Causante_Apellido1__c=caso.CAS_TXT_Apellidos__c;
		movimiento.MOV_TXT_Causante_Apellido2__c=caso.CAS_TXT_Apellidos_2__c;
		if(String.isNotBlank(caso.CAS_SEL_Causante_Compania__c)){
			if(CIAId == Label.IDE_SEGURCAIXA){
				movimiento.MOV_TXT_Causante_Compania__c=caso.CAS_SEL_Causante_Compania__c.left(12);
			}else{
				movimiento.MOV_TXT_Causante_Compania__c=caso.CAS_SEL_Causante_Compania__c.left(25);
			}
		}
	   
		
		movimiento.MOV_TXT_Causante_Direccion__c=caso.CAS_TXT_Causante_Direccion__c;
		movimiento.MOV_TXT_Causante_Nombre__c=caso.CAS_TXT_Nombre__c;
		movimiento.MOV_TXT_Causante_Num_Documento__c=caso.CAS_TXT_Causante_N_Documento__c;
		movimiento.MOV_TXT_Causante_Num_Poliza__c=caso.CAS_TXT_Causante_Poliza_R_C__c;
		movimiento.MOV_TXT_Causante_Poblacion__c=caso.CAS_TXT_Causante_Poblacion__c;
		movimiento.MOV_TXT_Causante_Provincia__c=caso.CAS_SEL_Causante_Provincia__c;
		movimiento.MOV_TXT_Causante_Responsable__c=caso.CAS_SEL_Causante_Responsable__c;
		movimiento.MOV_TFN_Causante_Telefono__c=caso.CAS_TFN_Telefono_1__c;
		movimiento.MOV_TXT_Causante_Tipo_Documento__c=caso.CAS_SEL_Causante_Tipo_Documento__c;
		movimiento.MOV_TXT_Codigo_Apertura__c=caso.CAS_TXT_Codigo_Apertura__c;
		movimiento.MOV_LKP_Caso__c = caso.id;
		movimiento.MOV_TXT_Codigo_Cliente_CIA__c=caso.CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Cliente_ING__c;
		movimiento.MOV_TXT_Codigo_Perito__c=caso.CAS_LKP_Perito__r.PER_TXT_Codigo_Perito__c;
		if(String.isNotBlank(caso.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c)){
			aux = caso.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Cod_Producto__c.split('\\|');
			movimiento.MOV_TXT_Codigo_Producto__c=aux.get(0);
			if(aux.size()>1){
				movimiento.MOV_TXT_Modalidad__c=aux.get(1);
			} if(aux.size()>2){
				movimiento.MOV_TXT_Submodalidad__c=aux.get(2);
			}
		}
		
		//Se comenta, pendiente de traducción
		//movimiento.MOV_TXT_Codigo_Reapertura__c=caso.CAS_SEL_Motivo_Reapertura__c;
		String traduccionRechazo = mapaTraduccionCaso.get(IDIOMA + CIAId + 'CAS_SEL_Motivo_Rechazo__c' + caso.CAS_SEL_Motivo_Rechazo__c);
		movimiento.MOV_TXT_Responsable_Siniestro__c = (traduccionRechazo != null ? traduccionRechazo : caso.CAS_SEL_Motivo_Rechazo__c );
		//movimiento.MOV_TXT_Codigo_Rechazo__c=caso.CAS_SEL_Codigo_Rechazo__c;
		movimiento.MOV_LKP_Compania__c=caso.CAS_LKP_Compania__c;
		//movimiento.CreatedDate=caso.LastModifiedDate;
		movimiento.MOV_EMA_Email_Asegurado__c=caso.CAS_EMA_Solicitud_Email__c;
		movimiento.MOV_DAT_Fecha_Apertura__c=caso.CreatedDate;
		movimiento.MOV_DAT_Fecha_Ocurrencia__c=caso.CAS_DAT_Fecha_Ocurrencia__c;
		movimiento.MOV_TXT_Gremio__c=caso.CAS_SEL_Gremio_Principal__c;
		//movimiento.MOV_TXT_Grupo_Causa__c=caso.CAS_SEL_Grupo_Causa__c;
		movimiento.MOV_DIV_Importe_Reserva__c=caso.CAS_DIV_Importe_Total__c;
		movimiento.MOV_TXT_Motivo_Perito__c=caso.CAS_SEL_Motivo_Peticion_Perito__c;
		movimiento.MOV_TXT_Motivo_Perito_Obs__c=caso.CAS_SEL_Motivo_Peticion_Perito__c;
		movimiento.MOV_TXT_Num_Caso_CIA__c = caso.CAS_TXT_Num_Caso_CIA__c;
		movimiento.MOV_TXT_Num_Caso_HS__c=caso.CAS_TXT_Num_Caso_HS__c;
		movimiento.MOV_TXT_Num_Certificado_Poliza__c=caso.CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Certificado__c;
		movimiento.MOV_TXT_Num_OrdenTrabajo_HS__c=caso.CAS_LKP_Orden_Trabajo_Principal__r.OTR_TXT_Num_OrdenTrabajo_HS__c;
		if(String.isNotBlank(caso.CAS_LKP_PolizaContrato__r.name)){
			movimiento.MOV_TXT_Num_Poliza__c=String.valueOf(Long.valueOf(caso.CAS_LKP_PolizaContrato__r.name)).left(6);
		}
		//movimiento.MOV_TXT_Siniestro_Consorciable__c=caso.CAS_CAS_Siniestro_Consorciable__c;
		movimiento.MOV_TXT_Suplemento_Pdte__c=caso.CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Suplemento_Poliza__c;
		movimiento.MOV_TFN_Telefono_Asegurado__c=caso.CAS_TFN_Solicitud_Telefono__c;
		//temporal para demo Patria, pues se van a enviar sólo los siniestros reparables.
		//movimiento.MOV_TXT_Tipo_Actuacion__c=caso.Type;
		String traduccionTipo = mapaTraduccionCaso.get(IDIOMA + CIAId + 'Type' + caso.Type);
		system.debug('Mapa traducc: '+ mapaTraduccionCaso);
		system.debug('vamos a hacer el get de: '+ IDIOMA + CIAId + 'Type' + caso.Type);
		system.debug('traduccion tipo = ' + traduccionTipo);
		if(traduccionTipo == null){
			insertaMovimiento = false;
		}else{
			movimiento.MOV_TXT_Tipo_Actuacion__c=traduccionTipo;
		}
		
		if(caso.CAS_LKP_PolizaContrato__c!=null && caso.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__c !=null){
			movimiento.MOV_TXT_Tipo_Producto__c = mapaTraduccionTipoProducto.get(IDIOMA+CIAId+'TPR_SEL_Tipo_Producto__c'+caso.CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Tipo_Producto__c);
		} else {
			movimiento.MOV_TXT_Tipo_Producto__c = '0';
		}
		movimiento.MOV_DAT_Fecha_Informe_Pericial__c = caso.CAS_DAT_Fecha_Informe_Pericial__c;
		if(listComentarios.size()>0){
			if (accion=='14' && listComentarios.size()==1 && CIAId == Label.IDE_PATRIA_HISPANA)
				insertaMovimiento = false;
			movimiento.MOV_TXT_Descripcion__c = listComentarios[0].CMC_TXT_Comentario__c.left(114);
		}
		movimiento.MOV_TXT_Codigo_Gestor_Poliza__c = caso.CAS_LKP_VersionPolizaContrato__r.POLV_TXT_Codigo_Gestor_CIA__c ;
		movimiento.MOV_DAT_Fecha_Cierre__c = caso.ClosedDate;
		if(caso.CAS_DAT_Fecha_Pago_Minuta__c!=null){
			movimiento.MOV_DAT_Fecha_Factura_Perito__c = caso.CAS_DAT_Fecha_Pago_Minuta__c.date();
		}
		movimiento.MOV_TXT_Provincia__c=caso.Account.CUE_SEL_Provincia__c;
		//LLM
		Set<String> estadosCerrados = new Set<String>{label.CAS_ESTADO_CERRADO,label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR,label.CAS_ESTADO_ANULADO,label.CAS_ESTADO_RECHAZADO,label.CAS_ESTADO_CERRADO_FACTURADO};
		//añadir al set estados '799','733','793','730','731','732'???
		if (estadosCerrados.contains(caso.Status)){
			 movimiento.MOV_TXT_Estado_Siniestro__c = '2';
		//	 movimiento.MOV_DIV_Importe_Gestion__c = decimal.valueOf(label.PH_Importe_Gestion);
		}else{
			 movimiento.MOV_TXT_Estado_Siniestro__c = '1';
		 //	movimiento.MOV_DIV_Importe_Gestion__c = 0;
		}
		//movimiento.MOV_TXT_Estado_Siniestro__c = caso.Status; //Requiere traducción?(Error String too Long)

		//Campos que requieren traducción
		movimiento.MOV_TXT_Responsable_Siniestro__c=mapaTraduccionCaso.get(IDIOMA + CIAId + 'CAS_CAS_Tercero_Causante__c' + booleanToString(caso.CAS_CAS_Tercero_Causante__c));
		//movimiento.MOV_TXT_Codigo_Cierre__c=Util_Movimientos.traduccionCampo(CIAId, 'CAS_TXT_Codigo_Cierre__c', caso.CAS_TXT_Codigo_Cierre__c, mapa); Pendiente de traducir y definir valores en SF

		//Campos Asignados con información que no proviene de un campo de Salesforce
		movimiento.MOV_TXT_Tipo_Movimiento__c=tipoMovimiento;
		movimiento.MOV_TXT_Codigo_Modificacion__c=codigoModificacion;
		
		//Cargamos el momento de la creación del movimiento
		movimiento.MOV_DAT_Fecha_Generacion__c = generacion;
		
		//Comprobamos, en caso de que el movimiento NO sea de apertura, que tiene ya un movimiento de apertura generado previamente.
		if ((accion != '1') && movimientoEnEspera(CIAId, casoId))
			//insertaMovimiento = false;
			movimiento.MOV_SEL_Estado_Movimiento__c = '08';
			
		//Campos provenientes de factura
		if (accion == '99' || accion == '98' || accion == '97' || accion == '96'){//Si es un tipo Facturación, Pagos, Pagos estadísticos o IVA pagos.
			system.debug('LLM entra!');
			system.debug('LA ID DE LA FACTURA ES: ' + factura.Id);
			
			//movimiento.MOV_DIV_Importe_facturado_garantia1__c = importeGarantias;
			//movimiento.MOV_DIV_Importe_IVA_garantia1__c = importeGarantias * factura.FAC_POR_PorcentajeIVA__c / 100;
			movimiento.MOV_DAT_Fecha_Factura__c = factura.FAC_DAT_FechaFactura__c;
			movimiento.MOV_DIV_Retencion_Pago__c = factura.FAC_DIV_RetencionPago__c;
			movimiento.MOV_TXT_Mes_Pago__c = String.valueOf(factura.FAC_NUM_MesPago__c);
			movimiento.MOV_TXT_Indicador_Quincena__c = String.valueOf(factura.FAC_NUM_IndicadorQuincena__c);
			movimiento.MOV_TXT_Indicador_Franquicia__c = booleanToString(factura.FAC_CAS_IndicadorPagoFranquicia__c);
			movimiento.MOV_DIV_Importe_Franquicia__c = factura.FAC_DIV_ImporteFranquicia__c;
			movimiento.MOV_DIV_Importe_Pago__c = factura.FAC_DIV_Importe_Pago__c;
			movimiento.MOV_TXT_Codigo_Capital__c = factura.FAC_TXT_Codigo_Capital__c;
			movimiento.MOV_TXT_Ano_Pago__c = String.valueOf(factura.FAC_NUM_Ano_Pago__c);
			movimiento.MOV_NUM_Porcentaje_IVA__c = factura.FAC_POR_PorcentajeIVA__c;
			movimiento.MOV_TXT_Numero_factura__c = factura.FAC_TXT_Numero_factura__c;
			
			if(facturaGestion != null){
				system.debug('ha entrado en factura de gestión');
				movimiento.MOV_DIV_Importe_Gestion__c = facturaGestion.FAC_NUM_ImporteFinal__c;
				movimiento.MOV_DIV_Importe_IVA_Gestion__c = facturaGestion.FAC_NUM_ImporteIVA__c;
				movimiento.MOV_NUM_Porcentaje_IVA_Gestion__c = facturaGestion.FAC_POR_PorcentajeIVA__c;
			}
			if(factura.FAC_DIV_RetencionPago__c!=null){
				//movimiento.MOV_NUM_Porc_Retencion__c = String.ValueOf(factura.FAC_DIV_RetencionPago__c);//Campo nuevo?Fórmula?
			}
			movimiento.MOV_DIV_Base_Imponible__c = factura.FAC_NUM_Base_Imponible__c;
			movimiento.MOV_DIV_Importe_Final__c = factura.FAC_NUM_ImporteFinal__c;
			//Ver longitud real que tendrá este campo!!!
			movimiento.MOV_TXT_Tipo_Registro__c = (factura.FAC_TXT_Tipo_Registro__c.length()==1)?factura.FAC_TXT_Tipo_Registro__c:'e';
			movimiento.MOV_DIV_Importe_IVA__c = factura.FAC_NUM_ImporteIVA__c;
			/*Campos pendientes de aclarar
			 movimiento.MOV_DIV_Importe_Gastos__c
			 movimiento.MOV_DIV_Importe_Honorarios__c
			 movimiento.MOV_TXT_Codigo_Recurso__c
			 movimiento.MOV_TXT_Numero_Pago__c
			 movimiento.MOV_TXT_Perceptor__
			 movimiento.MOV_TXT_Tipo_IVA__c*/
			 
			if(!listOrdenesTrabajo.isEmpty()){
				movimiento.MOV_TXT_Num_Doc_Profesional__c = listOrdenesTrabajo.get(0).OTR_LKP_Recurso_Servicio__r.RSE_TXT_Numero_Documento__c;
			}
		}
		if(!listGarantias.isEmpty()){
			//Temporal, aclarar longitud campo código garantía
			if(String.isNotBlank(listGarantias.get(0).GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c)){
				movimiento.MOV_TXT_Codigo_Pago__c = listGarantias.get(0).GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c.left(3);
			}
		}
		movimientosInsertar = duplicaMovimientos(movimiento);
		system.debug('va a insertrarar: ' +movimientosInsertar + 'con al flag a ' + insertaMovimiento);
		if(!movimientosInsertar.isEmpty()){
			try{
				if(insertaMovimiento){
					insert movimientosInsertar;
			   		marcaMovimientosEnEspera(accion, casoId, movimientosInsertar.get(0).MOV_TXT_Num_Caso_HS__c);  
				}
			}catch(Exception e){
				system.debug('********** EXCEPTION SQL : ' + e);
			}
		}
		
		system.debug('La id del movimineto insertado es:  ' + movimientosInsertar.get(0).id);

		//Insertar campos en Objeto INT_Contactos_Telefonicos__c
		
			for(INT_Movimiento_CIA__c mov :movimientosInsertar){
				if(Util_Siniestro.esSiniestro(caso)){
					for (Contacto_telefonico__c c : listContactosTel){
						INT_Contactos_Telefonicos__c contacto = new INT_Contactos_Telefonicos__c();
						contacto.ICT_TXT_Nombre__c=c.CTF_FOR_Nombre__c;
						contacto.ICT_TXT_Apellidos__c=c.CTF_FOR_Apellidos__c;
						contacto.ICT_EMA_Correo_Electronico__c=c.CTF_FOR_Email__c;
						contacto.ICT_TFN_Telefono__c = c.CTF_FOR_Telefono__c;
						contacto.ICT_TXT_Hora_Desde__c = c.CTF_SEL_Hora_desde__c;
						contacto.ICT_TXT_Hora_Hasta__c = c.CTF_SEL_Hora_hasta__c;
						contacto.ICT_LKP_Movimiento_CIA__c=mov.Id;
						contacto.ICT_TXT_Tipo_Telefono__c = (contacto.ICT_TFN_Telefono__c.right(9).left(1)=='9'||contacto.ICT_TFN_Telefono__c.right(9).left(1)=='8')?'1':'2';
						contactosTelefonicosInsertar.add(contacto);
					}
				}else{
					for(Integer i=0;i<contactosTelefonicosInsertar.size();i++){
						contactosTelefonicosInsertar.get(i).ICT_LKP_Movimiento_CIA__c=mov.Id;
					}
				}
			}
		
		if(!contactosTelefonicosInsertar.isEmpty()){
			try{
				insert contactosTelefonicosInsertar;
			}catch(Exception e){
				system.debug('********** EXCEPTION SQL : ' + e);
			}
		}

		//Insertar campos en Objeto INT_Comentarios__c
		INT_Comentarios__c comentario = new INT_Comentarios__c();
		String aux1;
		for(INT_Movimiento_CIA__c mov :movimientosInsertar){
			for (Comentario_caso__c c : listComentarios){
				if(String.isEmpty(c.CMC_SEL_Tipo__c)) {c.CMC_SEL_Tipo__c='00';} 
				aux1 = mapaPicklistComentarios.get(c.CMC_SEL_Tipo__c);
				if(aux1.containsIgnoreCase('Manual')){aux1 = mapaPicklistCaso.get(c.CMC_LKP_Caso__r.Type);
				}else if(aux1.containsIgnoreCase('Repara')){
					//system.debug('se mete en repara con comentario: ' + c.CMC_TXT_Comentario__c);
					comentario.ICC_TXT_Comentario_Sin_Rep__c = (c.CMC_TXT_Comentario__c!=null)?c.CMC_TXT_Comentario__c.left(255):null;
				}else if(aux1.containsIgnoreCase('Rechaz')){
					comentario.ICC_TXT_Comentario_Rechazo__c = (c.CMC_TXT_Comentario__c!=null)?c.CMC_TXT_Comentario__c.left(255):null;
				}else if(aux1.containsIgnoreCase('Indemni')){
					comentario.ICC_TXT_Comentario_Sin_Indem__c = (c.CMC_TXT_Comentario__c!=null)?c.CMC_TXT_Comentario__c.left(255):null;
				}
				//Para Patria, si no es movimiento de comentario, debe ir el primero de todos.
				if(CIAId == Label.IDE_PATRIA_HISPANA){
					if(accion!='14'){
						comentario.ICC_TXT_Comentario_Sin_Rep__c=mov.MOV_TXT_Descripcion__c;
					}
					else{
						comentario.ICC_TXT_Comentario_Sin_Rep__c = ultimoComentario;
					}
				}
					
				comentario.ICC_TXT_Comentario__c=(c.CMC_TXT_Comentario__c!=null)?c.CMC_TXT_Comentario__c.left(1000):null;
				comentario.ICC_LKP_Movimiento_CIA__c=mov.Id;
			}
		}
		if(comentario.ICC_LKP_Movimiento_CIA__c!=null){//Si se ha añadido algún comentario
			try{
			insert comentario;
			}catch(Exception e){
				system.debug('********** EXCEPTION SQL : ' + e);
			}
		}


		Decimal importeGarantias= 0;	 
		for(INT_Movimiento_CIA__c mov :movimientosInsertar){
			for (Garantia_Siniestro__c g : listGarantias){
				INT_Garantias_Siniestros__c garantia = new INT_Garantias_Siniestros__c();
				if(g.GSIN_LKP_Garantia__c!=null){
					//Temporal para demo patria hispana, sólo se envían tres posiciones
					garantia.IGS_TXT_Codigo_Garantia__c=g.GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c.left(3);
					garantia.IGS_DIV_Importe_Reserva_Garantia__c=g.GSIN_LKP_Garantia__r.GAR_DIV_Importe_Reserva_Media__c;
					//el importe de IVA sólo se rellena para Patria
					if(factura != new Factura__c()){
						System.debug('@@@@@g.GSIN_LKP_Garantia__c '+g.GSIN_LKP_Garantia__c);
						System.debug('@@@@@g.FACTURA '+factura);
						garantia.IGS_DIV_Importe_IVA__c = g.GSIN_LKP_Garantia__r.GAR_DIV_Importe_Reserva_Media__c * factura.FAC_POR_PorcentajeIVA__c / 100;
					}
				}
				system.debug('la id de movimiento es: ' + mov.Id);
				garantia.IGS_LKP_Movimiento_CIA__c=mov.Id;
				//para NN a futuro
				//garantia.IGS_FOR_Importe_Reserva_Garantia_Sin_IVA__c = g.GSIN_LKP_Garantia__r.GAR_DIV_Importe_Reserva_Media__c - garantia.IGS_DIV_Importe_IVA__c;
				
				garantiasInsertar.add(garantia);
						   	
				/*INT_Garantias_Siniestros__c garantia = new INT_Garantias_Siniestros__c();
				garantia.IGS_TXT_Codigo_Garantia__c=g.GSIN_LKP_Garantia__r.GAR_TXT_Codigo_Garantia__c;
				//cuando el importe total va sobre le primera garantía y el resto va a cero. 
				garantia.IGS_DIV_Importe_Reserva_Garantia__c=0;
				garantia.IGS_DIV_Importe_IVA__c = 0;
				garantia.IGS_LKP_Movimiento_CIA__c=mov.Id;
				
				garantiasInsertar.add(garantia);*/
			   // importeGarantias +=  g.GSIN_LKP_Garantia__r.GAR_DIV_Importe_Reserva_Media__c;
			}
			/*if (CIAId == Label.IDE_PATRIA_HISPANA && !garantiasInsertar.isEmpty()){
				garantiasInsertar[0].IGS_DIV_Importe_Reserva_Garantia__c = factura.FAC_DIV_ImporteFactura__c;
				garantiasInsertar[0].IGS_DIV_Importe_IVA__c = factura.FAC_NUM_ImporteIVA__c;
			}*/
		}
	   
		system.debug('Va a insertar garantías: ' + garantiasInsertar);
		if(!garantiasInsertar.isEmpty()){
			try{
				insert garantiasInsertar;
			}catch(Exception e){
				system.debug('********** EXCEPTION SQL : ' + e);
			}
		}

		//Insertar campos en Objeto INT_Perjudicados__c
		for(INT_Movimiento_CIA__c mov :movimientosInsertar){
			for (Perjudicado_Siniestro__c p : listPerjudicados){
				INT_Perjudicados__c perjudicado = new INT_Perjudicados__c();
				if(p.PRJ_TXT_Cbanc_Pais__c == null){
					p.PRJ_TXT_Cbanc_Pais__c = '0';
				}
				if(p.PRJ_TXT_Cbanc_Digito_Control_IBAN__c == null){
					p.PRJ_TXT_Cbanc_Digito_Control_IBAN__c = '0';
				}
				perjudicado.IPE_TXT_Cbanc_IBAN__c = p.PRJ_TXT_Cbanc_Pais__c + p.PRJ_TXT_Cbanc_Digito_Control_IBAN__c;
				perjudicado.IPE_TXT_Apellido_1__c=p.PRJ_TXT_Apellido_1__c;
				perjudicado.IPE_TXT_Apellido_2__c=p.PRJ_TXT_Apellido_2__c;
				perjudicado.IPE_TXT_Codigo_Postal__c=p.PRJ_TXT_Codigo_Postal__c;
				perjudicado.IPE_TXT_Direccion__c=p.PRJ_TXT_Direccion__c;
				perjudicado.IPE_TXT_Nombre__c=p.PRJ_TXT_Nombre__c;
				perjudicado.IPE_TXT_Perjudicado_N_Documento__c=p.PRJ_TXT_Perjudicado_N_Documento__c;
				perjudicado.IPE_TXT_Poblacion__c=p.PRJ_TXT_Poblacion__c;
				perjudicado.IPE_TXT_Provincia__c=p.PRJ_SEL_Provincia__c;
				perjudicado.IPE_TFN_Telefono__c=p.PRJ_TFN_Telefono_1__c;
				perjudicado.IPE_TXT_Tipo_Perjudicado__c=p.PRJ_SEL_Tipo_Perjudicado__c;
				perjudicado.IPE_TXT_Cbanc_Codigo_Entidad__c = p.PRJ_TXT_Cbanc_Codigo_Entidad__c;
				perjudicado.IPE_TXT_Cbanc_Digito_Control__c = p.PRJ_TXT_Cbanc_Digito_Control__c;
				perjudicado.IPE_TXT_Cbanc_Numero__c = p.PRJ_TXT_Cbanc_Numero__c;
				perjudicado.IPE_TXT_Cbanc_Sucursal_Oficina__c = p.PRJ_TXT_Cbanc_Sucursal_Oficina__c;
				//perjudicado.IPE_TXT_Pais__c=p.PRJ_TXT_Pais__c;//Traducción
				perjudicado.IPE_EMA_Perjudicado_Email__c=p.PRJ_EMA_Email__c;
				perjudicado.IPE_LKP_Movimiento_CIA__c=mov.Id;
	
				//Campos que requieren traducción
				perjudicado.IPE_TXT_Perjudicado_Tipo_Documento__c = mapaTraduccionPerjudicado.get(IDIOMA + CIAId + 'PRJ_SEL_Perjudicado_Tipo_Documento__c' + p.PRJ_SEL_Perjudicado_Tipo_Documento__c);
	
				perjudicadosInsertar.add(perjudicado);
			}
		}
		if(!perjudicadosInsertar.isEmpty()){
			try{
				insert perjudicadosInsertar;
			}catch(Exception e){
				system.debug('********** EXCEPTION SQL : ' + e);
			}
		}

		//Insertar campos en Objeto INT_Orden_Trabajo__c
		for(INT_Movimiento_CIA__c mov :movimientosInsertar){
			for (WorkOrder ot : listOrdenesTrabajo){
				INT_Orden_Trabajo__c ordenTrabajo = new INT_Orden_Trabajo__c();
				ordenTrabajo.IOT_LKP_Movimiento_CIA__c=mov.Id;
				ordenTrabajo.IOT_TXT_Num_OrdenTrabajo_HS__c = ot.OTR_TXT_Num_OrdenTrabajo_HS__c;
				ordenTrabajo.IOT_TXT_Gremio__c = ot.OTR_SEL_Gremio__c;
				ordenTrabajo.IOT_TXT_Gremio_Desc__c = mapaPicklistOt.get(ot.OTR_SEL_Gremio__c);
				//ordenTrabajo.IOT_TXT_Urgente__c=traduccionCampo(CIAId,'OTR_CAS_Urgente__c',booleanToString(ot.OTR_CAS_Urgente__c),mapa);
				//ordenTrabajo.IOT_TXT_Motivo_Anulacion__c=ot.OTR_Motivo_anulacion__c;
	
				ordenesTrabajoInsertar.add(ordenTrabajo);
			}
		}
		if(!ordenesTrabajoInsertar.isEmpty()){
			try{
				insert ordenesTrabajoInsertar;
			}catch(Exception e){
				system.debug('********** EXCEPTION SQL : ' + e);
			}
		}

	}//FIN generarMovimientos()

	/**
	 * Comprueba en función de la ID de la compañía y de los códigos de movimiento y modificación si se debe
	 * enviar y por tanto guardar en la tabla de movimientos
	 *  @param CIAId  -  Id del caso que se cargará en el objeto Movimientos
	 *  @param accion  -  String de la acción según Tabla COM
	 *  @param casoId   -   Id del caso
	 *
	 *  @return !listIntMovCIA.isEmpty()  -  true: se debe enviar a Movimientos /false: no se debe enviar a Movimientos 
	 */
	public static void compruebaEnviable(Id casoId, String CIAId, String accion){
		//List<Integracion_Movimiento_CIA__mdt> listIntMovCIA = Util_Metadatos.getIntMovCIAMetadata(new Set<String>{CIAId},new Set<String>{accion}).values();
		List<Integracion_Movimiento_CIA__mdt> listIntMovCIA = [SELECT Identificador_CIA__c FROM Integracion_Movimiento_CIA__mdt 
															   WHERE (Identificador_CIA__c = :CIAId AND  Accion__c = : accion)];
		
		System.debug('@@@@@Comrpueba: '+casoId+' '+CIAId+' '+accion);
		if(!listIntMovCIA.isEmpty()){
			system.debug('entra en el metadato');
			Util_Movimientos mov= new Util_Movimientos(casoId,CIAId,accion,null, system.now());
			system.debug('va a encolar el trabajo');
			System.enqueueJob(mov);
		}
	}

	/**
	 * Comprueba en función de la ID de la compañía y de los códigos de movimiento y modificación si se debe
	 * enviar y por tanto guardar en la tabla de movimientos
	 *  @param CIAId  -  Id del caso que se cargará en el objeto Movimientos
	 *  @param accion  -  String de la acción según Tabla COM
	 *  @param casoId   -   Id del caso
	 *  @param WOId -   Id de la WO
	 *
	 *  @return !listIntMovCIA.isEmpty()  -  true: se debe enviar a Movimientos /false: no se debe enviar a Movimientos 
	 */
	public static void compruebaEnviable(Id casoId, String CIAId, String accion,Id WOId){
		//List<Integracion_Movimiento_CIA__mdt> listIntMovCIA = Util_Metadatos.getIntMovCIAMetadata(new Set<String>{CIAId},new Set<String>{accion}).values();
		List<Integracion_Movimiento_CIA__mdt> listIntMovCIA = [SELECT Identificador_CIA__c FROM Integracion_Movimiento_CIA__mdt 
															   WHERE (Identificador_CIA__c = :CIAId AND  Accion__c = : accion)];
		System.debug('@@@@@Comprueba enviable acción: ' + accion);
		if(!listIntMovCIA.isEmpty()){
			Util_Movimientos mov= new Util_Movimientos(casoId,CIAId,accion,WOId, system.now());
			System.enqueueJob(mov);
		}
	}
	 /**
	 * Comprueba en función de la ID de la compañía y de los códigos de movimiento y modificación si se debe
	 * enviar y por tanto guardar en la tabla de movimientos. Invocado desde Process Builder
	 *  @param CIAId  -  Id del caso que se cargará en el objeto Movimientos
	 *  @param accion  -  String de la acción según Tabla COM
	 *  @param casoId   -   Id del caso
	 *  @param WOId -   Id de la WO
	 *
	 *  @return !listIntMovCIA.isEmpty()  -  true: se debe enviar a Movimientos /false: no se debe enviar a Movimientos 
	 */
	@InvocableMethod(label='compruebaEnviablePB' description='compruebaEnviablePB')
	public static void compruebaEnviablePB(List<ParametrosPB> parametros){
		
		Id casoId;
		String CIAId;
		String accion;
		Id WOId;
		
		for (ParametrosPB p : parametros) {
			casoId=p.casoIdPB;
			CIAId=p.CIAIdPB;
			accion=p.accionPB;
			WOId=p.WOIdPB;
	}
		//List<Integracion_Movimiento_CIA__mdt> listIntMovCIA = Util_Metadatos.getIntMovCIAMetadata(new Set<String>{CIAId},new Set<String>{accion}).values();
		List<Integracion_Movimiento_CIA__mdt> listIntMovCIA = [SELECT Identificador_CIA__c FROM Integracion_Movimiento_CIA__mdt 
															   WHERE (Identificador_CIA__c = :CIAId AND  Accion__c = : accion)];
		if(!listIntMovCIA.isEmpty()){
			Util_Movimientos mov= new Util_Movimientos(casoId,CIAId,accion,WOId, system.now());
			System.enqueueJob(mov);
		}
	}
	/**
	 * Método para transformar el valor de un campo Boolean a un String,
	 * para enviar el String al método de traducción.
	 *  @param valor  -  Boolean del campo en Salesforce que se va a traducir 
	 *
	 *  @return valorString  -  String del valor Boolean que se recibe 
	 */
	public static String booleanToString(Boolean valor){
		String valorString;
		//Si existe la traducción se mantiene el valor de Salesforce
		if (valor==true){
			valorString='true';
		} else{
			valorString='false';
		}
		return valorString;
	}

	public void execute(QueueableContext context) {
		system.debug('va a generar los mpvimientos');
		generarMovimientos();
	}

	/**
	 * Devuelve un mapa de envíos programados a partir de sus ids.
	 *
	 * @param ids: ids de los envíos a buscar
	 * @return mapa de envíos programados encontrados
	 */
	public static Map<Id,INT_Envio_Programado__c> queryEnvioProgramado(Set<Id> ids){
		Map<Id,INT_Envio_Programado__c> mapa = new Map<Id,INT_Envio_Programado__c>();
		if(ids != null && !ids.isEmpty()){
			for(List<INT_Envio_Programado__c> lista:[SELECT Id,
							ENV_LKP_Fichero__c,
							ENV_SEL_Hora__c,
							ENV_NUM_Contador_Lote__c, 
							ENV_LKP_Fichero__r.FIC_LKP_Compania__r.Id, ENV_LKP_Fichero__r.Name,
							ENV_LKP_Fichero__r.FIC_TXT_Query__c
					 FROM INT_Envio_Programado__c WHERE ENV_LKP_Fichero__c IN :ids]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Método para generar los duplicados para pagos e IVA pagos para la CIA Almudena, ya que su disparador es el mismo
	 *  @param INT_Movimiento_CIA__c  -  Movimiento a duplicar 
	 *
	 *  @return List<INT_Movimiento_CIA__c>  -  Lista de movimientos a insertar. Estará contenida 
	 *  únicamente por el movimiento a insertar en caso de que no aplique.
	 */
	private List<INT_Movimiento_CIA__c> duplicaMovimientos(INT_Movimiento_CIA__c mov){
		List<INT_Movimiento_CIA__c> listRetorno = new List<INT_Movimiento_CIA__c>();
		INT_Movimiento_CIA__c movimiento;
		if(CIAId==Label.IDE_ALMUDENA && accion == '98'){//La acción 98 se corresponde con los movimientos que se generan desde facturación
			movimiento=mov.clone(false,true,false,false);
			mov.MOV_TXT_Codigo_Modificacion__c = '98';
			movimiento.MOV_TXT_Codigo_Modificacion__c = '96';
			listRetorno.add(movimiento);
		}
		listRetorno.add(mov);
		return listRetorno;
	}

	/**
	 * Se monta la query dinámicamente en función de si se debe buscar por WO o por caso
	 *
	 *  @return String  retorno  Sentencia sobre la que hacer la query 
	 */
  private String queryFactura(){
		String retorno = 'SELECT Id,FAC_DAT_FechaFactura__c,FAC_DIV_RetencionPago__c,FAC_NUM_MesPago__c,FAC_NUM_IndicadorQuincena__c,'; 
		retorno += 'FAC_CAS_IndicadorPagoFranquicia__c,FAC_DIV_ImporteFranquicia__c,FAC_DIV_Importe_Pago__c,FAC_TXT_Codigo_Capital__c,FAC_NUM_Ano_Pago__c,FAC_POR_PorcentajeIVA__c, ';
		retorno += 'FAC_TXT_Numero_factura__c,FAC_NUM_Base_Imponible__c,FAC_NUM_ImporteFinal__c,FAC_TXT_Tipo_Registro__c,FAC_NUM_ImporteIVA__c, FAC_CAS_Factura_de_Gestion__c ';
		retorno += 'FROM Factura__c ';
		if(WOId != null){
			retorno +='WHERE FAC_LKP_WorkOrkder__c=\''+WOId+'\'';
		} else{
			retorno += 'WHERE FAC_LKP_Caso__c=\''+casoId+'\' OR FAC_LKP_WorkOrkder__r.CaseId=\''+casoId+'\'';
		}
		return retorno;
	}
	
	/*
	private List<Factura__c> queryFactura(){
		List<Factura__c> retorno = new List<Factura__c>();
		if(WOId != null){
			retorno = Util_Factura.queryFacturaByIdWorkOrder(new Set<Id>{WOId}).values();
		} else{
			retorno = Util_Factura.queryFacturaByIdCaso(new Set<Id>{casoId}).values();
		}
		return retorno;
	}*/
	

	/**
	 *  Se llama desde el trigger de caso
	 */
	
	public static void generaMovimientos(List<Case> triggerNew, Map<Id, Case> triggerOldMap, Map<Id, Account> mapaCuentas){
		
		for(Case caso : triggerNew){
			System.debug('******Inicia generación de movimientos en TRG_Caso, comprueba si aplicable');
			if(Util_Siniestro.esSiniestro(caso)){ 
				Account compania = mapaCuentas.get(caso.CAS_LKP_Compania__c);
				if(compania != null){
					/*if(Trigger.isInsert){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'1');
					}*/
					if(caso.Status == label.CAS_ESTADO_REAPERTURADO 
							&& (Trigger.isInsert || caso.Status != triggerOldMap.get(caso.Id).Status)){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'3');
					}
					if(caso.Status == label.CAS_ESTADO_CERRADO 
							&& (Trigger.isInsert || caso.Status != triggerOldMap.get(caso.Id).Status)){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'4');
					}
					if(caso.CAS_CAS_Siniestro_Encuestado__c == true
							&& (Trigger.isInsert || caso.CAS_CAS_Siniestro_Encuestado__c != triggerOldMap.get(caso.Id).CAS_CAS_Siniestro_Encuestado__c)){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'5');
					}
					if(Trigger.isUpdate && caso.CAS_TXT_Sondeo_Causa__c != triggerOldMap.get(caso.Id).CAS_TXT_Sondeo_Causa__c){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'8');
					}
					if((Trigger.isInsert && Util_Siniestro.terceroModificado(caso, null))
							|| (Trigger.isUpdate && Util_Siniestro.terceroModificado(caso, triggerOldMap.get(caso.Id)))){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'11');
					}
					if(Trigger.isUpdate && caso.CAS_CAS_Tercero_Causante__c == true 
							&& triggerOldMap.get(caso.Id).CAS_CAS_Tercero_Causante__c != caso.CAS_CAS_Tercero_Causante__c){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'13');
					}
					if(caso.CAS_LKP_Perito__c != null 
							&& (Trigger.isInsert || caso.CAS_LKP_Perito__c != triggerOldMap.get(caso.Id).CAS_LKP_Perito__c)){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'16');
					}
					if (Trigger.isUpdate && caso.Status == Label.CAS_ESTADO_ANULADO && triggerOldMap.get(caso.Id).Status != caso.Status) {
						compruebaEnviable(caso.Id, compania.CUE_TXT_Identificador__c, '18');
					}
					if(Trigger.isUpdate && caso.CAS_TXT_Subestado_Caso__c != null && triggerOldMap.get(caso.Id).CAS_TXT_Subestado_Caso__c == null){
						compruebaEnviable(caso.Id, compania.CUE_TXT_Identificador__c,'21');
					}
					if(Trigger.isUpdate && caso.Status == Label.CAS_ESTADO_CERRADO 
							&& triggerOldMap.get(caso.Id).Status != Label.CAS_ESTADO_CERRADO
							&& caso.Type == Label.CAS_TIPO_RECHAZO_EN_APERTURA){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'31');
					}
					if(Trigger.isUpdate && caso.CAS_CAS_Siniestro_Facturado__c == true
							&& caso.Status == Label.CAS_ESTADO_CERRADO 
							&& triggerOldMap.get(caso.Id).CAS_CAS_Siniestro_Facturado__c != caso.CAS_CAS_Siniestro_Facturado__c){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'38');
					}
					if ((caso.CAS_CAS_Informe_Preliminar_Recibido__c == true 
							&& (Trigger.isInsert || caso.CAS_CAS_Informe_Preliminar_Recibido__c !=triggerOldMap.get(caso.Id).CAS_CAS_Informe_Preliminar_Recibido__c))
							|| (caso.CAS_CAS_Informe_Definitivo_Recibido__c == true 
							&& (Trigger.isInsert || caso.CAS_CAS_Informe_Definitivo_Recibido__c !=triggerOldMap.get(caso.Id).CAS_CAS_Informe_Definitivo_Recibido__c))){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'43');
					}
					if(caso.CAS_CAS_Requiere_Perito__c == true
							&& (Trigger.isInsert || caso.CAS_CAS_Requiere_Perito__c != triggerOldMap.get(caso.Id).CAS_CAS_Requiere_Perito__c)
							&& caso.CAS_SEL_Motivo_Peticion_Perito__c == label.CAS_MOTIVO_PETICION_PERITO_SOLICITUD_CLIENTE){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'46');
					}
					if(caso.CAS_CAS_Requiere_Perito__c == true
							&& (Trigger.isInsert || caso.CAS_CAS_Requiere_Perito__c !=triggerOldMap.get(caso.Id).CAS_CAS_Requiere_Perito__c)
							&& caso.CAS_SEL_Motivo_Peticion_Perito__c == label.CAS_MOTIVO_PETICION_PERITO_SOLICITUD_CIA){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'47');
					}
					if(Trigger.isUpdate && compania.CUE_TXT_Identificador__c == Label.IDE_NATIONALE_NETHERLANDEN
							&& caso.CAS_TXT_Num_Caso_CIA__c != null 
							&& triggerOldMap.get(caso.Id).CAS_TXT_Num_Caso_CIA__c == null){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'48');
					}
					if(caso.CAS_CAS_Siniestro_Consorciable__c == true
							&& (Trigger.isInsert || caso.CAS_CAS_Siniestro_Consorciable__c != triggerOldMap.get(caso.Id).CAS_CAS_Siniestro_Consorciable__c)){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'55');
					}
					if(caso.CAS_DIV_Importe_Reserva_Perito__c != null
							&& (Trigger.isInsert || caso.CAS_DIV_Importe_Reserva_Perito__c != triggerOldMap.get(caso.Id).CAS_DIV_Importe_Reserva_Perito__c)){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'57');
					}
					/*if(Trigger.isUpdate && caso.CAS_CAS_Siniestro_Facturado__c == true
							&& triggerOldMap.get(caso.Id).CAS_CAS_Siniestro_Facturado__c != caso.CAS_CAS_Siniestro_Facturado__c){
						compruebaEnviable(caso.Id,compania.CUE_TXT_Identificador__c,'99');
					}*/
				}
			}
		}
	}

	/**
	 * Devuelve los INT_Movimiento_CIA__c filtrados por las bitácoras.
	 *
	 * @param setBitacorasIds: conjunto de bitácoras
	 *
	 * @return mapa que contiene las INT_Movimiento_CIA__c encontradas
	 */
	public static Map<Id, INT_Movimiento_CIA__c> queryMovimientosByBitacora(Set<String> setBitacorasIds) {
		Map<Id, INT_Movimiento_CIA__c> mapMovimientos=new Map<Id,INT_Movimiento_CIA__c>();
		if(!setBitacorasIds.isEmpty()) {
			for(List<INT_Movimiento_CIA__c> listMovimientos:[SELECT Id FROM INT_Movimiento_CIA__c WHERE MOV_LKP_Bitacora__c IN: setBitacorasIds]) {
				mapMovimientos.putAll(listMovimientos);
			}
		}
		return mapMovimientos;
	}

	/**
	 * Devuelve los INT_Movimiento_CIA__c filtrados por un set de Ids
	 *
	 * @param setBitacorasIds: conjunto de Ids de Movimiento_CIA
	 *
	 * @return mapa que contiene las INT_Movimiento_CIA__c encontradas
	 */
	public static Map<Id, INT_Movimiento_CIA__c> queryMovimientosById(Set<Id> setIds) {
		Map<Id, INT_Movimiento_CIA__c> mapMovimientos=new Map<Id,INT_Movimiento_CIA__c>();
		if(!setIds.isEmpty()) {
			for(List<INT_Movimiento_CIA__c> listMovimientos:[SELECT Id, MOV_LKP_Caso__c, MOV_LKP_Compania__r.CUE_TXT_Identificador__c, MOV_TXT_Codigo_Modificacion__c, MOV_TXT_Tipo_Movimiento__c  FROM INT_Movimiento_CIA__c WHERE Id IN: setIds]) {
				mapMovimientos.putAll(listMovimientos);
			}
		}
		return mapMovimientos;
	}


	/**
	 * Devuelve los INT_Movimiento_CIA__c filtrados por los casos y las acciones.
	 *
	 * @param setCaso: conjunto de IDs de Caso
	 * @param setAccion: conjunto de acciones
	 *
	 * @return mapa que contiene las INT_Movimiento_CIA__c encontradas
	 */
	public static Map<Id, INT_Movimiento_CIA__c> queryMovimientosByCasoAndAccion(Set<Id> setCaso, Set<String> setAccion) {
		Map<Id, INT_Movimiento_CIA__c> mapMovimientos=new Map<Id,INT_Movimiento_CIA__c>();
		if(setCaso != null && !setCaso.isEmpty() && setAccion != null && !setAccion.isEmpty()) {
			for(List<INT_Movimiento_CIA__c> listMovimientos:[SELECT Id FROM INT_Movimiento_CIA__c WHERE MOV_LKP_Caso__c IN :setCaso and MOV_TXT_Accion__c IN :setAccion]) {
				mapMovimientos.putAll(listMovimientos);
			}
		}
		return mapMovimientos;
	}

	/**
	 * Devuelve los INT_Movimiento_CIA__c filtrados por los casos y los estados de movimiento.
	 *
	 * @param setCaso: conjunto de IDs de Caso
	 * @param setEstadoMov: conjunto de estados de movimiento
	 *
	 * @return mapa que contiene las INT_Movimiento_CIA__c encontradas
	 */
	public static Map<Id, INT_Movimiento_CIA__c> queryMovimientosByCasoAndEstadoMov(Set<Id> setCaso, Set<String> setEstadoMov) {
		Map<Id, INT_Movimiento_CIA__c> mapMovimientos=new Map<Id,INT_Movimiento_CIA__c>();
		if(setCaso != null && setEstadoMov != null){
			if(!setCaso.isEmpty()  && !setEstadoMov.isEmpty()){
				for(List<INT_Movimiento_CIA__c> listMovimientos:[SELECT Id FROM INT_Movimiento_CIA__c WHERE MOV_LKP_Caso__c IN :setCaso and MOV_SEL_Estado_Movimiento__c IN :setEstadoMov order by MOV_DAT_Fecha_Generacion__c asc]) {
					mapMovimientos.putAll(listMovimientos);
				}   
			}
		}
		
		//esta condicion da null pointer exception
		/*if((setCaso == null || setCaso.isEmpty() ) && !setCaso.isEmpty() && setEstadoMov != null && !setEstadoMov.isEmpty()){
			for(List<INT_Movimiento_CIA__c> listMovimientos:[SELECT Id,MOV_LKP_Caso__c FROM INT_Movimiento_CIA__c WHERE MOV_LKP_Caso__c !=null and MOV_SEL_Estado_Movimiento__c IN :setEstadoMov ]) {
				mapMovimientos.putAll(listMovimientos);
			}
		}*/
		
		Boolean realizaQuery = false;
		if(setCaso == null){
			realizaQuery = true;	
		}else{
			if (setCaso.isEmpty())
				realizaQuery = true;
		}
		
		if(setEstadoMov == null){
			realizaQuery = false;
		}else{
			if (!setEstadoMov.isEmpty()) realizaQuery = true;
			else realizaQuery = false;
		}
				
		if(realizaQuery){
			for(List<INT_Movimiento_CIA__c> listMovimientos:[SELECT Id,MOV_LKP_Caso__c FROM INT_Movimiento_CIA__c WHERE MOV_LKP_Caso__c !=null and MOV_SEL_Estado_Movimiento__c IN :setEstadoMov ]) {
				mapMovimientos.putAll(listMovimientos);
			}
		}   
		return mapMovimientos;
	}

	/**
	 * Devuelve un booleano indicando si se deben generar los movimientos "En espera de apertura" (de manera que no se envíen dichos movimientos) o en estado "No enviado" (de manera que sí se envíen).
	 * Si el movimiento no es de apertura comprobamos que exista para ese caso ya generado un movimiento de apertura. En caso de que no exista, se generará en estado "En espera de apertura".
	 *
	 * @return booleano que nos indica si el movimiento se queda en espera o no
	 */
	public static Boolean movimientoEnEspera(String CIAId, Id casoId){
		Boolean enEspera = false;
		List<Comentario_caso__c> listaComentarios;
		//sacamos el texto de apertura para esa compañía
		//String textoApertura = Util_Metadatos.getIntMovCIAMetadata(new Set<String>{CIAId},new Set<String>{'1'}).values().get(0).MasterLabel;
		List<Integracion_Movimiento_CIA__mdt> listaIntegracionMov = new List<Integracion_Movimiento_CIA__mdt>([SELECT MasterLabel FROM Integracion_Movimiento_CIA__mdt 
						WHERE (Identificador_CIA__c = :CIAId AND Accion__c = '1') LIMIT 1]);
		String textoApertura;
		if(!listaIntegracionMov.isEmpty()){
			textoApertura = listaIntegracionMov[0].MasterLabel;
			//comprobamos si ya se ha generado el movimiento de apertura para este caso
			List<INT_Movimiento_CIA__c> movimientoApertura = queryMovimientosByCasoAndAccion(new Set<Id>{casoId},new Set<String>{textoApertura}).values();//[SELECT Id FROM INT_Movimiento_CIA__c WHERE MOV_LKP_Caso__c = :casoId and MOV_TXT_Accion__c = :textoApertura];
			if (movimientoApertura.isEmpty()) 
				enEspera = true;
		}
		return enEspera;
	}


	/**
	 * Método que, una vez insertado un movimiento de apertura, cambia el estado de cualquier movimiento que existiera para ese caso y que estuviera en estado "En espera de apertura"
	 * Cambia el estado a "No enviado", de forma que se envíen. También les asigna el número de intervencion HS.
	 *
	 * @return
	 */
	public static void marcaMovimientosEnEspera(String accion, Id casoId, String numeroHS){
		if(accion == '1'){
			//List<INT_Movimiento_CIA__c> movimientosEnEspera = queryMovimientosByCasoAndEstadoMov(new Set<Id>{casoId},new Set<String>{'08'}).values();
			List<INT_Movimiento_CIA__c> movimientosEnEspera = [SELECT Id, MOV_SEL_Estado_Movimiento__c,MOV_DAT_Fecha_Generacion__c, MOV_TXT_Num_Caso_HS__c FROM INT_Movimiento_CIA__c 
							WHERE MOV_LKP_Caso__c = :casoId and MOV_SEL_Estado_Movimiento__c = '08' order by MOV_DAT_Fecha_Generacion__c asc];
			if (!movimientosEnEspera.isEmpty()){
				Integer i=0;
				for (INT_Movimiento_CIA__c movimientoEsp : movimientosEnEspera){
					movimientoEsp.MOV_SEL_Estado_Movimiento__c = '01';
					movimientoEsp.MOV_TXT_Num_Caso_HS__c = numeroHS;
					i++;
					movimientoEsp.MOV_DAT_Fecha_Generacion__c = system.now().addSeconds(i);
				}
				update movimientosEnEspera;
			}   
		}
	}
	//FLLM

	/**
	 * Devuelve los Movimientos IR filtrados por Enviado.
	 *
	 * @param boolEnviado: true si está enviado, false en otro caso
	 * @param limite: límite de registros a devolver
	 *
	 * @return mapa que contiene los Movimientos IR encontrados
	 */
	public static Map<Id,Movimiento_IR__c> getMovIRByEnviado(Boolean boolEnviado, Integer limite){
		Map<Id,Movimiento_IR__c> mapa = new Map<Id,Movimiento_IR__c>();
		if(boolEnviado != null && limite != null){
			for(List<Movimiento_IR__c> lista:[SELECT MIR_TXT_NUM_SINIESTRO__c,MIR_TXT_DNI__c,MIR_TXT_TELEFONO__c,MIR_TXT_ID_PROCEDENCIA__c
												FROM Movimiento_IR__c
												WHERE MIR_CAS_ENVIADO__c = :boolEnviado LIMIT :limite]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}