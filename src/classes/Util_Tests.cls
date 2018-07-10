/**
 * Clase de funciones auxiliares para los tests
 * 
 * @author EVERIS
 * 
 */
//@isTest
public without sharing class Util_Tests {
	
	public static boolean ejecutarTRG = true;
	//metodo que se encarga de devolver una cuenta a partir de su nombre
	public static Account getAccountByName(String name){
		Account cuenta;

		/*
		PREV:
		List<Account> listaCuentas = new List<Account>([Select Id,
		                                                Name,
		                                                ShippingStreet,
		                                                ShippingPostalCode,
		                                                ShippingCity,
		                                                ShippingState,
		                                                CUE_TXT_Identificador__c,
		                                                CUE_EMA_Email__c,
		                                                RecordTypeId,
		                                                CUE_TXT_Numero_Documento__c,
		                                                CUE_TXT_PrimerApellido__c,
		                                                CUE_TXT_Nombre__c,
		                                                CUE_CAS_No_Permite_Servicio_B2C__c,
		                                                CUE_TXT_Presentacion__c,
		                                                CUE_TXT_SegundoApellido__c,
		                                                CUE_LKP_Cuenta_principal__c 
		                                                FROM Account Where Name = :name LIMIT 1]);

		*/
		//NEW
		List<Account> listaCuentas = Util_Cuentas.queryCuentasByName(new Set<String>{name}).values();
		
		if(!listaCuentas.isEmpty()){
			cuenta = listaCuentas.get(0);
		}else{
			throw new TestException('No existen cuentas con el nombre especificado');
		}

		return cuenta;
	}

	public static Linea_Contrato__c getLineaContratoByName(String name){
		Linea_Contrato__c lineaC;

		/* PREV:
			List<Linea_Contrato__c> listaLineasC = new List<Linea_Contrato__c>([Select Id,			
		                                                                    Name,
		                                                                    LDC_LKP_Contrato__c,
		                                                                    LDC_NUM_Limite_de_servicios__c,
		                                                                    LDC_SEL_Gremio__c,
		                                                                    RecordTypeId,
		                                                                    LDC_CAS_Activo__c
		                                                                    FROM Linea_Contrato__c Where Name = :name LIMIT 1]);*/
		//NEW
		List<Linea_Contrato__c> listaLineasC = Util_B2B.queryLineaContratoByName(new Set<String>{name}).values();                                        

		if(!listaLineasC.isEmpty()){
			lineaC = listaLineasC.get(0);
		}else{
			throw new TestException('No existen líneas de contrato con el Name especificado');
		}

		return lineaC;
	}

	public static Contract getContractByAccountId(Id accountId){
		Contract contract;

		/*PREV: List<Contract> contractList = new List<Contract>([Select Id,
		                                                  Status,
		                                                  AccountId,
		                                                  ContractNumber
		                                                  FROM Contract WHERE AccountId = :accountId LIMIT 1
		                                                  ]);
		                                            */
		//NEW
		List<Contract> contractList = Util_Poliza_Contrato.getContractByAccountId(new Set<Id>{accountId}).values();
		
		if(!contractList.isEmpty()){
			contract = contractList.get(0);
		}else{
			throw new TestException('No existen contrato para esa cuenta');
		}

		return contract;
	}

	public static Linea_Contrato__c getLineaContratoByContractId(Id contractId){
		Linea_Contrato__c lineaContrato;

		/* PREV: List<Linea_Contrato__c> lineaContratoList = new List<Linea_Contrato__c>([Select Id,
		                                                                         Name,
		                                                                         LDC_LKP_Contrato__c,
		                                                                         LDC_NUM_Limite_de_servicios__c,
		                                                                         LDC_SEL_Gremio__c,
		                                                                         LDC_LKP_Contrato__r.AccountId,
		                                                                         LDC_FOR_RTDevName__c,
		                                                                         LDC_LKP_Contrato__r.Status                       
		                                                                         FROM Linea_Contrato__c WHERE LDC_LKP_Contrato__c = :contractId LIMIT 1]);*/
		//NEW
		List<Linea_Contrato__c> lineaContratoList = Util_B2B.queryLineaContratoByCont(new Set<Id>{contractId}).values();
		if(!lineaContratoList.isEmpty()){
			lineaContrato = lineaContratoList.get(0);
		}else{
			throw new TestException('No existen linea de contrato para este contrato');
		}
		//lineaContrato.LDC_LKP_Contrato__r.Status = 'Activo';
		return lineaContrato;

	}

	//metodo que se encarga de devolver un caso a partir del Id de su póliza/contrato
	public static Case getCaseById(Id id){
		Case caso;

		/* PREV:
		List<Case> listaCasos = new List<Case>([Select Id,
		                                        CaseNumber,			
		                                        CAS_LKP_PolizaContrato__c,
		                                        AccountId,
		                                        CAS_TXT_Codigo_Postal__c,
		                                        CAS_TFN_Solicitud_Telefono__c,
		                                        CAS_LKP_Compania__c,
		                                        Origin,
		                                        CAS_TXT_Persona_que_llama__c,
		                                        RecordTypeId,
		                                        status,
		                                        CAS_SEL_Motivo_No_Apertura__c,
		                                        CAS_SEL_Tipo_Interlocutor__c,
		                                        CAS_LKP_Procedencia__c,
		                                        CAS_LKP_PolizaContrato__r.Name,
		                                        CAS_LKP_Perito__c,
		                                        CAS_LKP_Compania__r.CUE_SEL_GestionIndemnizable__c,
		                                        CAS_CAS_Requiere_Perito__c,
		                                        Type,
		                                        CAS_SEL_DirRiesgo_Estado_Provincia__c,
		                                        CAS_CAS_Siniestro_Grave__c,
		                                        CAS_LKP_Cliente_contable__c
		                                        FROM Case Where CAS_LKP_PolizaContrato__c = :id LIMIT 1]);*/
		//NEW                                 
		List<Case> listaCasos = Util_Caso.getCasosByPolizaId(new Set<Id>{id}).values();
		
		if(!listaCasos.isEmpty()){
			caso = listaCasos.get(0);
		}else{
			throw new TestException('No existen casos con el nombre especificado');
		}

		return caso;
	}

	//metodo que se encarga de devolver una poliza a partir de su nombre
	public static ServiceContract getServiceContractByName(String name){
		ServiceContract poliza;

		/*List<ServiceContract> listaPolizas = new List<ServiceContract>([Select Id,
		                                                                POL_LKP_Compania__r.Name,
		                                                                POL_LKP_Compania__r.CUE_EMA_Email__c,
		                                                                POL_TXT_Calle__c,
		                                                                POL_TXT_Codigo_Postal__c,
		                                                                POL_SEL_Estado_Provincia__c,
		                                                                POL_TXT_Poblacion__c,
		                                                                POL_FOR_N_de_Documento__c,
		                                                                AccountId,
		                                                                Account.Name,
		                                                                POL_CAS_Corresponde_a_HomeServe__c,
		                                                                POL_TXT_Id_Version_Poliza__c,
		                                                                POL_SEL_Tipo_Riesgo__c,
		                                                                startDate,
		                                                                POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Autorizados__c,
		                                                                Name
		                                                                FROM ServiceContract Where Name = :name LIMIT 1]);                */
		//NEW:
		List<ServiceContract> listaPolizas =   Util_Poliza_Contrato.queryPolizaByName(new Set<String>{name}).values();                                                             
		                                                                                  
		if(!listaPolizas.isEmpty()){
			poliza = listaPolizas.get(0);
		}else{
			throw new TestException('No existen polizas/contratos con el nombre especificado');
		}

		return poliza;
	}

	//metodo que se encarga de dolver un contacto telefonico a partir de su nombre
	public static Contacto_telefonico__c getContactoTlfByTfno(String id){
		Contacto_telefonico__c ttc;

		/* //PREV:
		List<Contacto_telefonico__c> listaTtc = new List<Contacto_telefonico__c>([
		                                                                          Select 	Id,
		                                                                          CTF_LKP_Poliza_Contrato__c,
		                                                                          CTF_SEL_Tipo_Relacion__c,
		                                                                          CTF_LKP_Contacto__c
		                                                                          FROM	Contacto_telefonico__c 
		                                                                          Where	CTF_TXT_Observaciones__c = :id LIMIT 1]);*/
		 //NEW                                                                         
		List<Contacto_telefonico__c> listaTtc = Util_Contacto_Telefonico.getContTelByObservaciones(new set<String> {id}).values();
		if(!listaTtc.isEmpty()){
			ttc = listaTtc.get(0);
		}else{
			throw new TestException('No existen Contactos telefonicos con el Id de teléfono especificado');
		}

		return ttc;
	}

	//metodo que se encarga de devolver un telefono transfer cia a partir de su nombre
	public static Telefonos_Transfer_CIA__c getTfnoTransferByTfno(String tfno){
		Telefonos_Transfer_CIA__c ttc;

		/* //PREV:
		List<Telefonos_Transfer_CIA__c> listaTtc = new List<Telefonos_Transfer_CIA__c>([
		                                                                                Select 	Id
		                                                                                FROM	Telefonos_Transfer_CIA__c 
		                                                                                Where	TTC_TXT_Descripcion__c like: tfno LIMIT 1]);*/
        //NEW:
        List<Telefonos_Transfer_CIA__c> listaTtc =   Util_CTI.getTelefonosTransfer_CIAByDescripcionLike( new Set<String>{tfno}).values();

		if(!listaTtc.isEmpty()){
			ttc = listaTtc.get(0);
		}else{
			throw new TestException('No existen teléfonos de transferencia de CIA con el número de teléfono especificado');
		}

		return ttc;
	}

	//metodo que se encarga de devolver un ServiceTerritory a partir de su CP
	public static ServiceTerritory getTerritorio(String cp){
		ServiceTerritory territorio;

		/* //PREV:
		List<ServiceTerritory> listaTerritorios = [
		                                           SELECT 
		                                           Id,
		                                           IsActive,
		                                           Name,
		                                           PostalCode,
		                                           TDS_TXT_Identificador__c
		                                           FROM 
		                                           ServiceTerritory
		                                           WHERE 
		                                           PostalCode = :cp 
		                                           LIMIT 1];
		                                           */
	     //NEW
		 List<ServiceTerritory> listaTerritorios = Util_TerritorioServicio.getMapaTerrActPorCP(new Set<String>{cp}).values();

		if(!listaTerritorios.isEmpty()){
			territorio = listaTerritorios.get(0);
		}else{
			throw new TestException('No existen territorios de servicio con el código postal especificado');
		}

		return territorio;
	}

	//metodo que se encarga de devolver una poblacion a partir de su nombre
	public static Poblacion__c getPoblacion(String name){
		Poblacion__c poblacion;

		 //PREV:
		List<Poblacion__c> listaPoblaciones = new List<Poblacion__c>([
		                                                              SELECT  
		                                                              Id,
		                                                              Name,
		                                                              /**POB_NUM_Codigo_Postal_Fin__c,
                                    POB_NUM_Codigo_Postal_Inicio__c,*/
		                                                              POB_SEL_Provincia__c
		                                                              FROM 
		                                                              Poblacion__c 
		                                                              WHERE 
		                                                              Name = :name
		                                                              LIMIT 1]);
		     
		//NEW:
		
		if(!listaPoblaciones.isEmpty()){
			poblacion = listaPoblaciones.get(0);
		}else{
			throw new TestException('No existen poblaciones con el nombre especificado');
		}

		return poblacion;
	}

	//metodo que se encarga de devolver un workOrder a partir de su OTR_TXT_Num_OrdenTrabajo_HS__c
	public static WorkOrder getWorkOrderByTXT(String txt){
		WorkOrder orden;

		List<WorkOrder> listaOrdenes = new List<WorkOrder>([Select Id,
		                                                    OTR_TXT_Num_OrdenTrabajo_HS__c,
		                                                    CaseId,
		                                                    OTR_SEL_Gremio__c,
		                                                    OTR_LKP_Linea_Contrato__c,
		                                                    OTR_DAT_Fecha_Primera_Cita__c,
		                                                    Status,
		                                                    AccountId
		                                                    FROM WorkOrder Where OTR_TXT_Num_OrdenTrabajo_HS__c = :txt LIMIT 1]);

		if(!listaOrdenes.isEmpty()){
			orden = listaOrdenes.get(0);
		}else{
			throw new TestException('No existen órdenes de trabajo con el nombre especificado');
		}

		return orden;
	}

	//obtiene el caso a partir del nombre de una poliza
	public static Case getCaseBySC(String name){
		Case caso;

		List<Case> listaCasos = new List<Case>([Select Id,          
		                                        CAS_LKP_PolizaContrato__c,
		                                        AccountId,
		                                        CAS_LKP_Compania__c,
		                                        CAS_LKP_Compania__r.CUE_TXT_Presentacion__c,
		                                        Origin,
		                                        CAS_TXT_Persona_que_llama__c,
		                                        RecordTypeId,
		                                        status,
		                                        CAS_SEL_Motivo_No_Apertura__c,
		                                        CAS_SEL_Tipo_Interlocutor__c,
		                                        Account.CUE_TXT_Presentacion__c,
		                                        CAS_LKP_Procedencia__c,
		                                        CAS_LKP_Orden_Trabajo_Principal__c,
		                                        CAS_SEL_Gremio_Principal__c,
		                                        CAS_LKP_Linea_de_Contrato__c
		                                        FROM Case Where CAS_LKP_PolizaContrato__r.Name = :name LIMIT 1]);

		if(!listaCasos.isEmpty()){
			caso = listaCasos.get(0);
		}else{
			throw new TestException('No existen casos con el nombre especificado');
		}

		return caso;
	}

	//metodo que se encarga de devolver un workOrder a partir de su nombre
	public static WorkType getWorkTypeByName(String name){
		Worktype tipoTrabajo;

		List<WorkType> listaTiposTrabajo = new List<WorkType>([Select Id,			
		                                                       Name,
		                                                       EstimatedDuration,
		                                                       DurationType,
		                                                       TDT_SEL_Categoria__c,
		                                                       TDT_SEL_Gremio__c,
		                                                       ShouldAutoCreateSvcAppt
		                                                       FROM WorkType Where Name = :name LIMIT 1]);

		if(!listaTiposTrabajo.isEmpty()){
			tipoTrabajo = listaTiposTrabajo.get(0);
		}else{
			throw new TestException('No existen tipos de trabajo con el nombre especificado');
		}

		return tipoTrabajo;
	}

	//metodo que se encarga de devolver un workOrder a partir de su id 
	public static WorkOrder getWorkOrderById(Id id){
		WorkOrder ordenTrabajo;

		List<WorkOrder> listaOrdenesTrabajo = new List<WorkOrder>([Select Id,			
		                                                           WorkOrderNumber,
		                                                           OTR_TXT_Num_OrdenTrabajo_HS__c,
		                                                           CaseId
		                                                           FROM WorkOrder Where Id = :id LIMIT 1]);

		if(!listaOrdenesTrabajo.isEmpty()){
			ordenTrabajo = listaOrdenesTrabajo.get(0);
		}else{
			throw new TestException('No existen ordenes de trabajo con el id de caso especificado');
		}

		return ordenTrabajo;
	}

	//metodo que se encarga de devolver un workOrder a partir del id de la poliza 
	public static WorkOrder getWorkOrderByPolizaId(Id idPoliza){
		WorkOrder workOrder;

		List<WorkOrder> listaWorkOrder = new List<WorkOrder>([Select Id,
		                                                      OTR_TXT_Num_OrdenTrabajo_HS__c,
		                                                      CaseId
		                                                      FROM WorkOrder Where CaseId = :idPoliza LIMIT 1]);

		if(!listaWorkOrder.isEmpty()){
			workOrder = listaWorkOrder.get(0);
		}else{
			throw new TestException('No existen WorkOrders con la id de poliza especificado');
		}

		return workOrder;
	}

	public static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c getDireccionB2B2CById(Id id){
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direccion;

		List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaDirecciones = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>([Select Id,			
		                                                                                                                            Name,
		                                                                                                                            DLC_LKP_Direccion_B2B_B2B2C__c,
		                                                                                                                            DLC_LKP_Linea_de_Contrato__c,
		                                                                                                                            DLC_NUM_Servicios_restantes__c,
		                                                                                                                            DLC_LKP_Linea_de_Contrato__r.LDC_LKP_Contrato__r.Status,
		                                                                                                                            DLC_LKP_Linea_de_Contrato__r.LDC_SEL_Gremio__c,
		                                                                                                                            DLC_FOR_LC_RTDevName__c,
		                                                                                                                            DLC_LKP_Linea_de_Contrato__r.LDC_CAS_Activo__c 
		                                                                                                                            FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
		                                                                                                                            WHERE DLC_LKP_Direccion_B2B_B2B2C__c = :id LIMIT 1]);

		if(!listaDirecciones.isEmpty()){
			direccion = listaDirecciones.get(0);
		}else{
			throw new TestException('No existen direcciones con la cuenta especificada');
		}

		return direccion;
	}

	public static Linea_Contrato__c getLineaContratoById(Id id){
		Linea_Contrato__c lineaC;

		List<Linea_Contrato__c> listaLineasC = new List<Linea_Contrato__c>([Select Id,			
		                                                                    Name,
		                                                                    LDC_LKP_Contrato__c,
		                                                                    LDC_NUM_Limite_de_servicios__c,
		                                                                    LDC_SEL_Gremio__c,
		                                                                    RecordTypeId
		                                                                    FROM Linea_Contrato__c Where Id = :id LIMIT 1]);

		if(!listaLineasC.isEmpty()){
			lineaC = listaLineasC.get(0);
		}else{
			throw new TestException('No existen líneas de contrato con el id especificado');
		}

		return lineaC;
	}

	public static Factura__c getFacturaByNumber(String num){
		Factura__c factura;

		List<Factura__c> listaFacturas = new List<Factura__c>([Select Id,
		                                                       FAC_TXT_Numero_factura__c
		                                                       FROM Factura__c Where FAC_TXT_Numero_factura__c = :num LIMIT 1]);

		if(!listaFacturas.isEmpty()){
			factura = listaFacturas.get(0);
		}else{
			throw new TestException('No existen facturas con el número especificado');
		}

		return factura;
	}

	/*
	 * Los siguiente métodos no se deberían de utilizar al pasarse a utilizar el framework de Tests (https://steps.everis.com/confluence/display/SFDCHC/Testing)
	 * Se dejan por ahora para mantener el soporte de las clases en que se utiliza
	 *
	 */
	public static Account crearCuentaCompania(String Name,String identificador, String cif){
		Account cuenta = new Account();
		cuenta.Name = Name;
		cuenta.CUE_TXT_Identificador__c = identificador;
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_COMPANIA);
		cuenta.CUE_SEL_Tipo_Documento__c = 'C';
		cuenta.CUE_TXT_Numero_Documento__c = cif;
		return cuenta;
	}
	
	public static Account crearCuentaAsegurado(String Name, String identificador, String email,
			String numDocumento,String nombre, String primerApellido, String segundoApellido){
		Account cuenta = new Account();
		cuenta.Name = Name;
		cuenta.CUE_TXT_Identificador__c = identificador;
		cuenta.CUE_EMA_Email__c = email;
		cuenta.CUE_TXT_Numero_Documento__c = numDocumento;
		cuenta.CUE_TXT_Nombre__c = nombre;
		cuenta.CUE_TXT_PrimerApellido__c = primerApellido;
		cuenta.CUE_TXT_SegundoApellido__c = segundoApellido;
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_ASEGURADO);
		cuenta.CUE_SEL_Tipo_Documento__c = 'N';
		return cuenta;
	}
	
	public static Account crearCuentaB2BPpal(String Name,String identificador, String cif){
		Account cuenta = new Account();
		cuenta.Name = Name;
		cuenta.CUE_TXT_Identificador__c = identificador;
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1);
		cuenta.CUE_SEL_Tipo_Documento__c = 'C';
		cuenta.CUE_TXT_Numero_Documento__c = cif;
		return cuenta;
	}
	
	public static Account crearCuentaB2BSec(String Name,String identificador, Id parentId, String cif){
		Account cuenta = new Account();
		cuenta.Name = Name;
		cuenta.CUE_TXT_Identificador__c = identificador;
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2);
		cuenta.CUE_LKP_Cuenta_principal__c = parentId;
		cuenta.CUE_SEL_Tipo_Documento__c = 'C';
		cuenta.CUE_TXT_Numero_Documento__c = cif;
		return cuenta;
	}
	
	// ESTE METODO SE DEBE BORRAR, SE DEBE USAR EN TODAS LAS CLASES EL DE ARRIBA
	public static Account crearCuentaB2BSec(String Name, String identificador, Id parentId){
		Account cuenta = new Account();
		cuenta.Name = Name;
		cuenta.CUE_TXT_Identificador__c = identificador;
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2);
		cuenta.CUE_LKP_Cuenta_principal__c = parentId;
		return cuenta;
	}
	
	public static Account crearCuentaProfesionalContrato(String Name, String identificador, String cif, Id profesionalEmpresa){
		Account cuenta = new Account();
		cuenta.Name = Name;
		cuenta.CUE_TXT_Identificador__c = identificador;
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_PROFESIONAL_CONTRATO);
		cuenta.CUE_SEL_Tipo_Documento__c = 'C';
		cuenta.CUE_TXT_Numero_Documento__c = cif;
		cuenta.CUE_LKP_CuentaPrincipalProf__c = profesionalEmpresa;
		//cuenta.CUE_LKP_Cuenta_Principal__c = null;
		return cuenta;
	}
	
	public static Account crearCuentaB2C(String Name,String identificador, String cif){
		Account cuenta = new Account();
		cuenta.Name = Name;
		cuenta.CUE_TXT_Identificador__c = identificador;
		cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2C_1);
		cuenta.CUE_SEL_Tipo_Documento__c = 'C';
		cuenta.CUE_TXT_Numero_Documento__c = cif;
		return cuenta;
	}
	
	public static VDN_Compania__c crearVDNCompania(String nombre, Id idCompania){
		VDN_Compania__c vdn = new VDN_Compania__c();
		vdn.Name = nombre;
		vdn.VDN_LKP_Compania__c = idCompania;
		vdn.VDN_TXT_Identificador__c = nombre;
		return vdn;
	}
	public static Contact crearContacto(String nombre, String apellidos, Id idCuenta, String identificador){
		Contact contacto = new Contact();
		contacto.FirstName = nombre;
		contacto.Lastname = apellidos;
		contacto.AccountId = idCuenta;
		contacto.CON_TXT_Identificador__c = identificador;
		return contacto;
	}
	
	public static Tipo_Producto_CIA__c crearTipoProductoCIA(String nombre, String tipoProducto, Id idCompania){
		Tipo_Producto_CIA__c tipoProductoCIA = new Tipo_Producto_CIA__c();
		tipoProductoCIA.Name = nombre;
		tipoProductoCIA.TPR_SEL_Tipo_Producto__c = tipoProducto;
		tipoProductoCIA.TPR_LKP_Compania__c = idCompania;
		tipoProductoCIA.TPR_TXT_Identificador__c = tipoProducto+String.valueOf(idCompania);
		return tipoProductoCIA;
	}
	
	public static Producto_CIA__c crearProductoCIA(String nombre, String codigoProducto, Id idTipoProductoCIA){
		Producto_CIA__c productoCIA = new Producto_CIA__c();
		productoCIA.Name = nombre;
		productoCIA.PRD_TXT_Cod_Producto__c = codigoProducto;
		productoCIA.PRD_LKP_Tipo_Producto_CIA__c = idTipoProductoCIA;
		return productoCIA;
	}
	
	public static Poblacion__c crearPoblacion(String nombre, String provincia){
		Poblacion__c poblacion = new Poblacion__c();
		poblacion.Name = nombre;
		poblacion.POB_SEL_Provincia__c = provincia;
		poblacion.POB_TXT_Identificador__c = provincia+'#'+nombre.toUpperCase();
		return poblacion;
	}
	
	public static OperatingHours crearHoraFuncionamiento(String nombre, String zona){
		OperatingHours horaFuncionamiento = new OperatingHours();
		horaFuncionamiento.Name = nombre;
		horaFuncionamiento.TimeZone = zona;
		return horaFuncionamiento;
	}
	
	public static ServiceTerritory crearTerritorioServicio(String nombre,Id id_HoraFuncionamiento,String codigo_postal){
		ServiceTerritory territorioServicio = new ServiceTerritory();
		territorioServicio.Name = nombre;
		territorioServicio.OperatingHoursId = id_HoraFuncionamiento;
		territorioServicio.PostalCode = codigo_postal;
		territorioServicio.TDS_TXT_Identificador__c = nombre;
		return territorioServicio;
	}
	public static ServiceTerritoryMember crearMiembroTerritorioServicio(ServiceResource s,ServiceTerritory st,String terrType,Datetime fecha){
		ServiceTerritoryMember miembroTerritorioServicio = new ServiceTerritoryMember();
		miembroTerritorioServicio.ServiceResourceId = s.Id;
		miembroTerritorioServicio.ServiceTerritoryId = st.Id;
		miembroTerritorioServicio.TerritoryType = terrType;
		miembroTerritorioServicio.EffectiveStartDate = fecha;
		return miembroTerritorioServicio;
	}
	
	public static Poblacion_CP__c crearPoblacionCP(String nombre,Id id_poblacion,Id id_territorioServicio, String codigo_postal){
		Poblacion_CP__c poblacionCP = new Poblacion_CP__c();
		poblacionCP.Name = nombre;
		poblacionCP.PCP_LKP_Poblacion__c = id_poblacion;
		poblacionCP.PCP_LKP_TerritorioServicio__c = id_territorioServicio;
		poblacionCP.PCP_TXT_Identificador__c = codigo_postal+'#'+nombre;
		return poblacionCP;
	}
	
	public static Case crearCasoSini(Id poliza, Id cuenta, Id compania){
		Case caso = new Case();
		caso.CAS_LKP_PolizaContrato__c = poliza;
		caso.AccountId = cuenta;
		caso.CAS_LKP_Compania__c = compania;
		caso.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
		return caso;
	}
	
	public static Case crearCasoB2B(Id poliza, Id cuenta, Id compania){
		Case caso = new Case();
		caso.CAS_LKP_PolizaContrato__c = poliza;
		caso.AccountId = cuenta;
		caso.CAS_LKP_Compania__c = compania;
		caso.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
		return caso;
	}
	
	public static Case crearCasoConClienteContable(Id poliza, Id cuenta, Id compania, ID clienteCon){
		Case caso = new Case();
		caso.CAS_LKP_PolizaContrato__c = poliza;
		caso.AccountId = cuenta;
		caso.CAS_LKP_Compania__c = compania;
		caso.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
		caso.CAS_LKP_Cliente_contable__c = clienteCon;
		return caso;
	}
	
	public static Case crearCasoReclamacion(Id poliza, Id cuenta, Id compania){
		Case caso = new Case();
		caso.CAS_LKP_PolizaContrato__c = poliza;
		caso.AccountId = cuenta;
		caso.CAS_LKP_Compania__c = compania;
		caso.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
		return caso;
	}
	
	public static Version_ContratoServicio__c crearVersionPoliza( Id poliza, Date fechaInicio){
		Version_ContratoServicio__c versionPoliza = new Version_ContratoServicio__c();
        versionPoliza.POLV_LKP_PolizaContrato__c = poliza;
        versionPoliza.POLV_SEL_Pais__c = 'ES';
        versionPoliza.POLV_SEL_Idioma__c = '2';
        versionPoliza.POLV_DAT_FechaFin__c = fechaInicio;
        versionPoliza.POLV_DAT_FechaInicio__c = fechaInicio.addDays(2);
        return versionPoliza;
	}

	public static ServiceContract crearPolizaContrato(String nombre, Id idCompania, Id idCuenta, Id idProductoCIA){
		ServiceContract polizaContrato = new ServiceContract();
        polizaContrato.Name = nombre;
        polizaContrato.POL_LKP_Compania__c = idCompania;
        polizaContrato.AccountId = idCuenta;
        polizaContrato.POL_LKP_Producto_Cia__c = idProductoCIA;
        return polizaContrato;
	}
	
	public static WorkType crearTipoTrabajo(String nombre, String gremio, Decimal estimated_duration){
		WorkType tipoTrabajo = new WorkType();
		tipoTrabajo.Name = nombre;
		tipoTrabajo.TDT_SEL_Gremio__c = gremio;
		tipoTrabajo.ShouldAutoCreateSvcAppt = true;
		tipoTrabajo.EstimatedDuration = estimated_duration;
		tipoTrabajo.DurationType = 'Hours';
		return tipoTrabajo;
	}
	
	public static WorkOrder crearOrdenTrabajo(String numHS, String gremio, Id idTipoTrabajo, Id idCaso){
		WorkOrder ordenTrabajo = new WorkOrder();
		ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = numHS;
		ordenTrabajo.OTR_SEL_Gremio__c = gremio;
		ordenTrabajo.WorkTypeId = idTipoTrabajo;
		ordenTrabajo.CaseId = idCaso;
		return ordenTrabajo;
	}
	
		public static WorkOrder crearOrdenTrabajoConProfesional(String numHS, String gremio, Id idTipoTrabajo, Id idCaso, Id ServiceRes){
		WorkOrder ordenTrabajo = new WorkOrder();
		ordenTrabajo.OTR_TXT_Num_OrdenTrabajo_HS__c = numHS;
		ordenTrabajo.OTR_SEL_Gremio__c = gremio;
		ordenTrabajo.WorkTypeId = idTipoTrabajo;
		ordenTrabajo.CaseId = idCaso;
		ordenTrabajo.OTR_LKP_Recurso_Servicio__c = ServiceRes;
		return ordenTrabajo;
	}
	
	public static WorkOrderLineItem crearNuevaPartidaTrabajo(Id idWorkOrder){
		WorkOrderLineItem partidaWO = new WorkOrderLineItem();
		partidaWO.WorkOrderId = idWorkOrder;
		partidaWO.PAR_DIV_Liquidar_Prof_AI__c = 100;
		partidaWO.PAR_TXT_Baremo_Desc__c = 'clase de test';
		partidaWO.PAR_NUM_Altura__c	= 100;
		partidaWO.PAR_NUM_Ancho__c	= 100;
		partidaWO.PAR_DIV_Cantidad_Venta__c = 100;
		partidaWO.PAR_DIV_Cargar_Cliente_AI__c = 100.02;
		partidaWO.PAR_NUM_Iva__c = 21.01;
		partidaWO.PAR_TXT_S_Ref__c = 'prueba test';
		partidaWO.PAR_NUM_Unidades__c = 100;
		partidaWO.PAR_DIV_UnitPrice__c = 100;
		return partidaWO;
	}
	
	public static Contract crearContrato(Id idCuenta,String nombre){
		Contract contrato = new Contract();
		contrato.AccountId = idCuenta;
		contrato.Name=nombre;
		contrato.CTR_NUM_Version_Contrato__c = 1;
		contrato.StartDate = system.now().Date();
		return contrato;
	}

	public static Buzon_CIA__c crearBuzon(String nombre,Id id_cuenta,String direccion){
		Buzon_CIA__c buzon = new Buzon_CIA__c();
		buzon.Name = nombre;
		buzon.BUZ_LKP_Cuenta__c = id_cuenta;
		buzon.BUZ_EMA_Direccion__c = direccion;
		return buzon;
	}

	public static Linea_Contrato__c crearLineaContrato(Id contratoId,Integer limiteServicios,String gremio, String nombreRecordType){
		Linea_Contrato__c lineaContrato = new Linea_Contrato__c();
		lineaContrato.LDC_LKP_Contrato__c = contratoId;
		lineaContrato.LDC_NUM_Limite_de_servicios__c=limiteServicios;
		lineaContrato.LDC_SEL_Gremio__c = gremio;
		lineaContrato.recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(nombreRecordType);
		return lineaContrato;
	}
	
	public static Procedencia__c crearProcedencia(Decimal contador_sini, Integer contador_rechazos, Integer contador_serv_b2b, Integer contador_reclamaciones, Integer contador_servicios, Id cuenta, String identificador, String tiposCaso){
		Procedencia__c procedencia = new Procedencia__c();
		procedencia.PROC_NUM_Contador__c = contador_sini;
		procedencia.PROC_NUM_Contador_Rechazos__c = contador_rechazos;
		procedencia.PROC_LKP_Cuenta__c = cuenta;
		procedencia.PROC_TXT_Identificador__c = identificador;
		procedencia.PROC_SEL_Tipos_Caso__c = tiposCaso;
		return procedencia;
	}

	public static Direcciones_B2B_B2B2C_Lineas_de_Contrato__c crearDireccionesB2B_B2B2CLineasContrato(Id cuentaId, Id lineaId, Integer serviciosRestantes){
		Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direcciones = new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c();
		direcciones.DLC_LKP_Direccion_B2B_B2B2C__c = cuentaId;
		direcciones.DLC_LKP_Linea_de_Contrato__c = lineaId;
		direcciones.DLC_NUM_Servicios_restantes__c = serviciosRestantes;
		return direcciones;
	}
	
	public static Direccion_Cuenta__c crearDireccionCuenta(String codigo_postal, Id id_cuenta){
		Direccion_Cuenta__c direccionCuenta = new Direccion_Cuenta__c();
		direccionCuenta.DCU_TXT_Codigo_Postal__c = codigo_postal;
		direccionCuenta.DCU_LKP_Cuenta__c = id_cuenta;
		return direccionCuenta;
	}
	
	public static Presupuesto__c crearPresupuesto(String estado, Id idCaso, Integer numVersion){
		Presupuesto__c presupuesto = new Presupuesto__c();
		presupuesto.PRE_SEL_Estado__c = estado;
		presupuesto.PRE_LKP_Caso__c = idCaso;
		presupuesto.PRE_NUM_Version__c = numVersion;
		return presupuesto;
	}
	
	public static Comentario_caso__c crearComentarioCaso(String comentario, Id idCaso){
		Comentario_caso__c comentarioCaso = new Comentario_caso__c();
		comentarioCaso.CMC_TXT_Comentario__c = comentario;
		comentarioCaso.CMC_LKP_Caso__c = idCaso;
		return comentarioCaso;
	}
	
	public static Comentario_Orden_de_Trabajo__c crearComentarioOT(String comentario, Id idOT){
		Comentario_Orden_de_Trabajo__c comentarioOT = new Comentario_Orden_de_Trabajo__c();
		comentarioOT.COT_TXT_Comentario__c = comentario;
		comentarioOt.COT_LKP_Orden_de_trabajo__c = idOT;
		return comentarioOT;
	}
	
	public static FSL__Scheduling_Policy__c crearPolitica(String Name){
		FSL__Scheduling_Policy__c politica = new FSL__Scheduling_Policy__c();
		politica.Name = Name;
		return politica;
	}
	
	public static ServiceAppointment crearCitaServicio(String ciudad, String pais, String codigoPostal, String estado, String calle, datetime fechaInicio,datetime fechaVencimiento){
		ServiceAppointment citaServicio = new ServiceAppointment();
		citaServicio.City = ciudad;
		citaServicio.Country = pais;
		citaServicio.PostalCode = codigoPostal;
		citaServicio.State = estado;
		citaServicio.Street = calle;
		citaServicio.DueDate = fechaVencimiento;
		citaServicio.EarliestStartTime = fechaInicio;
		return citaServicio;
	}	
	
	public static Contact crearContacto(String nombre, String apellidos){
		Contact contacto = new Contact();
		contacto.FirstName = nombre;
		contacto.LastName = apellidos;
		return contacto;
	}
	
    public static Procedencia__c crearProcedencia(Decimal contador_sini, Decimal contador_rechazos, Decimal contador_serv_b2b, Decimal contador_reclamaciones, Decimal contador_servicios, Id cuenta, String identificador, String tiposCaso){
		Procedencia__c procedencia = new Procedencia__c();
		procedencia.PROC_NUM_Contador__c = contador_sini;
		procedencia.PROC_NUM_Contador_Rechazos__c = contador_rechazos;
		procedencia.PROC_LKP_Cuenta__c = cuenta;
		procedencia.PROC_TXT_Identificador__c = identificador;
		procedencia.PROC_SEL_Tipos_Caso__c = tiposCaso;
		return procedencia;
	}
	
	public static Skill crearSkill(String nombre, String etiqueta){
		Skill habilidad = new Skill();
		habilidad.DeveloperName = nombre;
		habilidad.MasterLabel = etiqueta;
		return habilidad;
	}
	
	public static SkillRequirement crearSkillRequirement(Id ordenTrabajo, Id habilidad, Decimal  nivelHabilidad){
		SkillRequirement requisito = new SkillRequirement();
		requisito.RelatedRecordId = ordenTrabajo;
		requisito.SkillId = habilidad;
		requisito.SkillLevel = nivelHabilidad;
		return requisito;
	}
	
	public static Festivos__c crearFestivo(String tipoDia,Id Idservice,Date fecha){
	Festivos__c festivo = new Festivos__c();
	festivo.FES_SEL_Tipo_de_Festivo__c = tipoDia;
	festivo.FES_LKP_Territorio__c = Idservice;
	festivo.FES_DAT_Fecha__c = fecha;
	return festivo;
	}

	public static ServiceResource crearRecursoServicio(String nombre, String codigoRecurso, Id idCuentaProf, User userId){
		ServiceResource profesional = new ServiceResource();
		profesional.RSE_LKP_Cuenta__c = idCuentaProf;
		profesional.RSE_TXT_Codigo_Recurso__c = codigoRecurso;
		profesional.Name = nombre;
		profesional.RelatedRecordId = userId.Id;
		profesional.IsActive = true;
		return profesional;
	}
	
	public static Propuesta_de_Evento__c crearPropuestaDeEvento(String estado, Id idCaso, Id idOrdenTrabajo){
		Propuesta_de_Evento__c propuestaEvento = new Propuesta_de_Evento__c();
		propuestaEvento.EV_AB_SEL_Estado__c = estado;
		propuestaEvento.EV_AB_LKP_Caso__c = idCaso;
		propuestaEvento.EV_AB_LKP_Orden_de_Trabajo__c = idOrdenTrabajo;
		return propuestaEvento;
	}
	
	public static Tarea_Linea_Contrato__c crearTareaLineaContrato(Id idLineaContrato, Id idTareaTipoTrabajo){
		Tarea_Linea_Contrato__c TareaLineaContrato = new Tarea_Linea_Contrato__c();
		TareaLineaContrato.TLC_LKP_LineaContrato__c = idLineaContrato;
		TareaLineaContrato.TLC_LKP_Tarea_Tipo_Trabajo__c = idTareaTipoTrabajo;
		return TareaLineaContrato;
	}
	
	public static Tareas_Tipo_Trabajo__c crearTareaTipoTrabajo(String name, Id idTipoTrabajo){
		Tareas_Tipo_Trabajo__c TareaTipoTrabajo = new Tareas_Tipo_Trabajo__c();
		TareaTipoTrabajo.Name = name;
		TareaTipoTrabajo.TTT_LKP_Tipo_Trabajo__c = idTipoTrabajo;
		return TareaTipoTrabajo;
	}
	
	public static User nuevoUsuario(String apellidos, String alias, String correo, String nombreUser, String apodo, Profile perfil){
		User usuario = new User();
		usuario.Alias = alias;
		usuario.Email = correo;
		usuario.LastName = nombreUser;
		usuario.CommunityNickname = apodo;
		usuario.ProfileId = perfil.Id;
		usuario.username = correo;
		usuario.EmailEncodingKey = 'ISO-8859-1';
		usuario.LanguageLocaleKey = 'es';
		usuario.LocaleSidKey = 'es_ES';
		usuario.timeZoneSidKey = 'GMT';
		return usuario;
	}
	
	public static INT_Bitacora__c nuevaBitacora(String BIT_SEL_Estado, String BIT_TXT_Nombre_Integracion, String BIT_SEL_Tipo_Integracion){
		INT_Bitacora__c bitacora= new INT_Bitacora__c();
    	bitacora.BIT_SEL_Estado__c = BIT_SEL_Estado;
		bitacora.BIT_TXT_Nombre_Integracion__c = BIT_TXT_Nombre_Integracion;
		bitacora.BIT_SEL_Tipo_Integracion__c = BIT_SEL_Tipo_Integracion;			
		return bitacora;
	} 
	
	public static AssignedResource asignarRecurso(ServiceAppointment citaServicio,ServiceResource s){
		AssignedResource aRecurso = new AssignedResource();
		aRecurso.ServiceAppointmentId = citaServicio.Id;
		aRecurso.ServiceResourceId = s.Id;
		return aRecurso;
	}
	public static Telefonos_Transfer_CIA__c nuevoTransferCIA (String ayuda, Id compania, String descripcion) {
		Telefonos_Transfer_CIA__c transfer = new Telefonos_Transfer_CIA__c();
		transfer.TTC_TXT_Ayuda__c = ayuda;
		transfer.TTC_LKP_Cuenta__c = compania;
		transfer.TTC_TXT_Descripcion__c = descripcion;
		return transfer;
	}
	
	public static INT_Config_Fichero_CIA__c crearConfigFichero (Id compania, String query, String descripcion){
		INT_Config_Fichero_CIA__c config = new INT_Config_Fichero_CIA__c();
		config.FIC_LKP_Compania__c = compania;
		config.FIC_TXT_Query__c = query;
		config.FIC_TXT_Descripcion__c = descripcion;
		return config;
	}
	
	public static INT_Envio_Programado__c crearEnvProg (Id fichero, String hora, Date fecha, Integer lote){
		INT_Envio_Programado__c envio = new INT_Envio_Programado__c();
		envio.ENV_LKP_Fichero__c = fichero;
		envio.ENV_SEL_Hora__c = hora;
		envio.ENV_DAT_Fecha_Puntual__c = fecha;
		envio.ENV_NUM_Contador_Lote__c = lote;
		return envio;
	}
	
	public static INT_Bitacora__c crearbitacoraFichero(Id envio){
		INT_Bitacora__c bitacora = new INT_Bitacora__c();
		bitacora.BIT_LKP_Envio_Programado_CIA__c = envio;
		bitacora.BIT_SEL_Tipo_Integracion__c = '01';
		return bitacora;
	}
	
	public static Contacto_telefonico__c crearContactoTelefonico( Id idCaso, Id idContacto , boolean isContactoPoliza, boolean sms){
		Contacto_telefonico__c contactoTelefonico = new Contacto_telefonico__c();
		contactoTelefonico.CTF_CAS_SMS__c = sms ;
		contactoTelefonico.CTF_CAS_Contacto_Poliza__c = isContactoPoliza;
		contactoTelefonico.CTF_LKP_Caso__c = idCaso;
		contactoTelefonico.CTF_LKP_Contacto__c = idContacto;
		return contactoTelefonico;
	}
	
	public static Perito__c  crearPerito(Id compania, boolean noasignar, String nombre){
		Perito__c perito  =new Perito__c();
		perito.per_lkp_compania__c  = compania; 
		perito.per_cas_no_asignar__c =  noasignar;
		perito.Name =  nombre;
		return perito;
	}

	
	
	
	/*
	* Método que permite obtener un mapa con (nombreObjeto, Lista de campos obligatorios)
	* @param setNombreObjetos
	* @return Map<String,List<sObjects>> mapasObjectYCamposObligatorios
	*/
	public Map<String,List<String>> obtenerCamposObligatoriosDeObjetos (Set<String> setNombreObjetos){
		Map<String,List<String>>  mapasObjectYCamposObligatorios= new Map<String,List<String>>();
		for(String nombreSObject : setNombreObjetos){
			sObject	sobj= Schema.getGlobalDescribe().get(nombreSObject.toLowerCase()).newSObject() ;
			mapasObjectYCamposObligatorios.put(nombreSObject,obtenerCamposObligatorios(sobj));
		}
		return mapasObjectYCamposObligatorios;
	}	
	
	
	/*
	* Método que imprime los campos que es obligatorio informar a la hora de crear un objeto determinado de Salesforce 
	* @param objetoAConsultar: instancia de un objeto cuyos campos obligatorios se quieren consultar.
	* @return List<String> listaCamposObligatorios
	*/
	public List<String> obtenerCamposObligatorios (sObject objetoAConsultar){
	List<String> listaCamposObligatorios = new List<String>();
	Schema.DescribeSObjectResult r = objetoAConsultar.getSObjectType().getDescribe();
	//Obtener el nombre de API del objeto del que se van a sacar los campos requeridos 
	String nombreAPIdeObjeto = r.getName() ;
	
			Map<String,Schema.SObjectField> M = r.fields.getMap();
			//Recorremos el mapa de campos del objetivo
			system.debug('@camposObligatorios Util_Test: sObject: '+nombreAPIdeObjeto );
			for(String fieldName : M.keySet()){ 
				Schema.SObjectField field = M.get(fieldName);
				Schema.DescribeFieldResult F = field.getDescribe();
				//A nillable field can have empty content. A isNillable Boolean non-nillable field must have a value for the object to be						//created or saved. 
				// if F.isNillable() is false then field is mandatory
				if(!F.isNillable()){
					system.debug(fieldName + ' DE '+  nombreAPIdeObjeto +' - es Obligatorio');
					listaCamposObligatorios.add(fieldName);
				}
			}
			return listaCamposObligatorios;
	}
	
}