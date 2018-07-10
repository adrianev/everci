global without sharing class AltaSiniestroVesta_RQ {

	global without sharing class peticionAlta{

		//Parametros de entrada para ser seteados en el caso
		webService String Id;
		webService String CAS_NUM_Id_Actuacion_SondeoExt;
		webService String CAS_SEL_Sondeo_Fase;
		webService String Status;
		webService String CAS_CAS_Apertura_Parcial;
		webService String Type;
		webService String CAS_SEL_Motivo_Rechazo;
		webService String CAS_SEL_Motivo_No_Apertura;
		webService String CAS_DAT_Fecha_Ocurrencia;
		webService String CAS_SEL_Grupo_Causas;
		webService String CAS_SEL_Tipo_Averia;
		webService String CAS_SEL_Detalle_Averia;
		webService String CAS_SEL_Causa_Averia;
		webService String CAS_CAS_Siniestro_Grave;
		webService String CAS_CAS_Siniestro_Consorciable;
		webService String CAS_CAS_Danos_Propios;
		webService String CAS_SEL_Situacion_Danos_Propios;
		webService String CAS_SEL_Otros_Danos;
		webService String CAS_CAS_Danos_Perjudicado;
		webService String CAS_CAS_Tercero_Causante;
		webService String CAS_SEL_Causante_Responsable;
		webService String CAS_TXT_Nombre;
		webService String CAS_TXT_Apellidos;
		webService String CAS_TXT_Apellidos_2;
		webService String CAS_SEL_Causante_Tipo_Documento;
		webService String CAS_TXT_Causante_N_Documento;
		webService String CAS_TXT_Causante_Direccion;
		webService String CAS_TXT_Codigo_Postal;
		webService String CAS_TFN_Telefono_1;
		webService String CAS_TFN_Telefono_2;
		webService String CAS_EMA_Email;
		webService String CAS_TXT_Causante_Poliza_R_C;
		webService String CAS_SEL_Causante_Compania;
		webService String CAS_TXT_Causante_N_exp_Stro;
		webService String CAS_SEL_Sondeo_Gremios;
		webService String CAS_TXT_Sondeo_Tipo_de_Carta;
		webService String CAS_DIV_Sondeo_Limite_Actuacion;
		webService String CAS_CAS_Sondeo_Peticion_Perito;
		webService String CAS_SEL_Motivo_Peticion_Perito;
		webService String CAS_TXT_Submotivo_Perito;
		webService String CAS_SEL_Sondeo_DocsIndemnizable;
		webService String CAS_SEL_Sondeo_DocIndemSug;
		webService String CAS_TXT_Sondeo_Grupo_Causa;
		webService String CAS_TXT_Sondeo_Causa;
		webService String CMC_TXT_Comentario;
		webService String CAS_SEL_Tipo_Llamada;
		webService String CAS_LKP_Ayuda_Indemnizable;
		webService String AYU_TXT_Identificador;

		//Listado de comentarios Comentario_caso__c
		//Cada comentario debe tener una LKP al caso CMC_LKP_Caso__c
		webService List <String> listadoComentarios;
		//webService List <String,String> listadoComentarios;
		webService String CMC_LKP_Caso;

		//Listado de garantías Garantia__c
		webService List <String> listadoGarantias;

		//Garantia_Poliza__c LKP a Garantia__c
		webService String GPOL_LKP_Garantia;

		//nodo garantia
		webService String garantia;
		webService String GAR_TXT_Codigo_Garantia;

		//Garantia_Poliza__c MasterDetail a Service Contract POL_TXT_Id_Version_Poliza
		webService String GPOL_LKP_PolizaContrato;
		webService String POL_TXT_Id_Version_Poliza;
		webService String GPOL_DIV_Franquicia;
		webService String GPOL_DIV_Capital_Asegurado;

		webService list <String> listadoPerjudicado;
		webService String PRJ_LKP_Siniestro;
		webService String PRJ_SEL_Tipo_Perjudicado;
		webService String PRJ_SEL_Situacion_Danos;
		webService String PRJ_SEL_Otros_Danos;
		webService String PRJ_TXT_Nombre;
		webService String PRJ_TXT_Direccion;
		webService String PRJ_TFN_Telefono_1;
		webService String PRJ_TFN_Telefono_Adicional;
		webService String PRJ_TFN_Movil;
		webService String PRJ_EMA_Email;

		webService String GSIN_LKP_Caso;
		webService String GSIN_LKP_Garantia;
	}
}