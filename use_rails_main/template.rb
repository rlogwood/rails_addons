# frozen_string_literal: true
#gem "rails", git:'https://github.com/rails/rails.git', branch: 'main'
def rails_main_gem
  <<~'END_STRING'
    gem "rails", git:'https://github.com/rails/rails.git', branch: '7-0-stable'
  END_STRING
end

gsub_file 'Gemfile', /gem "rails",.*/, rails_main_gem
