require 'mysql'

module OrgSocGraph
  FIELDS = {
    "orgs.csv" => [
      Class.new(Object) do
        def name
          :description
        end
     end.new
    ]
  }
 
  START_JOBS = [
    Class.new(BaseJob) do
      # parent job doesn't do anything
      def url
        "http://www.example.com"
      end
      
      def get_children(doc)
        # do MySQL query to get the URLs of the child jobs
        dbh = MySQL.real_connect("216.93.247.46", "turb_mi5", "db-fastlane", "techmi5_socgraph")
        # limit to 10 for test run
        res = dbh.query('SELECT website_url FROM tbl_organizations WHERE website_url != "" LIMIT 10')
        res.each_row do |r|
          Class.new(BaseJobWithUrl) do
            def url
               url
            end
                
            def execute(doc, data_store, fields)
              # crawl for meta description
              meta_desc = doc.css("meta[name='description']")
              if(!meta_desc.empty?)
               data_store.add_item("orgs.csv", [
                 self.url,
                 meta_desc[0]['content']
               ])
              end
            end
          end.new(r["website_url"])
        end
      end
    end
  ]
end
