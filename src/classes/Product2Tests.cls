@isTest
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @IsTest
    static void GetStandardPricebookId() {
        System.Assert(false, 'Test.getStandardPricebookId(): ' + Test.getStandardPricebookId());
    }

    @IsTest
    static void Product2Extension_UnitTest(){
        // Simulate a user's visit
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);

        // When the page is opened, I expect only Constants.DEFAULT_ROWS items
        Product2 someProduct = new Product2(Name='Test', IsActive=true);
        Product2Extension ext = new Product2Extension(new ApexPages.StandardController(someProduct));
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());

        // When the add button is pressed, I expect that Constants.DEFAULT_ROWS are added to the page
        ext.addRows();
        System.assertEquals(2 * Constants.DEFAULT_ROWS, ext.productsToInsert.size());

        // When the save button is pressed, ?? only the records with all fields filled should be saved ??
        Integer countProductBefore  = [SELECT COUNT() FROM Product2];
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
            Product2Extension.ProductWrapper productWrapper = ext.productsToInsert.get(i);
            productWrapper.productRecord.Name = 'Test ' + i;
            productWrapper.productRecord.Family = Constants.PRODUCT_FAMILY.get(math.mod(i,Constants.PRODUCT_FAMILY.size())).value;
            productWrapper.productRecord.IsActive = true;
            productWrapper.productRecord.Initial_Inventory__c = i+1;

            productWrapper.pricebookEntryRecord.UnitPrice = i+1 * 3;
            productWrapper.pricebookEntryRecord.IsActive = true;

            System.Debug(productWrapper);
        }
        Test.startTest();
            ext.save();
        Test.stopTest();

        Integer countProductsAfter = [SELECT COUNT() FROM Product2];
        System.assertEquals(countProductBefore + Constants.DEFAULT_ROWS, countProductsAfter);
    }

}