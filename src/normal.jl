"Pêndulo normal, composto por um fio rígido com massa desprezível e massa pontual."
module Normal

export DynamicCfg, State, System

using Pendulums: Animation, Integration

@kwdef struct DynamicCfg
    alpha::Float64
    g::Float64
    l::Float64
end

@kwdef mutable struct State{T}
    theta::T
    omega::T
end

@kwdef struct System{T}
    state::State{T}
    configs::DynamicCfg
    dt::Float64
end

###
# Animation Stuff
###

function Animation.max_length(system::System)
    system.configs.l
end

function Animation.get_xy(system::System)
    l = system.configs.l
    theta = -π/2 + system.state.theta
    return [0.0, l * cos(theta)], [0.0, l * sin(theta)]
end

###
# Integration Stuff
###

struct Data
    theta::Vector{Float64}
    omega::Vector{Float64}
end
Data(length) = Data(Vector(undef, length), Vector(undef, length))

function Integration.init_data_object(system::System, num_steps)
    data = Data(num_steps)
    data.theta[1] = system.state.theta
    data.omega[1] = system.state.omega
    return data
end

function Integration.update_data_object!(system::System, data::Data, i)
    state = system.state
    data.theta[i] = state.theta
    data.omega[i] = state.omega
end

function Integration.step!(system::System)
    state = system.state
    dt = system.dt
    g, l, alpha = system.configs.g, system.configs.l, system.configs.alpha

    theta, omega1 = state.theta, state.omega

    state.omega += -g/l * sin(theta) * dt + alpha * randn() * dt^0.5
    state.theta += (state.omega + omega1) / 2 * dt
end

end