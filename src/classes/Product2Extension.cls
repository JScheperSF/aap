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
        try {
            List<Product2> product2s = new List<Product2>();
            List<PricebookEntry> pricebookentries = new List<PricebookEntry>();
            for (ProductWrapper productWrapper : productsToInsert) {
                product2s.add(productWrapper.productRecord);
                pricebookentries.add(productWrapper.pricebookEntryRecord);
            }
            insert product2s;
            insert pricebookentries;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){

        }
        return null;
    }

    public class ProductWrapper {
        public Product2 productRecord {get;set;}
        public PricebookEntry pricebookEntryRecord {get;set;}
    }
}