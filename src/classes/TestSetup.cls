/**
 * This class is the base classe for the others test classes, every test class must extend this
 * class and in their @testSetup must instantiate a new object of this class and call the method
 * {@setTestdata}
 * 
 * <p>This class will get the name of the calling test class and get the TestSetup record
 *	assigned to them and execute all the loadSteps related to this TestSetup</p>
 *
 * <p>And make asserts to assure that the number of records in the file are the same that the
 * number of records inserted</p> 
 *
 * @author Leandro Bittencourt
 * @author Antonio Acosta	
 *
 * 
 */
public virtual class TestSetup {

	/**
	 * this method get the LoadSteps related to the TestSetup of the calling class and execute 
	 * every load steps and assert that the number of lines in the file are the same that the
	 * number of records inserted
	 * @throws TestSetupException if get an error when the records from a file are being inserted
	 */
	public void setTestData() {
		//get the className of the class that called the method
		String className = String.valueOf(this).split(':')[0];

		List<Id> lstFilesIds = new List<Id>();
		List<String> lstFilesName = new List<String>();

		//Map that will store the result of the list of records after call Test.LoadData()
		Map<String, Integer> mapFileToInsertedRecords = new Map<String,Integer>();

		//Mpa that will store the number of lines in a file, each line represent a record
		Map<String, Integer> mapFileToNumOfLines = new Map<String,Integer>();

		//This for will run over the LoadSteps records and get the TestData.id and put them into a list<Id>
		for(TestLoadStep__mdt loadSteps : [SELECT MasterLabel, TestData__c, Order__c
		                                   FROM TestLoadStep__mdt 
		                                   WHERE TestSetup__c IN 
		                                   (SELECT TestSetup__c FROM TestClass__mdt WHERE MasterLabel=:className) 
		                                   ORDER BY Order__c ASC]){
			lstFilesIds.add(loadSteps.TestData__c);
		}

		Map<Id, TestData__mdt> lstFiles = new Map<Id, TestData__mdt>([SELECT ID, Masterlabel, Sobject__c FROM TestData__mdt WHERE ID=:lstFilesIds]);

		//For each TestData record try to insert using Test.LoadData() method
		Integer loaded = 0;
		for(Id filesId: lstFilesIds){
			TestData__mdt files = lstFiles.get(filesId);
			System.debug('Loading: ' + files.Sobject__c + ' from: ' + files.MasterLabel);
			lstFilesName.add(files.MasterLabel);
			system.debug('CSVs insertados: '+loaded);
			try{
				//put the number of records from the list returned from Test.LoadData() as value for the map and the key is the filename
				mapFileToInsertedRecords.put(files.MasterLabel, Test.loadData(Schema.getGlobalDescribe().get(files.Sobject__c), files.masterLabel).size());    
				loaded++;
			}
			catch(Exception e){
				throw new TestSetupException('[ERROR]: Error during ' + files.masterLabel +
						' processing\n' + e.getMessage() +'\n'+
						'Cause:' + e.getCause() +'\n'+
						'Line number:' + e.getLineNumber() +'\n'+ 
						e.getStackTraceString());
			}
		}
		//Fill the map with the number of lines for each file
		mapFileToNumOfLines = getLinesPerFile(lstFilesName);

		//for each file compare the number of lines and the number of records inserted
		for(String fileName : lstFilesName){
			system.assertEquals(mapFileToNumOfLines.get(fileName), mapFileToInsertedRecords.get(fileName), 'Fail to insert objects from: ' + fileName);
		}

	}


	/**
	 *	This method get the number of lines for each file.body in the list
	 * 	@param the list with the file bodys
	 *	@return a map of filename to the number of lines that this file have	
	 */
	private map<String,Integer> getLinesPerFile(List<String> files){
		Map<String,Integer> mapFileToLineCount = new Map<String,Integer>();
		for(StaticResource file : [Select body,name from StaticResource where Name =:files]){
			mapFileToLineCount.put(file.name,countLines(file.body.toString()));
		}
		return mapFileToLineCount;
	}
	/**
	 *	This method counts the number of lines that a string (file.body) have, split by every '\n'
	 *	@param string that represents the file's body
	 *	@return the number of lines from file, the header must be ignored
	 */
	private Integer countLines(String body){
		Integer count = 0;
		for(String line : body.split('\n')){
			count++;
		}
		// count -1 to ignore the header
		return count-1;
	}
}