trigger CompleteResolutionTimeMilestone on Case (before update) {

    Set<String> MILESTONES = new Set<String>{'First Response','Propose Resolution','Close Case'};

    if (UserInfo.getUserType() == 'Standard') {
        DateTime completionDate = System.now(); 
        List<Id> updateCases = new List<Id>();

        for (Case c : Trigger.new) {
            if (((c.isClosed == true)||(c.Status == 'Closed'))&&((c.SlaStartDate 
                                                                  <= completionDate)&&(c.SlaExitDate == null)))
                updateCases.add(c.Id);
        }

        if (updateCases.isEmpty() == false) {
            List<CaseMilestone> milestones = [
				SELECT
                	Id,
                	CompletionDate
                FROM
                	CaseMilestone
                WHERE
					CaseId IN :updateCases
                	AND
					MilestoneType.Name IN :MILESTONES
            ];
            
            for (CaseMilestone cm : milestones) {
                cm.CompletionDate = completionDate;
            }
            
            Database.update(milestones);
        }
        
    }
}