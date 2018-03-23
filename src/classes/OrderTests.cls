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
}