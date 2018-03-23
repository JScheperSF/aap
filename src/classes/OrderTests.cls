@isTest
private class OrderTests {

//    @TestSetup
//    static void SetupTestData() {
//        TestDataFactory.InsertTestData(1);
//    }

    @IsTest
    static void OrderUpdate_UnitTest() {
        Map<Id, Product2> productsBefore = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2]);

        Test.startTest();
            List<Order> orders = [SELECT Status FROM Order];
            for (Order order : orders) {
                order.Status = Constants.ACTIVATED_ORDER_STATUS;
            }
            update orders;
        Test.stopTest();

        Map<Id, Product2> productsAfter = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2]);
        for (Product2 updatedProduct : productsAfter.values()) {
            Product2 originalProduct = productsBefore.get(updatedProduct.Id);
            TestDataFactory.VerifyQuantityOrdered(originalProduct, updatedProduct, Constants.DEFAULT_ROWS);
        }
    }

    @IsTest(SeeAllData=true)
    static void PaginationPreserveValues() {
        orderExtension ext = new orderExtension(new apexPages.standardController(new Order()));
        ext.orderItemList[0].Quantity = 1;
        ext.orderItemList[0].UnitPrice = 1;
        ext.orderItemList[1].Quantity = 2;
        ext.orderItemList[1].UnitPrice = 2;
        ext.OnFieldChange();
        ext.next();
        system.assert(ext.orderItemList[0].Quantity != 1);
        system.assert(ext.orderItemList[0].UnitPrice != 1);
        system.assert(ext.orderItemList[1].Quantity != 2);
        system.assert(ext.orderItemList[1].UnitPrice != 2);
        ext.previous();
        system.assert(ext.orderItemList[0].Quantity == 1);
        system.assert(ext.orderItemList[0].UnitPrice == 1);
        system.assert(ext.orderItemList[1].Quantity == 2);
        system.assert(ext.orderItemList[1].UnitPrice == 2);
    }

    @IsTest(SeeAllData=true)
    static void PieChartUpdate() {
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id,Name FROM Product2]);
        Map<Id,PricebookEntry> pricebookEntryMap = new Map<Id,PricebookEntry>([SELECT Id,Name FROM PricebookEntry]);

        Map<String,Decimal> chartMap = new Map<String,Decimal>();
        orderExtension ext = new orderExtension(new apexPages.standardController(new order()));
        ext.orderItemList[0].Quantity = 1;
        ext.orderItemList[0].UnitPrice = 1;
        ext.orderItemList[1].Quantity = 2;
        ext.orderItemList[1].UnitPrice = 2;
        for (OrderItem oi : ext.orderItemList ){
            String name;
            if (oi.Product2 != null && String.isNotBlank(oi.Product2.Name) ){
                name = oi.Product2.Name;
            }
            else if ( oi.PricebookEntryId != null && String.isNotBlank(oi.PricebookEntry.Name) ){
                name = oi.PricebookEntry.Name;
            }
            else if ( oi.Product2Id != null ){
                name = productMap.get(oi.Product2Id).Name;
            }
            else if ( oi.PricebookEntryId != null ){
                name = pricebookEntryMap.get(oi.PricebookEntryId).Name;
            }
            if ( String.isNotblank(name) && oi.Quantity != null && oi.UnitPrice != null ){
                Decimal x = 0;
                if ( chartMap.containsKey(oi.Product2.Name) ){
                    x = chartMap.get(oi.Product2.Name);
                }
                x += ( oi.Quantity * oi.UnitPrice );
                chartMap.put(oi.Product2.Name,x);
            }
        }
        ext.onFieldChange();

        for ( chartHelper.chartData cd : ext.pieData ){
        system.assert( cd.val == chartMap.get(cd.name), cd.name+': '+cd.val + '!='+ chartMap.get(cd.name) );
        }
    }
}