class Mux {
   int id, year, month, date, numOfDates;
   String name;
   String url;
   String dob;
   String temp, forename, middle, surname;
   int[] whichFaces = new int[numUsersForMux];
 
   Mux(int _id, String _name) {
     id = _id;
     name = _name;
     url = "http://multiplex.me/mux/" + id + "/";
     dob = "07-02-1982";
     whichFaces = new int[numUsersForMux];
   }
   
   void update() {
      id++;
      url = "http://multiplex.me/mux/" + id + "/";
      
      if ( mysql.connect() ) {
        //MYSQL
        mysql.query( "SELECT id, forename, middle_name, surname, dob FROM user ORDER BY RAND() LIMIT " + numUsersForMux);
        int currentRow = 0;
        forename = middle = surname = "";
        year = month = date = 0;
        numOfDates = numUsersForMux;
        
        while (mysql.next ()) {
          whichFaces[currentRow] = mysql.getInt("id");
          temp = mysql.getString("forename");
          if (temp.length() > 0) forename += temp.charAt((int)random(temp.length()));
          temp = mysql.getString("middle_name");
          if (temp != null) middle += temp.charAt((int)random(temp.length()));
          temp = mysql.getString("surname");
          if (temp.length() > 0) surname += temp.charAt((int)random(temp.length()));
          temp = mysql.getString("dob");
          if (temp != null) {
            year += int(temp.substring(0, 4));
            month += int(temp.substring(5, 7));
            date += int(temp.substring(8, 10));
            println(temp.substring(0, 4) + "/" + temp.substring(5, 7) + "/" + temp.substring(8,10));
          } else {
            numOfDates--;
          }
          currentRow++;
        }
        
        dob = int(year/numOfDates) + "-" + int(month/numOfDates)  + "-" + int(date/numOfDates);
        name = surname + ", " + forename + " " + middle;
      } 
      else {
        println("Connection Failed!");
      }
      //mysql.close();
   }
 }
