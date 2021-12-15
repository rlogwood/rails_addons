# Bite-size Addons for an existing Rails App Using Templates

# Usage

The add-ons are named to indicate their purpose. The documentation is a WIP.
To get started and experiment try one of the scripts in bin.

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
- For example, to create a basic rails 7 tailwind app with devise and a navigation bar use the provided script `bin/create_basic_twdr7_rails_app.rb`. 
This script will run several add-ons in the right order to create a basic app. 
    ```shell
    wget https://raw.githubusercontent.com/rlogwood/rails_addons/main/bin/create_basic_twdr7_rails_app.rb
    ruby create_basic_twdr7_rails_app.rb
    ```

## Recipies
<details> 
  <summary>Creating basic Rails 7, tailwind, devise app </summary>
This script will run the following add-on templates in order to create 
Rails 7 TailwindCSS application with Devise authentication, 
a navigation bar and several pages (home, about, services)

- rails7_tailwind_config
- add_tailwind_scaffold
- add_devise
- add_pages_devise_nav

  ```shell
  wget https://raw.githubusercontent.com/rlogwood/rails_addons/main/bin/create_basic_twdr7_rails_app.rb
  ruby create_basic_twdr7_rails_app.rb
  ```
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