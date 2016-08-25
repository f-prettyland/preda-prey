static final String   DEFAULT_CONFIG_FILE_PATH    = "config.json";
static final String[] DEFAULT_SIGIL_STRING_COLORS = {
  "ffffb300", // Vivid Yellow
  "ff803e75", // Strong Purple
  "ffff6800", // Vivid Orange
  "ffa6bdd7", // Very Light Blue
  "ffc10020", // Vivid Red
  "ffcea262", // Grayish Yellow
  "ff817066", // Medium Gray
  "ff007d34", // Vivid Green
  "fff6768e", // Strong Purplish Pink
  "ff00538a", // Strong Blue
  "ffff745c", // Strong Yellowish Pink
  "ff53377a", // Strong Violet
  "ffff8e00", // Vivid Orange Yellow
  "ffb32851", // Strong Purplish Red
  "fff4c800", // Vivid Greenish Yellow
  "ff7f180d", // Strong Reddish Brown
  "ff93aa00", // Vivid Yellowish Green
  "ff593315", // Deep Yellowish Brown
  "fff13a13", // Vivid Reddish Orange
  "ff232c16", // Dark Olive Green
};

static boolean mouse_held = false;

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
  String bg_color = "fff5f5f5";

  int initial_tribe_count = 20;

  boolean tribes_mutate        = true;
  float   tribes_mutate_chance = 0.000001;

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

    this.bg_color = json.getString("bgColor", this.bg_color);

    this.initial_tribe_count = json.getInt("initialTribeCount", this.initial_tribe_count);

    this.tribes_mutate = json.getBoolean("tribesMutate", this.tribes_mutate);
    this.tribes_mutate_chance = json.getFloat("tribesMutateChance", this.tribes_mutate_chance);

    this.wait = json.getInt("wait", this.wait);

    try {
      String[] string_sigils = json.getJSONArray("sigils").getStringArray();
      for (int i = 0; i < string_sigils.length; i++) {
        this.sigils.add(string_sigils[i]);
      }
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
    println("Background Color = #" + this.bg_color);
    println("Initial Tribes = " + this.initial_tribe_count);
    println("Tribes Mutate? = " + this.tribes_mutate);
    println("Tribes Mutation Chance = " + this.tribes_mutate_chance);
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
  tribes = new Tribe[global_config.initial_tribe_count + 1];
  
  //blank is blank
  tribes[0] =  new Tribe(unhex(global_config.bg_color));
  for (int i = 1; i < tribes.length; i++) {
    tribes[i] = new Tribe(unhex(global_config.sigils.get((i - 1) % (global_config.sigils.size() - 1))));
  }

  //blank gets beaten by all
  Tribe white_crushers[] = new Tribe[tribes.length];
  for (int i = 1; i < tribes.length; i++) {
    white_crushers[i-1] = tribes[i];
  }
  tribes[0].addDominators(white_crushers);

  //adding each tribes predators
  int num_domniators = global_config.initial_tribe_count / 2;
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
  pointy_ones = new Pointy[width / global_config.cell_width][height / global_config.cell_height];
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
      lil_point.display(global_config.cell_width, global_config.cell_height);
    }
  }
  //Allow user to draw
  if(mouse_held){mouseHeld();};

  if(millis() - time >= global_config.wait){
    updateCells();
    // saveFrame("line-######.png");
    time = millis();
  }
}

void updateCells(){
  for (int i = 0; i < pointy_ones.length-1; i++) {
    for (int j = 0; j < pointy_ones[i].length-1; j++) {
      pointy_ones[i][j].update(pointy_ones[i+1][j], global_config.tribes_mutate, global_config.tribes_mutate_chance);
      pointy_ones[i][j].update(pointy_ones[i][j+1], global_config.tribes_mutate, global_config.tribes_mutate_chance);

    }
  }
  for (int i = pointy_ones.length-1; i > 0 ; i--) {
    for (int j =  pointy_ones[i].length-1; j > 0; j--) {
      pointy_ones[i][j].update(pointy_ones[i-1][j], global_config.tribes_mutate, global_config.tribes_mutate_chance);
      pointy_ones[i][j].update(pointy_ones[i][j-1], global_config.tribes_mutate, global_config.tribes_mutate_chance);
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
    Pointy this_point = pointy_ones[mouseX / global_config.cell_width][mouseY / global_config.cell_height];
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
 
  void update(Pointy fightee, boolean mutate, float mutation_chance) {
    if(mutate && random(1) < mutation_chance){
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
