aliasid=`grep "ONTAP" delete_luns.txt | rev | cut -d'/' -f 1 | rev|awk -F\. '{print $1}'`
lunid=`grep "LUN:" delete_luns.txt |cut -d \: -f2`
lsize=`grep "LUN Size:" delete_luns.txt |cut -d \: -f2 |sed 's/g//'`
wwid=`grep "Host Device" delete_luns.txt | awk 'NR > 1 {print $1}' RS='(' FS=')'|grep -v 36006`

echo $aliasid | sed 's/ /\n/g' > aliasid.txt
echo $lunid | sed 's/ /\n/g' > lunid.txt
echo $lsize | sed 's/ /\n/g' > lsize.txt
echo $wwid  | sed 's/ /\n/g' > wwid.txt

paste  aliasid.txt  lsize.txt  lunid.txt  wwid.txt | awk '{print $1 "," $2 "," $3 "," $4 ",oracle,dba"}' > final.txt

for i in `cat final.txt`; do
  aliasid=`echo $i | awk -F, '{print $1}'`
  lsize=`echo $i | awk -F, '{print $2}' | awk -F\. '{print $1}'`
  lunid=`echo $i | awk -F, '{print $3}'`
   wwid=`echo $i | awk -F, '{print $4}'`
  echo "$aliasid,$lunid,$lsize,$wwid,oracle,dba"
done

rm -rf aliasid.txt
rm -rf lunid.txt
rm -rf lsize.txt
rm -rf wwid.txt
