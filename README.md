# Code Style Guidelines

* Use HAML on new pages and a page that's in HTML that needs a large re-design
* Use the asset pipeline
* Views/layouts should just be full page "templates" designs
* "template" partials should go into views/shared if they are referenced throughout the site
* partials just used in one view category can stay in that view folder

* bind bootstrap modals to links using "data-toggle"=>"modal", "data-target"=>"#<ID_OF_MODAL>" do not use javascript just to show a modal bootstrap already does that. (unless the link is a remote link then using JS to show the modal is fine)

* follow the same JS code style that others have used in order to keep it consistent. 

* CSS GUIDELINES
  * Use Bootstrap CSS/JS features if overriding isn't necessary
    * Then try to use simple custom css / js
      * If it's for a large portion of the site that really needs an external styles (like a slideshow library or something)
        * Then you can use an external CSS/JS library
  * Keep CSS that's for a certain "model" in its appropriate CSS file. 
    * If a "model" is used in another "view category" put the styles in the "model" CSS still
  * Define a class once. Dont have two definitions of the same class reference with different styles in it
  * DO NOT REFERENCE AND ALTER A BOOTSTRAP CLASS DIRECTLY (unless its GUARANTEED never to be used another way).
  * PUT ALL MEDIA QUERIES IN A GROUP AT THE BOTTOM
    * DONT Put one at the top then some normal css next and then more media queries at the bottom
    * PUT THEM ALL TOGETHER.
    * Put them in order from largest query to smallest
    * Also only define a media query once in a file
  * INDENT INDENT INDENT your css
    * The first nested line should have no spaces preceding
    * then everything nested two spaces nested every nest below
    * no breaklines in between any of the brackets
    * A good style example is in scaffold.scss

# DB Design
* Combine as much SQL into one query as possible (using raw sql is find and actually encouraged for multiple table joins)
* Quickest DB queries and smallest memory tables trumps server side code or other application layers
* Design and consider the DB in your updates as the 1st priority

# App Dev process

Once you have the spacedecentral application running on your local machine you should make sure you have the latest code, and then checkout a new personal branch:
```
git checkout mynewbranch
```
then you can save and push the changes you made with
```
git add --all
git commit -m 'yourcomment'
git push origin mynewbranch
```

After completing an issue you must do
``` 
git pull origin master
```
And check to see if everything still looks right

Refer to this guide for tips on branching: https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging


# Installation

used guide http://railsapps.github.io/installing-rails.html

This guide is for issues I had following the OSX Sierra guide http://railsapps.github.io/installrubyonrails-mac.html

You can skip most of the steps in this guide. The essential is to follow the RVM installation, then do: 

```
rvm install ruby-2.4.0
gem update --system

git clone https://github.com/spacedecentral/spacedecentral-network.git
cd spacedecentral-network
rvm use ruby-2.4.0@rails5.0 --create
gem install rails
gem install bundler
gem install puma -v '3.6.2' -- --with-opt-dir=/usr/local/opt/openssl
```

*(Heres where you install mysql for your system)*
*(I have errors on osx and sierra on this step atm)* ***Heres how you do it on ubuntu (tested working):***

```
sudo apt-get install libmysqlclient-dev
sudo apt-get install mysql-server
```

* *(create the dev user and database)*

```
mysql -u root -p
```

```
CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'db_user';
CREATE DATABASE db_spacedecentral_dev;
GRANT ALL PRIVILEGES ON *.* TO 'db_user'@'localhost';
FLUSH PRIVILEGES;
SET PASSWORD FOR 'db_user'@'localhost' = PASSWORD('db_user');
```
```
bundle install
rake db:migrate
rake db:seed
```
### Updating roles

#### Step 1: open terminal and cd to root project and run command
```
rails c
```

#### Step2: query and create role
```
user = User.find_by_email("your_email")
mission = Mission.find(yourIDhere)
user.mission_user_roles.create(mission: mission, role: 1)
```

# Install Homebrew & Redis

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install redis
```


Setting up a local server environment to host the app can be done with virtual hosts and passenger
which is how it should be done in a production environment but can be time consuming

So for a local dev environment its enough to serve the app with the rails server
run

```
rails server (in the spacedecentral-network directory)
```
then access app at http://localhost:3000



# Tips

* In your local dev environment, after registering for an account, look at the development.log for the activation link.

* To create a new mission, navigate to http://localhost:3000/missions/new

# Deploying to production or staging

before deploying run the tests and see if all success

```
rake test
```

then to deploy
For production, run:

```
cap production deploy
```

For staging, run:

```
cap staging deploy
```
# Messaging System

New message has user lookup form and body text and a hidden field named "group_users"
a 1-1 message just has a group of 1 with the other "user to" append on the FE user ids into this field
to send to multiple users. 
The BE will save this combination into a group with all the referenced members If you use the "add group member" on the message UI
that will add that user to that conversation. If you start a new message with different or the same but (less or more ) of the same group it will create a new conversation.

The websockets for new messages / notifications is done in notifier.js and sends dom updates and other information over cable. 

Mission chat is currently seperated as the FE and BE is simpler to treat the entire mission as the group no user tracking is required. 
But this may change if mission chat opens on any page then each member of the mission needs to subscribe to the channel on every mission on every page...

rendering user avatars in the messaging UI will have changes if you were the last person to send a message you will still see either the "user tos" avatar or a subset of the groups avatars.
But you shouldn't render the user who sent the messages avatar.

# Tag System

The tag system consists of two databases the `tags` database and the `tag_references`

The Tags table holds all of the "tags" which is essentially just a string value.
So each row is just a unique string in the database.

The TagReference table is all of the references of tags used in the system.
It has a references ( an id ) to the tag database, and a reference ( an id ) of the object that used it.

The TagReference tables columns are each type of object that can use a "tag" in order to add a new object that can be "tagged"
just create a new reference column in the TagReference table and in the front end save the id of the object in that row.

It is possible to add new Tags ( or string values ) into the Tag database if there is no current Tag with that value just insert into Tags
whenever it created and used by an object.

# Mission User Roles
reserverd = 1
Master = 2
Mission Coordinator = 3
Mission Designer = 4
Mission Trainee = 5
Mission Trainee = 6
Mission Trainee = 7

# Time - Stamps

Dont use `time_ago_in_words` it only loads on page reload
instead use our timestamp helper `.platform_timestamp{"data-time-stamp"=>MODEL.created_at}=platform_timestamp(MODEL.created_at)` 

# Admin Access

go to `/dashboard` to access the admin panel and create accounts for new users
