@isTest
private class OrderTests {

    @TestSetup
    static void SetupTestData() {
        TestDataFactory.InsertTestData(12);
    }

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

    @IsTest
    static void OrderExtension_UnitTest() {
        PageReference pageRef = Page.OrderEdit;
        Test.setCurrentPage(pageRef);
        Order o = [SELECT Id, Status FROM Order LIMIT 1];

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(o);
        OrderExtension ext = new OrderExtension(new  ApexPages.StandardController(new Order()));
        Integer totalPages = ext.GetTotalPages();
        System.Assert(totalPages > 1, 'More than one page expected, but totalPages is: ' + totalPages);

        ext.orderItemList[1].Quantity = 3;
        ext.Last();
        ext.orderItemList[1].Quantity = 2;

        ext.First();
        System.Assert(ext.orderItemList[1].Quantity == 3);
        System.Assert(ext.GetPageNumber() == 1);

        ext.Last();
        System.Assert(ext.orderItemList[1].Quantity == 2);
        System.Assert(ext.GetPageNumber() == totalPages);

        ext.OnFieldChange();
        ext.SelectFamily();
        ext.Save();
        ext.Next();
        ext.Previous();
        ext.GetHasPrevious();
        ext.GetHasNext();
        List<SelectOption> options = ext.GetFamilyOptions();

        System.Assert(true);
    }
}