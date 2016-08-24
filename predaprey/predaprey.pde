static final int hei = 1; 
static final int wid = 1; 
static final color[] sigils = {#f5f5f5, #CC6600, #71025c, #5382a1};
static final int wait = 1;

Pointy pointy_ones[][];
Tribe tribes[];
int time;

void setup()
{
  size(300, 300);

  //generate tribes
  tribes = new Tribe[sigils.length];
  for (int i = 0; i < sigils.length; i++) {
    tribes[i] = new Tribe(sigils[i]);
  }
  Tribe temp[] = {tribes[1],tribes[2],tribes[3]};
  tribes[0].addDominators(temp);
  Tribe temp1[] = {tribes[2]};
  tribes[1].addDominators(temp1);
  Tribe temp2[] = {tribes[3]};
  tribes[2].addDominators(temp2);
  Tribe temp3[] = {tribes[1]};
  tribes[3].addDominators(temp3);

  //create blank points
  pointy_ones = new Pointy[width/wid][height/hei];
  for (int i = 0; i < pointy_ones.length; i++) {
    for (int j = 0; j < pointy_ones[i].length; j++) {
      pointy_ones[i][j] = new Pointy(i, j, tribes[0]);
    }
  }


  for (int i = 0; i < 80; i++) {
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
  // if(millis() - time >= wait){
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
    saveFrame("line-######.png");
  //   time = millis();
  // }
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