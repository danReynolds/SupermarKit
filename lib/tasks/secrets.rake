namespace :secrets do
  desc 'encrypt secrets and writes them to env.secret'
  task :encrypt do
    # Fetch plaintext secrets from .env.yml
    env_plain_file = File.open('.env.yml', 'rb')
    env_plain = env_plain_file.read
    env_plain_file.close

    # Set cipher to encryption mode and provide key/IV
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    while true
      begin
        cipher.key = IO.console.getpass('Secrets key: ')
        break
      rescue OpenSSL::Cipher::CipherError
        puts "Invalid key. Key must be 32 characters."
      end
    end
    iv = cipher.random_iv

    # IV is public and stored at .env.iv
    env_iv_file = File.open('.env.iv', 'wb')
    env_iv_file.write(iv)
    env_iv_file.close

    # Encrypt secrets and store at .env.secret
    env_encrypted = "#{cipher.update(env_plain)}#{cipher.final}"
    env_secret_file = File.open('.env.secret', 'wb')
    env_secret_file.write(env_encrypted)
    env_secret_file.close

    puts 'Encrypted to .env.secret; REMOVE plaintext secrets file.'
  end
end
