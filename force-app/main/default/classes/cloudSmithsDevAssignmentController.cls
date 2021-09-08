public with sharing class cloudSmithsDevAssignmentController {

    @AuraEnabled
    public static void saIdSearch(String saID) {
        List<SouthAfricanID__c> saIdList = new List<SouthAfricanID__c>();
        SouthAfricanID__c sfId = new SouthAfricanID__c();
        if(!String.isEmpty(saID)){
            saIdList = [SELECT Id, Citizenship__c, Gender__c, DateofBirth__c, NumberOfQueries__c, SouthAfricanIDNumber__c FROM SouthAfricanID__c WHERE SouthAfricanIDNumber__c =: Long.valueOf(saID)];
        }
        if (saIdList.isEmpty()){
            sfId.DateofBirth__c = saID.substring(4,6) +'/'+ saID.substring(2,4) + '/' +saID.substring(0,2);
            System.debug(sfId.DateofBirth__c);
            sfId.Citizenship__c = integer.valueOf(saID.substring(10, 11)) == 0 ? 'SA citizen' : 'Permanent resident';
            System.debug(sfId.Citizenship__c);
            sfId.Gender__c = integer.valueOf(saID.substring(6, 10)) < 5000 ? 'Female' : 'Male';
            System.debug(sfId.Gender__c);
            sfId.SouthAfricanIDNumber__c = Long.valueOf(saID);
            System.debug(sfId.SouthAfricanIDNumber__c);
            sfId.NumberOfQueries__c = 1;
            insert sfId;
        }else{
            saIdList[0].NumberOfQueries__c += 1;
            update saIdList;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<JSON2Apex.Holidays> getHolidays(String saID) {
        List<JSON2Apex.Holidays> holidays;
        Integer currentYear = System.Today().year();
        String year = '';

        if(Integer.valueOf(String.valueOf(currentYear).substring(2,4)) >= Integer.valueOf(saID.substring(0,2))){
            year = '20'+saID.substring(0,2);
        }else{
            year = '19'+saID.substring(0,2);
        }
        system.debug(year);
        holidays = HolidaysCallouts.makeGetCallout(year);
        
        return holidays;
    }
    // My api ea5636fcdf02b64ebbf825f4bc86a56a14b66ac9

    @AuraEnabled
    public static void saveHolidays(List<JSON2Apex.Holidays> holidays, String saID) {
        system.debug('saveHolidays!!!!!');
        List<SouthAfricanID__c> saIdList = new List<SouthAfricanID__c>();
        List<Holiday__c> holidaylist = new List<Holiday__c>();
        if(!String.isEmpty(saID)){
            saIdList = [SELECT Id, Citizenship__c, Gender__c, DateofBirth__c, NumberOfQueries__c, SouthAfricanIDNumber__c FROM SouthAfricanID__c WHERE SouthAfricanIDNumber__c =: Long.valueOf(saID)];
        }
        if (!saIdList.isEmpty()){
            if(!holidays.isEmpty()){
                for(JSON2Apex.Holidays hol : holidays){
                    Holiday__c holiday = new Holiday__c();
                    holiday.Name = hol.name;
                    holiday.Description__c = hol.description;
                    holiday.HolidayDate__c = hol.date_Z.iso;
                    holiday.HolidayType__c = hol.type[0];
                    holiday.SouthAfricanID__c = saIdList[0].Id;
                    holidaylist.add(holiday);
                }
            }
        }
        insert holidaylist;
    }

}
