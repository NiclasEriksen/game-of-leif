# Game of Leif

Game of Leif is (*kind of*) a cellular automata that is based purely on attraction and repulsion. It is built in Godot 3.5 with the heavy calculations done in C++ through GDNative.

![](https://i.imgur.com/8imeUUk.png)

------

### Status

------

**Prototype.** There is a lot of performance still to be squeezed out of this, and to move the simulation into a separate thread so the UI can be processed independently at a higher frame rate. Expect 15-30fps on mid-range CPU's with 3400 particles.

------

### Inspiration

------

This method is based on a brilliant video by Brainxyz. The complexity of the "organisms" with such simple rules, and their succinct and passionate description of it, made me jump in my seat and I immediately got to work reimplementing it in Godot. This kind of particle interaction is nothing new, but what stood out to me is the sheer variety of behavior you can get through tweaking the parameters.

Check out their video here (it's well worth the watch): https://www.youtube.com/watch?v=0Kx4Y9TVMGg

Here is the code for their simulator (C++): https://github.com/hunar4321/life_code

The patterns seen in their README should (for the most part) easily be reproducible in Leif.

------

### How it works

------

We have 4 sets of particles in different colors. These will either pull or push other particles based on their color, which is defined by a set of rules. We have one rule for each color combination, to a total of 16 (4x4), and they're specified like this: particle color, other color, attraction force (negative is push), and radius in which particles will be affected.

A red particle might pull on a green particle, while the green particle pushes on the red, which will end in an equilibrium at a certain distance based on their strength. The interesting part is when you add another color, e.g. blue, and it might pull on *both* red and green while being repulsed by them. This will disturb the equilibrium and perhaps cause an oscillation/vibration. Throw *another* color in to the mix, and the results becomes too hard to predict.

This is obviously very computationally heavy as each particle will pull or push on *all* other particles(-1) in range every frame, in this simulations current state that means each potentially up to 11.5 *million* interactions every cycle.

------

### Added features so far

------

- Presets with ability to create your own
- Import/Export the rules to a string, in order to share discoveries
- Randomizer for the parameters
- Shader effects (just glow for now)
- Ambient particles
- Windows and Linux binaries

------

### Build instructions

------

I will add a brief description later of how to build the libraries for running the simulation, but if you're already familiar with the GDNative workflow this should be a breeze.
