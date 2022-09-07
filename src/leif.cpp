#include "leif.h"

using namespace godot;


void LeifParticle::_register_methods() {
    register_method("_process", &LeifParticle::_process);
    register_property<LeifParticle, Vector2>("velocity", &LeifParticle::velocity, Vector2(0, 0));
}

LeifParticle::LeifParticle() {
}

LeifParticle::~LeifParticle() {
    // add your cleanup here
}

void LeifParticle::_init() {
    // initialize any variables here
}

Vector2 LeifParticle::get_velocity() {
    return velocity;
}

void LeifParticle::set_velocity(Vector2 vel) {
    velocity = vel;
}

Vector2 LeifParticle::get_pos() {
    return pos;
}

void LeifParticle::set_pos(Vector2 p) {
    pos = p;
}
void LeifParticle::set_pos_x(float x) {
    pos.x = x;
}
void LeifParticle::set_pos_y(float y) {
    pos.y = y;
}

void LeifParticle::_process(float delta) {
}


void LeifWorld::_register_methods() {
    register_method("_process", &LeifWorld::_process);
    register_method("rule", &LeifWorld::rule);
    register_method("set_viscosity", &LeifWorld::set_viscosity);
    register_method("_gather_particles", &LeifWorld::_gather_particles);
    register_property<LeifWorld, Vector2>("WORLD_SIZE", &LeifWorld::WORLD_SIZE, Vector2(1920, 1080));
    register_property<LeifWorld, int>("BOUNDS_TYPE", &LeifWorld::BOUNDS_TYPE, BOUNDS_STRICT);
}

LeifWorld::LeifWorld() {
}

LeifWorld::~LeifWorld() {
    // add your cleanup here
}


void LeifWorld::_init() {
}

void LeifWorld::set_viscosity(float v) {
    LeifWorld::viscosity = 1.0 - v;
}

void LeifWorld::_gather_particles() {
    Godot::print("Gathering particles");

    Array red_arr = get_tree()->get_nodes_in_group("red");
    Array green_arr = get_tree()->get_nodes_in_group("green");
    Array white_arr = get_tree()->get_nodes_in_group("white");
    Array blue_arr = get_tree()->get_nodes_in_group("blue");
    for (int i = 0; i < red_arr.size(); i++) {
        LeifParticle* p = red_arr[i];
        p->set_pos(p->get_position());
        LeifWorld::red.push_back(p);
    }
    for (int i = 0; i < green_arr.size(); i++) {
        LeifParticle* p = green_arr[i];
        p->set_pos(p->get_position());
        LeifWorld::green.push_back(p);
    }
    for (int i = 0; i < white_arr.size(); i++) {
        LeifParticle* p = white_arr[i];
        p->set_pos(p->get_position());
        LeifWorld::white.push_back(p);
    }
    for (int i = 0; i < blue_arr.size(); i++) {
        LeifParticle* p = blue_arr[i];
        p->set_pos(p->get_position());
        LeifWorld::blue.push_back(p);
    }
    LeifWorld::PARTICLE_COUNT_RED = red.size();
    LeifWorld::PARTICLE_COUNT_GREEN = green.size();
    LeifWorld::PARTICLE_COUNT_WHITE = white.size();
    LeifWorld::PARTICLE_COUNT_BLUE = blue.size();
}

// This is the method called by GDScript, which wraps the _rule method
void LeifWorld::rule(int p1name, int p2name, float G, float radius) {
    std::vector<LeifParticle *> p1arr;
    std::vector<LeifParticle *> p2arr;
    int p1_l = 1000;
    int p2_l = 1000;
    switch(p1name) {
        case RED:
            p1arr = red;
            p1_l = PARTICLE_COUNT_RED;
            break;
        case GREEN:
            p1arr = green;
            p1_l = PARTICLE_COUNT_GREEN;
            break;
        case WHITE:
            p1arr = white;
            p1_l = PARTICLE_COUNT_WHITE;
            break;
        case BLUE:
            p1arr = blue;
            p1_l = PARTICLE_COUNT_BLUE;
            break;
        default:
            p1arr = red;
    }
    switch(p2name) {
        case RED:
            p2arr = red;
            p2_l = PARTICLE_COUNT_RED;
            break;
        case GREEN:
            p2arr = green;
            p2_l = PARTICLE_COUNT_GREEN;
            break;
        case WHITE:
            p2arr = white;
            p2_l = PARTICLE_COUNT_WHITE;
            break;
        case BLUE:
            p2arr = blue;
            p2_l = PARTICLE_COUNT_BLUE;
            break;
        default:
            p2arr = red;
    }
    _rule(p1arr, p2arr, G, radius, p1_l, p2_l);
}

