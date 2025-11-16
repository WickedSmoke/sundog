options [
    game_cheats:   false    "Enable cheats"
    psys_debugger: false    "Enable P-system command line debugger."
]

resource-cmd: "tools/resource_compiler.py -o src/sundog_resource_data.h"
foreach res [
    %swoosh/frame000.bmp
    %swoosh/frame001.bmp
    %swoosh/frame002.bmp
    %swoosh/frame003.bmp
    %swoosh/frame004.bmp
    %swoosh/frame005.bmp
    %swoosh/frame006.bmp
    %swoosh/frame007.bmp
    %swoosh/frame008.bmp
    %swoosh/frame009.bmp
    %swoosh/frame010.bmp

    %shaders/screen-hq4x.vert
    %shaders/screen-hqish.vert
    %shaders/screen.vert
    %shaders/screen.frag
    %shaders/screen-hq4x.frag
    %shaders/screen-hqish.frag
    %shaders/hq4x.bmp.gz
][
    appair resource-cmd ' ' res
]
gen %sundog_resource_data.h %shaders/screen-hq4x.vert resource-cmd

gen %src/game/game_debuginfo.h %tools/libcalls_list.py
    "tools/gen_debug_info.py src/game/game_debuginfo.h"

lib %psys [
    cflags "-Wno-unused-parameter"
    include_from [%src/psys %src]
    sources_from %src/psys [
        %psys_bootstrap.c
        %psys_debug.c
        %psys_interpreter.c
        %psys_opcodes.c
        %psys_registers.c
        %psys_rsp.c
        %psys_save_state.c
        %psys_set.c
        %psys_task.c
    ]
]

lib %game [
    cflags "-Wno-unused-parameter"
    include_from [
        %src
        %thirdparty/emu2149
        %/usr/include/SDL2
    ]
    sources_from %src [
        %game/game_gembind.c
        %game/game_screen.c
        %game/game_shiplib.c
        %game/game_sound.c
        %game/game_debug.c
        %game/wowzo.c
        %util/util_img.c
        %util/util_time.c
    ]
    if psys_debugger [
        sources [%util/debugger.c]
    ]
]

exe %sundog [
    cflags "-DUSE_SYSGL"
    if game_cheats [cflags "-DGAME_CHEATS"]
    include_from [
        %src
        %/usr/include/SDL2
    ]
    sources [
        %src/sundog.c
        %src/sundog_resources.c
        %src/swoosh.c
        %src/glutil.c
        %src/renderer_basic.c
        %src/renderer_hq4x.c
        %thirdparty/emu2149/emu2149.c
    ]
    libs_from %. [%game %psys]
    libs [%SDL2 %GL %m]
]

/*
if debug_ui [
    lib %debugui [
        sources [%debugui/debugui.cpp]
        libs [%imgui %SDL2]
    ]
]
*/

linux [
    exe %sundog_compare_trace [
        include_from %src
        sources [%src/sundog_compare_trace.c]
        libs_from %. [%game %psys]
        libs [%SDL2 %m]
    ]
    exe %rip_images [
        include_from %src
        sources [%src/rip_images.c %src/util/write_bmp.c]
        libs_from %. [%game %psys]
    ]
]
