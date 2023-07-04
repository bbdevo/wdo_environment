public class wkDemo_AppointTimeChange {

    @AuraEnabled
    public static Boolean updTime(){
        Long cDate = DateTime.now().getTime();
        Long aDate,diff;
        //DateTime aEndTime,aStartTime,due,eStartTime
        Integer dayss;
        
        List<ServiceAppointment> appointments = [SELECT Id, ArrivalWindowEndTime ,ArrivalWindowStartTime ,DueDate, SchedEndTime,SchedStartTime,EarliestStartTime,Days__c 
                                                 FROM ServiceAppointment];
        for(ServiceAppointment s : appointments){
            aDate = s.ArrivalWindowEndTime.getTime();
            diff = (cDate-aDate)/1000/60/60/24;
            if(s.Days__c!=null){
                dayss = diff.intValue()+s.Days__c.intValue()-2;
            }else{
                dayss = diff.intValue()-1;
            }
            
            s.ArrivalWindowEndTime = s.ArrivalWindowEndTime.addDays(dayss); 
            s.ArrivalWindowStartTime = s.ArrivalWindowStartTime.addDays(dayss);
            s.DueDate = s.DueDate.addDays(dayss);
            s.EarliestStartTime = s.EarliestStartTime.addDays(dayss);
            if(s.SchedEndTime!=null){
                s.SchedEndTime = s.SchedEndTime.addDays(dayss);
            }
            if(s.SchedStartTime!=null){
              s.SchedStartTime = s.SchedStartTime.addDays(dayss);  
            }
            
        }
        
        try{
            update(appointments); 
            system.debug('appointment updated');
            
        }catch(DMLException e){
            system.debug(e);
        }
        
        return true;
    }
}