static final String   DEFAULT_CONFIG_FILE_PATH    = "config.json";
static final String[] DEFAULT_SIGIL_STRING_COLORS = {"fff5f5f5", "ffcc6600", "ff71025c", "ff5382a1"};

Pointy pointy_ones[][];
Tribe tribes[];
int time;

Config global_config;

/**
 * Stores the current configuration state of the application.
 */
class Config {
  int cell_height = 1;
  int cell_width = 1;

  int window_height = 300;
  int window_width  = 300;

  ArrayList<String> sigils = new ArrayList<String>();

  int wait = 1;

  /**
   * Add the default sigil colors.
   */
  void use_default_sigils() {
    for (int i = 0; i < DEFAULT_SIGIL_STRING_COLORS.length; i++) {
      this.sigils.add(DEFAULT_SIGIL_STRING_COLORS[i]);
    }
  }

  /**
   * Attempt to load configuration values from a JSON file.
   *
   * @param path Path to the configuration file.
   */
  boolean load_from_file(String path) {
    File config_file = new File(path);

    if (!config_file.exists()) {
      this.use_default_sigils();

      return false;
    }

    JSONObject json = loadJSONObject(path);

    this.cell_height = json.getInt("cellHeight", this.cell_height);
    this.cell_width  = json.getInt("cellWidth", this.cell_width);

    this.window_height = json.getInt("windowHeight", this.window_height);
    this.window_width = json.getInt("windowWidth", this.window_width);

    try {
      String[] string_sigils = json.getJSONArray("sigils").getStringArray();
      for (int i = 0; i < string_sigils.length; i++) {
        this.sigils.add(string_sigils[i]);
      }

      this.wait = json.getInt("wait", this.wait);
    } catch (RuntimeException e) {
      this.use_default_sigils();
    }

    return true;
  }

  /**
   * Print the current configuration state of the application to stdout.
   */
  void print_state() {
    println("Window (Width,Height) = (" + this.window_width + "," + this.window_height + ")");
    println("Cell (Width,Height) = (" + this.cell_width + "," + this.cell_height + ")");
    println("Number of Sigils = " + this.sigils.size());
    println("Wait = " + this.wait);
  }
}

void settings() {
  global_config = new Config();

  global_config.load_from_file(DEFAULT_CONFIG_FILE_PATH);
  global_config.print_state();

  size(global_config.window_width, global_config.window_height);
}

void setup()
{
  //generate tribes
  tribes = new Tribe[global_config.sigils.size()];
  for (int i = 0; i < global_config.sigils.size(); i++) {
    tribes[i] = new Tribe(unhex(global_config.sigils.get(i)));
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
  pointy_ones = new Pointy[width / global_config.cell_width][height / global_config.cell_height];
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
      lil_point.display(global_config.cell_width, global_config.cell_height);
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
 
  void display(int cell_width, int cell_height) {
    fill(tribe.getCol());
    rect(cell_width * xP, cell_height * yP, cell_width, cell_height);
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
