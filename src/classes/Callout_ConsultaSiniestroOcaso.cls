public without sharing class Callout_ConsultaSiniestroOcaso {
	@InvocableMethod(label='Update Case Ocaso' description='Actualiza el siniestro de Ocaso abierto por Email2Case')
	public static List<ID> updateCase() {
		//ToDo Callout Consulta de siniestros desde CRM a Ocaso
		List<Case> caso = new List<Case>();
		Database.SaveResult[] results = Database.update(caso);
        system.debug(results + ' resultadoooos');
		List<ID> caseId = new List<ID>();
		for (Database.SaveResult result : results) {
			if (result.isSuccess()) {
				caseId.add(result.getId());
			}
		}
		return caseId;
	}
}