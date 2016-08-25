static final int hei = 5;
static final int wid = 5;
//Using Kellys Colours 
static final color background = #f5f5f5;
static final color[] sigils = {#FFB300, //Vivid Yellow
#803E75, //Strong Purple
#FF6800, //Vivid Orange
#A6BDD7, //Very Light Blue
#C10020, //Vivid Red
#CEA262, //Grayish Yellow
#817066, //Medium Gray
#007D34, //Vivid Green
#F6768E, //Strong Purplish Pink
#00538A, //Strong Blue
#FF7A5C, //Strong Yellowish Pink
#53377A, //Strong Violet
#FF8E00, //Vivid Orange Yellow
#B32851, //Strong Purplish Red
#F4C800, //Vivid Greenish Yellow
#7F180D, //Strong Reddish Brown
#93AA00, //Vivid Yellowish Green
#593315, //Deep Yellowish Brown
#F13A13, //Vivid Reddish Orange
#232C16,}; //Dark Olive Green
static final int num_of_tribes = 20;
static final int wait = 0;
static final boolean muatate = true;
static final float mutation_chance = 0.000001;
static boolean mouse_held = false;

Pointy pointy_ones[][];
Tribe tribes[];
int time;

void setup()
{
  size(600, 600);

  //generate tribes
  tribes = new Tribe[num_of_tribes+1];
  
  //blank is blank
  tribes[0] =  new Tribe(background);
  for (int i = 1; i < tribes.length; i++) {
    tribes[i] = new Tribe(sigils[(i-1)%(sigils.length-1)]);
  }

  //blank gets beaten by all
  Tribe white_crushers[] = new Tribe[tribes.length];
  for (int i = 1; i < tribes.length; i++) {
    white_crushers[i-1] = tribes[i];
  }
  tribes[0].addDominators(white_crushers);
  //adding each tribes predators
  int num_domniators = num_of_tribes/2;
  for (int i = 1; i < tribes.length; i++) {
    Tribe temp[] = new Tribe[num_domniators];
    //iterate over each new denominator
    for (int j = 0; j < num_domniators; j++) {
      int denom_index = i+1+j;
      if(denom_index >= tribes.length){
        denom_index = denom_index%tribes.length;
      }
      temp[j] = tribes[denom_index];
    }
    tribes[i].addDominators(temp);
  }

  //create blank points
  pointy_ones = new Pointy[width/wid][height/hei];
  for (int i = 0; i < pointy_ones.length; i++) {
    for (int j = 0; j < pointy_ones[i].length; j++) {
      pointy_ones[i][j] = new Pointy(i, j, tribes[0]);
    }
  }
  for (int i = 0; i < 500; i++) {
    int rand_x = int(random(pointy_ones.length));
    int rand_y = int(random(pointy_ones[0].length));
    int rand_tri = int(random(tribes.length-1))+1;
    pointy_ones[rand_x][rand_y] = new Pointy(rand_x,rand_y, tribes[rand_tri]);
  }

  time = millis();
}

void draw()
{
  noStroke();
  for(Pointy[] point_line : pointy_ones){
    for(Pointy lil_point : point_line){
      lil_point.display();
    }
  }
  //Allow user to draw
  if(mouse_held){mouseHeld();};

  if(millis() - time >= wait){
    updateCells();
    // saveFrame("line-######.png");
    time = millis();
  }
}

void updateCells(){
  for (int i = 0; i < pointy_ones.length-1; i++) {
    for (int j = 0; j < pointy_ones[i].length-1; j++) {
      pointy_ones[i][j].update(pointy_ones[i+1][j]);
      pointy_ones[i][j].update(pointy_ones[i][j+1]);

    }
  }
  for (int i = pointy_ones.length-1; i > 0 ; i--) {
    for (int j =  pointy_ones[i].length-1; j > 0; j--) {
      pointy_ones[i][j].update(pointy_ones[i-1][j]);
      pointy_ones[i][j].update(pointy_ones[i][j-1]);
    }
  }
}

void mousePressed(){
  mouse_held = true;
}

void mouseReleased(){
  mouse_held = false;
}

void mouseHeld() {
  if(mouseX>0 && mouseY>0 && mouseX<width-1 && mouseY<height-1){
    Pointy this_point = pointy_ones[mouseX/wid][mouseY/hei];
    this_point.setTribe(tribes[int(random(tribes.length-1))+1]);
  }
}
 
class Pointy 
{
  float xP, yP;
  boolean beat = false;
  Tribe tribe;
  Pointy(float xp, float yp, Tribe tr) {
    xP = xp;
    yP = yp;
    tribe = tr;
  }
 
  void update(Pointy fightee) {
    //mutate
    if(muatate && random(1) < mutation_chance){
      tribe = tribes[int(random(tribes.length-1))+1];
      return;
    }
    Tribe other_tribe = fightee.getTribe();
    int result = tribe.getsBeat(other_tribe);
    if(result == 1){
      if(beat){
        return;
      }
      fightee.setTribe(tribe);
    }else if(result == -1){
      if(fightee.isBeat()){
        return;
      }
      beat = true;
      tribe = other_tribe;
    }
  }

  Tribe getTribe(){
    return tribe;
  }

  boolean isBeat(){
    return beat;
  }

  void setTribe(Tribe tr){
    tribe = tr;
    beat = true;
  }
 
  void display() {
    fill(tribe.getCol());
    rect(wid*xP, hei*yP, hei, wid);
    beat =false;
  }
}
 
class Tribe 
{
  color sigil;
  Tribe[] dominators;
  Tribe(color sig){
    sigil = sig;
  }

  void addDominators(Tribe[] domin){
    dominators = domin;
  }

  int getsBeat(Tribe t){
    if(this == t){
      return 0;
    }
    for(Tribe dom : dominators){
      if (t == dom){
        return -1;
      }
    }
    return 1;
  }

  color getCol(){
    return sigil;
  }
}