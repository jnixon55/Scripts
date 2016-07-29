def add(n1, n2)
  return n1 + n2
end

def subtract(n1, n2)
  return n1 - n2
end

def mult(n1, n2)
  return n1 * n2
end

def div(n1, n2)
  return n1 / n2
end

print("Enter First Number: ")
num1 = Float(gets)
print("Enter Second Number: ")
num2 = Float(gets)
print("Enter Operation (+,-,*,/): ")
op = gets
op = op.chomp
if op == "+"
  puts(add(num1, num2))
elsif op == "-"
  puts(subtract(num1, num2))
elsif op == "*"
  puts(mult(num1, num2))
elsif op == "div"
  put(div(num1, num2))
else
  put("Bad Operator")
end
