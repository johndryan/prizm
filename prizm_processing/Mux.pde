class Mux {
   int id;
   String name;
   String url;
   String dob;
 
   Mux(int _id, String _name) {
     id = _id;
     name = _name;
     url = "http://multiplex.me/mux/" + id + "/";
     dob = "07-02-1982";
   }
   
   void update() {
     id++;
     name = "New MUX #" + id;
     url = "http://multiplex.me/mux/" + id + "/";
     dob = nf((int)random(12),2) + "-" + nf((int)random(31),2) + "-" + (int)random(1925,2005);
     //println(name);
   }
 }
