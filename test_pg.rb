require "pg"
begin
  conn = PG.connect(host: "172.17.0.2", port: 5432, user: "postgres", password: "123")
  puts "Connected!"
  conn.close
rescue => e
  puts "Error: #{e.message}"
end