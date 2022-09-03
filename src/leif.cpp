#include "leif.h"

using namespace godot;



void LeifWorld::_process(float delta) {

}


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
    return LeifParticle::velocity;
}

void LeifParticle::set_velocity(Vector2 vel) {
    LeifParticle::velocity = vel;
}


void LeifParticle::_process(float delta) {
}


void LeifWorld::_register_methods() {
    register_method("_process", &LeifWorld::_process);
    // register_method("_rule", &LeifWorld::_rule);
    register_method("rule", &LeifWorld::rule);
    register_method("_gather_particles", &LeifWorld::_gather_particles);
    register_property<LeifWorld, Vector2>("WORLD_SIZE", &LeifWorld::WORLD_SIZE, Vector2(1500, 1000));
}

LeifWorld::LeifWorld() {
}

LeifWorld::~LeifWorld() {
    // add your cleanup here
}

void LeifWorld::_init() {
}


void LeifWorld::_gather_particles() {
    Array red_arr = get_tree()->get_nodes_in_group("red");
    Array green_arr = get_tree()->get_nodes_in_group("green");
    Array white_arr = get_tree()->get_nodes_in_group("white");
    Array blue_arr = get_tree()->get_nodes_in_group("blue");
    for (int i = 0; i < red_arr.size(); i++) {
        LeifWorld::red.push_back(red_arr[i]);
    }
    for (int i = 0; i < green_arr.size(); i++) {
        LeifWorld::green.push_back(green_arr[i]);
    }
    for (int i = 0; i < white_arr.size(); i++) {
        LeifWorld::white.push_back(white_arr[i]);
    }
    for (int i = 0; i < blue_arr.size(); i++) {
        LeifWorld::blue.push_back(blue_arr[i]);
    }
    LeifWorld::PARTICLE_COUNT_RED = red.size();
    LeifWorld::PARTICLE_COUNT_GREEN = green.size();
    LeifWorld::PARTICLE_COUNT_WHITE = white.size();
    LeifWorld::PARTICLE_COUNT_BLUE = blue.size();
}


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
    float g = G / -100;
    if (std::abs(G) < 0.1 || std::abs(radius) < 0.1) { return; }

    omp_set_num_threads(4);
    #pragma omp parallel for
    for (int i = 0; i < p1_length; i++) {
        LeifParticle* p1 = particles1[i];
        float fx = 0;
        float fy = 0;
        Vector2 p1pos = p1->get_position();
        for (int j = 0; j < p2_length; j++) {
            LeifParticle* p2 = particles2[j];
            Vector2 p2pos = p2->get_position();
            float dx = p1pos.x - p2pos.x;
            float dy = p1pos.y - p2pos.y;
            float r = std::sqrt(dx * dx + dy * dy);
            if (r < radius && r > 0.0) {
                fx += (dx / r);
                fy += (dy / r);
            }
        }

        Vector2 p1vel = p1->get_velocity();

        p1vel.x = (p1vel.x + (fx * g)) * 0.5;
        p1vel.y = (p1vel.y + (fy * g)) * 0.5;

        p1->set_position(p1pos + p1vel);

        if (((p1pos.x - WORLD_SIZE.x) > 0 && p1vel.x > 0) || (p1pos.x < 0 && p1vel.x < 0)) { p1vel.x *= -1;}
        if (((p1pos.y - WORLD_SIZE.y) > 0 && p1vel.y > 0) || (p1pos.y < 0 && p1vel.y < 0)) { p1vel.y *= -1;}
        p1->set_velocity(p1vel);

    }
}
