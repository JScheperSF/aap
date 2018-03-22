/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/
public class AnnouncementQueueable implements Queueable{

    public List<ConnectApi.AnnouncementInput> toPost;

    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/
    public void PostAnnouncements(List<ConnectApi.AnnouncementInput> announcements){
        if ( announcements.size() > 0 && !test.isRunningTest() ){
            AnnouncementQueueable q = new AnnouncementQueueable();
            q.toPost = announcements;

            System.enqueueJob(q);
        }
    }

    public void execute(QueueableContext qc) {
        List<Community> comm = [SELECT Id FROM Community WHERE Name = 'Inventory Announcements'];
        System.assert(comm.size() == 1, 'Found multiple communities called "Inventory Announcements", where only one was expected.');

        for (ConnectApi.AnnouncementInput announcement : toPost) {
            ConnectApi.Announcements.postAnnouncement(String.valueOf(comm.get(0).Id), announcement);
        }
    }
}