## Description
The ActiveRecord Sqlserver CRM gem is used to communicate with the Microsoft CRM database. When reading it accesses the CRM database directly using the activerecord-sqlserver-adapter gem. When writing or deleting it uses the CRM OData API. From experience we have found querying with OData to be slow and restricted. So thats why it accesses the databse directly when reading. Writing directly to the database is dangerous in Microsoft CRM because it has triggers that perform other tasks like writing to other tables. Therfore we go through OData which uses the CRM SDK which sets all the necessary triggers.  

The ActiveRecord Sqlserver CRM is based on the [activerecord-sqlserver-adapter](https://github.com/rails-sqlserver/activerecord-sqlserver-adapter) gem, hence the name of the project. This project is a [Rails engine](http://guides.rubyonrails.org/engines.html). This means this gem (engine) is intended to work with a Rails application. 

Looking at the folder structure it will match a typical Rails application, this is the way Rails engines work. Under the **app/models** folder you will see the models which are based on the Microsoft CRM database. The class names are not important but the table name definitions in the class must match the Database table name. Field names will match the field names in the database. **Please note there is no mapping of fields. Field names have NOT been rubyized, so if the name of a field in the database is ContactId, the field name in ruby will also be ContactId.**

## Getting started

You will need to **create your own company rails engine gem** for your company based on this gem.

Then you will **create your own Rails project** that uses the rails engine gem your created for your company.

Both of these are explained below.

## Adapting to your own Company
### Creating your own company rails engine gem
Its most likely there will be tables that you created in Microsoft CRM for your own company. To use these custom tables it is recommended that you create your own gem for your company that builds on this gem. This gem can be used in all your projects that need to access your company CRM database. You only need one of these gems for your company. Here are the recommended steps to do this:

* Create a rails engine gem with **full** flag. Replace 'mycompany' with your won company name.

```
$ rails plugin new activerecord_sqlserver_mycompany --full
```

* Add this gem to gemspec file and bundle install

```ruby
  s.add_dependency "activerecord_sqlserver_crm"
```

* Create an initializer file **config/initializers/extensions.rb** with the following:

```ruby
Dir[File.join(File.expand_path("../..",__dir__),"app/models/concerns/*.rb")].each {|file| require_dependency file }
```

* Alter existing CRM table models in this gem with concerns. These are standard CRM table models, for example Contact, Account, Invoice.
* Under the **app/models** folder create a **concerns** folder
* Create your altered models like this (*app/models/concerns/account_ext.rb*):

```ruby
module AccountExt
  extend ActiveSupport::Concern

  included do
    has_many :widgets, foreign_key: 'AccountId'
  end

  def testa
    puts "testa"
  end

  module ClassMethods
    def testb
      puts "testb"
    end

  end
end

# Add new code into Account model
Crm::Account.send(:include, AccountExt)
```

* Under the **app/models** folder create a **crm** folder
* Create your company table models in the **app/models/crm** folder

* Under **app/models/crm** add your company custom table (*app/models/crm/widget.rb*):

```ruby
module Crm
  class Widget < ActiveRecord::Base
    self.table_name = "new_Widget"
    self.primary_key = "new_WidgetId"

    belongs_to :account, foreign_key: 'new_WidgetId', crm_key: 'new_WidgetId'

  end
end
```

You should be able to see widgets like this (test using rails console):

```ruby
Crm::Widget.count

Crm::Widget.last

Crm::Widget.where("end_date < ?", Time.now)
```

If you linked the table to an account, you should be able to see widgets under accounts like this

```ruby
account = Crm::Account.last
account.widgets.count
account.testa

Crm::Account.testb
```

Your company activerecord sqlserver gem is now ready to be used in your projects.

### Your Company Project
Your project must be a rails project. The gem you created previously is a rails engine and only works with rails projects.

In your **Gemfile** you will need to add the following:

#### Gems to access Microsoft CRM

```ruby
gem 'activerecord_sqlserver_crm', '~> 5.0'
gem 'activerecord_sqlserver_mycompany', git: 'git@bitbucket.org:mycompanyrepo/activerecord_sqlserver_mycompany.git'
```

#### Gems for Caching

To improve **performance** of reading table structures, fields, indexes, etc. **Caching** is used. The table structures are read once and stored in cache (if you use caching). I highly recommend using caching, as this will improve your read times significantly. One thing to keep in mind though, *if your database structure changes, you will need to clear cache*. In this gem I use **Rails.cache**, so you should be able to use any caching library that supports Rails.cache. Here I use a **Redis** library called **hiredis**. 

```ruby
gem 'readthis',         '~> 2.0.2'
gem 'hiredis',          '~> 0.6.1'
gem 'redis-namespace',  '~> 1.5', '>= 1.5.2'
```

#### Cache environment settings
In each of your **config/environments** files you will need to configure your cache. You will need to look up the documentation for the Rails cache library you use. In my case I use redis (hiredis gem) and I set like this:

```ruby
REDIS_URL='redis://localhost:6379/'
APP_CACHE_NAME = "my_project_name"

Rails.application.configure do
...

  config.cache_store = :readthis_store, {
      expires_in: 1.day.to_i,
      namespace: APP_CACHE_NAME,
      redis: { url: REDIS_URL, driver: :hiredis }
  }

...

end

```

#### Start Cache Library
Start the cache server. In my case I use Redis so I start like this. Which runs redis server in the background.

```bash
$ redis-server &
```

#### Clearing cache
When your database structure changes you will need to clear the case for the gem to pick up the changes. In code I set an **expires** time of **1 day**, so it will re read the database structures at least once a day. If you cant wait 1 day and want to changes immediately you will need to clear your own cache. If using Redis you would do this:

```bash
$ redis-cli
127.0.0.1:6379> KEYS *
 1) "mytable:sqlserver_table_view_info_new_subscription"
 2) "mytable:sqlserver_def_col__new_subscriptionBase"
127.0.0.1:6379> FLUSHALL
OK
127.0.0.1:6379> KEYS *
(empty list or set)
127.0.0.1:6379>
```


#### CRM Models
All your CRM models are defined in the activerecord_sqlserver_mycompany gem. You should not have any CRM models in your project.

#### Non-CRM Models using SqlServer
If you need to access other SqlServer databases that are not CRM you will need to make a couple adjustments to support it. The main issue is the activerecord_sqlserver_crm code overrides the write, update, delete functions for the SqlServer database and forces it to use OData. For your Non-CRM models that are in SqlServer you do not want this OData overriding, you want to to write direct.

Create a **app/models/concerns/sqlserver_adapter_base.rb** file with the following:

```ruby
module SqlserverAdapterBase

  # Allows us to re-include ActiveRecord::Persistence
  # thus giving SqlServer Adapter the standard database
  # persistent methods (not going through ODATA - sqlserver_adapter_crm gem)
  def include_again(mod)
    mod.instance_methods.each do |m|
      send(:define_method, m) do |*args|
        mod.instance_method(m).bind(self).call(*args)
      end
    end
  end
end
```

Create your new **Non-CRM sqlserver model**. In this example I use a database called **Devdb** and a table called **ProcessLog**. Create the folder and file like this **app/models/devdb/process_log.rb**. The contents of the file like this:

```ruby
module Devdb
  class ProcessLog < ActiveRecord::Base
    establish_connection "#{Rails.env}_devdb".to_sym
    extend SqlserverAdapterBase
    include_again ActiveRecord::Persistence

    self.primary_key = :devdbid
    self.table_name = "ProcessLog"

    # My class methods go here

  end
end
```

Add the table settings in the **database.yml** file:

```ruby
# DEVDB database. Used for reading/writing ProcessLogs
development_devdb: &devdb_development
  adapter: sqlserver
  host: my_devdb_host.com
  port: 1433
  database: DEVDB
  username: DevDBUser
  password: my_password

staging_devdb:
  <<: *devdb_development

test_devdb:
  <<: *devdb_development
```

Test your new table using **rails c**. You should be able to write/update/delete to your table without using OData.

```ruby
$ bundle exec rails c
Loading development environment (Rails 5.0.2)
irb(main):001:0> Devdb::ProcessLog.count
2017-07-24 11:20:19 -0600 DEBUG   SQL (30.9ms)  USE [DEVDB]
2017-07-24 11:20:20 -0600 DEBUG    (49.9ms)  SELECT COUNT(*) FROM [ProcessLog]
=> 197825
```

## Reading records
Because it is based on the rails framework you have all the activerecord goodness. All models are under the **Crm** namespace. To read a Contact in the Microsoft CRM database:

```ruby
Crm::Contact.where(ContactId: 'AAAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE').first
```

Number of records in Contact table:

```ruby
Crm::Contact.count
```

All read queries will talk to the CRM database directly.

### Creating, Updating or Deleting a record
Create, Update, Delete will use the OData interface rather than direct. Directly creating, updating or deleting is not recommended because Microsoft CRM performs various other functions such as creating records in other tables. You will see the OData calls in the Ruby debug logs.

Create a new record with

```ruby
contact = Crm::Contact.new(FirstName: 'Test', LastName: "Testerson")
contact.save
```

Update a record with

```ruby
contact.update(FirstName: 'John')
contact.save
```

Delete a record with
```ruby
contact.destroy
```

### OData Metadata

The OData metadata can be found in your CRM site here **https://mycompany.com/TEST/api/data/v8.n/$metadata**

### Associations 
Associations can be referenced as usual in activerecord. For example:

```ruby
contact = Crm::Contact.where(ContactId: '<crm_guid>').first
invoices = contact.invoices
```

When adding your own models, make sure you add these associations using the typical activerecord **has_many**, **belongs_to** methods. There is an extra field included in the **belongs_to** method called **crm_key**. The **crm_key** is used only for OData calls. Sometimes the foreign_key stored in the table is different than the whats used in OData. 
To find the foreign_key field, look in the database table. To find the crm_key, look in the OData metadata Entity. It is case sensitive. The crm_key will look something like this in the metadata file (customerid_contact):
 
```xml
<EntityType Name="invoice" BaseType="mscrm.crmbaseentity">

  <NavigationProperty Name="customerid_contact" Type="mscrm.contact" Nullable="false" Partner="invoice_customer_contacts">
    <ReferentialConstraint Property="_customerid_value" ReferencedProperty="contactid"/>
  </NavigationProperty>

```
 
The **Name="customerid_contact"** in the example above is used as the **crm_key** in your table definitions.

### Adding a new Field
There is nothing required in the library for a new field. Just start using it in your app. Fields are case sensitive. You may need to clear your cache to see it immediately.

## How it works
In the *lib/active_record_extension.rb* file it over writes Active Record persistence functions to use OData. When using this gem it will appear to be like a typical rails adapter.

This gem has only been tested with the **Microsoft CRM 2016**.

### One to Many relationships

Here is an example of a one to many relationship *(only relevant parts shown)*

The One to Many table (Contact has many Opportunities)

```ruby
module Crm
  class Opportunity < ActiveRecord::Base
    self.table_name = "Opportunity"
    self.primary_key = "OpportunityId"

    belongs_to :contact, foreign_key: 'ContactId', crm_key: 'customerid_contact'
  end
end

module Crm
  class Contact < ActiveRecord::Base
    self.table_name = "Contact"
    self.primary_key = "ContactId"

    has_many :opportunities, foreign_key: 'ContactId'
  end
end
```

### Many to Many relationships

Here is an example of a many to many relationship *(only relevant parts shown)*

The Many to Many Tables (Opportunities and Users)

```ruby
module Crm
  class Opportunity < ActiveRecord::Base
    self.table_name = "Opportunity"
    self.primary_key = "OpportunityId"

    has_many :opportunity_users, foreign_key: 'opportunityid'
    has_many :users, through: :opportunity_users, foreign_key: "opportunityid"
  end
end

module Crm
  class User < ActiveRecord::Base
    self.table_name = "SystemUser"
    self.primary_key = "SystemUserId"

    has_many :opportunity_users, foreign_key: 'systemuserid'
    has_many :opportunities, through: :opportunity_users, foreign_key: "systemuserid"
  end
end

module Crm
  class OpportunityUser < ActiveRecord::Base
    self.table_name = "new_opportunity_systemuser"
    self.primary_key = "new_opportunity_systemuserId"
    self.many_to_many_associated_tables = [Crm::User, Crm::Opportunity]
    self.many_to_many_use_old_api = true

    belongs_to :opportunity, foreign_key: 'opportunityid', crm_key: 'new_opportunityid'
    belongs_to :user, foreign_key: 'systemuserid', crm_key: 'new_systemuserid'

    validates :opportunity, presence: true
    validates :user, presence: true
  end
end
```

The **self.many_to_many_use_old_api = true** I have found only a problem when working with the **SystemUser** table like
 above. For all other tables you should be able to use the new REST api, so that line can be omitted.
 
### Associate a Many to Many
You must create the many to many association like this:

```
opp = Crm::Opportunity.where(OpportunityId: '0000000-0000-0000-0000-000000000001').last
user = Crm::User.where(SystemUserId: '0000000-0000-0000-0000-000000000002').last
ou = Crm::OpportunityUser.create!(opportunity: opp, user: user)
```

### Disassociate a Many to Many
You must delete the many to many association like this:

```
opp = Crm::Opportunity.where(OpportunityId: '0000000-0000-0000-0000-000000000001').last
user = Crm::User.where(SystemUserId: '0000000-0000-0000-0000-000000000002').last
ou = Crm::OpportunityUser.where(opportunity: opp, user: user)
ou.destroy!
```
 

## OData differences
In some rare cases Microsoft CRM names fields differently in OData than in database. If you this occurs for you, you can use the **odata_field** method. For example

```ruby
module Crm
  class Tag < ActiveRecord::Base
    self.table_name = "new_tag"
    self.primary_key = "new_tagId"

    # Field is same name as table. Database uses "new_tag", OData uses "new_tag1"
    odata_field :new_tag, crm_key: 'new_tag1'

    validates :new_tag, presence: true
  end
end
```

If OData calls then table name differently than the Database you can use the **odata_table_reference** method:
```ruby
module Crm
  class Tag < ActiveRecord::Base
    self.table_name = "new_tag"
    self.primary_key = "new_tagId"
    odata_table_reference = "odata_new_tag"
  end
end
```

## Failover Database
The library supports fail over using a secondary database. If active record cannot connect to the primary database, it will switch
to using the secondary. After every 5 minutes it will retry to connect to the master database. To use this feature add **slaves** to your **database.yml** file:

```ruby
development:
  adapter: sqlserver
  host: master.db.int
  port: 1433
  database: CompanyDatabase
  username: user
  password: pass
  slaves:
    - host: slave.db.int
```

## OData
You can switch OData writing off for your environment by setting the **odata_enabled** flag to false in your odata.yml file. For example:

```ruby
test:
  <<: *development
  odata_enabled: false
```

## Unit Tests
To get the unit tests working in this gem you must create the following yaml files:

* **spec/dummy/config/database.yml** - points to your Microsoft CRM database. (See **spec/dummy/config/sample.database.yml**)
* **spec/dummy/config/odata.yml** - points to your Microsoft CRM OData interface.  (See **spec/dummy/config/sample.odata.yml**)

run as

```
bundle exec rspec spec
```

Unit tests will create, update and destroy records in the **test** database as defined in the database.yml file. It will not drop or truncate table.


## Feedback

Let me know if you see any issues or have any suggestions of improvements.
