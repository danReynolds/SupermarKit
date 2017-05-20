module YourApp
  class Application < Rails::Application
    config.before_initialize do
      puts "Loading secrets.."
      # Read encrypted secrets from .env.secret
      env_secret_file = File.open('.env.secret', 'rb')
      env_secret = env_secret_file.read
      env_secret_file.close

      # Set cipher to decryption mode
      decipher = OpenSSL::Cipher::AES256.new(:CBC)
      decipher.decrypt

      # Set decryption key from environment or prompt
      if ENV['ENV_KEY']
        deciper.key = ENV['ENV_KEY']
      else
        while true do
          key = IO.console.getpass('Secrets key: ')
          begin
            decipher.key = key
            break
          rescue OpenSSL::Cipher::CipherError
            puts 'Incorrect key'
          end
        end
      end


        # Load IV from .env.iv
        env_iv_file = File.open('.env.iv', 'rb')
        env_iv = env_iv_file.read
        env_iv_file.close

        # Set decryption key and iv
        begin
          decipher.key = ENV['ENV_KEY']
          decipher.iv = env_iv
        rescue OpenSSL::Cipher::CipherError
          puts "Incorrect key provided."
        end

        # Decrypt secrets file and write to environment variables
        env_plain = "#{decipher.update(env_secret)}#{decipher.final}"
        env_plain_yaml = YAML.load(env_plain)
        env_plain_yaml.each do |k, v|
          ENV[k] = v
        end

        puts "Secrets loaded."
      else
        puts "Secrets skipped."
      end
    end
  end
end
