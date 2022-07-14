namespace :configkey do
     task :setupkey do
       key_config = <<-EOF
     4772cb3fc058b52543331134a22cfed6
   EOF
       on roles(:app) do
         execute "mkdir -p #{shared_path}/config"
         upload! StringIO.new(key_config), "#{shared_path}/config/master.key"
       end
   end
end
