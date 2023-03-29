# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
password = Settings.default_admin_password
admin = User.find_or_initialize_by(admin: true)
admin.update!(email: "admin@api-placeholder.herokuapp.com", password: password, name: "Admin")

20.times.each do
  User.create!(email: Faker::Internet.email, password: 'Aa@12345678', name: Faker::Superhero.name)
end

40.times.each do
  blog = Blog.create!(title: Faker::Movie.title, content: Faker::Lorem.paragraphs.join("\n"))
  rand(0..100).times.each do
    blog.comments.create!(user: User.order("RAND()").first, content: Faker::Lorem.paragraphs.join("\n"))
  end
end
