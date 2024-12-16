
# db/seeds.rb

puts "Seeding roles..."

roles = ['Head', 'Member (Adult)', 'Member (Child)']

roles.each do |role_name|
  Role.find_or_create_by!(name: role_name)
end

puts "Roles seeded successfully!"
