#!/usr/bin/bash
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[0;33m'

find ~ -type f | grep 'AhmedEhabDBMS.sh' > temp.txt 
scriptname=AhmedEhabDBMS.sh
mypath=`awk -F"/" -v n="$scriptname" 'BEGIN{i=1;m=""} {for(j=1;j<=NF;j++){if($j!=n){printf "%s/",$j}}} END{print ""} ' temp.txt `
rm temp.txt

cd $mypath

echo "User Name : `whoami`"
date

echo  "----------------------------------------------- Data Base Managment System ------------------------------------------------------ "

function mainMenu {
	PS3="DBMS Main Menu ==== > Enter Number of Command : "
select choise in CreateDB ListDB ConnectDB DropDB  Exit
do
	case $choise in
		CreateDB) CreateDB
			break;;

		ListDB)   clear;ListDB
			break;;

		ConnectDB) ConnectDB
			break;;

		DropDB)  DropDB
			break;;
		Exit) exit
			break;;

		*) echo -e "${RED}Synatx error :Invalid Command${NC}";mainMenu
			break;;
	esac
done
} 

function CreateDB {
     read  -p "Enter Database Name: " dbName
     if test -d database/$dbName
     then
	     echo -e "$dbName is Already Exist,try again!\n"
	     CreateDB
     else
	     mkdir -p database/$dbName
	     echo -e "=======================$dbName database is created===========================\n"
     fi
     mainMenu
}

function DropDB {
     read -p "Enter DataBase Name: " dropDb
     if test -d database/$dropDb
     then
	     read -p "Are you sure you want to delete $dropDb ?(y/n): " answer
	     if test $answer = "y"
	     then
		     rm -r database/$dropDb
		     echo -e "=====================$dropDb Is dropped=================================\n"
	     fi
     else
	     echo "$dropDb Not Exist!\n"
     fi
     mainMenu
}

function ListDB {

   echo -e "==================This Is List With Available Databases =========== \n"
   let i=1
   
   list=`ls database | wc -l`
   if test $list = "0"
   then
	echo no databaseses has been created!
   else
   	for DB in `ls database`
   	do
    
	   echo "$i)$DB"
	   i=$((i+1))
          
   	done
   fi
   echo
   mainMenu
}


function ConnectDB {
    read -p "Enter Database Name: " SelectDB
    if [[ -d database/$SelectDB ]] && [[ $SelectDB != "" ]]
    then
	    cd database/$SelectDB
	    TableMenu
    else
	    echo -e "${RED}Invalid Database Name,try agai!\n${NC}"
	    ConnectDB
    fi
}

function TableMenu {
        PS3="Table Menue ===== > Enter number of Command: "
	select action in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "return to main Menu" "Exit"
	do
		case $action in
			"Create Table") CreateTable
				break;;

			"List Tables")  ListTables
				break;;

			"Drop Table")   DropTable
				break;;

			"Insert into Table") InsertintoTable
				break;;

			"Select From Table") selectMenu
				break;;

			"Delete From Table") DeletefromTable
				break;;
			"return to main Menu") cd ../.. 2>> ./.error.log;
						mainMenu
						break;;
					"Exit")exit
						;;

			*) echo -e "${RED}Syntax error : Invalid Command${NC}"
				;;
		esac
	done
}

function CreateTable {
      
       read -p "Enter Table Name:" TableName
      
       if test -d $TableName
       then
	       echo -e "${RED}Table Already Exist,try again!\n${NC}"
	       CreateTable

       elif test $TableName = ""
       then
	       echo -e "${RED}Invalid Name ,try again\n${NC}"
               CreateTable
       else
       
	       mkdir $TableName
	       touch $TableName/$TableName"_"metadata
	       touch $TableName/$TableName"_"rawdata.CSV
               fieldSep=","
	       read -p "Enter Number of column : " NumberOfColumn
               echo -e "Table Name"$fieldSep"Columns Number"$fieldSep"Column Name"$fieldSep"Type of Column" >> $TableName/$TableName"_"metadata
	       echo -e $TableName$fieldSep$NumberOfColumn >> $TableName/$TableName"_"metadata
	      
	       for (( i = 1 ; i <= $NumberOfColumn ; i++ ))
	       do
		        read -p "Enter Name of Column No [$i]: " colName	  
                       
			 if (($i != $NumberOfColumn ))
			 then
 				 echo -n $colName$fieldSep >> $TableName/$TableName"_"rawdata.CSV
			 else
			   	 echo -e "$colName" >> $TableName/$TableName"_"rawdata.CSV
			 fi
		       
			PS3="Type of Column $colName (press 1 for int and 2 for str):  "
		       
			select dtype in int str
    			do
     			 case $dtype in
       				int) colType="int"
					 break;;

      			        str) colType="str"
					 break;;

			       	  *) echo -e "${RED}Syntax error :Invalid data type${NC}" 
					  break;;
       			 esac
   			 done

                        echo -e $fieldSep$fieldSep$colName$fieldSep$colType >> $TableName/$TableName"_"metadata
			
			
	       done

	       echo -e "======================= $TableName Table has been Created==========================\n"
	       TableMenu

       fi	       
}

