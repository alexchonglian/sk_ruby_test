#modified after https://gist.github.com/enriclluelles/1423950

require 'csv'
require 'json'
require 'enumerator'

if ARGV.size != 2
  puts 'Usage: ruby csv2json.rb input_file.csv output_file.json'
  puts 'This script uses the first line of the csv file as the keys for the JSON properties of the objects'
  exit(1)
end

lines = CSV.open(ARGV[0]).readlines
keys = lines.delete(lines.first)

#abstract the modifier logic out to this method
def generate_modifer (flat_modifiers)
  #programming defensively
  return [] unless flat_modifiers
  #flat = [name1, price1, name2, price2, name3, price3]
  #grouped = [[name1, price1], [name2, price2], [name3, price3]]
  grouped_modifiers = flat_modifiers.each_slice(2).to_a
  result = grouped_modifiers.map do |pair|
    #pair = [name, price]
    name = pair[0]
    price = pair[1]
    {:name => name, :price => generate_price(price)} if name && price
  end
end

# "-$125.0" => -125.0
def generate_price(price_str)
  return nil unless price_str
  return price_str.tr('$','').to_f
end



File.open(ARGV[1], 'w') do |f|
  data = lines.map do |values|
    {
    :id => values[0],
    :description => values[1],
    :price => generate_price(values[2]),
    :cost => generate_price(values[3]),
    :price_type => values[4],
    :quantity_on_hand => values[5],
    :modifier => generate_modifer(values[6, values.size-1])
    }
  end
  f.puts JSON.pretty_generate(data)
end