void LeifWorld::_rule(std::vector<LeifParticle *> particles1, std::vector<LeifParticle *> particles2, float G, float radius, int p1_length, int p2_length) {
    if (std::abs(G) < 0.1 || std::abs(radius) < 1.0) { return; }
    const float g = G / -100;

    omp_set_num_threads(4);
    omp_set_nested(true);
    #pragma omp parallel for
    for (int i = 0; i < p1_length; i++) {
        LeifParticle* p1 = particles1[i];
        const Vector2 p1pos = p1->get_pos();
        float fx = 0;
        float fy = 0;

        for (int j = 0; j < p2_length; j++) {
            LeifParticle* p2 = particles2[j];
            const Vector2 p2pos = p2->get_pos();

            float virt_pos_x = p2pos.x;
            float virt_pos_y = p2pos.y;

            if (BOUNDS_TYPE == BOUNDS_REPEATING) {
                float smallest_dist= -1;

                // loop through all 9 quadrants with the current screen space being 
                // quad_x= 0, quad_y= 0 ( treated no different)
                for(int quad_x= -1; quad_x <= 1; quad_x++) {
                    for(int quad_y= -1; quad_y <= 1; quad_y++)
                    {
                        // virtual position of p2 in current quadrant
                        float quad_pos_x = p2pos.x + quad_x * WORLD_SIZE.x;
                        float quad_pos_y = p2pos.y + quad_y * WORLD_SIZE.y;
                        
                        float dx = p1pos.x - quad_pos_x;
                        float dy = p2pos.y - quad_pos_y;
                        
                        float fast_dist= dx * dx + dy * dy;
                        if(smallest_dist == -1 || smallest_dist > fast_dist)
                        {
                            smallest_dist = fast_dist;
                            virt_pos_x = quad_pos_x;
                            virt_pos_y = quad_pos_y;
                        }
                    }
                }
            }


            const float dx = p1pos.x - virt_pos_x;
            const float dy = p1pos.y - virt_pos_y;
            const float r = std::sqrt(dx * dx + dy * dy);


            if (r > 0 && r < radius) {
                fx += (dx / r);
                fy += (dy / r);
            }
        }

        Vector2 p1vel = p1->get_velocity();

        p1vel.x = (p1vel.x + (fx * g)) * viscosity;
        p1vel.y = (p1vel.y + (fy * g)) * viscosity;

        if (BOUNDS_TYPE == BOUNDS_STRICT) {
            if ((p1pos.x - WORLD_SIZE.x) > 0 && p1vel.x > 0) { p1vel.x *= -1; p1->set_pos_x(WORLD_SIZE.x);} 
            else if (p1pos.x < 0 && p1vel.x < 0) { p1vel.x *= -1; p1->set_pos_x(0); }
            else if ((p1pos.y - WORLD_SIZE.y) > 0 && p1vel.y > 0) { p1vel.y *= -1; p1->set_pos_y(WORLD_SIZE.y);} 
            else if (p1pos.y < 0 && p1vel.y < 0) { p1vel.y *= -1; p1->set_pos_y(0); }
        } else if (BOUNDS_TYPE == BOUNDS_REPEATING) {
            if ((p1pos.x - WORLD_SIZE.x) > 0) { p1->set_pos_x(0);} 
            else if (p1pos.x < 0) { p1->set_pos_x(WORLD_SIZE.y); }
            else if ((p1pos.y - WORLD_SIZE.y) > 0) { p1vel.y *= -1; p1->set_pos_y(0);} 
            else if (p1pos.y < 0) { p1->set_pos_y(WORLD_SIZE.y); }
        }

        p1->set_velocity(p1vel);

    }

    // Update positions of all particles in particles1
    for (int i = 0; i < p1_length; i++) {
        LeifParticle* p1 = particles1[i];
        const Vector2 new_pos = p1->get_pos() + p1->get_velocity();
        p1->set_position(new_pos);
        p1->set_pos(new_pos);
    }
}

void LeifWorld::_process(float delta) {
}
