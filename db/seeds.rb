# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Dir[Rails.root.join('db', 'seeds', '*.yaml')].each do |seed|
  documents = YAML.load_file(seed)
  klass = File.basename(seed, '.yaml').classify.constantize
  documents.each do |doc|
    klass.create(doc.last)
  end
end

Plan.find_by_name('Yearly').discounts.create({
  code: 'NbFuhV',
  percentage: 30.00,
  days_to_expire: 365
})