from mmm_audio import *

struct DBAPDust(Movable, Copyable):
    var world: World  
    var dust: Dust[1]
    var messenger: Messenger
    var pos: MFloat[2]
    

    def __init__(out self, world: World):
        self.world = world
        self.dust = Dust[1](world)
        self.pos = MFloat[2](0, 0)
        self.messenger = Messenger(self.world)
        
        

    def next[speakers: InlineArray[MFloat[2], 4], weights: InlineArray[Float64, 4]](mut self) -> MFloat[next_power_of_two(4)]:
        self.messenger.update("pos", self.pos)
        var sig = self.dust.next()
        new_pos = self.pos * MFloat[2](1.0, 1.0)
        out = dbap2D[
            4,
            speakers,
            weights,
             ](sig, new_pos)

        return out
        pass

# there can only be one graph in an MMMAudio instance
# a graph can have as many synths as you want
struct DefaultGraph(Movable, Copyable):
    var world: World
    var synth: DBAPDust
  

    def __init__(out self, world: World):
        self.world = world
        self.synth = DBAPDust(self.world)
        

    def next(mut self) -> MFloat[next_power_of_two(4)]:
        comptime speakers : InlineArray[MFloat[2], 4]= [
            MFloat[2](-1, 1), 
            MFloat[2](1, 1),
            MFloat[2](-1, -1),
            MFloat[2](1, -1)
        ]

        comptime weights : InlineArray[Float64, 4] = [1.0,1.0,1.0,1.0]

        return self.synth.next[speakers, weights]()  # Get the next sample from the synth