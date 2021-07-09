def add_has_many(parent, child)
  filename = model_filename(parent)
  children = pluralize_sym(child)
  puts "updating: (#{filename}): #{parent} :has_many #{children}"
  insert_into_file(filename, before: 'end') { "  has_many :#{children}\n" }
end

def model_filename(model_name)
  "app/models/#{model_name.to_s}.rb"
end

def pluralize_sym(symbol)
  symbol.to_s.pluralize.to_sym
end

def model_migration_filename(model)
  migration_pattern = File.join( 'db','migrate',"*_create_#{model}.rb")
  puts "Searching for model (#{model}) migration file pattern (#{migration_pattern})"
  Dir.glob(migration_pattern).first
end

def create_resume_scaffold(options)
  generate :scaffold, "resume version introduction:text seeking:text status firstname lastname phone email user:references published:boolean", options
  generate :scaffold, "job title company start:date end:date role skills:string technologies:string resume:references", options
  generate :scaffold, "job_role name summary:text start:date end:date job:references", options
  generate :scaffold, "job_task description job_role:references", options
end

def add_has_many_relations
  add_has_many(:resume, :job)
  add_has_many(:job, :job_role)
  add_has_many(:job_role, :job_task)
end

def remove_scaffold(perform_rollback)
  rails_command 'db:rollback STEP=4' if perform_rollback
  rails_command "destroy scaffold resume"
  rails_command "destroy scaffold job"
  rails_command "destroy scaffold job_role"
  rails_command "destroy scaffold job_task"
end

def add_enum(model, column, values)
  filename = model_filename(model)
  enum_values = "\n  enum #{column}: %i[#{values.join(' ')}]"
  insert_into_file(filename, enum_values, after: '< ApplicationRecord')
end

def column_reader_writer(column)
  <<-END_STRING
  def #{column}=(val)
    self[:#{column}] = get_array_from_string(val)
  end

  def #{column}
    convert_array_to_string(self[:#{column}])
  end

  END_STRING
end

def array_column_support
  <<-'END_STRING'
  private

  def get_array_from_string(val)
    values = val.downcase.split(/ *[,;:] */)
    values.reject!(&:empty?)
    puts "From value:(#{val}) created (#{values.join(',')})"
    values
  end

  def convert_array_to_string(val)
    val.join('; ')
  end
  END_STRING
end

def add_array_attribute_reader_writer(model, columns)
  filename = model_filename(model)
  columns.each do |column|
    insert_into_file(filename, column_reader_writer(column), before: /^end/)
  end
  insert_into_file(filename, array_column_support, before: /^end/)
end

def add_array_and_index(model, column)
  puts "model:#{model}"
  puts "column:#{column}"
  table = pluralize_sym(model)
  puts "table:#{table}"
  filename = model_migration_filename(table)
  puts "filename:#{filename}"
  puts("Updating (#{model}) for array column (#{column}) and index in (#{filename})")
  insert_into_file(filename, ", array: true, default:[]", after: "t.string :#{column}", force: true)
  insert_into_file(filename, "    add_index :#{table}, :#{column}, using: 'gin'\n", before: /^  end\n^end/)
end

def add_array_support(model, columns)
  columns.each { |column| add_array_and_index(model, column) }
  add_array_attribute_reader_writer(model, columns)
end

def update_model_relations_and_enums
  add_has_many_relations
  add_enum(:resume,:status,%i[active archived])
end

def prod_run
  # TODO: make perform_rollback based on migrations being present
  remove_scaffold(false)
  create_resume_scaffold("--migration")
  update_model_relations_and_enums
  add_array_support(:job, [:skills, :technologies])
  rails_command "db:migrate", abort_on_failure: true
end

prod_run

