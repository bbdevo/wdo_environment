/**
 * Utility method that can be used in Trigger to automatically create Case Sharing rules.
 * - This is using without sharing to allow the Case Share creation to happen even if the
 *   current User should not have permission : use with caution
 */
public without sharing class FakeCaseSharingService {
    public void createSharesForCases(List<Case> casesList) {
        List<CaseShare> caseSharesToInsert = new List<CaseShare>();
        Map<Id, Employee> employeeMapByCaseId = getEmployeeByCase(casesList);

        for (Case updatedCase : casesList) {
            if (employeeMapByCaseId.containsKey(updatedCase.Id)) {
                Id userId = employeeMapByCaseId.get(updatedCase.Id).UserId;
                if (
                    userId != null &&
                    userId != String.valueOf(updatedCase.ownerId)
                ) {
                    caseSharesToInsert.add(
                        buildCaseShare(updatedCase.Id, userId)
                    );
                }
            }
        }

        insert (List<SObject>) caseSharesToInsert;
    }

    private Map<Id, Employee> getEmployeeByCase(List<Case> casesList) {
        Map<Id, Employee> employeeMapByCaseId = new Map<Id, Employee>();
        Map<Id, List<Case>> caseListByContactIdMap = new Map<Id, List<Case>>();
        
        System.debug('casesList: ' + casesList);

        for (Case updatedCase : casesList) {
            if (!caseListByContactIdMap.containsKey(updatedCase.ContactId)) {
                caseListByContactIdMap.put(
                    updatedCase.ContactId,
                    new List<Case>()
                );
            }
            caseListByContactIdMap.get(updatedCase.ContactId).add(updatedCase);
        }

        // Gather all person account records so that we have an easy way of getting
        // the personContactId from the personAccountId and vice-versa
        Map<Id, Account> personAccounts = new Map<Id, Account> ([
            SELECT Id, PersonContactId
            	FROM Account
            	WHERE PersonContactId IN :caseListByContactIdMap.keySet()
        ]);

        // Get all employees who have cases in caseList
        List<Employee> employees = [
            SELECT UserId, RelatedPersonId
            FROM Employee
            WHERE RelatedPersonId IN :personAccounts.keySet()
        ];
        
        System.debug('employees: ' + employees);
        
        for (Employee employee : employees) {
            Id relatedPersonAccountId = employee.RelatedPersonId;
            Id relatedPersonContactId = personAccounts.get(
                    relatedPersonAccountId
                )
                .PersonContactId;
            List<Case> relatedCases = caseListByContactIdMap.get(
                relatedPersonContactId
            );

            for (Case relatedCase : relatedCases) {
                employeeMapByCaseId.put(relatedCase.Id, employee);
            }
        }

        return employeeMapByCaseId;
    }

    private CaseShare buildCaseShare(Id caseId, Id userId) {
        CaseShare caseShare = new CaseShare();
        caseShare.put('CaseId', caseId);
        caseShare.put('UserOrGroupId', userId);
        caseShare.put('RowCause', Schema.CaseShare.RowCause.Manual);
        caseShare.put('CaseAccessLevel', 'edit');

        return caseShare;
    }

    public void deleteOldCaseSharing(List<Case> oldCases) {
        Map<Id, Employee> employeeMapByCaseId = getEmployeeByCase(oldCases);
        List<CaseShare> caseSharesToDelete = new List<CaseShare>();

        List<CaseShare> caseSharesForOldCases = [
            SELECT Id, CaseId, UserOrGroupId
            FROM CaseShare
            WHERE
                CaseId IN :employeeMapByCaseId.keySet()
                AND RowCause = :Schema.CaseShare.RowCause.Manual
        ];

        for (CaseShare cs : caseSharesForOldCases) {
            if (
                employeeMapByCaseId.get(cs.CaseId) != null &&
                employeeMapByCaseId.get(cs.CaseId).UserId == cs.UserOrGroupId
            ) {
                caseSharesToDelete.add(cs);
            }
        }

        delete (List<SObject>) caseSharesToDelete;
    }

    public Boolean needSharingRecalculation(Case newCase, Case oldCase) {
        if (newCase == null) {
            return false;
        }
        if (oldCase == null) {
            return true;
        }
        // Owner change should trigger sharing calculation
        if (newCase.OwnerId != oldCase.OwnerId) {
            return true;
        }

        // Case contact (person account) change should trigger calculation
        if (newCase.ContactId != oldCase.ContactId) {
            return true;
        }
        return false;
    }
}