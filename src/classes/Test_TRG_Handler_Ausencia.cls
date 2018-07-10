@isTest
public class Test_TRG_Handler_Ausencia{

	static Testmethod void handler_Ausencia(){
		Profile p = [SELECT Id FROM profile WHERE name = 'Administrador del sistema'];
		User newUser = new User();
		newUser.FirstName = 'Juanito';
		newUser.LastName = 'tena';
		newUser.Email = 'Juanito@Juanito.com';
		newUser.Alias = 'Manolo';
		newUser.ProfileId = p.Id;
		newUser.Username = ' john784poi@acme7.com';
		newUser.CommunityNickname = 'pepe';
		newUser.TimeZoneSidKey = 'Europe/Paris';
		newUser.LocaleSidKey = system.UserInfo.getLocale();
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.LanguageLocaleKey = 'es';
		insert newUser;

		system.runAs(newUser){
			Account cuentaInit = Util_Tests.crearCuentaB2BPpal('Principal','1018','X1234567X');   
			insert cuentaInit;

			Account cuenta = Util_Tests.crearCuentaProfesionalContrato('PR125678', '1256','X19876453',null);
			cuenta.CUE_SEL_Tipo_de_Profesional__c = '01';
			cuenta.CUE_LKP_CuentaPrincipalProf__c = cuentaInit.Id;
			insert cuenta;
	
			cuenta.CUE_SEL_Estado__c = '02';
			update cuenta;
	
			User us = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
			Account cuentaProfesional2 = [SELECT id, Name, CUE_TXT_Identificador__c FROM Account WHERE id = :cuenta.Id ];
			ServiceResource sr =  Util_Tests.crearRecursoServicio('PR123457','PRMPM',cuenta.Id,us);

			Profesional_Gremio__c profGrem = new Profesional_Gremio__c();
			profGrem.PRG_LKP_Cuenta_Profesional__c = cuentaProfesional2.Id;
			profGrem.PRG_TXT_Identificador__c='j40dg49alnf194j';
			profGrem.PRG_NUM_Lim_OT_en_Curso__c=2;
			profGrem.PRG_SEL_Gremio__c = '01';
			profGrem.Name = cuentaProfesional2.CUE_TXT_Identificador__c+'_'+profGrem.PRG_SEL_Gremio__c;
			insert profGrem;

			sr.Name = cuentaProfesional2.CUE_TXT_Identificador__c+'_01_2';
			sr.RSE_SEL_Gremio__c = '01';
			insert sr;
	
			List<ResourceAbsence> ausenciaList = new List<ResourceAbsence>();
			Id ausenciaRecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_FSL_FESTIVO);
			ResourceAbsence ra = new ResourceAbsence(Type = 'Ausencia', ResourceId = sr.Id, Start = system.now().addDays(-1), End = system.now().addDays(1),Description = 'Festivo Local/Provincial', RecordTypeId = ausenciaRecordTypeId);
			ausenciaList.add(ra);
			ausenciaList.add(ra);
			OperatingHours oh = Util_Tests.crearHoraFuncionamiento('nombre','Europe/Paris');
			insert oh;
	
			ServiceTerritory st = Util_Tests.crearTerritorioServicio('nombre',oh.Id,'28001');
			insert st;
	
			Guardia__c guardia = new Guardia__c();
			guardia.GUA_LKP_Territorio__c = st.Id;
			guardia.GUA_LKP_Profesional__c = sr.Id;
			guardia.GUA_DAT_Fecha_Inicio__c = system.Today().addDays(-2);
			guardia.GUA_DAT_Fecha_Fin__c = system.Today().addDays(1);
			guardia.GUA_LKP_Territorio__c = st.Id;
			insert guardia;

			TRG_Handler_Ausencia.comprobarGuardia(ausenciaList);
		}
	}
}