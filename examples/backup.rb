module Kernel
  def implies(test)
    test ? yield : true
  end
end

module Backup
  class Model
    extend RDL
 
    spec :initialize do
      dsl do
        spec :database do
          post_cond do |a|
            db = a[0]

            implies (db.class == Backup::Database::PostgreSQL) do
              n = 0 - "pg_dump".length - 1
              psql = db.pg_dump_utility[0..n] + "psql"

              username_options = db.username.to_s.empty? ? " " : "-U #{db.username.to_s}"
              password_options = db.password.to_s.empty? ? '' : "PGPASSWORD='#{password}' "

              cmd = "#{password_options} " + "#{psql} -d #{db.name} #{username_options} --command=\";\""

              pipeline = Pipeline.new
              pipeline << cmd
              pipeline.run

              pipeline.success?
            end
          end          
        end

        spec :store_with do
          post_cond do |a|
            sw = a[0]

            implies (sw.class == Backup::Storage::SFTP) do
              begin
                # Make sure to pass a block so that the session is terminated
                # automatically.
                Net::SFTP.start(sw.ip, sw.username, 
                                :password => sw.password, :port => sw.port) {}
                true
              rescue
                false
              end
            end
          end
        end
      end
    end
  end
  
  class Archive
    extend RDL

    spec :initialize do
      dsl do
        spec :add do
          pre_cond do |path|
            File.exist?(path)
          end
        end

        spec :exclude do
          pre_cond do |path|
            File.exist?(path)
          end
        end
      end

    end
  end

  module Storage
    class Local
      extend RDL
      
      spec :initialize do
        dsl do
          spec :path= do
            # if dir path does not exist, backup will create it later
            
            pre_cond do |path|
              implies File.exist?(path) do
                # make sure the path is not an exisiting regular file
                File.directory?(path) and File.writable?(path) 
              end
            end
          end
        end
      end
    end

  end
end


