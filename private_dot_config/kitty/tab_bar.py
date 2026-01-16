from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import DrawData, TabBarData, ExtraData, as_rgb
from kitty.utils import color_as_int

opts = get_options()

BG = as_rgb(color_as_int(opts.background))
COLOR_INACTIVE = as_rgb(color_as_int(opts.color3))
COLOR_ACTIVE = as_rgb(color_as_int(opts.color5))

tabs: list[TabBarData] = []

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global tabs

    tabs.append(tab)

    if is_last:
        # Hide tab bar if only 1 tab
        if len(tabs) == 1:
            tabs = []
            return screen.cursor.x

        # Calculate total width
        total_width = len(tabs) * 3 - 1  # "N" + spaces between
        start_x = (screen.columns - total_width) // 2

        screen.cursor.x = start_x
        for idx, t in enumerate(tabs):
            if idx != 0:
                screen.draw(" ")

            color = COLOR_ACTIVE if t.is_active else COLOR_INACTIVE

            screen.cursor.bg = color
            screen.cursor.fg = BG
            screen.cursor.bold = True
            screen.draw(f" {t.tab_id} ")
            screen.cursor.bold = False
            screen.cursor.bg = 0

        tabs = []

    return screen.cursor.x
