# preda-prey
Written in Processing, this program aims to create a predator-prey model where
the top predator gets eaten by the bottom prey. During the model a user can
click and hold to draw new in new defection/mutation with their mouse.

## 3 Groups Fighting Example
![](/out/example.gif)

## 20 Groups Fighting Examples with 0.000001% Defection Rate - No Interaction
### 500 initial tribe cells
![](/out/example-20-1.gif)

### 5000 initial tribe cells
[See animation](/out/example-20-2.gif)


Warning: 30 MB gif. <sub>Sorry about that.</sub>

## Running
If you have processing installed as a system package you can simply do:
```
make run
```
If you have installed processing to a custom location you can instead do:
```
make run processing-bin=/path/to/processing-java
```

## Configuration
The sketch looks for a `config.json` file in the directory that it is run from
and will load values if they are present.
All configurable values are optional and have sensible defaults which will be
loaded unless overriden.
Colors are specified as string representation of hex codes with the first
digit being the alpha channel and the following digits the standard RGB
values.

**cellHeight** and **cellWidth** (__Integers__):
Height/Width of each cell that can be occupied.

**windowHeight** and **windowWidth** (__Integers__):
Height/Width of the sketch window.

**bgColor** (__String__):
Background color of the sketch window.

**sigils** (__[String]__):
Array of colors that corrospond to each different tribe.

**initialTribeCount** (__String__):
Initial number of tribes at the start of the simulation.

**tribesMutate** (__Boolean__):
Enable/Disable tribes mutating.

**tribesMutateChance** (__Float__):
Chance ranging from 0.0 to 1.0 that a tribe will mutate.

**saveFrames** (__Boolean__):
Enable/Disable saving frames of every generated step to `out/frames`.

**clickMutate** (__Boolean__):
Enable/Disable the ability for user to hold down mouse to randomise selected
cells tribe.

## Todo
- Expand in 8 directions not just 4
- Increase values a lot
- Speed of infection, momentum for travelling waves of success
- Use this pattern as vector of movement for datamosh
