
"""
An example of the DBAP algorithm for a 4 channel array of speakers at arbitrary locations.
"""

from mmm_python import *

# instantiate and load the graph
mmm_audio = MMMAudio(128, num_output_channels=4, graph_name="DBAPGraph", package_name="examples")
mmm_audio.start_audio() 

mmm_audio.send_floats("pos", 0, 0)

# set the frequency to a random value
from random import random
mmm_audio.send_float("freq", random() * 500 + 100) # set the frequency to a random value

mmm_audio.stop_audio()

mmm_audio.stop_process()

exit()