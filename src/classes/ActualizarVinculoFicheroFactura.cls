public without sharing class ActualizarVinculoFicheroFactura {

	@InvocableMethod(label='Update ActualizarVinculoFicheroFactura' description='Actualiza la tabla ContentDocumentLink')
	public static void updateContentDocument(List<Factura__c> facturaRecibida /*Id idFactura, String numeroFactura*/) {//ActualizarVinculoFicheroFactura sólo nos deja recibir una lista.
		String idFactura = facturaRecibida[0].Id;
		String numeroFactura = facturaRecibida[0].FAC_TXT_Numero_factura__c;
		//List<Factura__c> facturasHermanas= new List<Factura__c>([SELECT Id FROM Factura__c WHERE FAC_TXT_Numero_factura__c =:  numeroFactura]);
		List<Factura__c> facturasHermanas= Util_Factura.queryFacturaByNumeroFactura(new Set<String>{numeroFactura}).values();
		system.debug('>>>>>facturasHermanas: '+facturasHermanas);

		List<ContentVersion> desencadenador = new List<ContentVersion>([SELECT Id, FirstPublishLocationId, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = :idFactura ORDER BY CreatedDate LIMIT 1]);

		system.debug('>>>>>desencadenador[0]: '+desencadenador[0]);
		//Al ejecutarse el tigger después de insertar el archivo, éste ya tendrá Id, lo buscaré con el Id de la factura asociada, y como el último elemento insertado asociado a esta factura.

		system.debug('>>>>>facturasHermanas.size(): '+facturasHermanas.size());
		//Resultado >1, indica que se ha insertado un fichero que tiene varias facturas, y hay que realizar una inserción en la tabla ContentDocumentLink para el resto de hermanas

		if(facturasHermanas.size() > 1){ //indicando el ContentDocument y la entidad con que se va a relacionar quedando así las N facturas “hermanas” linkadas. Resultado esperado
			//visualmente: que todos los registros de Factura__c tengan el mismo documento en el apartado Notas y archivos adjuntos(Note & attachment).

			//Buscar el ContentDocumentId y recuperarlo de la BBDD

			List<ContentVersion> contentVersionId = [SELECT Id, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE Id =:desencadenador[0].Id];
			system.debug('>>>>>contentVersionId: '+contentVersionId);
			List<ContentDocumentLink> facturasRelacionadas = new List<ContentDocumentLink>();
			ContentDocumentLink addLista = new ContentDocumentLink();

			for(Factura__c factura:facturasHermanas){

				system.debug('>>>>>desencadenador[0].FirstPublishLocationId: '+ desencadenador[0].FirstPublishLocationId);
				system.debug('>>>>>factura.Id: '+ factura.Id);

				if(desencadenador[0].FirstPublishLocationId!=factura.Id){
					system.debug('>>>>>factura.Id: '+factura.Id);
					system.debug('>>>>>desencadenador[0].ContentDocumentId: '+desencadenador[0].ContentDocumentId);
					system.debug('>>>>>contentVersionId[0].ContentDocumentId: '+contentVersionId[0].ContentDocumentId);
					system.debug('>>>>>desencadenador[0].ContentDocumentId: '+desencadenador[0].ContentDocumentId+'   >>>>contentVersionId[0].ContentDocumentId: '+contentVersionId[0].ContentDocumentId);
					//addLista = new ContentDocumentLink(ContentDocumentId = desencadenador[0].ContentDocumentId, LinkedEntityId = factura.Id, ShareType='C', Visibility='SharedUsers');
					addLista = new ContentDocumentLink(LinkedEntityId = factura.Id, ShareType='V', ContentDocumentId = contentVersionId[0].ContentDocumentId);
					system.debug('>>>>>addLista: ' + addLista);
					facturasRelacionadas.add(addLista);
				}
			}

			system.debug('>>>>>facturasRelacionadas: '+facturasRelacionadas); 
			insert facturasRelacionadas;
			system.debug('>>>>>facturasRelacionadasInsertadas: '+facturasRelacionadas);
		}

	}

}