public with sharing class HolidaysCallouts {
    public static List<JSON2Apex.Holidays> makeGetCallout(String year) {
        JSON2Apex myClass;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://calendarific.com/api/v2/holidays?&api_key=ea5636fcdf02b64ebbf825f4bc86a56a14b66ac9&country=ZA&year='+year);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            myClass = JSON2Apex.parse(response.getBody());
            
            for(JSON2Apex.Holidays x : myClass.Response.holidays){
                system.debug(x.name);
                system.debug(x.description);
                system.debug(x.date_Z);
                system.debug(x.type);
            }
        }
        return myClass.Response.holidays;
    }

}
