module Integration

export integrate

"Avança o sistems em um passo temporal"
function step!(system) end

"""
Cria e retorna o objeto que conterá os dados de uma integração
com `num_steps` passos temporais, inicializado com o primeito passo. 
"""
function init_data_object(system, num_steps) end

"""
Atualiza o objeto que contém os dados da integração para
o i-ésimo passo temporal.
"""
function update_data_object!(system, data, i) end

"Integra o sistema dado até o tempo `tf`"
function integrate(system, tf)
    num_steps = trunc(Int, tf / system.dt) + 1
    times = Array{Float64}(undef, num_steps)
    
    times[1] = 0
    data = init_data_object(system, num_steps)
    for i in 2:num_steps
        step!(system)
        times[i] = times[i-1] + system.dt
        update_data_object!(system, data, i)
    end

    return times, data
end

end