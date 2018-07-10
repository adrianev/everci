global without sharing class ActualizaMovimiento_RQ {
	webservice String done{get;set;}
	webservice String tipoFichero{get;set;}
	webservice String lote{get;set;}
	webservice List<Registro> listMov{get;set;}
	global without sharing class Registro{
		webservice String error{get;set;}
		webservice String numSiniestro{get;set;}
		webservice String registro{get;set;}
	}
	
	global ActualizaMovimiento_RQ(ActualizaMovimiento_RQ recepcion){//Constructor
		done = recepcion.done;
		tipoFichero = recepcion.tipoFichero;
		lote = recepcion.lote;
		listMov = recepcion.listMov;
	}
	
	/**
	 * Constructor auxiliar empleado para @trataSiniSegurCaixa
	 */
	global ActualizaMovimiento_RQ(String done, String tipoFichero, String lote, List<Registro> listaRegistro){//Constructor
		system.debug(done+','+tipoFichero+','+lote+','+listaRegistro);
		this.done = done;
		this.tipoFichero = tipoFichero;
		this.lote = lote;
		listMov = new List<Registro>(listaRegistro);
	}
	
	/**
	 * Método para separar cada parte del fichero de siniestros de SegurCaixa
	 * 
	 * @return mapa	Mapa formado por cada parte del fichero. Como Id un nombre identificativo para cada parte del fichero y como contenido la lista de ActualizaMovimiento_RQ
	 */
	public Map<String,ActualizaMovimiento_RQ>trataSiniSegurCaixa(){
		Map<String,ActualizaMovimiento_RQ> mapa = new Map<String,ActualizaMovimiento_RQ>();
		List<Registro> listaRegistro123 = new List<Registro>();
		List<Registro> listaRegistro4 = new List<Registro>();
		List<Registro> listaRegistro5 = new List<Registro>();
		List<Registro> listaRegistro6 = new List<Registro>();
		for(Registro r:listMov){
			if(r.registro.left(1)=='1' || r.registro.left(1)=='2' || r.registro.left(1)=='3'){//Bloque del fichero 'Detalle'
				listaRegistro123.add(r);
			}else if(r.registro.left(1)=='4'){//Bloque del fichero 'Registro Presupuesto'
				listaRegistro4.add(r);
			}else if(r.registro.left(1)=='5'){//Bloque del fichero 'Registro Perjudicado'
				listaRegistro5.add(r);
			}else if(r.registro.left(1)=='6'){//Bloque del fichero 'Registro Causante'
				listaRegistro6.add(r);
			}
		}
		if(!listaRegistro123.isEmpty()){
			mapa.put('Detalle',new ActualizaMovimiento_RQ(done,tipoFichero+'Detalle',lote,listaRegistro123));
		}if(!listaRegistro4.isEmpty()){
			mapa.put('Presupuesto',new ActualizaMovimiento_RQ(done,tipoFichero+'Presupuesto',lote,listaRegistro4));
		}if(!listaRegistro5.isEmpty()){
			mapa.put('Perjudicado',new ActualizaMovimiento_RQ(done,tipoFichero+'Perjudicado',lote,listaRegistro5));
		}if(!listaRegistro6.isEmpty()){
			mapa.put('Causante',new ActualizaMovimiento_RQ(done,tipoFichero+'Causante',lote,listaRegistro6));
		}
		System.debug('@@@@@Mapa :'+mapa.keySet());
		return mapa;
	}
}