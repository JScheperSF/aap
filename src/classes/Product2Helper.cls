public without sharing class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = 'group name'
        OR Name = :('TEST'+'group name')
        OR Name = :('TEST' + Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
        List<Product2> needsAnnouncement = new List<Product2>();

        Map<String, Inventory_Setting__mdt> inventorySettings = new Map<String, Inventory_Setting__mdt>();

        for (Inventory_Setting__mdt inventorySetting : [SELECT DeveloperName, Label, Language, Low_Quantity_Alert__c, MasterLabel, NamespacePrefix, QualifiedApiName FROM Inventory_Setting__mdt]) {
            inventorySettings.put(inventorySetting.Label, inventorySetting);
        }

        for (Product2 product : newList) {
            Decimal thresholdQuantity = inventorySettings.get(product.Family).Low_Quantity_Alert__c;
            if (product.Quantity_Remaining__c < thresholdQuantity) {
                needsAnnouncement.add(product);
            }
        }

        PostAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW + '. Quantity is down to ' + p.Quantity_Remaining__c;

            List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>{textSegmentInput};

            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = messageSegments;

            ConnectApi.AnnouncementInput newAnnouncement = new ConnectApi.AnnouncementInput();
            newAnnouncement.ParentID=p.Id;
            newAnnouncement.expirationDate = System.today().addDays(1);
            newAnnouncement.sendEmails = false;
            newAnnouncement.body = body;

            toPost.add(newAnnouncement);
        }

        AnnouncementQueueable q = new AnnouncementQueueable();
        q.PostAnnouncements(toPost);
    }
}