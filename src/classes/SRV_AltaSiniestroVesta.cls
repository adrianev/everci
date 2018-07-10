/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         everis
Company:        Everis España
Description:    APEX SOAP - Alta de Siniestro VESTA

History:  APEX SOAP - Alta de Siniestro VESTA

27/11/2017                    everis                        Versión inicial
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
global without sharing class SRV_AltaSiniestroVesta {

	//Declaramos el objeto Peticion con el cual mapearemos el xml recibido del WS 

	webservice static AltaSiniestroVesta_RP createCase(AltaSiniestroVesta_RQ.peticionAlta peticionAlta){

		//Response
		AltaSiniestroVesta_RP respuesta = new AltaSiniestroVesta_RP();

		//1 recuperamos el caso para almacenar en SF el caso generado por VESTA

		Case[] caseToUpdate = [Select CAS_NUM_Id_Actuacion_SondeoExt__c, Id,/*CAS_SEL_Sondeo_Fase__c, Status, CAS_CAS_Apertura_Parcial__c,
		                       Type, CAS_SEL_Motivo_Rechazo__c, CAS_SEL_Motivo_No_Apertura__c, CAS_DAT_Fecha_Ocurrencia__c, CAS_SEL_Grupo_Causas__c, CAS_SEL_Tipo_Averia__c,
		                       CAS_SEL_Detalle_Averia__c, CAS_SEL_Causa_Averia__c, CAS_CAS_Siniestro_Grave__c, CAS_CAS_Siniestro_Consorciable__c, CAS_CAS_Danos_Propios__c,
		                       CAS_SEL_Situacion_Danos_Propios__c, CAS_SEL_Otros_Danos__c, CAS_CAS_Danos_Perjudicado__c,CAS_CAS_Tercero_Causante__c, CAS_SEL_Causante_Responsable__c,
		                       CAS_TXT_Nombre__c, CAS_TXT_Apellidos__c, CAS_TXT_Apellidos_2__c, CAS_SEL_Causante_Tipo_Documento__c,  CAS_TXT_Causante_N_Documento__c,
		                       CAS_TXT_Causante_Direccion__c, CAS_TXT_Codigo_Postal__c, CAS_TFN_Telefono_1__c,CAS_TFN_Telefono_2__c, CAS_EMA_Email__c,
		                       CAS_TXT_Causante_Poliza_R_C__c, CAS_SEL_Causante_Compania__c, CAS_TXT_Causante_N_exp_Stro__c, CAS_SEL_Sondeo_Gremios__c,
		                       CAS_TXT_Sondeo_Tipo_de_Carta__c, CAS_DIV_Sondeo_Limite_Actuacion__c, CAS_SEL_Motivo_Peticion_Perito__c,*/
		                       CAS_TXT_Submotivo_Perito__c, CAS_SEL_Sondeo_DocsIndemnizable__c, CAS_SEL_Sondeo_DocIndemSug__c
		                       //CAS_TXT_Sondeo_Grupo_Causa__c,
		                       //CAS_TXT_Sondeo_Causa__c
		                       From Case WHERE Id=:peticionAlta.Id];

		Case case1 = new Case();
		if(caseToUpdate.size()>=1){
			case1=caseToUpdate.get(0);
			respuesta.resultado = 'OK';
			case1=setValues(case1, peticionAlta);
			system.debug('BPJ: '+ case1.Id);
		}	else{
			respuesta.resultado = 'KO';
		}

		update case1;

		//2 Un caso está asociado a una garantía

		//3 Garantia_Poliza__c tiene una LKP a Garantia__c

		//4 Garantia_Poliza__c tiene una MSTDetail a Service Contract

		/*List<Garantia_Poliza__c> listGarantia = new List<Garantia_Poliza__c>(); 
		for(Garantia__c aux  : peticionAlta.listadoGarantias)
		{
			Garantia_Poliza__c gPoliza = aux.
		}*/

		//5 Recuperamos el listado de perjudicados listadoPerjudicados
		/*List<String>  listaPerjudicados = peticionAlta.get('listadoPerjudicados');

		//Instanciamos el objeto Perjudicado_Siniestro__c y creamos tantos como recuperemos de la request
		Perjudicado_Siniestro__c perjudicadoToInsert = new Perjudicado_Siniestro__c();
		for (String perjudicado : listaPerjudicados) {
			{
				Map<String, Perjudicado_Siniestro__c > perjudicado = listaPerjudicados.get(key);
				// Map<String, Perjudicado_Siniestro__c > perjudicado = (Map< String, Perjudicado_Siniestro__c >) perjudicadoMap.get(perjudicado);
				String  idSiniestro = (String) perjudicado.get(‘PRJ_LKP_Siniestro’);
				perjudicadoToInsert. PRJ_LKP_Siniestro__c= idSiniestro;
				String  tipoPerjudicado = (String) perjudicado.get(‘PRJ_SEL_Tipo_Perjudicado’);
				perjudicadoToInsert. PRJ_SEL_Tipo_Perjudicado__c= tipoPerjudicado;
				String  danyos = (String) perjudicado.get(‘PRJ_SEL_Situacion_Danos’);
				perjudicadoToInsert. PRJ_SEL_Situacion_Danos’__c= danyos;

				//ETC. con el resto de campos del perjudicado
			}

			*/
			system.debug('BPJ: '+ respuesta);
			return respuesta;
		}

		//Metodo setea los valores de la request en el caso recuperado
		static Case setValues(Case caseToUpdate,AltaSiniestroVesta_RQ.peticionAlta peticionAlta){
			//ToDo
			return caseToUpdate;
		}

	}