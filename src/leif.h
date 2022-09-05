#ifndef LEIFPARTICLE_H
#define LEIFPARTICLE_H

#include <Godot.hpp>
#include <Node2D.hpp>
#include <SceneTree.hpp>
#include <String.hpp>
#include <omp.h>
#include <RID.hpp>
#include <VisualServer.hpp>
#include <Transform2D.hpp>
#include <vector>

const int RED = 0;
const int GREEN = 1;
const int WHITE = 2;
const int BLUE = 3;

typedef wchar_t CharType;

namespace godot {


class LeifParticle : public Node2D {
    GODOT_CLASS(LeifParticle, Node2D)

private:
    Vector2 velocity = Vector2(0, 0);


public:
    static void _register_methods();
    Vector2 get_velocity();
    void set_velocity(Vector2 vel);

    LeifParticle();
    ~LeifParticle();

    void _init(); // our initializer called by Godot

    void _process(float delta);
};


class LeifWorld : public Node2D {
    GODOT_CLASS(LeifWorld, Node2D)

private:
    VisualServer* Visual;
    Vector2 WORLD_SIZE = Vector2(750, 750);

    float PARTICLE_RADIUS = 6.0;
    int PARTICLE_COUNT_RED = 1000;
    int PARTICLE_COUNT_GREEN = 1000;
    int PARTICLE_COUNT_WHITE = 1000;
    int PARTICLE_COUNT_BLUE = 1000;

    std::vector<LeifParticle *> red;
    std::vector<LeifParticle *> green;
    std::vector<LeifParticle *> white;
    std::vector<LeifParticle *> blue;

// const GROUPS := ["yellow", "red", "green"]

public:
    static void _register_methods();

    LeifWorld();
    ~LeifWorld();   

    void _init(); // our initializer called by Godot

    void _process(float delta);

    void _gather_particles();
    void _rule(std::vector<LeifParticle *> particles1, std::vector<LeifParticle *> particles2, float G, float radius, int p1_length, int p2_length);
    void rule(int p1name, int p2name, float G, float radius);
};


}
#endif