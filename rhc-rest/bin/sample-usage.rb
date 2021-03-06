#!/usr/bin/env ruby
# Copyright 2011 Red Hat, Inc.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require '../lib/rhc-rest'


if __FILE__ == $0
  
end_point = ARGV[0]
username = ARGV[1]
password = ARGV[2]
domain_id = ARGV[3]

if end_point.nil? or username.nil? or password.nil? or domain_id.nil?
  puts "Usage: https://<hostname>/broker/rest <username> <password> <domain_id>"
  exit 1
end

client = Rhc::Rest::Client.new(end_point, username, password)

puts "Creating a domain"
domain = client.add_domain(domain_id)
puts "Domain created: #{domain.id}"

puts "Getting all cartridges..."
client.cartridges.each do |cart|
  puts "  #{cart.name} (type: #{cart.type})"
end

puts "Creating application appone"
carts = client.find_cartridge("php-5.3")
domain.add_application("appone", carts.first.name)

puts "Try deleting domain with an application"
begin
  domain.delete
rescue Exception => e
  puts e.message
end

puts "Getting all domains and applications..."
client.domains.each do |domain|
  puts "  Domain: #{domain.id}"
  domain.applications.each do |app|
    puts "    Application: #{app.name}"
    app.cartridges.each do |cart|
      puts "      Cartridge #{cart.name} (#{cart.type})"
    end
  end
end

puts "Find application=appone and restart it..."
apps = client.find_application("appone")
apps.first.restart

apps = client.find_application("appthree")
if not apps.nil? and not apps.first.nil?
  apps.first.delete
end

puts "Create new application named appthree..."
app = client.domains.first.add_application("appthree", "php-5.3")
puts "Adding MySQL cartridge to appthree"
cartridge = app.add_cartridge("mysql-5.1")
puts "Check to see if it was added"
app.cartridges.each do |cart|
  puts "Cartridge #{cart.name} (#{cart.type})"
end

puts "Restart MySQL cartridge"
cartridge.restart
puts "Deleting MySQL cartridge"
cartridge.delete
puts "Check to see if it was deleted"
if app.cartridges.size == 0
  puts "MySQL cartridge is deleted"
end
puts "Deleting appthree"
app.delete
end

puts "Adding, updating and deleting keys"
key = client.user.add_key("newkey", "NEWKEYCONTENT", "ssh-rsa")

puts "Added key: #{key.name} updating key content"
key.update(key.type, "NEWKEYCONTENT123")

puts "Getting all keys..."
client.user.keys.each do |key|
  puts "  Key: #{key.name} (type: #{key.type}) #{key.content}"
end

puts "Deleting key"
begin
  key.delete
rescue Exception => e
  puts e.message
end

puts 'Clean up domains and apps by force deleting domain'
client.domains.each do |domain|
  domain.delete(true)
end

