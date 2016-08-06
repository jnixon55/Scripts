
add = "tere"
added = "nothing"

file = File.open("add_luns", "r")
contents = file.read
puts contents   #=> Lorem ipsum etc.whileloop = 'cat add_luns | while read alias wwid

while read add added
  puts "#{add}"
  puts "#{added}"
end
