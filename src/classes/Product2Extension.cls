public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController stdController){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i < Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public List<SelectOption> GetFamilyOptions() {
        List<SelectOption> selectOptions = new List<SelectOption>{new SelectOption('', Constants.SELECT_ONE)};

        for (Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            selectOptions.add(new SelectOption(entry.label, entry.value));
        }

        return selectOptions;
    }

    public PageReference Save(){
        Savepoint savePoint = Database.setSavepoint();
        try {
            List<Product2> product2s = new List<Product2>();
            for (ProductWrapper productWrapper : productsToInsert) {
                product2s.add(productWrapper.productRecord);
            }
            insert product2s;

            List<PricebookEntry> pricebookentries = new List<PricebookEntry>();
            for (ProductWrapper productWrapper : productsToInsert) {
                productWrapper.pricebookEntryRecord.Product2Id = productWrapper.productRecord.id;
                productWrapper.pricebookEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                pricebookentries.add(productWrapper.pricebookEntryRecord);
            }
            insert pricebookentries;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
            Database.rollback(savePoint);
        }
        return null;
    }

    public class ProductWrapper {
        ProductWrapper() {
            productRecord = new Product2();
            pricebookEntryRecord = new PricebookEntry();
        }
        public Product2 productRecord {get;set;}
        public PricebookEntry pricebookEntryRecord {get;set;}
    }
}