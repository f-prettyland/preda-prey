# preda-prey
Written in Processing, this program aims to create a predator-prey model where the top predator gets eaten by the bottom prey.

## 3 Groups Fighting Example
![](/out/example.gif)

## 20 Groups Fighting Examples with 0.000001% Defection Rate
### 500 initial tribe cells
![](/out/example-20-1.gif)

### 5000 initial tribe cells
![](/out/example-20-2.gif)

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

## Todo
- Increase values a lot
- Speed of infection
- Add interactive
	+ input values
