"""
An example of Vector Base Amplitude Panning. Inclues a 4 channel speaker array example where speakers are placed at azimuths of -55, 55, -110, and 110 degrees. Also includes a 7-channel surround sound example.

The position of the audio source is controlled by the mouse. The corners of the screen are positioned directly on top of the speakers.
"""

from mmm_python import *
from math import pi
# instantiate and load the graph
mmm_audio = MMMAudio(128, num_output_channels=4, graph_name="VectorBasePanning3D", package_name="examples")




def calc_speaker_triplets(speakers):
    triangles = []
    speaker_u = []
    speaker_v = []
    speaker_uvs = []
    for speaker in speakers:
        vec = [cos(speaker[0]) * cos(speaker[1]), sin(speaker[0]) * cos(speaker[1]), sin(speaker[1])]
        speaker_u.append(0.5 + (arctan2(vec[2], vec[0])/(2*pi)))
        speaker_v.append(0.5 + (arcsin(vec[1])/pi))
        speaker_uvs.append([(0.5 + speaker[1]) * cos(speaker[0]), (0.5 + speaker[1]) * sin(speaker[0])])


    for i in range(len(speakers) - 2):
          for j in range(len(speakers) - 2 - i):
               for k in range(len(speakers) - 2 - j - i):
                    triangles.append([i , i + 1 +  j, i + 2 + j + k])

    speaker_uvs = [[speaker_u[x], speaker_v[x]] for x in range(len(speakers))]
    return speaker_uvs




mmm_audio.start_audio()

mmm_audio.send_float("az", 0.2 * 2 * pi)
mmm_audio.send_float("az", 0.125 * 2 * pi)
mmm_audio.send_float("az", -0.25 * 2 * pi)
# mmm_audio.send_float("az", 0.375 * 2 * pi)
# mmm_audio.send_float("az", 0.5 * 2 * pi)
# mmm_audio.send_float("az", 0.625 * 2 * pi)
# mmm_audio.send_float("az", 0.75 * 2 * pi)
# mmm_audio.send_float("az", 0.875 * 2 * pi)

mmm_audio.send_float("ht", 0.35 * 2 * pi)


# This implementation of VBAP uses UV unwrapping and Delaunay triangulation to determine speaker triplets. The code below shows the triplet mapping.
from math import cos, sin, pi, sqrt
from numpy import arctan2, arcsin
from matplotlib import pyplot as plt
from scipy.spatial import Delaunay, delaunay_plot_2d
two_pi = 2 * pi
speaker_positions = [
    
    [-0.25 * pi, 0],
    [0.25 * pi, 0],
    [-0.25 * pi, 0.35 * pi],
    [0.25 * pi, 0.35 * pi],
    [0.25 * pi, -0.35 * pi],
    [-0.25 * pi, -0.35 * pi]
]


speaker_uvs = calc_speaker_triplets(speaker_positions)
# for speaker in speaker_positions:
#   speaker_uvs.append([(sin(speaker[0])) * cos(speaker[1]), sin(speaker[1])])




delaunay = Delaunay(speaker_uvs)

fig, ax = plt.subplots()
delaunay_plot_2d(delaunay, ax=ax)

for index, (x, y) in enumerate(speaker_uvs):
  ax.text(
      x + 0.01,
      y + 0.01,
      str(index),
      fontsize=12,
      color='red',
      weight='bold',
  )

# clicked = False
# def on_click(event):

#     clicked = not clicked # type: ignore
    

    
    

def on_move(event):
   
    az = arctan2(event.xdata, abs(event.ydata))
      
    el = arcsin(event.ydata)
    # print(az/pi, " ", el/pi)
    mmm_audio.send_float("az", az)
    
    mmm_audio.send_float("ht", el)
    pass
      


# plt.connect('button_press_event', on_click)
plt.connect('motion_notify_event', on_move)
plt.show()

#Enable/disable mouse
mmm_audio.send_bool("mouse", True)
mmm_audio.send_bool("mouse", False)

# for Wayland use the fake mouse
MMMAudio.fake_mouse()

mmm_audio.stop_audio()

mmm_audio.plot(48000)

