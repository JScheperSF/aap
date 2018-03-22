/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    public Integer defaultRowsInTable {
        get {
            return Constants.DEFAULT_ROWS;
        }
    }

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;
    ApexPages.StandardController standardController;

    public OrderExtension(ApexPages.StandardController standardController){
        List<Product2> allproducts = [SELECT Name FROM Product2 WHERE Name LIKE 'Product%' LIMIT 10];
        for (Product2 product : allproducts) {
            System.debug(product);
        }
        delete allproducts;

        this.standardController = standardController;
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        orderItemList = new List<OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }

        List<Product2> products = [SELECT Quantity_Ordered__c FROM Product2];// WHERE Id = :orderRecord.Id]; // Must likely be updated. Use it now for getting the standardSetController up and running.
        standardSetController = new ApexPages.StandardSetController(products);
        standardSetController.setPageSize(defaultRowsInTable);
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection

    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total

    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        Savepoint savepoint = Database.SetSavepoint();
        try {
            standardController.Save();
        } catch(Exception e) {
            Database.rollback(savepoint);
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        Integer totalPages = (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
        System.debug('############ totalPages: ' + totalPages);
        return totalPages;
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> selectOptions = new List<SelectOption>{new SelectOption('', Constants.SELECT_ONE)};

        for (Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            selectOptions.add(new SelectOption(entry.label, entry.value));
        }

        return selectOptions;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}