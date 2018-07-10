/**
 * Clase de funciones auxiliares relativas a habilidades o habilidades requeridas.
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Habilidades {

	/**
	 * Devuelve las habilidades requeridas filtradas por los IDs.
	 *
	 * @param setIdHabReq: conjunto de IDs de habilidades requeridas
	 *
	 * @return mapa que contiene las habilidades requeridas encontradas
	 */
	public static Map<Id,SkillRequirement> getSkillRequirementById(Set<Id> setIdHabReq){
		Map<Id,SkillRequirement> mapa = new Map<Id,SkillRequirement>();
		if(setIdHabReq != null && !setIdHabReq.isEmpty()){
			for(List<SkillRequirement> lista:[SELECT SkillId,
													SkillLevel,
													SkillNumber,
													RelatedRecordId,
													Skill.Description,
													Skill.MasterLabel,
													Skill.DeveloperName
												FROM SkillRequirement
												WHERE Id IN :setIdHabReq]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve las habilidades requeridas filtradas por RelatedRecordId.
	 *
	 * @param setRelatedRecordId: conjunto de RelatedRecordId's
	 *
	 * @return mapa que contiene las habilidades requeridas encontradas
	 */
	public static Map<Id,SkillRequirement> getSkillRequirementByRelatedRecord(Set<Id> setRelatedRecordId){
		Map<Id,SkillRequirement> mapa = new Map<Id,SkillRequirement>();
		if(setRelatedRecordId != null && !setRelatedRecordId.isEmpty()){
			for(List<SkillRequirement> lista:[SELECT SkillId,
													SkillLevel,
													SkillNumber,
													RelatedRecordId,
													Skill.Description,
													Skill.MasterLabel,
													Skill.DeveloperName
												FROM SkillRequirement
												WHERE RelatedRecordId IN :setRelatedRecordId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve un mapa de habilidades requeridas en base a un conjunto de IDs.
	 *
	 * @param setIdHabReq: IDs de las habilidades requeridas buscadas
	 * @param setRelRecord: conjunto de RelatedRecordId's de las habilidades requeridas buscadas
	 * @return mapa de habilidades requeridas encontradas
	 */
	/*public static Map<Id,SkillRequirement> queryMapHabilidadesRequeridas(set<Id> setIdHabReq, set<Id> setRelRecord){
		Map<Id,SkillRequirement> mapa = new Map<Id,SkillRequirement>();
		if((setIdHabReq != null && !setIdHabReq.isEmpty()) || (setRelRecord != null && !setRelRecord.isEmpty())){
			String sentencia = 'SELECT Id,';
			sentencia += ' SkillId,';
			sentencia += ' SkillLevel,';
			sentencia += ' SkillNumber,';
			sentencia += ' RelatedRecordId,';
			sentencia += ' Skill.Description,';
			sentencia += ' Skill.MasterLabel,';
			sentencia += ' Skill.DeveloperName';
			sentencia += ' FROM SkillRequirement';
			String sentencia_where = ' WHERE ';
			if(setIdHabReq != null && !setIdHabReq.isEmpty()){
				sentencia_where += 'Id IN :setIdHabReq';
			}
			else if(setRelRecord != null && !setRelRecord.isEmpty()){
				sentencia_where += 'RelatedRecordId IN :setRelRecord';
			}
			sentencia += sentencia_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Habilidades.queryMapHabilidadesRequeridas.sentencia: '+sentencia);
			for(List<SkillRequirement> lista : database.query(sentencia)){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}*/

	/**
	 * Devuelve una lista de habilidades requeridas en base a su Id o a su RelatedRecordId.
	 *
	 * @param ID de la habilidad requerida
	 * @param campo RelatedRecordId de la habilidad requerida
	 * @return lista de habilidades requeridas encontradas
	 */
	/*public static List<SkillRequirement> queryHabilidadesRequeridas(Id idHabReq, Id relRecord){
		List<SkillRequirement> lista = new List<SkillRequirement>();
		if(!(idHabReq == null && relRecord == null)){
			String sentenciaOT = 'SELECT Id,';
			sentenciaOT += ' SkillId,';
			sentenciaOT += ' SkillLevel,';
			sentenciaOT += ' SkillNumber,';
			sentenciaOT += ' RelatedRecordId,';
			sentenciaOT += ' Skill.Description,';
			sentenciaOT += ' Skill.MasterLabel,';
			sentenciaOT += ' Skill.DeveloperName';
			sentenciaOT += ' FROM SkillRequirement';
			String sentenciaOT_where = ' WHERE ';
			if(idHabReq != null){
				sentenciaOT_where += 'Id = \'' + idHabReq + '\'';
			}
			else if(relRecord != null){
				sentenciaOT_where += 'RelatedRecordId = \'' + relRecord + '\'';
			}
			sentenciaOT += sentenciaOT_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Habilidades.queryHabilidadesRequeridas.sentenciaOT: ' + sentenciaOT);
			lista = database.query(sentenciaOT);
		}
		return lista;
	}*/

	/**
	 * Devuelve una lista de habilidades filtradas por un filtro.
	 *
	 * @param filtro: filtro de la sentencia where que filtra la búsqueda de habilidades
	 * @return lista de habilidades encontradas
	 */
	/*public static List<Skill> queryHabilidadesByFilter(String filtro){
		List<Skill> lista = new List<Skill>();
		if(filtro != null){
			String sentenciaOT = 'SELECT Id,';
			sentenciaOT += ' MasterLabel,';
			sentenciaOT += ' DeveloperName';
			sentenciaOT += ' FROM Skill';
			String sentenciaOT_where = ' WHERE ';
			sentenciaOT_where += '(' + filtro + ')';
			sentenciaOT += sentenciaOT_where;
			system.debug('>>>>>>>>>>>>>>>>>>Util_Habilidades.queryHabilidadesByFilter.sentenciaOT: ' + sentenciaOT);
			lista = database.query(sentenciaOT);
		}
		return lista;
	}*/
}