function ListTables {
   echo -e "======================================This is Available Tables====================================== \n"
  
   let i=1  
   list=`ls | wc -l`
   if test $list = "0"
   then
	echo no Tables has been created!
   else
   	for table in `ls`
   	do
	   echo "$i)$table"
   	   i=$((i+1))
        done
   fi
   echo
   TableMenu
}

function DropTable {
     read -p "Enter table Name: " dropTable
     if test -d $dropTable
     then
	     read -p "Are you sure you want to delete $dbName ?(y/n): " answer
	     if test $answer = "y"
	     then
		     rm -r $dropTable
		     echo -e "=====================$dropTable table Is dropped=================================\n"
	     else
		     TableMenu
	     fi
     else
	     echo -e "${RED}$dropTable is not Exist,please try again${NC}"
	     DropTable
     fi
     TableMenu
}

function InsertintoTable {
     read -p "Enter table Name: " insertTable
     fieldSep=","   

     if test -d $insertTable
     then
              typeset -i  colNumbers=`awk -F"," '{if(NR == 2) print $2}' $insertTable/$insertTable"_"metadata` 
	                    
	      i=1
	      j=3
	       
	      for var in `awk -F"," '{if(NR > 2) print $3}' $insertTable/$insertTable"_"metadata`
	      do
		 coltype=`awk -F"," '{if(NR == var) print $4}' var="${j}" $insertTable/$insertTable"_"metadata`
        	# echo $coltype
		 read -p "Enter Value of $var : " value
		  
		 if (( $i == 1 ))
		  then
		          result=`awk -F"," '{if($1 == var) print $1 }' var="${value}" $insertTable/$insertTable"_"rawdata.CSV`
		  	 if test  "$result" != ""
		     	 then
			       echo -e "${RED}Syntax error:$var is a primary key of $insertTable and it must be unique,Start from Begining.${NC}" 
			    	    InsertintoTable 
		    	 fi
	        fi

		if [[ $coltype = "int" && "$value" = +([0-9]) || $coltype = "str" && "$value" = +([a-zA-Z]) ]]
	        then	
	       		 if (($i != $colNumbers ))
	       		 then
 		   		 echo -n $value$fieldSep >> $insertTable/$insertTable"_"rawdata.CSV
	       		 else
				 echo -e "$value" >> $insertTable/$insertTable"_"rawdata.CSV
		         fi
	
		else
			echo -e "${RED}Invalid data type ,Start from Begining.${NC}"
			InsertintoTable
		fi
 
		  	 
		    i=$((i+1))
		    j=$((j+1))
             done
	       


     else
          echo -e "${RED}$insertTable Not Exist${NC}"	     
     fi
     read -p "Are you want to insert more record?(y/n) : " ans
     if test $ans == 'y'
     then
	    InsertintoTable
     else 
    	 TableMenu
     fi

}

function selectMenu {

  echo -e "\n===================================== Select Menu =============================================\n"
  echo " 1. Select All Columns of a Table              "
  echo " 2. Select Specific Column from a Table        "
  echo " 3. Back To Tables Menu                        "
  echo " 4. Back To Main Menu                          "
  echo " 5. Exit                                       "
  
  read -p "Enter no of your Choice : " choice
 
  case $choice in
    1) selectAllColumns
	    break;;
    2) selectCol
	    break;;
    3) TableMenu
	    break;;
    4) cd ../.. 2>>./.error.log;
	    mainMenu 
	    break;;
    5) exit 
	    ;;
    *) echo -e "${RED}Syntax error :invalid command {NC}" ; selectMenu;
  esac
}

function selectAllColumns {
  read -p"Enter Table Name: " tName
  
  if test -d $tName
  then
	 column $tName/$tName"_"rawdata.CSV -t -s ","

  else
    echo -e "${RED}Error Displaying Table $tName ${NC}"
  fi
  selectMenu
}


function selectCol {
  read -p "Enter Table Name : " tbName
  let i=1 
  clear
  echo "list of columns in $tbName"
  for var in  ` awk -F"," '{if(NR > 2) print $3"     "}' $tbName/$tbName"_"metadata`
  do
	  echo "$i)$var"
	  i=$((i+1))
  done
  read -p "Enter Column Number to display it : " ColNum
  awk 'BEGIN{FS=","}{print $var}' var="${ColNum}" $tbName/$tbName"_"rawdata.CSV
  selectMenu
}

function DeletefromTable {
  read -p "Enter Table Name:" tbName

    pk=`head -n 1 $tbName/$tbName"_"rawdata.CSV | cut -f 1 -d "," `
    
    echo -e "${YELLOW} $pk is a primary key of $tbName ${NC}"
    read -p "Enter Value of $pk to delete it's record: " val
    res=`awk -F"," '{if($1 == var) print $1 }' var="${val}" $tbName/$tbName"_"rawdata.CSV`
    
   if test "$res" = ""
    then
	  echo -e "${RED}This value of $pk is not found!,try again${NC}"
	  DeletefromTable
    else
          sed -i "/^$val\b/Id" $tbName/$tbName"_"rawdata.CSV
    	  echo "Row Deleted Successfully"
     	  TableMenu
    fi
}

mainMenu
