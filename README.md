# Bite-size Addons for an existing Rails App Using Templates

## Usage
 1. Clone the repo locally
 2. Follow the steps in an example run, using your environment

## Add-ons

<details> 
  <summary>Active Storage Test</summary>

### Basic ActiveStorage test with Digital Ocean spaces
This simple template distills down only the changes needed to make **NEW** Rails 6 app
work with ActiveStorage using Digital Ocean spaces. Use this example as a simple 
reference application to see how ActiveStorage works.

<details>
<summary>Example Run for Active Storage Test</summary>

- Watch GoRails Video https://gorails.com/episodes/direct-uploads-with-rails-active-storage
- This template is built from watching that video
- Sign-up for digtal ocean spaces and create your space and API keys
```

cd ~/mystuff

app_name=(your app name here)

if [ -d $app_name ]
then
  echo "trying to drop db ${app_name}_development"
  cd $app_name
  bin/rails db:drop ${app_name}_development
  cd ..
  echo "removing old app $app_name"
  rm -fr $app_name
else
  echo  "${app_name} is a new app creating it fresh"
fi

echo "creating a default rails app with postgresql"
rails new $app_name -d postgresql

echo "adding active storage"
cd $app_name

template="~/mystuff/rails_addons/active_storage_test/template.rb"

bin/rails app:template LOCATION=$template --trace

bin/rails db:create
bin/rails db:migrate

s3cmd setcors lib/active_storage_config/digital_ocean/cors.xml s3://(my bucket) 
 
export S3_KEY=(my key)
export S3_SECRET=(my secret))

bin/rails s
```
</details>


</details>