# Bite-size Addons for an existing Rails App Using Templates

### NOTE:
Rails 7 requires [redis for turbo-streams](https://github.com/hotwired/turbo-rails/issues/225). 
For Ubuntu 20.04.4, Rails 7.0.2.2 and ruby 3.1.1p18 this was a manual install `gem install redis`

# Usage

The add-ons are named to indicate their purpose. The documentation is a WIP.
To get started and experiment try one of the scripts in bin.

Note, the utilities create Rails 7 apps. For newbies to Rails 7, to start the app, `cd` to the app directory 
and run `bin/dev`. Visit `localhost:3000` in your browser.

## 1. Some add-ons require cloning the repo locally.
 1. Clone the repo locally
 2. Follow the steps in an example run, using your environment

## 2. Other add-ons can be run directly from github.
- For example to update the tailwind configuration of a 
new rails 7 application with a basic setup: 
    ```shell
    bin/rails app:template LOCATION=https://raw.githubusercontent.com/rlogwood/rails_addons/main/add_tailwind_scaffold/template.rb --trace
    ```
## 3. Some add-ons work well together
- For example, to create a basic rails 7 tailwind app with devise, a navigation bar and blog use the provided script `bin/create_rails_app.rb`. 
This script will run several add-ons in the right order to create a basic app. 

## Recipies
<details> 
  <summary>Creating basic Rails 7, tailwind, devise app </summary>
This script will run the following add-on templates in order to create 
Rails 7 TailwindCSS application with Devise authentication, 
a navigation bar and several pages (home, about, services), a blog and post model.
The script will prompt for an email address and password and add an admin 
user that can create posts. 

-  rails7_tailwind_config
-  add_tailwind_scaffold
-  add_devise
-  add_pages_devise_nav
-  add_cancancan
-  add_blog
-  add_error_pages

### Create the app:
- _NOTE: Most of the individual addons can be run directly from the repo
but to run the script that creates the app applying all the above addons , you must first clone the repo_

  ```shell
  # clone the repo
  # run the ruby script
  % (repo_location)/bin/create_rails_app.rb
  ```

- _TODOs: WIP, improve layout and styling_

</details>

## How to run specific Add-ons

<details> 
  <summary>Active Storage Test (requires clone)</summary>

### Basic ActiveStorage test with Digital Ocean spaces
This simple template distills down only the changes needed to make **NEW** Rails 6 app
work with ActiveStorage using Digital Ocean spaces. Use this example as a simple 
reference application to see how ActiveStorage works. 

**An advanced use case is to run the template for an existing application. Do this on a new,
clean working branch so that you can see all the files that are added and changed.** The 
template will support the following use cases:
- using asset pipeline for css and webpacker 5 or 6 for javascript 
- using webpacker 5 or 6 for both css and javascript
- NOTE: Adding the template to existing applications has only been tested on webpacker 6 apps using webpacker for CSS



<details>
<summary>Example Run for Active Storage Test</summary>

- Watch GoRails Video https://gorails.com/episodes/direct-uploads-with-rails-active-storage
- This template is built from watching that video
- Sign-up for digtal ocean spaces and create your space and API keys
```

cd ~/mystuff

app_name=(your app name here)

echo "creating a default rails app with postgresql"
rails new $app_name -d postgresql

echo "adding active storage"
cd $app_name

template="~/mystuff/rails_addons/active_storage_test/template.rb"

bin/rails app:template LOCATION=$template --trace

bin/rails db:create
bin/rails db:migrate

# note install s3cmd (if you use brew: brew install s3cmd)
# configure s3cmd with s3cmd --configure (https://docs.digitalocean.com/products/spaces/resources/s3cmd/)

s3cmd setcors lib/active_storage_config/digital_ocean/cors.xml s3://(my bucket) 
 
export S3_KEY=(my key)
export S3_SECRET=(my secret))

bin/rails s
```
</details>


</details>