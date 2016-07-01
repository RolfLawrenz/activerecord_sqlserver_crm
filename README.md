## Description
The ActiveRecord Sqlserver CRM gem is used to communicate with the Microsoft CRM database. When reading it accesses the CRM database directly using the activerecord-sqlserver-adapter gem. When writing or deleting it uses the CRM OData API. From experience we have found querying with OData to be slow and restricted. So thats why it accesses the databse directly when reading. Writing directly to the database is dangerous in Microsoft CRM because it has triggers that perform other tasks like writing to other tables. Therfore we go through OData which uses the CRM SDK which sets all the necessary triggers.  

The ActiveRecord Sqlserver CRM is based on the [activerecord-sqlserver-adapter](https://github.com/rails-sqlserver/activerecord-sqlserver-adapter) gem, hence the name of the project. This project is a [Rails engine](http://guides.rubyonrails.org/engines.html). This means this gem (engine) is intended to work with a Rails application. 

Looking at the folder structure it will match a typical Rails application, this is the way Rails engines work. Under the **app/models** folder you will see the models which are based on the Microsoft CRM database. The class names are not important but the table name definitions in the class must match the Database table name. Field names will match the field names in the database. **Please note there is no mapping of fields. Field names have NOT been rubyized, so if the name of a field in the database is ContactId, the field name in ruby will also be ContactId.**

## Getting started
Add to your Gemfile with:

```
gem 'activerecord_sqlserver_crm'
```

Run the bundle command to install it

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
Create, Update, Delete will use the OData interface rather than direct. Directly creating, updating or deleting is not recommended because Microsoft CRM performs various other functions such as creating records in other tables.

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


### Microsoft CRM Tables
Some of the Microsoft CRM core tables are added to this gem. If you have your own tables you want to add, you will need to create your own model classes.

In your projects **app/models** folder create a new folder called **crm**. In the **crm** folder create a new class model, for example (*app/models/crm/invoice.rb*)

```ruby
module Crm
  class Invoice < ActiveRecord::Base
    # Names must match exactly what is in CRM database
    self.table_name = "Invoice"
    self.primary_key = "InvoiceId"
    
    # foreign_key is in database table. Used for reading
    # crm_key is used in OData call (writing). See OData metadata for name 
    belongs_to :contact, foreign_key: 'InvoiceId', crm_key: 'customerid_contact'
    
    # Add validations if any in table
    
  end
end
```


The OData metadata can be found in your CRM site here **https://mycompany.com/TEST/api/data/v8.0/$metadata**

### Associations 
Associations can be referenced as usual in activerecord. For example:

```ruby
contact = Crm::Contact.where(ContactId: '<crm_guid>').first
invoices = contact.invoices
```

When adding your own models, make sure you add these associations using the typical activerecord **has_many**, **belongs_to** methods. There is an extra field included in the **belongs_to** method called **crm_key**. The **crm_key** is used only for OData calls. Sometimes the foreign_key stored in the table is different than the whats used in OData. 
To find the foreign_key field, look in the database table. To find the crm_key, look in the OData metadata Entity. It is case sensitive. The crm_key will look something like this in the metadata (customerid_contact):
 
```xml
<EntityType Name="invoice" BaseType="mscrm.crmbaseentity">

  <NavigationProperty Name="customerid_contact" Type="mscrm.contact" Nullable="false" Partner="invoice_customer_contacts">
    <ReferentialConstraint Property="_customerid_value" ReferencedProperty="contactid"/>
  </NavigationProperty>

```
 

### Adding a new Field
There is nothing required in the library for a new field. Just start using it in your app. Fields are case sensitive.

## Unit Tests
To get the unit tests working in this gem you must create the following yaml files:

* **spec/dummy/config/database.yml** - points to your Microsoft CRM database. (See **spec/dummy/config/sample.database.yml**)
* **spec/dummy/config/odata.yml** - points to your Microsoft CRM OData interface.  (See **spec/dummy/config/sample.odata.yml**)

run as

```
bundle exec rspec spec
```

Unit tests will create, update and destroy records in the **test** database as defined in the database.yml file. It will not drop or truncate table.

## How it works
In the *lib/active_record_extension.rb* file it over writes Active Record persistence functions to use OData. When using this gem it will appear to be like a typical rails adapter.

This gem has only been tested with the **Microsoft CRM 2016**.

## Adapting to your own Company
Its most likely there will be tables that you created in Microsoft CRM for your own company. To use these custom tables it is recommended that you create your own gem for your company that builds on this gem. Here are the recommended steps to do this:

* Create a rails engine gem with **full** flag

```
$ rails plugin new activerecord_sqlserver_mycompany --full
```

* Add this gem to gemspec file and bundle install

```ruby
  s.add_dependency "activerecord_sqlserver_crm"
```

* Under the **app/models** folder create a **crm** folder
* Create your new models in the **app/models/crm** folder
* Alter existing models in this gem with concerns.
* Create an initializer file **config/initializers/extensions.rb**

```ruby
Dir[File.join(File.expand_path("../..",__dir__),"app/models/concerns/*.rb")].each {|file| require file }
```

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

Under models/crm add your custom table (*app/models/crm/widget.rb*):

```ruby
module Crm
  class Widget < ActiveRecord::Base
    self.table_name = "new_Widget"
    self.primary_key = "new_WidgetId"

    belongs_to :account, foreign_key: 'new_WidgetId', crm_key: 'new_WidgetId'

  end
end
```

You should be able to see widgets under accounts like this

```ruby
account = Crm::Account.last
account.widgets.count
account.testa

Crm::Account.testb
```

Now in your company projects you include this company gem (activerecord_sqlserver_mycompany) in your Gemfile.

### Many to Many relationships

Here is an example of a many to many relationship

The Many to Many table (WidgetThing)

```ruby
module Crm
  class WidgetThing < ActiveRecord::Base
    self.table_name = "new_WidgetThing"
    self.primary_key = "new_WidgetThingId"

    belongs_to :widget, foreign_key: 'new_widgetId', crm_key: 'new_widgetid'
    belongs_to :thing, foreign_key: 'new_thingId', crm_key: 'new_thingid'
  end
end
```

The One to Many Tables

```ruby
module Crm
  class Widget < ActiveRecord::Base
    self.table_name = "new_Widget"
    self.primary_key = "new_WidgetId"

    has_many :widget_things, foreign_key: 'new_widgetId'
    has_many :things, through: :widget_things, foreign_key: "new_widgetId", class_name: "Crm::WidgetThing"
  end
end

module Crm
  class Thing < ActiveRecord::Base
    self.table_name = "new_Thing"
    self.primary_key = "new_ThingId"

    has_many :widget_things, foreign_key: 'new_thingId'
    has_many :widgets, through: :widget_things, foreign_key: "new_thingId", class_name: "Crm::WidgetThing"
  end
end
```

## Help needed

I have only added a handful of models from Microsoft CRM into this gem. Its a mammoth task to add all CRM models, relationships, validations into this gem. If you use this gem and add additional common models, please send me a pull request to include in this gem.
