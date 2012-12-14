class Mux {
   int id, year, month, date, numOfDates, currentRow;
   String name;
   String url;
   String dob;
   String temp, forename, middle, surname;
   int[] whichFaces = new int[numUsersForMux];
   String[] dates;
 
   Mux(int _id, String _name) {
     id = _id;
     name = _name;
     url = "http://multiplex.me/mux/" + id + "/";
     dob = "07-02-1982";
     whichFaces = new int[numUsersForMux];
   }
   
   void update() {
      id++;
      
      println("New MUX #" + id);
      url = "http://multiplex.me/mux/" + id + "/";
      println("About to connect");
      if ( mysql.connect() ) {
        println("Connected");
        //MYSQL
        mysql.query( "SELECT id, forename, middle_name, surname, dob FROM user ORDER BY RAND() LIMIT " + numUsersForMux);
        currentRow = 0;
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
            dates = split(temp, '-');
            year += int(dates[0]);
            month += int(dates[1]);
            date += int(dates[2]);
            //println(dates[0] + "/" + dates[1] + "/" + dates[2]);
          } else {
            numOfDates--;
          }
          currentRow++;
        }
        
        if (numOfDates > 0) dob = year/numOfDates + "-" + month/numOfDates  + "-" + date/numOfDates;
        name = surname + ", " + forename + " " + middle;
      } else {
        println("Connection Failed!");
      }
      mysql.close();
      println("Closed");
   }
 }
