@isTest
public class tst_subscriptionEngine {
    @testSetup static void setupData() {
        utilities.generateEncryptionKey();
    }

    @isTest static void newEvent() {
        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_NEW,
            Subscription_Id__c = '123'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Contact',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_NEW,
            Subscription_Id__c = '456'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        insert new Account(
            Name = 'a'
            );
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }

    @isTest static void fieldIsValueEvent() {
        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Contact',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '123',
            Field__c = 'LastName',
            Value__c = '123'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Contact',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'LastName'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        insert new Contact(
            LastName = '123'
            );
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }

    @isTest static void fieldIsValueFromUpdateEvent() {
        Case c = new Case(
            SuppliedName = '456');

        insert c;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Case',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '123',
            Field__c = 'SuppliedName',
            Value__c = '123'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Case',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'AccountId'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        c.SuppliedName = '123';
        update c;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }

    @isTest static void fieldChangedEvent() {
        Lead l = new Lead(
            FirstName = '456',
            LastName = '789',
            Email = 'test@test.com',
            Company = 'Acme');

        insert l;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Lead',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'FirstName'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Lead',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '123',
            Field__c = 'LastName',
            Value__c = '123'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        l.FirstName = '123';
        update l;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('456', subEvent.Subscription_Id__c);
    }

    @isTest static void opportunityWonEvent() {
        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Opportunity',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_OPPORTUNITY_WON,
            Subscription_Id__c = '123'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Contact',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'FirstName'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        Opportunity opp = new Opportunity(
            Name = '123',
            CloseDate = Date.today(),
            StageName = 'Closed Won'
            );

        insert opp;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }

    @isTest static void dateReachedChangedEvent() {
        Opportunity opp = new Opportunity(
            Name = '123',
            CloseDate = Date.today(),
            StageName = 'Closed Won'
            );

        insert opp;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Opportunity',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_DATE_REACHED,
            Subscription_Id__c = '123',
            Record_Id__c = opp.Id,
            Field__c = 'CloseDate'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Opportunity',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'StageName'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        opp.CloseDate = opp.CloseDate.addDays(1);

        update opp;
        Test.stopTest();

        System.assertEquals(2, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
        System.assertEquals('delete', subEvent.Action__c);

        subEvent = subscriptionEngine.subscriptionEventsTest.get(1);
        System.assertEquals('123', subEvent.Subscription_Id__c);
        System.assertEquals('', subEvent.Action__c);
    }

    @isTest static void deleteDateReachedEvent() {
        Opportunity opp = new Opportunity(
            Name = '123',
            CloseDate = Date.today(),
            StageName = 'Closed Won'
            );

        insert opp;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Opportunity',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_DATE_REACHED,
            Subscription_Id__c = '123',
            Record_Id__c = opp.Id,
            Field__c = 'CloseDate'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Opportunity',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'StageName'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        delete opp;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
        System.assertEquals('delete', subEvent.Action__c);
    }

    @isTest static void dateOverdueChangedEvent() {
        Account a = new Account(
            Name = '123'
            );

        insert a;

        Task t = new Task(
            Subject = '123',
            WhatId = a.Id,
            ActivityDate = Date.today()
            );

        insert t;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_DATE_OVERDUE,
            Subscription_Id__c = '123',
            Record_Id__c = t.Id,
            Field__c = 'ActivityDate'
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'Subject'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Record_Id__c = a.Id,
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        t.ActivityDate = t.ActivityDate.addDays(1);

        update t;
        Test.stopTest();

        System.assertEquals(2, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
        System.assertEquals('delete', subEvent.Action__c);

        subEvent = subscriptionEngine.subscriptionEventsTest.get(1);
        System.assertEquals('123', subEvent.Subscription_Id__c);
        System.assertEquals('', subEvent.Action__c);
    }

    @isTest static void assignedToMeTask() {
        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME,
            Subscription_Id__c = '123',
            User__c = UserInfo.getUserId()
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'Subject'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        Task t = new Task(
            Subject = '123',
            ActivityDate = Date.today()
            );

        insert t;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }

    @isTest static void newCallActivityEvent() {
        Account a = new Account(
            Name = '123'
            );

        insert a;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '123',
            Field__c = 'TaskSubtype',
            Value__c = 'Call',
            User__c = UserInfo.getUserId(),
            Record_Id__c = a.Id
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'Subject'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        Task t = new Task(
            Subject = '123',
            WhatId = a.Id,
            ActivityDate = Date.today(),
            TaskSubtype = 'Call'
            );

        insert t;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }

    @isTest static void newEventActivityEvent() {
        Account a = new Account(
            Name = '123'
            );

        insert a;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Event',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_DATE_REACHED,
            Subscription_Id__c = '123',
            Field__c = 'EndDateTime',
            User__c = UserInfo.getUserId(),
            Record_Id__c = a.Id
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'Subject'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        Event e = new Event(
            Subject = '123',
            WhatId = a.Id,
            StartDateTime = Date.today(),
            EndDateTime = Date.today()
            );

        insert e;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }

    @isTest static void wrongOwnerForParentRecord() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser' + DateTime.now().getTime() + '@testorg.com');

        insert u;

        Account a = new Account(
            Name = '123',
            OwnerId = u.Id
            );

        insert a;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Event',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_DATE_REACHED,
            Subscription_Id__c = '123',
            Field__c = 'EndDateTime',
            User__c = UserInfo.getUserId(),
            Record_Id__c = a.Id
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'Subject'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        Event e = new Event(
            Subject = '123',
            WhatId = a.Id,
            StartDateTime = Date.today(),
            EndDateTime = Date.today()
            );

        insert e;
        Test.stopTest();

        System.assertEquals(null, subscriptionEngine.subscriptionEventsTest);
    }

    @isTest static void nonOwnerRecordLevelEvent() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser' + DateTime.now().getTime() + '@testorg.com');

        insert u;

        Account a = new Account(
            Name = '123',
            OwnerId = u.Id
            );

        insert a;

        Subscription__c sub = new Subscription__c(
            Object_Type__c = 'Event',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_DATE_REACHED,
            Subscription_Id__c = '123',
            Field__c = 'EndDateTime',
            Record_Id__c = a.Id
            );

        insert sub;

        Subscription__c dummy = new Subscription__c(
            Object_Type__c = 'Task',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            Subscription_Id__c = '456',
            Field__c = 'Subject'
            );

        insert dummy;

        Subscription__c dummy2 = new Subscription__c(
            Object_Type__c = 'Account',
            Subscription_Type__c = constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            Subscription_Id__c = '789',
            Field__c = 'Name',
            Value__c = '123'
            );

        insert dummy2;

        Test.startTest();
        Event e = new Event(
            Subject = '123',
            WhatId = a.Id,
            StartDateTime = Date.today(),
            EndDateTime = Date.today()
            );

        insert e;
        Test.stopTest();

        System.assertEquals(1, subscriptionEngine.subscriptionEventsTest.size());
        Subscription_Event__e subEvent = subscriptionEngine.subscriptionEventsTest.get(0);
        System.assertEquals('123', subEvent.Subscription_Id__c);
    }
}