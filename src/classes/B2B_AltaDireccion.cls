/**
 * Clase controladora de la Visualforce "B2B_AltaDireccion" encargada de dar de alta direcciones para una linea de contrato.
 * 
 * @author EVERIS
 */
public without sharing class B2B_AltaDireccion {
	//variables cuenta principal
	public String valorNombre {get; set;}
	public String valorVia_Domicilio {get; set;}
	public String valorCodigoPostal {get; set;}
	public List<SelectOption> listaPoblaciones {get; set;}
	public String poblacion {get; set;}
	public String valorPoblacion {get; set;}
	public List<SelectOption> listaProvincias {get; set;}
	public String valorProvincia {get; set;}
	//variables lienas de contrato
	public String valorNombre2 {get; set;}
	public String valorVia_Domicilio2 {get; set;}
	public String valorCodigoPostal2 {get; set;}
	public List<SelectOption> listaPoblaciones2 {get; set;}
	public String poblacion2 {get; set;}
	public String valorPoblacion2 {get; set;}
	public List<SelectOption> listaProvincias2 {get; set;}
	public String valorProvincia2 {get; set;}
	public Linea_Contrato__c lineaContrato {get; set;}
	public List<Account> listaDirecciones {get; set;}
	public List<wCCuenta> listaWCCuenta {get; set;}
	public List<wCCuenta> listaWCCuentaConLinea {get; set;}
	public Boolean todos {get; set;}
	public Boolean todosCuenta {get; set;}
	public List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaLineasContrato {get; set;}
	public Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dirLCFecha {get; set;}
	public Map<Id, Account> mapaCuentaConLC;
	public Id recordTypeCorrectivo{get; set;}

	/*
	 *  WRAPPER CLASS Para los check de las cuentas
	 *
	 *
	 *
	 **/
	public class wCCuenta{
		public Account cuenta {get; set;}
		public Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direcciones {get; set;}
		public Boolean selected {get; set;}

		/*  Constructor de la WrapperClass
		 *
		 *
		 **/
		public wCCuenta(Account cu, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dir){
			cuenta = cu;
			direcciones = dir;
			selected = false;
		}

	}//FIN WRAPPER CLASS


	/**
	 * Constructor de la clase.
	 * 
	 * @param objeto Linea_Contrato__c principal del controlador
	 */  
	public B2B_AltaDireccion(ApexPages.standardController stdCtr){
		todos = false;
		todosCuenta = false;
		recordTypeCorrectivo = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_LIN_CON_CORRECTIVO); 
		dirLCFecha = new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c();
		listaPoblaciones = Util_Poblacion.inicializarListaPoblaciones();
		listaProvincias = Util_Poblacion.inicializarListaProvincias();
		listaPoblaciones2 = Util_Poblacion.inicializarListaPoblaciones();
		listaProvincias2 = Util_Poblacion.inicializarListaProvincias();
		PageReference paginaActual = ApexPages.currentPage();
		// Comprobar parámetros de entrada
		if (!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}else{
			listaWCCuenta = new List<wCCuenta>();
			listaWCCuentaConLinea = new List<wCCuenta>();
			//Recojo la linea de contrato que se me pasa por URL
			List<String> fields = new List<String> {'Name',
				'LDC_LKP_Contrato__c',
				'LDC_LKP_Contrato__r.Name',
				'LDC_LKP_Contrato__r.AccountId',
				'LDC_LKP_Contrato__r.Account.Name',
				'LDC_LKP_Contrato__r.Account.CUE_TXT_Identificador__c',
				'LDC_LKP_Contrato__r.Status',
				'LDC_FOR_Cuenta_relacionada__c',
				'LDC_NUM_Horas_de_Mano_de_obra__c',
				'LDC_DIV_Importe_Material_incluido__c',
				'LDC_NUM_Limite_de_servicios__c',
				'LDC_SEL_Gremio__c',
				'LDC_NUM_Periodicidad__c',
				'LDC_NUM_Preaviso_dias__c',
				'LDC_SEL_Unidad_de_periodicidad__c', 
				'LDC_LKP_Tipo_Trabajo__c',
				'LDC_LKP_Tipo_Trabajo__r.Name',
				'LDC_FOR_Tipo__c',
				'LDC_FOR_RTDevName__c'
			};
			if (!Test.isRunningTest()) stdCtr.addFields(fields);
			lineaContrato = (Linea_Contrato__c)stdCtr.getRecord();
			cargarListaDirecciones();

			system.debug('***** lineaContrato.LDC_LKP_Contrato__r.AccountId : ' + lineaContrato.LDC_LKP_Contrato__r.AccountId);

			//Almaceno las Direcciones (cuentas) que tienen la linea de contrato asociada y que tienen la cuenta principal asociada
			listaLineasContrato = Util_Direcciones_B2B_B2B2C_Lineas.getDLCByLCAndAccount(new Set<Id>{lineaContrato.Id},new Set<Id>{lineaContrato.LDC_LKP_Contrato__r.AccountId}).values();
			//listaLineasContrato = Util_Direcciones_B2B_B2B2C_Lineas.queryDirecciones(lineaContrato);
			/*listaLineasContrato = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>(
					[  SELECT   Id, 
					   DLC_LKP_Direccion_B2B_B2B2C__c,
					   DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,
					   DLC_LKP_Linea_de_Contrato__c,
					   DLC_DAT_Activacion_primer_servicio__c,
					   DLC_FOR_Nombre_de_Cuenta__c,
					   DLC_FOR_Direccion__c
					   FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
					   WHERE   DLC_LKP_Linea_de_Contrato__c = :lineaContrato.Id
					   AND DLC_LKP_Direccion_B2B_B2B2C__r.CUE_LKP_Cuenta_principal__c = :lineaContrato.LDC_LKP_Contrato__r.AccountId]);*/
			system.debug('***** lineaContrato.Id: ' + lineaContrato.Id);
			system.debug('***** lineaContrato.LDC_LKP_Contrato__r.AccountId : ' + lineaContrato.LDC_LKP_Contrato__r.AccountId);


			cargarListaDirecConLineaContrato();      
			system.debug('***** lineaContrato : ' + lineaContrato);
			system.debug('***** listaDirecciones : ' + listaDirecciones);
			system.debug('***** listaLineasContrato : ' + listaLineasContrato);
			//system.debug('***** setIdCuentas : ' + setIdCuentas);
			system.debug('***** mapaCuentaConLC : ' + mapaCuentaConLC);
		}//FIN ID/ELSE CONSTRUCTOR
	}//FIN CONSTRUCTOR


	/**
       * Vuelve del proceso actual en la página B2B_AltaDireccion
       * 
       * @return página a navegar tras volver
       */

	public PageReference volver(){
		PageReference pagVuelta = new PageReference('/' + lineaContrato.Id);       
		pagVuelta.setRedirect(true);
		return pagVuelta;
	}

	/**
       * Carga la lista de Direcciones
       */

	public void cargarListaDirecciones(){
		//Almaceno todas las Cuentas que tengan como CUE_LKP_Cuenta_Principal la cuenta Principal
		String query = 'SELECT Id,CUE_TXT_Identificador__c,Name,ShippingStreet,ShippingPostalCode,ShippingCity,ShippingState FROM Account';
		query += ' WHERE CUE_LKP_Cuenta_principal__c = \''+lineaContrato.LDC_LKP_Contrato__r.AccountId +'\' AND CUE_CAS_Dada_de_Baja__c != true';
		query += ' AND TYPE != \'' + Label.CUE_TIPO_CONTABLE + '\' AND TYPE != \'' + Label.CUE_TIPO_OK_PYMES + '\''; 
		//Nombre
		System.debug('<<<<<<<<<<<<<<<valorNombre ' + valorNombre);
		if(valorNombre != null && valorNombre.trim() != ''){
			query += ' AND Name LIKE \'%' + valorNombre.trim() + '%\'';
		}
		String queryDir = '';
		//Domicilio
		if(valorVia_Domicilio != null && valorVia_Domicilio.trim() != ''){
			queryDir += ' AND ShippingStreet LIKE \'%' + valorVia_Domicilio.trim() + '%\'';
		}
		//C.P.
		if(valorCodigoPostal != null && valorCodigoPostal.trim() != ''){
			queryDir += ' AND ShippingPostalCode = \'' + valorCodigoPostal.trim() + '\'';
		}
		//Poblacion
		if(poblacion != null && poblacion.trim() != ''){
			queryDir += ' AND ShippingCity = \'' + valorPoblacion + '\'';
		}
		//Provincia
		if(valorProvincia != null && valorProvincia.trim() != ''){
			query += ' AND ShippingState = \'' + Util_Listas_Seleccion.getLabelDesdeAPI('Poblacion__c','POB_SEL_Provincia__c').get(valorProvincia.trim()) + '\'';
		}
		if (queryDir != ''){
			query += queryDir;
		}   

		system.debug('>>>>busqueda.query: ' + query);
		listaDirecciones = Database.query(query);
		//Recorro la lista para crear la lista con la wrapperclass
		listaWCCuenta = new List<wCCuenta>();
		for(Account cue : listaDirecciones){
			listaWCCuenta.add(new wCCuenta(cue, null));
		}

		system.debug('>>>>listaWCCuenta ' + listaWCCuenta);
	}

	/**
       * Carga la lista de Direcciones con Contrato
    */

	private void cargarListaDirecConLineaContrato(){
		Set<Id> setIdCuentas = new Set<Id>();
		//Recorro la lista y me guardo en un set las ID's de las cuentas que están en la lista
		for(Direcciones_B2B_B2B2C_Lineas_de_Contrato__c direc : listaLineasContrato){
			setIdCuentas.add(direc.DLC_LKP_Direccion_B2B_B2B2C__c);
		}

		//Lista de las cuentas (direcciones) que tienen la línea de contrato seleccionada
		mapaCuentaConLC = Util_Cuentas.getMapCuentasById(setIdCuentas);

		//Recorro la lista para crear la lista con la wrapperclass
		listaWCCuentaConLinea = new List<wCCuenta>();
		for(Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dir : listaLineasContrato){
			listaWCCuentaConLinea.add(new wCCuenta(mapaCuentaConLC.get(dir.DLC_LKP_Direccion_B2B_B2B2C__c), dir));
		}  
		for(wCCuenta wc : listaWCCuenta){
			wc.selected = false;
		}
	}

	/**
       * Filtra por lineas de contrato
       */   

	public void filtrarLineasContrato(){
		filtrar();
		cargarListaDirecConLineaContrato();

	}

	/**
       * Filtro a aplicar en la página de B2B_AltaDireccion
       */

	private void filtrar(){
		String query = 'SELECT Id,DLC_LKP_Direccion_B2B_B2B2C__c,DLC_LKP_Direccion_B2B_B2B2C__r.CUE_TXT_Identificador__c,DLC_LKP_Linea_de_Contrato__c,DLC_DAT_Activacion_primer_servicio__c,DLC_FOR_Nombre_de_Cuenta__c,DLC_FOR_Direccion__c FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c WHERE DLC_LKP_Linea_de_Contrato__c= \''+ lineaContrato.Id +'\'';  
		query += 'AND DLC_LKP_Direccion_B2B_B2B2C__r.CUE_LKP_Cuenta_principal__c =\''+ lineaContrato.LDC_LKP_Contrato__r.AccountId +'\'';
		//Nombre
		if(valorNombre2 != null && valorNombre2.trim() != ''){
			query += ' AND DLC_LKP_Direccion_B2B_B2B2C__r.Name LIKE \'%' + valorNombre2.trim() + '%\'';
		}
		String queryDir = '';
		//Domicilio
		if(valorVia_Domicilio2 != null && valorVia_Domicilio2.trim() != ''){
			queryDir += ' AND DLC_LKP_Direccion_B2B_B2B2C__r.ShippingStreet LIKE \'%' + valorVia_Domicilio2.trim() + '%\'';
		}
		//C.P.
		if(valorCodigoPostal2 != null && valorCodigoPostal2.trim() != ''){
			queryDir += ' AND DLC_LKP_Direccion_B2B_B2B2C__r.ShippingPostalCode = \'' + valorCodigoPostal2.trim() + '\'';
		}
		//Poblacion
		if(poblacion2 != null && poblacion2.trim() != ''){
			queryDir += ' AND DLC_LKP_Direccion_B2B_B2B2C__r.ShippingCity = \'' + valorPoblacion2 + '\'';
		}
		//Provincia
		if(valorProvincia2 != null && valorProvincia2.trim() != ''){
			query += ' AND DLC_LKP_Direccion_B2B_B2B2C__r.ShippingState = \'' + Util_Listas_Seleccion.getLabelDesdeAPI('Poblacion__c','POB_SEL_Provincia__c').get(valorProvincia2.trim()) + '\'';
		}
		if (queryDir != ''){
			query += queryDir;
		}
		system.debug('>>>>busqueda.query: ' + query);

		listaLineasContrato = Database.query(query);
	}

	/**
       * Añade una dirección al objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
       */   

	public void anadirDireccion(){
		if(dirLCFecha.DLC_DAT_Activacion_primer_servicio__c == null 
				&& lineaContrato.LDC_FOR_RTDevName__c == Label.RT_LIN_CON_PREVENTIVO){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
		}else{
			if(lineaContrato.LDC_LKP_Contrato__r.Status != Label.CONTRATO_ESTADO_ACTIVO){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_CONTRATO_NO_ACTIVO));
			}else{
				List<Tarea_Linea_Contrato__c> listaTareasLC = Util_B2B.queryMapTareaLineaContrato(new Set<Id>{lineaContrato.Id}).values();
				//List<Tarea_Linea_Contrato__c> listaTareasLC = Util_B2B.queryTareaLineaContrato(new Set<Id>{lineaContrato.Id});
				/*List<Tarea_Linea_Contrato__c> listaTareasLC = new List<Tarea_Linea_Contrato__c>(
						[SELECT Id
						 FROM Tarea_Linea_Contrato__c
						 WHERE TLC_LKP_LineaContrato__c = :lineaContrato.Id]);*/
				if(listaTareasLC.isEmpty() && lineaContrato.LDC_FOR_RTDevName__c == Label.RT_LIN_CON_PREVENTIVO){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_LC_SIN_TAREAS));
				}else{
					todos = false;
					List <Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaAgregarDirec = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
					Map<Id, wCCuenta> mapaCuentasConLinea = new Map<Id, wCCuenta>();
					//Recorro la lista de los que ya estan en la linea del contrato para que no se inserten duplicados
					for(wCCuenta wCC : listaWCCuentaConLinea){
						mapaCuentasConLinea.put(wCC.direcciones.DLC_LKP_Direccion_B2B_B2B2C__c, wCC);
					}
					system.debug('***** mapaCuentasConLinea: ' + mapaCuentasConLinea);
					system.debug('***** listaWCCuenta: ' + listaWCCuenta);
					//Recorro la lista con los seleccionados
					for(wCCuenta wC : listaWCCuenta){
						//Si está seleccionada, creo un nuevo objeto intermedio y lo relaciono, y lo meto en una lista
						if(wC.selected && mapaCuentasConLinea.get(wC.cuenta.Id) == null){
							listaAgregarDirec.add(Util_B2B.vincularB2BSecLineaCtr(wC.cuenta, lineaContrato, dirLCFecha.DLC_DAT_Activacion_primer_servicio__c));
							system.debug('***** DENTRO DE SELECCIONADO');
						}else if(mapaCuentasConLinea.get(wC.direcciones.DLC_LKP_Direccion_B2B_B2B2C__c) == null){
							//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Algunos de las direcciones ya estaban agregadas.'));
							system.debug('***** DENTRO DE YA ESTABA AGREGADO');
						}
					}
					system.debug('***** listaAgregarDirec: ' + listaAgregarDirec);
					//Si la lista no está vacía
					if(!listaAgregarDirec.isEmpty()){
						System.Savepoint puntoGuardado = Database.setSavepoint();
						try{
							insert listaAgregarDirec;
							listaLineasContrato.addAll(listaAgregarDirec);
							cargarListaDirecConLineaContrato();
							//cargarListaDirecciones();
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
						}
						catch(Exception e){
							Database.rollback(puntoGuardado);
							system.debug(e.getStackTraceString());
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
						}
					}
				}
			}
		}//FIN IF/ELSE SI LA FECHA NO ESTÁ INFORMADA

	}

	/**
	 * Método asociado al botón "Eliminar" del listado de direcciones (cuentas).
	 */
	public void seleccionarTodos(){
		for (wCCuenta wc : listaWCCuentaConLinea){
			wc.selected = todosCuenta;
			system.debug('**** wc.selected'+wc.selected);
		}
	}

	/**
	 * Método asociado al botón "Eliminar" del listado de direcciones.
	 */
	public void seleccionarTodosC(){
		for(wCCuenta wc: listaWCCuenta){
			wc.selected = todos;
		}
	}
	/**
       * Elimina una dirección del objeto Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
       */
	public void eliminarDireccion(){
		List <Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> listaElimDirec = new List<Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		Set<Id> setIdElim = new Set<Id>();
		for(wCCuenta wC : listaWCCuentaConLinea){
			//Si está seleccionada, creo un nuevo objeto intermedio y lo relaciono, y lo meto en una lista
			if(wC.selected){
				//listaElimDirec.add(dirLC);
				setIdElim.add(wC.direcciones.DLC_LKP_Direccion_B2B_B2B2C__c);
				system.debug('***** DENTRO DE SELECCIONADO');
			}

		}
		if(!setIdElim.isEmpty()){
			listaElimDirec = Util_Direcciones_B2B_B2B2C_Lineas.getDLCByDirB2BB2B2CAndLC(setIdElim,new Set<Id>{lineaContrato.Id}).values();
			//listaElimDirec = Util_Direcciones_B2B_B2B2C_Lineas.queryDirecciones(setIdElim,lineaContrato.Id);
			/*listaElimDirec = [  SELECT Id
			                    FROM Direcciones_B2B_B2B2C_Lineas_de_Contrato__c
			                    WHERE DLC_LKP_Direccion_B2B_B2B2C__c IN :setIdElim AND DLC_LKP_Linea_de_Contrato__c = : lineaContrato.Id];*/
		}
		system.debug('***** listaElimDirec');
		if (todosCuenta){
			listaLineasContrato.clear();
			todosCuenta = false;
			cargarListaDirecConLineaContrato();
		}
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			delete listaElimDirec;
			Integer num = 0;
			Map<Id,Integer> mapaDel = new Map<Id,Integer>(); 
			for(Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dir : listaLineasContrato){
				mapaDel.put(dir.DLC_LKP_Direccion_B2B_B2B2C__c, num);
				num++;
			}
			for(wCCuenta wc : listaWCCuentaConLinea){
				if(wc.selected){
					listaLineasContrato.remove(mapaDel.get(wc.direcciones.DLC_LKP_Direccion_B2B_B2B2C__c));
				}

			}
			cargarListaDirecConLineaContrato();
			//cargarListaDirecciones();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
		}
		//}

	}//FIN eliminarContacto 

	/**
	 * Carga la lista de poblaciones a elegir según el código postal seleccionado
	 */

	public void cargarListaPoblacionPorCP(){
		listaPoblaciones = Util_TerritorioServicio.cargarListaPoblacionPorCP(valorCodigoPostal);
		poblacion = listaPoblaciones.get(0).getValue(); //CódigoProvincia#NombrePoblación
		valorProvincia = null;
		valorPoblacion = null;
		if (listaPoblaciones.size() > 1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
		}else if (listaPoblaciones.get(0).getValue() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
		}else{
			cargarProvinciaPoblacion();
		}
	}

	/**
	 * Carga la Provincia según la población elegida
	 */

	public void cargarProvinciaPoblacion(){
		valorPoblacion = Util_TerritorioServicio.obtenerPoblacionSel(poblacion);
		valorProvincia = Util_TerritorioServicio.obtenerProvinciaSel(poblacion);
	}

	/**
	 * Carga la lista de poblaciones a elegir según el código postal 2
	 */  

	public void cargarListaPoblacionPorCP2(){
		listaPoblaciones2 = Util_TerritorioServicio.cargarListaPoblacionPorCP(valorCodigoPostal2);
		poblacion2 = listaPoblaciones2.get(0).getValue(); //CódigoProvincia#NombrePoblación
		valorProvincia2 = null;
		valorPoblacion2 = null;
		if (listaPoblaciones2.size() > 1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
		}else if (listaPoblaciones2.get(0).getValue() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
		}else{
			cargarProvinciaPoblacion2();
		}
	}

	/**
	 * Carga la Provincia según la población 2 elegida
	 */

	public void cargarProvinciaPoblacion2(){
		valorPoblacion2 = Util_TerritorioServicio.obtenerPoblacionSel(poblacion2);
		valorProvincia2 = Util_TerritorioServicio.obtenerProvinciaSel(poblacion2);
	}
}