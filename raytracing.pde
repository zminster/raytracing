final float velocity_movement = 5;
final float player_height = 100;
final int jump_frame_limit = 73;
final float jump_speed = 2.9;
final float gravity = 0.08;
float phi, theta, body_theta;  // for camtrans
PVector cam_position;
boolean up, left, down, right, jump;
float jump_velocity;
int jump_frame;
ArrayList<Face> faces;
PImage img_crosshair;

void setup() {
  fullScreen(P3D);
  colorMode(HSB, 360);
  
  noCursor();

  phi = 0;
  theta = 0;
  body_theta = 0;
  cam_position = new PVector(100, 100, 100);
  up = false;
  left = false;
  down = false;
  right = false;
  jump = false;
  jump_velocity = 0;
  jump_frame = 0;
  
  PVector v1, v2, v3, v4;
  float noiseScale = 0.01;
  float mountainScale = 75;
  int differential = 4;
  faces = new ArrayList<Face>();
  for (int x = 0; x < 500; x+=differential) {
    for (int z = 0; z < 500; z+=differential) {
      v1 = new PVector(x,noise(x*noiseScale,z*noiseScale)*mountainScale,z);
      v2 = new PVector(x+differential,noise((x+differential)*noiseScale,z*noiseScale)*mountainScale,z);
      v3 = new PVector(x,noise(x*noiseScale,(z+differential)*noiseScale)*mountainScale,z+differential);
      v4 = new PVector(x+differential,noise((x+differential)*noiseScale,(z+differential)*noiseScale)*mountainScale,z+differential);
      faces.add(new Face(v1,v3,v2));
      faces.add(new Face(v2,v3,v4));
    }
  }
  
  img_crosshair = loadImage("crosshair.png");
}

void draw() {
  perspective(PI/3.0, width/height, cam_position.z/1000.0, cam_position.z*1000.0);
  clear();
  if (mousePressed)
    mousePressed();
  handleKeyMovement();
  handleJump();
  camtrans();
  //drawAxes();
  noStroke();
  //lights();
  directionalLight(120,360,100,1,0,0);
  directionalLight(240,360,100,-1,0,0);
  directionalLight(360,360,100,0,1,0);
  directionalLight(60,360,100,0,-1,0);
  directionalLight(180,360,100,0,0,1);
  directionalLight(320,100,100,0,0,-1);
  directionalLight(0,0,150,0,-1,0);
  beginShape(TRIANGLES);
  for (Face f : faces)
    f.render();
  endShape();
  
  set(width/2-60,height/2-60,img_crosshair);
}

void handleJump() {
  cam_position.y += jump_velocity;
  jump_velocity -= gravity;
  if (cam_position.y <= 0) {
    cam_position.y = 0;
  }
}

void camtrans() {
  theta = map(mouseX, width / 20, width - width / 20, PI / 6, - PI / 6);
  phi = map(mouseY, height, 0, -PI, - PI / 2 + PI / 12);
  if (mouseX < width / 20)  // turning body left
    body_theta += PI/60;
  else if (mouseX > width - width / 20)  // turning body right
    body_theta -= PI/60;

  float look_x, look_y, look_z;
  look_x = cam_position.x + sin(phi) * cos(theta + body_theta);
  look_y = (cam_position.y + player_height) + cos(phi);
  look_z = cam_position.z + sin(phi) * sin(theta + body_theta);
  camera(cam_position.x, (cam_position.y + player_height), cam_position.z, look_x, look_y, look_z, 0, -1, 0);
}

void drawAxes() {
  strokeWeight(3);
  stroke(0, 100, 100);
  line(0, 0, 0, 1000, 0, 0);
  stroke(33, 100, 100);
  line(0, 0, 0, 0, 1000, 0);
  stroke(66, 100, 100);
  line(0, 0, 0, 0, 0, 1000);
  stroke(0,0,0);
  strokeWeight(1);
}

void handleKeyMovement() {
  float delta_x = 0;
  float delta_z = 0;
  float velocity_factor = velocity_movement / ((up ? 1 : 0) + (left ? 1 : 0) + (right ? 1 : 0) + (down ? 1 : 0));
  if (up) {
    delta_x += -cos(body_theta + theta) * velocity_factor;
    delta_z += -sin(body_theta + theta) * velocity_factor;
  }
  if (left) {
    delta_x += cos(body_theta + theta - PI / 2) * velocity_factor;
    delta_z += sin(body_theta + theta - PI / 2) * velocity_factor;
  }
  if (down) {
    delta_x += cos(body_theta + theta) * velocity_factor;
    delta_z += sin(body_theta + theta) * velocity_factor;
  }
  if (right) {
    delta_x += cos(body_theta + theta + PI / 2) * velocity_factor;
    delta_z += sin(body_theta + theta + PI / 2) * velocity_factor;
  }
  if (jump && frameCount - jump_frame > jump_frame_limit) {
    jump_velocity = jump_speed;
    jump_frame = frameCount;
  }
  cam_position.x += delta_x;
  cam_position.z += delta_z;
}

void setMove(char key, boolean pressed) {
  if (key == 'w')
    up = pressed;
  else if (key == 'a')
    left = pressed;
  else if (key == 's')
    down = pressed;
  else if (key == 'd')
    right = pressed;
  else if (key == ' ')
    jump = pressed;
}

void keyReleased() {
  setMove(key, false);
}

void keyPressed() {
  setMove(key, true);
}

void mousePressed() {
  // convert mouse click point to vector in form (center, direction)
  // C is camera point, P is passthru point, together CP define a ray
  PVector origin = new PVector(cam_position.x, (cam_position.y + player_height), cam_position.z);
  PVector direction = new PVector(sin(phi) * cos(theta + body_theta), cos(phi), sin(phi) * sin(theta + body_theta));
  // TODO: direction right now is the CENTER of the camera
  // how do we offset it to figure out where mouse currently is?
  
  // determine t* value (and validity) for all faces:
  Face hit = null;
  float d, dist = 1000000;
  for (Face f : faces) {
    d = f.dist(origin, direction);
    if (d < dist && d != -1) {
      hit = f;
      dist = d;
    }
  }
  
  // color in collided face (if available)
  if (hit != null)
    hit.colorIn();
}
