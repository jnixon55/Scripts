use warnings;
use strict;
 
my $num1;
my $num2;
my $ans;
 
&menu;
sub menu
{
{
print
{"Welcome to Chris&#8217; Calculator",
"\n",
"1. Add\n",
"2. Subtract\n",
"3. Multiply\n",
"4. Divide\n",
"5. Exit\n",
"\n",
"What is your choice? (e.g "1", "2"; w/o the quotes)\n"
;}
 
my $choice = readline STDIN;
chomp ($choice);
 
if ($choice==1)
{&add;}
elsif ($choice == 2)
{&subt;}
elsif ($choice ==3)
{&mult;}
elsif ($choice == 4)
{&div;}
elsif ($choice == 5)
{print "Goodbye! Come again soon!\n";
exit;}
}