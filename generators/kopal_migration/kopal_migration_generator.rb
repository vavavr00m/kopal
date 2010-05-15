#FIXME: Shows correct output like "create ....", but file is not being created, so
#for the moment creating files manually by examining file name from output.
class KopalMigrationGenerator < Rails::Generator::NamedBase

  MIGRATION_NAME_PREFIX = 'kopal_plugin_'

  def manifest
    record do |m|
      m.migration_template 'migration:migration.rb', Kopal.root.join('lib','db','migrate'),
        {
          :assigns => kopal_local_assigns,
          :migration_file_name => migration_name
        }
    end
  end

private

  def migration_name
    "#{MIGRATION_NAME_PREFIX}#{class_name.underscore.downcase}"
  end

  def kopal_local_assigns
    returning(assigns = {}) do
      assigns[:class_name] = migration_name
    end
  end
end