public without sharing class ChartHelper {

    public static List<chartData> GetInventory(){
        AggregateResult[] arResults = [SELECT Family, SUM(Quantity_Remaining__c) Quantity
            FROM Product2
            WHERE IsActive = true
                AND Quantity_Remaining__c > 0
            GROUP BY Family];

        List<chartData> cht = new List<chartData>();
        for (AggregateResult ar : arResults) {
            cht.add(new ChartData((String)ar.get('Family'), (Decimal)ar.get('Quantity')));
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}