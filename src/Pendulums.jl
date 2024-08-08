module Pendulums

export Normal
export integrate
export animate, VideoCfg, AnimationCfg

include("integration.jl")
include("animation.jl")
include("normal.jl")

using .Animation
using .Integration

end
