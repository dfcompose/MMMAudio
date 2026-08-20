from mmm_audio import *

# THE SYNTH


struct VectorBasePanning3D(Movable, Copyable):
    var world: World  
    var dust: Dust[1] 
    var messenger: Messenger
    var az: Float64
    var ht: Float64
    var filt: Reson[1]
    var wsl: Int
    var pos: List[Float64]
    var mouse: Bool
    var vbap: VBAP3D[8]
    def __init__(out self, world: World):
        self.world = world
        self.dust = Dust[1](world)
        self.filt = Reson[1](world)
        self.messenger = Messenger(self.world)
        self.az = 0.0
        self.ht = 0.0
        self.wsl = 0
        self.pos = [0.0, -1.0]
        self.mouse = False
        self.vbap = VBAP3D[8]([
            MFloat[2](deg_to_rad(-55), deg_to_rad(55)),
            MFloat[2](deg_to_rad(55), deg_to_rad(55)),
            MFloat[2](deg_to_rad(-55), deg_to_rad(-55)),
            MFloat[2](deg_to_rad(55), deg_to_rad(-55)),
            MFloat[2](deg_to_rad(-110), deg_to_rad(110)),
            MFloat[2](deg_to_rad(110), deg_to_rad(110)),
            MFloat[2](deg_to_rad(-110), deg_to_rad(-110)),
            MFloat[2](deg_to_rad(110), deg_to_rad(-110)),
            ])

        
    def next(mut self) -> MFloat[8]:
        
        comptime two_pi = 2 * pi

        self.messenger.update("az", self.az)
        self.messenger.update("ht", self.ht)
        self.messenger.update("pos", self.pos)
        self.messenger.update("mouse", self.mouse)
       
        
     
        # comptime offset = deg_to_rad(90)
        if self.mouse:
            var x = linlin(self.world[].mouse_x(), 0.0, 1.0, 0.0, 2.0 * pi)
            var y = linlin(self.world[].mouse_y(), 0.0, 1.0, 0.0, 2.0 * pi)
            self.az = x
            self.ht = y
        # self.world[].print("Hello?")
        var sig = self.dust.next(10, 40) * 0.5
        sig = self.filt.bpf(sig, 1200, 10.0, 1.0)

        # if self.messenger.notify_update("ht", self.ht):
        #     _ = self.vbap.next[8](sig, self.az, self.ht)
        var out = self.vbap.next[8](sig, self.az, self.ht)
        # var out = MFloat[8](0.0)
        self.world[].print(self.vbap.active_triplet)
        
        return out * 0.5


