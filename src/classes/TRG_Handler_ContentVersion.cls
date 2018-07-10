/**
  * Handler del Trigger TRG_ContentVersion. Clase implementada para poder vincular las facturas insertadas desde el Facturador
  * con el resto de Facturas hermanas en el escenario de que se facture agrupadamente por varios work orders. 
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_ContentVersion {

	/**	
	 *	Este método relaciona los objetos insertados con las facturas que compartan el mismo número de factura (FAC_TXT_Numero_factura__c).
	 *	@param desencadenador	Lista con los objetos insertados del trigger.new
	 */
	public static void obtenerFactura(List<ContentVersion> desencadenador){
		
		List<String> listaDesencadenador = new List<String> ();
		for(ContentVersion aux:desencadenador){
			listaDesencadenador.add(aux.FirstPublishLocationId);
		}
		
		List<Factura__c> esFactura = Util_Factura.queryFacturaById(new Set<Id>((List<Id>)listaDesencadenador)).values();
		//List<Factura__c> esFactura = new List<Factura__c>([SELECT FAC_TXT_Numero_factura__c FROM Factura__c WHERE Id IN :listaDesencadenador]);
		system.debug('>>>>>verFacturas: '+ esFactura);
		system.debug('>>>>>verNumFacturas: '+ esFactura.size());
		if(esFactura.size() == 1){//Si el resultado es =1, significará que se ha insertado un fichero de tipo factura unicamente, que es la casuística
								  //que nos encontraremos pues el Facturador inserta sobre ContentVersion uno a uno.	
			
			system.debug('>>>>>Se ha insertado un fichero para una factura');
			
		   List<Factura__c> facturasHermanas = Util_Factura.queryFacturaByNumeroFactura(new Set<String>{esFactura[0].FAC_TXT_Numero_factura__c}).values();
		   //List<Factura__c> facturasHermanas= new List<Factura__c>([SELECT Id FROM Factura__c WHERE FAC_TXT_Numero_factura__c = :esFactura[0].FAC_TXT_Numero_factura__c]);
			system.debug('>>>>>facturasHermanas.size() '+facturasHermanas.size());
			//Resultado >1, indica que se ha insertado un fichero que tiene varias facturas, y hay que realizar una inserción en la tabla ContentDocumentLink para el resto de hermanas
			if(facturasHermanas.size() > 1){ //indicando el ContentDocument y la entidad con que se va a relacionar quedando así las N facturas “hermanas” linkadas. Resultado esperado
													 //visualmente: que todos los registros de Factura__c tengan el mismo documento en el apartado Notas y archivos adjuntos(Note & attachment).
				
				List<ContentDocumentLink> facturasRelacionadas = new List<ContentDocumentLink>();
				ContentDocumentLink addLista = new ContentDocumentLink();
				
				for(Factura__c factura:facturasHermanas){
					
					if(desencadenador[0].FirstPublishLocationId!=factura.Id)
					{
						system.debug('>>>>>desencadenador[0]: ' + desencadenador[0]);
						system.debug('>>>>>factura.Id: '+factura.Id);
						system.debug('>>>>>desencadenador[0].ContentDocumentId: '+desencadenador[0].ContentDocumentId);
						addLista = new ContentDocumentLink(ContentDocumentId = desencadenador[0].ContentDocumentId,	LinkedEntityId = factura.Id, ShareType='V');
						facturasRelacionadas.add(addLista);
					}
					
				}
				system.debug('>>>>>facturasRelacionadas: '+facturasRelacionadas);
			   
				insert facturasRelacionadas;
			}
		}// Si es más de uno el resultado, significará que se ha ejecutado una funcionalidad distinta a la esperada
		
	}

	/**	
	 *	Esta funcion ejecuta los metodos necesarios para el tratamiento del after.
	 *	@param triggerNew	Lista con los objetos actualizados del trigger.new
	 */
	public static void tratamientoAfter(List<ContentVersion> triggerNew){
		Set<Id> setIdsCitas = new Set<Id>();
		Map<Id, ServiceAppointment> mapaCitas = new Map<Id, ServiceAppointment>();
		Set<Id> setIdsOts = new Set<Id>();
		Map<Id, WorkOrder> mapaOts = new Map<Id, WorkOrder>();
		Map<Id, WorkOrder> mapaOtsUpdate = new Map<Id, WorkOrder>();
		List<Task> listaTareasInsert = new List<Task>();

		if(trigger.isInsert){

			// Cargar conjunto de Ids de citas vinculadas al documento
			for(ContentVersion cv : triggerNew){
				if(esCitaServicio(cv.FirstPublishLocationId)){
					setIdsCitas.add(cv.FirstPublishLocationId);
				}
			}
			// Cargar mapa de citas vinculadas al documento
			if(!setIdsCitas.isEmpty()){
				mapaCitas = Util_Cita_Servicio.getMapCitasById(setIdsCitas);
				/*mapaCitas = new Map<Id, ServiceAppointment>(
					[SELECT Id,
							AppointmentNumber,
							ParentRecordId
					 FROM ServiceAppointment
					 WHERE Id IN :setIdsCitas]);*/
			}
			// Cargar conjunto de Ids de órdenes de trabajo vinculadas al documento
			for(ServiceAppointment cita : mapaCitas.values()){
				setIdsOts.add(cita.ParentRecordId);
			}
			// Cargar mapa de órdenes de trabajo vinculadas al documento
			mapaOts = Util_Orden_Trabajo.queryMapOTById(setIdsOts);
			//mapaOts = Util_Orden_Trabajo.queryOTBySet(setIdsOts, new Set<ID>(), null);

			for(ContentVersion cv : triggerNew){
				ServiceAppointment cita = mapaCitas.get(cv.FirstPublishLocationId);
				WorkOrder ot = null;
				if(cita != null){
					ot = mapaOts.get(cita.ParentRecordId);
					if(mapaOtsUpdate.get(cita.ParentRecordId) != null){
						ot = mapaOtsUpdate.get(cita.ParentRecordId);
					}

					// [AFTER-INSERT] Generación de Albarán
					if(cv.Title.startsWith(Label.PDF_TIPO_ALBARAN) && ot != null){

						// Establecer el estado de la OT en "Albaran Recibido" si el estado es "Pdte. Albaran"
						if(ot.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN){
							ContentVersion ultimoAlbaran = Util_Orden_Trabajo.getUltimoAlbaranOT(ot.Id);
							if(ultimoAlbaran != null && ultimoAlbaran.Id == cv.Id){
								ot.Status = Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO;					
								mapaOtsUpdate.put(ot.Id, ot);	
							}
						}

						// Generar Tarea tras generación de nuevo Albarán para ENDESA
						if(ot.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_ENDESA){
							listaTareasInsert.add(Util_tarea.crearTarea(Label.RT_TAR_COMUN,
								Label.TAR_ASUNTO_ALBARAN_ENDESA + ' ' + cita.AppointmentNumber, Label.TAR_ESTADO_EN_CURSO, '',
								ot.Case.OwnerId, ot.Id, ot.Case.CAS_LKP_Compania__c));
						}
					}
				}
			}
		}

		// Actualizar Órdenes de Trabajo
		if(!mapaOtsUpdate.isEmpty()){
			update mapaOtsUpdate.values();
		}

		// Insertar tareas generadas
		if(!listaTareasInsert.isEmpty()){
			insert listaTareasInsert;
		}
	}


	/**	
	 *	Devuelve si el id recibido pertenece a un registro de Cita de Servicio.
	 *	@param idObjeto	Id del objeto a comprobar
	 *	@return true si el id recibido pertenece a un registro de Cita de Servicio
	 */
	private static Boolean esCitaServicio(Id idObjeto) {
		Boolean esCita = false;
		if(idObjeto != null){
			Schema.SObjectType sobjectType = idObjeto.getSObjectType();
			String sobjectName = sobjectType.getDescribe().getName();
			esCita = (sobjectName == 'ServiceAppointment');
		}
		return esCita;
	}
}