module Animation

export AnimationCfg, VideoCfg
export animate

using GLMakie
using Pendulums.Integration: step!

"""
Configurações da animação.

- num_steps_per_frame:
    Número de passos temporais dados por frame.

- fps:
    Frames por segundo.

- offset_rel:
    Espaçamento extra do gráfico que contém o pêndulo, dado
    em relação ao tamnho do mesmo.
"""
@kwdef struct AnimationCfg
    num_steps_per_frame::Int=10
    fps::Int=30
    offset_rel::Float64=0.1
end

"""
Configurações para salvar um vídeo.

- path: 
    Caminho onde o vídeo será salvo (em relação 
    ao local onde o REPL está aberto).

- duration: 
    Duração em segundos do vídeo.

- anim_cfg:
    Configirações da animação (Ver docs de AnimCfg para mais informações).
"""
@kwdef struct VideoCfg
    path::String
    duration::Float64
    anim_cfg::AnimationCfg=AnimationCfg()
end

"""
Retorna dois vetores:
- xs: Posições no eixo x dos pontos que formam o pêndulo
- ys: Posições no eixo y dos pontos que formam o pêndulo
"""
function get_xy(system) end

"Retorna o comprimento máximo que o pêndulo pode ter."
function max_length(system) end

"""
Faz uma animação do sistema. Seu comporntamento depende
do tipo de `cfg`:

- AnimationCfg: Realiza a animação em tempo real.
- VideoCfg: Salva a animação em um vídeo.
"""
function animate(system, cfg=AnimationCfg())
    is_video = false
    anim_cfg = AnimationCfg()
    if typeof(cfg) == VideoCfg
        is_video = true
        anim_cfg = cfg.anim_cfg
    else 
        anim_cfg = cfg
    end

    l = max_length(system)

    fig = Figure()
    ax = Axis(fig[1, 1])
    
    ax.aspect = 1

    offset = l * anim_cfg.offset_rel
    GLMakie.xlims!(ax, -l - offset, l + offset)
    GLMakie.ylims!(ax, -l - offset, l + offset)

    x_line, y_line = get_xy(system)
    
    # x_obs = Observable(x)
    # y_obs = Observable(y)

    x_line_obs = Observable(x_line)
    y_line_obs = Observable(y_line)
    
    linesegments!(ax, x_line_obs, y_line_obs)
    GLMakie.scatter!(ax, x_line_obs, y_line_obs)
    
    function make_frame()
        for i in 1:anim_cfg.num_steps_per_frame
            step!(system)
        end
    
        xs, ys = get_xy(system)
        x_line[:] = xs
        y_line[:] = ys
        
        notify(x_line_obs)
        notify(y_line_obs)
    end
    
    if is_video
        num_frames = trunc(Int, anim_cfg.fps * cfg.duration)
        record(fig, cfg.path, 1:num_frames; framerate=anim_cfg.fps) do frame
            make_frame()
        end
    else
        display(fig)
        while events(fig).window_open[] 
            make_frame()
            sleep(1/anim_cfg.fps)
        end
    end
end

end