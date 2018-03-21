/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (
    before insert, after insert
    ,before update, after update
    ,before delete, after delete
    ,after undelete
) {
    try {
        if ( Trigger.New != null && Trigger.isAfter && Trigger.IsUpdate){
            OrderHelper.AfterUpdate(
                    new List<Order>(Trigger.newMap.values()),
                    new List<Order>(Trigger.oldMap.values())
            );
        }
    }catch ( Exception e ){
    
    }
}