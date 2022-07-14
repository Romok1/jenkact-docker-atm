namespace :configdb do
     task :setupdb do
       setup_config = <<-EOF
     development:
       adapter: postgresql
       encoding: unicode
       database: jenkact_development
       pool: 5
       username: pass
       password: pass
     test:
       adapter: postgresql
       encoding: unicode
       database: jenkact_test
       pool: 5
       username: pass
       password: pass
     staging:
       adapter: postgresql
       encoding: unicode
       database: jenkact_staging
       pool: 5
       username: pass
       password: pass
   EOF
       on roles(:app) do
         execute "mkdir -p #{shared_path}/config"
         upload! StringIO.new(setup_config), "#{shared_path}/config/database.yml"
       end
   end
end
