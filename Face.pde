// source: https://courses.cs.washington.edu/courses/cse457/09au/lectures/triangle_intersection.pdf

class Face {
  PVector v1, v2, v3;
  float hue, saturation;
  PVector normal;
  float d;
  
  Face(PVector v1, PVector v2, PVector v3) {
    this.v1 = v1;  // A
    this.v2 = v2;  // B
    this.v3 = v3;  // C
    hue = 322+random(-2,2);
    saturation = 0;
    
    // solve for equation of triangle supporting plane
    // let n be normal and d be coefficient for plane
    normal = (PVector.sub(v2,v1).cross(PVector.sub(v3,v1))).normalize();
    d = normal.dot(v1);
  }
  
  // find t value where ray given by origin -> direction intersects triangle plane
  float dist(PVector origin, PVector direction) {
    // find parametric value of t where ray intersects plane of this face
    float t = (d - normal.dot(origin)) / normal.dot(direction);
    // find intersection point I given t and ray
    PVector I = PVector.add(origin, PVector.mult(direction, t));
    // determine if intersection point I lies within triangle ABC
    //  (triangle inside-outside testing)
    boolean AB, BC, AC;
    AB = (PVector.sub(v2,v1).cross(PVector.sub(I,v1))).dot(normal) >= 0;
    BC = (PVector.sub(v3,v2).cross(PVector.sub(I,v2))).dot(normal) >= 0;
    AC = (PVector.sub(v1,v3).cross(PVector.sub(I,v3))).dot(normal) >= 0;
    
    if (AB && BC && AC) return t; else return -1;
  }
  
  void render() {
    fill(hue, saturation, 360);
    vertex(v1.x,v1.y,v1.z);
    vertex(v2.x,v2.y,v2.z);
    vertex(v3.x,v3.y,v3.z);
  }
  
  void colorIn() {
    saturation= 360;
  }
  
}
